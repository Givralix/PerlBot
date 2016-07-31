#!/usr/bin/perl
use utf8;
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON::XS;
use WWW::Tumblr;
use Data::Dumper;
use Inline Python => <<'END';
import markovify
import random
import textblob

def generate_sentence():
	with open("shitpost_database",'r',) as f:
		text = f.read()
	
	text_model = markovify.NewlineText(text)
	
	return text_model.make_sentence(tries=100)

def generate_answer(question):
	print(question)
	question = question.decode('UTF-8')

	f = open('shitpost_database', 'r')
	shitpost = f.read().split("\n")
	f.close()
	
	f = open('chat_database', 'r')
	chat = f.read().split("\n")
	f.close()
	
	sentences = []
	for i in range(7):
		sentences.append(shitpost[random.randint(0,len(shitpost)-1)])
	for i in range(3):
		sentences.append(chat[random.randint(0,len(chat)-1)])
	sentences.append(question)
	
	wiki = []
	for i in range(len(sentences)):
		wiki.append(textblob.TextBlob(sentences[i]))
	
	# i use the tags from the base_sentence and words from the other sentences to make a new sentence
	random_int = random.randint(0,7)
	base_sentence = wiki[random_int].tags
	del wiki[random_int]
	new_sentence = []

	# tracking where we are in the sentence
	a = 0
	# tracking how many times it tried looking for words
	done = 0
	while i < len(wiki):
		for j in range(len(wiki[i].tags)):
			if wiki[i].tags[j][1] == base_sentence[a][1]:
				new_sentence.append(wiki[i].tags[j][0])
				a += 1
			if a == len(base_sentence): break
		i += 1
		if a == len(base_sentence):
			break
		elif i == len(wiki):
			i = 0
			done += 1
		if done == 2:
			break
	
	result = ""
	for i in range(len(new_sentence)):
		result += new_sentence[i] + " "
	return result
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

sub answer_asks
{
	my $blog = $_[0];
	my @submissions = @{$blog->posts_submission->{posts}};
	my @asks = ();
	for(my $i = 0 ; $i <= $#submissions ; $i++) {
		print "Ask #$submissions[$i]{id} sent by $submissions[$i]{asking_name} at $submissions[$i]{date}:\n$submissions[$i]{question}\n";
		print "Answer it? (y/n) ";
		my $answer = <STDIN>;
		my @answers = ();
		if($answer == "y") {
			for(my $j = 0 ; $j < 10 ; $j++) {
				push(@answers, generate_answer($submissions[$i]{question}));
			}
			print join("\n", @answers);
			print "What answer do you choose? (0-9) ";
			my $answer = <STDIN> + 0;
			my $post = $blog->post( type => 'answer', comment => @answers[$answer], tags => 'answer,PerlBot' );
		}
	}
}
answer_asks($blog);
