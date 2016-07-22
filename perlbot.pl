#!/usr/bin/perl
use utf8;
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON::XS;
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

my %request_params = 
			('consumer_key' => $tokens[0],
			'consumer_secret' => $tokens[1],
			'token' => $tokens[2],
			'token_secret' => $tokens[3],
			'signature_method' => 'HMAC-SHA1',
		);

##### FUNCTIONS
# queueing text posts
sub queueing_text {
	my($blog) = $_[0];
	my($body) = $_[1];
	my $request_params = %{ $_[2] };
	utf8::decode($body);
	my $url = 'http://api.tumblr.com/v2/blog/' . $blog . '/post';
	my $request =
		Net::OAuth->request("protected resource")->new
			(request_url => $url,
			%request_params,
			request_method => 'POST',
			timestamp => time(),
			nonce => rand(1000000),
			extra_params => {
				'type' => 'text',
				'body' => $body,
				'tags' => 'random thought,PerlBot',
				'state' => 'queue',
		},);
	$request->sign;
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request(POST $url, Content => $request->to_post_body);
	my $date = localtime();
	if ( $response->is_success ) {
		my $r = decode_json($response->content);
		if($r->{'meta'}{'status'} == 201) {
			print "[$date] Following tumblr entry queued: $body\n";
		} else {
			printf("[$date] Cannot create Tumblr entry: %s\n",
				$r->{'meta'}{'msg'});
		}
	} else {
	printf("[$date] Cannot create Tumblr entry: %s\n",
			$response->as_string);
	}
	return;
}
# getting asks (or die trying)
sub getting_answers {
	my($blog) = $_[0];
	my $request_params = %{ $_[1] };
	my $url = 'http://api.tumblr.com/v2/blog/' . $blog . '/posts/submission';
	my $request =
		Net::OAuth->request("protected resource")->new(
			request_url => $url,
			%request_params,
			request_method => 'GET',
			timestamp => time(),
			nonce => rand(1000000),
		);
	$request->sign;
	my $ua = LWP::UserAgent->new;
	my $authorization_signature = $request->to_authorization_header;

	my $message = GET  . $url . '?' . $request->normalized_message_parameters . 'Authorization' => $authorization_signature;
	return $message;
}

my $blog = 'perlbot.tumblr.com';
my $body = generate_sentence();
my @question = ['hey minnie!','Pearl is a lesbian just like you!','hi thegaypanic','this is a certain thing.'];

print getting_answers($blog, \%request_params);
