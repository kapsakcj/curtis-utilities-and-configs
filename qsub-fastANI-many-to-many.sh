#!/bin/bash
#$ -o fastANI.qsub.log
#$ -j y
#$ -N fastANI
#$ -pe smp 16
#$ -l h_vmem=72G
#$ -V -cwd

## Curtis Kapsak, pjx8, 2020-12-14

## This script runs fastANI many-to-many comparison, given a query list and reference list
# The query and referenes lists MUST list one ABSOLUTE file path per line

## GET INPUTS ##
# your list of samples
queryList=$1

# your list of references to compare to
referenceList=$2

outputFile=$3

# if any of the 3 arguments are blank/not given, exit script
if [[ "$1" == "" || "$2" == "" || "$3" == "" ]]; then
    echo "You must supply the queryList refernceList and outputFile IN THIS ORDER"
    echo 
    echo "Usage: $0 queryList referenceList outputFile"
    echo 
    echo "fastANI binary MUST be in your current working directory and..."
    echo "...it must be named exactly 'fastANI' for it to work"    
    exit 1
fi

# debugging statements
hostname
echo '$NSLOTS is set to:' $NSLOTS
trap ' { echo "END - $(date)" } ' EXIT

# run fastANI on user supplied genomes and reflist. force the use of 16 threads for parallelization
./fastANI --ql ${queryList} --rl ${referenceList} -t ${NSLOTS} -o ${outputFile}

