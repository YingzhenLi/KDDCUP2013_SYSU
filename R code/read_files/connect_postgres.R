require(RPostgreSQL)
# 读入 driver
drv = dbDriver("PostgreSQL")
# 填写连接信息
con = dbConnect(drv, dbname = "kdd_sample", 
                user = "postgres", password = "zhuxuening", port = 5432)
# 查询语句
#rs = dbSendQuery(con, statement = "select * from paper1000;")
# 收割结果
#df = fetch(rs, n = -1)
# 直接执行查询返回结果
author=dbGetQuery(con, "select * from author1000;")
paper=dbGetQuery(con, "select * from paper1000;")
conference=dbGetQuery(con, "select * from conference1000;")
journal=dbGetQuery(con, "select * from journal1000;")
paperauthor=dbGetQuery(con, "select * from paperauthor1000;")
trainconfirmed=dbGetQuery(con, "select * from trainconfirmed1000;")
traindeleted=dbGetQuery(con, "select * from traindeleted1000;")
validpaper=dbGetQuery(con, "select * from validpaper1000;")
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
author23=data.frame(apply(author[,2:3],2,recoding))
paper26=data.frame(apply(paper[,c(2,6)],2,recoding))
conference234=data.frame(apply(conference[,2:4],2,recoding))
journal234=data.frame(apply(journal[,2:4],2,recoding))
paperauthor34=data.frame(apply(paperauthor[,3:4],2,recoding))

author=data.frame(id=author[,1],author23)
paper=data.frame(id=paper$id,year=paper$year,conferenctid=paper$conferenceid,journalid=paper$journalid
                 ,paper26)
conference=data.frame(id=conference$id,conference234)
journal=data.frame(id=journal$id,journal234)
conference=data.frame(id=conference$id,conference234)

paperauthor=data.frame(paperid=paperauthor$paperid,authorid=paperauthor$authorid,paperauthor34)







setwd("F:/kdd/2013 kdd/rda")
save(author,file="author.rda")
save(paper,file="paper.rda")
save(conference,file="conference.rda")
save(journal,file="journal.rda")
save(paperauthor,file="paperauthor.rda")
save(trainconfirmed,file="trainconfirmed.rda")






