#!/usr/bin/env python3
from html.parser import HTMLParser
from collections import Counter
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
        self.new_executor = False

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
        if 'New Executor' in data: self.new_executor = True
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
    # print(parser.new_executor)
    return parser

'''
  return counter of { <Operator, Time>, }
'''
def parse_group_by_operator(querynum, queryfile):
  plannode_matcher = re.compile(r'([A-Z][a-z]+ )+')
  query_counter = {}

  res = parse(queryfile)
  # if (res.new_executor is False): return

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

    if node not in query_counter: query_counter[node] = 0
    query_counter[node] += time

  for k,v in sorted(query_counter.items(), key = lambda x : x[1]):
    print('{}\t{}\t{}\t{}'.format(querynum, v, k, 'NewQE' if res.new_executor else 'OldQE'))

  return query_counter



'''
  return split file list
'''
def split(file):
  ret = []
  input = open(file, 'r')
  mark_matcher = re.compile(r'Time: [0-9.]+ ms')

  output_base = '/tmp/planchecker.'
  count = 1
  output = open(output_base + str(count) + '.txt', 'w')
  for line in input:
    output.write(line)
    if mark_matcher.search(line):
      output.close()
      ret.append(output_base + str(count) + '.txt')
      count += 1
      output = open(output_base + str(count) + '.txt', 'w')
  if output:
      output.close()

  return ret



if __name__ == "__main__":
    if (len(sys.argv) == 2):
      path = sys.argv[1]
      assert(os.path.isdir(path))

      queryfiles = [os.path.join(path, f) for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]

      querynum_matcher = re.compile(r'query([0-9]+)')

      tot_counter = Counter()
      print('{}\t{}\t{}'.format('Query', 'Time','PlanNode'))
      for queryfile in queryfiles:
        querynum = queryfile
        search = querynum_matcher.search(queryfile)
        if search: querynum = (search.group(1))

        # skip query file that contains multiple queries
        if querynum in ['query4', 'query14']:
          continue

        split_files = split(queryfile)
        for queryfile in split_files:
          query_counter = parse_group_by_operator(querynum, queryfile)
          tot_counter.update(query_counter)


      # Print group by tot_counter
      exit()
      print()
      print('{}\t{}'.format('Time', 'PlanNode'))
      for k,v in sorted(tot_counter.items(), key = lambda x : x[1]):
        print('{}\t{}'.format(v, k))
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
