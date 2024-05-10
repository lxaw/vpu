#!/bin/bash

# Just a bash script to run the Verilog test files.
# This is to make life easier, so we can just type
# ./run_bench.sh .
# Don't forget to `chmod +x run_bench.sh` !

# Compile verilog files
iverilog -o vpu_wav vpu.v vpu_tb.v

# simulate design
vvp vpu_wav

# delete the wav afterwards 
# I typically like to do this when developing
rm vpu_wav

# exit (with success!)
exit 0