
keyword=as.character(paper$keyword)

getLen<-function(vector)
{
  if (min(vector)==-1) return(0)
  else return(length(vector))
}

splitkey<-function(keyword)
{
  s=matrix(0,nrow=length(keyword),ncol=6)
  s[,1]=unlist(lapply(gregexpr(";\\s",keyword),getLen))
  s[,2]=unlist(lapply(gregexpr(",",keyword),getLen))
  s[,3]=unlist(lapply(gregexpr("\\|",keyword),getLen))
  s[,4]=unlist(lapply(gregexpr("\\.\\s",keyword),getLen))
  s[,5]=unlist(lapply(gregexpr("¡¤",keyword),getLen))
  s[,6]=unlist(lapply(gregexpr("-\\s",keyword),getLen))
  return(s)
}

s=splitkey(keyword)
spl=c(";\\s",",","\\|","\\.\\s","¡¤","-\\s")
spliter=apply(s,1,
              function(x) {
                if (max(x)==0) return(spl[1])
                else return(spl[which(x!=0)[1]])
              })
key=strsplit(keyword,spliter)

#####just for stat #####
pasteind<-function(vector)
{
  if (max(vector)==0) return("0")
  else return(paste(which(vector!=0),collapse=" "))
}

ind=apply(s,1,pasteind)

