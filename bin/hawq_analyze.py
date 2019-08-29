#!/usr/bin/env python3
from html.parser import HTMLParser
import requests
import sys
import os
import re

'''
table format of the reponsed HTML

Summary, Query Plan, Offset, First, End, Node, Prct
'''
class MyHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tr = 0 # parsed rows index count from 1
        self.td = 0 # zero to mark non-table data
        self.curr_plannode = ''
        self.curr_timing = 0.0
        self.plannodes = []
        self.timings = []

    def handle_starttag(self, tag, attrs):
        if (tag == 'tr'): # new row
            self.tr += 1
            self.curr_plannode = ''
        if (tag == 'td'):
            self.td += 1

    def handle_endtag(self, tag):
        if (tag == 'tr'): # end new row
            self.td = 0
            if (self.curr_plannode != ''): # skip invalid parsed row
              self.plannodes.append(self.curr_plannode)
              self.timings.append(self.curr_timing)
              # print(self.curr_timing)
              # print(self.curr_plannode)

    def handle_data(self, data):
        # skip first two line of header
        if (self.tr <= 2): return 

        if (self.td == 2):
            self.curr_plannode += data
        if (self.td == 6):
            self.curr_timing = data

def parse(file):
    parser = MyHTMLParser()
    data = [('action', 'parse')]
    files = {'uploadfile': open(file, 'rb')}
    r = requests.post(url = 'http://localhost:38324/plan/', files = files, data = data)
    if (r.text.find('Oops...') >= 0):
        print('Fails to parse EXPLAIN ANALYZE result!')
        raise ValueError
    parser.feed(r.text)
    # print(parser.plannodes)
    # print(parser.timings)
    return parser

if __name__ == "__main__":
    if (len(sys.argv) == 2):
      path = sys.argv[1]
      assert(os.path.isdir(path))

      queryfiles = [os.path.join(path, f) for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]
      
      plannode_matcher = re.compile(r'([A-Z][a-z]+ )+')

      counter = {}
      for queryfile in queryfiles:
        # skip query file that contains multiple queries
        # print(queryfile)
        if "14" in queryfile or "23" in queryfile or "24" in queryfile or "39" in queryfile: continue

        res = parse(queryfile)
        for node_idx in range(0, len(res.timings)):
          time = float(res.timings[node_idx])
          if (time < 0): continue # skip dirty data

          lines = res.plannodes[node_idx].splitlines()

          if 'Slice' in lines[0]:
            node = lines[1].strip()
          else:
            node = lines[0].strip()

          search = plannode_matcher.search(node)
          if search: node = (search.group())
          node = node.replace(' ', '')

          if node not in counter: counter[node] = 0
          counter[node] += time

          # print(node, time)

      # Print group by counter
      print()
      for k,v in sorted(counter.items()):
        print('{}\t{}'.format(k, v))
      exit()
    
    assert(len(sys.argv) == 3)
    old_file = parse(sys.argv[1])
    new_file = parse(sys.argv[2])
    
    assert(len(new_file.timings) == len(old_file.timings))
    for node_idx in range(0, len(new_file.timings)):
        old_t = float(old_file.timings[node_idx])
        new_t = float(new_file.timings[node_idx])
        if (old_t > 30 and new_t > 30 and
              (old_t / new_t < 3)
           ):
            print(old_t, new_t)
            print(old_file.plannodes[node_idx])
            print(new_file.plannodes[node_idx])
