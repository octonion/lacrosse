sink("ncaa_lmer_advanced.txt")

library("lme4")
library("nortest")
library("RPostgreSQL")

#library("sp")

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="lacrosse")

query <- dbSendQuery(con, "
select
r.game_id,
r.year,
r.field as field,

(
case
  when r.field='none' then 'none'
  when r.field='offense_home' then r.team_id::text||'/'||field
  when r.field='defense_home' then r.opponent_id::text||'/'||field
end)
as team_field,

--coalesce(distance_in_km(site.latitude,site.longitude,team.latitude,team.longitude),0) as team_distance,

--coalesce(distance_in_km(site.latitude,site.longitude,opponent.latitude,opponent.longitude),0) as opponent_distance,

--round(coalesce(team.elevation-site.elevation,0)/500.0) as team_elevation,
--round(coalesce(opponent.elevation-site.elevation,0)/500.0) as opponent_elevation,

r.team_id as team_id,
r.team_div_id as o_div,
r.opponent_id as opponent_id,
r.opponent_div_id as d_div,
r.game_length as game_length,
r.team_score::float as gs
from ncaa.results r

--left join ncaa.geocodes site
--  on (site.team_id)=(r.location_id)
--left join ncaa.geocodes team
--  on (team.team_id)=(r.team_id)
--left join ncaa.geocodes opponent
--  on (opponent.team_id)=(r.opponent_id)

where
    r.year between 2002 and 2015
--and r.game_date < '2015/11/29'::date

and r.team_div_id is not null
and r.opponent_div_id is not null

and r.team_score>=0
and r.opponent_score>=0
and r.team_score<=50
and r.opponent_score<=50

and not(r.team_score,r.opponent_score)=(0,0)

-- fit all excluding March and April

--and not(extract(month from r.game_date)) in (3,4)

;")

games <- fetch(query,n=-1)

dim(games)

attach(games)

pll <- list()

# Fixed parameters

#games$team_elevation <- as.factor(games$team_elevation)
#games$team_elevation <- relevel(games$team_elevation, ref = "0")

#games$opponent_elevation <- as.factor(games$opponent_elevation)
#games$opponent_elevation <- relevel(games$opponent_elevation, ref = "0")

year <- as.factor(year)
year <- relevel(year, ref = "2002")
#contrasts(games$year)<-'contr.sum'

field <- as.factor(field)
field <- relevel(field, ref = "none")

d_div <- as.factor(d_div)
d_div <- relevel(d_div, ref = "1")

o_div <- as.factor(o_div)
o_div <- relevel(o_div, ref = "1")

game_length <- as.factor(game_length)
game_length <- relevel(game_length, ref = "0 OT")

fp <- data.frame(year,field,d_div,o_div,game_length)
fpn <- names(fp)

# Random parameters

game_id <- as.factor(game_id)
#contrasts(game_id) <- 'contr.sum'

offense <- as.factor(paste(year,"/",team_id,sep=""))
#contrasts(offense) <- 'contr.sum'

defense <- as.factor(paste(year,"/",opponent_id,sep=""))
#contrasts(defense) <- 'contr.sum'

team_field <- as.factor(team_field)
team_field <- relevel(team_field, ref = "none")
#contrasts(team_field) <- 'contr.sum'

rp <- data.frame(game_id,offense,defense,team_field)
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
dbWriteTable(con,c("ncaa","_parameter_levels_advanced"),parameter_levels,row.names=TRUE)

#model0 <- log_ps ~ year+game_length+field+d_div+o_div+team_distance+opponent_distance+(1|offense)+(1|defense)+(1|game_id)+(1|team_field)
#fit0 <- lmer(model0,data=games,REML=T,verbose=T)

#model <- log_ps ~ year+game_length+field+d_div+o_div+team_distance+opponent_distance+team_elevation+opponent_elevation+(1|offense)+(1|defense)+(1|game_id)+(1|team_field)

g <- cbind(fp,rp)
g$gs <- gs

detach(games)

dim(g)

model <- gs ~ year+game_length+field+d_div+o_div+(1|offense)+(1|defense)+(1|game_id)+(1|team_field)

fit <- glmer(model,data=g,REML=TRUE,verbose=TRUE,family=poisson(link=log))

fit
summary(fit)

#anova(fit)
#anova(fit0,fit)

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

dbWriteTable(con,c("ncaa","_basic_factors_advanced"),as.data.frame(combined),row.names=TRUE)

f <- fitted(fit) 
r <- residuals(fit)

# Jackknife - 4500 data points 1000 times

subs=4500
iter=1000

# Vector of results

pvals=rep(NA, iter)

# Sample p-values

for(i in 1:iter){
samp=sample(1:length(r),4500)
p.i=sf.test(r[samp])$p.value
pvals[i]=p.i
}

# Sampled p-value statistics

mean(pvals)
median(pvals)
sd(pvals)

# Graph p-values

jpeg("shapiro-francia_advanced.jpg")
hist(pvals,xlim=c(0,1))
abline(v=0.05,lty='dashed',lwd=2,col='red')
quantile(pvals,prob=seq(0,1,0.05))

# Examine residuals

jpeg("fitted_vs_residuals_advanced.jpg")
plot(f,r)
jpeg("q-q_plot_advanced.jpg")
qqnorm(r,main="Q-Q plot for residuals")

quit("no")
