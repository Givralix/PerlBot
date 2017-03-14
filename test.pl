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

my @submissions = @{$blog->posts_submission->{posts}};
print @submissions . "\n";
