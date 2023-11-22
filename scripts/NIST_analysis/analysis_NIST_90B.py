##############################################################################
#                                                                            #
#   This script analyzes the output files from NIST SP 800-90B test and      #
#   produces a text file where different results for different analyses      #
#   are compared                                                             #
#                                                                            #
##############################################################################
import sys
import os.path
import math
import numpy as np
import matplotlib.pyplot as plot
import glob


path = os.path.join(os.getcwd(), "NON_IID_results/*.txt")
files = glob.glob(path)
s_to_find = 'H_original: '
H_vals = []

for elem in files:
    with open(elem, 'r') as fileID:
        for i, line in enumerate(fileID):
            if s_to_find in line:
               H_vals.append(line.split()[1])
            

new_file = os.path.join(os.getcwd(), "NON_IID_results/Comparation.txt")
files.remove(new_file)
with open(new_file, 'w') as fileID:
    fileID.write("Min entropy  |   Shannon entropy   |  Case of study\n")
    fileID.write("--------------------------------------------------------------------------\n")
    for i, elem in enumerate(H_vals):

        fileID.write(elem)
        for n in range(13-len(elem)):
            fileID.write(" ")
        fileID.write("| ")

        float_elem = float(elem)
        Shannon_H = -2**(-float_elem)*math.log2(2**(-float_elem)) - (1-2**(-float_elem))*math.log2(1-2**(-float_elem))
        fileID.write(str(Shannon_H))
        for n in range(20-len(str(Shannon_H))):
            fileID.write(" ")
        fileID.write("| ")

        file_name = files[i].split('/')[-1]
        n_INVs = (int)(file_name.split('_')[3].split('I')[0])
        n_ROs  = (int)(file_name.split('_')[4].split('R')[0])
        sigma  = (int)(file_name.split('_')[5].split('s')[0])
        fileID.write("n_RO = %d, n_INV = %d, sigma = %d ps \n" %(n_ROs, n_INVs, sigma))
        
        if(elem == max(H_vals)):
            n_INV_max  = n_INVs
            n_RO_max   = n_ROs
            sigma_max  = sigma
            Shan_H_max = Shannon_H
            
    fileID.write("--------------------------------------------------------------------------\n")
    fileID.write("Best result:\n")
    fileID.write("H_min = %f, H_shan = %f - %d ROs of %d inverters (sigma = %d ps)" %(float(max(H_vals)), Shan_H_max, n_RO_max, n_INV_max, sigma_max))
