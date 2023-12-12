#!/bin/bash

# Assumptions/Requirements:
# referece FASTA files have already been indexed with 'bwa index' prior to running this script
# docker


# This function will check to make sure the directory doesn't already exist before trying to create it
make_directory() {
    if [ -e $1 ]; then
        echo "Directory "$1" already exists"
    else
        mkdir -v $1
    fi
}

set -ou pipefail

# set variables
export READ1=$1
echo "READ1 is set to:" $READ1

# determine samplename based on READ1 prefix
export SAMPLENAME=$(basename $READ1 | cut -f 1 -d '-')
echo "SAMPLENAME is set to:" $SAMPLENAME

export READ2=$2
echo "READ2 is set to:" $READ2

export REF_FASTA=$3
echo "REF_FASTA is set to:" $REF_FASTA

export OUTDIR=$4
echo "OUTDIR is set to:" $OUTDIR

make_directory ${OUTDIR}

echo running BWA on all files in ${SAMPLENAME}

# map reads to reference genome with BWA; sort and convert to BAM; generate basic stats on alignments
docker run --rm \
 -e READ1 -e READ2 -e REF_FASTA -e OUTDIR -e SAMPLENAME \
 -v ${PWD}:/data \
 -u $(id -u):$(id -g) \
 us-docker.pkg.dev/general-theiagen/staphb/ivar:1.3.1-titan \
 /bin/bash -c 'bwa mem -t 4 /data/$REF_FASTA /data/$READ1 /data/$READ2 | samtools sort -@ 4 -O BAM -o /data/$OUTDIR/$SAMPLENAME.bam; samtools flagstat -@ 4 /data/$OUTDIR/$SAMPLENAME.bam | tee /data/$OUTDIR/$SAMPLENAME.bam.flagstat.txt'