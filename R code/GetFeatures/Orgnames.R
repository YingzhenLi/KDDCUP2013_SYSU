

library(tm)
library(RWeka)
library(Snowball)
load("F:/kdd/2013 kdd/rda/conference.rda")
load("F:/kdd/2013 kdd/rda/author.rda")


#####remove the stops, punctuation,number and lower the letters ####
#### get the single words, not the phrases #######
removeStops<-function(corpus,stops,m=1000)
{
  n=length(stops)
  for (i in 1:ceiling(n/m))
  {
    show(i)
    if (i==ceiling(n/m))
      corpus= tm_map(corpus, removeWords, stops[((i-1)*m):n])
    else
      corpus= tm_map(corpus, removeWords, stops[((i-1)*m):(i*m)])
  }
  return(corpus)
}
deNoise<-function(text,stem=T,lower=T)
{
  docs=as.character(text)
  corpus=Corpus(VectorSource(docs))
  for (i in 1:length(corpus)){
    Encoding(corpus[[i]])<-"UTF-8"}
  corpus= tm_map(corpus, stripWhitespace)
  corpus= tm_map(corpus, removeNumbers)
  #corpus= tm_map(corpus, removePunctuation, preserve_intra_word_dashes = TRUE)
  if (lower==T)
    corpus= tm_map(corpus, tolower)
  #corpus1=unlist(inspect(corpus))
  corpus=removeStops(corpus,stops,1000)
  c1=unlist(inspect(corpus))
  #split and stemming
  key=lapply(c1,function(x) {x=gsub("[^a-z]"," ",x,perl=T);
                             x=unlist(strsplit(x," ",perl=T)); 
                             x=x[x!=""]; 
                      if(stem==T) x=SnowballStemmer(x)})
  return(key)
}

J_fkey=deNoise(journal$fullname)
J_skey=deNoise(journal$shortname,stem=F,lower=F)
C_fkey=deNoise(conference$fullname)
C_skey=deNoise(conference$shortname,stem=F,lower=F)

author$affiliation=as.character(author$affiliation)
aff=unique(author$affiliation[author$affiliation!=""])
A_aff=deNoise(aff)

#remove the department name
A_aff=lapply(A_aff,function(x) x=x[grepl("([\\sa-z])*((univers|univ)|(depart|dept.*)|(lab)|(school)|(instit|inst.*))([\\sa-z])*",
                                     x,perl=T)==F])
comA_aff=lapply(A_aff,function(x) x=table(x[x!=""]))

#combine names 
comName<-function(full,short)
{
  cc=list()
  for (i in 1:length(full))
  {
    a=c(table(full[[i]]),table(short[[i]]))
    #show(a)
    name=unique(names(a))
    show(i)
    name=name[name!=""]
    if (length(name)==0) cc[[i]]=0
    c=unlist(lapply(name,function(x) sum(a[x])))
    # show(name)
    names(c)=name
    cc[[i]]=c
  }
  return(cc)
}
comJN=comName(J_fkey,J_skey)
comCN=comName(C_fkey,C_skey)

save(comJN,file="comJN.rda")
save(comCN,file="comCN.rda")
save(A_aff,file="A_aff.rda")




