cmake_minimum_required(VERSION 3.21...3.25)

project(GreeterStandalone LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL AND CMAKE_BUILD_TYPE STREQUAL "Release")
  set(CMAKE_SKIP_INSTALL_RULES
      NO
      CACHE BOOL "Forced generation of installation rules" FORCE
  )
else()
  message(WARNING "set(CMAKE_SKIP_INSTALL_RULES YES)")
endif()

# --- Import project options ----

include(../cmake/options.cmake)

# ---- Dependencies ----

# FIXME: EXCLUDE_FROM_ALL has to be OFF or cxxopts target may NOT be installed! CK
  GITHUB_REPOSITORY jarro2783/cxxopts
  VERSION 3.1.0
  EXCLUDE_FROM_ALL NO
  # TODO DOWNLOAD_ONLY YES
  SYSTEM YES # used in case of cmake v3.25
  OPTIONS "CXXOPTS_BUILD_EXAMPLES NO" "CXXOPTS_BUILD_TESTS NO" "CXXOPTS_ENABLE_INSTALL YES"
)
if(cxxopts_SOURCE_DIR) # TODO AND NOT TARGET cxxopts)
  # TODO add_subdirectory(${cxxopts_SOURCE_DIR} cxxopts::cxxopts SYSTEM)
  message(TRACE "add_subdirectory(${cxxopts_SOURCE_DIR} cxxopts SYSTEM)")
  target_disable_clang_tidy(cxxopts)
  check_system_property(${cxxopts_SOURCE_DIR})
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
