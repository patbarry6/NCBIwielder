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
#' Find.records()

Find.records<-function(Species=c("Atheresthes evermanni","Atheresthes stomias"),
                       Loci=c("Cytb","cytochrome b", "dloop","d loop",
                              "control region", "CR", "COI","COXI",
                              "CO1","COII","COIII","16S","12S","ND5","ND3"),
                       LengthRange="100:20000",
                       LociGrps=list(1:2,3:6,7:9,10,11,12,13,14,15), ...){

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

      for (s in 1:length(Species)){
        LociCts<-vector()
        for (L in 1:length(unlist(Loci[[l]]))){
        cmd<-paste('esearch -db nucleotide -query "',
                   Loci[[l]][L]," ",LengthRange,
                 ' [SLEN] ',
                 Species[s],' [ORGN]" | grep "Count"',sep="")
        LociCts[L]<-system(cmd,intern=T,wait=T) %>%
          gsub(pattern = "<Count>|</Count>",replacement="",x=.) %>%
          str_trim()%>%
          as.numeric()
        } #over L loci grouped
        SpCts[s]<-sum(as.numeric(LociCts),na.rm=F)
        cat(paste("\t",Species[s],"\n",sep=""))
      } # over s species
    LocusList[[l]]<-SpCts
    } #over l loci

  res<-cbind(Species,do.call(cbind,LocusList))
  colnames(res)<-c("Species",LociNames)
  return(res)
  }
