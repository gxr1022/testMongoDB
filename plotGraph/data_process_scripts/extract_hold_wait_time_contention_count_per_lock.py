import re
import csv

# Define the input and output file paths
input_file_path = '../data/hold_wait_time_per_lock.txt'
output_file_path = '../data/hold_wait_time_contention_analysis_per_lock.csv'

# Regular expressions to match the data
lock_pattern = re.compile(r'mutex ([0-9a-f]+) \(\#?\d*\) ::: wait time ([\d.]+)us ::: hold time ([\d.]+)us ::: enter count (\d+)')
count_pattern = re.compile(r'Mutex ([0-9a-f]+) \(\#?\d*\) Count=(\d+)')

# Initialize a dictionary to store the extracted data
lock_data = {}

# Read the input file and extract data
with open(input_file_path, 'r') as file:
    content = file.read()
    
    # Extract lock, wait time, hold time, and enter count
    for match in lock_pattern.findall(content):
        address, wait_time, hold_time, enter_count = match
        lock_data[address] = {
            'wait_time': float(wait_time),
            'hold_time': float(hold_time),
            'enter_count': int(enter_count),
            'count': 0  # Initialize count to 0
        }
    
    # Extract count information
    for match in count_pattern.findall(content):
        address, count = match
        if address in lock_data:
            lock_data[address]['count'] = int(count)

# Convert the dictionary to a list of lists for sorting and writing to CSV
lock_list = [
    [address, data['wait_time'], data['hold_time'], data['enter_count'], data['count']]
    for address, data in lock_data.items()
]

# Sort the data by count in descending order
sorted_lock_list = sorted(lock_list, key=lambda x: x[4], reverse=True)

# Write the sorted data to a CSV file
with open(output_file_path, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(['Lock Address', 'Wait Time (us)', 'Hold Time (us)', 'Enter Count', 'Count'])
    csvwriter.writerows(sorted_lock_list)

print(f'Data has been written to {output_file_path}')
