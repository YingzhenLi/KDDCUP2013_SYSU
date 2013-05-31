source("functions.R")

### global variables
SEED <- 2013

### select K according to the mean of loglik and perplexity
### the CTM is employed for the criterion

### paper-paper using topic models ###
load("pap_Keydtm.rda")
sp=smp(5,nrow(pap_Keydtm),seed=1024)
gibK_pap=selectK(dtm=pap_Keydtm,k=k,SEED=SEED,cross=5,smp=sp)
save(gibK_pap,file="gibK_pap.rda")
TM_pap=get.topic(dtm=pap_Keydtm,k=seq(10,200,10),SEED=2013,cross=5,gibK=gibK_pap)
save(TM_pap,file="TM_pap.rda")
dist_pap_CTM=as.matrix(daisy(posterior(TM_pap[["CTM"]])[[2]]))
save(dist_pap_CTM,file="dist_pap_CTM.rda")

### journal-journal using topic matrix
load("Jour_dtm.rda")
sp=smp(5,nrow(Jour_dtm),seed=1024)
gibK_jour=selectK(dtm=Jour_dtm,k=k,SEED=SEED,cross=5,smp=sp)
save(gibK_jour,file="gibK_jour.rda")
TM_jour=get.topic(dtm=jour_Keydtm,k=seq(10,200,10),SEED=2013,cross=5,gibK=gibK_jour)
save(TM_jour,file="TM_jour.rda")
dist_jour_CTM=as.matrix(daisy(posterior(TM_jour[["CTM"]])[[2]]))
save(dist_jour_CTM,file="dist_jour_CTM.rda")

### conf-conf using topic models
load("Conf_dtm.rda")
sp=smp(5,nrow(Conf_dtm),seed=1024)
gibK_Conf=selectK(dtm=Conf_dtm,k=k,SEED=SEED,cross=5,smp=sp)
save(gibK_Conf,file="gibK_Conf.rda")
TM_Conf=get.topic(dtm=Conf_Keydtm,k=seq(10,200,10),SEED=2013,cross=5,gibK=gibK_Conf)
save(TM_Conf,file="TM_Conf.rda")
dist_Conf_CTM=as.matrix(daisy(posterior(TM_Conf[["CTM"]])[[2]]))
save(dist_Conf_CTM,file="dist_Conf_CTM.rda")

### aff-aff using author papers


### Org names using topic models
### aff using topicmodels #####
load("Aff_pos_dtm.rda")
load("Aff_neg_dtm.rda")
### positive part
sp=smp(5,nrow(Aff_pos_dtm),seed=1024)
gibK_Aff_pos=selectK(dtm=Aff_pos_dtm,k=k,SEED=SEED,cross=5,smp=sp)
save(gibK_Aff_pos,file="gibK_Aff_pos.rda")
TM_Aff_pos=get.topic(dtm=Aff_pos_Keydtm,k=seq(10,200,10),SEED=2013,cross=5,gibK=gibK_Aff_pos)
save(TM_Aff_pos,file="TM_Aff_pos.rda")
dist_Aff_pos_CTM=as.matrix(daisy(posterior(TM_Aff_pos[["CTM"]])[[2]]))
save(dist_Aff_pos_CTM,file="dist_Aff_pos_CTM.rda")

### negative part
sp=smp(5,nrow(Aff_neg_dtm),seed=1024)
gibK_Aff_neg=selectK(dtm=Aff_neg_dtm,k=k,SEED=SEED,cross=5,smp=sp)
save(gibK_Aff_neg,file="gibK_Aff_neg.rda")
TM_Aff_neg=get.topic(dtm=Aff_neg_Keydtm,k=seq(10,200,10),SEED=2013,cross=5,gibK=gibK_Aff_neg)
save(TM_Aff_neg,file="TM_Aff_neg.rda")
dist_Aff_neg_CTM=as.matrix(daisy(negterior(TM_Aff_neg[["CTM"]])[[2]]))
save(dist_Aff_neg_CTM,file="dist_Aff_neg_CTM.rda")


Aut_aff_Tpos_mat=get.auau.distMat(author,dist_Aff_pos_CTM) 
Aut_aff_Tneg_mat=get.auau.distMat(author,dist_aff_neg_CTM) 
save(Aut_aff_Tpos_mat,file="Aut_aff_pos_mat.rda")
save(Aut_aff_Tneg_mat,file="Aut_aff_neg_mat.rda")




### author-author matrix using topicmodels 
### including paper keys of confirmed, deleted, paperauthor
load("Aut_pos_dtm.rda")
load("Aut_neg_dtm.rda")
load("Aut_middle_dtm.rda")

### positive part
sp=smp(5,nrow(Aut_pos_dtm),seed=1024)
gibK_Aut_pos=selectK(dtm=Aut_pos_dtm,k=k,SEED=SEED,cross=5,smp=sp)
save(gibK_Aut_pos,file="gibK_Aut_pos.rda")
TM_Aut_pos=get.topic(dtm=Aut_pos_Keydtm,k=seq(10,200,10),SEED=2013,cross=5,gibK=gibK_Aut_pos)
save(TM_Aut_pos,file="TM_Aut_pos.rda")
dist_Aut_pos_CTM=as.matrix(daisy(negterior(TM_Aut_pos[["CTM"]])[[2]]))
save(dist_Aut_pos_CTM,file="dist_Aut_pos_CTM.rda")

### negative part
sp=smp(5,nrow(Aut_neg_dtm),seed=1024)
gibK_Aut_neg=selectK(dtm=Aut_neg_dtm,k=k,SEED=SEED,cross=5,smp=sp)
save(gibK_Aut_neg,file="gibK_Aut_neg.rda")
TM_Aut_neg=get.topic(dtm=Aut_neg_Keydtm,k=seq(10,200,10),SEED=2013,cross=5,gibK=gibK_Aut_neg)
save(TM_Aut_neg,file="TM_Aut_neg.rda")
dist_Aut_neg_CTM=as.matrix(daisy(negterior(TM_Aut_neg[["CTM"]])[[2]]))
save(dist_Aut_neg_CTM,file="dist_Aut_neg_CTM.rda")

### middle part
sp=smp(5,nrow(Aut_middle_dtm),seed=1024)
gibK_Aut_middle=selectK(dtm=Aut_middle_dtm,k=k,SEED=SEED,cross=5,smp=sp)
save(gibK_Aut_middle,file="gibK_Aut_middle.rda")
TM_Aut_middle=get.topic(dtm=Aut_middle_Keydtm,k=seq(10,200,10),SEED=2013,cross=5,gibK=gibK_Aut_middle)
save(TM_Aut_middle,file="TM_Aut_middle.rda")
dist_Aut_middle_CTM=as.matrix(daisy(middleterior(TM_Aut_middle[["CTM"]])[[2]]))
save(dist_Aut_middle_CTM,file="dist_Aut_middle_CTM.rda")




