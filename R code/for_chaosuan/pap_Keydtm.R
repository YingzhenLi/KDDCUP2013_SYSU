

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

##run the keywords.R title.R combine_features.R first ####

pap_col=get.col(com)
pap_Keymat=get.mat(col=pap_col,com)

pap_Keydtm <- as.DocumentTermMatrix(pap_Keymat,weighting =weightTf,
                                    control = list(stemming = TRUE, stopwords = TRUE,
                                                   removePunctuation = TRUE,tolower=T))

#pap_col[order(col_sums(pap_Keydtm),decreasing=T)[1:50]]
#colnames(pap_Keydtm)=pap_col
nn=setdiff(1:length(pap_col),which(is.element(pap_col,c("using","analysis","systems","system",
                                                        "model","study","experiment","approach","method"))))

com_ind=c(which(unlist(lapply(com,function(x) !all(x==0)))),ind)
table(row_sums(pap_Keydtm)) ##there is no zero lines
com_Nonzero=com_ind[which(!row_sums(pap_Keydtm)==0)]
pap_Keydtm=pap_Keydtm[row_sums(pap_Keydtm)>0,]


#table(row_sums(pap_Keydtm)) ##there is no zero lines
dist_pap_Keydtm <- as.matrix(dissimilarity(pap_Keydtm , method = 'cosine'))
pap_Mat=Matrix(0,length(paper$id),length(paper$id),sparse=T)
pap_Mat[ind,ind]=1-dist_pap_Keydtm

save(pap_Keydtm,file="pap_Keydtm.rda")
save(dist_pap_Keydtm,file="dist_pap_Keydtm.rda")
save(pap_Mat,file="pap_Mat.rda")
