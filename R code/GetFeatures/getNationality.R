getNationality=function(conference)
{
	homepage=as.character(conference[,4])
	n=length(homepage)
	mainad=strsplit(homepage,"/")
	ans=rep(0,n)
	for (i in 1:n)
	{
		if (length(mainad[[i]])==0 || is.na(mainad[[i]]))
			ans[i]=""
		else
		{
			tmp=mainad[[i]][1]
			if (tmp=="http:" || tmp=="https:")
				tmp=mainad[[i]][3]
			domain=strsplit(tmp,"\\.")[[1]]
			m=length(domain)
			ans[i]=domain[m]
		}
	}
	return(ans)
}
