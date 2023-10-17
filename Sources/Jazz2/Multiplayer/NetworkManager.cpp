﻿#include "NetworkManager.h"

#if defined(WITH_MULTIPLAYER)

#include "INetworkHandler.h"
#include "../../nCine/Base/Timer.h"

// <mmeapi.h> included by "enet.h" still uses `far` macro
#define far

#define ENET_IMPLEMENTATION
#define ENET_FEATURE_ADDRESS_MAPPING
#if defined(DEATH_DEBUG)
#	define ENET_DEBUG
#endif
#include "Backends/enet.h"

// Undefine it again after include
#undef far

#define MAX_CLIENTS 64

namespace Jazz2::Multiplayer
{
	NetworkManager::NetworkManager()
		: _initialized(false), _host(nullptr), _state(NetworkState::None), _handler(nullptr)
	{
		int error = enet_initialize();
		RETURN_ASSERT_MSG(error == 0, "Initialization failed with error %i", error);
		_initialized = (error == 0);
	}

	NetworkManager::~NetworkManager()
	{
		Dispose();

		if (_initialized) {
			enet_deinitialize();
		}
	}

	bool NetworkManager::CreateClient(INetworkHandler* handler, const char* address, std::uint16_t port, std::uint32_t clientData)
	{
		if (!_initialized || _host != nullptr) {
			return false;
		}

		_host = enet_host_create(nullptr, 1, (std::size_t)NetworkChannel::Count, 0, 0);
		RETURNF_ASSERT_MSG(_host != nullptr, "Failed to create client");

		//enet_host_compress_with_range_coder(host);

		_state = NetworkState::Connecting;

		ENetAddress addr = { };
		enet_address_set_host(&addr, address);
		addr.port = port;

		ENetPeer* peer = enet_host_connect(_host, &addr, (std::size_t)NetworkChannel::Count, clientData);
		if (peer == nullptr) {
			LOGE("Failed to create peer");
			_state = NetworkState::None;
			enet_host_destroy(_host);
			_host = nullptr;
			return false;
		}

		_peers.push_back(peer);

		_handler = handler;
		_thread.Run(NetworkManager::OnClientThread, this);
		return true;
	}

	bool NetworkManager::CreateServer(INetworkHandler* handler, std::uint16_t port)
	{
		if (!_initialized || _host != nullptr) {
			return false;
		}

		ENetAddress addr = { };
		addr.host = ENET_HOST_ANY;
		addr.port = port;

		_host = enet_host_create(&addr, MAX_CLIENTS, (std::size_t)NetworkChannel::Count, 0, 0);
		RETURNF_ASSERT_MSG(_host != nullptr, "Failed to create server");

		_handler = handler;
		_state = NetworkState::Listening;
		_thread.Run(NetworkManager::OnServerThread, this);
		return true;
	}

	void NetworkManager::Dispose()
	{
		if (_host == nullptr) {
			return;
		}

		for (auto& peer : _peers) {
			enet_peer_disconnect_now(peer, 0);
		}

		_state = NetworkState::None;
		_thread.Join();

		// Should be already destroyed by the thread
		//enet_host_destroy(_host);

		_host = nullptr;
	}

	NetworkState NetworkManager::GetState() const
	{
		return _state;
	}

	void NetworkManager::SendToPeer(const Peer& peer, NetworkChannel channel, const std::uint8_t* data, std::size_t dataLength)
	{
		ENetPeer* target;
		if (peer == nullptr) {
			if (_state != NetworkState::Connected || _peers.empty()) {
				return;
			}

			target = _peers[0];
		} else {
			target = peer._enet;
		}

		enet_uint32 flags;
		if (channel == NetworkChannel::Main) {
			flags = ENET_PACKET_FLAG_RELIABLE;
		} else {
			flags = ENET_PACKET_FLAG_UNSEQUENCED;
		}

		ENetPacket* packet = enet_packet_create(data, dataLength, flags);

		_lock.Lock();
		if (enet_peer_send(target, (std::uint8_t)channel, packet) < 0) {
			enet_packet_destroy(packet);
		} else if (channel == NetworkChannel::UnreliableUpdates) {
			enet_host_flush(_host);
		}
		_lock.Unlock();
	}

	void NetworkManager::SendToAll(NetworkChannel channel, const std::uint8_t* data, std::size_t dataLength)
	{
		if (_peers.empty()) {
			return;
		}

		enet_uint32 flags;
		if (channel == NetworkChannel::Main) {
			flags = ENET_PACKET_FLAG_RELIABLE;
		} else {
			flags = ENET_PACKET_FLAG_UNSEQUENCED;
		}

		ENetPacket* packet = enet_packet_create(data, dataLength, flags);

		_lock.Lock();
		bool success = false;
		for (ENetPeer* peer : _peers) {
			if (enet_peer_send(peer, (std::uint8_t)channel, packet) >= 0) {
				success = true;
			}
		}
		if (!success) {
			enet_packet_destroy(packet);
		} else if (channel == NetworkChannel::UnreliableUpdates) {
			enet_host_flush(_host);
		}
		_lock.Unlock();
	}

	void NetworkManager::OnClientThread(void* param)
	{
		NetworkManager* _this = reinterpret_cast<NetworkManager*>(param);
		INetworkHandler* handler = _this->_handler;
		ENetHost* host = _this->_host;

		ENetEvent ev;
		std::int32_t n = 10;
		while (n > 0) {
			if (_this->_state == NetworkState::None) {
				n = 0;
				break;
			}

			if (enet_host_service(host, &ev, 1000) >= 0 && ev.type == ENET_EVENT_TYPE_CONNECT) {
				break;
			}

			n--;
		}

		if (n <= 0) {
			LOGE("Failed to connect to the server");
			_this->_state = NetworkState::None;
		} else {
			_this->_state = NetworkState::Connected;
			handler->OnPeerConnected(ev.peer, ev.data);

			while (_this->_state != NetworkState::None) {
				_this->_lock.Lock();
				std::int32_t result = enet_host_service(host, &ev, 0);
				_this->_lock.Unlock();
				if (result <= 0) {
					if (result < 0) {
						LOGE("enet_host_service() returned %i", result);
						break;
					}
					Timer::sleep(10);
					continue;
				}

				switch (ev.type) {
					case ENET_EVENT_TYPE_RECEIVE:
						handler->OnPacketReceived(ev.peer, ev.channelID, ev.packet->data, ev.packet->dataLength);
						enet_packet_destroy(ev.packet);
						break;

					case ENET_EVENT_TYPE_DISCONNECT:
						_this->_state = NetworkState::None;
						break;

					case ENET_EVENT_TYPE_DISCONNECT_TIMEOUT:
						_this->_state = NetworkState::None;
						break;
				}
			}
		}

		handler->OnPeerDisconnected(_this->_peers[0], 0);

		for (ENetPeer* peer : _this->_peers) {
			//enet_peer_reset(peer);
			enet_peer_disconnect(peer, 1);
		}
		_this->_peers.clear();

		enet_host_destroy(_this->_host);
		_this->_host = nullptr;
		_this->_handler = nullptr;

		_this->_thread.Detach();

		LOGD("Client thread exited");
	}

	void NetworkManager::OnServerThread(void* param)
	{
		NetworkManager* _this = reinterpret_cast<NetworkManager*>(param);
		INetworkHandler* handler = _this->_handler;
		ENetHost* host = _this->_host;

		ENetEvent ev;
		while (_this->_state != NetworkState::None) {
			_this->_lock.Lock();
			std::int32_t result = enet_host_service(host, &ev, 0);
			_this->_lock.Unlock();
			if (result <= 0) {
				if (result < 0) {
					LOGE("enet_host_service() returned %i", result);
					break;
				}
				Timer::sleep(10);
				continue;
			}

			switch (ev.type) {
				case ENET_EVENT_TYPE_CONNECT:
					if (handler->OnPeerConnected(ev.peer, ev.data)) {
						_this->_peers.push_back(ev.peer);
					} else {
						enet_peer_disconnect_now(ev.peer, 1);
					}
					break;

				case ENET_EVENT_TYPE_RECEIVE:
					handler->OnPacketReceived(ev.peer, ev.channelID, ev.packet->data, ev.packet->dataLength);
					enet_packet_destroy(ev.packet);
					break;

				case ENET_EVENT_TYPE_DISCONNECT:
					handler->OnPeerDisconnected(ev.peer, ev.data);
					break;

				case ENET_EVENT_TYPE_DISCONNECT_TIMEOUT:
					handler->OnPeerDisconnected(ev.peer, 0);
					break;
			}
		}

		for (ENetPeer* peer : _this->_peers) {
			//enet_peer_reset(peer);
			enet_peer_disconnect(peer, 1);
		}
		_this->_peers.clear();

		enet_host_destroy(_this->_host);
		_this->_host = nullptr;
		_this->_handler = nullptr;

		_this->_thread.Detach();

		LOGD("Server thread exited");
	}
}

#endif