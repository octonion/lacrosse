begin;

select round_id as rd,
r.team_name as name,
p::numeric(4,3) as p
from ncaa_women.rounds_d3 r
join ncaa_women.teams t
 on (t.team_id)=(r.team_id)
where TRUE --round_id=2
and p<1.0
order by round_id asc,p desc;

copy
(
select round_id as rd,
r.team_name as name,
p::numeric(4,3) as p
from ncaa_women.rounds_d3 r
join ncaa_women.teams t
 on (t.team_id)=(r.team_id)
where TRUE --round_id=2
and p<1.0
order by round_id asc,p desc
)
to '/tmp/round_p.csv' csv header;

commit;
