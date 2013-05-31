
load("journal_Mat.rda")
load("dist_jour_CTM.rda")
load("conf_Mat.rda")
load("dist_Conf_CTM.rda")


## the paper-paper Matrix
## paper-paper matrix using the paper keywords and title
### pap_Mat

## paper-author * author-paper ###
Pap_Aut_Pap_Mat=Pap_Aut_Mat%*%t(Pap_Aut_Mat)


## 1 paper-journal * journal-paper
## 2 paper-journal * journal-journal * journal-paper
Pap_Jour_Pap_Mat=t(jour_pap_dist)%*%jour_pap_dist
Pap_JJ_Pap_Mat=t(jour_pap_dist)%*%journal_Mat%*%jour_pap_dist

Pap_JTJ_Pap_Mat=t(jour_pap_dist)%*%dist_jour_CTM%*%jour_pap_dist


## 1 paper-conf * conf-paper
## 2 paper-conf * conf-conf * conf-paper
Pap_Conf_Pap_Mat=t(conf_pap_dist)%*%conf_pap_dist
Pap_CC_Pap_Mat=t(conf_pap_dist)%*%conf_Mat%*%conf_pap_dist
Pap_CTC_Pap_Mat=t(conf_pap_dist)%*%dist_Conf_CTM%*%conf_pap_dist

## matrix calculation 
### the author-author matrix ####
## the coauthor matrix ###
Pap_Aut_Mat=confirmMat+deleteMat+pap_autMat
CoAut_Mat=t(Pap_Aut_Mat)%*%Pap_Aut_Mat
Aut_Pap_Aut_Mat=t(Pap_Aut_Mat)%*%pap_Mat%*%Pap_Aut_Mat
Aut_PAP_Aut_Mat=t(Pap_Aut_Mat)%*%Pap_Aut_Pap_Mat%*%Pap_Aut_Mat
Aut_PJP_Aut_Mat=t(Pap_Aut_Mat)%*%Pap_Jour_Pap_Mat%*%Pap_Aut_Mat
Aut_PJJP_Aut_Mat=t(Pap_Aut_Mat)%*%Pap_JJ_Pap_Mat%*%Pap_Aut_Mat
Aut_PCP_Aut_Mat=t(Pap_Aut_Mat)%*%Pap_Conf_Pap_Mat%*%Pap_Aut_Mat
Aut_PCCP_Aut_Mat=t(Pap_Aut_Mat)%*%Pap_CC_Pap_Mat%*%Pap_Aut_Mat


Aut_PT_Aut_Mat=t(Pap_Aut_Mat)%*%dist_pap_CTM%*%Pap_Aut_Mat
Aut_PJTJP_Aut_Mat=t(Pap_Aut_Mat)%*%Pap_JTJ_Pap_Mat%*%Pap_Aut_Mat
Aut_PCTCP_Aut_Mat=t(Pap_Aut_Mat)%*%Pap_CTC_Pap_Mat%*%Pap_Aut_Mat


## the AuAuAffMat ###
## aut-aut using the aff names
### aff_mat

####get the features

## author-paper paper-paper
PAP=Pap_Aut_Mat%*%pap_Mat
PAPAP=Pap_Aut_Mat%*%Pap_Aut_Pap_Mat
PAPJP=Pap_Aut_Mat%*%Pap_Jour_Pap_Mat
PAPJJP=Pap_Aut_Mat%*%Pap_JJ_Pap_Mat
PAPCP=Pap_Aut_Mat%*%Pap_Conf_Pap_Mat
PAPCCP=Pap_Aut_Mat%*%Pap_CC_Pap_Mat
PATP=Pap_Aut_Mat%*%dist_pap_CTM


## author-author author-paper
AAP=aff_mat%*%t(Pap_Aut_Mat)
CoA=CoAut_Mat%*%t(Pap_Aut_Mat)
APapA=Aut_Pap_Aut_Mat%*%t(Pap_Aut_Mat)
APAPA=Aut_PAP_Aut_Mat%*%t(Pap_Aut_Mat)
APJPA=Aut_PJP_Aut_Mat%*%t(Pap_Aut_Mat)
APJJPA=Aut_PJJP_Aut_Mat%*%t(Pap_Aut_Mat)
APCPA=Aut_PCP_Aut_Mat%*%t(Pap_Aut_Mat)
APCCPA=Aut_PCCP_Aut_Mat%*%t(Pap_Aut_Mat)

AT_pos=dist_Aut_pos_CTM%*%t(Pap_Aut_Mat)
AT_neg=dist_Aut_neg_CTM%*%t(Pap_Aut_Mat)
AT_middle=dist_Aut_middle_CTM%*%t(Pap_Aut_Mat)

Aut_aff_pos_Pap=Aut_aff_pos_mat%*%t(Pap_Aut_Mat)
Aut_aff_neg_Pap=Aut_aff_neg_mat%*%t(Pap_Aut_Mat)
AT_aff_pos_Pap=Aut_aff_Tpos_mat%*%t(Pap_Aut_Mat)
AT_aff_neg_Pap=Aut_aff_Tneg_mat%*%t(Pap_Aut_Mat)



save(PAP,file="PAP.rda")
save(PAPJP,file="PAPJP.rda")
save(PAPJJP,file="PAPJJP.rda")
save(PAPCP,file="PAPCP.rda")
save(PAPCCP,file="PAPCCP.rda")
save(AAP,file="AAP.rda")
save(CoA,file="CoA.rda")
save(APapA,file="APapA.rda")
save(APapA,file="APapA.rda")
save(APAPA,file="APAPA.rda")
save(APJPA,file="APJPA.rda")
save(APJJPA,file="APJJPA,.rda")
save(APCPA,file="APCPA.rda")
save(APCCPA,file="APCCPA.rda")

save(Pap_JTJ_Pap_Mat,file="Pap_JTJ_Pap_Mat.rda")
save(Pap_JTJ_Pap_Mat,file="Pap_JTJ_Pap_Mat.rda")

save(Aut_PT_Aut_Mat,file="Aut_PT_Aut_Mat.rda")
save(Aut_PJTJP_Aut_Mat,file="Aut_PJTJP_Aut_Mat.rda")
save(Aut_PCTCP_Aut_Mat,file="Aut_PCTCP_Aut_Mat.rda")

save(PATP,file="PATP.rda")
save(AT_pos,file="AT_pos.rda")
save(AT_neg,file="AT_neg.rda")
save(AT_middle,file="AT_middle.rda")
save(Aut_aff_pos_Pap,file="Aut_aff_pos_Pap.rda")
save(Aut_aff_neg_Pap,file="Aut_aff_neg_Pap.rda")
save(AT_aff_pos_Pap,file="Aut_aff_pos_Pap.rda")
save(AT_aff_neg_Pap,file="Aut_aff_neg_Pap.rda")




