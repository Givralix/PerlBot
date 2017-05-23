#!/usr/bin/perl
use utf8;
#use Net::OAuth;
#$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
#use HTTP::Request::Common;
#use LWP::UserAgent;
#use WWW::Tumblr;
use Data::Dumper;
#use JSON::XS;
#use HTML::Entities;
use String::Markov;
use Lingua::EN::Tagger;
use XML::LibXML;
srand;
use File::Random qw/random_line/;
#use YAX::Parser;

use strict;
use warnings;

#open my $f, "<", "tokens"
#	or die "Couldn't open token file: $!";
#my $file = <$f>;
#chop($file);
#my @tokens = split(';', $file);
#close $f;

#my $blog = WWW::Tumblr::Blog->new(
#	'consumer_key' => $tokens[0],
#	'secret_key' => $tokens[1],
#	'token' => $tokens[2],
#	'token_secret' => $tokens[3],
#	'base_hostname' => 'perlbot.tumblr.com',
#);

#my @submissions = @{$blog->posts_submission->{posts}};
#print @submissions . "\n";
my $markov = String::Markov->new(
		order => 2,
		sep => '',
		split_sep => ' ',
		join_sep => ' ',
		null => "\0",
		stable => 1,
		do_normalize => undef,
		do_chomp => 1,
);

my @files = (
	"show_dialogue.txt",
	"blog_dialogue.txt",
);

open my $f, $files[0] or die "couldn't open 'show_dialogue.txt': $!";
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
		$sentence = $markov->generate_sample();
	}
	return $sentence;
}
#print generate_sentence($markov, \%forbidden_sentences) . "\n";


sub generate_answer {
	my $p = $_[0]; # Lingua::EN::Tagger object
	my $question = $_[1];

	my @sentences = random_line("show_dialogue.txt", 7);
	push(@sentences, random_line("blog_dialogue.txt", 3));

	my $text = XML::LibXML->load_xml( string => "<base>" . $p->add_tags(join('', @sentences, $question)) . "</base>");
	my $base_sentence = XML::LibXML->load_xml( string => "<base>" . $p->add_tags($sentences[6]) . "</base>" );

	my $answer = '';

	foreach my $tag ($base_sentence->findnodes('/base/*')) {
		my $nodeName = $tag->nodeName . "\n";
		my $word = "";

		eval {
			$word = $text->findnodes("/base/$nodeName")->[0]->to_literal();
		};
		if ($@) {
			warn "Skipping word\n";
		}
		if ($answer eq '') {
			$answer = $word;
		} else {
			$answer = $answer . " $word";
		}
	}

	return $answer;
}

my $base_sentence = "Our light-composed forms couldn’t keep their hands to your hipsYou know you put a fence up there, so this will be waiting for you.";
my $text = join("\n", @show_dialogue, $base_sentence);
# Create a parser object
my $p = new Lingua::EN::Tagger;
 
# Add part of speech tags to a text
my $tagged_base = "<base>" . $p->add_tags($base_sentence) . "</base>";
my $tagged_text = "<base>" . $p->add_tags($text) . "</base>";
 
# Get a readable version of the tagged text
my $readable_text = $p->get_readable($text);

$base_sentence = XML::LibXML->load_xml( string => $tagged_base );
$text = XML::LibXML->load_xml( string => $tagged_text );

# Making the new sentence
my $sentence = '';
foreach my $tag ($base_sentence->findnodes('/base/*')) {
	my $nodeName = $tag->nodeName . "\n";
	my $word = $text->findnodes("/base/$nodeName")->[0]->to_literal();
	if ($sentence eq '') {
		$sentence = $word;
	} else {
		$sentence = $sentence . " $word";
	}
}

print $sentence . "\n";

print generate_answer($p, "Do you like cats?");
