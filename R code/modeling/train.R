

train=rbind(data.frame(trainconfirmed[which(is.element(trainconfirmed$paperid,paper$id)&
                                   is.element(trainconfirmed$authorid,paperauthor$authorid)),],match=1),
            data.frame(traindeleted[which(is.element(traindeleted$paperid,paper$id)&
                                 is.element(traindeleted$authorid,paperauthor$authorid)),],match=0))



get.author.paper<-function(validpaper,paperauthor,paper)
{
  aut_papers=list()
  autid=unique(validpaper$authorid)
  for (i in 1:length(autid))
  {
    authorid=autid[i]
    show(i)
    paperid=unique(paperauthor$paperid[paperauthor$authorid==authorid])
    ind=is.element(paper$id,paperid)
    a=unlist(com_all[ind])
    name=unique(names(a))
    name=name[name!=""]
    if (length(name)==0) aut_papers[[i]]=0
    c=unlist(lapply(name,function(x) sum(a[x])))
    # show(name)
    names(c)=name
    aut_papers[[i]]=c
  }
  return(aut_papers)
}


###please ignore it 
modify.aut.papers<-function(train)
{
  res=list()
  authors=unique(train$authorid)
  aut_papers=lapply(authors,function(x) 
    x=unique(paperauthor$paperid[paperauthor$authorid==x]))
  for (i in 1:length(aut_papers))
  {
    show(i)
    authorids=unique(trainconfirmed$authorid[is.element(aut_papers[[i]],
                                                 paperauthor$paperid)])
    show(authorids)
    wei=NULL
    for (j in 1:length(authorids))
    {
    #  show(j)
      paperids=paperauthor$paperid[paperauthor$authorid==authorids[j]]
      wei=c(wei,length(intersect(aut_papers[[i]],paperids)))
      show(length(intersect(aut_papers[[i]],paperids)))
    }
    res[[i]]=wei
  }
  return(res)
}

aut_paper_wei=modify.aut.papers(train)





valid_aut_papers=get.author.paper(train,paperauthor,paper)

#sum(unlist(lapply(aut_papers,function(x) x=any(x==0)))) #0 

#combine the paper with the journal & conference keys
valid.paper.com<-function(validpaper,paper,comJ,comC,wei=c(1,1,1))
{
  valid_papers=list()
  papid=unique(validpaper$paperid)
  for (i in 1:length(papid))
  {
    show(i)
    paperid=papid[i]
    ind=paper$id==paperid
    show(which(ind))
    a=c(unlist(com_all[ind])*wei[1],
        unlist(comJ[is.element(journal$id,paper$journalid[ind])])*wei[2],
        unlist(comC[is.element(conference$id,paper$conferenceid[ind])])*wei[3])
    name=unique(names(a))
    name=name[name!=""]
    if (length(name)==0) valid_papers[[i]]=0
    c=unlist(lapply(name,function(x) sum(a[x])))
    # show(name)
    names(c)=name
    valid_papers[[i]]=c
  }
  return(valid_papers)
}
valid_papers=valid.paper.com(train,paper,comJ,comC,wei=c(1,1,1))
papid=unique(train$paperid)

train=train[!is.element(train$paperid,papid[unlist(lapply(valid_papers,is.null))]),]
valid_papers=valid_papers[!unlist(lapply(valid_papers,is.null))]


get.dist<-function(train,dist_dtm)
{
  autid=unique(train$authorid)
  papid=unique(train$paperid)
  naut=length(autid)
  dist=rep(0,nrow(train))
  for (i in 1:nrow(train))
  {
    ind1=which(autid==train$authorid[i])
    ind2=which(papid==train$paperid[i])+naut
    dist[i]=dist_dtm[ind1,ind2]
  }
  return(data.frame(train,dist=dist))
}
train1=get.dist(train,dist_dto)

gg=glm(match~dist,family=binomial,data=train1)

a=predict(gg)
auc<-function(outcome,prob){
  if (is.factor(outcome))
    outcome=as.numeric(outcome)-1
  N=length(prob)
  N_pos=sum(outcome)
  outcome=outcome[order(-prob)]
  above=(1:N)-cumsum(outcome)
  return(1-sum(above*outcome)/(N_pos*(N-N_pos)))
}

auc(train1$match,a)


