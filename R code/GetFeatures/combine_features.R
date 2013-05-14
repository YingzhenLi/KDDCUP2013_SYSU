
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




com=lapply(1:length(ind),comb,wei=c(3,2,1,1),cate=Cate[ind],key=Key[ind],
           subkey=Subkey[ind],title_key=title_key[ind])



zero=unlist(lapply(1:length(ind),function(i) {if (any(com[[i]]==0|is.null(com[[i]]))) i}))
com=com[setdiff(1:length(ind),zero)]
ind=setdiff(ind,ind[zero])


com_all=as.list(rep(0,nrow(paper)))
com_all[ind]=com








