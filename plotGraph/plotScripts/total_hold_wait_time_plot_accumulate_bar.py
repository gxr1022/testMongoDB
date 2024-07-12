import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Load the actual dataframe
file_path = '../data/extracted_thread_data_grouped1.xlsx'  # 替换为你的文件路径
df = pd.read_excel(file_path)

# Convert hold times from microseconds to seconds
df['Hold Time (s)'] = df['Hold Time (us)'] / 1_000_000
df['Wait Time (s)'] = df['Wait Time (us)'] / 1_000_000

df['Thread Number'] = df.groupby('Group').cumcount() + 1

df_grouped = df.groupby(['Group', 'Thread Number'])['Hold Time (s)'].sum().unstack().fillna(0)
df_grouped_wait = df.groupby(['Group', 'Thread Number'])['Wait Time (s)'].sum().unstack().fillna(0)

# Sort the groups by their numeric value
sorted_groups = sorted(df_grouped.index, key=lambda x: int(''.join(filter(str.isdigit, x))))
df_grouped = df_grouped.loc[sorted_groups]
df_grouped_wait = df_grouped_wait.loc[sorted_groups]

thread_counts = [1,4,8,12,16,20,24,28,32]
print(thread_counts)

# Plotting the data
fig, ax = plt.subplots(figsize=(14, 8))

# Generate a colormap
num_shades = df_grouped.shape[1]
viridis = plt.cm.viridis(np.linspace(0.1, 1, num_shades))  # Using viridis colormap
plasma = plt.cm.plasma(np.linspace(0.1, 1, num_shades))    # Using plasma colormap

# num_threads = df['Thread'].nunique()  # Number of unique threads

bar_width = 0.35  # Width of the bars
indices = np.arange(len(df_grouped))

# Plot hold times
bottom_hold = np.zeros(len(df_grouped))
for i, thread in enumerate(df_grouped.columns):
    ax.bar(indices - bar_width/2, df_grouped[thread], bar_width, label=f'Hold Time Thread {thread}', bottom=bottom_hold, color=viridis[i % len(viridis)])
    bottom_hold += df_grouped[thread]

# Plot wait times
bottom_wait = np.zeros(len(df_grouped_wait))
for i, thread in enumerate(df_grouped_wait.columns):
    ax.bar(indices + bar_width/2, df_grouped_wait[thread], bar_width, label=f'Wait Time Thread {thread}', bottom=bottom_wait, color=plasma[i % len(plasma)])
    bottom_wait += df_grouped_wait[thread]

# Customizing the plot
size = 13
plt.xlabel('Thread Number', fontsize=size)
plt.ylabel('Total Time (s)', fontsize=size)
plt.xticks(ticks=indices, labels=thread_counts, fontsize=size)
plt.yticks(fontsize=size)
plt.title('Total Hold and Wait Time per Group by Thread')
# plt.legend(title='Thread', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.legend(title='Thread', bbox_to_anchor=(1.05, 1), loc='upper left', ncol=2)
plt.tight_layout()
plt.subplots_adjust(left=0.1, right=0.65, top=0.9, bottom=0.15)

for spine in ax.spines.values():
    spine.set_linewidth(1.5)

# Save the plot to a specific path
output_path = '../outputGraph/total_hold_time_per_group_by_thread_seconds1.png'  # 替换为保存路径
plt.savefig(output_path)

plt.show()
