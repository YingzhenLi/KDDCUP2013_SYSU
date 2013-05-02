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

getConcret=function(word,finger,freq)
{
	n=length(word)
	conc=1:n
	for (i in 1:n)
	{
		tmp=word[[i]]
		tfp=finger[i]
		tfreq=freq[i]
		nn=length(tmp)
		if (nn==1)
			conc[i]=tfreq
		else
		{
			mxp=-Inf
			for (j in 1:(nn-1))
			{
				a1=tmp[1:j]
				a2=tmp[(j+1):nn]
				ind1=getind(a1,finger)
				ind2=getind(a2,finger)
				tmxp=log(freq[ind1])+log(freq[ind2])
				mxp=max(mxp,tmxp)
			}
			conc[i]=exp(log(tfreq)-mxp)
		}
	}
	return(conc)
}	

getAllPhrases=(StrData,d0)#Get a table with phrase, frequency, entropy, concretion
{
	n=length(StrData)
	StrData=c(" ",StrData," ")
	
	ansWord=NULL
	ansFreq=NULL
	ansEntropy=NULL
	ansFinger=NULL
	for (d in 1:d0)
	{
		phfix=list()
		fingerprint=NULL
		for (i in 2:(n+1))
		{
			phfix[[i-1]]=StrData[max(i-1,1):min(i+d0,n+2)]
			fingerprint[i-1]=paste(StrData[i:min(i+d0-1,n+1)],collapse="")
		}
		ind=order(fingerprint)
		phfix=phfix[ind]
		i=1
		
		Word=list()
		Freq=NULL
		Entropy=NULL
		Finger=NULL
		counter=1
		while(i<=n)
		{
			tmp=phfix[[i]][1:d]
			j=i+1
			while (j<=n && sum(tmp==phfix[[j]][1:d])==d)
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
			Finger[counter]=paste(tmp[2:(nn-1)],collapse="")
			counter=counter+1
			i=j+1
		}
		ansWord=c(ansWord,Word)
		ansFreq=c(ansFreq,Freq)
		ansEntropy=c(ansEntropy,Entropy)
		ansFinger=c(ansFinger,Finger)
	}
	ind=order(ansFinger)
	ansFinger=ansFinter[ind]
	ansWord=ansWord[ind]
	ansFreq=ansFreq[ind]
	ansConcrete=getConc(ansWord,ansFinger,ansFreq)
	return(list(ansWord,ansFreq,ansEntropy,ansConcrete))
}

PhraseSegment=function(StrData,d0,ent0,fre0,conc0)
{
	require(entropy)
	StrData=as.character(StrData)
	
	tmp=getAllPhrases(StrData,d0)#a table with each words and other info, including words length one
	phrases=tmp[[1]]
	freq=tmp[[2]]
	ent=tmp[[3]]
	conc=tmp[[4]]
	
	ind=cleaning(freq,ent,conc,freq0,ent0,conc0)
	
	ind=which(freq>=freq0 & ent>=ent0 & conc>=conc0)
	
	phrases=phrases[[ind]]
	freq=freq[ind]
	ent=ent[ind]
	conc=conc[ind]
	
	phrases=phrases[order(freq)]
	freq=freq[order(freq)]
	ent=ent[order(freq)]
	conc=conc[order(freq)]
	
	return(list(Phrase=phrases,Freq=freq,Entropy=ent,Concret=conc))
}
