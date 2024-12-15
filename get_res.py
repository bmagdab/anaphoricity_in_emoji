import pandas as pd
from io import StringIO
import re

polish = True
if polish: # different files are required for the polish version of the experiment and it also has one result to be removed
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

# below I separate the whole results file from ibex so that I have each portion of data sent to the server separately
save = False
split = text.split('# Results on')
split = split[1:]
split_list = []
for elt in split: # I don't want the test runs to be included, so we wrote down when we started receiving real results from participants
    whole_elt = '# Results on' + elt
    if polish and (re.match(remove1, whole_elt) or re.match(remove2, whole_elt)):
        continue # in the Polish version of the experiment there was one run to be discarded after we shared the experiment
    if re.match(start_line, whole_elt):
        save = True
    if save:
        split_list.append(whole_elt.split('\n'))

# here I check which results we received contain the bio information about the participants, we only want those included (because these are completed)
# also here I start writing down only the results, without the ibex comments
save_res = False
save_bio = False
results = []
bio_inf = []
for elt in split_list:
    results_temp = []
    bio_inf_temp = []
    for line in elt:
        if line.startswith('#'): # ibex comments start with #, so I don't save those lines in my list
            save_res = False
            save_bio = False
        if save_res and not re.search('practice', line): # I don't want to save answers from the practice questions
            results_temp.append(line)
        elif save_bio and re.search('DropDown', line): # there were some additional lines next to the bio information, I don't want this
            bio_inf_temp.append(line)
        if line == '# 11. Time taken to answer.': # participant answers start always after this line
            save_res = True
        elif line == '# 13. Comments.': # bio information starts after this line
            save_bio = True
    if bio_inf_temp: # if bio information was found, the participant filled out the survey completely and I want to save this
        results += results_temp
        bio_inf += bio_inf_temp

res_str = """time_rec,hash,controller,item_no,el_no,type,group,question,answer,correct,time_ans\n"""
bio_str = """time_rec,hash,Gender,Age,Use,Rec,iOS\n"""
for line in results: # I write the participant answers into a string that will be turned into a dataframe
    res_str += line + '\n'

# I need to save the bio data in a slightly different format, so that it works with the R code
# I want all bio information about a participant in one line
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

# I turn the strings I just created into a dataframe
results = pd.read_csv(StringIO(res_str), sep=',')
bio_inf = pd.read_csv(StringIO(bio_str), sep=',')

# below I read the names that appear in subject positions in our survey, to mark them in the dataframe as just "subject"
subjects = []
with open(subjects_file, mode='r', encoding='utf-8') as file:
    lines = file.readlines()
    lines = list(set(lines))
    for line in lines:
        subjects.append(line[1:-3])
print(len(subjects))

# now same for names that appear in object position
objects = []
with open(objects_file, mode='r', encoding='utf-8') as file:
    lines = file.readlines()
    lines = list(set(lines))
    for line in lines:
        objects.append(line[1:-3])
print(len(objects))

# I wanted to make sure that names don't repeat, because if they do, recoding values in the dataframe would be more complicated
for s in subjects:
    for o in objects:
        if s == o:
            print('names repeat between subjects and objects')

# print(results['answer'])

# I recode the values
for i in range(len(results)):
    if results.iloc[i]['answer'][:-1] in subjects:
        results.at[i, 'answer'] = 'Subject'
    elif results.iloc[i]['answer'][:-1] in objects:
        results.at[i, 'answer'] = 'Object'
    elif results.iloc[i]['answer'] in ['The sender of the message.', 'Nadawcy wiadomości.']:
        results.at[i, 'answer'] = 'Sender'

# print(results['answer'])

# I create a new column to mark the ID of participant, because the ID given by ibex actually doesn't identify participants uniquely
# fortunately, the time when we received the response does identify uniquely
# to make sure it works, I use both of those in the new ID column
results['ID'] = results['hash'] + results['time_rec'].astype(str)
bio_inf['ID'] = bio_inf['hash'] + bio_inf['time_rec'].astype(str)

# I rename the columns to have them fit the ones in the R script
results.rename(columns={'type': 'Condition', 'item_no': 'Item_Num', 'answer': 'Answer'}, inplace=True)

# I create the .csv files with the results
if polish:
    results.to_csv('Emoji_Pol.csv', index=False, columns=['ID', 'Condition', 'Item_Num', 'Answer'])
    bio_inf.to_csv('Emoji_Pol_Bio.csv', index=False, columns=['ID', 'Rec', 'Use', 'iOS', 'Age', 'Gender'])
else:
    results.to_csv('Emoji_Eng.csv', index=False, columns=['ID', 'Condition', 'Item_Num', 'Answer'])
    bio_inf.to_csv('Emoji_Eng_Bio.csv', index=False, columns=['ID', 'Rec', 'Use', 'iOS', 'Age', 'Gender'])
