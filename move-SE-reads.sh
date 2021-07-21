#!/bin/bash

# One lab in particular likes to mix in single end and paired end reads into the same folder
# so this is an attempt to separate them out, by moving single end reads into a separate
# folder

# function to check if there are any matches (one or more)
# https://stackoverflow.com/questions/24615535/bash-check-if-file-exists-with-double-bracket-test-and-wildcards
exists() { [[ -f $1 ]]; }

# This function will check to make sure the directory doesn't already exist before trying to create it
make_directory() {
    if [ -e $1 ]; then
        echo "Directory "$1" already exists"
    else
        mkdir -v $1
    fi
}

SOURCE_DIR=$1
echo "SOURCE_DIR is set to:" $SOURCE_DIR

DEST_DIR=$2
echo "DEST_DIR is set to:" $DEST_DIR

make_directory ${DEST_DIR}

# check for first and second argument
if [[ -z "${1}" || -z "${2}" ]]; then
  echo "You forgot to supply a target and/or destination directory."
  echo "USAGE: "
  echo "move-SE-reads.sh source-dir/ destination-for-single-end-reads/"  
  exit 1
fi

ID_list="$(find . -maxdepth 1 -type f -name "*.fastq.gz" | while read F; do basename $F | rev | cut -c 22- | rev; done | sort | uniq)"

# set counters to 0, increment in loop
num_IDs_with_multiple_files=0
num_IDs_with_one_file=0

# for ID in ID_list; look for files, count how many there are
# if there are more than one file for an ID, increment counter by 1
# if there is only one file, increment other counter by 1.
# Will eventually add line for moving files in here
for ID in ${ID_list}; do
  num_files=$(ls -f1 ${ID}* | wc -l)
  echo "number of files for ${ID}" ${num_files}
  if [[ ${num_files} -gt 1 ]]; then
    echo "There is more than one file for" $ID
    ((num_IDs_with_multiple_files++))
  else
    echo "There is only one file for" ${ID}
    ((num_IDs_with_one_file++))
    echo "moving single end files into ${DEST_DIR}"
    mv -v ${ID}*.gz ${DEST_DIR}
    echo
  fi
done

echo
echo "number of IDs with more than one file:" ${num_IDs_with_multiple_files}
echo
echo "number of IDs with only one file:" ${num_IDs_with_one_file}

echo "END"
date
