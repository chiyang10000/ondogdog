set(CMAKE_CXX_STANDARD 11)
ADD_EXECUTABLE(
        pipe-test
        pipe.cpp
)
ADD_EXECUTABLE(
        sort
        stdxxl.cpp
)
TARGET_LINK_LIBRARIES(sort stxxl_debug)
ADD_LIBRARY(
        mymalloc
        SHARED
        mymalloc.c
)
