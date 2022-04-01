cmake_minimum_required(VERSION 3.21...3.23)

project(GreeterTests LANGUAGES CXX)

# ---- Options ----

option(ENABLE_TEST_COVERAGE "Enable test coverage" OFF)
option(TEST_INSTALLED_VERSION "Test the version found by find_package" OFF)

# --- Import tools ----

# include(../cmake/tools.cmake)

# ---- Dependencies ----

CPMAddPackage("gh:doctest/doctest@2.4.8")
CPMAddPackage("gh:TheLartians/Format.cmake@1.7.3")

if(TEST_INSTALLED_VERSION)
  find_package(Greeter 1.0 REQUIRED)
  message(STATUS "Found ${Greeter_DIR}")
else()
  CPMAddPackage(NAME Greeter SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
endif()

# ---- Create binary ----

file(GLOB sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp)
add_executable(${PROJECT_NAME} ${sources})
target_link_libraries(${PROJECT_NAME} doctest::doctest Greeter::Greeter)
if(PROJECT_IS_TOP_LEVEL)
  target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)
endif()

# ---- Add GreeterTests ----

enable_testing()

# Note: doctest and similar testing frameworks can automatically configure CMake tests.
# For other # testing frameworks add the tests target instead:
# add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})

include(${doctest_SOURCE_DIR}/scripts/cmake/doctest.cmake)
doctest_discover_tests(${PROJECT_NAME})

# ---- code coverage ----

if(ENABLE_TEST_COVERAGE AND PROJECT_IS_TOP_LEVEL)
  target_compile_options(Greeter PUBLIC -O0 -g -fprofile-arcs -ftest-coverage)
  target_link_options(Greeter PUBLIC -fprofile-arcs -ftest-coverage)
endif()
