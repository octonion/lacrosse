begin;

drop table if exists ncaa.statistics;

create table ncaa.statistics (
        team_name             text,
        team_id               integer,
	year		      integer,
	player_name	      text,
	player_id	      integer,
	class		      text,
	academic_year	      text,
	position	      text,
	gp		      integer,
	goals		      integer,
	gpg		      float,
	assists		      integer,
	apg		      float,
	tp		      integer,
	ppg		      float,
	ground_balls	      integer,
	gbpg		      float,
	won		      integer,
	lost		      integer,
	pct		      float,
	min		      text,
	ga		      integer,
	ga_avg		      float,
	saves		      integer,
	save_pct	      float
--	primary key (player_id,year)

);

copy ncaa.statistics from '/tmp/statistics.csv' with delimiter as ',' csv;

commit;
