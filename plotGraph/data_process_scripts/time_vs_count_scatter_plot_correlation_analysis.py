import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os

# Load the data
file_path = '../data/hold_wait_time_contention_analysis_per_lock.csv'
df = pd.read_csv(file_path)

# Create the directory if it does not exist
output_dir = '/home/wjxt/gxr/testMongoDB/plotGraph/outputGraph'
os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, 'hold_wait_time_count_relationship.png')

# Plotting scatter plots
plt.figure(figsize=(14, 6))

# Hold Time vs. Count
plt.subplot(1, 3, 1)
plt.scatter(df['Count'], df['Hold Time (us)'], alpha=0.75)
plt.title('Hold Time vs. Count')
plt.xlabel('Count')
plt.ylabel('Hold Time (us)')

# Wait Time vs. Count
plt.subplot(1, 3, 2)
plt.scatter(df['Count'], df['Wait Time (us)'], alpha=0.75)
plt.title('Wait Time vs. Count')
plt.xlabel('Count')
plt.ylabel('Wait Time (us)')

plt.subplot(1, 3, 3)
plt.scatter(df['Hold Time (us)'], df['Wait Time (us)'], alpha=0.75)
plt.title('Hold Time (us) vs Wait Time')
plt.xlabel('Hold Time (us)')
plt.ylabel('Wait Time (us)')

plt.tight_layout()
plt.savefig(output_path)
plt.show()

# Calculating correlation coefficients
corr_hold_count = np.corrcoef(df['Count'], df['Hold Time (us)'])[0, 1]
corr_wait_count = np.corrcoef(df['Count'], df['Wait Time (us)'])[0, 1]

print(f"Correlation between Hold Time and Count: {corr_hold_count}")
print(f"Correlation between Wait Time and Count: {corr_wait_count}")
