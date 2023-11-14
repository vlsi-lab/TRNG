##############################################################################
#                                                                            #
#   This script analyzes the output file from NIST test and produces         #
#   graphs + text file.                                                      #
#                                                                            #
#   2 arguments required from command line:                                  #
#   argv[1] --> name of output file from NIST test (finalAnalysisReport.txt) #
#   argv[2] --> value of m = number of samples analyzed during NIST test     #
#                                                                            #
##############################################################################
import sys
import os.path
import math
import numpy as np
import matplotlib.pyplot as plot


#file_path = '/media/valeria/Windows-SSD/Linux-windows/Tesi/NIST/NIST_test_suite/sts-2.1.2/experiments/AlgorithmTesting/finalAnalysisReport.txt'
file_path = os.path.join(os.getcwd(), sys.argv[1])

j = 0
proportion = []
test = []
hist_values = []
P_values = []
undef_tests = []
with open(file_path, 'r') as fileID:
    for i, line in enumerate(fileID):
        # Ignore header
        if 6 < i < 195:
            # Consider only valid data
            if line.find('----') == -1:
                if line.find('*') != -1:
                    line = line.replace('*', '') # * ???
                line_values = line.split()
                
                # Histogram of valid P_values
                if(i == 7 or test[j-1] != line_values[12] or (test[j-1] == line_values[12] and P_values[j-1] > float(line_values[10]))):
                    if (i != 7 and test[j-1] == line_values[12] and P_values[j-1] > float(line_values[10])):
                        P_values[j-1] = float(line_values[10])
                        hist_values[j-1] = [int(elem) for elem in line_values[0:10]]
                        proportion[j-1] = float(line_values[11].split('/')[0])/float(line_values[11].split('/')[1]) 
                    else :
                        P_values.append(float(line_values[10]))
                        proportion.append(float(line_values[11].split('/')[0])/float(line_values[11].split('/')[1]))
                        test.append(line_values[12])
                        hist_values.append([int(elem) for elem in line_values[0:10]])
                        j = j + 1

            else:
                # Save which tests are undefined
                if(line.find('*') == - 1):
                    line = line.replace("*", "")
                    
                undef_tests.append(line.split()[12])   
                            
        elif i > 195:
            break

plot.figure(1)
alpha = 0.01
p_cap = 1 - alpha
conf_interv1 = p_cap + 3*math.sqrt((p_cap*(1-p_cap))/float(sys.argv[2]))
conf_interv2 = p_cap - 3*math.sqrt((p_cap*(1-p_cap))/float(sys.argv[2]))
plot.scatter(range(1,16), proportion)
plot.axhline(y = conf_interv1, linestyle = '--', label = 'Acceptable Range')
plot.axhline(y = conf_interv2, linestyle = '--')
plot.title('Proportion of Sequences Passing a Test')
plot.xticks(range(1,16))
plot.xlabel('Type of test')
plot.ylabel('Proportions')
plot.legend(loc = "lower right")
plot.grid()
#plot.show()
plot.savefig('./NIST_res_analysis/Pass_seq_%s' %sys.argv[1].split('/')[-1].replace(".txt", ".png"))

fig, axes = plot.subplots(4, 4)
for row in range(4):
    for col in range(4):
        if(col + 4*row < 15):
            axes[row][col].hist(x=np.arange(0,1,0.1), bins=10, weights = hist_values[col + 4*row])
            axes[row][col].set_ylabel(test[col + 4*row])
            axes[row][col].set_xticks(np.arange(0,1,0.1))
            axes[row][col].grid(axis ='x', alpha=0.1, linestyle = '-', linewidth = 1, color = 'r')
            
            
fig.suptitle('Histogram of P-Values - %s' %sys.argv[1].split('/')[-1])
fig.set_size_inches(32, 18)
plot.savefig('./NIST_res_analysis/Hist_Pval_%s' %sys.argv[1].split('/')[-1].replace(".txt", ".png"))

path_save = os.path.join(os.getcwd(), './NIST_res_analysis/')
with open(os.path.join(path_save, sys.argv[1].split('/')[-1]), 'w') as fileID:
    flag = 1
    fileID.write('P_VAL < 0.01 FOR TESTS (NO UNIFORM DISTRIBUTION): \n')
    for i, elem in enumerate(P_values):
        if elem < alpha:
            fileID.write(test[i])
            fileID.write('\n')
            flag = 0

    if(flag == 1):
        fileID.write("None")
    

    fileID.write('INCONCLUSIVE TESTS: \n')
    if not undef_tests:
        fileID.write("None")
    else:
        for elem in undef_tests:
            fileID.write(elem)
            fileID.write('\n')
            
