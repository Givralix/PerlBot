# PerlBot
This is a tumblr bot mainly written in Perl (and some Python)! So far it's not complete at all but I'm working on it.<br/>
It's based on Pearl from Steven Universe :D<br/>
The blog is at [http://perlbot.tumblr.com/](http://perlbot.tumblr.com/)

## Branches
### master
This branch is stable and has the code I use for posting posts most of the time

## Files
### perlbot.pl
All the functions for perlbot.

There is no official Tumblr API for Perl, but there is WWW::Tumblr, which I use.

(the official Tumblr API documentation is also very useful!)

### main.pl
This script calls the functions written in perlbot.pl to queue posts and answer asks.

For obvious reasons, I removed the OAuth parameters from the code (they're stored in environment variables).

### show_dialogue.txt
This is all the dialogue that Pearl ever says for the Markov Chain to generate sentences from.

So far it has the dialogue from all the episodes from Gem Glow to Lars' Head.

I get it from the Steven Universe wikia and each sentence is on its own line.

### blog_dialogue.txt
All the messages Perlbot got from the blog

### answered\_asks\_ids
The ids of asks that were already answered (since I don't know how to remove them from the inbox) (soon to be unused)

### hourly\_update\_script.sh
The script that is run hourly.

It:
1.	Fetches the remote repository & merges
2.	Runs main.pl
3.	Makes a commit of blog_dialogue.txt
4.	Pushes it to Github

## Dependencies
### Perl
*	utf8
*	Net::OAuth
*	HTTP::Request::Common
*	LWP::UserAgent
*	WWW::Tumblr
*	Inline::Python
*	Data::Dumper
*	HTML::Entities
*	String::Markov
*	Lingua::EN::Tagger
*	XML::LibXML
*	File::Random
