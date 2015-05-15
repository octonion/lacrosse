begin;

drop table if exists ncaa_pbp.play_by_play;

create table ncaa_pbp.play_by_play (
	game_id		      integer,
	period_id	      integer,
	event_id	      integer,
	time		      text,
	team_text	      text,
	team_score	      integer,
	opponent_score	      integer,
	score		      text,
	opponent_text	      text
--	primary key (game_id,period_id,event_id)
);

copy ncaa_pbp.play_by_play from '/tmp/play_by_play.csv' with delimiter as E'\t' csv;

commit;
