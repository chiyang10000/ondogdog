#!/usr/bin/env python
import sys
import re
from lib import yizhiyang

if __name__ == "__main__":
    assert len(sys.argv) == 3
    git_repo_dir = sys.argv[1]
    coverage_info_file = sys.argv[2]

    file_name_pattern = re.compile(r'SF:.*hornet/(.*)')
    line_hint_pattern = re.compile(r'LH:(.*)')
    line_file_pattern = re.compile(r'LF:(.*)')
    line_num_pattern = re.compile(r'DA:([0-9]+),([0-9]+)')

    new_line_set = yizhiyang.get_git_new_lines(git_repo_dir)
    covered_line_set = dict()
    uncovered_line_set = dict()

    input_stream = open(coverage_info_file)
    while True:
        line = input_stream.readline()  # TN:
        line = input_stream.readline()  # SF:
        if not line:
            break
        line = line.rstrip()
        file_name = file_name_pattern.match(line).group(1)
        while line != 'end_of_record':
            match = line_num_pattern.match(line)
            if match:
                line_num = int(match.group(1))
                check = int(match.group(2)) > 0
                if file_name in new_line_set and line_num in new_line_set[file_name]:
                    if new_line_set[file_name][line_num].strip() == '}':
                        pass
                    elif check:
                        if file_name not in covered_line_set:
                            covered_line_set[file_name] = set()
                        covered_line_set[file_name].add(line_num)
                    else:
                        if file_name not in uncovered_line_set:
                            uncovered_line_set[file_name] = set()
                        uncovered_line_set[file_name].add(line_num)
            line = input_stream.readline().rstrip()

    yizhiyang.print_coverage(new_line_set, covered_line_set, uncovered_line_set)
