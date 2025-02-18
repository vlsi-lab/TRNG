Each subdirectory contains an example of output obtained by applying the respective test suite to a bitstream produced by the TRNG. Remember: to obtain valid results, multiple bitstreams must be examined!  

## BSI AIS-31
Ref. [BSI AIS-31](https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Certification/Interpretations/AIS_31_Functionality_classes_for_random_number_generators_e.html)

The used test suite was directly downloaded from the Ref. website. Once started, the user needs to insert in the Evaluator GUI the required info: the type of test to be executed, the verbosity of the output, the data format (bin or char), whether the test has been already executed a first time and failed or not, and the parallelism of the key.

## NIST SP 800-22
Ref. [NIST SP 800-22](ttps://doi.org/10.6028/NIST.SP.800-22r1a)

The used test suite was obtained by cloning the [NIST SP 800-22-GiT](https://github.com/terrillmoore/NIST-Statistical-Test-Suite) repo. Check the README file of this repo for further details to execute the tests. In our case, after selecting the input file, we adjusted the parameters following the Ref. 
For n = 1,000,000 and 1000 bitstreams:
1) Block Freq.  : M >= 20, M > 0.01n, N = n/M < 100    --> chosen value = 10100
2) Non Overlap. : m = 9 or m = 10                      --> chosen value = 9
3) Overlap.     : m = 9 or m = 10                      --> chosen value = 9
4) Approx. Ent. : m < [ int_inf(log2(n)) - 5 ]         --> chosen value = 10
5) Serial       : m < [ int_inf(log2(n)) - 2 ]         --> chosen value = 16
6) Linear Comp. : 500 <= M <= 5000                     --> chosen value = 500

## NIST SP 800-90B
Ref. [NIST SP 800-90B](https://doi.org/10.6028/NIST.SP.800-90B)

The used test suite was obtained by cloning the [NIST SP 800-90B-GiT](https://github.com/usnistgov/SP800-90B_EntropyAssessment) repo. Check the README file of this repo for a detailed description to execute the IID and restart tests.
For what concerns the conditioning tests, we used Keccak, hence a vetted component. This means that the `ea_conditioning` command is:
`./ea_conditioning -v <n_in> 1600 1600 <h_in>`
where `n_in` is the number of true random bits in input to Keccak and `h_in` is equal to 0.9982 (IID entropy assessment per bit) multiplied by `n_in`.

In this way, the user can understand which value of `n_in` produces the required output entropy, thus how much the throughput of the whole system can be increased.
