#!/usr/bin/perl
# Input:
#   $ARGV[0] property.name 
#   $ARGV[1] property.value

use v5.10;
use strict;
use warnings;
use XML::LibXML;

my $configFile = '/usr/local/hawq/etc/hawq-site.xml';
my $dom = XML::LibXML->load_xml(location => $configFile);

my $name= $ARGV[0];
my $value = $ARGV[1];

# Add property
if (!$dom->exists("//name[text()='$name']/ancestor::property")) {
	if ($value) {
		say $name, ": = ", $value;
	
		my $nameElem = $dom->createElement('name');
		$nameElem->appendText("$name");
		my $valueElem = $dom->createElement('value');
		$valueElem->appendText("$value");
	
		my $propElem = $dom->createElement('property');
		$propElem->appendChild($nameElem);
		$propElem->appendChild($valueElem);
	
		my $configElem = $dom->documentElement;
		$configElem->appendChild($propElem);
	}
} else {
	# Modify property
	foreach my $propElem ($dom->findnodes("//name[text()='$name']/ancestor::property")) {
		my $valueElem = $propElem->getChildrenByTagName('value')->get_node(0);
		if (!$value) {
			say $name, ": ", $valueElem->textContent;
		} else {
			say $name, ": ", $valueElem->textContent, "  =>  ", $value;
			$valueElem->firstChild->setData($value);
		}
	}
}


# Output file
$dom->toFile($configFile, 2);

