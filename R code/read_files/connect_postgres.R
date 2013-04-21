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
author1000=dbGetQuery(con, "select * from author1000;")
paper1000=dbGetQuery(con, "select * from paper1000;")
conference1000=dbGetQuery(con, "select * from conference1000;")
journal1000=dbGetQuery(con, "select * from journal1000;")
paperauthor1000=dbGetQuery(con, "select * from paperauthor1000;")
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
author=apply(author1000,2,recoding)
paper=apply(paper1000,2,recoding)
conference=apply(conference1000,2,recoding)
journal=apply(journal1000,2,recoding)
paperauthor=apply(paperauthor1000,2,recoding)

setwd("F:/kdd/2013 kdd/rda")
save(author,file="author.rda")
save(paper,file="paper.rda")
save(conference,file="conference.rda")
save(journal,file="journal.rda")
save(paperauthor,file="paperauthor.rda")
save(trainconfirmed,file="trainconfirmed.rda")
save(traindeleted,file="traindeleted.rda")
save(validpaper,file="validpaper.rda")





