begin;

set timezone to 'America/New_York';

select

g.game_date::date as date,
'home' as site,
hd.team_name as home,
'D'||hd.div_id as div,
(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor)::numeric(4,2) as score,

vd.team_name as away,
'D'||vd.div_id as div,
(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive*d.exp_factor)::numeric(4,2) as score

from nll.games g
join nll._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.team_id)
join nll._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join nll.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join nll._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join nll._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join nll.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join nll._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join nll._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join nll._factors o
  on (o.parameter,o.level)=('field','offense_home')
join nll._factors d
  on (d.parameter,d.level)=('field','defense_home')
join nll._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join nll._basic_factors i
  on (i.factor)=('(Intercept)')
where
    not(g.game_date='')
and g.game_date::date between current_date and current_date+6
and g.location='Home'

union

select

g.game_date::date as date,
'neutral' as site,
hd.team_name as home,
'D'||hd.div_id as div,
(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor)::numeric(4,2) as score,

vd.team_name as away,
'D'||vd.div_id as div,
(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive)::numeric(4,2) as score

from nll.games g
join nll._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.team_id)
join nll._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join nll.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join nll._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join nll._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join nll.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join nll._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join nll._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join nll._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join nll._basic_factors i
  on (i.factor)=('(Intercept)')
where
    not(g.game_date='')
and g.game_date::date between current_date and current_date+6
and g.location='Neutral'

and g.team_id < g.opponent_id

order by home asc;

copy
(
select

g.game_date::date as date,
'home' as site,
hd.team_name as home,
'D'||hd.div_id as div,
(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor)::numeric(4,2) as score,

vd.team_name as away,
'D'||vd.div_id as div,
(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive*d.exp_factor)::numeric(4,2) as score

from nll.games g
join nll._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.team_id)
join nll._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join nll.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join nll._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join nll._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join nll.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join nll._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join nll._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join nll._factors o
  on (o.parameter,o.level)=('field','offense_home')
join nll._factors d
  on (d.parameter,d.level)=('field','defense_home')
join nll._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join nll._basic_factors i
  on (i.factor)=('(Intercept)')
where
    not(g.game_date='')
and g.game_date::date between current_date and current_date+6
and g.location='Home'

union

select

g.game_date::date as date,
'neutral' as site,
hd.team_name as home,
'D'||hd.div_id as div,
(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor)::numeric(4,2) as score,

vd.team_name as away,
'D'||vd.div_id as div,
(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive)::numeric(4,2) as score

from nll.games g
join nll._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.team_id)
join nll._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join nll.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join nll._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join nll._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join nll.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join nll._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join nll._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join nll._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join nll._basic_factors i
  on (i.factor)=('(Intercept)')
where
    not(g.game_date='')
and g.game_date::date between current_date and current_date+6
and g.location='Neutral'

and g.team_id < g.opponent_id

order by home asc
) to '/tmp/predict_weekly.csv' csv header;

commit;