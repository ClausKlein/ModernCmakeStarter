# this script adds all subprojects to a single build to allow IDEs understand the full project
# structure.

cmake_minimum_required(VERSION 3.21...3.23)

project(BuildAll LANGUAGES CXX)

# Note: by default ENABLE_DEVELOPER_MODE is True.
# This means that all analysis (sanitizers, static analysis) is enabled and all warnings are treated as errors.
# if you want to switch this behavior, change TRUE to FALSE
set(ENABLE_DEVELOPER_MODE
    ON # ${PROJECT_IS_TOP_LEVEL}
    CACHE BOOL "Enable 'developer mode'"
)
# Change this to OFF if you want to disable warnings_as_errors in developer mode
set(WARNINGS_AS_ERRORS_DEVELOPER_DEFAULT ON)
set(ENABLE_COVERAGE_DEVELOPER_DEFAULT ON)

include(../cmake/tools.cmake)

# needed to generate test target
enable_testing()

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../standalone ${CMAKE_BINARY_DIR}/standalone)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../test ${CMAKE_BINARY_DIR}/test)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../documentation ${CMAKE_BINARY_DIR}/documentation)
