
#for the journal & conference
#please run the stops.R first 

source("~/KDDCUP2013_SYSU/R\ code/GetFeatures/functions.R")
setwd("~/kdd_data/rda")
### run the comOrg.R first
comJ=comOrg(paper,com_all,orgid=unique(journal$id),allid=paper$journalid,onlyname=F,comN=comJN)
comC=comOrg(paper,com_all,orgid=unique(conference$id),allid=paper$conferenceid,onlyname=F,comN=comCN)
save(comJ,file="comJ.rda")
save(comC,file="comC.rda")

#####author-author with other info using text mining #####
author$affiliation=as.character(author$affiliation)
aff=unique(author$affiliation[author$affiliation!=""])
A_aff=deNoise(aff)

#remove the department name
A_aff=lapply(A_aff,function(x) x=x[grepl("([\\sa-z])*((univers|univ)|(depart|dept.*)|(lab)|(school)|(instit|inst.*)|(resear)|(center)|(nation))([\\sa-z])*",
                                         x,perl=T)==F])
comA_aff=lapply(A_aff,function(x) x=table(x[x!=""]))
save(comA_aff,file="comA_aff.rda")









