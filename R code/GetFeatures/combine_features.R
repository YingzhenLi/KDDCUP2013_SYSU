
library("slam")

#DocumentTerms Matrix

###how to filter the noise effectively?


ind=which(keyword!=""|title!="")
com=lapply(1:length(ind),comb,wei=c(3,2,1,1),cate=Cate[ind],key=Key[ind],
           subkey=Subkey[ind],title_key=title_key[ind])

zero=unlist(lapply(1:length(ind),function(i) {if (any(com[[i]]==0|is.null(com[[i]]))) i}))
com=com[setdiff(1:length(ind),zero)]

ind=setdiff(ind,ind[zero]) ##ind is the non-zero ones


com_all=as.list(rep(0,nrow(paper)))
com_all[ind]=com








