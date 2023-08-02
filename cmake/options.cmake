include_guard()

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(
    FATAL_ERROR
      "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there."
  )
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_DEBUG_POSTFIX D)

option(OPTION_ENABLE_UNITY "Enable Unity builds of project" ON)
option(OPTION_ENABLE_CLANG_TIDY "Enable clang-tdiy as prebuild step" OFF)

if(OPTION_ENABLE_CLANG_TIDY)
  set(ENABLE_CLANG_TIDY_DEVELOPER_DEFAULT ON)
  set(OPT_ENABLE_CLANG_TIDY
      ON
      CACHE BOOL "Enable clang-tidy checks" FORCE
  )
endif()

if(CMAKE_EXPORT_COMPILE_COMMANDS)
  set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()

include(${CMAKE_CURRENT_LIST_DIR}/CPM.cmake)

# XXX CPMAddPackage("gh:aminya/project_options@0.30.0")
cmake_policy(SET CMP0097 NEW)
CPMAddPackage(
  NAME project_options
  GIT_TAG v0.30.0
  GITHUB_REPOSITORY aminya/project_options
  # XXX GIT_MODULES "examples/cpp_vcpkg_project"
  GIT_MODULES ""
  # NOTE(CK): should be empty to NOT initializes submodules! See policy CMP0097.
)
if(project_options_SOURCE_DIR)
  list(APPEND CMAKE_MODULE_PATH ${project_options_SOURCE_DIR}/src)
  include(StaticAnalyzers) # for target_disable_clang_tidy() and enable_clang_tidy()

  if(OPT_ENABLE_CLANG_TIDY)
    set(ProjectOptions_ENABLE_PCH OFF)
    enable_clang_tidy("")
  endif()
endif()

# Disable clang-tidy for target
macro(target_disable_clang_tidy TARGET)
  find_program(CLANGTIDY clang-tidy)
  if(CLANGTIDY)
    set_target_properties(${TARGET} PROPERTIES C_CLANG_TIDY "")
    set_target_properties(${TARGET} PROPERTIES CXX_CLANG_TIDY "")
  endif()
endmacro()

macro(check_system_property DIRECTORY)
  get_property(
    _value
    DIRECTORY ${DIRECTORY}
    PROPERTY SYSTEM
    SET
  )
  if(NOT _value)
    message(SEND_ERROR "SYSTEM property is NOT defined for ${DIRECTORY}")
  endif()
endmacro()

macro(set_system_property DIRECTORY)
  message(TRACE "${DIRECTORY}")
  set_property(DIRECTORY ${DIRECTORY} PROPERTY SYSTEM ON)
  check_system_property(${DIRECTORY})
endmacro()
