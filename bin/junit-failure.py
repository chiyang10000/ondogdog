#!/usr/bin/env python

import sys
import xml.etree.ElementTree as et
import os.path

if __name__ == '__main__':
    assert (len(sys.argv) == 2)
    assert (os.path.isfile(sys.argv[1]))
    file_name = sys.argv[1]
    tree = et.parse(file_name)
    root = tree.getroot()

    for testsuite in root.findall(".//testsuite"):
        for testcase in testsuite.findall("./testcase[failure]"):
            print("{}.{}".format(testsuite.attrib["name"],
                                 testcase.attrib["name"]))
            print('')
            print(testcase.find('failure').text)
