#!/usr/bin/perl
use utf8;
binmode STDOUT, ':utf8';
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use Data::Dumper;
use JSON::XS;
use HTML::Entities;
use String::Markov;
use WWW::Tumblr;
use Lingua::EN::Tagger;
use XML::LibXML;
srand;
use File::Random qw/random_line/;

use strict;
use warnings;
# for the reblog function (unused)
#my %request_params = (
#	'consumer_key' => $tokens[0],
#	'consumer_secret' => $tokens[1],
#	'token' => $tokens[2],
#	'token_secret' => $tokens[3],
#	'signature_method' => 'HMAC-SHA1',
#);

## MY FUNCTIONS
# answering all asks in the inbox except already answered ones
sub answer_asks
{
	my $blog = $_[0];
	my $parser = new Lingua::EN::Tagger;
	my @no_space = (
		",",
		".",
		";",
		"?",
		"!",
		"...",
		"n't",
		"'",
	);
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
		if ($submissions[$i]{id} ~~ @previous_ids) {
			print "Already answered.\n";
			next;
		}

		my $question = $submissions[$i]{question};
		# make the question html safe
		encode_entities($question);

		my $answer = generate_answer($parser, $question, \@no_space);

		# make the answer html safe
		encode_entities($answer);
		my $body = "<b><a spellcheck=\"false\" class=\"tumblelog\">\@$submissions[$i]{asking_name}</a>: $question</b><br/><br/>$answer";
		my $date = localtime();
		if ( my $post = $blog->post( type => 'text', body => $body, tags => "answer,PerlBot,$submissions[$i]{asking_name}", state => "private", ) ) {
			print "[$date] Following tumblr entry posted: $body\n";
		} else {
			print STDERR Dumper $blog->error;
			die "[$date] Couldn't post following tumblr entry: $body";
		}

		open($f, '>>', "blog_dialogue.txt") or die "Could not open file 'blog_dialogue.txt' $!";
		say $f $submissions[$i]{question};
		close $f;
		open($f, '>>', "answered_asks_ids") or die "Could not open file 'answered_asks_ids' $!";
		say $f $submissions[$i]{id};
		close $f;
	}
}

# generate sentences
sub generate_sentence {
	my $markov = $_[0];
	my %forbidden_sentences = %{$_[1]};
	my $sentence = $markov->generate_sample();
	while ( $forbidden_sentences{$sentence} ) {
		#print $sentence . "\n";
		$sentence = $markov->generate_sample();
	}
	return $sentence;
}

# generate answers
sub generate_answer {
	my $p = $_[0]; # Lingua::EN::Tagger object
	my $question = $_[1];
	# hash containing punctuation that doesn't require a space before it
	my @no_space = @{$_[2]};

	my @sentences = ($question,);
	push(@sentences, random_line("show_dialogue.txt", 3));
	push(@sentences, random_line("blog_dialogue.txt", 1));

	foreach (@sentences) {
		$_ =~ s/[<>]//g;
	}

	# get text + base sentence tags
	my $text = XML::LibXML->load_xml( string => "<base>" . $p->add_tags(join('', @sentences, $question)) . "</base>");
	my $base_sentence = XML::LibXML->load_xml( string => "<base>" . $p->add_tags($sentences[2]) . "</base>" );

	# making the sentence
	my $answer = '';

	foreach my $tag ($base_sentence->findnodes('/base/*')) {
		my $nodeName = $tag->nodeName . "\n";
		my $word = "";

		if (my $node = $text->findnodes("/base/$nodeName")->[0]) {
			$word = $node->to_literal();
			# delete the node
			$node->unbindNode();
			# join the answer and the new word
			if ($answer eq '') {
				$answer = $word;
			} elsif ($word ~~ @no_space) {
				$answer = $answer . $word;
			} elsif (!$word eq '') {
				$answer = $answer . " $word";
			}
		} else {
			warn "Skipping word\n";
		}
	}

	return $answer;
}

# reblogging posts (not in WWW::Tumblr so i have to make my own) (unused) (i need to fork WWW::Tumblr and add this)
#sub reblog {
#	my $type = $_[1];
#	my $comment = $_[2];
#	my $id = $_[3];
#	my $reblog_key = $_[4];
#	my $tags = $_[5];
#	my $request_params = %{ $_[6] };
#	utf8::decode($comment);
#	my $request =
#		Net::OAuth->request("protected resource")->new
#			(request_url => 'http://api.tumblr.com/v2/blog/perlbot/post/reblog',
#			%request_params,
#			timestamp => time(),
#			nonce => rand(1000000),
#			request_method => 'POST',
#			extra_params => {
#				'type' => $type,
#				'comment' => $comment,
#				'tags' => $tags,
#				'id' => $id,
#				'reblog_key' => $reblog_key,
#		},);
#	print Dumper($request) . "\n";
#	$request->sign;
#	my $ua = LWP::UserAgent->new;
#	my $response = $ua->request(POST 'http://api.tumblr.com/v2/blog/perlbot/post/reblog', Content => $request->to_post_body);
#	my $date = localtime();
#	if ( $response->is_success ) {
#		my $r = decode_json($response->content);
#		if($r->{'meta'}{'status'} == 201) {
#			print "[$date] Successfully reblogged and added: $comment\n";
#		} else {
#			printf("[$date] Couldn't reblog: %s\n",
#				$r->{'meta'}{'msg'});
#		}
#	} else {
#	printf("[$date] Couldn't reblog: %s\n",
#			$response->as_string);
#	}
#	return;
#}

# queue a post generated by generate_sentence()
sub queue_post {
	my $blog = $_[0];
	my $body = $_[1];
	encode_entities($body);
	my $date = localtime();
	if ( my $post = $blog->post( type => 'text', body => $body, tags => "random thought,PerlBot", state => "queue", ) ) {
		print "[$date] Following tumblr entry queued: $body\n";
	} else {
		print STDERR Dumper $blog->error . "\n";
		die "[$date] Couldn't queue following tumblr entry: $body";
	}
}

1;
