#!/usr/bin/env python3
from html.parser import HTMLParser
from collections import Counter
import argparse
import requests
import sys
import os
import re

planchecker_url = os.getenv('planchecker_url', "http://cloudtest.oushu-tech.com:14122")


def op_name(operator):
    """
        return a striped name
    """
    operator_pattern = re.compile(r'([A-Za-z]+ )+')
    lines = operator.splitlines()

    if 'Slice' in lines[0]:
        op = lines[1].strip()
    else:
        op = lines[0].strip()

    if operator_pattern.search(op):
        op = (operator_pattern.search(op).group())
    op = op.replace(' ', '')

    return op


def io_info(operator):
    if not args.verbose_io:
        return None
    io_info_pattern = re.compile(r'.*InputStream Info: ([0-9]+) byte.*in ([0-9.]+) ms with ([0-9]+) read call.*')
    # io_info_pattern = re.compile(r'.*InputStream Info:')
    search = io_info_pattern.search(operator)
    if search:
        assert 'TABLE' in operator
        byte = int(search.group(1))
        time = float(search.group(2))
        call = int(search.group(3))
        return {'byte': byte, 'time': time, 'call': call}

    return None


class MyHTMLParser(HTMLParser):
    """
    table format of the reponsed HTML
    Summary, Query Plan, Offset, First, End, Node, Prct
    """
    total_runtime_pattern = re.compile(r'([0-9.]+) ms')

    def error(self, message):
        pass

    def __init__(self):
        super().__init__()
        self.tr = 0  # parsed rows index count from 1
        self.td = 0  # zero to mark non-table data
        self.curr_operator = ''
        self.curr_timing = 0.0

        self.operators = []
        self.ops = []  # corresponding to operators with striped name
        self.timings = []

        self.new_executor = False
        self.file_path = ''
        self.total_runtime = -0.0

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
                info = io_info(self.curr_operator)
                if info:
                    op = op_name(self.curr_operator)

                    # IO
                    self.operators.append(self.curr_operator)
                    self.ops.append('IO-' + op)
                    self.timings.append(info['time'])

                    # DECODE
                    self.operators.append(self.curr_operator)
                    self.ops.append('SCAN-' + op)
                    self.timings.append(self.curr_timing - info['time'])
                    return

                self.operators.append(self.curr_operator)
                self.ops.append(op_name(self.curr_operator))
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
            self.curr_timing = float(data)

        if data == 'Total runtime:':
            self.total_runtime = 0.0
        if self.total_runtime == 0.0 and MyHTMLParser.total_runtime_pattern.search(data):
            self.total_runtime = float(MyHTMLParser.total_runtime_pattern.search(data).group(1))


def parse(file):
    parser = MyHTMLParser()
    parser.file_path = file
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

        node = res.ops[node_idx]
        if args.pattern:
            filter_pattern = re.compile(args.pattern)
            if filter_pattern.match(res.ops[node_idx]):
                print(res.operators[node_idx])

        if node not in query_counter:
            query_counter[node] = 0
        query_counter[node] += time

    for operator, time in sorted(query_counter.items(), key=lambda x: x[1]):
        print('{}\t{:.2f}\t{}\t{}'.format(query_num, time, operator, 'NewQE' if res.new_executor else 'OldQE'))

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

    mismatched_plans = []
    old_parsed_results = []
    new_parsed_results = []

    for spilt_file_idx in range(len(old_split_files)):
        # print(old_split_files[i], new_split_files[i])
        old_file = parse(old_split_files[spilt_file_idx])
        new_file = parse(new_split_files[spilt_file_idx])

        old_parsed_results.append(old_file)
        new_parsed_results.append(new_file)

        if len(new_file.timings) != len(old_file.timings):
            # debug
            # [print(i) for i in old_file.operators]
            # [print(i) for i in new_file.operators]

            mismatched_plans.append('Mismatched query plan {}:{} {}:{}'.format(
                old_file.file_path, len(old_file.operators),
                new_file.file_path, len(new_file.operators)))
            continue

        print('{}\n{}'.format(old_file.file_path, new_file.file_path))
        print('-' * 80)
        for operator_idx in range(0, len(new_file.timings)):
            old_t = float(old_file.timings[operator_idx])
            new_t = float(new_file.timings[operator_idx])
            if old_t > args.time and new_t > args.time and (old_t / new_t < args.speedup):
                print(old_t, new_t)
                print(old_file.operators[operator_idx])
                print(new_file.operators[operator_idx])

    print("Mismatched Query Plans:\n", mismatched_plans)
    print("\n")

    old_op_counter = Counter()
    new_op_counter = Counter()
    summary = '{:>8} {:>8} {:>10} {:>10}\n'.format('QueryNo', 'Speedup', 'Old', 'New')
    for res_idx in range(len(old_parsed_results)):
        old = old_parsed_results[res_idx]
        new = new_parsed_results[res_idx]
        summary += (
            '{:>8} {:>8.2f} {:>10.0f} {:>10.0f}\n'.format(res_idx + 1, old.total_runtime / new.total_runtime,
                                                          old.total_runtime, new.total_runtime))
        for op_idx in range(len(old.ops)):
            old_op_counter.update({old.ops[op_idx]: old.timings[op_idx]})
            new_op_counter.update({new.ops[op_idx]: new.timings[op_idx]})
        # map(lambda op_idx: old_op_counter.update({old.ops[op_idx]: old.timings[op_idx]}), range(len(old.ops)))
        # map(lambda op_idx: new_op_counter.update({new.ops[op_idx]: new.timings[op_idx]}), range(len(new.ops)))
    print(summary)

    print('{:>8} {:>20} {:>10} {:>10}'.format('Speedup', 'Operator', 'Old', 'New'))
    for operator, time in sorted(old_op_counter.items(), key=lambda x: x[1], reverse=True):
        print('{:>8.2f} {:>20} {:>10.0f} {:>10.0f}'.format(
            time / (new_op_counter[operator] if new_op_counter[operator] > 0 else 1),
            operator, time, new_op_counter[operator]))


def analyze(path):
    assert (os.path.isdir(path) or os.path.isfile(path))

    query_num_matcher = re.compile(r'query([0-9]+)')
    tpch_query_num_matcher = re.compile(r'tpch_([0-9]+)')

    tot_counter = Counter()

    query_idx = 0
    if os.path.isdir(path):
        query_files = [os.path.join(path, f) for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]
    else:
        query_files = [path]

    print('{}\t{}\t{}'.format('QueryNo', 'Time', 'Operator', 'Mode'))
    for origin_query_file in query_files:
        query_num = origin_query_file

        if query_num_matcher.search(origin_query_file):
            query_num = (query_num_matcher.search(origin_query_file).group(1))
        if tpch_query_num_matcher.search(origin_query_file):
            query_num = (tpch_query_num_matcher.search(origin_query_file).group(1))

        split_files = split(origin_query_file)
        for single_query_file in split_files:
            query_idx += 1
            if os.path.isfile(path): query_num = str(query_idx)
            query_counter = parse_group_by_operator(query_num, single_query_file)
            tot_counter.update(query_counter)

    # Print group by tot_counter
    if not args.verbose:
        exit()

    print()
    tot_time = sum(map(lambda x: x[1], tot_counter.items()))
    print('Total {}'.format(tot_time))

    print(' {:>6} {:>20} {:>10}'.format('Ratio', 'Operator', 'Time'))
    for operator, time in sorted(tot_counter.items(), key=lambda x: x[1]):
        print('{:>6.2f}% {:>20} {:>10.2f}'.format(100.0 * time / tot_time, operator, time))
    exit()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", help="print summary output of each operator",
                        action="store_true")
    parser.add_argument("--verbose-io", help="print summary output of each operator",
                        action="store_true")
    parser.add_argument('-p', '--pattern', type=str,
                        help='regex pattern to filter out operator')
    parser.add_argument("-t", "--time", type=float, default=20.0,
                        help="minimum timing counter in ms for single operator when checking old vs new (default: 20)")
    parser.add_argument("-s", "--speedup", type=float, default=1.0,
                        help="speedup requirement when checking old vs new (default: 3)")
    parser.add_argument('input_args', metavar='path', type=str, nargs='+',
                        help='old file vs new file, otherwise file/dir to be parsed')

    args = parser.parse_args()

    # Analyze all EXPLAIN ANALYZE output
    if len(args.input_args) == 1:
        analyze(args.input_args[0])

    # Compare old vs new EXPLAIN ANALYZE output
    if len(args.input_args) == 2:
        compare(args.input_args[0], args.input_args[1])
