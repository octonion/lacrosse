begin;

set timezone to 'America/New_York';

select

(g.game_date||', '||g.year::text)::date as date,
'home' as site,
ht.team_name as home,
(exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive)::numeric(4,2) as score,

vt.team_name as away,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)::numeric(4,2) as score

from nll.games g
join nll._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.home_id)
join nll._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.away_id)
join nll.teams ht
  on (ht.year,ht.team_id)=(g.year,g.home_id)
join nll.teams vt
  on (vt.year,vt.team_id)=(g.year,g.away_id)
join nll._factors o
  on (o.parameter,o.level)=('field','offense_home')
join nll._factors d
  on (d.parameter,d.level)=('field','defense_home')
join nll._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join nll._basic_factors i
  on (i.factor)=('(Intercept)')
where
   (g.game_date||', '||g.year::text)::date
     between current_date and current_date+1
order by date,home asc;

copy
(
select

(g.game_date||', '||g.year::text)::date as date,
'home' as site,
ht.team_name as home,
(exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive)::numeric(4,2) as score,

vt.team_name as away,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)::numeric(4,2) as score

from nll.games g
join nll._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.home_id)
join nll._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.away_id)
join nll.teams ht
  on (ht.year,ht.team_id)=(g.year,g.home_id)
join nll.teams vt
  on (vt.year,vt.team_id)=(g.year,g.away_id)
join nll._factors o
  on (o.parameter,o.level)=('field','offense_home')
join nll._factors d
  on (d.parameter,d.level)=('field','defense_home')
join nll._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join nll._basic_factors i
  on (i.factor)=('(Intercept)')
where
   (g.game_date||', '||g.year::text)::date
     between current_date and current_date+1
order by date,home asc
) to '/tmp/predict_daily.csv' csv header;

commit;
