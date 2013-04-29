

setwd("F:/kdd/2013 kdd/rda")
load("F:/kdd/2013 kdd/rda/paper.rda")
keyword=as.character(paper$keyword)



######trim the key first ###########

key.trim<-function(word)
{
  end=nchar(word)+2
  a=gregexpr("index[\\s-！]*terms",word,perl=T,ignore.case=T)
  if (a[[1]][1]!=-1)
    word=substr(word,a[[1]][1]+attr(a[[1]],"match.length")[1]+1,end)
  
  a=gregexpr("Key[\\s-！]*words",word,perl=T,ignore.case=T)
  show(a[[1]][1])
  if (a[[1]][1]==-1) return(c(word,""))
  
  start=a[[1]][1]+attr(a[[1]],"match.length")[1]+1
  
  
  if (a[[1]][1]==1)
  {
    return(c(substr(word,start,end),""))
  }
  if (a[[1]][1]>1)
  {
    b=gregexpr(":",substr(word,start-1,end),perl=T)
    if (b[[1]][1]==-1) return(c(word,""))
    else 
    {
      mid=start+attr(b[[1]],"match.length")[1]
      spl=unlist(strsplit(word,substr(word,a[[1]][1]-1,mid),fixed=T))
      if(length(grep("[a-zA-Z]",spl[1],perl=T))==0) spl[1]=""
      return(spl[2:1])
    }
  }
}

a=unlist(gregexpr("Key[\\s-！]*words",keyword,perl=T,ignore.case=T))
b=unlist(gregexpr("index[\\s-！]*terms",keyword,perl=T,ignore.case=T))
index=which(a>0|b>0)
kk=lapply(keyword[index],key.trim)
k=matrix(unlist(kk),ncol=2,byrow=T)
keyword[index]=k[,1]
firstkey=rep("",length(keyword))
firstkey[index]=k[,2]


######split the keywords ####
getLen<-function(vector)
{
  if (min(vector)==-1) return(0)
  else return(length(vector))
}

splitkey<-function(keyword)
{
  s=matrix(0,nrow=length(keyword),ncol=6)
  s[,1]=unlist(lapply(gregexpr(";",keyword),getLen))
  s[,2]=unlist(lapply(gregexpr(",",keyword),getLen))
  s[,3]=unlist(lapply(gregexpr("\\|",keyword),getLen))
  s[,4]=unlist(lapply(gregexpr("！",keyword),getLen))
  s[,5]=unlist(lapply(gregexpr("，",keyword),getLen))
  s[,6]=unlist(lapply(gregexpr("[^0-9]\\.[^0-9]",keyword),getLen))
  return(s)
}

s=splitkey(keyword)
spl=c(";",",","\\|","！","，","\\.")
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
table(ind[nchar(ind)>=2])
keyword[ind=="6"]




