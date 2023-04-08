begin;

set timezone to 'America/Los_Angeles';

select

hd.div_id as div,
r.team_name,
r.opponent_name,
(case
when
(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor)>
(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive*d.exp_factor) and r.team_score>r.opponent_score then 1
when
(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor)<
(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive*d.exp_factor) and r.team_score<r.opponent_score then 1
else 0 end)
as pw

from ncaa.results r
join ncaa._schedule_factors h
  on (h.year,h.team_id)=(r.year,r.team_id)
join ncaa._schedule_factors v
  on (v.year,v.team_id)=(r.year,r.opponent_id)
join ncaa.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join ncaa._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join ncaa._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa._factors o
  on (o.parameter,o.level)=('field',r.field)
join ncaa._factors d
  on (d.parameter,d.level)=('field',
    (case when r.field='offense_home' then 'defense_home'
          when r.field='defense_home' then 'offense_home'
          when r.field='none' then 'none' end))
join ncaa._factors y
  on (y.parameter,y.level)=('year',r.year::text)
join ncaa._basic_factors i
  on (i.factor)=('(Intercept)')
where
--    not(g.game_date='')
    TRUE
and r.pulled_id = r.team_id
and r.field in ('offense_home','none')
and r.game_date between current_date-1 and current_date-1
and r.team_score is not null
and r.opponent_score is not null
and r.team_score>=0
and r.opponent_score>=0
and r.year=2023
and not((r.team_score,r.opponent_score)=(0,0))
order by div,pw,team_name,opponent_name;

commit;
