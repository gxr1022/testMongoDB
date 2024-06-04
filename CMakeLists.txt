cmake_minimum_required(VERSION 3.11)
PROJECT (TEST_MONGODB)

set(CMAKE_INSTALL_INCLUDEDIR "include")

include_directories(
    ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/bsoncxx/v_noabi
    ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/mongocxx/v_noabi
    /home/wjxt/gxr/mongo-cxx-driver-r3.10.1/build/src/bsoncxx/third_party/_deps/core-src/include
    /home/wjxt/gxr/testMongoDB/include
    ${GFLAGS_INCLUDE_DIRS}
)



find_package(Boost REQUIRED)
find_package(gflags REQUIRED)

add_executable(run_clients src/run_clients.cpp include/mongodbBench.h util/affinity.hpp)


target_include_directories(run_clients
  PRIVATE ${Boost_INCLUDE_DIRS}
)
target_include_directories(run_clients
  PRIVATE ${LIBMONGOCXX_INCLUDE_DIRS}
)
target_link_libraries(run_clients
  PRIVATE ${LIBMONGOCXX_LIBRARIES}
)
target_compile_definitions(run_clients
  PRIVATE ${LIBMONGOCXX_DEFINITIONS}
)
target_link_libraries(run_clients 
 PRIVATE bsoncxx)
 
 target_link_libraries(run_clients 
 PRIVATE mongocxx)

#  target_link_libraries(run_clients gflags::gflags)


target_link_libraries(run_clients
PRIVATE ${GFLAGS_LIBRARIES}
)



# How to use gflags Lib? https://gflags.github.io/gflags/ 


