
#lapply(mylist, write, "test.txt", append=TRUE, ncolumns=1000)
setwd("~/kdd_data/rda")
load("com_all.rda")
tmp=unlist(lapply(com_all[1:10000],function(x) x=paste(names(x),collapse=";")))
write.table(tmp,file="com_all.txt",row.names=F,col.names=F,quote=F)
tmp=unlist(lapply(com_all[1:10000],paste, collapse=";"))
write.table(tmp,file="com_all_key.txt",row.names=F,col.names=F,quote=F)
tmp=get.col(com_all[1:10000])
write.table(tmp,file="com_all_words.txt",row.names=F,col.names=F,quote=F)

ll=which(unlist(lapply(com_all,function(x) all(x!=0))))[1:10000]

           

