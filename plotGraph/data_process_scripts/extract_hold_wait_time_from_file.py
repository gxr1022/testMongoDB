import re

with open('../data/lock_contention_test.txt', 'r',encoding='utf-8', errors='ignore') as file:
    lines = file.readlines()


threads_data = []


pattern = re.compile(r'Thread (\d+) ::: total wait time ([\d.]+)us ::: total hold time ([\d.]+)us')

for line in lines:
    match = pattern.search(line)
    if match:
        thread_id = int(match.group(1))
        wait_time = float(match.group(2))
        hold_time = float(match.group(3))
        threads_data.append((thread_id, wait_time, hold_time))


for thread_data in threads_data:
    print(f'Thread ID: {thread_data[0]}, Wait Time: {thread_data[1]}us, Hold Time: {thread_data[2]}us')
