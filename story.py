with open('story.txt', 'r', encoding='utf-8') as f:
    story = f.read()

words = story.split('/')

for i in range(1, len(words)):
    word_new = words[i].strip().replace(
        '\n', r'{FormFeed}{FormFeed}{FormFeed}{FormFeed}')
    words[i] = f"'{word_new}',\n"

with open('story1.txt', 'w', encoding='utf-8') as f:
    f.writelines(words)
