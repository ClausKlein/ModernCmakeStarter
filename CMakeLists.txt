cmake_minimum_required(VERSION 3.21...3.23)

# Not ideal to use this global variable, but necessary to make sure that tooling and projects use
# the same version
set(CMAKE_CXX_STANDARD 20)

# strongly encouraged to enable this globally to avoid conflicts between -Wpedantic being enabled
# and -std=c++20 and -std=gnu++20 for example when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS NO)

# to be prepared for clang-tools usage!
set(CMAKE_EXPORT_COMPILE_COMMANDS YES)

# setup fix project configuration default options:
set(ENABLE_PCH_DEFAULT NO) # for user and developer builds

# strongly recomonded to NOT use this as precompile step!
set(ENABLE_CPPCHECK_DEFAULT NO) # for user and developer builds
# run_clang-tdiy -p build-dir ...
set(ENABLE_CLANG_TIDY_DEFAULT NO) # for user and developer builds

# ---- Project ----

# Note: update this to your new project's name and version
project(
  greeter
  VERSION 1.1
  LANGUAGES CXX
)

# to get CMAKE_INSTALL_INCLUDEDIR
include(GNUInstallDirs)

# ---- Add dependencies via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

include(cmake/CPM.cmake)

# see https://github.com/aminya/project_options for more info
CPMAddPackage("gh:aminya/project_options@0.20.0")
list(APPEND CMAKE_MODULE_PATH ${ProjectOptions_SRC_DIR})

# PackageProject.cmake will be used to make our target installable
CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.8.0")

CPMAddPackage(
  NAME fmt
  GIT_TAG 8.1.1
  GITHUB_REPOSITORY fmtlib/fmt
  OPTIONS "FMT_INSTALL YES" # create an installable target
)

# ---- Setup default project_options ----

include(DynamicProjectOptions)
# Initialize project_options variable related to this project
# This overwrites `project_options` and sets `project_warnings`
# uncomment the options to enable them:
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
# XXX file(GLOB_RECURSE headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")
# XXX file(GLOB_RECURSE sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp")
set(headers source/greeter.cpp)
set(sources include/greeter/greeter.h)

# ---- Create library ----

# Note: for header-only libraries change all PUBLIC flags to INTERFACE and create an interface
# target: add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME} ${headers} ${sources})
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_20)

# being a cross-platform target, we enforce standards conformance on MSVC
target_compile_options(${PROJECT_NAME} PRIVATE "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")

# Link dependencies
target_link_libraries(${PROJECT_NAME} PUBLIC fmt::fmt)

# FIXME: should be PRIVATE! CK
target_link_libraries(${PROJECT_NAME} PUBLIC project_warnings project_options)

# target_include_directories with the SYSTEM modifier will request the compiler
# to omit warnings from the provided paths, if the compiler supports that
target_include_directories(
  ${PROJECT_NAME} SYSTEM PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                                $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

# ---- Create an installable target ----
# this allows users to install and find the library via `find_package()`.

# Add other targets that you want installed here, be default we just package the one executable we
# know we want to ship
# cmake-format: off
package_project(
  TARGETS ${PROJECT_NAME} project_options project_warnings
  PUBLIC_DEPENDENCIES_CONFIGURED "fmt 8.1.1"
  # FIXME: NO! PRIVATE_DEPENDENCIES_CONFIGURED project_options project_warnings
  PUBLIC_INCLUDES ${PROJECT_SOURCE_DIR}/include
)
# cmake-format: on

# # the location where the project's version header will be placed should match the project's regular
# # header paths
# string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)
#
# packageProject(
#   NAME ${PROJECT_NAME}
#   VERSION ${PROJECT_VERSION}
#   NAMESPACE ${PROJECT_NAME}
#   BINARY_DIR ${PROJECT_BINARY_DIR}
#   INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
#   INCLUDE_DESTINATION include/${PROJECT_NAME}
#   VERSION_HEADER "${VERSION_HEADER_LOCATION}"
#   DISABLE_VERSION_SUFFIX YES
#   COMPATIBILITY SameMajorVersion
#   DEPENDENCIES "fmt 8.1.1"
# )

include(CPack)
