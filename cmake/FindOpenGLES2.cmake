#-------------------------------------------------------------------
# This file is part of the CMake build system for OGRE (http://www.ogre3d.org/)
#
# The contents of this file are placed in the public domain.
# Feel free to make use of it in any way you like.
#-------------------------------------------------------------------

# - Try to find OpenGLES and EGL
# Once done this will define
#
#	OPENGLES2_FOUND				- system has OpenGLES
#	OPENGLES2_INCLUDE_DIR	- the GL include directory
#	OPENGLES2_LIBRARIES		- Link these to use OpenGLES
#
#	EGL_FOUND				- system has EGL
#	EGL_INCLUDE_DIR	- the EGL include directory
#	EGL_LIBRARIES		- Link these to use EGL

# Win32, Apple, and Android are not tested!
# Linux tested and works

set(OPENGLES2_LIBRARIES)

macro(create_search_paths PREFIX)
	foreach(dir ${${PREFIX}_PREFIX_PATH})
		set(${PREFIX}_INC_SEARCH_PATH ${${PREFIX}_INC_SEARCH_PATH} ${dir}/include ${dir}/include/${PREFIX} ${dir}/Headers)
		set(${PREFIX}_LIB_SEARCH_PATH ${${PREFIX}_LIB_SEARCH_PATH} ${dir}/lib ${dir}/lib/${PREFIX} ${dir}/Libs)
	endforeach()
	set(${PREFIX}_FRAMEWORK_SEARCH_PATH ${${PREFIX}_PREFIX_PATH})
endmacro()

macro(findpkg_framework fwk)
	if(APPLE)
		set(${fwk}_FRAMEWORK_PATH
			${${fwk}_FRAMEWORK_SEARCH_PATH}
			${CMAKE_FRAMEWORK_PATH}
			~/Library/Frameworks
			/Library/Frameworks
			/System/Library/Frameworks
			/Network/Library/Frameworks
			/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.0.sdk/System/Library/Frameworks/
		)
		foreach(dir ${${fwk}_FRAMEWORK_PATH})
			set(fwkpath ${dir}/${fwk}.framework)
			if(EXISTS ${fwkpath})
				set(${fwk}_FRAMEWORK_INCLUDES ${${fwk}_FRAMEWORK_INCLUDES} ${fwkpath}/Headers ${fwkpath}/PrivateHeaders)
				if(NOT ${fwk}_LIBRARY_FWK)
					SET(${fwk}_LIBRARY_FWK "-framework ${fwk}")
				endif()
			endif()
		endforeach()
	endif()
endmacro()

if(WIN32)
	if(CYGWIN)
		find_path(OPENGLES2_INCLUDE_DIR GLES2/gl2.h)
		find_library(OPENGLES2_LIBRARY libGLESv2)
	else()
		if(BORLAND)
			set(OPENGLES2_LIBRARY import32 CACHE STRING "OpenGL ES 2.x library for Win32")
		else()
			# TODO
			# set(OPENGLES_LIBRARY ${SOURCE_DIR}/Dependencies/lib/release/libGLESv2.lib CACHE STRING "OpenGL ES 2.x library for win32"
		endif()
	endif()
elseif(APPLE)
	create_search_paths(/Developer/Platforms)
	findpkg_framework(OpenGLES2)
	set(OPENGLES2_LIBRARY "-framework OpenGLES")
else()
	find_path(OPENGLES2_INCLUDE_DIR GLES2/gl2.h
		PATHS /usr/openwin/share/include
			/opt/graphics/OpenGL/include
			/opt/vc/include
			/usr/X11R6/include
			/usr/include
			${EXTERNAL_INCLUDES_DIR}
	)

	find_library(OPENGLES2_LIBRARY
		NAMES GLESv2
		PATHS /opt/graphics/OpenGL/lib
			/usr/openwin/lib
			/usr/shlib /usr/X11R6/lib
			/opt/vc/lib
			/usr/lib/aarch64-linux-gnu
			/usr/lib/arm-linux-gnueabihf
			/usr/lib
			${NCINE_LIBS}/Linux/${CMAKE_SYSTEM_PROCESSOR}/
	)

	find_library(OPENGLES1_gl_LIBRARY
		NAMES GLESv1_CM
		PATHS /opt/graphics/OpenGL/lib
			/usr/openwin/lib
			/usr/shlib /usr/X11R6/lib
			/opt/vc/lib
			/usr/lib/aarch64-linux-gnu
			/usr/lib/arm-linux-gnueabihf
			/usr/lib
			${NCINE_LIBS}/Linux/${CMAKE_SYSTEM_PROCESSOR}/
	)

	if(NOT BUILD_ANDROID)
		find_path(EGL_INCLUDE_DIR EGL/egl.h
			PATHS /usr/openwin/share/include
				/opt/graphics/OpenGL/include
				/opt/vc/include
				/usr/X11R6/include
				/usr/include
				${EXTERNAL_INCLUDES_DIR}
		)

		find_library(EGL_LIBRARY
			NAMES EGL
			PATHS /opt/graphics/OpenGL/lib
				/usr/openwin/lib
				/usr/shlib
				/usr/X11R6/lib
				/opt/vc/lib
				/usr/lib/aarch64-linux-gnu
				/usr/lib/arm-linux-gnueabihf
				/usr/lib
				${NCINE_LIBS}/Linux/${CMAKE_SYSTEM_PROCESSOR}/
		)

		# On Unix OpenGL usually requires X11.
		# It doesn't require X11 on OSX.

		#if(OPENGLES2_LIBRARY)
		#	if(NOT X11_FOUND)
		#		find_package(X11)
		#	endif()
		#	if(X11_FOUND)
		#		list(APPEND OPENGLES2_LIBRARIES ${X11_LIBRARIES})
		#	endif()
		#endif()
	endif()
endif()

if(BUILD_ANDROID)
	if(OPENGLES2_LIBRARY AND OPENGLES2_INCLUDE_DIR)
		list(APPEND OPENGLES2_LIBRARIES ${OPENGLES2_LIBRARY})
		set(EGL_LIBRARIES)
		set(OPENGLES2_FOUND TRUE)
	endif()
else()
	if(OPENGLES2_LIBRARY AND OPENGLES2_INCLUDE_DIR AND EGL_LIBRARY AND EGL_INCLUDE_DIR)
		set(OPENGLES2_LIBRARIES ${OPENGLES2_LIBRARY})
		#if(OPENGLES1_gl_LIBRARY)
		#	list(APPEND OPENGLES2_LIBRARIES ${OPENGLES1_gl_LIBRARY})
		#endif()
		set(EGL_LIBRARIES ${EGL_LIBRARY} ${EGL_LIBRARIES})
		set(OPENGLES2_FOUND TRUE)
	endif()
endif()

mark_as_advanced(
	OPENGLES2_INCLUDE_DIR
	OPENGLES2_LIBRARY
	OPENGLES1_gl_LIBRARY
	EGL_INCLUDE_DIR
	EGL_LIBRARY
)

if(OPENGLES2_FOUND)
	message(STATUS "Found system OpenGL|ES 2 library: ${OPENGLES2_LIBRARIES}")
else()
	set(OPENGLES2_LIBRARIES "")
	set(OPENGLES2_INCLUDE_DIR "")
	set(EGL_LIBRARY "")
	set(EGL_INCLUDE_DIR "")
endif()
