sink("fo_lmer.txt")

library("lme4")
library("RPostgreSQL")

#library("sp")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,host="localhost",port="5432",dbname="lacrosse")

query <- dbSendQuery(con, "
select
year,
game_id,
team_id as team,
o_div,
opponent_id as opponent,
d_div,
site as field,
fo_taken,
fo_won
from ncaa_pbp._game_faceoffs
;")

games <- fetch(query,n=-1)

dim(games)

attach(games)

pll <- list()

# Fixed parameters

year <- as.factor(year)
#contrasts(year)<-'contr.sum'

field <- as.factor(field)
field <- relevel(field, ref = "neutral")

d_div <- as.factor(d_div)

o_div <- as.factor(o_div)

fp <- data.frame(year,field,d_div,o_div)
fpn <- names(fp)

# Random parameters

game_id <- as.factor(game_id)
#contrasts(game_id) <- 'contr.sum'

offense <- as.factor(paste(year,"/",team,sep=""))
#contrasts(offense) <- 'contr.sum'

defense <- as.factor(paste(year,"/",opponent,sep=""))
#contrasts(defense) <- 'contr.sum'

rp <- data.frame(offense,defense)
rpn <- names(rp)

for (n in fpn) {
  df <- fp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("fixed",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

for (n in rpn) {
  df <- rp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("random",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

# Model parameters

parameter_levels <- as.data.frame(do.call("rbind",pll))
dbWriteTable(con,c("ncaa","_fo_parameter_levels"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)
g$fo_taken <- fo_taken
g$fo_won <- fo_won
g$fo_lost <- fo_taken-fo_won

detach(games)

dim(g)

model <- cbind(fo_won,fo_lost) ~ year+field+d_div+o_div+(1|offense)+(1|defense) #+(1|game_id)
fit <- glmer(model,data=g,REML=TRUE,verbose=TRUE,family=binomial)

fit
summary(fit)

# List of data frames

# Fixed factors

f <- fixef(fit)
fn <- names(f)

# Random factors

r <- ranef(fit)
rn <- names(r) 

results <- list()

for (n in fn) {

  df <- f[[n]]

  factor <- n
  level <- n
  type <- "fixed"
  estimate <- df

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

for (n in rn) {

  df <- r[[n]]

  factor <- rep(n,nrow(df))
  type <- rep("random",nrow(df))
  level <- row.names(df)
  estimate <- df[,1]

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

combined <- as.data.frame(do.call("rbind",results))

dbWriteTable(con,c("ncaa","_fo_basic_factors"),as.data.frame(combined),row.names=TRUE)

quit("no")
