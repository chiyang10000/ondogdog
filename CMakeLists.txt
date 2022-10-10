cmake_minimum_required(VERSION 3.12)
PROJECT(OushuDB)

# set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CMAKE_COMMAND} -E time")
set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "yzy_time")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

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
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/hornet-opensource/dbcommon/src)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/hornet-opensource/univplan/src)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/hornet-opensource/storage/src)

    link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/dbcommon/src/)
    link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/univplan/src/)
    link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-opensource/storage/src/)

    add_subdirectory(hornet-opensource)
endif ()
if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/hornet-new/coroutine/CMakeLists.txt)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/hornet-new/coroutine/src)
    link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet-new/coroutine/src/)
    add_subdirectory(hornet-new/coroutine)
endif()
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/interconnect/src/)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/executor/src/)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/magma-client/src/magma/client)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/magma-common/src/magma/common)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/hornet/magma-server/src/magma)
add_subdirectory(hornet)
if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/hornet-new/coroutine/CMakeLists.txt)
    add_dependencies(magma-server-shared coroutine-shared)
endif()
if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/hornet-new/morsel_executor/CMakeLists.txt)
    add_subdirectory(hornet-new/morsel_executor)
endif()
add_subdirectory(hawq)

if (EXISTS yizhiyang)
    add_subdirectory(yizhiyang/cpp)
endif ()
set(CMAKE_INSTALL_PREFIX /opt/dependency/package)

add_custom_target(hawq-build
        COMMAND bash -ic 'hawq-config-load'
        COMMAND make install -C ${CMAKE_CURRENT_SOURCE_DIR}/hawq && hawq restart cluster -a -M immediate
        )
