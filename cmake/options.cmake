include_guard()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_DEBUG_POSTFIX D)

option(OPTION_ENABLE_UNITY "Enable Unity builds of project" ON)
option(OPTION_ENABLE_CLANG_TIDY "Enable clang-tdiy as prebuild step" OFF)

if(OPTION_ENABLE_CLANG_TIDY)
  set(ENABLE_CLANG_TIDY_DEVELOPER_DEFAULT ON)
  set(OPT_ENABLE_CLANG_TIDY ON)
endif()

if(CMAKE_EXPORT_COMPILE_COMMANDS)
  set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()

include(${CMAKE_CURRENT_LIST_DIR}/CPM.cmake)

CPMAddPackage("gh:aminya/project_options@0.26.3")
list(APPEND CMAKE_MODULE_PATH ${project_options_SOURCE_DIR}/src)
#XXX include(StaticAnalyzers) # for target_disable_clang_tidy()

# Disable clang-tidy for target
macro(target_disable_clang_tidy TARGET)
  find_program(CLANGTIDY clang-tidy)
  if(CLANGTIDY)
    set_target_properties(${TARGET} PROPERTIES C_CLANG_TIDY "")
    set_target_properties(${TARGET} PROPERTIES CXX_CLANG_TIDY "")
  endif()
endmacro()

macro(set_system_property DIRECTORY)
  message(TRACE "${DIRECTORY}")
  set_property(DIRECTORY ${DIRECTORY} PROPERTY SYSTEM "ON")
endmacro()
