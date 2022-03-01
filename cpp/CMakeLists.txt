set(CMAKE_CXX_STANDARD 11)
ADD_EXECUTABLE(
        pipe-test
        pipe.cpp
)
ADD_EXECUTABLE(
        sort
        stdxxl.cpp
)
TARGET_LINK_LIBRARIES(sort stxxl pthread)
ADD_LIBRARY(
        mymalloc
        SHARED
        mymalloc.c
)
ADD_EXECUTABLE(
        sum
        sum.cpp
)
#ADD_EXECUTABLE(
#        memory-mountain
#        memory-mountain.cpp
#)

