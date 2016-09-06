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
use Inline Python => <<'END';
import markovify
import random
import textblob

def generate_sentence():
	with open("shitpost_database",'r',) as f:
		text = f.read()
	
	with open("chat_database",'r',) as f:
		text += f.read()
	
	text_model = markovify.NewlineText(text)
	
	return text_model.make_sentence(tries=100)

def generate_answer(question):
	try:
		question = question.decode('UTF-8')
	except AttributeError:
		print("Could not decode the question")

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
	print(base_sentence)
	for i in range(len(wiki)):
		print(wiki[i].tags)
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
		if done == 10:
			break
		#print(i)
	
	result = ""
	for i in range(len(new_sentence)):
		result += new_sentence[i] + " "
	return result
END
use strict;
use warnings;

open my $f, "<", "tokens"
	or die "Couldn't open token file: $!";
my $file = <$f>;
chop($file);
my @tokens = split(';', $file);
close $f;

my $t = WWW::Tumblr->new(
	'consumer_key' => $tokens[0],
	'secret_key' => $tokens[1],
	'token' => $tokens[2],
	'token_secret' => $tokens[3],
);

# for the reblog function
my %request_params = (
	'consumer_key' => $tokens[0],
	'consumer_secret' => $tokens[1],
	'token' => $tokens[2],
	'token_secret' => $tokens[3],
	'signature_method' => 'HMAC-SHA1',
);

my $blog = $t->blog('perlbot.tumblr.com');
die Dumper $blog->error unless $blog->info();

## MY FUNCTIONS
# answering all asks in the inbox except already answered ones
sub answer_asks
{
	my $blog = $_[0];
	my @submissions = @{$blog->posts_submission->{posts}};
	open my $f, "<", "answered_asks_ids"
		or die "Could not open file 'answered_asks_ids' $!";
	my @previous_ids = <$f>;
	for (my $i = 0 ; $i <= $#previous_ids ; $i++) {
		chop($previous_ids[$i]);
	}
	close $f;
	my %previous_ids_hash = map { $_ => 1 } @previous_ids;
	for (my $i = 0 ; $i <= $#submissions ; $i++) {
		print "\nAsk #$submissions[$i]{id} sent by $submissions[$i]{asking_name} at $submissions[$i]{date}:\n$submissions[$i]{question}\n";

		# checking if the ask was already answered
		if (exists($previous_ids_hash{$submissions[$i]{id}})) {
			print "Already answered.\n";
			next;
		}

		# checking if I should answer the ask instead of PerlBot
		if (index($submissions[$i]{question}, "((") != -1) {
			print "Ignored.\n";
			next;
		}

		my $question = $submissions[$i]{question};
		encode_entities($question);

		my $answer = '';
		while (42) {
			$answer = generate_answer($question);
			unless($answer eq '') {
				last;
			}
		}
		encode_entities($answer);
		my $body = "<b><a spellcheck=\"false\" class=\"tumblelog\">\@$submissions[$i]{asking_name}</a>: $question</b><br/><br/>$answer";
		my $date = localtime();
		if ( my $post = $blog->post( type => 'text', body => $body, tags => "answer,PerlBot,$submissions[$i]{asking_name}", ) ) {
			print "[$date] Following tumblr entry posted: $body\n";
		} else {
			print STDERR Dumper $blog->error;
			die "[$date] Couldn't post following tumblr entry: $body";
		}

		open($f, '>>', "chat_database") or die "Could not open file 'chat_database' $!";
		say $f $submissions[$i]{question};
		close $f;
		open($f, '>>', "answered_asks_ids") or die "Could not open file 'answered_asks_ids' $!";
		say $f $submissions[$i]{id};
		close $f;
	}
}

# reblogging posts (not in WWW::Tumblr so i have to make my own)
sub reblog {
	my $type = $_[1];
	my $comment = $_[2];
	my $id = $_[3];
	my $reblog_key = $_[4];
	my $tags = $_[5];
	my $request_params = %{ $_[6] };
	utf8::decode($comment);
	my $request =
		Net::OAuth->request("protected resource")->new
			(request_url => 'http://api.tumblr.com/v2/blog/perlbot/post/reblog',
			%request_params,
			timestamp => time(),
			nonce => rand(1000000),
			request_method => 'POST',
			extra_params => {
				'type' => $type,
				'comment' => $comment,
				'tags' => $tags,
				'id' => $id,
				'reblog_key' => $reblog_key,
		},);
	print Dumper($request) . "\n";
	$request->sign;
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request(POST 'http://api.tumblr.com/v2/blog/perlbot/post/reblog', Content => $request->to_post_body);
	my $date = localtime();
	if ( $response->is_success ) {
		my $r = decode_json($response->content);
		if($r->{'meta'}{'status'} == 201) {
			print "[$date] Successfully reblogged and added: $comment\n";
		} else {
			printf("[$date] Couldn't reblog: %s\n",
				$r->{'meta'}{'msg'});
		}
	} else {
	printf("[$date] Couldn't reblog: %s\n",
			$response->as_string);
	}
	return;
}

foreach (0..1) {
	my $body = generate_sentence();
	encode_entities($body);
	my $date = localtime();
	if ( my $post = $blog->post( type => 'text', body => $body, tags => "random thought,PerlBot", state => "queue", ) ) {
		print "[$date] Following tumblr entry queued: $body\n";
	} else {
		print STDERR Dumper $blog->error;
		die "[$date] Couldn't queue following tumblr entry: $body";
	}
}

answer_asks($blog, \%request_params);
