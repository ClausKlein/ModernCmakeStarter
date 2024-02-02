#
# This project enables the developer to build, test, install the project. It is strongly recommended
# to test the exported cmake config package too!
#
cmake_minimum_required(VERSION 3.21...3.26)

project(GreeterTests LANGUAGES CXX)

# ---- local Options ----

option(TEST_INSTALLED_VERSION "Test the version found by find_package" NO)
option(CMAKE_SKIP_INSTALL_RULES "Whether to disable generation of installation rules" NO)

# --- Import project options ----

include(../cmake/options.cmake)

# ---- Dependencies ----

CPMAddPackage("gh:TheLartians/Format.cmake@1.7.3")

# NOTE: EXCLUDE_FROM_ALL must be OFF or doctest target will NOT be installed! CK
CPMAddPackage(
  GITHUB_REPOSITORY "doctest/doctest"
  VERSION "2.4.11"
  EXCLUDE_FROM_ALL OFF
  SYSTEM YES # used in case of cmake v3.25
  OPTIONS "DOCTEST_NO_INSTALL ${CMAKE_SKIP_INSTALL_RULES}"
)
if(TARGET doctest)
  target_disable_clang_tidy(doctest)
endif()

if(TEST_INSTALLED_VERSION) # TODO(CK): this breaks CI build! if(PROJECT_IS_TOP_LEVEL)
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
