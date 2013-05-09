

library(tm)
library(RWeka)
library(Snowball)

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
deNoise<-function(text,stem=T)
{
  docs=as.character(text)
  corpus=Corpus(VectorSource(docs))
  for (i in 1:length(corpus)){
    Encoding(corpus[[i]])<-"UTF-8"}
  corpus= tm_map(corpus, stripWhitespace)
  corpus= tm_map(corpus, removeNumbers)
  #corpus= tm_map(corpus, removePunctuation, preserve_intra_word_dashes = TRUE)
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
J_skey=deNoise(journal$shortname,stem=F)
C_fkey=deNoise(conference$fullname)
C_skey=deNoise(conference$shortname,stem=F)
A_aff=deNoise(author$affiliation)

#remove the department name
A_aff=lapply(A_aff,function(x) x=x[grepl("([\\sa-z])*((univers|univ)|(depart|dept.*)|(lab)|(school)|(instit|inst.*))([\\sa-z])*",
                                     x,perl=T)==F])

#for filter using tfidf, not completed
#not used
filter<-function(ll)
{
  vector=unlist(lapply(ll,paste,collapse=" "))
  corpus=Corpus(VectorSource(vector))
  dtm=DocumentTermMatrix(corpus, control = list(weighting=weightTf))
  term_tfidf <-tapply(dtm$v/row_sums(dtm)[dtm$i], dtm$j, mean) *
    log2(nDocs(dtm)/col_sums(dtm > 0))
  summary(term_tfidf)
  colnames(dtm)[which(term_tfidf<=1.5)]
}



