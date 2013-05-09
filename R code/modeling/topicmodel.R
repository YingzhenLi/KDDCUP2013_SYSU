
####for more details, please download the pdf:
## http://cran.r-project.org/web/packages/topicmodels/vignettes/topicmodels.pdf

library("slam")
summary(col_sums(dtm))

term_tfidf <-tapply(dtm$v/row_sums(dtm)[dtm$i], dtm$j, mean) *
  log2(nDocs(dtm)/col_sums(dtm > 0))
summary(term_tfidf)

dtm <- dtm[,term_tfidf >= 0.26]
dtm <- dtm[row_sums(dtm) > 0,]
summary(col_sums(dtm))
dim(dtm)
library("topicmodels")

# k selection from the gibbs procedure
# using the metric of perplexity and loglikelihood
# for perplexity definition: http://en.wikipedia.org/wiki/Perplexity
smp<-function(cross=5,n,seed)
{
  set.seed(seed)
  dd=list()
  aa0=sample(rep(1:cross,ceiling(n/cross))[1:n],n)
  for (i in 1:cross) dd[[i]]=(1:n)[aa0==i]
  return(dd)
}
sp=smp(5,nrow(dtm),seed=1024)

selectK<-function(dtm,kv=seq(5,50,5),SEED=2013,cross=5)
{
  per_gib=NULL
  log_gib=NULL
  for (k in kv)
  {
    show(k)
    per=NULL
    loglik=NULL
    for (i in 1:cross)
    {
      #show(i)
      te=sp[[i]]
      tr=setdiff(1:nrow(dtm),te)
      Gibbs = LDA(dtm[tr,], k = k, method = "Gibbs",
                  control = list(seed = SEED, burnin = 1000,
                                 thin = 100, iter = 1000))
      per=c(per,perplexity(Gibbs,newdata=dtm[te,]))
      loglik=c(loglik,logLik(Gibbs,newdata=dtm[te,]))
    }
    show(per)
    show(loglik)
    per_gib=rbind(per_gib,per)
    log_gib=rbind(log_gib,loglik)
  }
  return(list(perplex=per_gib,loglik=log_gib))
}
gibK=selectK(dtm=dtm,kv=seq(5,50,5),SEED=2013,cross=5)

##############don't run this section ###############
#k <- 30
SEED <- 2010
res=list()
loglik=NULL
perplex=NULL
for (k in seq(5,50,5))
{
  TM <- list(VEM = LDA(dtm, k = k, control = list(seed = SEED)),
             VEM_fixed = LDA(dtm, k = k,
                             control = list(estimate.alpha = FALSE, seed = SEED)),
             CTM = CTM(dtm, k = k,
                       control = list(seed = SEED,
                                      var = list(tol = 10^-4), em = list(tol = 10^-3))))
  loglik=rbind(loglik,sapply(TM, logLik))
  perplex=rbind(perplex,sapply(TM, perplexity))
  show(k)
  show(loglik)
  show(perplex)
  res[[k/5]]=TM
}
##################################################


m_per=apply(gibK[[1]],1,mean)
m_log=apply(gibK[[2]],1,mean)
k=seq(5,50,5)
plot(x=k,y=m_per) 
k[which.min(m_per)] # 50 is a better k for modeling
plot(x=k,y=m_log) 
k[which.max(m_log)] #20 is the max
#choose 30 as a balance of two

k <- 30
SEED <- 2013
TM <- list(VEM = LDA(dtm, k = k, control = list(seed = SEED)),
           VEM_fixed = LDA(dtm, k = k,
                           control = list(estimate.alpha = FALSE, seed = SEED)),
           Gibbs = LDA(dtm, k = k, method = "Gibbs",
                       control = list(seed = SEED, burnin = 1000,
                                      thin = 100, iter = 1000)),
           CTM = CTM(dtm, k = k,
                     control = list(seed = SEED,
                                    var = list(tol = 10^-4), em = list(tol = 10^-3))))

# just for observing the result
#sapply(TM[1:2], slot, "alpha")
#sapply(TM, function(x)
#  mean(apply(posterior(x)$topics,
#             1, function(z) - sum(z * log(z)))))

#to choose the top 2 major topic for each doc in fitted model
Topic <- topics(TM[["VEM"]], 2)

#most frequent terms for every topic
Terms <- terms(TM[["VEM"]], 5)
Terms[,1:5]

#the posterior distribution 
#a[[2]] stores the topic distribution for every topic
#look for the details by yourself
a=posterior(TM[["VEM"]])


