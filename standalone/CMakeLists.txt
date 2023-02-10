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

include(../cmake/CPM.cmake)

# ---- Dependencies ----

include(../cmake/CPM.cmake)

CPMAddPackage(
  GITHUB_REPOSITORY jarro2783/cxxopts
  VERSION 3.0.0 SYSTEM # used in case of cmake v3.25
  OPTIONS "CXXOPTS_BUILD_EXAMPLES NO" "CXXOPTS_BUILD_TESTS NO" "CXXOPTS_ENABLE_INSTALL YES"
)

CPMAddPackage(NAME greeter SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)

# ---- Create standalone executable ----

# XXX file(GLOB sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp)
set(sources source/main.cpp)

add_executable(${PROJECT_NAME} ${sources})
if(CMAKE_DEBUG_POSTFIX)
  set_property(TARGET ${PROJECT_NAME} PROPERTY DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})
endif()
target_link_libraries(${PROJECT_NAME} greeter::greeter cxxopts::cxxopts)
set_target_properties(${PROJECT_NAME} PROPERTIES UNITY_BUILD ${OPTION_ENABLE_UNITY})

# TODO(CK): why is this used? This overrides the CMAKE_DEBUG_POSTFIX!
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME Greeter)

# --- Test it ---

enable_testing()

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME} --help)
add_test(NAME ${PROJECT_NAME}-de COMMAND ${PROJECT_NAME} --lang=de)
add_test(NAME ${PROJECT_NAME}-err COMMAND ${PROJECT_NAME} --lang=err)

# --- Install it ---

install(TARGETS ${PROJECT_NAME} RUNTIME)

include(CPack)
