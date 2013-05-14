
library("")
#以下内容如有时间请帮忙检查，欢迎补充及修改

#请自设默认路径
setwd("F:/kdd/2013 kdd/rda")
load("F:/kdd/2013 kdd/rda/paper.rda")
keyword=as.character(paper$keyword)
notNULL=which(keyword!=""&is.na(keyword)==F)
keyword=gsub("(\\w+)", "\\L\\1",keyword, perl=TRUE)




#以下内容相关正则表达式的部分
#请参照正则表达式语法：http://msdn.microsoft.com/zh-cn/library/ae5bf541(v=vs.80).aspx
#R 的相关函数请help grep
#tm 包内容请见pdf刘思喆文本挖掘篇

#1、
#有些keywords内部或者开头部分会注明keywords:或者index terms:这两种记号（形式可能不唯一）
#我匹配的形式参照下面正则表达式部分，如果你发现其他形式的开头标记，请告知我
#2、
#有时keywords之前还会出现其他的keywords信息，我认为它们的级别高于keywords，把它们标记为firstkey

#下面这段代码去除keywords开头的说明标记，同时提出firstkey(针对所有keywords)：
######trim the key first ###########

key.trim<-function(word)
{
  end=nchar(word)+2
  a=gregexpr("[\\(\\-—.,\\s:]*index[\\s-—]*terms*[\\s:.\\-—,;]*",word,perl=T,ignore.case=T)
  if (a[[1]][1]!=-1)
    word=substr(word,a[[1]][1]+attr(a[[1]],"match.length")[1],end)
  
  a=gregexpr("[\\(\\-—.,\\s:]*Key[\\s-—]*words(\\sand\\sphrases)*[\\s:.\\-—,;]*",word,perl=T,ignore.case=T)
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

a=unlist(gregexpr("Key[\\s\\-—]*words",keyword,perl=T,ignore.case=T))
b=unlist(gregexpr("index[\\s\\-—]*terms",keyword,perl=T,ignore.case=T))
index=which(a>0|b>0)
kk=lapply(keyword[index],key.trim)
k=matrix(unlist(kk),ncol=2,byrow=T)
keyword[index]=k[,1]
firstkey=rep("",length(keyword))
firstkey[index]=k[,2]

#keywords的标点分隔形式很不相同，同时会出现一种标点多种用途的情形
#比如对于“.”，可以作为结束符、分隔符、省略符；我们需要甄别出它作为分隔符的情形

#我认为它们的优先级别与下述s矩阵1-7的顺序一致（可以通过ind来观察它们的统计情况）
#我得到的规律是，当优先级别较弱的分隔符与较强的分隔符同时出现时，一般以优先级较强的分隔符作为分隔符
#此时优先级较弱的分隔符作为其他途径使用
#当只（注意，是“只”）出现优先级较弱的分隔符时，一般作为分隔符使用

#值得一提的是：分号（;）与逗号（,）同时使用的情形
#此时“,”表示低于";"划分的keywords下一级别的keywords，以后计算时可以考虑赋以不同权重

#另外，当" - "这种结构只出现一次时，前面一边表示大类category；出现多次时会起到分隔符作用
#下面这段代码用于分隔keywords

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
  s[,2]=unlist(lapply(gregexpr("—",keyword),getLen))
  s[,3]=unlist(lapply(gregexpr("\\|",keyword),getLen))
  s[,4]=unlist(lapply(gregexpr("·",keyword),getLen))
  s[,5]=unlist(lapply(gregexpr(",",keyword),getLen))
  s[,6]=unlist(lapply(gregexpr("\\s-\\s",keyword,perl=T),getLen))
  s[,7]=unlist(lapply(gregexpr("[^0-9]\\.[^0-9]",keyword,perl=T),getLen))
  return(s)
}

s=splitkey(keyword)
ss=splitkey(firstkey[notNULL])
#####just for stat #####
pasteind<-function(vector)
{
  if (max(vector)==0) return("0")
  else return(paste(which(vector!=0),collapse=" "))
}

ind=apply(s,1,pasteind)
ind7=which(ind=="7")
s[ind7,7][s[ind7,7]==1]=0

spl=c("\\s*;\\s*","\\s*[—/]\\s*","\\s*[/\\|]\\s*","\\s*[/·]\\s*","\\s*[,/]\\s*","\\s*[/\\-]\\s*","\\s*[\\./]\\s*")
spliter=apply(s,1,
              function(x) {
                if (max(x)==0) return(spl[1])
                else return(spl[which(x!=0)[1]])
              })
key=strsplit(keyword,spliter)

#有时" - "之前会表示出文章的大类信息，如:Computer Science
#下面这段代码用于提出大类信息并且去除年份、月份（有一些会注明发表时间的）、期刊标号、网页链接
#等杂乱信息
#具体代码如下：

#####extract the category & trim the words ####
get.cate<-function(words)
{
  cate=""
  if (words=="") return(c(cate,words))
  
  a=unlist(strsplit(words,"\\s+",perl=T))
  a=a[grepl("\\[[0-9]+\\]",a,perl=T)==F]
  a=a[a!=""]
  show(words)
  #if (a[1]==""|length(grep("[\\s:—-]+",a[1],perl=T))==1) a=a[-1]
  words=paste(a,collapse=" ")
  b=gregexpr("\\s-\\s",words,perl=T)
  show(length(b[[1]]))
  if (b[[1]][1]!=-1)
  {
    new=unlist(strsplit(words,"\\s-\\s",perl=T))
    tmp=unlist(strsplit(new[1],"[:—,]\\s*",perl=T))
    cate=tmp[length(tmp)]
    words=paste(new[-1],collapse=" ")
  }
  words=paste(unlist(strsplit(words,"[^\\s]-\\s",perl=T)),collapse="")
  c=gregexpr(",",words,perl=T)
  
  return(c(cate,words))
}

get.key.cate<-function(vector)
{
  vector[grepl("(http)|(www)",vector,perl=T)]=""
  vector[grepl(paste("(\\s",paste(c(month.name,month.abb),collapse="\\s)|(\\s"),"\\s)",sep="")
               ,vector,perl=T)&grepl("\\s[12][0-9]{3}\\s",vector,perl=T)]=""
  vector=vector[vector!=""]
  a=matrix(unlist(lapply(vector,get.cate)),ncol=2,byrow=T)
  #cate=paste(unique(a[,1][a[,1]!=""]),collapse=";")
  cate=unique(a[,1][a[,1]!=""])
  key=a[,2][a[,2]!=""]
  return(list(cate=cate,key=key))
}

key.cate=lapply(key[keyword!=""],get.key.cate)

cate=lapply(key.cate,function(x) x$cate)
key2=lapply(key.cate,function(x) x$key)


#有时keywords后面有（）注明，他们会表示缩写形式，我将他们提出独立成词
#对于上述划分之后存在的“，”没有分割完全的情形，我将它们作为subkey抽出
#对于出现的停词，用停词作为分隔符对keywords进一步分割
#去除单个数字
#对于x-ray???
#对于非全大写的单词变为小写字母
#对于keyword!=""的情形，最终结果保存于key3 subkey 以及cate中
#将短语个数>=5的分割成单个


##extract subkey & trim again #####
library(tm)
stopword=paste("(\\s+",paste(stopwords("en"),collapse="\\s+)|(\\s+"),"\\s+)",sep="")

modify.word<-function(word)
{
  n=nchar(word)
  a=gregexpr("[a-z]\\.",word,perl=T)
  if (any((a[[1]]+1)==n))
    word=substr(word,1,n-1)
  #if (grepl("[a-z]",word,perl=T))
 #   word=gsub("(\\w+)", "\\L\\1",word, perl=TRUE)
  word=unlist(strsplit(paste(" ",word," "),stopword,perl=T))
  word=word[word!=""]
  word=strsplit(word," ")
  word=unlist(lapply(word,function(x) {x=x[x!=""]; x=paste(x,collapse=" ")}))
  return(word)
}
#modify.word("aef (aef)")

remove.bracket<-function(word)
{
  word=paste(" ",word)
  ab=gregexpr("\\s\\([\\w^\\W]+\\)",word,perl=T)
  abb=NULL
  if (ab[[1]][1]!=-1)
  {
    abb=substring(word,ab[[1]]+2,ab[[1]]+attr(ab[[1]],"match.length")-2)
    word=unlist(strsplit(word,"\\s\\([\\w^\\W]+\\)",perl=T))
  }
  word=unlist(lapply(lapply(word,function(x) unlist(strsplit(x,"\\(|\\)",perl=T))),
                     paste,collapse=""))
  if (all(word=="")==F) word=word[word!=""]
  else word=""
  return(list(word=word,abb=abb))
}
#remove.bracket(" (e,e‘’h)")

get.subkey<-function(words)
{
  subkey=""
  c=gregexpr(",",words,perl=T)
  if (c[[1]][1]!=-1)
  {
    subkey=unlist(lapply(unlist(strsplit(words,"\\s*[,?/]\\s*",perl=T)),modify.word))
    words=""
  }
  
  words=unlist(lapply(words,modify.word))
  words=words[words!=""]
  subkey=subkey[subkey!=""]
  return(list(words=c(words),subkey=subkey))
}


get.key.subkey<-function(vector)
{
  b=lapply(vector,remove.bracket)
  vector=unlist(lapply(b,function(x) x$word))
  abb=unlist(lapply(b,function(x) x$abb))
  a=lapply(vector,get.subkey)
  words=c(unlist(lapply(a,function(x) x$words)),abb)
  subkey=unlist(lapply(a,function(x) x$subkey))
  
  
  w=strsplit(words," ")
  s=strsplit(subkey," ")
  l1=unlist(lapply(w,length))
  l2=unlist(lapply(s,length))
  ww=words[l1>4]
  ss=subkey[l2>4]
  words=c(words[l1<=4],unlist(w[l1>4]))
  subkey=c(subkey[l2<=4],unlist(s[l2>4]))
  
  notN1=grepl("[^0-9]",words,perl=T)
  notN2=grepl("[^0-9]",subkey,perl=T)
  words=words[words!=""&words!="character(0)"&notN1==T]
  subkey=subkey[subkey!=""&subkey!="character(0)"&notN2==T]
  return(list(Words=words,Subkey=subkey))      
}

#get.key.subkey(key[test>0][[33]])

kk2=lapply(key2,get.key.subkey)
key3=lapply(kk2,function(x) x$Words)
subkey=lapply(kk2,function(x) x$Subkey)
ll=unlist(lapply(subkey,length))


ind=which(keyword!=""|title!="")
keyind=which(keyword!="")
c=as.list(rep("",length(keyword)))
Cate=c
Cate[keyind]=cate
Key=c
Key[keyind]=key3
Subkey=c
Subkey[keyind]=subkey
save(Cate,file="Cate.rda")
save(Key,file="Key.rda")
save(Subkey,file="Subkey.rda")






