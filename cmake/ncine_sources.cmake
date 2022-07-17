set(SOURCES
	${NCINE_ROOT}/Shared/SmallVector.cpp
	${NCINE_ROOT}/Shared/Utf8.cpp
)

list(APPEND SOURCES
	${NCINE_SOURCE_DIR}/nCine/Base/BitArray.cpp
	${NCINE_SOURCE_DIR}/nCine/Base/Clock.cpp
	${NCINE_SOURCE_DIR}/nCine/Base/FrameTimer.cpp
	${NCINE_SOURCE_DIR}/nCine/Base/HashFunctions.cpp
	${NCINE_SOURCE_DIR}/nCine/Base/Object.cpp
	${NCINE_SOURCE_DIR}/nCine/Base/Random.cpp
	${NCINE_SOURCE_DIR}/nCine/Base/Timer.cpp
	${NCINE_SOURCE_DIR}/nCine/Base/TimeStamp.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/AnimatedSprite.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/BaseSprite.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/Camera.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/DrawableNode.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/Geometry.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GfxCapabilities.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLAttribute.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLBlending.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLBufferObject.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLClearColor.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLCullFace.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLDebug.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLDepthTest.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLFramebuffer.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLRenderbuffer.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLScissorTest.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLShader.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLShaderProgram.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLShaderUniformBlocks.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLShaderUniforms.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLTexture.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLUniform.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLUniformBlock.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLUniformBlockCache.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLUniformCache.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLVertexArrayObject.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLVertexFormat.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/GL/GLViewport.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/IGfxDevice.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/ITextureLoader.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/ITextureSaver.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/Material.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/MeshSprite.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/Particle.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/ParticleAffectors.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/ParticleInitializer.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/ParticleSystem.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RectAnimation.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RenderBatcher.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RenderBuffersManager.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RenderCommand.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RenderCommandPool.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RenderQueue.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RenderResources.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RenderStatistics.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/RenderVaoPool.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/SceneNode.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/ScreenViewport.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/Sprite.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/Texture.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/TextureFormat.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/TextureLoaderDds.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/TextureLoaderKtx.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/TextureLoaderPvr.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/TextureLoaderRaw.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/TextureLoaderPng.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/TextureLoaderQoi.cpp
	${NCINE_SOURCE_DIR}/nCine/Graphics/Viewport.cpp
	${NCINE_SOURCE_DIR}/nCine/Input/IInputManager.cpp
	${NCINE_SOURCE_DIR}/nCine/Input/JoyMapping.cpp
	${NCINE_SOURCE_DIR}/nCine/IO/FileSystem.cpp
	${NCINE_SOURCE_DIR}/nCine/IO/IFileStream.cpp
	${NCINE_SOURCE_DIR}/nCine/IO/MemoryFile.cpp
	${NCINE_SOURCE_DIR}/nCine/IO/StandardFile.cpp
	${NCINE_SOURCE_DIR}/nCine/Primitives/Color.cpp
	${NCINE_SOURCE_DIR}/nCine/Primitives/Colorf.cpp
	${NCINE_SOURCE_DIR}/nCine/Primitives/ColorHdr.cpp
	${NCINE_SOURCE_DIR}/nCine/AppConfiguration.cpp
	${NCINE_SOURCE_DIR}/nCine/Application.cpp
	${NCINE_SOURCE_DIR}/nCine/ArrayIndexer.cpp
	${NCINE_SOURCE_DIR}/nCine/ServiceLocator.cpp
#	${NCINE_SOURCE_DIR}/nCine/Base/CString.cpp
#	${NCINE_SOURCE_DIR}/nCine/Base/String.cpp
#	${NCINE_SOURCE_DIR}/nCine/Base/Utf8.cpp
#	${NCINE_SOURCE_DIR}/nCine/FileLogger.cpp
#	${NCINE_SOURCE_DIR}/nCine/FntParser.cpp
#	${NCINE_SOURCE_DIR}/nCine/Font.cpp
#	${NCINE_SOURCE_DIR}/nCine/FontGlyph.cpp
#	${NCINE_SOURCE_DIR}/nCine/Graphics/TextNode.cpp
)

list(APPEND SOURCES
	${NCINE_SOURCE_DIR}/Main.cpp
	${NCINE_SOURCE_DIR}/Jazz2/ActorBase.cpp
	${NCINE_SOURCE_DIR}/Jazz2/ContentResolver.cpp
	${NCINE_SOURCE_DIR}/Jazz2/LevelHandler.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Player.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/PlayerCorpse.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/SolidObjectBase.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Collectibles/AmmoCollectible.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Collectibles/CarrotCollectible.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Collectibles/CoinCollectible.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Collectibles/CollectibleBase.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Collectibles/FoodCollectible.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Enemies/Bat.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Enemies/EnemyBase.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Enemies/Turtle.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Enemies/TurtleShell.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Environment/BonusWarp.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Environment/Checkpoint.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Environment/Spring.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Weapons/BlasterShot.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Weapons/BouncerShot.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Actors/Weapons/ShotBase.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Collisions/DynamicTree.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Collisions/DynamicTreeBroadPhase.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Events/EventMap.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Events/EventSpawner.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Tiles/TileMap.cpp
	${NCINE_SOURCE_DIR}/Jazz2/Tiles/TileSet.cpp
)