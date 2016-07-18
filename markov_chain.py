import markovify

with open("shitpost_database",'r',) as f:
	text = f.read()

text_model = markovify.NewlineText(text)

for i in range(5):
	print(text_model.make_sentence())
