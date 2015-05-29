begin;

drop table if exists mll.teams;

create table mll.teams (
       year	       integer,
       team_id	       integer,
       team_name       text,
       primary key (year,team_id)
);

insert into mll.teams
(year,team_id,team_name)
(
select
year,
home_id,
home_name
from mll.games
union
select
year,
away_id,
away_name
from mll.games
);

commit;
