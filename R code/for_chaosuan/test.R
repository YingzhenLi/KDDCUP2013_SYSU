

source("~/KDDCUP2013_SYSU/R\ code/GetFeatures/functions.R")
setwd("~/kdd_data/rda")
author=author[1:1000,]
#####author-author with other info using text mining #####
author$affiliation=as.character(author$affiliation)
aff=unique(author$affiliation[author$affiliation!=""])
system.time((A_aff=deNoise(aff)))

#remove the department name
A_aff=lapply(A_aff,function(x) x=x[grepl("([\\sa-z])*((univers|univ)|(depart|dept.*)|(lab)|(school)|(instit|inst.*)|(resear)|(center)|(nation))([\\sa-z])*",
                                         x,perl=T)==F])
comA_aff=lapply(A_aff,function(x) x=table(x[x!=""]))
save(comA_aff,file="comA_aff.rda")
