begin;

create temporary table d (
       year	       integer,
       player_id       integer,
       team_id	       integer,
       null_team_id    integer,
       primary key (year,player_id)
);

insert into d
(year,player_id,team_id,null_team_id)
(
select
s1.year,
s1.player_id,
s1.team_id,
s2.team_id
from ncaa.statistics s1
join ncaa.statistics s2
  on (s1.year,s1.player_id)=(s2.year,s2.player_id)
where
    s1.gp is not null
and s2.gp is null
and not(s1.team_id=s2.team_id)
);

delete from ncaa.statistics
where
(year,team_id,player_id) in
(select year,null_team_id,player_id from d);

delete from ncaa.statistics
where (year,team_id,player_id)=(2016,191,1771905);

delete from ncaa.statistics
where (year,team_id,player_id)=(2016,562,1644782);
commit;
