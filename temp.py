#! /usr/bin/env python

def main():
    file = open('wubi.extended.dict.yaml', 'a+', encoding='utf-8')
    dict_file = open('wubi.dict.yaml', 'r', encoding='utf-8')
    code_dict = dict()
    for line in dict_file.readlines():
        if line.find('\t') == -1:
            continue
        try:
            word, code, _, _ = line.split('\t')
        except:
            continue
        if code not in code_dict:
            code_dict[code] = []
        code_dict[code].append(word)
    lines = []
    for ch1 in 'abcdefghijklmnopqrstuvwxy':
        for ch2 in 'abcdefghijklmnopqrstuvwxy':
            code = ch1 + ch2
            if code not in code_dict:
                lines.append(f'word\t{code}\t0\n')
                lines.append(f'word\t{code}\t0\n')
            elif len(code_dict[code]) == 1:
                lines.append(f'word\t{code}\t20\n')
                lines.append(f'word\t{code}\t10\n')
    file.writelines(lines)
    file.close()

main()
