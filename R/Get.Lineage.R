#' Get lineage
#'
#' This function facilitates getting the taxonomic lineage of a species
#' @param Species A character vector of species names.
#' @param NCBI_TaxaIDs A character vector of taxa IDs
#' @param GetBy either "species" or "taxaID"
#' @keywords NCBI nucleotide
#' @export
#' @examples
#' get.taxonomy()

get.taxonomy<-function(Species,NCBI_TaxaIDs,GetBy="species",...){
  
  if(GetBy=="species"){
  #Clean up the objects
  Species <- Species %>%
    str_trim()
  
  #We need to get the taxa ids first
  TaxaIDs<-vector()
  for (s in 1:length(Species)){
      cmd<-paste("grep '",Species[s],"' ",system.file("extdata/names.dmp",package="NCBI.Wielder",lib.loc=NULL,mustWork=TRUE),sep="")
      #first check to see if there is a single TAXAid
      TaxaIDall<-system(cmd,intern=T,wait=T)%>%
      str_split(., pattern="\t|\t")%>%
      lapply(.,"[[",1)%>%
      unlist() %>%
      unique()
      
      if(is.null(TaxaIDall)){
          TaxaIDs[s]<-NA
      } else if(length(TaxaIDall)==1){
          TaxaIDs[s] <- TaxaIDall
      } else if (length(TaxaIDall)>1){
          cmd<-paste("grep '",Species[s],"' ",system.file("extdata/names.dmp",package="NCBI.Wielder",lib.loc=NULL,mustWork=TRUE),sep="")
          #first check to see if there is a single TAXAid
          TaxaIDtemp<-system(cmd,intern=T,wait=T)%>%
          grep(pattern='scientific name',value=T)%>%
          str_split(., pattern="\t|\t")
          
          KeepIndex<-lapply(1:length(TaxaIDtemp),function(x) grep(TaxaIDtemp[[x]],pattern=paste("^",Species[s],"$",sep="")))%>% lapply(., nchar)
          KeepIndex<-which(KeepIndex>0)
          TaxaIDtemp<-TaxaIDtemp[[KeepIndex]][1]
          TaxaIDs[s] <- TaxaIDtemp
      }
      
      # TaxaIDs[s] <- TaxaIDtemp %>%
      #   paste(.," ",sep="") #if NCBI doesn't have a taxa we need to pad it with a space
  }
  
  GoodTaxa<-which(!is.na(TaxaIDs))
  } #if Getby == Species
  
  Lineage<-list()
  
  for (s in GoodTaxa){
    cmd <- paste("bash",
    system.file("extdata/GetLineage.sh",package="NCBI.Wielder",lib.loc=NULL,mustWork=TRUE),
    TaxaIDs[s],
    system.file("extdata/names.dmp",package="NCBI.Wielder",lib.loc=NULL,mustWork=TRUE),
    system.file("extdata/nodes.dmp",package="NCBI.Wielder",lib.loc=NULL,mustWork=TRUE),
    sep=" ")
    Lineage[[s]]<-system(cmd, intern=T, wait=T)
  } 
  
  if(length(Lineage)>1 && any(lapply(Lineage,length)==0)){
  Lineage[[which(lapply(Lineage,length)==0)]]<-"No taxonomic information in NCBI"
  }
  
  if(GetBy=="species"){
  Lineage<-cbind(Species,TaxaIDs,do.call(rbind,Lineage))
  colnames(Lineage)<-c("Species","TaxaID","Taxonomy")
  }
  if(GetBy=="taxaID"){
    Lineage<-cbind(TaxaIDs,do.call(rbind,Lineage))
  colnames(Lineage)<-c("TaxaID","Taxonomy")
  }
  
  return(Lineage)

}
