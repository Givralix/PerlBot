#!/usr/bin/perl
use utf8;
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON::XS;
use strict;

##### FUNCTIONS
# posting function
sub posting_text {
	my($blog) = $_[0];
	my($body) = $_[1];
	utf8::decode($body);
	my(%oauth_api_params) = $_[2];
	my $url = 'http://api.tumblr.com/v2/blog/' . $blog . '/post';
	my $request =
		Net::OAuth->request("protected resource")->new
			(request_ul => $url,
			%oauth_api_params,
			timestamp => time(),
			nonce => rand(1000000),
			extra_params => {
				'type' => 'text',
				'body' => $body,
		});
	$request->sign;
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request(POST $url, Content => $request->to_post_body);
	if ( $response->is_success ) {
		my $r = decode_json($response->content);
		if($r->{'meta'}{'status'} == 201) {
			my $item_id = $r->{'reponse'}{'id'};
			my $date = localtime();
			print "[$date] Following tumblr entry added:\n$body";
		} else {
			my $date = localtime();
			printf("[$date] Cannot create Tumblr entry: %s\n",
				$r->{'meta'}{'msg'});
		}
	} else {
	my $date = localtime();
	printf("[$date] Cannot create Tumblr entry: %s\n",
			$response->as_string);
	}
	return;
}

my $mc = StupidMarkov->new();
my @files = ['shitpost_database'];
$mc->add_files(@files);
my $mc = String::Markov->new(order => 1, sep => ' ');
my $body = $mc->generate_sample;

my $blog = 'perlbot.tumblr.com';

# authentifying
my %oauth_api_params =
	('consumer_key' =>
		'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
	 'consumer_secret' =>
		'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
	 'token' =>
		'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
	 'token_secret' =>
		'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
	 'signature_method' =>
		'HMAC-SHA1',
	 request_method => 'POST',
);
posting_text($blog, $body, %oauth_api_params);
