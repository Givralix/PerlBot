import markovify
import random

def generate_answer(question):
	f = open('shitpost_database', 'r')
	text = list(f) 

	sentences = []
	for i in range(10):
		number = random.randint(0,len(text))
	for i in range(len(question)):
		sentences.append(question[i])
	
	text = ''

	for i in range(len(sentences)):
		text += sentences[i] + '\n'

	text_model = markovify.NewlineText(text)
	
	return text_model.make_sentence(tries=100)
print(generate_answer(['hey minnie!','Pearl is a lesbian just like you!','hi thegaypanic','this is a certain thing.']))
