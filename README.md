# NCBIwielder
An R package to help manipulate NCBI database information from the command line.

# About the package
This help users query the NCBI databases for nucleotide sequences. You can query the 
database for a list of taxa and loci and find out how many sequences are available.
You can pull the fasta formatted sequences for many taxa and loci. 
Currently the scripts only run on a UNIX operating syste. In the next iteration
I will figure out how to pass all the commands to the Windows subsystem for 
linux so that the grep and bash commands can be used on a Windows OS. For now,
as IT keeps telling me 'use a virtual machine with Linux kernal'. 

# Setup of the package
The setup is not entirely straightforward. You can install the R package like
you would normally do from GitHub but becuase there are some large files you
need to do some fine tunning from the command line. I know not everyone loves 
to do this, so I have tried to make the instructions painfully explicit. If you
need help don't hesitate to contact me: pdbarry@alaska.edu

## Download R package from github
```r
library(devtools)
install_github('patbarry6/NCBIwielder')
```

## Download blastn and edirect NCBI utilities
For the blastn utility which we will use to blast sequences to the ncbi nucleotide database
download [Blast+](https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/). Currently, 
no availabe functions use blastn, so you can skip this step for now.

For the edirect utility which we will use to search the ncbi nucleotide database
and retrieve sequences download [edirect](https://www.ncbi.nlm.nih.gov/books/NBK179288/).

Once those are installed, we  need to make sure they 
can be called from the terminal without having
to specify their full path. So we will create symbolic links to those
utilities in usr/bin which should be in your path. If you want to see 
what folders are in your path in the terminal execute
```bash
echo $PATH
```
You should see /usr/bin 

# Create symbolic links to put the progams blastn and esearch in your path
We won't move the actual utilities, but create some links with the cp command.
In the terminal you will want to copy the full path to each utility to the 
/usr/bin folder. If blastn was in the folder ~/Desktop/NCBItools/ncbi-blast-2.11.0+/bin/
and edirect was in the folder ~/Desktop/NCBItools/edirect/bin/esearch /usr/bin/blastn
I'd use the command:
```bash
sudo cp -s ~/Desktop/NCBItools/ncbi-blast-2.11.0+/bin/blastn /usr/bin/blastn.sh
sudo cp -s ~/Desktop/NCBItools/edirect/bin/esearch /usr/bin/edirect.sh
```
# Download the NCBI taxa dump files
NCBI's taxonomy database has a few files associated with it. Because GitHub
doesn't like hosting big files, you need to download these manually and 
move them in to the package folder. Download the 
[dmp files] (https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/)

The files come as compressed tar or tar.gz files. Extract the files from 
within the terminal
```bash
gunzip -c taxdump.tar.gz | tar xf -
```
The package relies on the names.dmp and nodes.dmp files to pull 
taxonomic information. These files now need to be moved to 
the inst/extdata folder of the NCBI.Wielder
package. 

To find the full path to that folder from within R execute the command:
 ```r
system.file("extdata/GetLineage.sh",package="NCBIwielder")%>%
  gsub(pattern = "GetLineage.sh",replacement="")
```
Now you can copy those files to the extdata/ folder of the NCBI.Wielder
package. In R you could do this by

 ```r
Path2Save<-system.file("extdata/GetLineage.sh",package="NCBIwielder")%>%
  gsub(pattern = "GetLineage.sh",replacement="")
Path2names<- Insert the filepath to names.dmp
Path2nodes <- Insert the filepath to nodes.dmp 
Cmd2Use<-paste("cp",Path2names,Path2Save)
system(Cmd2Use)
Cmd2Use<-paste("cp",Path2nodes,Path2Save)
system(Cmd2Use)
```

Along with the .dmp files is a taxdump_readme.txt
file that explains how to extract the files and 
gives detailed information about the contents. You should 
definately take a look and understand a bit about how the 
files are structured. 

My list of things to do:
* When pulling taxonomy get the correct species name instead of the first hit for the taxa ID in GetLineage.sh
* Add the option to save all the acc. numbers when we find.seqs()
* Figure out the passing of commands to the windows subsystem for linux. 
