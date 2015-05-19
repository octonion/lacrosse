begin;

select
row_number() over (order by estimate desc) as rk,
team_name,
exp(estimate)::numeric(4,3) as fo_str
from ncaa._fo_basic_factors bf
join ncaa_pbp.teams t
  on (t.year,t.team_id)=(split_part(level,'/',1)::integer,split_part(level,'/',2)::integer)
where
    factor='offense'
and t.year=2015
and t.division_id=1
order by fo_str desc;

copy (
select
row_number() over (order by estimate desc) as rk,
team_name,
exp(estimate)::numeric(4,3) as fo_str
from ncaa._fo_basic_factors bf
join ncaa_pbp.teams t
  on (t.year,t.team_id)=(split_part(level,'/',1)::integer,split_part(level,'/',2)::integer)
where
    factor='offense'
and t.year=2015
and t.division_id=1
order by fo_str desc
) to '/tmp/fo_current_ranking.csv' csv header;

commit;

