begin;

create temporary table r (
       rk	 serial,
       team 	 text,
       team_id integer,
       div_id	 integer,
       year	 integer,
       str	 numeric(5,3),
--       o_div	 numeric(4,3),
--       d_div	 numeric(4,3),
       ofs	 numeric(5,3),
       dfs	 numeric(5,3),
       sos	 numeric(5,3)
);

insert into r
(team,team_id,div_id,year,str,ofs,dfs,sos)
(
select
coalesce(sd.team_name,sf.team_id::text),
sf.team_id,
sd.div_id as div_id,
sf.year,
(sf.strength*o.exp_factor/d.exp_factor)::numeric(5,3) as str,
--o.exp_factor::numeric(5,3) as o_div,
--d.exp_factor::numeric(5,3) as d_div,
(offensive*o.exp_factor)::numeric(5,3) as ofs,
(defensive*d.exp_factor)::numeric(5,3) as dfs,
schedule_strength::numeric(5,3) as sos
from ncaa_women._schedule_factors sf
--join ncaa_women.teams s
--  on (s.team_id)=(sf.team_id)
join ncaa_women.teams_divisions sd
--  on (sd.team_id)=(sf.team_id)
  on (sd.team_id,sd.year)=(sf.team_id,sf.year)
join ncaa_women._factors o
  on (o.parameter,o.level::integer)=('o_div',sd.div_id)
join ncaa_women._factors d
  on (d.parameter,d.level::integer)=('d_div',sd.div_id)
where sf.year in (2017)
order by str desc);

select
rk,
team,
'D'||div_id as div,
str,
ofs,
dfs,
sos
from r
order by rk asc;

select
row_number() over (order by str desc nulls last) as rk,
team,
'D'||div_id as div,
str,ofs,dfs,sos
from r
where div_id=1
order by rk asc;

select
row_number() over (order by str desc nulls last) as rk,
team,
'D'||div_id as div,
str,ofs,dfs,sos
from r
where div_id=2
order by rk asc;

select
row_number() over (order by str desc nulls last) as rk,
team,
'D'||div_id as div,
str,ofs,dfs,sos
from r
where div_id=3
order by rk asc;

copy
(
select
rk,
team,
'D'||div_id::text as div,
str,
ofs,
dfs,
sos
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;

commit;
