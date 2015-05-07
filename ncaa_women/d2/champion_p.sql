begin;

select
r.team_name,p::numeric(4,3)
from ncaa_women.rounds_d2 r
join ncaa_women.teams t
  on (t.team_id)=(r.team_id)
where round_id=4
order by p desc;

copy
(
select
r.team_name,p::numeric(4,3)
from ncaa_women.rounds_d2 r
join ncaa_women.teams t
  on (t.team_id)=(r.team_id)
where round_id=4
order by p desc
) to '/tmp/champion_p.csv' csv header;

commit;
