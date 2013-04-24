
extract<-function(word,gregout,i)
{
  return(substr(word[i],gregout[[i]],gregout[[i]]+attr(gregout[[i]],'match.length')-1))
}

###extract university info #####
author$university=""
hav_u=grep("([\\sA-Za-z])*[Uu]niversity([\\sA-Za-z])*",author$affiliation,perl=T)
uu=gregexpr("([\\sA-Za-z])*[Uu]niversity([\\sA-Za-z])*",author$affiliation[hav_u],perl=T)
word=author$affiliation[hav_u]
u=unlist(lapply(1:length(word),extract,word=word,gregout=uu))
author$university[hav_u]=u

###extract department info ####

author$department=""
hav_d=grep("([\\sA-Za-z])*[Dd]epartment([\\sA-Za-z])*",author$affiliation,perl=T)
dd=gregexpr("([\\sA-Za-z])*[Dd]epartment([\\sA-Za-z])*",author$affiliation[hav_d],perl=T)
word=author$affiliation[hav_d]
d=unlist(lapply(1:length(word),extract,word=word,gregout=dd))
author$department[hav_d]=d


