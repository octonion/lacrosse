select
year,
(
sum(case when location='Home' and team_score>opponent_score then 1 else 0 end)::float/
sum(case when location='Home' then 1 else 0 end)::float)::numeric(4,3)
as home,
(sum(case when location='Away' and team_score>opponent_score then 1 else 0 end)::float/
sum(case when location='Away' then 1 else 0 end)::float)::numeric(4,3)
as away,
count(*) as n
from ncaa_women.games
where team_id=426
and team_score>0
and opponent_score>0
--and team_id < opponent_id
group by year
order by year asc;

select
(
sum(case when location='Home' and team_score>opponent_score then 1 else 0 end)::float/
sum(case when location='Home' then 1 else 0 end)::float)::numeric(4,3)
as home,
(sum(case when location='Away' and team_score>opponent_score then 1 else 0 end)::float/
sum(case when location='Away' then 1 else 0 end)::float)::numeric(4,3)
as away,
(sum(case when location='Neutral' and team_score>opponent_score then 1 else 0 end)::float/
sum(case when location='Neutral' then 1 else 0 end)::float)::numeric(4,3)
as neutral,
count(*) as n
from ncaa_women.games
where
    team_id=426
and team_score>0
and opponent_score>0;
--and team_id < opponent_id;
