#!/bin/bash
# This script is used to modify the header of the file
# Impemented due to an error in the control-fdr rule 'Error: tag PROB_NONE undefined in BCF/VCF header'
# Modify Header of the final bcf to include the PROB_NONE tag

# this script is designed to be run on the cluster
# it requires the Bioinformatics and bcftools modules
# This script is written by: Jim Delproposto at the University of Michigan

# Usage: bash header_mod.sh <input.bcf>

# 20230217 update: The problem was resolved through modification of the config.yaml file so this scrip is no longer used


# Load the Bioinformatics and bcftools module
module load Bioinformatics
module load bcftools

# create a function to unload the modules when exiting the script
function unload_modules {
    # unload the Bioinformatics and bcftools modules
    module unload Bioinformatics
    module unload bcftools
}

# call the function when exiting the script
trap unload_modules exit








# accept input and output file names from the command line
input=$1


# create a folder to store the log file
mkdir -p ./logs/header_mod

# create a log file in the logs folder with the file name .log
log=./logs/header_mod/$(basename $input .bcf).log

# print the date and time to the log file
date > $log

# create a temporary file to store the header
tmp=$(mktemp)

# extract the header from the input file
bcftools view -h $input > $tmp



# determine if PROB_ABSENT is already in the header
grep -q "PROB_ABSENT" $tmp

# if PROB_ABSENT is not in the header, create an error message and exit
if [ $? -ne 0 ]; then
    echo "Error: tag PROB_ABSENT undefined in BCF/VCF header which is used to add PROB_NONE tag"

    # wait for user input
    read -p "Press enter to continue"

    # print error message to the log file
    echo "Error: tag PROB_ABSENT undefined in BCF/VCF header which is used to add PROB_NONE tag" >> $log

    # add the header to the log file
    cat $tmp >> $log
    # remove the temporary file
    rm $tmp
    # exit the script
    exit 1
fi

# determine if PROB_NONE is already in the header
grep -q "PROB_NONE" $tmp

# if PROB_NONE is already in the header, create an error message and exit
if [ $? -eq 0 ]; then
    echo "Error: tag PROB_NONE already defined in BCF/VCF header"

    # wait for user input
    read -p "Press enter to continue"

    # print error message to the log file
    echo "Error: tag PROB_NONE already defined in BCF/VCF header" >> $log

    # add the header to the log file
    cat $tmp >> $log
    # remove the temporary file
    rm $tmp
    # exit the script
    exit 1
fi



# add the PROB_NONE tag to the header immedietly before PROB_ABSENT
sed -i '/PROB_ABSENT/ i\##INFO=<ID=PROB_NONE,Number=A,Type=Float,Description="Modified header to enter PROB_NONE info due to control fdr rule error">' $tmp

# turn the input into a vcf file
bcftools view -O v $input > $input.vcf


# overwrite the input with the new header
bcftools reheader -h $tmp $input.vcf > $input.tmp

# turn the input back into a bcf file
bcftools view -O b $input.tmp > $input

# remove the temporary files
rm $tmp
rm $input.vcf
rm $input.tmp

# end of script

