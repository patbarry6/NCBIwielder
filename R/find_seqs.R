#' Find out how many nucleotide records are in NCBIs database
#'
#' This function facilitates the search of NCBIs nucleotide db to find sequences
#' @param Species A vector of species names.
#' @param Loci A vector of loci to search.
#' @param LociGrps A list of how to group the loci if you want to search multiple names for the same locus (ie. COI, COXI, cytochrome oxidase I)
#' @param Length range for sequences to keep default is 100:20000
#' @keywords NCBI nucleotide
#' @export
#' @examples
#' find_seqs()

find_seqs<-function(Species,
                       Loci,
                       LengthRange="100:20000",
                       LociGrps, ...){

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

  LocusList<-list()
  for (l in 1:length(LociNames)){
    cat(paste("Working on:\n", LociNames[l],"\n ",sep=""))
SpCts<-vector()
      for (s in 1:length(Species)){
        LociAcc<-list()
        for (L in 1:length(unlist(Loci[[l]]))){
        cmd<-paste('esearch -db nucleotide -query "',
                    Loci[[l]][L],' [ALL] ',LengthRange,
                 ' [SLEN] ',
                 Species[s],' [ORGN]" | efetch -format acc',sep="")
        LociAcc[[L]]<-system(cmd,intern=T,wait=T)
        } #over L loci grouped
        SpCts[s]<-unlist(LociAcc)%>%unique()%>%length()
        cat(paste("\t",Species[s],"\n",sep=""))
      } # over s species
    LocusList[[l]]<-SpCts
    } #over l loci

  res<-cbind(Species,do.call(cbind,LocusList))
  colnames(res)<-c("Species",LociNames)
  
  return(res)
  
}
