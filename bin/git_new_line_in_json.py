#!/usr/bin/env python
import sys
import os.path
import json
from lib import yizhiyang

if __name__ == "__main__":
    assert len(sys.argv) == 2
    git_repo_dir = sys.argv[1]
    new_line_set = yizhiyang.get_git_new_lines(git_repo_dir)

    reorg_line_set = []
    for file_name, file_lines in new_line_set.items():
        line_ranges = []
        start = -1
        end = -1
        for line_num in sorted(file_lines):
            if line_num == end + 1:
                end += 1
            else:
                if start > 0:
                    line_ranges.append([start, end])
                    # print(file_name, start, end)
                start = line_num
                end = start
        # last group
        if start > 0:
            line_ranges.append([start, end])
            # print(file_name, start, end)

        reorg_line_set.append({'name': os.path.basename(file_name), 'lines': line_ranges})

    #print(json.dumps(reorg_line_set, indent=4, sort_keys=True))
    json_str = str(json.JSONEncoder().encode(reorg_line_set))
    json.loads(json_str) # validate
    print(json_str)
