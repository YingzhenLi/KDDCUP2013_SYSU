


setwd("~/kdd_data/rda")
source("~/KDDCUP2013_SYSU/R\ code/GetFeatures/functions.R")
load("com.rda")
load("com_all.rda")
load("comJN.rda")
load("comCN.rda")
load("comJ.rda")
load("comC.rda")
load("comA_aff.rda")
##try to build the model using sparse matrix
##  author with the same affiliation (exact relationship) ##

##### the author-paper matrix ###########
##### using the confirmed, deleted, paperauthor dataset #####

confirmMat=get.aut_pap(trainconfirmed,author,paper,v=1)
deleteMat=get.aut_pap(traindeleted,author,paper,v=-1)
pap_autMat=get.aut_pap(paperauthor,author,paper,v=0.5)
save(confirmMat,file="confirmMat.rda")
save(deleteMat,file="deleteMat.rda")
save(pap_autMat,file="pap_autMat.rda")


