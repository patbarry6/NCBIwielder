#!/bin/sh
#  RmDupLines.sh
#  
# Written by Patrick Barry on 1/13/21.
#  
InFile="${1}" #We are going to pass taxa_IDs from edirect
InFileOneLine=`echo "${InFile}"OneLine.fasta`
InFileWrapped=`echo "${InFile}"Wrap.fasta`

cp "${InFile}" "${InFileWrapped}"

#first we need to unwrap the fasta format (blarg)
#cat "${InFile}" | awk '{if (substr($0,1,1)==">"){if (p){print "\n";} print $0} else printf("%s",$0);p++;}END{print "\n"}' > "${InFileOneLine}"
cat "${InFile}" | awk '{if (substr($0,1,1)==">"){if (p){print "\n";} print $0} else printf("%s",$0);p++;}END{print "\n"}' > "${InFileOneLine}"

#UniqLines=( $( grep '^>' "${InFileOneLine}" | sort | uniq | grep -nf /dev/stdin "${InFileOneLine}" | awk '{print $1}' FS=":") )

#find out what our unique sequence labels are
grep '^>' "${InFileOneLine}" | sort | uniq > UniqueSeqs.txt

#read in the file as an array
IFS=$'\n' read -d '' -r -a UniqSeq < UniqueSeqs.txt

#find the first match to each unique sequence
#this is where I drop some sequences
UniqLines=()
for i in "${!UniqSeq[@]}"; do
#UniqLines+=($(grep -nm 1 "${UniqSeq[i]}" "${InFileOneLine}" | awk '{print $1}' FS=":"))
UniqLines+=($(echo "${UniqSeq[i]}" | awk '{print $1}' FS=" " | grep --max-count 1 -nf /dev/stdin "${InFileOneLine}"| awk '{print $1}' FS=":"))
done

#make an array for the sequences under the lables
LinesAdd=()
for i in "${!UniqLines[@]}"; do
LinesAdd+=($(bc -l <<< "${UniqLines[$i]} + 1" ))
done

#combine the two arrays and sort
SeqIndex=("${UniqLines[@]}" "${LinesAdd[@]}")

sortedSeqIndex=( $( printf "%s\n" "${SeqIndex[@]}" | sort -n ) )

rm "${InFile}"

for i in "${sortedSeqIndex[@]}"; do
sed -n "$i"p "${InFileOneLine}" >> "${InFile}"
done

exit 0
