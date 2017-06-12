#!/usr/bin/perl
require "./perlbot.pl";

use strict;
use warnings;

my $p = new Lingua::EN::Tagger;

my @no_space = (
	",",
	".",
	";",
	"?",
	"!",
	"...",
	"n't",
	"'",
);

print generate_answer($p, "How are you?", \@no_space) . "\n";
