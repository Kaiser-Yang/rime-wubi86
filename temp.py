#! /usr/bin/env python

def main():
    file = open('./wubi.dict.yaml', 'r+', encoding='utf-8')
    log_file = open('./removed.txt', 'w', encoding='utf-8')
    code_dict = dict()
    character_dict = dict()
    lines = file.readlines()
    for line in lines:
        words = line.split('\t')
        if len(words) < 2:
            continue
        character = words[0]
        code = words[1]
        if len(character) != 1:
            continue
        if code in code_dict:
            continue
        code_dict[code] = character
        if character in character_dict:
            character_dict[character].append(code)
        else:
            character_dict[character] = [code]
    for character in character_dict:
        character_dict[character].sort(key=lambda x: len(x))
    new_lines = []
    for line in lines:
        words = line.split('\t')
        if len(words) < 2:
            new_lines.append(line)
            continue
        character = words[0]
        code = words[1]
        if code not in code_dict or code_dict[code] != character or character not in character_dict or character_dict[character][0] == code:
            new_lines.append(line)
        else:
            log_file.write('removed: ' + line + 'reason : ' + character_dict[character][0] + '\n')
    file.seek(0)
    file.truncate()
    file.writelines(new_lines)
    file.close()

main()
