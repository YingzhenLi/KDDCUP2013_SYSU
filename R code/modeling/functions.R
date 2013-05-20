##### packages needed #####
library(slam)
library(topicmodels)
library(Rweka)
library(Snowball)
library(Matrix)
library(tm)
load("F:/kdd/2013 kdd/rda/stops.rda")
##### combine features for single paper #######
##### features including title & keyword ######
##### of which wei indicating the weight ######

comb<-function(i,wei,cate,key,subkey,title_key)
{
  a=c(table(cate[[i]])*wei[1],table(key[[i]])*wei[2],
      table(subkey[[i]])*wei[3],table(title_key[[i]])*wei[4])
  #show(a)
  name=unique(names(a))
  show(i)
  name=name[name!=""]
  if (length(name)==0) return(0)
  c=unlist(lapply(name,function(x) sum(a[x])))
  # show(name)
  names(c)=name
  return(c)
}

##### combine organizations: journal, conference and affiliations #####
##### com_all is needed for the papers belong to the organization #####

comOrg<-function(paper,com_all,orgid,allid,onlyname=F,comN)
{
  comO=list()
  for (i in 1:length(orgid))
  {
    show(i)
    id=which(allid==orgid[i])
    #show(id)
    if (onlyname==F) a=unlist(com_all[id])
    else  a=c(unlist(com_all[id]),comN[[i]])
    
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

##### for organization names ######
removeStops<-function(corpus,stops,m=1000)
{
  n=length(stops)
  for (i in 1:ceiling(n/m))
  {
    show(i)
    if (i==ceiling(n/m))
      corpus= tm_map(corpus, removeWords, stops[((i-1)*m):n])
    else
      corpus= tm_map(corpus, removeWords, stops[((i-1)*m):(i*m)])
  }
  return(corpus)
}
deNoise<-function(text,stem=T,lower=T)
{
  docs=as.character(text)
  corpus=Corpus(VectorSource(docs))
  for (i in 1:length(corpus)){
    Encoding(corpus[[i]])<-"UTF-8"}
  corpus= tm_map(corpus, stripWhitespace)
  corpus= tm_map(corpus, removeNumbers)
  #corpus= tm_map(corpus, removePunctuation, preserve_intra_word_dashes = TRUE)
  if (lower==T)
    corpus= tm_map(corpus, tolower)
  #corpus1=unlist(inspect(corpus))
  corpus=removeStops(corpus,stops,1000)
  c1=unlist(inspect(corpus))
  #split and stemming
  key=lapply(c1,function(x) {x=gsub("[^a-z]"," ",x,perl=T);
                             x=unlist(strsplit(x," ",perl=T)); 
                             x=x[x!=""]; 
                             if(stem==T) x=SnowballStemmer(x)})
  return(key)
}
comName<-function(full,short)
{
  cc=list()
  for (i in 1:length(full))
  {
    a=c(table(full[[i]]),table(short[[i]]))
    #show(a)
    name=unique(names(a))
    show(i)
    name=name[name!=""]
    if (length(name)==0) cc[[i]]=0
    c=unlist(lapply(name,function(x) sum(a[x])))
    # show(name)
    names(c)=name
    cc[[i]]=c
  }
  return(cc)
}

####get sparsematrix #######

get.col<-function(com)
{
  col=unique(unlist(lapply(com,function(x) names(x))))
  return(col)
}


get.mat<-function(col,com)
{
  nrow=length(com);ncol=length(col)
  ijv=NULL
  for (i in 1:length(com))
  {
    show(i)
    ii=which(is.element(col,names(com[[i]])))
    ijv=rbind(ijv,cbind(i,ii,as.vector(com[[i]])))
  }
  mat=simple_triplet_matrix(ijv[,1],ijv[,2],ijv[,3], dimnames = NULL)
  colnames(mat)=col
  return(mat)
}

#### topic models #########
####for more details, please download the pdf:
## http://cran.r-project.org/web/packages/topicmodels/vignettes/topicmodels.pdf

###### get matrix to model the relationships between the entities ####

#get aut-aut matrix due to the exact relationship
get.auau<-function(author)
{
  aff=unique(author$affiliation)
  aff=aff[aff!=""]
  ijv=NULL
  for(i in 1:length(aff))
  {
    show(i)
    ind=which(author$affiliation==aff[i])
    ijv=rbind(ijv,cbind(permutations(length(ind),2,ind,repeats.allowed=T),1))
  }
  mat=sparseMatrix(ijv[,1],ijv[,2],x=ijv[,3],dims=c(length(author$id),length(author$id)))
  mat[cbind(1:length(author$id),1:length(author$id))]=1
  colnames(mat)=author$id
  return(mat)
}



#modify the author-author matrix according to the dist between the affs
get.auau.distMat<-function(author,dist_aff_dtm)
{
  
  aff=unique(author$affiliation)
  aff=aff[aff!=""]
  ijv=NULL
  
  for(i in 1:length(aff))
  {
    for (j in 1:i)
    {
      show(i);show(j)
      rowid=which(author$affiliation==aff[i])
      show(rowid)
      colid=which(author$affiliation==aff[j])
      show(colid)
      show(dist_aff_dtm[i,j])
      ijv=rbind(ijv,cbind(rep(rowid,each=length(colid)),
                          rep(colid,length(rowid)),
                          1-dist_aff_dtm[i,j]))
      
    }
    
  }
  mat=sparseMatrix(ijv[,1],ijv[,2],x=ijv[,3],dims=c(length(author$id),length(author$id)))
  mat=mat+t(mat)
  mat[cbind(1:length(author$id),1:length(author$id))]=1
  colnames(mat)=author$id
  return(mat)
}


####get the paper-author matrix according to the confirmed deleted paperauthor matrix

get.aut_pap<-function(train,author,paper,v)
{
  aut=unique(author$id)
  pap=unique(paper$id)
  ijv=NULL
  for (i in 1:nrow(train))
  {
    show(i)
    rowid=which(aut==train[i,"authorid"])
    colid=which(pap==train[i,"paperid"])
    ijv=rbind(ijv,cbind(rowid,colid,v))
  }
  mat=sparseMatrix(ijv[,1],ijv[,2],x=ijv[,3],dims=c(length(aut),length(pap)))
  rownames(mat)=aut
  colnames(mat)=pap
  return(mat)
}

#### paper-paper

####paper-paper belong to the same organization
get.papaOrg<-function(paper,org,cha)
{
  orgid=unique(org$id)
  ijv=NULL
  
  for(i in 1:length(orgid))
  {
    show(i)
    ind=which(paper[,cha]==orgid[i])
    #show(ind)
    ijv=rbind(ijv,cbind(permutations(length(ind),2,ind,repeats.allowed=T),1))
  }
  mat=sparseMatrix(ijv[,1],ijv[,2],x=ijv[,3],dims=c(length(paper$id),length(paper$id) ))
  mat[cbind(1:length(paper$id),1:length(paper$id))]=1
  colnames(mat)=paper$id
  return(mat)
}

### organization-paper matrix using similarity of texts
get.Org_pap.dist<-function(comJ,com,ind,journal,paper)
{
  comJ_ind=which(unlist(lapply(comJ,function(x) !all(x==0))))
  comJJ=comJ[comJ_ind]
  com_ind=which(unlist(lapply(com,function(x) !all(x==0))))
  comm=com[com_ind]
  dist=Matrix(0,length(comJJ),length(comm),sparse=T)
  for (i in 1:length(comJJ))
  {
    for (j in 1:length(comm))
    {
      show(i);show(j)
      name=unique(get.col(c(comJJ[i],comm[j])))
      v1=rep(0,length(name))
      v2=rep(0,length(name))
      names(v1)=name
      names(v2)=name
      v1[names(comJJ[[i]])]=scale(comJJ[[i]],center=F)
      v2[names(comm[[j]])]=scale(comm[[j]],center=F)
      dist[i,j]=1-matrix(v1,nrow=1)%*%matrix(v2,ncol=1)
    }
  }
  dd=Matrix(0,length(journal$id),length(paper$id),sparse=T)
  dd[comJ_ind,ind[com_ind]]=dist
  return(dd)
}





