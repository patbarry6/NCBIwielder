#' Pull nucleotide sequences from NCBI nucleotide database
#'
#' This function facilitates the download of NCBIs nucleotide db
#' @param Species A vector of species names.
#' @param Loci A vector of loci to search.
#' @param LociGrps A list of how to group the loci if you want to search multiple names for the same locus (ie. COI, COXI, cytochrome oxidase I)
#' @param Length range for sequences to keep default is 100:20000
#' @keywords NCBI nucleotide
#' @export
#' @examples
#' pull_seqs()

pull_seqs<-function(Species,
                         Loci,
                         LengthRange="100:20000",
                         LociGrps,...){

  if(is.list(LociGrps)){
    GrpLoci=T
  } else {
    GrpLoci=T
  }

  #Clean up the objects
  Species <- Species %>%
    str_trim()
  Loci <- Loci %>%
    str_trim

  #convert loci to list and group the loci by name if you want
  if(GrpLoci==F){
    Loci<-as.list(Loci)
  } else if (GrpLoci==T){
    Loci<-lapply(LociGrps,function(x) Loci[x])
  }

  LociNames<-lapply(Loci,"[[",1) %>% gsub(pattern="\\s+",replacement="",x=.)
  names(Loci)<-LociNames


  for (l in 1:length(LociNames)){
    cat(paste("Working on:\n", LociNames[l],"\n ",sep=""))
    LocusList<-list()
    count<-1
     for (s in 1:length(Species)){
      SpSeqs<-list()
      for (L in 1:length(unlist(Loci[[l]]))){
        cmd<-paste('esearch -db nucleotide -query "',
                   Loci[[l]][L],' [ALL] ',
                   Species[s],' [ORGN] ',
                   LengthRange,' [SLEN]" | efetch -format fasta',sep="")
        LocusList[[count]]<-system(cmd,intern=T,wait=T)
        count<-count+1
      } #over L loci grouped
      cat(paste("\t",Species[s],"\n",sep=""))
    } # over s species
    writeLines(text=unlist(LocusList),con=paste("NCBI_",LociNames[l],".fasta",sep="")) #write out the locus fasta file
    cat(paste("Fasta file written for locus ",LociNames[l],"\n",sep=""))

  #now becuase we didn't store acc. numbers for each locus that may sound similar
  #we need to remove the duplicates
  cmd <- paste("bash",
    system.file("extdata/RmDupLines.sh",package="NCBIwielder",lib.loc=NULL,mustWork=TRUE),
    paste("NCBI_",LociNames[l],".fasta",sep=""),sep=" ")
 system(cmd,wait=T)


  } #over l loci
}
