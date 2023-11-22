##############################################################################
#                                                                            #
#   This script analyzes the output file from Synopsys' synthesis (timing,   #
#   power, area) and performs a PPA analysis through graphs:                 #
#   - area vs n_ROs + area vs n_INVs                                         #
#   - max frequency vs n_ROs + area vs n_INVs                                #
#   - total power vs n_ROs + area vs n_INVs                                  #
#                                                                            #
##############################################################################

import sys
import os.path
import math
import numpy as np
import matplotlib.pyplot as plot
import glob
import operator


def sort_n_plot(list, type_of_plot, unit_meas):
    fig, (ax1, ax2) = plot.subplots(1, 2)
    list.sort(key=operator.itemgetter(1,0)) #sort by INV to get ascending RO
    x = []
    y = []
    # n_inv fixed at 3 and 64

    for elem in list[:4]:
        x.append(elem[0])
        y.append(elem[2])
    
    ax1.plot(x, y, '-bo', label="#INV = 3")
    ax1.grid()
    ax1.set_xticks(range(0, 33, 4))
    ax1.set_xlabel('# parallel ROs')
    ylab = type_of_plot + ' [' + unit_meas + ']'
    ax1.set_ylabel(ylab)

    x.clear()
    y.clear()
    for elem in list[-4:]:
        x.append(elem[0])
        y.append(elem[2])

    ax1.plot(x, y, '-ro', label="#INV = 64")
    ax1.grid() 
    ax1.set_xticks(range(0, 33, 4))
    title = type_of_plot + ' vs #ROs'
    ax1.set_title(title)
    ax1.set_xlabel('# parallel ROs')
    ylab = type_of_plot + ' [' + unit_meas + ']'
    ax1.set_ylabel(ylab)
    ax1.legend()
    ax1.grid()

    list.sort(key=operator.itemgetter(0,0)) #sort by RO to get ascending INV
    x.clear()
    y.clear()

    # n_RO fixed at 4 and 32
    for elem in area_list[:5]:
        x.append(elem[1])
        y.append(elem[2])

    ax2.plot(x, y, '-bo', label="#RO = 4")
    ax2.set_xticks(range(1, 65, 2))
    ax2.set_xlabel('# INV in a RO')
    title = type_of_plot + ' vs #INVs'
    ax2.set_title(title)
    ax2.set_ylabel(ylab)

    x.clear()
    y.clear()

    for elem in area_list[-5:]:
        x.append(elem[1])
        y.append(elem[2])
        
    ax2.plot(x, y, '-ro', label="#RO = 32")
    ax2.set_xticks(range(1, 65, 2))
    ax2.set_xlabel('# INV in a RO')
    ax2.set_ylabel(ylab)
    ax2.grid()
    ax2.legend()
    
    #plot.show()
    fig.set_size_inches(21, 12)
    plot.savefig('./analysis_res/%s_graph.png' %type_of_plot)


path = os.path.join(os.getcwd(), "results/*.rpt")
files = glob.glob(path)
s_to_find = ['report_area', 'report_timing', 'report_power']


maxf_list = []
totpow_list = []
area_list = []

for elem in files:

    n_inv = int(elem.split('/')[-1].split('_')[2].split('INV')[0])
    n_ro  = int(elem.split('/')[-1].split('_')[3].split('RO')[0])

    if s_to_find[0] in elem.split('/')[-1]:
        # Area report 
        with open(elem, 'r') as fileID:
            for line in fileID:
                if 'Total cell area' in line:
                    area = float(line.split(':')[-1])
            
        temp = [n_ro, n_inv, area]
        area_list.append(temp)    

    elif s_to_find[1] in elem:
        # Timing report
        with open(elem, 'r') as fileID:
            for line in fileID:
                 if 'data arrival time' in line:
                    if '-' in line:
                        freq = (1/(float(line.split('-')[-1]))) * 1000 # MHz
        
        temp = [n_ro, n_inv, freq]
        maxf_list.append(temp)

    elif s_to_find[2] in elem:
        # Power report
        next_line = 0
        with open(elem, 'r') as fileID:
            for line in fileID:
                 if next_line == 1 and line.find('Total') != -1:
                     totpower = float(line.split('W')[-2].split(' ')[-2]) * 1000 #uW

                 if '----------' in line:
                     next_line = 1
                 else:
                     next_line = 0    

        temp = [n_ro, n_inv, totpower]
        totpow_list.append(temp)

    else:
        print("ERROR: file" + elem + "not valid")
        break

sort_n_plot(area_list, 'Area', 'um^2')
sort_n_plot(maxf_list, 'Max frequency', 'MHz')
sort_n_plot(totpow_list, 'Total Power', 'uW')
