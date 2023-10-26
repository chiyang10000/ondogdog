#!/usr/bin/env python

import time
import sys
import os


class Msg:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RESET = '\033[0m'

    if os.getenv('TERM') != 'xterm-256color':
        RED = ''
        GREEN = ''
        YELLOW = ''
        RESET = ''

    def __init__(self):
        pass

    @classmethod
    def failure(cls, s):
        return cls.RED + s + cls.RESET

    @classmethod
    def success(cls, s):
        return cls.GREEN + s + cls.RESET

    @classmethod
    def warning(cls, s):
        return cls.YELLOW + s + cls.RESET


toolbar_width = 50

# setup toolbar
sys.stdout.write("[%s]" % (" " * toolbar_width))
sys.stdout.flush()

for i in xrange(toolbar_width):
    sys.stdout.write("\b" * (toolbar_width - i + 1))  # return to start of line, after '['
    # update the bar
    sys.stdout.write(Msg.success('-'))
    sys.stdout.flush()
    time.sleep(0.05)  # do real work here
    p = (i + 1)*100/toolbar_width
    status = (' ' if p < 10 else '') + ' ' + str(p)
    status += '%'
    # status = Msg.warning(status)
    # assert len(status) == 3
    for j in xrange(toolbar_width - i - 1):
        sys.stdout.write(" ")
    sys.stdout.write(']')
    sys.stdout.write(Msg.warning(status))
    sys.stdout.write("\b" * len(status))  # return to start of line, after '['
    # sys.stdout.write("\b" * (toolbar_width - i-1))  # return to start of line, after '['
    # sys.stdout.flush()

sys.stdout.write('\n')
sys.stdout.flush()
# sys.stdout.write("]\n")  # this ends the progress bar
