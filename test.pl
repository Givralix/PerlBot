use strict;
use warnings;

use Test::More;

use_ok('WWW::Tumblr');

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

my $posts = $blog->posts;

ok $posts,                              'posts is set';

ok ref $posts,                          'posts is s reference';
is ref $posts, 'HASH',                  'a HASH reference';

ok ! $blog->posts( id => 1234567890 ),  'this should be an error';
ok $blog->posts( type => 'video' ),     'this should be fine';
ok $blog->posts_queue,                  'posts/queue';
ok $blog->posts_draft,                  'posts/draft';
ok $blog->posts_submission,             'posts/submission';

done_testing();
print $blog->posts( type => 'video' ) . "\n";
print $blog->posts_queue . "\n";
print $blog->posts_draft . "\n";
print $blog->posts_submission . "\n";
