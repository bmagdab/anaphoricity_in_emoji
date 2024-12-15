import pandas as pd
from io import StringIO
import re

polish = True
if polish:
    source = 'pol_raw.txt'
    subjects_file = 'pol_subjects.txt'
    objects_file = 'pol_objects.txt'
    start_line = '# Results on Sunday December 08 2024 11:42:08 UTC.'
    remove1 = '# Results on Sunday December 08 2024 19:55:12 UTC'
    remove2 = '# Results on Sunday December 08 2024 19:56:01 UTC'
else:
    source = 'eng_raw.txt'
    subjects_file = 'eng_subjects.txt'
    objects_file = 'eng_objects.txt'
    start_line = '# Results on Sunday December 08 2024 14:28:21 UTC.'

with open(source, mode='r', encoding='utf-8') as file:
    text = file.read()

save = False
split = text.split('# Results on')
split = split[1:]
split_list = []
for elt in split:
    whole_elt = '# Results on' + elt
    if polish and (re.match(remove1, whole_elt) or re.match(remove2, whole_elt)):
        continue
    if re.match(start_line, whole_elt):
        save = True
    if save:
        split_list.append(whole_elt.split('\n'))

save_res = False
save_bio = False
results = []
bio_inf = []
for elt in split_list:
    results_temp = []
    bio_inf_temp = []
    for line in elt:
        if line.startswith('#'):
            save_res = False
            save_bio = False
        if save_res and not re.search('practice', line):
            results_temp.append(line)
        elif save_bio and re.search('DropDown', line):
            bio_inf_temp.append(line)
        if line == '# 11. Time taken to answer.':
            save_res = True
        elif line == '# 13. Comments.':
            save_bio = True
    if bio_inf_temp:
        results += results_temp
        bio_inf += bio_inf_temp

res_str = """time_rec,hash,controller,item_no,el_no,type,group,question,answer,correct,time_ans\n"""
bio_str = """time_rec,hash,Gender,Age,Use,Rec,iOS\n"""
for line in results:
    res_str += line + '\n'
time_rec = ''
newline = ''
for line in bio_inf:
    line = line.split(',')
    if line[0] != time_rec:
        if newline:
            bio_str += newline + '\n'
        time_rec = line[0]
        newline = f'{line[0]},{line[1]}'
    newline += ',' + line[10]
bio_str += newline + '\n'

results = pd.read_csv(StringIO(res_str), sep=',')
bio_inf = pd.read_csv(StringIO(bio_str), sep=',')

subjects = []
with open(subjects_file, mode='r', encoding='utf-8') as file:
    lines = file.readlines()
    lines = list(set(lines))
    for line in lines:
        subjects.append(line[1:-3])
print(len(subjects))

objects = []
with open(objects_file, mode='r', encoding='utf-8') as file:
    lines = file.readlines()
    lines = list(set(lines))
    for line in lines:
        objects.append(line[1:-3])
print(len(objects))

for s in subjects:
    for o in objects:
        if s == o:
            print('names repeat between subjects and objects')

# print(results['answer'])

for i in range(len(results)):
    if results.iloc[i]['answer'][:-1] in subjects:
        results.at[i, 'answer'] = 'Subject'
    elif results.iloc[i]['answer'][:-1] in objects:
        results.at[i, 'answer'] = 'Object'
    elif results.iloc[i]['answer'] in ['The sender of the message.', 'Nadawcy wiadomości.']:
        results.at[i, 'answer'] = 'Sender'

# print(results['answer'])

results['ID'] = results['hash'] + results['time_rec'].astype(str)
bio_inf['ID'] = bio_inf['hash'] + bio_inf['time_rec'].astype(str)

results.rename(columns={'type': 'Condition', 'item_no': 'Item_Num', 'answer': 'Answer'}, inplace=True)

if polish:
    results.to_csv('Emoji_Pol.csv', index=False, columns=['ID', 'Condition', 'Item_Num', 'Answer'])
    bio_inf.to_csv('Emoji_Pol_Bio.csv', index=False, columns=['ID', 'Rec', 'Use', 'iOS', 'Age', 'Gender'])
else:
    results.to_csv('Emoji_Eng.csv', index=False, columns=['ID', 'Condition', 'Item_Num', 'Answer'])
    bio_inf.to_csv('Emoji_Eng_Bio.csv', index=False, columns=['ID', 'Rec', 'Use', 'iOS', 'Age', 'Gender'])
