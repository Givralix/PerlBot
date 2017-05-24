require "perlbot.pl";

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

my $markov = String::Markov->new(
		order => 2,
		sep => '',
		split_sep => ' ',
		join_sep => ' ',
		null => "\0",
		stable => 1,
		do_normalize => '',
		do_chomp => 1,
);

my @files = (
	"show_dialogue.txt",
	"blog_dialogue.txt",
);

$markov->add_files(@files);

open $f, $files[0] or die "couldn't open 'show_dialogue.txt': $!";
my @show_dialogue = <$f>;
close FILE;

open $f, $files[1] or die "couldn't open 'blog_dialogue.txt': $!";
my @blog_dialogue = <$f>;
close FILE;

chomp(@show_dialogue);
chomp(@blog_dialogue);

my %forbidden_sentences;
$forbidden_sentences{$_} = 1 for @show_dialogue;
$forbidden_sentences{$_} = 1 for @blog_dialogue;

my $p = new Lingua::EN::Tagger;

for (0..1) {
	my $sentence = generate_sentence($markov, \%forbidden_sentences);
	queue_post($blog, $sentence);
}

generate_answer($p, "text text text");
