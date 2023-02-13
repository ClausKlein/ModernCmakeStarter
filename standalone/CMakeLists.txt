cmake_minimum_required(VERSION 3.21...3.25)

project(GreeterStandalone LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL AND CMAKE_BUILD_TYPE STREQUAL "Release")
  set(CMAKE_SKIP_INSTALL_RULES
      NO
      CACHE BOOL "Forced generation of installation rules" FORCE
  )
endif()

option(OPTION_ENABLE_UNITY "Enable Unity builds of project" ON)

# --- Import tools ----

# XXX include(../cmake/tools.cmake)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

include(../cmake/CPM.cmake)

CPMAddPackage("gh:aminya/project_options@0.26.3")
list(APPEND CMAKE_MODULE_PATH ${project_options_SOURCE_DIR}/src)
include(StaticAnalyzers) # for target_disable_clang_tidy()

# ---- Dependencies ----

CPMAddPackage(
  GITHUB_REPOSITORY jarro2783/cxxopts
  VERSION 3.0.0 SYSTEM # used in case of cmake v3.25
  OPTIONS "CXXOPTS_BUILD_EXAMPLES NO" "CXXOPTS_BUILD_TESTS NO" "CXXOPTS_ENABLE_INSTALL YES"
)
if(cxxopts_ADDED)
  target_disable_clang_tidy(cxxopts)
endif()

CPMAddPackage(NAME greeter SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)

# ---- Add source files ----

# XXX file(GLOB _sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp)
set(_sources source/main.cpp)

# ---- Create standalone executable ----

add_executable(${PROJECT_NAME} ${_sources})
if(CMAKE_DEBUG_POSTFIX)
  set_property(TARGET ${PROJECT_NAME} PROPERTY DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})
endif()
target_link_libraries(${PROJECT_NAME} greeter::greeter cxxopts::cxxopts)
set_target_properties(${PROJECT_NAME} PROPERTIES UNITY_BUILD ${OPTION_ENABLE_UNITY})

# --- Test it ---

enable_testing()

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME} --help)
add_test(NAME ${PROJECT_NAME}-de COMMAND ${PROJECT_NAME} --lang=de)
add_test(NAME ${PROJECT_NAME}-err COMMAND ${PROJECT_NAME} --lang=err)

# --- Install it ---

install(TARGETS ${PROJECT_NAME} RUNTIME)

include(CPack)
