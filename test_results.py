## This script is for comparing the model's output with Prof.Borland's results
## Before running the script, add all the file names as a list of strings to the 'files_to_compare' list

#Libraries 
import csv 
#import matplotlib.pyplot as plt
import statistics as stats

#User Defined Variables
files_to_compare = ["Control Test-50.csv", "Control Test-30.csv", "Control Test-10.csv", "Control Test-100-1.csv", 
"Control Test-100-2.csv", "Control Test-100-3.csv", "Control Test-100-4.csv", "Control Test-100-5.csv", "Control Test-100-6.csv",
"Control Test-100-7.csv", "Control Test-100-8.csv", "Control Test-100-9.csv"]

#Header for Summary CSV
summary = [['Filename', 'ID Accuracy', 'Latency']] 

#Iterate through every file
for file in files_to_compare:

	#Define csv file locations
	generated_file = "UpdatedInterface/data/"  + file
	actual_file = "Control Test Failures/" + file


	#Initialize lists to hold timestamps and identified sounds 
	generated_timestamp = []
	generated_sound = []
	actual_timestamp = []
	actual_sound = []

	#Populated lists (ignoring delays)
	header = True
	with open(generated_file,  mode = 'r') as csvfile:
		reader = csv.reader(csvfile)
		for row in reader:
			if header:
				header = False
			else:
				if row[2] != 'Delay':
					generated_timestamp.append(row[1])
					generated_sound.append(row[2])

	with open(actual_file,  mode = 'r') as csvfile:
		reader = csv.reader(csvfile)
		for row in reader:
			curr_row = row[0].split()
			if curr_row[2] != "Delay":
				actual_timestamp.append(curr_row[1])
				actual_sound.append(curr_row[2].strip(".wav"))

	#Determine id accuracy & latency (ms)
	
	#Declare variables
	correct = 0
	missed = 0
	added = 0
	incorrect = 0
	latency = []
	i = 0
	j = 0
	generated_len = len(generated_sound)
	actual_len = len(actual_sound)

	#Iterate using actual list
	while i < actual_len:
		
		#if our list is done, the rest are misses
		if j == generated_len:
			i += 1
			missed += 1
			continue

		#the sound was correctly identified
		if actual_sound[i] == generated_sound[j]:
			correct += 1
			#latency (ms) calculation for when a row matches up 
			latency.append(round(1000*abs((float(actual_timestamp[i]) - float(generated_timestamp[j]))), 1))

		#Need to identify between missed, extra added and incorrect so we know how to move indexes for comparisons
		else:
			if ((i < actual_len - 1 and actual_sound[i+1] == generated_sound[j])):
				missed += 1
				j -= 1

			elif (( j < generated_len - 1 and actual_sound[i] == generated_sound[j + 1])):
				added += 1
				i -= 1
			#this logic only checks for misses and additions that happen indivudally, if there are sucessive misses, the 
			#algorithm will classify them all as incorrect and be out of phase for the remainder of the comparison.
			else:
				incorrect += 1
				#latency (ms) calculation, can maybe remove from here?
				latency.append(round(1000*abs((float(actual_timestamp[i]) - float(generated_timestamp[j]))), 1))

		i += 1 
		j += 1 

	#Calculate identification accuracy and average latency for this file
	accuracy = round((correct/(correct + missed + added + incorrect)) * 100, 2)
	average_latency =  round(stats.mean(latency), 2)

	#Add this file's important info to overall summary csv
	summary.append([file, accuracy, average_latency])
	print(summary[-1])

	# Output to file specific CSV
	with open ('testing results/' + file, 'w', newline = '') as csvfile:
		csvwriter = csv.writer(csvfile)
		csvwriter. writerow(['Correct', 'Missed', 'Added', 'Incorrect', 'ID Accuracy', ' ', 'Variance of Latency', 'Mean of Latency'])
		csvwriter.writerow([correct, missed, added, incorrect, accuracy, ' ', stats.variance(latency), average_latency])
		csvwriter.writerow([''])
		csvwriter.writerow(['Latency Numbers'])
		for num in latency:
			csvwriter.writerow([num])
	
	##Save latency plot, could maybe make a case for removing outliers for xtra marks
	#Will put all latency lines onto one plot rn
	#plt.scatter(latency)
	#plt.savefig('testing results/' + file + ' latency_figure.png')
	

#Output to summary CSV
with open ('testing results/' + 'summary.csv', 'w', newline = '') as csvfile:
		csvwriter = csv.writer(csvfile)
		for row in summary:
			csvwriter.writerow(row)