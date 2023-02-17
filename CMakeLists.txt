#
# this project is for using as a sub project with add_subdirectory() or with CPMAddPackage()
#
cmake_minimum_required(VERSION 3.21...3.25)

# Not ideal to use this global variable, but necessary to make sure that tooling and projects use
# the same version
set(CMAKE_CXX_STANDARD 20)

# strongly encouraged to enable this globally to avoid conflicts between -Wpedantic being enabled
# and -std=c++20 and -std=gnu++20 for example when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS NO)

# setup fix project configuration default options:
set(ENABLE_PCH_DEFAULT NO) # for user and developer builds

# It is strongly recomonded to NOT use this as precompile step!
set(ENABLE_CPPCHECK_DEFAULT NO) # for user and developer builds

# ---- Project ----

# Note: update this to your new project's name and version
project(
  greeter
  VERSION 1.1
  LANGUAGES CXX
)

# to get CMAKE_INSTALL_INCLUDEDIR
include(GNUInstallDirs)

# ---- local Options ----

if(NOT PROJECT_IS_TOP_LEVEL)
  message(WARNING "set(CMAKE_SKIP_INSTALL_RULES YES)")
  option(CMAKE_SKIP_INSTALL_RULES "Whether to disable generation of installation rules" YES)
endif()

# --- Import project options ----

include(cmake/options.cmake)

# ---- Add dependencies via CPM ----

# PackageProject.cmake will be used to make our target installable
CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.10.0")

# NOTE: The fmt library has to be installed if not found! BUT either clang-tidy checks nor compiler
# warnings are wanted!

# FIXME: EXCLUDE_FROM_ALL must be OFF or fmt target will NOT be installed! CK
option(FMT_INSTALL "create an installable target" NO)
CPMAddPackage(
  NAME fmt
  GIT_TAG 9.1.0
  GITHUB_REPOSITORY fmtlib/fmt
  EXCLUDE_FROM_ALL YES
  # TODO DOWNLOAD_ONLY YES
  SYSTEM YES # used in case of cmake v3.25
)
if(fmt_SOURCE_DIR) # TODO AND NOT TARGET fmt::fmt)
  # TODO add_subdirectory(${fmt_SOURCE_DIR} fmt SYSTEM)
  message(TRACE "add_subdirectory(${fmt_SOURCE_DIR} fmt SYSTEM EXCLUDE_FROM_ALL)")
  target_disable_clang_tidy(fmt)
  check_system_property(${fmt_SOURCE_DIR})
endif()

# ---- Setup default project_options ----

include(DynamicProjectOptions)
# Initialize project_options variable related to this project This overwrites `project_options` and
# sets `project_warnings` uncomment the options to enable them:
# cmake-format: off
dynamic_project_options(
  # MSVC_WARNINGS "/permissive-" # Override the defaults for the MSVC warnings
  # CLANG_WARNINGS "-Wall;-Wextra" # Override the defaults for the CLANG warnings
  # GCC_WARNINGS "-Wextra" # Override the defaults for the GCC warnings
)
# cmake-format: on
target_compile_features(project_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})

# ---- Add source files ----

# Note: globbing sources is considered bad practice as CMake's generators may not detect new files
# automatically. Keep that in mind when changing files, or explicitly mention them here.

# XXX # file(GLOB_RECURSE _headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")
set(_headers include/greeter/greeter.h)
# XXX file(GLOB_RECURSE _sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp")
set(_sources source/greeter.cpp)

# ---- Create library ----

# Note: for header-only libraries change all PUBLIC flags to INTERFACE and create an interface
# target: add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME} ${_headers} ${_sources})
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_${CMAKE_CXX_STANDARD})
set_target_properties(${PROJECT_NAME} PROPERTIES UNITY_BUILD ${OPTION_ENABLE_UNITY})

# being a cross-platform target, we enforce standards conformance on MSVC
target_compile_options(${PROJECT_NAME} PRIVATE "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_20) # mimimum requierd for package user

# Link dependencies
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt-header-only)

# target_include_directories with the SYSTEM modifier will request the compiler to omit warnings
# from the provided paths, if the compiler supports that
target_include_directories(
  ${PROJECT_NAME} SYSTEM PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                                $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(CMAKE_SKIP_INSTALL_RULES OR CMAKE_BUILD_TYPE STREQUAL "Debug")
  target_link_libraries(${PROJECT_NAME} PUBLIC project_warnings project_options)
  return()
endif()

# ---- Create an installable target ----
# this allows users to install and find the library via `find_package()`.

# the location where the project's version header will be placed should match the project's regular
# header paths
string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)

packageProject(
  NAME ${PROJECT_NAME}
  VERSION ${PROJECT_VERSION} NAMESPACE ${PROJECT_NAME}
  BINARY_DIR ${PROJECT_BINARY_DIR}
  INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
  INCLUDE_DESTINATION include/${PROJECT_NAME}
  VERSION_HEADER ${VERSION_HEADER_LOCATION} DISABLE_VERSION_SUFFIX YES
  COMPATIBILITY SameMajorVersion
  # XXX DEPENDENCIES "fmt 9.1.0"
)

include(CPack)
