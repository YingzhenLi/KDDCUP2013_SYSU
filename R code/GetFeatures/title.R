
library(tm)
library(RWeka)
#####               stop words                ########
###  download here: https://sites.google.com/site/kevinbouge/stopwords-lists #######
###  for Japanese: http://www.ranks.nl/stopwords/japanese.html   ###################
Jan=read.csv("Jan_stop.csv",header=F)
Jan=as.vector(as.matrix(Jan))
Jan=Jan[Jan!=""]
Zh=readLines("stopwords_zh.txt",encoding="UTF-8")
tm_stops=c(
  stopwords("english"),stopwords("french"),stopwords("german"),stopwords("spanish"),
  stopwords("italian"),stopwords("russian"),stopwords("portuguese"),stopwords("norwegian"),
  stopwords("finnish"),stopwords("dutch"),stopwords("hungarian"),stopwords("swedish"))

#cap_tm_stops=gsub("\\b(\\w)", "\\U\\1",tm_stops, perl=TRUE)    ###first letter capitalized
stops=c(Jan,Zh,tm_stops)


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
  return(unlist(inspect(title)))
}
system.time((title=removeStops(title,stops,1000)))

keywords<-function(vector)
{
  tmp=NGramTokenizer(vector[1])
  return(tmp[unlist(lapply(tmp,grepl,x=vector[2]))])
}
vv=cbind(title,title1)
res=apply(vv,1,keywords)




