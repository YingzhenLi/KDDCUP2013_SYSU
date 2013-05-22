getind=function(a,finger)#here finger is sorted thus we can employ binary search here.
{
	n=length(finger)
	imax=n
	imin=1
	while (imax>=imin)
	{
		imid=trunc((imax+imin)/2)
		if (finger[imid]<a)
			imin=imid+1
		else if (finger[imid]>a)
			imax=imid-1
		else
			return(imid)
	}
	return(NA)
}

getConcret=function(i,word,finger,freq)
{
	conc=0
	tmp=unlist(strsplit(word[i]," "))
	tfp=finger[i]
	tfreq=freq[i]
	nn=length(tmp)
	if (nn==1)
		conc=tfreq
	else
	{
		mxp=-Inf
		for (j in 1:(nn-1))
		{
			a1=paste(tmp[1:j],collapse="")
			a2=paste(tmp[(j+1):nn],collapse="")
			ind1=getind(a1,finger)
			ind2=getind(a2,finger)
			tmxp=log(freq[ind1])+log(freq[ind2])
			if (!is.na(tmxp))
				mxp=max(mxp,tmxp)
		}
		conc=exp(log(tfreq)-mxp)
	}

	return(conc)
}	

getAllPhrases=function(d,StrData)#Get a table with phrase, frequency, entropy, concretion
{
	n=length(StrData)
	StrData=c(" ",StrData," ")

	#show(paste(c("Working on phrases of length ",d),collapse=""))
	phfix=list()
	fingerprint=NULL
	for (i in 2:(n+2-d))
	{
		phfix[[i-1]]=StrData[max(i-1,1):min(i+d,n+2)]
		fingerprint[i-1]=paste(StrData[i:min(i+d-1,n+1)],collapse="")
	}
	ind=order(fingerprint)
	phfix=phfix[ind]
	i=1
	
	Word=list()
	Freq=NULL
	Entropy=NULL
	Finger=NULL
	counter=1
	
	m=length(phfix)
	while(i<=m)
	{
		nn=length(phfix[[i]])
		tmp=phfix[[i]][2:min(d+1,n-1)]
		j=i+1
		while (j<=m && length(phfix[[j]])==nn && sum(tmp==phfix[[j]][2:(d+1)])==d )
			j=j+1
		j=j-1
		freq=(j-i+1)/n
		cnt1=rep(" ",freq)
		cnt2=rep(" ",freq)
		for (k in i:j)
		{
			nn=length(phfix[[k]])
			cnt1[k-i+1]=phfix[[k]][1]
			cnt2[k-i+1]=phfix[[k]][nn]
		}
		cnt1=unname(table(cnt1))
		cnt2=unname(table(cnt2))
		
		ent1=entropy(cnt1,method="ML")
		ent2=entropy(cnt2,method="ML")
		
		ent=min(ent1,ent2)
		
		Word[[counter]]=tmp
		Freq[counter]=freq
		Entropy[counter]=ent
		nn=length(tmp)
		Finger[counter]=paste(tmp,collapse="")
		counter=counter+1
		i=j+1
	}
	ind=order(Finger)
	Finger=Finger[ind]
	Word=Word[ind]
	n=length(ind)
	tmp=NULL
	for (i in 1:n)
		tmp[i]=paste(Word[[i]],collapse=" ")
	Word=tmp
	Freq=Freq[ind]
	Entropy=Entropy[ind]
	return(list(Word,Freq,Entropy,Finger))
}
#ansConcrete=getConcret(ansWord,ansFinger,ansFreq)
	
cleaning=function(result,min.d=1,ent0=0,freq0=0,conc0=0)
{
	
	phrases=result[[1]]
	freq=result[[2]]
	ent=result[[3]]
	conc=result[[4]]
	
	ind=which(freq>freq0 & ent>ent0 & conc>conc0)
	
	phrases=phrases[ind]
	freq=freq[ind]
	ent=ent[ind]
	conc=conc[ind]
	
	ind=order(freq,decreasing=T)
	phrases=phrases[ind]
	ent=ent[ind]
	conc=conc[ind]
	freq=freq[ind]
	
	n=length(phrases)
	ind=NULL
	for (i in 1:n)
	{
		tmp=length(unlist(strsplit(phrases[i]," ")))
		if (tmp>=min.d)
			ind=c(ind,i)
	}
	phrases=phrases[ind]
	ent=ent[ind]
	conc=conc[ind]
	freq=freq[ind]
	
	return(list(Phrase=phrases,Freq=freq,Entropy=ent,Concret=conc))
}

PhraseSegment=function(StrData,d0=c(1,4),ent0,freq0,conc0)
{
	require(entropy)
	StrData=as.character(StrData)
	#show("Begin!")
	tmp=getAllPhrases(StrData,d0[2])#a table with each words and other info, including words length one
	#show("End of getAllPhrases")
	tmp=cleaning(tmp,d0[1],ent0,freq0,conc0)
	
	return(tmp)
}

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
	prt=proc.time()
    require(parallel)
    require(entropy)
    #Linux Version:
    mc <- getOption("mc.cores", 6)
    #Windows Version:
    #cl <- makeCluster(getOption("cl.cores", 2))
	
    txt=as.character(txt)
    x=txt
    x=unlist(strsplit(x,"[^A-Za-z]"))
    x=x[x!=""]
	#show(proc.time()-prt)
	prt=proc.time()
    
    clusterExport(cl, list("entropy","getind"))
	#Windows Version:
    #res <- parLapply(cl, 1:d0[2], getAllPhrases, x)
	#Linux Version
    res <- mclapply(1:d0[2], getAllPhrases, StrData, mc.cores = mc)
	#show(proc.time()-prt)
	prt=proc.time()
    n=length(res)
    ansWord=NULL
    ansFinger=NULL
    ansFreq=NULL
    ansEntropy=NULL
    for (i in 1:n)
    {
        ansWord=c(ansWord,res[[i]][[1]])
        ansFreq=c(ansFreq,res[[i]][[2]])
        ansEntropy=c(ansEntropy,res[[i]][[3]])
        ansFinger=c(ansFinger,res[[i]][[4]])
    }
	ind=order(ansFinger)
	ansFinger=ansFinger[ind]
	ansWord=ansWord[ind]
	n=length(ind)
	tmp=NULL
	for (i in 1:n)
		tmp[i]=paste(ansWord[[i]],collapse=" ")
	ansWord=tmp
	ansFreq=ansFreq[ind]
	ansEntropy=ansEntropy[ind]
	
    n=length(ansWord)
	#show(proc.time()-prt)
	prt=proc.time()
	#Windows Version
    #res2 <- parLapply(cl, 1:n, getConcret, ansWord,ansFinger,ansFreq)
	#Linux Version
    res2 <- mclapply(1:n, getConcret, ansWord,ansFinger,ansFreq, mc.cores = mc)
	#show(proc.time()-prt)
	prt=proc.time()
    ansConcrete=unlist(res2)
    result=list(ansWord,ansEntropy,ansFreq,ansConcrete)
    result=cleaning(result,d0[1],ent0,freq0,conc0)
    #Finish the phrase segmentation
    #show("Finish the phrase segmentation")
	
    ind=which(txt!="")
    n=length(txt)
    ans=rep("",n)
    txt=txt[txt!=""]
    a=divText(txt,result)
    ans[ind]=a
    return(list(result,ans))
}

