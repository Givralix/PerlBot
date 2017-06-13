#!/usr/bin/perl
require "./perlbot.pl";

my $blog = WWW::Tumblr::Blog->new(
	'consumer_key'  => $ENV{OAUTH_CONSUMER_KEY},
	'secret_key'    => $ENV{OAUTH_CONSUMER_SECRET},
	'token'         => $ENV{OAUTH_TOKEN},
	'token_secret'  => $ENV{OAUTH_TOKEN_SECRET},
	'base_hostname' => 'perlbot.tumblr.com',
);

die Dumper($blog->error) unless $blog->info();

my $markov = String::Markov->new(
		order     => 2,
		sep       => '',
		split_sep => ' ',
		join_sep  => ' ',
		null      => "\0",
		stable    => 1,
		normalize => 'C',
		do_chomp  => 1,
);

my @files = (
	"show_dialogue.txt",
	"blog_dialogue.txt",
);

$markov->add_files(@files);

open $f, $files[0] or die "couldn't open 'show_dialogue.txt': $!";
my @dialogue = <$f>;
close FILE;

open $f, $files[1] or die "couldn't open 'blog_dialogue.txt': $!";
push(@dialogue, <$f>);
close FILE;
chomp(@dialogue);

for (0..1) {
	my $sentence = generate_sentence($markov, \@dialogue);
	queue_post($blog, $sentence);
}

answer_asks($blog);
