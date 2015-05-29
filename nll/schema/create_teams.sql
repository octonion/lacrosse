begin;

drop table if exists nll.teams;

create table nll.teams (
       year	       integer,
       team_id	       integer,
       team_name       text,
       primary key (year,team_id)
);

insert into nll.teams
(year,team_id,team_name)
(
select
year,
home_id,
home_name
from nll.games
union
select
year,
away_id,
away_name
from nll.games
);

commit;
