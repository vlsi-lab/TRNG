# TRNG - VLSI LAB PoliTo

In the **TRNG** repository you can find a hardware implementation of a Ring Oscillator-based True Random Number Generator, with or without the additional conditioning through the [Keccak function](https://github.com/vlsi-lab/keccak_integration.git). The repository is structured in such way that the component can be easily integrated as an external accelerator in the X-HEEP microcontroller. **To only use the stand-alone components, just consider the "src" folders in each branch.**

[X-Heep](https://github.com/esl-epfl/x-heep.git) (eXtendable Heterogeneous Energy-Efficient Platform) is a RISC-V microcontroller described in SystemVerilog that can be configured to target small and tiny platforms as well as extended to support accelerators. For a correct step-by-step integration of the TRNG, follow the indications given in the X-HEEP documentation.

The repository is organized as follows. 

![Image](https://github.com/vlsi-lab/TRNG/blob/main/repo.png)

The main branch contains the theoretical Python model and some examples tests. 
* **Python Model.** There are two scripts in  `scripts/theoretical_model`. 
    * `delay_gen.py` : generates a .txt file with the delays (in ps) to associate to each inverter of the noise source. This .txt file must be read and assigned in the testbench.
    * `autom_test.sh` : you can run this script to automatically call `delay_gen.py` and automatically generate multiple text files depending on the variation of the number of ROs, number of inverters and sigma.  
* **Tests.** This directory is divided in three subdirectories, one for each test suite (BSI AIS-31, NIST SP 800-22 and NIST SP 800-90B). For more info, check the additional `README.md` file in this directory.

The other two important branches are:
* **x_heep_trng** : contains only the TRNG source codes.
* **x_heep_trng_keccak** : contains the files for the TRNG with the KECCAK conditiong.

Both branches are internally organized as follows:

    .
    ├── regs_gen
    ├── src
    │   ├── basic_gates
    │   ├── regs
    │   └── wrapper
    ├── sw
    ├── tb
    |  └── model_files
    └── vlsi_polito_xxx.core

* **regs_gen** : contains the .hjson description files to be used by RegTool. They are used to create the register interface between X-HEEP and the accelerator (not needed if components are used stand-alone).
* **src** : this folder contains the HDL files in SystemVerilog. A brief overview on its internal folders:
    * **basic_gates**: folder with the most basic gates and blocks.
    * **regs**: contains the .sv registers obtained by means of RegTool (not needed if components are used stand-alone).
    * **wrapper**: contains the .sv file wrapping the TRNG/TRNG+KECCAK and the register interface (not needed if components are used stand-alone).
* **sw**: provides the C drivers (not needed if components are used stand-alone).
* **tb**: contains the testbench for X-HEEP. If the components are not integrated in X-HEEP, a new testbench can be created. The important thing is to read and assign           the delays to the inverters. The file containing this information is contained in model_files.
* **vlsi_polito_xxx.core**: the core file to be used for the integration with FuseSOC (not needed if components are used stand-alone).

## Getting started
Get the repository:
```
git clone --recursive https://github.com/vlsi-lab/TRNG.git
```
And check for the branch desired.
```
git checkout x_heep_XXX
```

<!-- LICENSE -->
## License
Distributed under the MIT License.
See `LICENSE.txt` for more information.



<!-- CONTACT -->
## Contact
Valeria Piscopo - [linkedin](https://www.linkedin.com/in/valeria-piscopo-4aa88b256) - valeria.piscopo@polito.it

Alessandra Dolmeta - [linkedin](https://www.linkedin.com/in/alessandra-dolmeta-4884301a3/) - alessandra.dolmeta@polito.it

Mattia Mirigaldi -  [linkedin](https://www.linkedin.com/in/mattia-mirigaldi-8109b9201/) - mattia.mirigaldi@polito.it

## Reference
.


