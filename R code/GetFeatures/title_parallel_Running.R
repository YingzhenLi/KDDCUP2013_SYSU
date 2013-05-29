#cd KDDCUP2013_SYSU/R\ code/GetFeatures
#nohup Rscript title_parallel_Running.R &> title_parallel_Running_log &
#vi title_parallel_Running_log
#cd kdd_data/rda
#running on the sample part

source("title_parallel_functions.R")

setwd("~/kdd_data/rda")
load("paper.rda")

#title
tmp=SentenceSplit(paper[,2])#2846 secs, with parallel in secs
title.bag=tmp[[1]]
title.split.result=tmp[[2]]
save(title.bag,file="full.title.bag.rda")
save(title.split.result,file="full.title.split.result.rda")

#923 on 20
#10567 on 9
