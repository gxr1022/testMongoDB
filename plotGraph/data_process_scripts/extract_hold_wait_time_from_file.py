import re
import pandas as pd

# 打开文件并读取内容
with open('../data/lock_contention_test1.txt', 'r', encoding='utf-8', errors='ignore') as file:
    lines = file.readlines()

# 初始化存储结果的列表
threads_data = []

# 定义正则表达式来匹配需要的信息
pattern = re.compile(r'Thread (\d+) ::: total wait time ([\d.]+)us ::: total hold time ([\d.]+)us')

# 遍历每一行并提取信息
for line in lines:
    match = pattern.search(line)
    if match:
        thread_id = int(match.group(1))
        wait_time = float(match.group(2))
        hold_time = float(match.group(3))
        threads_data.append((thread_id, wait_time, hold_time))

# 将数据按线程ID排序
threads_data.sort()

# 初始化分组信息
grouped_data = []
current_group = 1

# 遍历数据，进行分组
for i in range(len(threads_data)):
    if i == 0:
        grouped_data.append((f"Group{current_group}", *threads_data[i]))
    else:
        # 检查当前线程ID与前一个线程ID是否连续
        if threads_data[i][0] != threads_data[i - 1][0] + 1:
            current_group += 1
        grouped_data.append((f"Group{current_group}", *threads_data[i]))

# 创建DataFrame
df = pd.DataFrame(grouped_data, columns=['Group', 'Thread ID', 'Wait Time (us)', 'Hold Time (us)'])

# 保存到Excel文件
output_path = '../data/extracted_thread_data_grouped1.xlsx'
df.to_excel(output_path, index=False)

print(f"Data has been successfully written to {output_path}")
