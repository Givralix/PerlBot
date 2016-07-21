import markovify
import random

def generate_answer(question):
	f = open('shitpost_database', 'r')
	text = list(f) 

	sentences = []
	for i in range(10):
		sentences.append(text[random.randint(0,len(text))-1])
	for i in range(len(question)):
		sentences.append(question[i])
	print(sentences)
	text = ''

	for i in range(len(sentences)):
		text += sentences[i] + '\n'

	text_model = markovify.NewlineText(text)
	
	return text_model.make_sentence(tries=100)
print(generate_answer(["You know who's an awesome bisexual?", 'Pearl from Steven Universe!','hi meowstic-seer','pearl is lesbian.']))
