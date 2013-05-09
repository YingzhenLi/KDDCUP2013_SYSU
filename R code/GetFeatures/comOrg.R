
#for the journal & conference
#please run the stops.R first 

#table(paper$journalid)
journalid=unique(paper$journalid)

com_all=as.list(rep(0,nrow(paper)))
com_all[ind]=com

comOrg<-function(paper,com_all,orgid,allid)
{
  comO=list()
  for (i in 1:length(orgid))
  {
    show(i)
    id=which(allid==orgid[i])
    #show(id)
    a=unlist(com_all[id])
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
comJ=comOrg(paper,com_all,orgid=journalid,allid=paper$journalid)

sum(unlist(lapply(comJ,is.null)))





