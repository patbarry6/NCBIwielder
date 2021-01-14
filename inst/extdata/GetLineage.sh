#!/bin/sh
#  GetLineage.sh
#  
# Written by  Frédéric Mahé
# Adapted by Patrick Barry on 1/13/21.
#  
Sp_TaxID="${1}" #We are going to pass taxa_IDs from edirect
NAMES="${2}" # We are going to pass these in through R
NODES="${3}"
TAXONOMY=""

# Function for extracting the taxa or node number
get_name_or_taxid()
{
grep --max-count=1 ^"${1}" "${2}" | cut -f "${3}"
}

# Set the TAXID variable to Sp_TaxID
TAXID="${Sp_TaxID}"

# Loop until you reach the root of the taxonomy (i.e. taxid = 1)
while [[ "${TAXID}" != 1 ]] ; do
# Obtain the scientific name corresponding to a taxid
NAME=$(get_name_or_taxid "${TAXID}" "${NAMES}" "3")
# Obtain the parent taxa taxid
PARENT=$(get_name_or_taxid "${TAXID}" "${NODES}" "3")
# Build the taxonomy path
TAXONOMY="${NAME};${TAXONOMY}"
TAXID="${PARENT}"
done

echo "${TAXONOMY}"

exit 0
