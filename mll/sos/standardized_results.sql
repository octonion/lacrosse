begin;

drop table if exists mll.results;

create table mll.results (
	game_id		      integer,
	year		      integer,
	team_name	      text,
	team_id		      integer,
	opponent_name	      text,
	opponent_id	      integer,
	field		      text,
	team_score	      integer,
	opponent_score	      integer,
	game_length	      text
);

insert into mll.results
(game_id,year,
 team_name,team_id,
 opponent_name,opponent_id,
 field,
 team_score,opponent_score,game_length)
(
select
g.game_id,
g.year,
g.away_name,
g.away_id,
g.home_name,
g.home_id,
'defense_home' as field,
g.away_score,
g.home_score,
(case when g.overtime is null then '0 OT'
      else g.overtime end) as game_length
from mll.games g
where

TRUE
and g.away_score is not NULL
and g.home_score is not NULL

and g.away_score >= 0
and g.home_score >= 0

and g.away_id is not NULL
and g.home_id is not NULL
);

insert into mll.results
(game_id,year,
 team_name,team_id,
 opponent_name,opponent_id,
 field,
 team_score,opponent_score,game_length)
(
select
g.game_id,
g.year,
g.home_name,
g.home_id,
g.away_name,
g.away_id,
'offense_home' as field,
g.home_score,
g.away_score,
(case when g.overtime is null then '0 OT'
      else g.overtime end) as game_length
from mll.games g
where

TRUE
and g.away_score is not NULL
and g.home_score is not NULL

and g.away_score >= 0
and g.home_score >= 0

and g.away_id is not NULL
and g.home_id is not NULL
);

commit;
