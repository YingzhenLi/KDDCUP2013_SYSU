
library("slam")

#DocumentTerms Matrix

###how to filter the noise effectively?


#只对keyword!=""的部分进行统计聚类：cate key3 subkey
comb<-function(i,wei,cate,key,subkey,title_key)
{
  #if no 
  #show(key[[i]])
  #show(title_key[[i]])
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


ind=which(keyword!=""|title!="")
keyind=which(keyword!="")
c=as.list(rep("",length(keyword)))
Cate=c
Cate[keyind]=cate
Key=c
Key[keyind]=key3
Subkey=c
Subkey[keyind]=subkey

com=lapply(1:length(ind),comb,wei=c(3,2,1,1),cate=Cate[ind],key=Key[ind],
           subkey=Subkey[ind],title_key=res[ind])


zero=unlist(lapply(1:length(ind),function(i) {if (any(com[[i]]==0|is.null(com[[i]]))) i}))
com=com[setdiff(1:length(ind),zero)]
ind=setdiff(ind,ind[zero])


col=unique(unlist(c(cate,key3,subkey,res)))
col=col[col!=""]
nrow=length(com);ncol=length(col)

get.mat<-function(nrow,ncol,col,com)
{
  ijv=NULL
  for (i in 1:length(com))
  {
    show(i)
    ii=which(is.element(col,names(com[[i]])))
    ijv=rbind(ijv,cbind(i,ii,as.vector(com[[i]])))
  }
  mat=simple_triplet_matrix(ijv[,1],ijv[,2],ijv[,3], dimnames = NULL)
  return(mat)
}
system.time((mat=get.mat(nrow,ncol,col,com)))
mat1=mat
colnames(mat1)=col

dtm <- as.DocumentTermMatrix(mat1,weighting =weightTf,
                             control = list(stemming = TRUE, stopwords = TRUE, removePunctuation = TRUE,tolower=T))

inspect(dtm[1:5, 1:5])
#dist_dtm <- dissimilarity(dtm, method = 'cosine')
#hc <- hclust(dist_dtm, method = 'ave')
#plot(hc, xlab = '')





