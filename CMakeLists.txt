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

add_subdirectory(hornet)
add_subdirectory(hawq)

add_subdirectory(yizhiyang/cpp)
set(CMAKE_INSTALL_PREFIX /opt/dependency/package)
