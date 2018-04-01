select
s.player_name,
s.team_name,
sf.schedule_strength::numeric(3,2) as team_sos,
s.won::integer as w,
s.lost::integer as l,
s.won::integer+s.lost::integer as a,
s.pct
from ncaa.statistics s
join ncaa._schedule_factors sf
  on (sf.team_id,sf.year)=(s.team_id,s.year)
where s.year=2017
and s.class in ('Sr','Sr.')
and (s.won::integer+s.lost::integer) >= 30
order by s.team_name asc;
--order by s.pct desc;
