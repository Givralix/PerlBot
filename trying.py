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
	
	# i use the tags from the base_sentence and words from the other sentences to make a new sentence
	base_sentence = wiki[random.randint(0,10)].tags
	print(base_sentence)
	new_sentence = []
	# tracking where we are in the sentence
	a = 0
	for i in range(len(wiki)):
		for j in range(len(wiki[i].tags)):
			print(wiki[i].tags[j][0])
			if wiki[i].tags[j][1] == base_sentence[a][1] and random.randint(0,4) != 0:
				new_sentence.append(wiki[i].tags[j][0])
				print("new_sentence[",a,"]: ",new_sentence[a],sep='')
				a += 1
			if a == len(base_sentence): break
		if a == len(base_sentence): break
	
	result = ""
	for i in range(len(new_sentence)):
		result += new_sentence[i] + " "
	return result

print(generate_answer(["skylar... pearl in a tux is really great and if you could see it your little robot lesbian heart would flutter.","Shadow yet love for learning how to use emojis seeing as how you.","tux?"]))
