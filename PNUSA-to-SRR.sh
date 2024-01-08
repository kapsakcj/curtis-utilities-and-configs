#!/bin/bash
#
# REQUIREMENTS:
# - input txt file containing one PNUSA identifier, e.g. PNUSAE159378, per line. NO WINDOWS LINE ENDINGS, MUST BE LINUX lf LINE ENDINGS
# - executables from NCBI entrez-utils must be installed and available, specifically:
#  - esearch
#  - efetch
#  - xtract
# "tee" must be installed for logging purposes (available on almost all linux distros)

# OPTIONAL:
# - set the global bash variable NCBI_API_KEY with your NCBI API key, if you have one.
# Prior to running the script, use the command "export NCBI_API_KEY=<your-api-key>" to set this variable.

PNUSA_LIST=$1
OUTFILE=$2

# check for first argument; input list of
if [[ -z "${1}" ]]; then
  echo "You forgot to supply a list of PNUSA identifiers."
  echo "USAGE: "
  echo "$0 list-of-pnusa-ids.txt <output-TSV-filename>"  
  exit 1
fi

# check for second argument
if [[ -z "${2}" ]]; then
  echo "You forgot to supply a target output file."
  echo "USAGE: "
  echo "$0 list-of-pnusa-ids.txt <output-TSV-filename>"  
  exit 1
fi

# check that necessary executables (efetch, esearch, xtract) are available
if ! command -v efetch &> /dev/null || ! command -v esearch &> /dev/null || ! command -v xtract &> /dev/null; then
    echo "efetch, esearch, or xtract could not be found"
    echo "Please install NCBI entrez-utils"
    exit 1
fi

# loop through each of the IDs in the input list, and for each one, query NCBI SRA for the SRR accession number
# if there is nothing returned from the query, then denote that "SRR accession could not be located on NCBI SRA"
# the output file should be a 2 column TSV, where the first column is the PNUSA ID, and the second column is the SRR accession number or the message "SRR accession could not be located on NCBI SRA"
cat ${PNUSA_LIST} | while read PNUSA_ID; do
  echo "querying NCBI SRA for ${PNUSA_ID}"
  # if any of the 3 below lines throws an error, then sleep for 10 seconds and try again

  esearch -db sra -query ${PNUSA_ID} </dev/null | \
  efetch -format docsum | \
  xtract -pattern Runs -element Run@acc > ${PNUSA_ID}.tmp

    # if the tmp file is empty, then the SRR accession could not be located on NCBI SRA
    ## TODO - perhaps adjust messaging to account for API limits hit or other errors. It's possible that the SRR accession could not be located on NCBI SRA because of an API limit being hit, or some other error.
    if [ ! -s ${PNUSA_ID}.tmp ]; then
        echo -e "${PNUSA_ID}\tSRR accession could not be located on NCBI SRA" | tee -a ${OUTFILE}

        # count the number of times this has happened and store it in a variable
        # additionally, generate a list of the PNUSA IDs that could not be located on NCBI SRA and list out these IDs in a separate output file called "PNUSAs-not-found.txt"
        ((COUNT_PNUSA_IDS_NOT_FOUND++))
        echo ${PNUSA_ID} >> PNUSAs-not-found.txt
    else
        # if the tmp file is not empty, then the SRR accession was located on NCBI SRA
        # so, add a new line to the output file with the PNUSA ID and the SRR accession
        echo -e "${PNUSA_ID}\t$(cat ${PNUSA_ID}.tmp)" | tee -a ${OUTFILE}
    fi
  # if the tmp file exists, remove it
  if [ -f ${PNUSA_ID}.tmp ]; then
    rm ${PNUSA_ID}.tmp
  fi
done

# print out the number of PNUSAs that could not be located on NCBI SRA
echo "-------------------------"
echo "Number of PNUSAs that could not be located on NCBI SRA: ${COUNT_PNUSA_IDS_NOT_FOUND}"
echo

# print out the list of PNUSAs that could not be located on NCBI SRA
echo "List of PNUSAs that could not be located on NCBI SRA:"
cat PNUSAs-not-found.txt
echo
echo "It's possible that the SRR accession could not be located on NCBI SRA because of an API limit being hit, or some other error."
echo "We recommend that you do a quick search of the PNUSA identifier(s) on https://www.ncbi.nlm.nih.gov/ to confirm."
echo
echo "Done! Output file is ${OUTFILE}"
