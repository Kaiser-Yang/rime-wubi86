#! /usr/bin/env python

def main():
    file = open('./wubi.dict.yaml', 'r+', encoding='utf-8')
    log_file = open('./unfinished.txt', 'w', encoding='utf-8')
    code_set = set()
    unfinished_lines = set()
    lines = file.readlines()
    for line in lines:
        words = line.split('\t')
        if len(words) < 4:
            continue
        character = words[0]
        code = words[1]
        # [:-1] to remove the '\n' at the end of the line
        stem = words[3][:-1]
        if len(character) != 1:
            continue
        if code in code_set and code != stem:
            unfinished_lines.add(line)
        code_set.add(code)
    for line in unfinished_lines:
        log_file.write(line)
    new_lines = []
    for line in lines:
        if line not in unfinished_lines:
            new_lines.append(line)
    file.seek(0)
    file.truncate()
    file.writelines(new_lines)
    file.close()

main()
