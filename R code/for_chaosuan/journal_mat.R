
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


## journal-journal matrix
## using only names
## run the Orgnames.R first 

journal_col=get.col(comJN)
journal_Namemat=get.mat(col=journal_col,comJN)
journal_Namedtm <- as.DocumentTermMatrix(journal_Namemat,weighting =weightTf,
                                         control = list(stemming = TRUE, stopwords = TRUE,
                                                        removePunctuation = TRUE,tolower=T))

#journal_col[order(col_sums(journal_Namedtm),decreasing=T)[1:50]]

nn=setdiff(1:length(journal_col),which(is.element(journal_col,
                                                  c("journal","research","intern","system","method"))))
#journal_col[order(col_sums(journal_Namedtm))[1:50]]
journal_Namedtm <- journal_Namedtm[,nn]
#table(row_sums(journal_Namedtm)) ##there is no zero lines
JNonzero=which(!row_sums(journal_Namedtm)==0)
journal_Namedtm=journal_Namedtm[row_sums(journal_Namedtm)>0,]
dist_journal_Namedtm <- as.matrix(dissimilarity(journal_Namedtm , method = 'cosine'))
journal_Mat=Matrix(0,length(journal$id),length(journal$id),sparse=T)
journal_Mat[JNonzero,JNonzero]=1-dist_journal_Namedtm


save(journal_Namedtm,file="journal_Namedtm.rda")
save(dist_journal_Namedtm,file="ddist_journal_Namedtm.rda")
save(journal_Mat,file="journal_Mat.rda")
