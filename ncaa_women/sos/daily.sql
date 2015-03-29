select
team_div_id as div,
game_date,
team_name,
team_score,
opponent_name,
opponent_score
from ncaa_women.results
where
year=2015
and game_date::date='2015/3/16'::date
and team_div_id=2
and pulled_id=team_id
and team_id<opponent_id
order by team_name;
