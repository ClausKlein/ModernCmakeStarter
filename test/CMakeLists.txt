cmake_minimum_required(VERSION 3.21...3.23)

project(GreeterTests LANGUAGES CXX)

# ---- Options ----

option(ENABLE_TEST_COVERAGE "Enable test coverage" OFF)
option(TEST_INSTALLED_VERSION "Test the version found by find_package" OFF)

# --- Import tools ----

include(../cmake/tools.cmake)

# ---- Dependencies ----

# XXX CPMAddPackage("gh:doctest/doctest@2.4.8")
CPMAddPackage("gh:iboB/doctest-lib@2.4.8")
CPMAddPackage("gh:TheLartians/Format.cmake@1.7.3")

if(TEST_INSTALLED_VERSION) # FIXME: if(PROJECT_IS_TOP_LEVEL)
  find_package(greeter 1.1 REQUIRED)
  message(STATUS "Found ${Greeter_DIR}")
else()
  CPMAddPackage(NAME Greeter SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
endif()

# ---- Create binary ----

# XXX file(GLOB sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp)
set(sources source/greeter.cpp)

add_executable(${PROJECT_NAME} ${sources})
target_link_libraries(${PROJECT_NAME} doctest-main greeter::greeter)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)

# ---- Add tests for ctest ----

enable_testing()

# Note: doctest and similar testing frameworks can automatically configure CMake tests.
# XXX include(${doctest_SOURCE_DIR}/scripts/cmake/doctest.cmake)
# XXX doctest_discover_tests(${PROJECT_NAME})

# For other testing frameworks add the tests target instead:
add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})

# ---- TODO: code coverage the old way! ----

if(ENABLE_TEST_COVERAGE)
  target_compile_options(greeter PUBLIC -O0 -g -fprofile-arcs -ftest-coverage)
  target_link_options(greeter PUBLIC -fprofile-arcs -ftest-coverage)
endif()
