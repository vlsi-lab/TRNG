# Introduction

In the **TRNG** repository you can find a possible hardware implementation of a True Random Number Generator, with or without the additional conditioning by means of the Keccak block (inserire riferimento repo Keccak?). 

The repository is organized as follows. 

![Image](https://github.com/vlsi-lab/TRNG/blob/main/repo.png)

There are two important branches:
* x_heep_trng : contains only the TRNG source codes
* x_heep_trng_keccak : contains the files for the TRNG with the KECCAK conditiong.

An important note is that both branches are organised to facilitate the integration in X-HEEP. To only use the stand-alone components, just consider the "src" folders in each branch.
.....
[X-Heep](https://github.com/esl-epfl/x-heep.git) (eXtendable Heterogeneous Energy-Efficient Platform) is a RISC-V microcontroller described in SystemVerilog that can be configured to target small and tiny platforms as well as extended to support accelerators.


## Getting started
TO BE MODIFIED
Get the repository:
```
git clone --recursive https://github.com/vlsi-lab/keccak_integration.git
```
And check for the branch desired.
```
git checkout keccak_XXX
```

<!-- LICENSE -->
## License
Distributed under the MIT License.
See `LICENSE.txt` for more information.




<!-- CONTACT -->
## Contact
Valeria Piscopo - [linkedin](https://www.linkedin.com/in/valeria-piscopo-4aa88b256) - valepiscopo.hk@gmail.com

Alessandra Dolmeta - [linkedin](https://www.linkedin.com/in/alessandra-dolmeta-4884301a3/) - alessandra.dolmeta@polito.it

Mattia Mirigaldi -  [linkedin](https://www.linkedin.com/in/mattia-mirigaldi-8109b9201/) - mattia.mirigaldi@polito.it

## Reference
.


