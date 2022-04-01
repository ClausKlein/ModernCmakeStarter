# The "bootstrap" part clones repositories (with hardwired paths). With the
# help of the below setting, we can redirect these clones to our internal
# Gitlab mirror.
#TODO export GIT_CONFIG_PARAMETERS='url.git@code.rsint.net:mirror/github.com/.insteadOf=https://github.com/'

export CXX=g++
export CC=gcc

export CPM_USE_LOCAL_PACKAGES=NO
export CPM_SOURCE_CACHE=${HOME}/.cache/CPM

# see https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
export CMAKE_BUILD_TYPE=Debug
# export CMAKE_C_COMPILER_LAUNCHER=ccache
# export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export CMAKE_EXPORT_COMPILE_COMMANDS=YES
export CMAKE_GENERATOR=Ninja
export CMAKE_NO_VERBOSE=YES

export CTEST_OUTPUT_ON_FAILURE=YES

PROJECT:=$(shell basename $(CURDIR))
BUILD_DIR:=./build-${PROJECT}-${CMAKE_BUILD_TYPE}
STAGE_DIR:=$(shell realpath $(CURDIR)/../stage)
CMAKE_SETUP:=-D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -D CMAKE_STAGING_PREFIX=$(STAGE_DIR) #XXX -D USE_SANITIZER=Thread

.PHONY: setup eclipse all test gcov install test_install clean distclean check format
all: setup
	cmake --build $(BUILD_DIR) --target $@

test: all
	cmake --build $(BUILD_DIR) --target $@

install: # TODO: test
	cmake -B $(BUILD_DIR) -S $(CURDIR)/all -D USE_SANITIZER=""
	DESTDIR=$(STAGE_DIR) cmake --install $(BUILD_DIR) --prefix /

check: $(BUILD_DIR)/compile_commands.json
	# find $(BUILD_DIR) -name '*.h' | \
	#   xargs perl -i -p -e 's/#include \/\*\*\/ "((ace|tao)[^"]+)"/#include <$$1>/;' \
	#                    -e 's/#include "((ace|tao)[^"]+)"/#include <$$1>/;'
	perl -i.bak -p -e 's#-W[-\w]+\b##g;' -e 's#-I(${CPM_SOURCE_CACHE})#-isystem $$1#g;' $(BUILD_DIR)/compile_commands.json
	run-clang-tidy -p $(BUILD_DIR) $(CURDIR)

setup: $(BUILD_DIR)/compile_commands.json
$(BUILD_DIR)/compile_commands.json:
	cmake -B $(BUILD_DIR) -S $(CURDIR)/all $(CMAKE_SETUP)

################################
>>>>>>> 2365824 (refactory cmake project concept)

test_install: install distclean
	cmake -B $(BUILD_DIR) -S $(CURDIR)/test $(CMAKE_SETUP) #XXX -D TEST_INSTALLED_VERSION=1
	cmake --build $(BUILD_DIR) --target all
	cmake --build $(BUILD_DIR) --target test

################################

gcov: distclean
	cmake -B $(BUILD_DIR) -S $(CURDIR)/test $(CMAKE_SETUP) -D ENABLE_TEST_COVERAGE=1
	cmake --build $(BUILD_DIR) --target all
	cmake --build $(BUILD_DIR) --target test
	gcovr $(BUILD_DIR)

clean:
	-cmake --build $(BUILD_DIR) --target $@

distclean: clean
	-cmake -E rm -rf $(BUILD_DIR) ../build-* build* ctags tags
	find . -name '*.orig' -delete
	find . -name '*.bak' -delete
	find . -name '*~' -delete

format:
	cmake-format -i ./CMakeLists.txt */CMakeLists.txt cmake/*.cmake

################################

eclipse:
	# eclipse 2021-12 = version 4.22
	cmake -G "Eclipse CDT4 - Ninja" -B $(BUILD_DIR) -S $(CURDIR)/all -D CMAKE_ECLIPSE_VERSION=4.22 $(CMAKE_SETUP)
	@echo "in eclipse you now may import the project from $(BUILD_DIR)"
