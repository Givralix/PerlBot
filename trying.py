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
	print(sentences)

	wiki = []
	for i in range(len(sentences)):
		wiki.append(textblob.TextBlob(sentences[i]))
		print(wiki[i].tags)
	base_sentence = wiki[random.randint(0,10)]



	for i in range(len(sentences)):
		text += sentences[i] + '\n'

print(generate_answer(["skylar... pearl in a tux is really great and if you could see it your little robot lesbian heart would flutter.","Shadow yet love for learning how to use emojis seeing as how you.","tux?"]))
