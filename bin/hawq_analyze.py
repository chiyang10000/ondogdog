#!/usr/bin/env python3
from html.parser import HTMLParser
import requests
import sys

'''
response table format

Summary, Query Plan, Offset, First, End, Node, Prct
'''
class MyHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tr = 0
        self.td = 0 # zero to mark non-table data
        self.curr_node = ''
        self.curr_prct = ''
        self.curr_timing = ''
        self.nodes = []
        self.timings = []

    def handle_starttag(self, tag, attrs):
        if (tag == 'tr'): # newqe row
            self.tr += 1
            self.curr_node = ''
        if (tag == 'td'):
            self.td += 1

    def handle_endtag(self, tag):
        if (tag == 'tr'): # end row
            self.td = 0
            self.nodes.append(self.curr_node)
            self.timings.append(self.curr_timing)
            # print(self.curr_timing)
            # print(self.curr_node)

    def handle_data(self, data):
        if (self.td == 0): return

        if (self.td == 2):
            self.curr_node += data
        if (self.td == 6):
            self.curr_timing = data
        if (self.td == 7):
            self.curr_prct = data

def parse(file):
    parser = MyHTMLParser()
    data = [('action', 'parse')]
    files = {'uploadfile': open(file, 'rb')}
    r = requests.post(url = 'http://localhost:38324/plan/', files = files, data = data)
    if (r.text.find('Oops...') >= 0):
        print('Fails to parse EXPLAIN ANALYZE result!')
        raise ValueError
    parser.feed(r.text)
    # print(parser.nodes)
    # print(parser.timings)
    return parser

if __name__ == "__main__":
    assert(len(sys.argv) == 3)
    newqe = parse(sys.argv[1])
    oldqe = parse(sys.argv[2])
    
    assert(len(newqe.timings) == len(oldqe.timings))
    for i in range(0, len(newqe.timings)):
        if (len(newqe.timings[i]) == 0): continue
        new_t = float(newqe.timings[i])
        old_t = float(oldqe.timings[i])
        if (old_t > 30 and new_t > 30 and
            (
              old_t / new_t < 2
            )
           ):
            print(new_t, old_t)
            print(newqe.nodes[i])
            print(oldqe.nodes[i])
