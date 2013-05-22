searchFreq=function(words,wd,freq)
{
	word=paste(words,collapse=" ")
	ind=getind(word,wd)
	if (is.na(ind))
		ans=NA
	else
		ans=log(freq[ind])
	return(ans)
}

divSentence=function(sent,wd,freq)#Using log to avoid underflow
{
	
	#sent=unlist(strsplit(sent,"[^A-Za-z]"))
	#sent=sent[sent!=""]
	n=length(sent)
	if (n==1)
		return(1)
	mf=min(log(freq))-1
	f=mat.or.vec(n,n)
	s=mat.or.vec(n,n)
	for (i in 1:n)
	{
		f[i,i]=searchFreq(sent[i],wd,freq)
		if (is.na(f[i,i]))
			f[i,i]=mf#f[i,i]=-Inf
		s[i,i]=i
	}
	for (d in 1:(n-1))
	{
		for (i in 1:(n-d))
		{
			f[i,i+d]=searchFreq(sent[i:(i+d)],wd,freq)
			s[i,i+d]=i+d
			for (k in 0:(d-1))
			{
				tmp=f[i,i+k]+f[i+k+1,i+d]
				#show(paste(c(d,i,k),collapse=""))
				if (is.na(f[i,i+d]) || tmp>f[i,i+d])#Is this standard sufficient enough??
				{
					f[i,i+d]=tmp
					s[i,i+d]=i+k
				}
			}
		}
	}
	return(s)
}

sepSent=function(sent,s,i,j)
{
	if (i>j)
		return("")
	if (s[i,j]==j)
		return(paste(sent[i:j],collapse=" "))
	k=s[i,j]
	p1=sepSent(sent,s,i,k)
	p2=sepSent(sent,s,k+1,j)
	return(c(p1,p2))
}

divText=function(txt,result)
{
	wd=result[[1]]
	freq=result[[2]]
	ind=order(wd)
	wd=wd[ind]
	freq=freq[ind]
	n=length(txt)
	ans=list()
	j=1
	for (i in 1:n)
	{
		sent=unlist(strsplit(txt[i],"[^A-Za-z]"))
		sent=sent[sent!=""]
		m=length(sent)
		if (m==0)
			ans[[i]]=NULL
		if (m==1)
			ans[[i]]=sent
		else if (m>1)
		{
			s=divSentence(sent,wd,freq)
			ans[[i]]=sepSent(sent,s,1,m)
		}
	}
	return(ans)
}

SentenceSplit=function(txt,d0=c(1,4),ent0=0,freq0=0,conc0=0)
{
	txt=as.character(txt)
	x=txt
	x=unlist(strsplit(x,"[^A-Za-z]"))
	x=x[x!=""]
	result=PhraseSegment(x,d0=d0,ent0=ent0,freq0=freq0,conc0=conc0)
	ind=which(txt!="")
	n=length(txt)
	ans=rep("",n)
	txt=txt[txt!=""]
	a=divText(txt,result)
	ans[ind]=a
	return(list(result,ans))
}

#running on the sample part

#keywords
tmp=SentenceSplit(paper[,6])#217 secs
keywords.bag=tmp[[1]]
keywords.split.result=tmp[[2]]
save(keywords.bag,file="keywords.bag.rda")
save(keywords.split.result,file="keywords.split.result.rda")

#title
tmp=SentenceSplit(paper[,5])#2846 secs
title.bag=tmp[[1]]
title.split.result=tmp[[2]]
save(title.bag,file="title.bag.rda")
save(title.split.result,file="title.split.result.rda")
