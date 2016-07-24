import markovify
import random
import textblob

def generate_answer(question):
	f = open('shitpost_database', 'r')
	text = f.read().split("\n")
	f.close()
	
	sentences = []
	for i in range(10):
		sentences.append(text[random.randint(0,len(text))-1])
	for i in range(len(question)):
		sentences.append(question[i])
	
	wiki = []
	for i in range(len(sentences)):
		wiki.append(textblob.TextBlob(sentences[i]))
	
	# i use the tags from the base_sentence and words from the other sentences to make a new sentence
	base_sentence = wiki[random.randint(0,10)].tags
	new_sentence = []
	# tracking where we are in the sentence
	a = 0
	for i in range(len(wiki)):
		for j in range(len(wiki[i].tags)):
			if wiki[i].tags[j][1] == base_sentence[a][1] and random.randint(0,4) != 0:
				new_sentence.append(wiki[i].tags[j][0])
				a += 1
			if a == len(base_sentence): break
		if a == len(base_sentence): break
	
	result = ""
	for i in range(len(new_sentence)):
		result += new_sentence[i] + " "
	return result

print(generate_answer(["Perl, I was wondering...","Do all Pearls use spears?","What are your opinions on this?"]))
