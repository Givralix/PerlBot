import markovify
import random
import textblob

def generate_answer(question):
	f = open('shitpost_database', 'r')
	shitpost = f.read().split("\n")
	f.close()
	
	f = open('chat_database', 'r')
	chat = f.read().split("\n")
	f.close()
	
	sentences = []
	for i in range(7):
		sentences.append(shitpost[random.randint(0,len(shitpost)-1)])
	for i in range(3):
		sentences.append(chat[random.randint(0,len(chat)-1)])
	for i in range(len(question)):
		sentences.append(question[i])
	
	wiki = []
	for i in range(len(sentences)):
		wiki.append(textblob.TextBlob(sentences[i]))
	
	# i use the tags from the base_sentence and words from the other sentences to make a new sentence
	random_int = random.randint(0,7)
	base_sentence = wiki[random_int].tags
	del wiki[random_int]
	print(base_sentence)
	for i in range(len(wiki)):
		print(wiki[i].tags)
	new_sentence = []
	# tracking where we are in the sentence
	a = 0
	# tracking how many times it tried looking for words
	done = 0
	while i < len(wiki):
		for j in range(len(wiki[i].tags)):
			if wiki[i].tags[j][1] == base_sentence[a][1]:
				new_sentence.append(wiki[i].tags[j][0])
				a += 1
			if a == len(base_sentence): break
		i += 1
		if a == len(base_sentence):
			break
		elif i == len(wiki):
			i = 0
			done += 1
		if done == 2:
			break
		print(i)
	
	result = ""
	for i in range(len(new_sentence)):
		result += new_sentence[i] + " "
	return result

print(generate_answer(["what is the least painful way to kill yourself???"]))
