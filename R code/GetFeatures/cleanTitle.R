

en_stop=paste("(\\s",paste(stopwords("en"),collapse="\\s)|(\\s"),"\\s)",sep="")

clean.title<-function(t)
{
  for (i in 1:length(t))
  {
    show(i)
    word=gsub("(\\w+)", "\\L\\1",t[[i]], perl=TRUE)
    if (all(word==""))
    {t[[i]]=""}
    else{
      words=strsplit(word," ")
      t[[i]]=unlist(lapply(words,function(x) {a=grepl(en_stop,paste(" ",x," ",sep=""),perl=T);
                                              ind=which(a==F)
                                              if (length(ind)!=0) a[min(ind):max(ind)]=F;
                                              x=paste(x[a==F],collapse=" ")}))
      t[[i]]=t[[i]][t[[i]]!=""]
    }
  }
  return(t)
}
tt=clean.title(title.split.result[title!=""])
