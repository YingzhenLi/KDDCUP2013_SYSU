
#running on the sample part

source("title_parallel_functions.R")

#keywords
tmp=SentenceSplit(paper[,6])#217 secs, with parallel in 200 secs
keywords.bag=tmp[[1]]
keywords.split.result=tmp[[2]]
save(keywords.bag,file="keywords.bag.rda")
save(keywords.split.result,file="keywords.split.result.rda")

#title
tmp=SentenceSplit(paper[,5])#2846 secs, with parallel in secs
title.bag=tmp[[1]]
title.split.result=tmp[[2]]
save(title.bag,file="title.bag.rda")
save(title.split.result,file="title.split.result.rda")
