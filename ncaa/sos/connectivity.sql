begin;

select
r.year,
t.div_id as div,
o.div_id as div,
sum(case when r.team_score>r.opponent_score then 1 else 0 end) as won,
sum(case when r.team_score<r.opponent_score then 1 else 0 end) as lost,
sum(case when r.team_score=r.opponent_score then 1 else 0 end) as tied,
count(*)
from ncaa.results r
left join ncaa.teams_divisions t
  on (t.team_id,t.year)=(r.team_id,r.year)
left join ncaa.teams_divisions o
  on (o.team_id,o.year)=(r.opponent_id,r.year)
where
    t.div_id <= o.div_id
and r.pulled_id = least(r.team_id,r.opponent_id)
--and r.team_name < r.opponent_name
--and r.field in ('none','offense_home')
and r.team_score > 0
and r.opponent_score > 0
and r.year between 2002 and 2016
group by r.year,t.div_id,o.div_id
order by r.year,t.div_id,o.div_id;

commit;
