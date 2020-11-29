#!/usr/bin/env python

import sys
import xml.etree.ElementTree as et
import os.path

config_files = ['/usr/local/hawq/etc/hawq-site.xml', '/usr/local/hawq/etc/magma-site.xml']

if __name__ == '__main__':
    assert (len(sys.argv) <= 3)

    for config_file in config_files:
        if not os.path.isfile(config_file):
            continue
        tree = et.parse(config_file)
        root = tree.getroot()
        if len(sys.argv) == 2:
            name = sys.argv[1]
            value_node = root.find(".//property[name='{}']/./value".format(name))
            print('undefined' if value_node is None else value_node.text)
            exit

        if len(sys.argv) == 3:
            name = sys.argv[1]
            value = sys.argv[2]
            value_node = root.find(".//property[name='{}']/./value".format(name))
            if value_node is None:
                property_node = et.SubElement(root, 'property')
                name_node = et.SubElement(property_node, 'name')
                value_node = et.SubElement(property_node, 'value')
                name_node.text = name
                value_node.text = value
            else:
                value_node.text = value
            tree.write(config_file)
