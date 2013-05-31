
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

#auau_aff=get.auau(author)
aff_col=get.col(comA_aff)
aff_mat=get.mat(aff_col,comA_aff)
aff_dtm <- as.DocumentTermMatrix(aff_mat,weighting =weightTf,
                                 control = list(stemming = TRUE, stopwords = TRUE,
                                                removePunctuation = TRUE,tolower=T))

save(aff_dtm,file="aff_dtm.rda")