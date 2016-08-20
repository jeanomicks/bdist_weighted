# bdist_weighted
Partial version of baraminic distance calculation program (BDIST) with character weights

This program is a partially command line perl program version of the BDIST software available at http://www.coresci.org/bdist.html, authored by Dr. Todd Wood of the Core Academy of Sciences. It is different from it in that it allows the user to add weights to the individual characters in the entry dataset matrix.

This github repository contains three files:

bdist_mc_weights.pl naledi_postcran2.out naledi_postcran2.txt

The first is the program itself, which can be run this way:

perl bdist_mc_weights.pl -c 0.95 -i naledi_postcran2.txt -o naledi_postcran2.out

Here -c is the relevabce cutoff, and -i is the input data matrix, and -o is the output.

The last line of the input contains the word weights followed by a list of numbers with values between 0 and 1 representing the weight of that character.

References:

Wood, T.C. and M.J. Murray 2003. Understanding the Pattern of Life. Broadman & Holman, Nashville, TN.

Wood, T.C. 2008. BDISTMDS software, v. 2.0. Core Academy of Science.
