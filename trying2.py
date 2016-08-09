from gensim import corpora
from collections import defaultdict
from pprint import pprint  # pretty-printer

f = open("shitpost_database")
documents = list(f)
f.close()

stoplist = set('for a of the and to in'.split())
texts = [[word for word in document.lower().split() if word not in stoplist]
	for document in documents]

# remove words that appear only once
frequency = defaultdict(int)
for text in texts:
	for token in text:
		frequency[token] += 1
texts = [[token for token in text if frequency[token] > 1]
	for text in texts]
pprint(texts)
dictionary = corpora.Dictionary(texts)
dictionary.save('test.dict')  # store the dictionary, for future reference
print(dictionary)
print(dictionary.token2id)
new_doc = documents[1111]
print(new_doc)
new_vec = dictionary.doc2bow(new_doc.lower().split())
print(new_vec)
