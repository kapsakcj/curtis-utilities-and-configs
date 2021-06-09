#!/bin/bash
#
# REQUIREMENTS:
# -filenames must end with standard ILMN filename endings, that are 21 characters long:
#   _L002_R2_001.fastq.gz
#   _L001_R1_001.fastq.gz
#   etc.

# totally stolen and modified from https://www.biostars.org/p/317385/

# function to check if there are any matches (one or more)
# https://stackoverflow.com/questions/24615535/bash-check-if-file-exists-with-double-bracket-test-and-wildcards
exists() { [[ -f $1 ]]; }

# first argument must be target directory
TARGET_DIR=$1
echo "TARGET_DIR is set to $TARGET_DIR"

# check for first argument
if [[ -z "${1}" ]]; then
  echo "You forgot to supply a target directory."
  echo "USAGE: "
  echo "$0 dir-of-fastq.gz-files/"  
  exit 1
fi

# optional second argument. if pass 'dry' as second argument, don't concatenate, just echo cat commands
DRY_RUN=$2
if [[ "${DRY_RUN}" == "dry" ]]; then
  echo "DRY RUN OPTION SPECIFIED, NOT ACTUALLY CONCATENATING HERE..."
  # cut -c 22n is because this has 21 characters in it: _L002_R2_001.fastq.gz 
  # STARTING FROM 22ND CHARACTER, PRINT TIL THE END. THIS IS THE VARIABLE F WHICH IS THE SAMPLE ID
  for i in $(find ${TARGET_DIR} -maxdepth 1 -type f -name "*.fastq.gz" | while read F; do basename $F | rev | cut -c 22- | rev; done | sort | uniq); do
      echo "Merging R1 for ${i}"
      echo "cat "${i}"_L00*_R1_001.fastq.gz > "${i}"_merged_R1.fastq.gz"
    # check to see if R2 exists before concatenating & making an empty file when there is no R2
    if exists ${TARGET_DIR}/${i}*R2*.fastq.gz ; then
      echo "Merging R2 for ${i}"
      echo "cat "${i}"_L00*_R2_001.fastq.gz > "${i}"_merged_R2.fastq.gz"
    else
       echo "R2 file for ${i} was not found. Skipping R2 concatenation..."
    fi
  done
  # exit after doing dry run loop
  exit 0
fi

# actual concatenate
# maxdepth 1 so it only looks for fastq.gz's in the supplied path
for i in $(find ${TARGET_DIR} -maxdepth 1 -type f -name "*.fastq.gz" | while read F; do basename $F | rev | cut -c 22- | rev; done | sort | uniq); do
  echo "Merging R1 for ${i}"
  cat "${i}"_L00*_R1_001.fastq.gz > "${i}"_merged_R1.fastq.gz
  # check to see if R2 exists before concatenating & making an empty file when there is no R2
  if exists ${TARGET_DIR}/${i}*R2*.fastq.gz ; then
    echo "Merging R2 for ${i}"
    cat "${i}"_L00*_R2_001.fastq.gz > "${i}"_merged_R2.fastq.gz
  else
    echo "R2 file for ${i} was not found. Skipping R2 concatenation..."
  fi
done

date
echo "DONE"
