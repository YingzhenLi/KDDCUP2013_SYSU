searchFreq=function(words,sorted.result)
{
	word=paste(words,collapse=" ")
	ind=getind(word,wd)
	if (is.na(ind))
		ans=-Inf
	else
		ans=log(freq[ind])
	return(ans)
}

divSentence=function(sent,wd,freq)#Using log to avoid underflow
{
	
	sent=unlist(strsplit(sent,"[^A-Za-z]"))
	sent=sent[sent!=""]
	n=length(sent)
	f=mat.or.vec(n,n)
	s=mat.or.vec(n,n)
	for (i in 1:n)
	{
		f[i,i]=searchFreq(sent[i],wd,freq)
		s[i,i]=i
	}
	for (d in 1:n-1)
	{
		for (i in 1:(n-d))
		{
			f[i,i+d]=searchFreq(sent[i:i+d],wd,freq)
			s[i,i+d]=j
			for (k in 0:(d-1))
			{
				tmp=f[i,i+k]+f[i+k+1,i+d]
				if (tmp>f[i,i+d])
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
	if (s[i,j]==j)
		return(sent)
	k=s[i,j]
	p1=sepSent(sent[i:k],s,i,k)
	p2=sepSent(sent[(k+1):j],s,k+1,j)
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
	for (i in 1:n)
	{
		tmp=divSentence(txt[i],wd,freq)
		sent=unlist(strsplit(sent,"[^A-Za-z]"))
		sent=sent[sent!=""]
		m=length(sent)
		ans[[i]]=sepSent(sent,s,1,m)
	}
	return(ans)
}