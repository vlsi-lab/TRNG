###################################################################################
#  Ref.: "True-Randomness and Pseudo-Randomness in Ring Oscillator-Based          #
#         True Random Number Generators", N. Bochard, F. Bernard, V. Fischer,     #
#         B. Valtchanov                                                           #
###################################################################################

import os.path
import numpy as np
import matplotlib.pyplot as plot

# Time unit : ps

# Parameters
n_RO = 32
n_delay_elem = 13
sigma = 50

# Deterministic jitter supposed = 0
Delta_dGD = 0
#Delta_dGD_freq = 3000
#sin_arg = 2*np.pi*Delta_dGD_Freq*time
#A = 5
#offset = 5
#Delta_dGD = A*np.sin(sin_arg) + offset

with open(os.path.join(os.getcwd(), 'model_13INV_32RO_50sigma.txt'), 'w') as fileID:
    for j in range(1, n_RO + 2):
        h = 0
        D_i = np.random.randint(275, 282)  # mean gate delay of a RO (275-281)
        # print delays of a RO for each line
        if j != 1:
            n_char = fileID.write(f'RO #{j-1} ')
            for print_var in range(len("RO #xxxx") - n_char):
                fileID.write(' ')
        for i in range(1, n_delay_elem + 1):
            if j == 1:
                if i == 1:
                    for _ in range(len("RO #xxxx")):
                        fileID.write(' ')
                fileID.write(f'I#{i} ')
            else:
                Delta_dLG = np.random.normal(0, sigma)
                h = h + D_i + Delta_dLG + Delta_dGD
                # print delay of INV for each column
                fileID.write(f'{int(D_i + Delta_dLG + Delta_dGD)} ')
                
                
        fileID.write('\n')
