#! /usr/bin/env python

def main():
    file = open('./wubi.dict.yaml', 'r+', encoding='utf-8')
    log_file = open('./redundant.txt', 'w', encoding='utf-8')
    code_dict = dict()
    character_dict = dict()
    redundant_lines = set()
    lines = file.readlines()
    for line in lines:
        words = line.split('\t')
        if len(words) < 4:
            continue
        character = words[0]
        code = words[1]
        if len(character) != 1:
            continue
        if code not in code_dict:
            code_dict[code] = character
            character_dict[character] = code
    for line in lines:
        words = line.split('\t')
        if len(words) < 4:
            continue
        character = words[0]
        code = words[1]
        if len(character) != 1:
            continue
        if character in character_dict and code != character_dict[character]:
            log_file.write(line)
            redundant_lines.add(line)
    new_lines = []
    for line in lines:
        if line not in redundant_lines:
            new_lines.append(line)
    file.seek(0)
    file.truncate()
    file.writelines(new_lines)
    file.close()

main()
