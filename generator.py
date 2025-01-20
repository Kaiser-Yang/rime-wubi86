import random


def main():
    word_file = open('./wubi.extended.dict.yaml', 'r')
    output_file = open('./output.txt', 'w')
    words = []
    for line in word_file.readlines():
        if line.startswith('#'):
            continue
        try:
            word, code, weight = line.split('\t')
            # if len(code) != 1:
            #     continue
            # if int(weight) != 20:
            #     continue
        except:
            continue
        words.append((code, word))
    words.sort(key=lambda x: x[0])
    # shuffle words
    # random.shuffle(words)
    output_file.write('code\tword\n')
    for code, word in words:
        output_file.write(code + '\t' + word + '\n')


if __name__ == '__main__':
    main()
