#include <stdio.h>
#include <unistd.h>

#include <iostream>

int main() {
  int sortPipeInputFd[2];  // write to sort utility
  int sortPipeOutputFd[2]; // read from sort utility
  pid_t cpid;
  char buf;

  if (pipe(sortPipeInputFd) == -1) {
    perror("pipe");
  }
  if (pipe(sortPipeOutputFd) == -1) {
    perror("pipe");
  }

  cpid = fork();
  if (cpid == -1) {
    perror("fork");
    exit(EXIT_FAILURE);
  }

  if (cpid == 0) { /* Child reads from pipe */
    std::cout << "reader" << std::endl;
    close(sortPipeInputFd[1]); /* Close unused write end */
    close(sortPipeOutputFd[0]);

    dup2(sortPipeInputFd[0], STDIN_FILENO);
    dup2(sortPipeOutputFd[1], STDOUT_FILENO);
    char *args[] = {"--buffer-size=1G", NULL};
    if (execv("/usr/bin/sort", args) == -1)
      perror("echo");

    // while (read(sortPipeInputFd[0], &buf, 1) > 0) write(STDOUT_FILENO, &buf,
    // 1);

    // write(STDOUT_FILENO, "\n", 1);
    close(sortPipeInputFd[0]);
    close(sortPipeOutputFd[1]);
    close(STDIN_FILENO);
    close(STDOUT_FILENO);

    _exit(EXIT_SUCCESS);

  } else { /* Parent writes argv[1] to pipe */
    char eol = '\n';
    close(sortPipeInputFd[0]); /* Close unused read end */
    close(sortPipeOutputFd[1]);
    write(sortPipeInputFd[1], "haha", 4);
    write(sortPipeInputFd[1], &eol, 1);
    write(sortPipeInputFd[1], "c", 1);
    write(sortPipeInputFd[1], &eol, 1);
    write(sortPipeInputFd[1], "a", 1);
    write(sortPipeInputFd[1], &eol, 1);

    for (auto i = 0; i < 100; i++) {
      std::string tmp = std::to_string(i) + '\n';
      write(sortPipeInputFd[1], tmp.c_str(), tmp.size());
    }

    close(sortPipeInputFd[1]); /* Reader will see EOF */
    while (read(sortPipeOutputFd[0], &buf, 1) > 0) {
      std::cout << buf;
    }
#ifdef __APPLE__
    wait(nullptr); /* Wait for child */
#else
    wait(); /* Wait for child */
#endif
    std::cout << "hello" << std::endl;
    exit(EXIT_SUCCESS);
  }
}
