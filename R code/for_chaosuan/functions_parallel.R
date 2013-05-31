


split.vector<-function(l=length(com),n=10)
{
  avg=ceiling(l/n)
  nn=ceiling(l/avg)
  res=list()
  for (i in 1:nn)
  {
    res=c(res,list((avg*(i-1)+1):min(avg*i,l)))
  }
  return(res)
}
get.ijv<-function()
{
  obj= mpi.recv.Robj( source=0, tag=1, comm=1)
  com=obj[[1]]
  col=obj[[4]]
#  nrow=length(com);ncol=length(col)
#  ijv=NULL
  ijv=lapply(1:length(com),function(i) x=cbind(i,which(is.element(col,names(com[[i]]))),
                                          as.vector(com[[i]])))
  ijv=do.call(rbind,ijv)
  ijv[,1]=ijv[,1]+(obj[[2]]-1)*obj[[3]]
  mpi.send.Robj(ijv, dest=0, tag=1, comm = 1)
}

