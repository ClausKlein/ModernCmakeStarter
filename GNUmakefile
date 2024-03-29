
# export CXX=g++-12
# export CC=gcc-12

# export CXX=clang++
# export CC=clang

export CPM_USE_LOCAL_PACKAGES?=NO
export CPM_SOURCE_CACHE?${HOME}/.cache/CPM

####################################
# see https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
export CTEST_OUTPUT_ON_FAILURE=YES

STAGE_DIR:=$(shell realpath $(CURDIR)/stagedir)
BUILD_DIR:=$(shell realpath $(CURDIR)/build)
####################################

.PHONY: setup all test gcov install lib_install test_install standalone documentation clean distclean check format
all: install
	cd all && cmake --preset default --debug-find-pkg=greeter
	cd all && cmake --workflow --preset default

test: setup
	cmake --build $(BUILD_DIR)/all --target all
	cmake --build $(BUILD_DIR)/all --target $@

check: setup
	run-clang-tidy -extra-arg=-Wno-unknown-warning-option -p $(BUILD_DIR)/all source */source

setup:
	cd all && cmake --preset default --log-level=TRACE --trace-expand --trace-source=CPM.cmake
#XXX	perl -i.bak -p -e 's#-W[-\w]+(=\d)?\b##g;' \
#XXX	-e 's#-I(${CPM_SOURCE_CACHE})#-isystem $$1#g;' $(BUILD_DIR)/all/compile_commands.json

################################
# Begin Release workflows

install: standalone
lib_install:
	cmake --workflow --preset default --fresh

test_install: lib_install
	cd test && cmake --workflow --preset default --fresh

standalone: test_install
	cd standalone && cmake --workflow --preset default --fresh

# End Release workflows
################################

documentation:
	cmake -S documentation -B build/doc
	cmake --build build/doc --target GenerateDocs

gcov: test
	gcovr $(BUILD_DIR)/all

clean:
	-cmake --build $(BUILD_DIR)/all --target $@

distclean: #XXX clean
	-cmake -E rm -rf $(BUILD_DIR) $(STAGE_DIR) ctags tags

format: setup
	cmake --build $(BUILD_DIR)/all --target $@

################################
