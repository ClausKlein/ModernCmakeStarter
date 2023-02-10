#
# This project enables the developer to build, test, install the project.
# It is strongly recommended to test the exported cmake config package too!
#
cmake_minimum_required(VERSION 3.21...3.25)

project(GreeterTests LANGUAGES CXX)

# ---- Options ----

option(TEST_INSTALLED_VERSION "Test the version found by find_package" OFF)

# --- Import tools ----

include(../cmake/tools.cmake)

# ---- Dependencies ----

include(../cmake/CPM.cmake)

CPMAddPackage("gh:doctest/doctest@2.4.9")
CPMAddPackage("gh:TheLartians/Format.cmake@1.7.3")

if(TEST_INSTALLED_VERSION) # FIXME: or if(PROJECT_IS_TOP_LEVEL)
  find_package(greeter 1.1 REQUIRED)
  message(STATUS "Found ${Greeter_DIR}")
else()
  CPMAddPackage(NAME Greeter SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
  target_disable_clang_tidy(doctest)
endif()

# ---- Create binary ----

# XXX file(GLOB sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp)
set(sources source/main.cpp source/greeter.cpp)

add_executable(${PROJECT_NAME} ${sources})
target_link_libraries(${PROJECT_NAME} doctest::doctest greeter::greeter)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)

# ---- Add tests for ctest ----

enable_testing()


# For other testing frameworks add the tests target instead:
add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
