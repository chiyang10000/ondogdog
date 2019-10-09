#!/usr/bin/env python3
import subprocess
import sys
import re
import io

if __name__ == "__main__":
    assert len(sys.argv) == 3
    git_repo_dir = sys.argv[1]
    coverage_info_file = sys.argv[2]

    file_name_pattern = re.compile(r'SF:.*hornet/(.*)')
    line_hint_pattern = re.compile(r'LH:(.*)')
    line_file_pattern = re.compile(r'LF:(.*)')
    line_num_pattern = re.compile(r'DA:([0-9]+),([0-9]+)')
    git_newline_pattern = re.compile(r'([^ ]+):([0-9]+)(.*$)')

    new_line_set = dict()
    covered_line_set = dict()
    uncovered_line_set = dict()
    result = subprocess.check_output("git_new_line", cwd=git_repo_dir, shell=True)
    for line in io.StringIO(result.decode('utf8')):
        line = line.strip()
        match = git_newline_pattern.match(line)
        if not match:
            print(line)
        if match:
            file_name = match.group(1)
            line_num = int(match.group(2))
            line_content = match.group(3)
            if file_name not in new_line_set:
                new_line_set[file_name] = dict()
            new_line_set[file_name][line_num] = line_content
            # print(file_name, line_num, line_content)

    # Output new line information
    print()
    new_line_count = sum(map(lambda x: len(x), new_line_set.values()))
    print("Added {} new lines.".format(new_line_count))
    for file_name in new_line_set:
        continue
        print("  {}: {}".format(file_name, len(new_line_set[file_name])))

    input_stream = open(coverage_info_file)
    for line in input_stream:
        line = input_stream.readline()
        file_name = file_name_pattern.match(line.strip()).group(1)
        while line.strip() != 'end_of_record':
            match = line_num_pattern.match(line)
            if match:
                line_num = int(match.group(1))
                check = int(match.group(2)) > 0
                if file_name in new_line_set and line_num in new_line_set[file_name]:
                    if check:
                        if file_name not in covered_line_set:
                            covered_line_set[file_name] = set()
                        covered_line_set[file_name].add(line_num)
                    else:
                        if file_name not in uncovered_line_set:
                            uncovered_line_set[file_name] = set()
                        uncovered_line_set[file_name].add(line_num)
            line = input_stream.readline()

    print()
    uncovered_line_count = sum(map(lambda x: len(x), uncovered_line_set.values()))
    covered_line_count = sum(map(lambda x: len(x), covered_line_set.values()))
    print("Contained {} reachable C++ library lines.".format(covered_line_count + uncovered_line_count))

    print()
    print("Uncovered {} C++ library lines: ".format(uncovered_line_count))
    for file_name in uncovered_line_set:
        print(file_name)
        for line_num in uncovered_line_set[file_name]:
            print("  {}\t {}".format(line_num, new_line_set[file_name][line_num]))

    print()
    print("Covered {} C++ library lines: ".format(covered_line_count))
    for file_name in covered_line_set:
        continue
        print(file_name)
        for line_num in sorted(covered_line_set[file_name]):
            print("  {}\t {}".format(line_num, new_line_set[file_name][line_num]))

    if covered_line_count + uncovered_line_count == 0:
        exit(0)
    print()
    print("Unit Test Code Coverage: {} %".format(
        covered_line_count / (covered_line_count + uncovered_line_count) * 100))
