select
s.team_name,
split_part(o.level,'/',1) as team,
(exp(o.estimate)/exp(d.estimate))::numeric(4,3) as home
from ncaa._basic_factors_advanced o
join ncaa._basic_factors_advanced d
  on (split_part(d.level,'/',1),split_part(d.level,'/',2))=
     (split_part(o.level,'/',1),'defense_home')
join ncaa.teams_divisions s
  on (s.team_id,s.year,s.div_id)=(split_part(o.level,'/',1)::integer,2019,3)
where o.factor='team_field'
and split_part(o.level,'/',2)='offense_home'
order by home desc;

--select split_part(o.level,'/',1) as team,(o.exp_factor)::numeric(4,3) as HCA_offense,(d.exp_factor)::numeric(4,3) as HCA_defense from bbref._factors o join bbref._factors d on (split_part(d.level,'/',1),split_part(d.level,'/',2))=(split_part(o.level,'/',1),'defense_home') where o.parameter='team_field' and o.level like '%offense%' order by team asc;