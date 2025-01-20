def main():
    word_file = open('./wubi.extended.dict.yaml', 'r')
    origin_dict = open('./wubi.dict.yaml', 'r+')
    word_set = set()
    single_character_set = set()
    for line in word_file.readlines():
        try:
            word, _, _ = line.split('\t')
        except:
            continue
        if word.startswith('#'):
            continue
        word_set.add(word)
        single_character_set.add(word[0])
    new_lines = list()
    for line in origin_dict.readlines():
        line = line.split('\t')
        if len(line) < 3 or line[0] not in word_set:
            # replace the number in line with 30
            if line[0] in single_character_set:
                line[2] = '30'
                if len(line) == 3:
                    line[2] += '\n'
            new_lines.append('\t'.join(line))
            continue
    origin_dict.seek(0)
    origin_dict.truncate()
    origin_dict.write(''.join(new_lines))


if __name__ == '__main__':
    main()
