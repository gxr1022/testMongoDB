# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.22

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/build

# Include any dependencies generated for this target.
include CMakeFiles/run_client.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/run_client.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/run_client.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/run_client.dir/flags.make

CMakeFiles/run_client.dir/src/run_client.cpp.o: CMakeFiles/run_client.dir/flags.make
CMakeFiles/run_client.dir/src/run_client.cpp.o: ../src/run_client.cpp
CMakeFiles/run_client.dir/src/run_client.cpp.o: CMakeFiles/run_client.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/run_client.dir/src/run_client.cpp.o"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/run_client.dir/src/run_client.cpp.o -MF CMakeFiles/run_client.dir/src/run_client.cpp.o.d -o CMakeFiles/run_client.dir/src/run_client.cpp.o -c /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/src/run_client.cpp

CMakeFiles/run_client.dir/src/run_client.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/run_client.dir/src/run_client.cpp.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/src/run_client.cpp > CMakeFiles/run_client.dir/src/run_client.cpp.i

CMakeFiles/run_client.dir/src/run_client.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/run_client.dir/src/run_client.cpp.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/src/run_client.cpp -o CMakeFiles/run_client.dir/src/run_client.cpp.s

# Object files for target run_client
run_client_OBJECTS = \
"CMakeFiles/run_client.dir/src/run_client.cpp.o"

# External object files for target run_client
run_client_EXTERNAL_OBJECTS =

run_client: CMakeFiles/run_client.dir/src/run_client.cpp.o
run_client: CMakeFiles/run_client.dir/build.make
run_client: /usr/local/lib/libgflags.so.2.2.2
run_client: CMakeFiles/run_client.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable run_client"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/run_client.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/run_client.dir/build: run_client
.PHONY : CMakeFiles/run_client.dir/build

CMakeFiles/run_client.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/run_client.dir/cmake_clean.cmake
.PHONY : CMakeFiles/run_client.dir/clean

CMakeFiles/run_client.dir/depend:
	cd /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/build /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/build /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/build/CMakeFiles/run_client.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/run_client.dir/depend

