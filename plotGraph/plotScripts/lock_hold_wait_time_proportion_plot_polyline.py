import pandas as pd
import matplotlib.pyplot as plt

# Load the actual dataframe
file_path = '../data/extracted_thread_data_grouped1.xlsx'
df = pd.read_excel(file_path)

# Calculate the mean hold time and wait time for each group
hold_time_type = 'Hold Time (us)'
wait_time_type = 'Wait Time (us)'

# Convert times from microseconds to seconds
df['Hold Time Proportion'] = df[hold_time_type] / 1_000_000 / 300
df['Wait Time Proportion'] = df[wait_time_type] / 1_000_000 / 300

# Group by 'Group' and calculate the mean
grouped_df = df.groupby('Group')[['Hold Time Proportion', 'Wait Time Proportion']].mean().reset_index()

# Ensure 'Group' column is sorted properly
group_id = [1, 2, 3, 4, 5, 6, 7, 8, 9]
grouped_df['Group'] = pd.Categorical(grouped_df['Group'], categories=[f'Group{i}' for i in group_id], ordered=True)
grouped_df = grouped_df.sort_values('Group')

# Define the thread counts for x-axis
thread_counts = [1, 4, 8, 12, 16, 20, 24, 28, 32]

print(grouped_df)

size = 11

# Plotting the data
plt.figure(figsize=(14, 8))

# Setting the positions and width for the bars
bar_width = 0.35
index = range(len(grouped_df))

plt.plot(index, grouped_df['Hold Time Proportion'], marker='o', label='Hold Time Proportion', color='#80AF81', linewidth=2)
plt.plot(index, grouped_df['Wait Time Proportion'], marker='x', label='Wait Time Proportion', color='#2C7865', linewidth=2)

plt.xlabel('Thread Number', fontsize=size + 3)
plt.ylabel('Time (s)', fontsize=size + 3)
plt.title('Lock Hold Time and Wait Time Proportion per Thread Group', fontsize=size + 5)

plt.xticks([i for i in index], thread_counts, fontsize=size + 3)
plt.yticks(fontsize=size + 3)
plt.legend(ncol=2, fontsize=size + 2)

plt.tight_layout()

output_path = '../outputGraph/lock_hold_wait_time_proportion_polyline.png'
plt.savefig(output_path)

plt.show()
