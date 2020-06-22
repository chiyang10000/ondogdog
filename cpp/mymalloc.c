/*
 * mymalloc.c - Examples of run-time, link-time, and compile-time
 *              library interpositioning.
 */

/*
 * Run-time interpositioning of malloc and free based
 * on the dynamic linker's (ld-linux.so) LD_PRELOAD mechanism
 *
 * Example (Assume a.out calls malloc and free):
 *   linux> gcc -Wall -DRUNTIME -shared -fpic -o mymalloc.so mymalloc.c -ldl
 *
 *   bash> (LD_PRELOAD="./mymalloc.so" ./a.out)
 *   ...or
 *   tcsh> (setenv LD_PRELOAD "./mymalloc.so"; ./a.out; unsetenv LD_PRELOAD)
 */
/* $begin interposer */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

/* malloc wrapper function */
void *malloc(size_t size) {
  void *(*mallocp)(size_t size);
  char *error;

  mallocp = dlsym(RTLD_NEXT, "malloc"); /* Get address of libc malloc */
  if ((error = dlerror()) != NULL) {
    fputs(error, stderr);
    exit(1);
  }
  char *ptr = mallocp(size); /* Call libc malloc */
  printf("malloc(%d) = %p\n", (int)size, ptr);
  return ptr;
}

/* free wrapper function */
void free(void *ptr) {
  void (*freep)(void *) = NULL;
  char *error;

  if (!ptr)
    return;

  freep = dlsym(RTLD_NEXT, "free"); /* Get address of libc free */
  if ((error = dlerror()) != NULL) {
    fputs(error, stderr);
    exit(1);
  }
  freep(ptr); /* Call libc free */
  printf("free(%p)\n", ptr);
}
/* $end interposer */
