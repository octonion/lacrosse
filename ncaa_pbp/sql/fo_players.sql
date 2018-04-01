copy
(
select
ps.player_name as player,
ps.team_name as team,
sf.schedule_strength::numeric(3,2) as team_sos,
ps.class_year as class,
ps.fo_won as won,
ps.fo_taken as take,
ps.fo_pct as fo_pct
from ncaa_pbp.player_summaries ps
join ncaa._schedule_factors sf
  on (sf.year,sf.team_id)=(ps.year,ps.team_id)
where ps.year=2018
and ps.class_year='Sr'
and ps.fo_taken >= 100
and ps.fo_pct >= 0.60
order by ps.fo_pct desc
)
to '/tmp/fo_players.csv' csv header;
