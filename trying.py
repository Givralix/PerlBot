import markovify
import random
import textblob
import time

def generate_answer(question):
	#question = question.decode('UTF-8')

	f = open('shitpost_database', 'r')
	shitpost = f.read().split("\n")
	f.close()
	
	f = open('chat_database', 'r')
	chat = f.read().split("\n")
	f.close()
	
	sentences = []
	for i in range(7):
		sentences.append(random.choice(shitpost))

	# i use the tags from the base_sentence and words from the other sentences to make a new sentence
	base_sentence = textblob.TextBlob(random.choice(sentences))
	sentences.remove(base_sentence)
	for i in range(3):
		sentences.append(random.choice(chat))
	sentences.append(question)

	wiki = []
	for i in range(len(sentences)):
		wiki.append(textblob.TextBlob(sentences[i]))
	
	print("base_sentence:",base_sentence.tags)
	for i in range(len(wiki)):
		print(wiki[i].tags)
	new_sentence = []
	# tracking where we are in the sentence
	a = 0
	# tracking how many times it tried looking for words
	done = 0
	while done < 2:
		for j in range(len(wiki[i].tags)):
			try:
				if wiki[i].tags[j][1] == base_sentence.tags[a][1]:
					new_sentence.append(wiki[i].tags[j][0])
					a += 1
					if a == len(base_sentence.tags): break
			except IndexError:
				pass
		i += 1
		if i == len(wiki):
			i = 0
			done += 1

	result = ""
	for i in range(len(new_sentence)):
		result += new_sentence[i] + " "
	return result
print(generate_answer("Steven back away. Its time to boop the snoot."))
