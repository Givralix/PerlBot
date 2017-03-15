require "perlbot.pl";

use strict;
use warnings;

open my $f, "<", "tokens"
	or die "Couldn't open token file: $!";
my $file = <$f>;
close $f;
chomp($file);
my @tokens = split(';', $file);

my $blog = WWW::Tumblr::Blog->new(
	'consumer_key' => $tokens[0],
	'secret_key' => $tokens[1],
	'token' => $tokens[2],
	'token_secret' => $tokens[3],
	'base_hostname' => 'perlbot.tumblr.com',
);

die Dumper($blog->error) unless $blog->info();

for (0..1) {
	queue_post($blog);
}
