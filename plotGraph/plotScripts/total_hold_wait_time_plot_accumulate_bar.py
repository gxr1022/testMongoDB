# '../data/grouped_lock_contention_data.xlsx'
# '../outputGraph/total_hold_time_per_group_by_thread_seconds.png'

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Load the actual dataframe
file_path = '../data/grouped_lock_contention_data.xlsx'  # 替换为你的文件路径
df = pd.read_excel(file_path)

# Convert hold times from microseconds to seconds
df['Hold Time (s)'] = df['Hold Time (us)'] / 1_000_000

df['Thread Number'] = df.groupby('Group').cumcount() + 1

df_grouped = df.groupby(['Group', 'Thread Number'])['Hold Time (s)'].sum().unstack().fillna(0)

# Prepare the data for stacked bar plot
# df_grouped = df.groupby(['Group', 'Thread'])['Hold Time (s)'].sum().unstack().fillna(0)



# Sort the groups by their numeric value
sorted_groups = sorted(df_grouped.index, key=lambda x: int(''.join(filter(str.isdigit, x))))
df_grouped = df_grouped.loc[sorted_groups]

print(df_grouped)

# Plotting the data
fig, ax = plt.subplots(figsize=(14, 8))

# Generate a colormap
num_shades = df_grouped.shape[1]
# blues = plt.cm.Blues(np.linspace(0.3, 1, num_shades))
# num_shades = df_grouped.shape[1]
blues = plt.cm.viridis(np.linspace(0.1, 1, num_shades))  # Using viridis colormap


num_threads = df['Thread'].nunique()  # Number of unique threads

# Plot stacked bar chart
bottom = None
for i, thread in enumerate(df_grouped.columns):
    ax.bar(df_grouped.index, df_grouped[thread], label=f'Thread {thread}', bottom=bottom, color=blues[i % len(blues)])
    if bottom is None:
        bottom = df_grouped[thread]
    else:
        bottom += df_grouped[thread]


size=13
plt.xlabel('Group',fontsize=size)
plt.ylabel('Total Hold Time (s)',fontsize=size)
plt.xticks(fontsize=size)
plt.yticks(fontsize=size)
plt.title('Total Hold Time per Group by Thread')
plt.legend(title='Thread', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.subplots_adjust(left=0.1, right=0.85, top=0.9, bottom=0.25)
# Save the plot to a specific path
output_path = '../outputGraph/total_hold_time_per_group_by_thread_seconds.png'  # 替换为保存路径
plt.savefig(output_path)

plt.show()
