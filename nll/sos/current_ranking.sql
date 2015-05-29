begin;

create temporary table r (
       rk	 serial,
       team 	 text,
       team_id integer,
       year	 integer,
       str	 numeric(4,3),
       ofs	 numeric(4,3),
       dfs	 numeric(4,3),
       sos	 numeric(4,3)
);

insert into r
(team,team_id,year,str,ofs,dfs,sos)
(
select
t.team_name,
t.team_id,
sf.year,
(sf.strength)::numeric(4,3) as str,
(offensive)::numeric(4,3) as ofs,
(defensive)::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from nll._schedule_factors sf
join nll.teams t
  on (t.year,t.team_id)=(sf.year,sf.team_id)
where sf.year in (2015)
order by str desc);

select
rk,team,str,ofs,dfs,sos
from r
order by rk asc;

copy (
select
rk,
team,
str,
ofs,
dfs,
sos
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;

commit;
