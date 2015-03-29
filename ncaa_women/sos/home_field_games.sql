select
g.year,
--g.field,
(
sum(
case when g.field='offense_home' and g.team_score>g.opponent_score then 1
     when g.field='defense_home' and g.team_score<g.opponent_score then 1
     when g.field='none' then 0.5
     else 0
end
)::float/
count(*)
)::numeric(3,2) as win_pct,
count(*) as n
from ncaa_women.results g

where

TRUE
and g.year>=2002

and g.pulled_id=g.team_id
and g.team_id<g.opponent_id

--and g.field in ('offense_home','defense_home')

--and extract(month from g.game_date::date) in (3,4)
--where
group by g.year
order by g.year;
--group by g.field
--order by g.field;
