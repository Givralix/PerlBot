# PerlBot
This is a tumblr bot mainly written in Perl! So far it's not complete at all but I'm working on it.<br/>
It's based on Pearl from Steven Universe :D<br/>
The blog is at [http://perlbot.tumblr.com/](http://perlbot.tumblr.com/)

## Files
### markov_chain.py
This is a Python program that generates 8 sentences using a Markov Chain library (Markovify) and the "shitpost_database" text file.<br/>
I'm more fluent in Python than Perl but the Tumblr API only works with Python 2 and I hate it. Also I can't write a Pearl bot in Python when there's a language named Perl out there.

### test1.pl
This is basically most of the code for the bot.<br/>
Since there's no Tumblr API for Perl, I got the code for posting text posts from [this person](https://txlab.wordpress.com/2011/09/03/using-tumblr-api-v2-from-perl/#comment-7004) (which thankfully works).<br/>
For obvious reasons I removed the OAuth parameters from the code.

### shitpost_database
This is all the dialogue that Pearl ever says for the Markov Chain to generate sentences from.<br/>
So far it has the dialogue from the 31 first episodes of the show (Gem Glow to Alone Together) and the dialogue from Hit the Diamond. Feel free to help me complete it! (it's really boring)<br/>
I get it from the Steven Universe wikia and also each sentence is on its own line!

## Dependencies
### Python
*	Markovify

### Perl
*	Net::OAuth
*	HTTP::Request
*	LWP::UserAgent
*	JSON::XS
*	Inline::Python
