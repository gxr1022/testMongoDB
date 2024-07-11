import pandas as pd
import matplotlib.pyplot as plt

# Load the actual dataframe
file_path = '../data/grouped_lock_contention_data.xlsx'
df = pd.read_excel(file_path)

# Calculate the mean hold time and wait time for each group
hold_time_type = 'Hold Time (us)'
wait_time_type = 'Wait Time (us)'

# Convert times from microseconds to seconds
df['Hold Time (s)'] = df[hold_time_type] / 1_000_000
df['Wait Time (s)'] = df[wait_time_type] / 1_000_000



# Group by 'Group' and calculate the mean
grouped_df = df.groupby('Group')[['Hold Time (s)', 'Wait Time (s)']].mean().reset_index()

# Sort the dataframe by Group ID
grouped_df['Group'] = pd.Categorical(grouped_df['Group'], categories=sorted(grouped_df['Group'], key=lambda x: int(''.join(filter(str.isdigit, x)))), ordered=True)
grouped_df = grouped_df.sort_values('Group')

print(grouped_df)

size=11

# Plotting the data
plt.figure(figsize=(14, 8))

# Setting the positions and width for the bars
bar_width = 0.35
index = range(len(grouped_df))

# Plotting Hold Time
plt.bar(index, grouped_df['Hold Time (s)'], bar_width, label='Hold Time (s)', color='#80AF81', edgecolor='black')

# Plotting Wait Time next to Hold Time
plt.bar([i + bar_width for i in index], grouped_df['Wait Time (s)'], bar_width, label='Wait Time (s)', color='#2C7865', edgecolor='black')

plt.xlabel('Group',fontsize=size+3)
plt.ylabel('Time (s)',fontsize=size+3)
plt.title('Average Hold Time and Wait Time per Group')
plt.xticks([i + bar_width / 2 for i in index], grouped_df['Group'], rotation=45,fontsize=size)
plt.yticks(fontsize=size+3)
plt.legend(ncol=2,fontsize=size+2)
# plt.grid(axis='y')

plt.tight_layout()

output_path = './outputGraph/average_hold_wait_time_per_group_max_32_threads.png'
plt.savefig(output_path)

plt.show()
