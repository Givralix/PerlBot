#!/usr/bin/perl
use utf8;
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON::XS;
use Inline Python => <<'END';
import markovify

def generate_sentence():
	with open("shitpost_database",'r',) as f:
		text = f.read()

	text_model = markovify.NewlineText(text)
	
	return text_model.make_sentence(tries=100)
END
use strict;

##### FUNCTIONS
# posting function
sub posting_text {
	my($blog) = $_[0];
	my($body) = $_[1];
	utf8::decode($body);
	my $url = 'http://api.tumblr.com/v2/blog/' . $blog . '/post';
	open my $f, "<", "tokens"
		or die "Couldn't open token file: $!";
	my $file = <$f>;
	my @tokens = split(';', $file);
	close $f;
	my $request =
		Net::OAuth->request("protected resource")->new
			(request_url => $url,
			'consumer_key' => $tokens[0],
			'consumer_secret' => $tokens[1],
			'token' => $tokens[2],
			'token_secret' => $tokens[3],
			'signature_method' => 'HMAC-SHA1',
			request_method => 'POST',
			timestamp => time(),
			nonce => rand(1000000),
			extra_params => {
				'type' => 'text',
				'body' => $body,
				'tags' => 'random thought,PerlBot',
		},);
	$request->sign;
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request(POST $url, Content => $request->to_post_body);
	my $date = localtime();
	if ( $response->is_success ) {
		my $r = decode_json($response->content);
		if($r->{'meta'}{'status'} == 201) {
			my $item_id = $r->{'reponse'}{'id'};
			print "[$date] Following tumblr entry added:\n$body";
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

my $blog = 'perlbot.tumblr.com';
my $body = generate_sentence();

posting_text($blog, $body);
