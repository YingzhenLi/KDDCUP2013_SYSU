

setwd("F:/kdd/2013 kdd/rda")
load("F:/kdd/2013 kdd/rda/paper.rda")
keyword=as.character(paper$keyword)

######trim the key first ###########

key.trim<-function(word)
{
  end=nchar(word)+2
  a=gregexpr("[\\(\\-！.,\\s:]*index[\\s-！]*terms*[\\s:.\\-！,;]*",word,perl=T,ignore.case=T)
  if (a[[1]][1]!=-1)
    word=substr(word,a[[1]][1]+attr(a[[1]],"match.length")[1],end)
  
  a=gregexpr("[\\(\\-！.,\\s:]*Key[\\s-！]*words(\\sand\\sphrases)*[\\s:.\\-！,;]*",word,perl=T,ignore.case=T)
  show(a[[1]][1])
  if (a[[1]][1]==-1) return(c(word,""))
  
  start=a[[1]][1]+attr(a[[1]],"match.length")[1]
  b=gregexpr(":\\s*",substr(word,start,end),perl=T)
  if (b[[1]][1]!=-1) start=b[[1]][1]+start+attr(b[[1]],"match.length")-1
  
  if (a[[1]][1]==1)
  {
    return(c(substr(word,start,end),""))
  }
  if (a[[1]][1]>1)
  {
    spl=unlist(strsplit(word,substr(word,a[[1]][1],start),fixed=T))
    return(spl[2:1])
  }
}

a=unlist(gregexpr("Key[\\s\\-！]*words",keyword,perl=T,ignore.case=T))
b=unlist(gregexpr("index[\\s\\-！]*terms",keyword,perl=T,ignore.case=T))
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
  s=matrix(0,nrow=length(keyword),ncol=7)
  s[,1]=unlist(lapply(gregexpr(";",keyword),getLen))
  s[,2]=unlist(lapply(gregexpr("！",keyword),getLen))
  s[,3]=unlist(lapply(gregexpr("\\|",keyword),getLen))
  s[,4]=unlist(lapply(gregexpr("，",keyword),getLen))
  s[,5]=unlist(lapply(gregexpr(",",keyword),getLen))
  s[,6]=unlist(lapply(gregexpr("[^0-9]\\.[^0-9]",keyword,perl=T),getLen))
  s[,7]=unlist(lapply(gregexpr("\\s-\\s",keyword,perl=T),getLen))
  return(s)
}

s=splitkey(keyword)
#####just for stat #####
pasteind<-function(vector)
{
  if (max(vector)==0) return("0")
  else return(paste(which(vector!=0),collapse=" "))
}

ind=apply(s,1,pasteind)
ind7=which(ind=="7")
s[ind7,7][s[ind7,7]==1]=0

spl=c("\\s*;\\s*","\\s*[！/]\\s*","\\s*[/\\|]\\s*","\\s*[/，]\\s*","\\s*[,/]\\s*","\\s*[\\./]\\s*","\\s*[/\\-]\\s*")
spliter=apply(s,1,
              function(x) {
                if (max(x)==0) return(spl[1])
                else return(spl[which(x!=0)[1]])
              })
key=strsplit(keyword,spliter)



#####extract the category & trim the words ####
get.cate<-function(words)
{
  cate=""
  if (words=="") return(c(cate,words))
  
  a=unlist(strsplit(words,"\\s+",perl=T))
  a=a[grepl("\\[[0-9]+\\]",a,perl=T)==F]
  a=a[a!=""]
  show(words)
  #if (a[1]==""|length(grep("[\\s:！-]+",a[1],perl=T))==1) a=a[-1]
  words=paste(a,collapse=" ")
  b=gregexpr("\\s-\\s",words,perl=T)
  show(length(b[[1]]))
  if (b[[1]][1]!=-1)
  {
    new=unlist(strsplit(words,"\\s-\\s",perl=T))
    tmp=unlist(strsplit(new[1],"[:！,]\\s*",perl=T))
    cate=tmp[length(tmp)]
    words=paste(new[-1],collapse=" ")
  }
  return(c(cate,words))
}

get.key.cate<-function(vector)
{
  vector[grepl("(http)|(www)",vector,perl=T)]=""
  vector[grepl(paste("(\\s",paste(c(month.name,month.abb),collapse="\\s)|(\\s"),"\\s)",sep="")
               ,vector,perl=T)&grepl("\\s[12][0-9]{3}\\s",vector,perl=T)]=""
  vector=vector[vector!=""]
  a=matrix(unlist(lapply(vector,get.cate)),ncol=2,byrow=T)
  cate=paste(unique(a[,1][a[,1]!=""]),collapse=";")
  key=a[,2][a[,2]!=""]
  return(list(cate=cate,key=key))
}

key.cate=lapply(key[keyword!=""],get.key.cate)

cate=unlist(lapply(key.cate,function(x) x$cate))
key2=lapply(key.cate,function(x) x$key)






