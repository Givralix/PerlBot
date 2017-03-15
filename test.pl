#!/usr/bin/perl
use utf8;
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use WWW::Tumblr;
use Data::Dumper;
use JSON::XS;
use HTML::Entities;
use String::Markov;

use strict;
use warnings;

open my $f, "<", "tokens"
	or die "Couldn't open token file: $!";
my $file = <$f>;
chop($file);
my @tokens = split(';', $file);
close $f;

my $blog = WWW::Tumblr::Blog->new(
	'consumer_key' => $tokens[0],
	'secret_key' => $tokens[1],
	'token' => $tokens[2],
	'token_secret' => $tokens[3],
	'base_hostname' => 'perlbot.tumblr.com',
);

#my @submissions = @{$blog->posts_submission->{posts}};
#print @submissions . "\n";
my $markov = String::Markov->new(
		order => 2,
		sep => '',
		split_sep => ' ',
		join_sep => ' ',
		null => "\0",
		stable => 1,
		normalize => undef,
		do_chomp => 1,
);
my @list = (
	"show_dialogue.txt",
	"blog_dialogue.txt",
);

#open(DATA,"<show_dialogue.txt") or die "Can't open data";
#my @lines = <DATA>;
#close(DATA);

my @files = (
	"show_dialogue.txt",
	"blog_dialogue.txt",
);

open $f, $files[0] or die "couldn't open 'show_dialogue.txt': $!";
my @show_dialogue = <$f>;
close FILE;

open $f, $files[1] or die "couldn't open 'blog_dialogue.txt': $!";
my @blog_dialogue = <$f>;
close FILE;

chomp(@show_dialogue);
chomp(@blog_dialogue);

my %forbidden_sentences;
$forbidden_sentences{$_} = 1 for @show_dialogue;
$forbidden_sentences{$_} = 1 for @blog_dialogue;

$markov->add_files(@files);

sub generate_sentence {
	my $markov = $_[0];
	my %forbidden_sentences = %{$_[1]};
	my $sentence = $markov->generate_sample();
	while ( $forbidden_sentences{$sentence} ) {
		print $sentence . "\n";
		$sentence = $markov->generate_sample();
	}
	return $sentence;
}
print $forbidden_sentences{"Hey, Steven..."} . "\n";
print generate_sentence($markov, \%forbidden_sentences) . "\n";
