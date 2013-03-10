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

coalesce(distance_in_km(site.latitude,site.longitude,team.latitude,team.longitude),0) as team_distance,

coalesce(distance_in_km(site.latitude,site.longitude,opponent.latitude,opponent.longitude),0) as opponent_distance,

round(coalesce(team.elevation-site.elevation,0)/500.0) as team_elevation,
round(coalesce(opponent.elevation-site.elevation,0)/500.0) as opponent_elevation,

r.team_id as team,
r.team_div_id as o_div,
r.opponent_id as opponent,
r.opponent_div_id as d_div,
r.game_length as game_length,
ln(r.team_score::float) as log_ps
from ncaa.results r

left join ncaa.geocodes site
  on (site.team_id)=(r.location_id)
left join ncaa.geocodes team
  on (team.team_id)=(r.team_id)
left join ncaa.geocodes opponent
  on (opponent.team_id)=(r.opponent_id)

where
    r.year between 2002 and 2013
--and r.game_date < '2013/11/29'::date
and r.team_div_id is not null
and r.opponent_div_id is not null
and r.team_score>0
and r.opponent_score>0
and not(r.team_score,r.opponent_score)=(0,0)

-- fit all excluding March and April

and not(extract(month from r.game_date)) in (3,4)

;")

games <- fetch(query,n=-1)

dim(games)

pll <- list()

# Fixed parameters

games$team_elevation <- as.factor(games$team_elevation)
games$team_elevation <- relevel(games$team_elevation, ref = "0")

games$opponent_elevation <- as.factor(games$opponent_elevation)
games$opponent_elevation <- relevel(games$opponent_elevation, ref = "0")

games$year <- as.factor(games$year)
contrasts(games$year)<-'contr.sum'

games$field <- as.factor(games$field)
games$field <- relevel(games$field, ref = "none")

games$d_div <- as.factor(games$d_div)
games$d_div <- relevel(games$d_div, ref = "1")

games$o_div <- as.factor(games$o_div)
games$o_div <- relevel(games$o_div, ref = "1")

games$game_length <- as.factor(games$game_length)
games$game_length <- relevel(games$game_length, ref = "0 OT")

fp <- data.frame(games$year,games$field,games$d_div,games$o_div,games$game_length)
fpn <- names(fp)

# Random parameters

games$game_id <- as.factor(games$game_id)
contrasts(games$game_id) <- 'contr.sum'

games$offense <- as.factor(paste(games$year,"/",games$team,sep=""))
contrasts(games$offense) <- 'contr.sum'

games$defense <- as.factor(paste(games$year,"/",games$opponent,sep=""))
contrasts(games$defense) <- 'contr.sum'

games$team_field <- as.factor(games$team_field)
games$team_field <- relevel(games$team_field, ref = "none")
#contrasts(team_field) <- 'contr.sum'

rp <- data.frame(games$game_id,games$offense,games$defense,games$team_field)
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

model <- log_ps ~ year+game_length+field+d_div+o_div+team_distance+opponent_distance+team_elevation+opponent_elevation+(1|offense)+(1|defense)+(1|game_id)+(1|team_field)
fit <- lmer(model,data=games,REML=T,verbose=T)

fit
summary(fit)

anova(fit)
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
