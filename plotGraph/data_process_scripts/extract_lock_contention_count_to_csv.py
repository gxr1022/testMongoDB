import re
import csv

# Define the input and output file paths
input_file_path = '../data/lock_contention_analysis.txt'
output_file_path = '../data/lock_counts.csv'

# Regular expression to match the Mutex entries
mutex_pattern = re.compile(r'Mutex ([0-9a-f]+) \(\#?\d*\) Count=(\d+)')

# Initialize a list to store the extracted data
extracted_data = []

# Read the input file and extract data
with open(input_file_path, 'r') as file:
    content = file.read()
    matches = mutex_pattern.findall(content)
    for match in matches:
        address, count = match
        extracted_data.append([address, int(count)])

# Sort the extracted data by the count in descending order
sorted_data = sorted(extracted_data, key=lambda x: x[1], reverse=True)

# Write the sorted data to a CSV file
with open(output_file_path, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(['Lock Address', 'Count'])
    csvwriter.writerows(sorted_data)

print(f'Data has been written to {output_file_path}')
