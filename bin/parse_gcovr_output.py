#!/usr/bin/env python
import sys
import re
from lib import yizhiyang


def get_line_num_list(input_str):
    # exception handling code
    input_str = input_str.replace(' [* ', ',').replace(']', '')
    input_str = input_str.replace('[* ', '')

    if len(input_str) == 0:
        return []
    num_list = list()
    str_list = input_str.split(',')
    for str in str_list:
        if '-' in str:
            lower_bound, upper_bound = str.split('-')
            for num in range(int(lower_bound), int(upper_bound) + 1):
                num_list.append(num)
        else:
            num_list.append(int(str))
    return num_list


if __name__ == "__main__":
    assert len(sys.argv) == 3
    git_repo_dir = sys.argv[1]
    coverage_info_file = sys.argv[2]

    file_name_pattern = re.compile(r'^[^ ]+\.(h|c|cc|cpp)$')
    cov_info_pattern = re.compile(r'^ +([0-9]+) +([0-9]+) +([0-9]+)%( +(.+)$|$)')
    file_name_cov_info_pattern = re.compile(r'^([^ ]+\.(h|c|cc|cpp)) +([0-9]+) +([0-9]+) +([0-9]+)%( +(.*)$|$)')

    new_line_set = yizhiyang.get_git_new_lines(git_repo_dir)
    covered_line_set = dict()
    uncovered_line_set = dict()

    input_stream = open(coverage_info_file)
    while True:
        line = input_stream.readline()
        if not line:
            break
        line = line.rstrip()
        match1 = file_name_pattern.match(line)
        match2 = file_name_cov_info_pattern.match(line)
        if not match1 and not match2:
            continue

        if match1:
            file_name = match1.group(0)
            line = input_stream.readline().rstrip()

            match3 = cov_info_pattern.match(line)
            line_tot = int(match3.group(1))
            line_exec = int(match3.group(2))
            line_missing = match3.group(5)

        if match2:
            file_name = match2.group(1)
            line_tot = int(match2.group(3))
            line_exec = int(match2.group(4))
            line_missing = match2.group(7)

        if line_missing:
            line_hit = None
            if '|' in line_missing:  # Extra line hit info
                tmp = line_missing.split('|')
                line_missing = tmp[0].strip()
                line_hit = get_line_num_list(tmp[1].strip())
            line_missing = get_line_num_list(line_missing)
            assert line_tot == line_exec + len(line_missing)
            assert len(line_hit) if line_hit else line_exec == line_exec

            for line_num in line_missing:
                if file_name in new_line_set and line_num in new_line_set[file_name]:
                    if file_name not in uncovered_line_set:
                        uncovered_line_set[file_name] = set()
                    uncovered_line_set[file_name].add(line_num)

        if not line_missing:
            assert line_tot == line_exec

        if line_hit is not None:
            for line_num in line_hit:
                if file_name in new_line_set and line_num in new_line_set[file_name]:
                    if file_name not in covered_line_set:
                        covered_line_set[file_name] = set()
                    covered_line_set[file_name].add(line_num)
            continue

        # Fallback when no line_hit info
        if file_name in new_line_set:
            for line_num in new_line_set[file_name]:
                if not line_missing or line_num not in line_missing:
                    if file_name not in covered_line_set:
                        covered_line_set[file_name] = set()
                    covered_line_set[file_name].add(line_num)

    yizhiyang.print_coverage(new_line_set, covered_line_set, uncovered_line_set)
