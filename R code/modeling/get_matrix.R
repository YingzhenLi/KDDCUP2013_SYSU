
library(slam)
##try to build the model using sparse matrix
##  author with the same affiliation (exact relationship) ##

#auau_aff=get.auau(author)

#####author-author with other info using text mining #####
author$affiliation=as.character(author$affiliation)
aff=unique(author$affiliation[author$affiliation!=""])
A_aff=deNoise(aff)

#remove the department name
A_aff=lapply(A_aff,function(x) x=x[grepl("([\\sa-z])*((univers|univ)|(depart|dept.*)|(lab)|(school)|(instit|inst.*)|(resear)|(center)|(nation))([\\sa-z])*",
                                         x,perl=T)==F])
comA_aff=lapply(A_aff,function(x) x=table(x[x!=""]))


aff_col=get.col(comA_aff)
aff_mat=get.mat(aff_col,comA_aff)
aff_dtm <- as.DocumentTermMatrix(aff_mat,weighting =weightTf,
                             control = list(stemming = TRUE, stopwords = TRUE,
                                            removePunctuation = TRUE,tolower=T))

# aff_col[order(col_sums(aff_dtm),decreasing=T)[1:50]]
dist_aff_dtm <- as.matrix(dissimilarity(aff_dtm, method = 'cosine'))

aff_mat=get.auau.distMat(author,dist_aff_dtm)  #this matrix is consistent with the first one



#author-name ambiguity  to be continued


##### the author-paper matrix ###########
##### using the confirmed, deleted, paperauthor dataset #####

confirmMat=get.aut_pap(trainconfirmed,author,paper,v=1)
deleteMat=get.aut_pap(traindeleted,author,paper,v=-1)
pap_autMat=get.aut_pap(paperauthor[1:1000,],author,paper,v=0.5)

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

pap_col[order(col_sums(pap_Keydtm),decreasing=T)[1:50]]
#colnames(pap_Keydtm)=pap_col
nn=setdiff(1:length(pap_col),which(is.element(pap_col,c("using","analysis","systems","system",
                                                        "model","study","experiment","approach","method"))))

com_ind=c(which(unlist(lapply(com,function(x) !all(x==0)))),ind)
table(row_sums(pap_Keydtm)) ##there is no zero lines
com_Nonzero=com_ind[which(!row_sums(pap_Keydtm)==0)]
pap_Keydtm=pap_Keydtm[row_sums(pap_Keydtm)>0,]

#table(row_sums(pap_Keydtm)) ##there is no zero lines
dist_pap_Keydtm <- as.matrix(dissimilarity(pap_Keydtm , method = 'cosine'))
pap_Mat=simple_triplet_zero_matrix(length(paper$id),length(paper$id))
pap_Mat[ind,ind]=1-dist_pap_Keydtm

## journal-journal matrix
## using only names
## run the Orgnames.R first 

journal_col=get.col(comJN)
journal_Namemat=get.mat(col=journal_col,comJN)

journal_Namedtm <- as.DocumentTermMatrix(journal_Namemat,weighting =weightTf,
                                         control = list(stemming = TRUE, stopwords = TRUE,
                                                        removePunctuation = TRUE,tolower=T))

journal_col[order(col_sums(journal_Namedtm),decreasing=T)[1:50]]

nn=setdiff(1:length(journal_col),which(is.element(journal_col,c("journal","research","intern","system","method"))))

journal_col[order(col_sums(journal_Namedtm))[1:50]]

journal_Namedtm <- journal_Namedtm[,nn]

table(row_sums(journal_Namedtm)) ##there is no zero lines
JNonzero=which(!row_sums(journal_Namedtm)==0)
journal_Namedtm=journal_Namedtm[row_sums(journal_Namedtm)>0,]

dist_journal_Namedtm <- as.matrix(dissimilarity(journal_Namedtm , method = 'cosine'))
journal_Mat=simple_triplet_zero_matrix(length(journal$id),length(journal$id))
journal_Mat[JNonzero,JNonzero]=1-dist_journal_Namedtm



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
conf_Mat=simple_triplet_zero_matrix(length(conference$id),length(conference$id))
conf_Mat[CNonzero,CNonzero]=1-dist_conf_Namedtm

### org-paper matrix ###
### using the keywords & title
### run the comOrg.R first
comJ=comOrg(paper,com_all,orgid=unique(journal$id),allid=paper$journalid,onlyname=F,comN=comJN)
comC=comOrg(paper,com_all,orgid=unique(conference$id),allid=paper$conferenceid,onlyname=F,comN=comCN)

jour_pap_dist=get.Org_pap.dist(comJ,com,ind,journal,paper)
conf_pap_dist=get.Org_pap.dist(comC,com,ind,conference,paper)


