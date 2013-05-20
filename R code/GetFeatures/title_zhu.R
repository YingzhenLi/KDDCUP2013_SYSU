
library(tm)
library(RWeka)
title=as.character(paper$title)

#####for the keywords ####
docs=as.character(paper$title)
title=Corpus(VectorSource(docs))
title= tm_map(title, stripWhitespace)
title= tm_map(title, removeNumbers)
title= tm_map(title, removePunctuation)
title= tm_map(title, tolower)
title1=unlist(inspect(title))
removeStops<-function(title,stops,m=1000)
{
  n=length(stops)
  for (i in 1:ceiling(n/m))
  {
    show(i)
    if (i==ceiling(n/m))
      title= tm_map(title, removeWords, stops[((i-1)*m):n])
    else
      title= tm_map(title, removeWords, stops[((i-1)*m):(i*m)])
  }
  a=unlist(inspect(title))
  for (i in 1:length(a))
  {
    b=strsplit(a[i]," ")
    a[i]=paste(b[[1]][b[[1]]!=""],collapse=" ")
  }
  return(a)
}
system.time((title=removeStops(title,stops,1000)))

keywords<-function(vector)
{
  words=unlist(strsplit(vector[1]," "))
  if (length(words)<=2)
    return(unique(c(words,vector[1])))
  tmp=NGramTokenizer(vector[1])
  return(tmp[unlist(lapply(tmp,grepl,x=vector[2]))])
}





#vv=cbind(title,title1)
#title_key=apply(vv,1,keywords)

title_key=lapply(title,function(x) {x=strsplit(x," ");x=x[x!=""]})


