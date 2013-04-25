
###### this section just help to observe the data. Ignore it if you don't like #####
#####                try to split the affiliations             #####################
#####          to observe the word frequencies                ######################
aff_spl=strsplit(as.character(author$affiliation),"[,|/;]",perl=T)
aff_len=unlist(lapply(aff_spl,length))
a=unlist(aff_spl)
b=unlist(strsplit(a," "))
b_first=substr(b,1,1)
table(b[b_first=="s"|b_first=="S"])
####help to check the first & last word ####
get.word<-function(word,n=1,end=F)
{
  if (end==F)
  {return(word[n])}
  else
    return(word[length(word)])
}

c=unlist(lapply(b,get.word,n=1,end=F))
c_f=table(c)
b_f=table(unlist(b))
c_f[c_f>1]
##########could add other methods to observe ##############
###########################################################

######### to extract attributes of the affiliation ######

extract<-function(word,gregout,i)
{
  return(substr(word[i],gregout[[i]],gregout[[i]]+attr(gregout[[i]],'match.length')-1))
}

###extract university info #####
author$university=""
hav_u=grep("([\\sA-Za-z])*(universi|Univ)([\\sA-Za-z])*",author$affiliation,perl=T,ignore.case=T)
uu=gregexpr("([\\sA-Za-z])*(universi|Univ)([\\sA-Za-z])*",author$affiliation[hav_u],perl=T,ignore.case=T)
word=author$affiliation[hav_u]
u=unlist(lapply(1:length(word),extract,word=word,gregout=uu))
author$university[hav_u]=u

###extract department info ####

author$department=""
hav_d=grep("([\\sA-Za-z])*(depart|dept.*)([\\sA-Za-z])*",author$affiliation,perl=T,ignore.case=T)
dd=gregexpr("([\\sA-Za-z])*(depart|dept.*)([\\sA-Za-z])*",author$affiliation[hav_d],perl=T,ignore.case=T)
word=author$affiliation[hav_d]
d=unlist(lapply(1:length(word),extract,word=word,gregout=dd))
author$department[hav_d]=d

###extract Laboratory info ####

author$laboratory=""
hav_l=grep("([\\sA-Za-z])*lab([\\sA-Za-z])*",author$affiliation,perl=T,ignore.case=T)
ll=gregexpr("([\\sA-Za-z])*lab([\\sA-Za-z])*",author$affiliation[hav_l],perl=T,ignore.case=T)
word=author$affiliation[hav_l]
l=unlist(lapply(1:length(word),extract,word=word,gregout=ll))
author$laboratory[hav_l]=l

###extract school info #####

author$school=""
hav_s=grep("([\\sA-Za-z])*school([\\sA-Za-z])*",author$affiliation,perl=T,ignore.case=T)
ss=gregexpr("([\\sA-Za-z])*school([\\sA-Za-z])*",author$affiliation[hav_s],perl=T,ignore.case=T)
word=author$affiliation[hav_s]
s=unlist(lapply(1:length(word),extract,word=word,gregout=ss))
author$laboratory[hav_s]=s

###extract Institute info #####
author$institute=""
hav_i=grep("([\\sA-Za-z])*(instit|inst.*)([\\sA-Za-z])*",author$affiliation,perl=T,ignore.case=T)
ii=gregexpr("([\\sA-Za-z])*(instit|inst.*)([\\sA-Za-z])*",author$affiliation[hav_i],perl=T)
word=author$affiliation[hav_i]
i=unlist(lapply(1:length(word),extract,word=word,gregout=ii))
author$institute[hav_i]=i










