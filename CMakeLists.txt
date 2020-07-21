cmake_minimum_required(VERSION 3.12)
PROJECT(OushuDB)

# set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CMAKE_COMMAND} -E time")
set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "yzy_time")

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    add_compile_options(-fdiagnostics-color=always)
elseif ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    add_compile_options(-fcolor-diagnostics)
endif ()


#add_compile_options(-fprofile-arcs -ftest-coverage)
#add_link_options(-fprofile-arcs -ftest-coverage)
#add_compile_options(-fsanitize=address)
#add_link_options(-fsanitize=address)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/hornet-opensource/CMakeLists.txt AND NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/hornet/thirdparty)
    add_subdirectory(hornet-opensource)

    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/hornet-opensource/dbcommon/src)
    include_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/dbcommon/src)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/hornet-opensource/univplan/src)
    include_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/univplan/src)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/hornet-opensource/storage/src)
    include_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/storage/src)

    link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/dbcommon/src/)
    link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/univplan/src/)
    link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/storage/src/)
endif ()
add_subdirectory(hornet)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/interconnect/src/)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/executor/src/)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/magma-client/src/magma/client)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/magma-server/src/magma)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/scheduler/src/)
add_subdirectory(hawq)

add_subdirectory(yizhiyang/cpp)
set(CMAKE_INSTALL_PREFIX /opt/dependency/package)

add_custom_target(hawq-build
        COMMAND bash -ic 'hawq-config-load'
        COMMAND make install -C ${CMAKE_CURRENT_SOURCE_DIR}/hawq && hawq restart cluster -a -M immediate
        )
