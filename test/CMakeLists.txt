#
# This project enables the developer to build, test, install the project. It is strongly recommended
# to test the exported cmake config package too!
#
cmake_minimum_required(VERSION 3.21...3.26)

project(GreeterTests LANGUAGES CXX)

# ---- local Options ----

option(TEST_INSTALLED_VERSION "Test the version found by find_package" OFF)

# --- Import project options ----

include(../cmake/options.cmake)

# ---- Dependencies ----

CPMAddPackage("gh:TheLartians/Format.cmake@1.7.3")

# XXX CPMAddPackage("gh:doctest/doctest@2.4.9")
CPMAddPackage(
  GITHUB_REPOSITORY "doctest/doctest"
  VERSION "2.4.9"
  SYSTEM YES # used in case of cmake v3.25
)
if(doctest_SOURCE_DIR)
  target_disable_clang_tidy(doctest)
endif()

if(TEST_INSTALLED_VERSION) # TODO(CK): or if(PROJECT_IS_TOP_LEVEL)
  find_package(greeter 1.1 REQUIRED)
  message(TRACE "Found at ${Greeter_DIR}")
else()
  CPMAddPackage(
    NAME greeter
    SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..
    FORCE YES
  )
endif()

# ---- Create binary ----

# XXX file(GLOB _sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp)
set(_sources source/main.cpp source/greeter.cpp)

add_executable(${PROJECT_NAME} ${_sources})
target_link_libraries(${PROJECT_NAME} doctest::doctest greeter::greeter)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)

# ---- Add tests for ctest ----

enable_testing()

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
