[![MacOS](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/macos.yml/badge.svg)](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/macos.yml)
[![Install](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/install.yml/badge.svg)](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/install.yml)
[![Ubuntu](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/ubuntu.yml)
[![Windows](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/windows.yml/badge.svg)](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/windows.yml)
[![Standalone](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/standalone.yml/badge.svg)](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/standalone.yml)
[![Style](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/style.yml/badge.svg)](https://github.com/ClausKlein/ModernCmakeStarter/actions/workflows/style.yml)

<p align="center">
  <img src="https://repository-images.githubusercontent.com/254842585/4dfa7580-7ffb-11ea-99d0-46b8fe2f4170" height="175" width="auto" />
</p>

# ModernCmakeStarter

Setting up a new C++ project usually requires a significant amount of preparation and boilerplate code, even more so for modern C++ projects with tests, executables and continuous integration.
This project is the result of learnings from many previous projects and should help reduce the work required to setup up a modern C++ project.

## Features

- [How to Use CMake Without the Agonizing Pain](https://alexreinking.com/blog/how-to-use-cmake-without-the-agonizing-pain-part-1.html) Note the Resources sections!
- [Modern CMake practices](https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/) Noteable if you want to use project without CMake config package exports
- Suited for single header libraries and projects of any scale
- Clean separation of library and executable code
- Integrated test suite
- Continuous integration via [GitHub Actions](https://help.github.com/en/actions/)
- Code coverage via [codecov](https://codecov.io)
- Code formatting enforced by [clang-format](https://clang.llvm.org/docs/ClangFormat.html) and [cmake-format](https://github.com/cheshirekow/cmake_format) via [Format.cmake](https://github.com/TheLartians/Format.cmake)
- Reproducible dependency management via [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake)
- Installable target with automatic versioning information and header generation via [PackageProject.cmake](https://github.com/TheLartians/PackageProject.cmake)
- Automatic [documentation](https://thelartians.github.io/ModernCppStarter) and deployment with [Doxygen](https://www.doxygen.nl) and [GitHub Pages](https://pages.github.com)
- Configurable support for [sanitizer tools, and more](#additional-tools)
- [CMake presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)
- Supports [CMake Workflow Presets](https://cmake.org/cmake/help/v3.25/manual/cmake-presets.7.html#id10)

### New Features added

Alternatively you may use the [flexible project options](https://github.com/aminya/project_options#readme). It provides different CMake functions such:

- `project_options()`
- `dynamic_project_options()`
- [Build a project with presets](https://cmake.org/cmake/help/latest/manual/cmake.1.html#build-a-project)

## Usage

### Important note

**To cleanly separate the library and subprojects code, the outer
[CMakeLists.txt](CMakeLists.txt) only defines the library itself while the
tests and other subprojects are self-contained in their own directories.**

During development it is usually convenient to [build all subprojects at
once](#build-everything-at-once).

A [./GNUmakefile](./GNUmakefile) encapsulates the most common tasks. Where this
is not feasible the underlying CMake commands are shown as an alternative.

#### This project lives on this directory tree:

```bash
tree -d -L 3
.
├── all
├── cmake
├── documentation
│   └── pages
├── include
│   └── greeter
├── source
├── standalone
│   └── source
└── test
    └── source

11 directories
```

#### The CMake workflows presets creates this directory tree:

```bash
tree -d -L 2 build stagedir
build
├── all
│   ├── CMakeFiles
│   ├── CPM_modules
│   ├── Testing
│   ├── _deps
│   ├── bin
│   ├── documentation
│   ├── standalone
│   └── test
├── doc
│   ├── CMakeFiles
│   ├── CPM_modules
│   ├── __pycache__
│   ├── _deps
│   └── doxygen
├── standalone
│   ├── CMakeFiles
│   ├── CPM_modules
│   ├── Testing
│   ├── _CPack_Packages
│   ├── _deps
│   └── bin
├── test
│   ├── CMakeFiles
│   ├── CPM_modules
│   ├── Testing
│   ├── _deps
│   └── bin
└── user
    ├── CMakeFiles
    ├── CPM_modules
    ├── PackageProjectInclude
    ├── _CPack_Packages
    └── _deps
stagedir
├── bin
├── include
│   ├── fmt
│   └── greeter
└── lib
    ├── cmake
    ├── greeter
    └── pkgconfig

44 directories
```

### Build and install the Release library and its dependencies only

see [./CMakeLists.txt](./CMakeLists.txt)
and [./CMakePresets.json](./CMakePresets.json)

**This `CMakeList.txt` project file is intended to be used as a subproject with
`CPMAddPackage()` only!**

Use the following command to install the **Release** library without test:

```bash
make install

## This is equivalent to call:
# cmake --workflow --preset default --fresh

# the build/user is the CMake binary tree
```

The installed CMake export config package is:

```bash
tree stagedir/lib/cmake/greeter

stagedir/lib/cmake/greeter
├── greeterConfig.cmake
├── greeterConfigVersion.cmake
├── greeterTargets-release.cmake
└── greeterTargets.cmake

0 directories, 4 files
```

### Build, test, and install the standalone Release targets and its dependencies

see [standalone/CMakeLists.txt](standalone/CMakeLists.txt)
and [standalone/CMakePresets.json](standalone/CMakePresets.json)

Use the following command to build, test, and install the **Release**
executable target:

```bash
make standalone

## This is equivalent to call:
# cmake --workflow --preset default --fresh
# cd test && cmake --workflow --preset default --fresh
# cd standalone && cmake --workflow --preset default --fresh

# to directly call the executable use:
./build/standalone/greeter --help
```

### Build and test the installed Release version of the libray

see [test/CMakeLists.txt](test/CMakeLists.txt)
and [test/CMakePresets.json](test/CMakePresets.json)

Use the following commands to run the **Release** test suite at once:

```bash
cd test && cmake --workflow --preset=default
```

### Build and test a Debug build with CMake and generate a test coverage report with gcovr

see [all/CMakeLists.txt](all/CMakeLists.txt)
and [all/CMakePresets.json](all/CMakePresets.json)

Use the following command to run the **Debug** test suite at once:

```bash
make gcov

## This is equivalent to call:
# cd all && cmake --preset default
# cmake --build build/all --target all
# cmake --build build/all --target test
# gcovr build/all

# to directly call the executable use:
./build/test/GreeterTestsD
```

### Run clang-format

Use the following command from the project's root directory to check and fix
C++ and CMake source style.  This requires _clang-format_, _cmake-format_ and
_pyyaml_ to be installed on the current system.

```bash
make format

## This is equivalent to call:
# cd all && cmake --preset default
# cmake --build build/all --target format

### you may check it manually this way:
# cmake --build build/all --target check-format
```

See [Format.cmake](https://github.com/TheLartians/Format.cmake) for details.
These dependencies can be easily installed using pip.

```bash
pip3 install -r requirements.txt
```

### Build the documentation

see [documentation/CMakeLists.txt](documentation/CMakeLists.txt)

To manually build documentation, call the following commands.

```bash
cmake -S documentation -B build/doc
cmake --build build/doc --target GenerateDocs

# view the docs
open build/doc/doxygen/html/index.html
```

To build the documentation locally, you will need _Doxygen_, jinja2 and Pygments
installed on your system.

## Build everything at once

**Note: This workflow is for developers only and their targets must not be installed!**

The project also includes an `all` directory that allows building all **Debug**
targets at the same time.  This is useful during development, as it exposes all
subprojects to your IDE and avoids redundant builds of the library.

```bash
make all
# cd all && cmake --workflow --preset=default

# to run-clang-tidy on all sources:
make check
# cd all && cmake --preset default
# run-clang-tidy -p build/all source */source

# too you generate the documentation
cmake --build build/all --target GenerateDocs
```

### Additional tools

The all subprojects include additional tools on-demand through CMake configuration presets.

#### Sanitizers

Sanitizers can be enabled by configuring with 

```bash
make setup
cd build/all && ccmake .
```

#### Static Analyzers

Static Analyzers are enabled by default for developers at the all subdirectory

By default, analyzers will automatically find configuration files such as `.clang-format`.

#### Ccache

Ccache is enabled as long it is found.

## FAQ

> Can I use this for header-only libraries?

Yes, however you will need to change the library type to an `INTERFACE` library as documented in the [CMakeLists.txt](CMakeLists.txt).
See [here](https://github.com/TheLartians/StaticTypeInfo) for an example header-only library project.

> I don't need a standalone target / documentation. How can I get rid of it?

Simply remove the standalone / documentation directory and according github workflow file.

> Can I build the standalone and tests at the same time? / How can I tell my IDE about all subprojects?

To keep the project modular, all subprojects derived from the library have been separated into their own CMake modules.
This approach makes it trivial for third-party projects to re-use the projects library code.
To allow IDEs to see the full scope of the project, the project includes the `all` directory that will create a single build for all subprojects.
Use this as the main directory for best IDE support.

> I see you are using `GLOB` to add source files in CMakeLists.txt. Isn't that evil?

Glob is considered bad because any changes to the source file structure [might not be automatically caught](https://cmake.org/cmake/help/latest/command/file.html#filesystem) by CMake's builders and you will need to manually invoke CMake on changes.
  I personally prefer the `GLOB` solution for its simplicity, but feel free to change it to explicitly listing sources.

> I want create additional targets that depend on my library. Should I modify the main CMakeLists to include them?

Avoid including derived projects from the libraries CMakeLists (even though it is a common sight in the C++ world), as this effectively inverts the dependency tree and makes the build system hard to reason about.
Instead, create a new directory or project with a CMakeLists that adds the library as a dependency (e.g. like the [standalone](standalone/CMakeLists.txt) directory).
Depending type it might make sense move these components into a separate repositories and reference a specific commit or version of the library.
This has the advantage that individual libraries and components can be improved and updated independently.

> You recommend to add external dependencies using CPM.cmake. Will this force users of my library to use CPM.cmake as well?

[CPM.cmake](https://github.com/cpm-cmake/CPM.cmake) should be invisible to library users as it's a self-contained CMake Script.
If problems do arise, users can always opt-out by defining the CMake or env variable [`CPM_USE_LOCAL_PACKAGES`](https://github.com/cpm-cmake/CPM.cmake#options), which will override all calls to `CPMAddPackage` with the according `find_package` call.
This should also enable users to use the project with their favorite external C++ dependency manager, such as vcpkg or Conan.

> Can I configure and build my project offline?

No internet connection is required for building the project, however when using CPM missing dependencies are downloaded at configure time.
To avoid redundant downloads, it's highly recommended to set a CPM.cmake cache directory, e.g.: `export CPM_SOURCE_CACHE=$HOME/.cache/CPM`.
This will enable shallow clones and allow offline configurations dependencies are already available in the cache.

> Can I use CPack to create a package installer for my project?

As there are a lot of possible options and configurations, this is not (yet) in the scope of this project. See the [CPack documentation](https://cmake.org/cmake/help/latest/module/CPack.html) for more information on setting up CPack installers.

> This is too much, I just want to play with C++ code and test some libraries.

Perhaps the [MiniCppStarter](https://github.com/TheLartians/MiniCppStarter) is something for you!

## Related projects and alternatives

- [**cmake-init - The missing CMake project initializer**](https://github.com/friendlyanon/cmake-init#readme)
- [**cpp-best-practices cpp_starter_project**](https://github.com/cpp-best-practices/cpp_starter_project#readme): A popular C++ starter project
- [**ModernCppStarter & PVS-Studio Static Code Analyzer**](https://github.com/viva64/pvs-studio-cmake-examples/tree/master/modern-cpp-starter): Official instructions on how to use the ModernCppStarter with the PVS-Studio Static Code Analyzer.
- [**filipdutescu/modern-cpp-template**](https://github.com/filipdutescu/modern-cpp-template): A recent starter using a more traditional approach for CMake structure and dependency management.
- [**vector-of-bool/pitchfork**](https://github.com/vector-of-bool/pitchfork/): Pitchfork is a Set of C++ Project Conventions.
