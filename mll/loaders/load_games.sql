begin;

drop table if exists mll.games;

create table mll.games (
	league_id	      integer,
	season_id	      integer,
	year		      integer,
	game_number	      text,
	away_id		      integer,
	away_name	      text,
	away_url	      text,
	away_score	      integer,
	home_id		      integer,
	home_name	      text,
	home_url	      text,
	home_score	      integer,
	game_date	      text,
	game_time	      text,
	score		      text,
	overtime	      text,
	game_id		      integer,
	flash_url	      text,
	boxscore_url	      text,
	location	      text,
	extra		      text
);

copy mll.games from '/tmp/games.csv' with delimiter as ',' csv quote as '"';

--alter table mll.games add column game_id serial primary key;

--update mll.games
--set game_length = trim(both ' -' from game_length);

commit;
