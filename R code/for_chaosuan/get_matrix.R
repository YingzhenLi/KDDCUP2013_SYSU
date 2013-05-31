

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
#####get topic models###

# aff_col[order(col_sums(aff_dtm),decreasing=T)[1:50]]
dist_aff_dtm <- as.matrix(dissimilarity(aff_dtm[1:10,], method = 'cosine'))
save(dist_aff_dtm,file="dist_aff_dtm.rda")
aff_mat=get.auau.distMat(author,dist_aff_dtm)  #this matrix is consistent with the first one
save(aff_mat,file="aff_mat.rda")


#author-name ambiguity  to be continued


##### the author-paper matrix ###########
##### using the confirmed, deleted, paperauthor dataset #####

confirmMat=get.aut_pap(trainconfirmed,author,paper,v=1)
deleteMat=get.aut_pap(traindeleted,author,paper,v=-1)
pap_autMat=get.aut_pap(paperauthor,author,paper,v=0.5)
save(confirmMat,file="confirmMat.rda")
save(deleteMat,file="deleteMat.rda")
save(pap_autMat,file="pap_autMat.rda")

######   paper_paper matrix  #####
#### journal/ conference relationship (exact relationship) #####


#pap_journal=get.papaOrg(paper,org=journal,cha="journalid")
#pap_conference=get.papaOrg(paper,org=conference,cha="conferenceid")


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


##conference-conference matrix
conf_col=get.col(comCN)
conf_Namemat=get.mat(col=conf_col,comCN)
conf_Namedtm <- as.DocumentTermMatrix(conf_Namemat,weighting =weightTf,
                                      control = list(stemming = TRUE, stopwords = TRUE,
                                                     removePunctuation = TRUE,tolower=T))

conf_col[order(col_sums(conf_Namedtm),decreasing=T)[1:50]]
#colnames(conf_Namedtm)=conf_col
nn=setdiff(1:length(conf_col),which(is.element(conf_col,c("confer","research","intern","system","workshop"))))
conf_Namedtm <- conf_Namedtm[,nn]

table(row_sums(conf_Namedtm)) 
CNonzero=which(!row_sums(conf_Namedtm)==0)
conf_Namedtm=conf_Namedtm[row_sums(conf_Namedtm)>0,]

dist_conf_Namedtm <- as.matrix(dissimilarity(conf_Namedtm , method = 'cosine'))
conf_Mat=Matrix(0,length(conference$id),length(conference$id),sparse=T)
conf_Mat[CNonzero,CNonzero]=1-dist_conf_Namedtm

save(conf_Namedtm,file="conf_Namedtm.rda")
save(dist_conf_Namedtm,file="dist_conf_Namedtm.rda")
save(conf_Mat,file="conf_Mat.rda")
### org-paper matrix ###
### using the keywords & title

jour_pap_dist=get.Org_pap.dist(comJ,com,ind,journal,paper)
conf_pap_dist=get.Org_pap.dist(comC,com,ind,conference,paper)
save(jour_pap_dist,file="jour_pap_dist")
save(conf_pap_dist,file="conf_pap_dist")

### journal-journal matrix using names and paper keys (for topicmodels)####
Jour_col=get.col(comJ)
Jour_mat=get.mat(col=Jour_col,comJ)

Jour_dtm <- as.DocumentTermMatrix(Jour_mat,weighting =weightTf,
                                  control = list(stemming = TRUE, stopwords = TRUE,
                                                 removePunctuation = TRUE,tolower=T))

#Jour_col[order(col_sums(Jour_dtm),decreasing=T)[1:50]]
nn=setdiff(1:length(Jour_col),
           which(is.element(Jour_col,c("confer","research","intern","system","workshop",
                                       "research","intern","system","method",
                                       "using","analysis","systems","system",
                                       "model","study","experiment","approach","method"))))
Jour_col[order(col_sums(Jour_dtm))[1:50]]
Jour_dtm <- Jour_dtm[,nn]
#table(row_sums(Jour_dtm)) 
Jour_dtm=Jour_dtm[row_sums(Jour_dtm)>0,]
save(Jour_dtm,file="Jour_dtm.rda")

####conf-conf using names and paper keys for topicmodels ###

Conf_col=get.col(comC)
Conf_mat=get.mat(col=Conf_col,comC)

Conf_dtm <- as.DocumentTermMatrix(Conf_mat,weighting =weightTf,
                                  control = list(stemming = TRUE, stopwords = TRUE,
                                                 removePunctuation = TRUE,tolower=T))

#Conf_col[order(col_sums(Conf_dtm),decreasing=T)[1:50]]
nn=setdiff(1:length(Conf_col),
           which(is.element(Conf_col,c("confer","research","intern","system","workshop",
                                       "research","intern","system","method",
                                       "using","analysis","systems","system",
                                       "model","study","experiment","approach","method"))))
#Conf_col[order(col_sums(Conf_dtm))[1:50]]
Conf_dtm <- Conf_dtm[,nn]
table(row_sums(Conf_dtm)) 
Conf_dtm=Conf_dtm[row_sums(Conf_dtm)>0,]
save(Conf_dtm,file="Conf_dtm.rda")

#### aff-aff matrix using 
#### positive part

res_aff=comAff(author,aff=unique(author$affiliation),
               confirmed=trainconfirmed,deleted=traindeleted,
               com_all=com_all,comA_aff=comA_aff,wei=c(2,2))
aff_pos=res_aff[[1]]
Aff_pos_col=get.col(aff_pos)
Aff_pos_mat=get.mat(col=Aff_pos_col,com_all)

Aff_pos_dtm <- as.DocumentTermMatrix(Aff_pos_mat,weighting =weightTf,
                                     control = list(stemming = TRUE, stopwords = TRUE,
                                                    removePunctuation = TRUE,tolower=T))

#Aff_pos_col[order(col_sums(Aff_pos_dtm),decreasing=T)[1:50]]
nn=setdiff(1:length(Aff_pos_col),
           which(is.element(Aff_pos_col,c("confer","research","intern","system","workshop",
                                          "research","intern","system","method",
                                          "using","analysis","systems","system",
                                          "model","study","experiment","approach","method"))))
#Aff_pos_col[order(col_sums(Aff_pos_dtm))[1:50]]
Aff_pos_dtm <- Aff_pos_dtm[,nn]
table(row_sums(Aff_pos_dtm)) ##there is no zero lines

Aff_pos_dtm=Aff_pos_dtm[row_sums(Aff_pos_dtm)>0,]
save(Aff_pos_dtm,file="Aff_pos_dtm.rda")

#### negtive part

aff_neg=res_aff[[2]]
Aff_neg_col=get.col(Aff_neg)
Aff_neg_mat=get.mat(col=Aff_neg_col,comC)
Aff_neg_dtm <- as.DocumentTermMatrix(Aff_neg_mat,weighting =weightTf,
                                     control = list(stemming = TRUE, stopwords = TRUE,
                                                    removePunctuation = TRUE,tolower=T))

#Aff_neg_col[order(col_sums(Aff_neg_dtm),decreasing=T)[1:50]]
nn=setdiff(1:length(Aff_neg_col),
           which(is.element(Aff_neg_col,c("confer","research","intern","system","workshop",
                                          "research","intern","system","method",
                                          "using","analysis","systems","system",
                                          "model","study","experiment","approach","method"))))
#Aff_neg_col[order(col_sums(Aff_neg_dtm))[1:50]]
Aff_neg_dtm <- Aff_neg_dtm[,nn]
#table(row_sums(Aff_neg_dtm)) ##there is no zero lines
Aff_neg_dtm=Aff_neg_dtm[row_sums(Aff_neg_dtm)>0,]
save(Aff_neg_dtm,file="Aff_neg_dtm.rda")


### author-author according to aff dist using aff-papers
dist_aff_pos_dtm <- as.matrix(dissimilarity(Aff_pos_dtm, method = 'cosine'))
Aut_aff_pos_mat=get.auau.distMat(author,dist_aff_pos_dtm)  
dist_aff_neg_dtm <- as.matrix(dissimilarity(Aff_neg_dtm, method = 'cosine'))
Aut_aff_neg_mat=get.auau.distMat(author,dist_aff_neg_dtm) 
save(Aut_aff_pos_mat,file="Aut_aff_pos_mat.rda")
save(Aut_aff_neg_mat,file="Aut_aff_neg_mat.rda")

### author-author using paperkeys ####
### pos part
Aut_pos=get.author.paper(data=trainconfirmed,com_all)
Aut_pos_col=get.col(Aut_pos)
Aut_pos_mat=get.mat(col=Aut_pos_col,Aut_pos)
Aut_pos_dtm <- as.DocumentTermMatrix(Aut_pos_mat,weighting =weightTf,
                                     control = list(stemming = TRUE, stopwords = TRUE,
                                                    removePunctuation = TRUE,tolower=T))

Aut_pos_col[order(col_sums(Aut_pos_dtm),decreasing=T)[1:50]]
nn=setdiff(1:length(Aut_pos_col),
           which(is.element(Aut_pos_col,c("confer","research","intern","system","workshop",
                                          "research","intern","system","method",
                                          "using","analysis","systems","system",
                                          "model","study","experiment","approach","method"))))
#Aut_pos_col[order(col_sums(Aut_pos_dtm))[1:50]]
Aut_pos_dtm <- Aut_pos_dtm[,nn]
#table(row_sums(Aut_pos_dtm)) ##there is no zero lines

Aut_pos_dtm=Aut_pos_dtm[row_sums(Aut_pos_dtm)>0,]
save(Aut_pos_dtm,file="Aut_pos_dtm.rda")

### aut_neg
Aut_neg=get.author.paper(data=traindeleted,com_all)
Aut_neg_col=get.col(Aut_neg)
Aut_neg_mat=get.mat(col=Aut_neg_col,Aut_neg)
Aut_neg_dtm <- as.DocumentTermMatrix(Aut_neg_mat,weighting =weightTf,
                                     control = list(stemming = TRUE, stopwords = TRUE,
                                                    removePunctuation = TRUE,tolower=T))

#Aut_neg_col[order(col_sums(Aut_neg_dtm),decreasing=T)[1:50]]
nn=setdiff(1:length(Aut_neg_col),
           which(is.element(Aut_neg_col,c("confer","research","intern","system","workshop",
                                          "research","intern","system","method",
                                          "using","analysis","systems","system",
                                          "model","study","experiment","approach","method"))))
#Aut_neg_col[order(col_sums(Aut_neg_dtm))[1:50]]
Aut_neg_dtm <- Aut_neg_dtm[,nn]
table(row_sums(Aut_neg_dtm)) 

Aut_neg_dtm=Aut_neg_dtm[row_sums(Aut_neg_dtm)>0,]
save(Aut_neg_dtm,file="Aut_neg_dtm.rda")

###aut-middle
Aut_middle=get.author.paper(data=paperauthor,com_all)
Aut_middle_col=get.col(Aut_middle)
Aut_middle_mat=get.mat(col=Aut_middle_col,Aut_middle)
Aut_middle_dtm <- as.DocumentTermMatrix(Aut_middle_mat,weighting =weightTf,
                                        control = list(stemming = TRUE, stopwords = TRUE,
                                                       removePunctuation = TRUE,tolower=T))

#Aut_middle_col[order(col_sums(Aut_middle_dtm),decreasing=T)[1:50]]
nn=setdiff(1:length(Aut_middle_col),
           which(is.element(Aut_middle_col,c("confer","research","intern","system","workshop",
                                             "research","intern","system","method",
                                             "using","analysis","systems","system",
                                             "model","study","experiment","approach","method"))))
#Aut_middle_col[order(col_sums(Aut_middle_dtm))[1:50]]
Aut_middle_dtm <- Aut_middle_dtm[,nn]
#table(row_sums(Aut_middle_dtm)) 
Aut_middle_dtm=Aut_middle_dtm[row_sums(Aut_middle_dtm)>0,]
save(Aut_middle_dtm,file="Aut_middle_dtm.rda")



