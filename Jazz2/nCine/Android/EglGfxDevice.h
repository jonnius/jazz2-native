#pragma once

#include "../Graphics/IGfxDevice.h"
#include "../Graphics/DisplayMode.h"
#include "../Primitives/Vector2.h"

#include <EGL/egl.h>
#include <EGL/eglext.h>

struct android_app;

namespace nCine {

	/// The EGL based graphics device
	class EglGfxDevice : public IGfxDevice
	{
	public:
		/// Constructor taking a `DisplayMode` object
		EglGfxDevice(struct android_app* state, const GLContextInfo& glContextInfo, const DisplayMode& displayMode);
		~EglGfxDevice() override;

		void setSwapInterval(int interval) override { }

		void setResolution(bool fullscreen, int width = 0, int height = 0) override { }

		inline void update() override {
			eglSwapBuffers(display_, surface_);
		}

		void setWindowPosition(int x, int y) override { }
		void setWindowTitle(const StringView& windowTitle) override { }
		void setWindowIcon(const StringView& windowIconFilename) override { }

		/// Recreates a surface from a native window
		void createSurface(struct android_app* state);
		/// Binds the current context
		void bindContext();
		/// Unbinds the current context
		void unbindContext();
		/// Queries the size of the current surface
		void querySurfaceSize();

		/// Checks if the desired pixel format is supported
		static bool isModeSupported(struct android_app* state, const GLContextInfo& glContextInfo, const DisplayMode& mode);
		
	protected:
		void setResolutionInternal(int width, int height) override { }

	private:
		/// The EGL display connection
		EGLDisplay display_;
		/// The EGL drawing surface
		EGLSurface surface_;
		/// The EGL context
		EGLContext context_;
		/// The EGL config used to create the first surface
		EGLConfig config_;

		/// Initializes the OpenGL graphic context
		void initDevice(struct android_app* state);
	};

}
