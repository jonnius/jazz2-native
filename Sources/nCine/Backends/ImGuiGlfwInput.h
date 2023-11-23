#pragma once

#if defined(WITH_IMGUI) && defined(WITH_GLFW)

#include <imgui.h>

struct GLFWwindow;
struct GLFWmonitor;
struct GLFWcursor;

namespace nCine
{
	/// The class that handles GLFW input for ImGui
	class ImGuiGlfwInput
	{
	public:
		static void init(GLFWwindow* window, bool withCallbacks);
		static void shutdown();
		static void newFrame();

		static inline void setInputEnabled(bool inputEnabled) {
			inputEnabled_ = inputEnabled;
		}

	private:
		static bool inputEnabled_;

		static GLFWwindow* window_;
		static GLFWwindow* mouseWindow_;
		static double time_;
		static GLFWcursor* mouseCursors_[ImGuiMouseCursor_COUNT];
		static ImVec2 lastValidMousePos_;
		static bool installedCallbacks_;

		static void mouseButtonCallback(GLFWwindow* window, int button, int action, int mods);
		static void scrollCallback(GLFWwindow* window, double xoffset, double yoffset);
		static void keyCallback(GLFWwindow* window, int keycode, int scancode, int action, int mods);
		static void windowFocusCallback(GLFWwindow* window, int focused);
		static void cursorPosCallback(GLFWwindow* window, double x, double y);
		static void cursorEnterCallback(GLFWwindow* window, int entered);
		static void charCallback(GLFWwindow* window, unsigned int c);
		static void monitorCallback(GLFWmonitor* monitor, int event);

		static void installCallbacks(GLFWwindow* window);
		static void restoreCallbacks(GLFWwindow* window);

		static void updateMouseData();
		static void updateMouseCursor();
		static void updateGamepads();
	};
}

#endif