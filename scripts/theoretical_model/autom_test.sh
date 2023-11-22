#!/bin/bash

# Change n_inv, n_RO and sigma to modify parameters in "delay_gen.py"

# Vary number of inverters in a RO
for n_inv in 3 13 
do
    sed -i "s/n_delay_elem = .*/n_delay_elem = $n_inv/" "delay_gen.py"
    sed -i "s/model_.*INV/model_${n_inv}INV/" "delay_gen.py"
    # Vary number of parallel ROs 
    for n_RO in 32
    do
    sed -i "s/n_RO = .*/n_RO = $n_RO/" "delay_gen.py"
    sed -i "s/model_${n_inv}INV_.*RO/model_${n_inv}INV_${n_RO}RO/" "delay_gen.py"

    # Vary variance of gaussian jitter
        for sigma in 0 50 
        do
        sed -i "s/sigma = .*/sigma = $sigma/" "delay_gen.py"
        sed -i "s/model_${n_inv}INV_${n_RO}RO_.*sigma/model_${n_inv}INV_${n_RO}RO_${sigma}sigma/" "delay_gen.py"
        python3 ./delay_gen.py

        done

    done
done


