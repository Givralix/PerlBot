import re
f = open('to_parse')
to_parse = f.read()
match = r'^\s{23}\{$[\s*.*]+\s{23}\}'
capture = r'^\s{23}\{$(\s*.*)+\s{23}\}'
parsed = re.findall(capture,to_parse,re.MULTILINE)
print(parsed)
