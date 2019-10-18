#!/usr/bin/env python

import sys
import xml.etree.ElementTree as ET

config_file = '/usr/local/hawq/etc/hawq-site.xml'
tree = ET.parse(config_file)
root = tree.getroot()

if __name__ == '__main__':
    assert (len(sys.argv) <= 3)

    if len(sys.argv) == 2:
        name = sys.argv[1]
        value_node = root.find(".//property[name='{}']/./value".format(name))
        print('' if value_node is None else value_node.text)

    if len(sys.argv) == 3:
        name = sys.argv[1]
        value = sys.argv[2]
        value_node = root.find(".//property[name='{}']/./value".format(name))
        if value_node is None:
            property_node = ET.SubElement(root, 'property')
            name_node = ET.SubElement(property_node, 'name')
            value_node = ET.SubElement(property_node, 'value')
            name_node.text = name
            value_node.text = value
        else:
            value_node.text = value
        tree.write(config_file)
