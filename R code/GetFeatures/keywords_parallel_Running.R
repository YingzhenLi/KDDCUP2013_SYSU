#cd KDDCUP2013_SYSU/R\ code/GetFeatures
#nohup Rscript keywords_parallel_Running.R &> keywords_parallel_Running_log &
#vi keywords_parallel_Running_log
#cd kdd_data/rda
#running on the sample part

source("title_parallel_functions.R")

setwd("~/kdd_data/rda")
load("paper.rda")

#keywords
tmp=SentenceSplit(paper[,6])#217 secs, with parallel in 200 secs
keywords.bag=tmp[[1]]
keywords.split.result=tmp[[2]]
save(keywords.bag,file="full.keywords.bag.rda")
save(keywords.split.result,file="full.keywords.split.result.rda")

#30197 on 24