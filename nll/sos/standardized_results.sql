begin;

drop table if exists nll.results;

create table nll.results (
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

insert into nll.results
(game_id,year,
 team_name,team_id,
 opponent_name,opponent_id,
 field,
 team_score,opponent_score,game_length)
(
select
g.game_id,
g.year,
trim(both from g.away_name),
g.away_id,
trim(both from g.home_name),
g.home_id,
'Away' as field,
g.away_score,
g.home_score,
(case when g.overtime is null then '0 OT'
      else g.overtime end) as game_length
from nll.games g
where

TRUE
and g.away_score is not NULL
and g.home_score is not NULL

and g.away_score >= 0
and g.home_score >= 0

and g.away_id is not NULL
and g.home_id is not NULL
);

insert into nll.results
(game_id,year,
 team_name,team_id,
 opponent_name,opponent_id,
 field,
 team_score,opponent_score,game_length)
(
select
g.game_id,
g.year,
trim(both from g.home_name),
g.home_id,
trim(both from g.away_name),
g.away_id,
'Home' as field,
g.home_score,
g.away_score,
(case when g.overtime is null then '0 OT'
      else g.overtime end) as game_length
from nll.games g
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
