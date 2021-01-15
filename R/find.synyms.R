#' Find species synonyms
#'
#' This function facilitates the search of NCBIs taxonomy db to find species synonyms
#' @param Species A vector of species names.
#' @keywords NCBI taxonomy species synonyms
#' @export
#' @examples
#' find.synyms()

find.synyms<-function(Species, ...){
  
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
      
  }
  GoodTaxa<-which(!is.na(TaxaIDs))


SpNames<-list()

for (s in GoodTaxa){
  cmd <- paste("grep '^",TaxaIDs[s],"\\s|' ",system.file("extdata/names.dmp",package="NCBI.Wielder",lib.loc=NULL,mustWork=TRUE),sep="")
  SpNameTemp <- system(cmd, intern=T, wait=T)
  SpNames[[s]]<-SpNameTemp%>%
    grep(x=., "scientific name|synonym",value=T)%>%
    str_split(string=.,pattern="\t|\t")%>%
    lapply(.,"[[",3)%>%
    unlist() %>%
    paste(.,collapse="|")
}

if(length(SpNames)>1 && any(lapply(SpNames,length)==0)){
    SpNames[[which(lapply(SpNames,length)==0)]]<-"No taxonomic information in NCBI"
}

SynInfo<-cbind(Species,TaxaIDs,unlist(SpNames))
colnames(SynInfo)<-c("Species","TaxaIDs","Synonyms")
   
return(SynInfo)

}
