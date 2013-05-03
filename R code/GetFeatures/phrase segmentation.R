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
				a1=paste(tmp[1:j],collapse="")
				a2=paste(tmp[(j+1):nn],collapse="")
				ind1=getind(a1,finger)
				ind2=getind(a2,finger)
				tmxp=log(freq[ind1])+log(freq[ind2])
				if (!is.na(tmxp))
					mxp=max(mxp,tmxp)
			}
			conc[i]=exp(log(tfreq)-mxp)
		}
	}
	return(conc)
}	

getAllPhrases=function(StrData,d0)#Get a table with phrase, frequency, entropy, concretion
{
	n=length(StrData)
	StrData=c(" ",StrData," ")
	
	ansWord=list()
	ansFreq=NULL
	ansEntropy=NULL
	ansFinger=NULL
	for (d in 1:d0)
	{
		show(paste(c("Working on phrases of length ",d),collapse=""))
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
		ansWord=c(ansWord,Word)
		ansFreq=c(ansFreq,Freq)
		ansEntropy=c(ansEntropy,Entropy)
		ansFinger=c(ansFinger,Finger)
	}
	ind=order(ansFinger)
	ansFinger=ansFinger[ind]
	ansWord=ansWord[ind]
	ansFreq=ansFreq[ind]
	ansEntropy=ansEntropy[ind]
	show("Working on the Concretion")
	ansConcrete=getConcret(ansWord,ansFinger,ansFreq)
	return(list(ansWord,ansFreq,ansEntropy,ansConcrete))
}

PhraseSegment=function(StrData,d0=c(1,4),ent0,freq0,conc0)
{
	require(entropy)
	StrData=as.character(StrData)
	show("Begin!")
	tmp=getAllPhrases(StrData,d0[2])#a table with each words and other info, including words length one
	show("End of getAllPhrases")
	phrases=tmp[[1]]
	freq=tmp[[2]]
	ent=tmp[[3]]
	conc=tmp[[4]]
	
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
		if (length(phrases[[i]])>d0[1])
			ind=c(ind,i)
	phrases=phrases[ind]
	ent=ent[ind]
	conc=conc[ind]
	freq=freq[ind]
	
	return(list(Phrase=phrases,Freq=freq,Entropy=ent,Concret=conc))
}

#load("D:\\My Documents\\Study\\Kaggle\\KDD 2013\\github\\KDDCUP2013_SYSU\\samples\\rda\\paper.rda")
#with keywords
paper[,6]=as.character(paper[,6])#with keywords
x=paste(paper[,6],collapse=" ")
tmp=strsplit(x,"[^A-Za-z]")[[1]]
strdat=tmp[which(tmp!="")]
result=PhraseSegment(strdat,c(1,4),0,0,0)#17k words in 150 secs, pretty fast

#with title
paper[,5]=as.character(paper[,5])#with title
x=paste(paper[,5],collapse=" ")
tmp=strsplit(x,"[^A-Za-z]")[[1]]
strdat=tmp[which(tmp!="")]
result=PhraseSegment(strdat,c(1,4),0,0,0)#70k words in 1900 secs, pretty slow!