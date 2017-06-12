#!/usr/bin/perl
require "./perlbot.pl";

my $p = new Lingua::EN::Tagger;

@no_space = (
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
