
#for the journal & conference
#please run the stops.R first 

#table(paper$journalid)
load("F:/kdd/2013 kdd/rda/stops.rda")
load("F:/kdd/2013 kdd/rda/journal.rda")
journalid=unique(journal$id)

comOrg<-function(paper,com_all,orgid,allid,comN)
{
  comO=list()
  for (i in 1:length(orgid))
  {
    show(i)
    id=which(allid==orgid[i])
    #show(id)
    a=c(unlist(com_all[id]),comN[[i]])
    name=unique(names(a))
    
    name=name[name!=""]
    #show(name)
    if (length(name)==0) comO[[i]]=0
    else
    {
      c=unlist(lapply(name,function(x) sum(a[x])))
      names(c)=name
      comO[[i]]=c
    }
  }
  return(comO)
}
comJ=comOrg(paper,com_all,orgid=unique(journal$id),allid=paper$journalid,comN=comJN)
comC=comOrg(paper,com_all,orgid=unique(conference$id),allid=paper$conferenceid,comN=comCN)



# 3/4 affiliations are missing
# for the confirmed first
comAff<-function(author,aff,confirmed,deleted,com_all,comA_aff,wei=c(2,2))
{
  res=list()

  for (i in 1:length(aff))
  {
#    show(i)
    authorid=author$id[author$affiliation==aff[i]]
#    show(authorid)
    confirmed_paperid=trainconfirmed$paperid[
      is.element(trainconfirmed$authorid,authorid)]
    deleted_paperid=traindeleted$paperid[
      is.element(traindeleted$authorid,authorid)]
#    pa_authorid=which(is.element(paperauthor$authorid,authorid))
#    pa_authorid=paperauthor$authorid[
#      paperauthor$affiliation==aff[i]]
    pa_paperid=paperauthor$paperid[
      which(is.element(paperauthor$authorid,authorid))]
    ind1=is.element(paper$id,confirmed_paperid)
    ind2=is.element(paper$id,deleted_paperid)
    ind3=is.element(paper$id,pa_paperid)
    
    a1=c(unlist(com_all[ind1]),comA_aff[[i]])
#    show(a1)
    a2=unlist(com_all[ind2])
    a=list(c(a1*wei[1],a3))
    a3=unlist(com_all[ind3])
    a[[2]]=c(a2*wei[2],a3)
    name=list(unique(names(a[[1]])),unique(names(a[[2]])))
    name=lapply(name,function(x) x=x[x!=""])
#    show(a)
#    show(name)
    aa=list()
    for (j in 1:2)
    {
#      show(j)
      if (length(name[[j]])==0)
      {
        aa[[j]]=0
        if (j==2) show(i)
      }
      else
      {
        c=unlist(lapply(name[[j]],function(x) sum(a[[j]][x])))
        names(c)=name[[j]]
        aa[[j]]=c
      }
    }
    res[[i]]=aa
  }
  pos=lapply(res,function(x) x=x[[1]])
  neg=lapply(res,function(x) x=x[[2]])
  return(list(pos=pos,neg=neg))
}

res_aff=comAff(author,aff=aff,
           confirmed=trainconfirmed,deleted=traindeleted,
           com_all=com_all,comA_aff=comA_aff,wei=c(2,2))




