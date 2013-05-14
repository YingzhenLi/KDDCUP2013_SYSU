

libraty(slam)
##combine the names with the paper keywords and title

get.col<-function(com)
{
  col=unique(unlist(lapply(com,function(x) names(x))))
  return(col)
}

#col=get.col(c(comJ,comC))
col=get.col(c(valid_aut_papers,valid_papers))


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
#system.time((mat=get.mat(col=col,c(comJ,comC))))

system.time((mat=get.mat(col=col,c(valid_aut_papers,valid_papers))))
#dist_dtm <- dissimilarity(dtm, method = 'cosine')
#hc <- hclust(dist_dtm, method = 'ave')
#plot(hc, xlab = '')





