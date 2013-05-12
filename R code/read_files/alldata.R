require(RPostgreSQL)
# 读入 driver
drv = dbDriver("PostgreSQL")
# 填写连接信息
con = dbConnect(drv, dbname = "kdd", 
                user = "postgres", password = "zhuxuening", port = 5432)
# 查询语句
#rs = dbSendQuery(con, statement = "select * from paper1000;")
# 收割结果
#df = fetch(rs, n = -1)
# 直接执行查询返回结果
author=dbGetQuery(con, "select * from author;")
paper=dbGetQuery(con, "select * from paper;")
conference=dbGetQuery(con, "select * from conference;")
journal=dbGetQuery(con, "select * from journal;")
paperauthor=dbGetQuery(con, "select * from paperauthor;")
trainconfirmed=dbGetQuery(con, "select * from trainconfirmed;")
traindeleted=dbGetQuery(con, "select * from traindeleted;")
validpaper=dbGetQuery(con, "select * from validpaper;")
# 断开连接
dbDisconnect(con)
# 释放资源
dbUnloadDriver(drv)

### convert to utf-8 #####
recoding<-function(vec)
{
  Encoding(vec)="UTF-8"
  return(vec)
}
options(stringsAsFactors = FALSE)
author23=data.frame(apply(author[,2:3],2,recoding))
paper26=data.frame(apply(paper[,c(2,6)],2,recoding))
conference234=data.frame(apply(conference[,2:4],2,recoding))
journal234=data.frame(apply(journal[,2:4],2,recoding))
paperauthor34=data.frame(apply(paperauthor[,3:4],2,recoding))

author=unique(data.frame(id=author[,1],author23))
paper=unique(data.frame(id=paper$id,year=paper$year,conferenceid=paper$conferenceid,journalid=paper$journalid
                 ,paper26))
conference=unique(data.frame(id=conference$id,conference234))
journal=unique(data.frame(id=journal$id,journal234))
conference=unique(data.frame(id=conference$id,conference234))
paperauthor=unique(data.frame(paperid=paperauthor$paperid,authorid=paperauthor$authorid,paperauthor34))

#set session first
setwd("F:/kdd/2013 kdd/rda")
save(author,file="author.rda")
save(paper,file="paper.rda")
save(conference,file="conference.rda")
save(journal,file="journal.rda")
save(paperauthor,file="paperauthor.rda")
save(trainconfirmed,file="trainconfirmed.rda")
save(traindeleted,file="traindeleted.rda")
save(validpaper,file="validpaper.rda")



