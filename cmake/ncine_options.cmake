include(CMakeDependentOption)
if(POLICY CMP0127)
	cmake_policy(SET CMP0127 NEW)
endif()

# nCine options
option(NCINE_PROFILING "Enable runtime profiling" OFF)
option(NCINE_DOWNLOAD_DEPENDENCIES "Download all build dependencies" ON)
option(NCINE_LINKTIME_OPTIMIZATION "Compile the game with link time optimization when in release" ON)
option(NCINE_AUTOVECTORIZATION_REPORT "Enable report generation from compiler auto-vectorization" OFF)
#option(NCINE_DYNAMIC_LIBRARY "Compile the engine as a dynamic library" ON)
option(NCINE_EMBED_SHADERS "Export shader files to C strings to be included in engine sources" ON)
option(NCINE_BUILD_ANDROID "Build Android version of the game" OFF)
option(NCINE_STRIP_BINARIES "Enable symbols stripping from libraries and executables when in release" OFF)
option(NCINE_VERSION_FROM_GIT "Try to set current game version from GIT repository" ON)

set(NCINE_PREFERRED_BACKEND "GLFW" CACHE STRING "Specify preferred backend on desktop")
#set_property(CACHE NCINE_PREFERRED_BACKEND PROPERTY STRINGS "GLFW;SDL2;QT5")
set_property(CACHE NCINE_PREFERRED_BACKEND PROPERTY STRINGS "GLFW;SDL2")

if(EMSCRIPTEN)
	option(NCINE_WITH_THREADS "Enable Emscripten Pthreads support" OFF)
	set(NCINE_DYNAMIC_LIBRARY OFF)
else()
	option(NCINE_WITH_THREADS "Enable support for threads" ON)

	if(NCINE_BUILD_ANDROID)
		set(NCINE_NDK_ARCHITECTURES "arm64-v8a" CACHE STRING "Set NDK target architectures")
		option(NCINE_ASSEMBLE_APK "Assemble Android APK with Gradle" ON)
		option(NCINE_UNIVERSAL_APK "Configure Gradle build script to assemble an universal APK for all ABIs" OFF)
		set(NDK_DIR "" CACHE PATH "Set path to Android NDK")
	elseif(MSVC)
		set(NCINE_ARCH_EXTENSIONS "" CACHE STRING "Specifies architecture for code generation (IA32, SSE, SSE2, AVX, AVX2, AVX512)")
		if(WINDOWS_PHONE OR WINDOWS_STORE)
			set(NCINE_UWP_CERTIFICATE_THUMBPRINT "" CACHE STRING "Code-signing certificate thumbprint (Windows RT only)")
			set(NCINE_UWP_CERTIFICATE_PATH "" CACHE STRING "Code-signing certificate path (Windows RT only)")
			set(NCINE_UWP_CERTIFICATE_PASSWORD "" CACHE STRING "Code-signing certificate password (Windows RT only)")
			set(_NCINE_WITH_ANGLE_DEFAULT ON)
		else()
			option(NCINE_INSTALL_SYSLIBS "Install required MSVC system libraries with CMake" OFF)
			option(NCINE_COPY_DEPENDENCIES "Copy all build dependencies to target directory" OFF)
			set(_NCINE_WITH_ANGLE_DEFAULT OFF)
		endif()
		option(NCINE_WITH_ANGLE "Enable Google ANGLE libraries support" ${_NCINE_WITH_ANGLE_DEFAULT})
	elseif(UNIX AND NOT APPLE AND NOT ANDROID)
		option(NCINE_ASSEMBLE_DEB "Assemble DEB package of the game" OFF)
		option(NCINE_ASSEMBLE_RPM "Assemble RPM package of the game" OFF)
	endif()
endif()

if((WIN32 OR NOT NCINE_ARM_PROCESSOR) AND NOT EMSCRIPTEN AND NOT ANDROID AND NOT NCINE_BUILD_ANDROID)
	option(NCINE_WITH_GLEW "Use GLEW library" ON)
endif()
option(NCINE_WITH_WEBP "Enable WebP image file support" OFF)
option(NCINE_WITH_AUDIO "Enable OpenAL support and thus sound" ON)
option(NCINE_WITH_VORBIS "Enable Ogg Vorbis audio file support" ON)
option(NCINE_WITH_OPENMPT "Enable module (libopenmpt) audio file support" ON)
option(NCINE_WITH_ANGELSCRIPT "Enable AngelScript scripting support" OFF)

option(NCINE_WITH_TRACY "Enable integration with Tracy frame profiler" OFF)
option(NCINE_WITH_RENDERDOC "Enable integration with RenderDoc" OFF)

set(NCINE_DATA_DIR "${CMAKE_SOURCE_DIR}/Content" CACHE PATH "Set path to the game data directory")

if(NCINE_WITH_RENDERDOC)
	set(RENDERDOC_DIR "" CACHE PATH "Set path to RenderDoc directory")
endif()

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
	option(NCINE_ADDRESS_SANITIZER "Enable AddressSanitizer memory error detector of GCC and Clang" OFF)
	option(NCINE_UNDEFINED_SANITIZER "Enable UndefinedBehaviorSanitizer detector of GCC and Clang" OFF)
	option(NCINE_CODE_COVERAGE "Enable gcov instrumentation for testing code coverage" OFF)
endif()
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
	option(NCINE_GCC_HARDENING "Enable memory corruption mitigation methods of GCC" OFF)
endif()

#set(NCINE_WITH_FIXED_BATCH_SIZE "0" CACHE PATH "Set custom fixed batch size (unsafe)")

# Shared library options
option(DEATH_TRACE "Enable runtime event tracing" ON)

# Check if we can use IFUNC for CPU dispatch. Linux with glibc and Android with API 18+ has it,
# but e.g. Alpine Linux with musl doesn't, and on Android with API < 30 we don't get AT_HWCAP passed
# into the resolver and can't call getauxval() ourselves because it's too early at that point,
# which makes it pretty useless. Plus it also needs a certain binutils version and a capable compiler,
# so it's easiest to just verify the whole thing. The feature is supported on ELF platforms only,
# so general Linux/BSD but not Apple.
if(UNIX AND NOT APPLE)
	include(CheckCXXSourceCompiles)
	set(CMAKE_REQUIRED_QUIET ON)
	check_cxx_source_compiles("\
int fooImplementation() { return 42; }
#if defined(__ANDROID_API__) && __ANDROID_API__ < 30
#error need Android API 30+ to have AT_HWCAP passed into the resolver
#endif
extern \"C\" int(*fooDispatcher())() {
	return fooImplementation;
}
int foo() __attribute__((ifunc(\"fooDispatcher\")));
int main() { return foo() - 42; }\
		" _DEATH_CPU_CAN_USE_IFUNC)
	set(CMAKE_REQUIRED_QUIET OFF)
	if(_DEATH_CPU_CAN_USE_IFUNC)
		set(_DEATH_CPU_USE_IFUNC_DEFAULT ON)
		# On GCC 4.8, if --coverage or -fprofile-arcs is enabled, the ifunc dispatchers cause a segfault.
		# On Ubuntu 20.04 at least. Not the case with GCC 5 there, not the case with GCC 4.8 on Arch.
		# Can't find any upstream bug report or commit that would be related to this.
		if(NCINE_CODE_COVERAGE AND CMAKE_CXX_COMPILER_ID AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.9")
			if(NOT DEFINED DEATH_CPU_USE_IFUNC)
				message(WARNING "Disabling DEATH_CPU_USE_IFUNC by default as it may crash when used together with --coverage on GCC 4.8.")
			endif()
			set(_DEATH_CPU_USE_IFUNC_DEFAULT OFF)
		endif()

		# If sanitizers are enabled, call into the dispatch function crashes. Upstream bugreport
		# https://github.com/google/sanitizers/issues/342 suggests using __attribute__((no_sanitize_address)),
		# but that doesn't work / can't be used because it would mean marking basically everything including
		# the actual implementation that's being dispatched to.
		if(NCINE_ADDRESS_SANITIZER OR NCINE_UNDEFINED_SANITIZER)
			if(NOT DEFINED DEATH_CPU_USE_IFUNC)
				message(WARNING "Disabling DEATH_CPU_USE_IFUNC by default as it crashes when used together with sanitizers. See https://github.com/google/sanitizers/issues/342 for more information.")
			endif()
			set(_DEATH_CPU_USE_IFUNC_DEFAULT OFF)
		endif()
	else()
		set(_DEATH_CPU_USE_IFUNC_DEFAULT OFF)
	endif()
else()
	set(_DEATH_CPU_CAN_USE_IFUNC OFF)
	set(_DEATH_CPU_USE_IFUNC_DEFAULT OFF)
endif()
cmake_dependent_option(DEATH_CPU_USE_IFUNC "Allow using GNU IFUNC for runtime CPU dispatch" ${_DEATH_CPU_USE_IFUNC_DEFAULT} "_DEATH_CPU_CAN_USE_IFUNC" OFF)

# Runtime CPU dispatch. Because going through a function pointer may have negative perf consequences,
# enable it by default only on platforms that have IFUNC, and thus can avoid the function pointer indirection.
option(DEATH_CPU_USE_RUNTIME_DISPATCH "Build with runtime dispatch for CPU-dependent functionality" ${_DEATH_CPU_CAN_USE_IFUNC})

# Jazz² Resurrection options
option(SHAREWARE_DEMO_ONLY "Show only Shareware Demo episode" OFF)

if(EMSCRIPTEN)
	# Multiplayer is not supported on Emscripten yet
	set(WITH_MULTIPLAYER OFF)
else()
	option(WITH_MULTIPLAYER "Enable multiplayer support" OFF)
endif()
