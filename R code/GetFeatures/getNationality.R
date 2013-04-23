getNationality=function(conference)
{
	homepage=as.character(conference[,4])
	n=length(homepage)
	mainad=strsplit(homepage,"/")
	ans=rep(0,n)
	for (i in 1:n)
	{
		tmp=mainad[[i]][3]
		domain=strsplit(tmp,"\\.")[[1]]
		m=length(domain)
		ans[i]=domain[m]
	}
	return(ans)
}
