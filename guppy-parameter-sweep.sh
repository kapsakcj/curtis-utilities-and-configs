#!/bin/bash
# Curtis Kapsak, started 2021-02-16
#
# NOTES
# ONT recommends to NOT decrease chunk size as it leads to lower accuracy in some cases
# dna_r9.4.1_450bps_hac_prom.cfg has chunk size = 2000

# https://community.nanoporetech.com/posts/guppy_server-on-aws-v100-i
# This guy ran Guppy last Jan 2020 on AWS instance with 1 V100, 8 vCPUS, up to 61GB RAM

# testing with NARMS subset dataset (6.3GBytes) Rapid barcoding kit, R941 flowcell

# this script assumes we are in /scicomp/scratch/pjx8 and using the fast5 files at:
# /scicomp/scratch/pjx8/NARMS-subset-6.3GB-r941-rbk

#take the first argument as OUTDIR
OUTDIR=$1

if [[ $1 == "" ]]; then
  echo "You forgot to specify an OUTDIR."
  echo "Please specify an OUTDIR with YYYY-MM-DD-guppy-#.#.#-param-sweep"
  echo 
  echo "Example usage:"
  echo "$0 2021-02-19-guppy-4.4.2-param-sweep/"
  exit 1
fi

fast5s=/scicomp/scratch/pjx8/NARMS-subset-6.3GB-r941-rbk
echo "fast5s set to:" $fast5s

# set up the environment
source /etc/profile.d/modules.sh
module purge
module load guppy/4.4.2
guppy_basecaller --version

hostname
echo "Started at:"$(date)


# chunk size will be KEPT at 2000
# num callers 2, 3, 4, 5, 6
for numCallers in $(seq 2 6); do
  # gpu runners 2 3 4 5 6
  for gpuRunners in $(seq 2 6); do
    # chunks per runner
    # steps are small, I'm expecting to hit many GPU out of memory errors
    for chunksPerRunner in 768 1024 1280 1536 ; do
      guppy_basecaller -i $fast5s \
                       -s $OUTDIR/numCallers-${numCallers}_gpuRunners${gpuRunners}_chunksPerRunner${chunksPerRunner} \
                       -r \
                       -c dna_r9.4.1_450bps_hac.cfg \
                       --gpu_runners_per_device ${gpuRunners} \
                       --chunks_per_runner ${chunksPerRunner} \
                       --num_callers $numCallers \
                       --compress_fastq \
                       --trim_barcodes \
                       --barcode_kits "SQK-RBK004" \
                       --num_barcode_threads 8 \
                       -x cuda:0
      echo "Completed this combination:"
      echo "numCallers-${numCallers}_gpuRunners${gpuRunners}_chunksPerRunner${chunksPerRunner}"
      echo "Onto the next!"
      echo "------------------------------------------------------------------------"
    done
  done
done
