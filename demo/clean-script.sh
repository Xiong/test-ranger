#!/bin/bash
#
# This one-line shell script "cleans up" the output of 'script (1)'
# See http://www.ncssm.edu/~cs/index.php?loc=logging.html&callPrintLinuxSupport=1
#
cat $1 | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b > $1.out
