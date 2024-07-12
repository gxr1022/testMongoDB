import pandas as pd
import matplotlib.pyplot as plt

# Load the actual dataframe
file_path = '../data/extracted_thread_data_grouped1.xlsx'
df = pd.read_excel(file_path)

# Calculate the mean hold time and wait time for each group
hold_time_type = 'Hold Time (us)'
wait_time_type = 'Wait Time (us)'

# Convert times from microseconds to seconds
df['Hold Time (s)'] = df[hold_time_type] / 1_000_000
df['Wait Time (s)'] = df[wait_time_type] / 1_000_000

# Group by 'Group' and calculate the mean
grouped_df = df.groupby('Group')[['Hold Time (s)', 'Wait Time (s)']].mean().reset_index()


thread_counts = [1, 4, 8, 12, 16, 20, 24, 28, 32]
group_id=[1, 2, 3, 4, 5, 6, 7, 8, 9]
grouped_df['Group'] = pd.Categorical(grouped_df['Group'], categories=[f'Group{i}' for i in group_id], ordered=True)
grouped_df = grouped_df.sort_values('Group')
print(grouped_df)

size = 11

# Plotting the data
plt.figure(figsize=(14, 8))

# Setting the positions and width for the bars
bar_width = 0.35
index = range(len(grouped_df))

# Plotting Hold Time
plt.bar(index, grouped_df['Hold Time (s)'], bar_width, label='Hold Time (s)', color='#80AF81', edgecolor='black')

# Plotting Wait Time next to Hold Time
plt.bar([i + bar_width for i in index], grouped_df['Wait Time (s)'], bar_width, label='Wait Time (s)', color='#2C7865', edgecolor='black')

plt.xlabel('Thread Number', fontsize=size + 3)
plt.ylabel('Time (s)', fontsize=size + 3)
plt.title('Average Hold Time and Wait Time per Group')

# Set the x-ticks to the thread counts
plt.xticks([i + bar_width / 2 for i in index], thread_counts, fontsize=size+3)
plt.yticks(fontsize=size + 3)
plt.legend(ncol=2, fontsize=size + 2)

plt.tight_layout()

output_path = '../outputGraph/average_hold_wait_time_per_group_max_32_threads1.png'
plt.savefig(output_path)

plt.show()
