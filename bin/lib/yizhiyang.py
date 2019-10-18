import subprocess
import io
import re


def get_git_new_lines(git_repo_dir):
    git_newline_pattern = re.compile(r'([^ ]+):([0-9]+)(.*$)')

    new_line_set = dict()
    print()
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

    return new_line_set


def print_coverage(new_line_set, covered_line_set, uncovered_line_set):
    uncovered_line_count = sum(map(lambda x: len(x), uncovered_line_set.values()))
    covered_line_count = sum(map(lambda x: len(x), covered_line_set.values()))

    print()
    print("Unit Test Code Coverage For Added Reachable C++ Lines: {} %".format(
        covered_line_count / (covered_line_count + uncovered_line_count) * 100))

    print()
    print("Contained {} reachable C++ library lines.".format(covered_line_count + uncovered_line_count))

    if covered_line_count + uncovered_line_count == 0:
        exit(0)

    print()
    print("Covered {} C++ library lines: ".format(covered_line_count))
    for file_name in covered_line_set:
        # continue
        print()
        print("  {}".format(file_name))
        for line_num in sorted(covered_line_set[file_name]):
            print("      {}\t {}".format(line_num, new_line_set[file_name][line_num]))

    print()
    print("Uncovered {} C++ library lines: ".format(uncovered_line_count))
    for file_name in uncovered_line_set:
        print()
        print("  {}".format(file_name))
        for line_num in uncovered_line_set[file_name]:
            print("      {}\t {}".format(line_num, new_line_set[file_name][line_num]))

    print()
    print("Unit Test Code Coverage For Added reachable C++ lines: {} %".format(
        covered_line_count / (covered_line_count + uncovered_line_count) * 100))
