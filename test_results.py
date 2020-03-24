## This script is for comparing the model's output with Prof.Borland's results
## Before running the script, add all the file names as a list of strings to the 'files_to_compare' list

#Libraries 
import csv 
import matplotlib.pyplot as plt
import statistics as stats

#User Defined Variables
files_to_compare = ["Control Test-50.csv", "Control Test-30.csv", "Control Test-10.csv"]

#Variables
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
	min_len = min(len(generated_sound), len(actual_sound))

	#Iterate using smaller list which usually should be generated list
	while i < min_len:
		
		if generated_sound[i] == actual_sound[j]:
			correct += 1
			#latency (ms) calculation for when a row matches up 
			latency.append(round(1000*abs(float(generated_timestamp[i]) - float(actual_timestamp[j])), 1))

		#Need to identify between missed, extra added and incorrect so know how to move indexes for comparisons
		else:
			if i == len(generated_sound) or j == len(actual_sound):
				incorrect += 1
			#its unlikely that we will see errors clustered together so assuming error is isolated 
			# and other rows around should be correct
			elif generated_sound[i] == actual_sound[j+1] and generated_sound[i + 1] == actual_sound[j+2]:
				missed += 1
				i -= 1
			elif generated_sound[i + 1] == actual_sound[j] and generated_sound[i + 2] == actual_sound[j + 1]:
				added += 1
				i += 1 
			else:
				incorrect += 1

		i += 1 
		j += 1 

	#Calculate identification accuracy and average latency for this file
	accuracy = correct/(correct +missed +added + incorrect)
	average_latency =  stats.mean(latency)

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