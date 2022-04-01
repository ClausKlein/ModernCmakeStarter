cmake_minimum_required(VERSION 3.21...3.23)

# Not ideal to use this global variable, but necessary to make sure that tooling and projects use
# the same version
set(CMAKE_CXX_STANDARD 20)

# strongly encouraged to enable this globally to avoid conflicts between -Wpedantic being enabled
# and -std=c++20 and -std=gnu++20 for example when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS OFF)

# ---- Project ----

# Note: update this to your new project's name and version
project(
  greeter
  VERSION 1.1
  LANGUAGES CXX
)

# Note: by default ENABLE_DEVELOPER_MODE is True This means that all analysis (sanitizers, static
# analysis) is enabled and all warnings are treated as errors if you want to switch this behavior,
# change TRUE to FALSE
set(ENABLE_DEVELOPER_MODE
    ${PROJECT_IS_TOP_LEVEL}
    CACHE BOOL "Enable 'developer mode'"
)
# Change this to false if you want to disable warnings_as_errors in developer mode
set(OPT_WARNINGS_AS_ERRORS_DEVELOPER_DEFAULT ${PROJECT_IS_TOP_LEVEL})

# ---- Add dependencies via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

include(cmake/CPM.cmake)

# https://github.com/aminya/project_options/tree/v0.20.0
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

include(DynamicProjectOptions)
# Initialize project_options variable related to this project This overwrites `project_options` and
# sets `project_warnings` uncomment the options to enable them:
dynamic_project_options(
  # MSVC_WARNINGS    # Override the defaults for the MSVC warnings
  # CLANG_WARNINGS   # Override the defaults for the CLANG warnings
  # GCC_WARNINGS     # Override the defaults for the GCC warnings
  # CPPCHECK_OPTIONS # Override the defaults for CppCheck
)
target_compile_features(project_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})

# ---- Add source files ----

# Note: globbing sources is considered bad practice as CMake's generators may not detect new files
# automatically. Keep that in mind when changing files, or explicitly mention them here.
# XXX file(GLOB_RECURSE _headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")
# XXX file(GLOB_RECURSE _sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp")
set(_headers source/greeter.cpp)
set(_sources include/greeter/greeter.h)

# ---- Create library ----

# Note: for header-only libraries change all PUBLIC flags to INTERFACE and create an interface
# target: add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME} ${headers} ${sources})
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_${CMAKE_CXX_STANDARD})

# being a cross-platform target, we enforce standards conformance on MSVC
target_compile_options(${PROJECT_NAME} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17) # mimimum requierd for package user

# Link dependencies
target_link_libraries(${PROJECT_NAME} PUBLIC fmt::fmt)
target_link_libraries(${PROJECT_NAME} PRIVATE project_options)

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
package_project(
  TARGETS ${PROJECT_NAME} project_options PUBLIC_DEPENDENCIES_CONFIGURED "fmt 8.1.1"
  #NO! PRIVATE_DEPENDENCIES_CONFIGURED project_options
)

# the location where the project's version header will be placed should match the project's regular
# header paths
# string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)
#
# packageProject(
#   NAME ${PROJECT_NAME}
#   VERSION ${PROJECT_VERSION}
#   NAMESPACE ${PROJECT_NAME}
#   BINARY_DIR ${PROJECT_BINARY_DIR}
#   INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
#   INCLUDE_DESTINATION include/${PROJECT_NAME}
#   VERSION_HEADER "${VERSION_HEADER_LOCATION}" DISABLE_VERSION_SUFFIX YES
#   COMPATIBILITY SameMajorVersion
#   DEPENDENCIES "fmt 8.1.1; project_options"
# )

include(CPack)
