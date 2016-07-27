#!/usr/bin/perl
use utf8;
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON::XS;
use WWW::Tumblr;
use Inline Python => <<'END';
import markovify
import random

def generate_sentence():
	with open("shitpost_database",'r',) as f:
		text = f.read()
	
	text_model = markovify.NewlineText(text)
	
	return text_model.make_sentence(tries=100)

def generate_answer(question):
	with open("shitpost_database",'r',) as f:
		text = list(f)
	
	sentences = []
	for i in range(10):
		number = random.randint(0,len(text))
		if sentences.count(text[number]) == 0:
			sentences.append(text[number])
		else:
			i == i - 1
			continue
	for i in range(len(question)):
		sentences.append(question[i])

	text_model = markovify.NewlineText(sentences)
	
	return text_model.make_sentence(tries=100)
END
use strict;

open my $f, "<", "tokens"
	or die "Couldn't open token file: $!";
my $file = <$f>;
my @tokens = split(';', $file);
close $f;

my $t = WWW::Tumblr->new(
	'consumer_key' => $tokens[0],
	'secret_key' => $tokens[1],
	'token' => $tokens[2],
	'token_secret' => $tokens[3],
);

my $blog = $t->blog('perlbot.tumblr.com');

my $info = $blog->info;
print $info . "\n";
