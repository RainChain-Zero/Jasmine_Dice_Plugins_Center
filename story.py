with open('story.txt', 'r', encoding='utf-8') as f:
    story = f.read()

words = story.split('/')

tmp = []
res = []
for i in range(1, len(words)):
    word_new = words[i].strip().replace(
        '\n', r'{FormFeed}{FormFeed}{FormFeed}{FormFeed}')
    tmp.append(word_new+r'\n')
    # 每3句话组成一个段落
    if i % 3 == 0:
        tmp[2] = tmp[2].replace(r'\n', '')
        res.append("'"+''.join(tmp)+"',\n")
        tmp = []
    # words[i] = f"'{word_new}',\n"

with open('story1.txt', 'w', encoding='utf-8') as f:
    f.writelines(res)
