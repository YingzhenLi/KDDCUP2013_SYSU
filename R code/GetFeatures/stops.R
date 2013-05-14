library(tm)
library(RWeka)
title=as.character(paper$title)
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
save(stops,file="stops.rda")