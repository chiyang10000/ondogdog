#!/usr/bin/env python3
from html.parser import HTMLParser
from collections import Counter
import requests
import sys
import os
import re

planchecker_url = os.getenv('planchecker_url', "http://cloudtest.oushu-tech.com:14122")


class MyHTMLParser(HTMLParser):
    """
    table format of the reponsed HTML
    Summary, Query Plan, Offset, First, End, Node, Prct
    """

    def __init__(self):
        super().__init__()
        self.tr = 0  # parsed rows index count from 1
        self.td = 0  # zero to mark non-table data
        self.curr_operator = ''
        self.curr_timing = 0.0
        self.operators = []
        self.timings = []
        self.new_executor = False

    def handle_starttag(self, tag, attrs):
        if tag == 'tr':  # new row
            self.tr += 1
            self.curr_operator = ''
        if tag == 'td':
            self.td += 1

    def handle_endtag(self, tag):
        if tag == 'tr':  # end new row
            self.td = 0
            if self.curr_operator != '':  # skip invalid parsed row
                self.operators.append(self.curr_operator)
                self.timings.append(self.curr_timing)
                # print(self.curr_timing)
                # print(self.curr_operator)

    def handle_data(self, data):
        # skip first two line of header
        if 'New Executor' in data:
            self.new_executor = True
        if self.tr <= 2:
            return
        if self.td == 2:
            self.curr_operator += data
        if self.td == 6:
            self.curr_timing = data


def parse(file):
    parser = MyHTMLParser()
    data = [('action', 'parse')]
    files = {'uploadfile': open(file, 'rb')}
    plan_checker_response = requests.post(url=planchecker_url + "/plan/", files=files, data=data)
    if plan_checker_response.text.find('Oops...') >= 0:
        print('Fails to parse EXPLAIN ANALYZE result!')
        raise ValueError
    parser.feed(plan_checker_response.text)
    # print(parser.operators)
    # print(parser.timings)
    # print(parser.new_executor)
    return parser


def parse_group_by_operator(query_num, query_file):
    """
      return counter of { <Operator, Time>, }
    """
    operator_pattern = re.compile(r'([A-Z][a-z]+ )+')
    query_counter = {}

    res = parse(query_file)
    # if (res.new_executor is False): return

    for node_idx in range(0, len(res.timings)):
        time = float(res.timings[node_idx])
        if time < 0:  # skip dirty data
            continue

        lines = res.operators[node_idx].splitlines()

        if 'Slice' in lines[0]:
            node = lines[1].strip()
        else:
            node = lines[0].strip()

        if operator_pattern.search(node):
            node = (operator_pattern.search(node).group())
        node = node.replace(' ', '')

        if node not in query_counter:
            query_counter[node] = 0
        query_counter[node] += time

    for operator, time in sorted(query_counter.items(), key=lambda x: x[1]):
        print('{}\t{}\t{}\t{}'.format(query_num, time, operator, 'NewQE' if res.new_executor else 'OldQE'))

    return query_counter


def split(file):
    """
      return split file list
    """
    ret = []
    input_stream = open(file, 'r')
    plan_matcher = re.compile(r'QUERY PLAN')
    mark_matcher = re.compile(r'Time: [0-9.]+ ms')

    count = 1
    is_plan = False
    output_name_base = '/tmp/planchecker.' + os.path.basename(file) + '.'
    output_stream = open(output_name_base + str(count) + '.txt', 'w')
    for line in input_stream:
        output_stream.write(line)
        if plan_matcher.search(line):
            is_plan = True
        if mark_matcher.search(line):
            output_stream.close()
            if is_plan:
                ret.append(output_name_base + str(count) + '.txt')
            count += 1
            is_plan = False
            output_stream = open(output_name_base + str(count) + '.txt', 'w')
    if output_stream:
        output_stream.close()

    return ret


def compare(old_file, new_file):
    assert (os.path.isfile(old_file))
    assert (os.path.isfile(new_file))

    old_split_files = split(old_file)
    new_split_files = split(new_file)
    assert (len(old_split_files) == len(new_split_files))

    for spilt_file_idx in range(len(old_split_files)):
        # print(old_split_files[i], new_split_files[i])
        old_file = parse(old_split_files[spilt_file_idx])
        new_file = parse(new_split_files[spilt_file_idx])

        assert (len(new_file.timings) == len(old_file.timings))
        for operator_idx in range(0, len(new_file.timings)):
            old_t = float(old_file.timings[operator_idx])
            new_t = float(new_file.timings[operator_idx])
            if old_t > 30 and new_t > 30 and (old_t / new_t < 3):
                print(old_t, new_t)
                print(old_file.operators[operator_idx])
                print(new_file.operators[operator_idx])


def analyze(path):
    assert (os.path.isdir(path))

    query_num_matcher = re.compile(r'query([0-9]+)')
    tpch_query_num_matcher = re.compile(r'tpch_([0-9]+)')

    tot_counter = Counter()
    query_files = [os.path.join(path, f) for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]

    print('{}\t{}\t{}'.format('QueryNo', 'Time', 'Operator', 'Mode'))
    for origin_query_file in query_files:
        query_num = origin_query_file

        if query_num_matcher.search(origin_query_file):
            query_num = (query_num_matcher.search(origin_query_file).group(1))
        if tpch_query_num_matcher.search(origin_query_file):
            query_num = (tpch_query_num_matcher.search(origin_query_file).group(1))

        split_files = split(origin_query_file)
        for single_query_file in split_files:
            query_counter = parse_group_by_operator(query_num, single_query_file)
            tot_counter.update(query_counter)

    # Print group by tot_counter
    exit()
    print()
    print('{}\t{}'.format('Time', 'Operator'))
    for operator, time in sorted(tot_counter.items(), key=lambda x: x[1]):
        print('{}\t{}'.format(time, operator))
    exit()


if __name__ == "__main__":
    # Compare old vs new EXPLAIN ANALYZE output
    if len(sys.argv) == 3:
        compare(sys.argv[1], sys.argv[2])

    # Analyze all EXPLAIN ANALYZE output
    if len(sys.argv) == 2:
        analyze(sys.argv[1])
