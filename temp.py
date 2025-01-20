#! /usr/bin/env python

def main():
    file = open('temp.log', 'w', encoding='utf-8')
    dict_file = open('wubi.dict.yaml', 'r', encoding='utf-8')
    code_dict = dict()
    for line in dict_file.readlines():
        try:
            word, code, _, _ = line.split('\t')
        except:
            continue
        if code not in code_dict:
            code_dict[code] = []
        code_dict[code].append(word)
    lines = set()
    for ch1 in '\0abcdefghijklmnopqrstuvwxy':
        for ch2 in '\0abcdefghijklmnopqrstuvwxy':
            for ch3 in '\0abcdefghijklmnopqrstuvwxy':
                for ch4 in '\0abcdefghijklmnopqrstuvwxy':
                    code = ''
                    if ch1 != '\0':
                        code += ch1
                    if ch2 != '\0':
                        code += ch2
                    if ch3 != '\0':
                        code += ch3
                    if ch4 != '\0':
                        code += ch4
                    if len(code) != 3:
                        continue
                    if code not in code_dict:
                        lines.add(code)
    lines = list(lines)
    # sort by len then by code
    lines.sort(key=lambda x: (len(x), x))
    for line in lines:
        new_line = line
        for code in code_dict:
            if code.startswith(line):
                for word in code_dict[code]:
                    new_line += '\t' + word
        if len(new_line) > 3:
            file.write(new_line + '\n')
    file.close()
    dict_file.close()


main()
