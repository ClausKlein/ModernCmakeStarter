# The "bootstrap" part clones repositories (with hardwired paths). With the
# help of the below setting, we can redirect these clones to our internal
# Gitlab mirror.
#TODO export GIT_CONFIG_PARAMETERS='url.git@code.example.com:mirror/github.com/.insteadOf=https://github.com/'

export CXX=g++
export CC=gcc

export CPM_USE_LOCAL_PACKAGES=NO
export CPM_SOURCE_CACHE=${HOME}/.cache/CPM

# see https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
export CMAKE_GENERATOR=Ninja
export CMAKE_BUILD_TYPE=Debug
####################################

# unsed cmake variables, we use the defaults
# export CMAKE_CONFIG_TYPE=${CMAKE_BUILD_TYPE}
# export CMAKE_CONFIGURATION_TYPES=${CMAKE_BUILD_TYPE}
# export CMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache
# export CMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache

export CMAKE_EXPORT_COMPILE_COMMANDS=YES
export CMAKE_NO_VERBOSE=YES

export CTEST_OUTPUT_ON_FAILURE=YES

#XXX  INSTALL_PREFIX:=/usr
STAGE_DIR:=$(shell realpath $(CURDIR)/stagedir)
####################################

# PROJECT:=$(shell basename $(CURDIR))
# BUILD_DIR:=./build-${PROJECT}-${CMAKE_BUILD_TYPE}
BUILD_DIR:=$(shell realpath $(CURDIR)/build)
CMAKE_SETUP:=-D CMAKE_STAGING_PREFIX=$(STAGE_DIR)/$(INSTALL_PREFIX) #XXX -D CMAKE_INSTALL_PREFIX=$(INSTALL_PREFIX)

.PHONY: setup all test gcov install test_install clean distclean check format
all:
	cd all && cmake --workflow --preset default # --fresh

test: setup
	cmake --build $(BUILD_DIR) --target $@

check: setup
	run-clang-tidy -p $(BUILD_DIR) */source

setup:
	cmake -B $(BUILD_DIR) -S $(CURDIR)/all $(CMAKE_SETUP)
	perl -i.bak -p -e 's#-W[-\w]+(=\d)?\b##g;' -e 's#-I(${CPM_SOURCE_CACHE})#-isystem $$1#g;' $(BUILD_DIR)/compile_commands.json

################################

install:
	cmake --workflow --preset default --fresh

test_install: install
	cd test && cmake --workflow --preset default --fresh

################################

gcov: all
	gcovr $(BUILD_DIR)

clean:
	-cmake --build $(BUILD_DIR) --target $@

distclean: clean
	-cmake -E rm -rf $(BUILD_DIR) $(STAGE_DIR) ctags tags

format: # NO! all
	cd all && cmake --preset default
	cmake --build $(BUILD_DIR)/all --target $@

################################
