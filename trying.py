import markovify
import random
import textblob

def generate_answer(question):
	f = open('shitpost_database', 'r')
	text = list(f)
	f.close()

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

with open('shitpost_database','r') as f:
	text = f.read()
tokens = nltk.word_tokenize(text)
tagged = nltk.pos_tag(tokens)
print(text.generate())
