import os

def get_single_character_set() -> set:
    single_character_set = set()
    word_file = open('./wubi.extended.dict.yaml', 'r')
    for line in word_file.readlines():
        try:
            word, _, _ = line.split('\t')
        except:
            continue
        if word.startswith('#'):
            continue
        single_character_set.add(word[0])
    return single_character_set

def read_word_freq_files() -> list:
    # read all the files in ./freq
    lines = []
    word_freq_files = []
    for root, _, files in os.walk('./freq'):
        for file in files:
            word_freq_files.append(os.path.join(root, file))
    for file in word_freq_files:
        with open(file, 'r', encoding='utf-8') as f:
            temp = []
            for line in f.readlines():
                try:
                    word, freq = line.split('\t')
                    if len(word) != 2:
                        continue
                    # remove non digits in freq
                    freq = ''.join(filter(str.isdigit, freq))
                    line = word + '\t' + freq
                    temp.append(line)
                except:
                    continue
            lines.append(temp)
    return lines


def main():
    result_file = open('fre_result.txt', 'w', encoding='utf-8')
    char_dict = dict()
    files = read_word_freq_files()
    single_character_set = get_single_character_set()
    for char in open('./char.txt', 'r').read():
        if char in single_character_set:
            continue
    # for char in single_character_set:
        char_dict[char] = []
        for file in files:
            cnt = 0
            temp = []
            for line in file:
                word, freq = line.split('\t')
                if word.startswith(char):
                    temp.append((word, freq))
                    cnt += 1
                    if cnt == 10:
                        break
            temp.sort(key=lambda x: int(x[1]), reverse=True)
            char_dict[char].append(temp)
    for char in char_dict:
        if len(char_dict[char]) == 0:
            continue
        result_file.write(char + '\n')
        for res in char_dict[char]:
            for word, freq in res:
                result_file.write(word + '\t' + freq + '\n')
            result_file.write('\n')


if __name__ == '__main__':
    main()
