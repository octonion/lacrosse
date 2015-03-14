begin;

drop table if exists ncaa.teams_divisions;

create table ncaa.teams_divisions (
	sport_code		text,
	team_name		text,
	team_id		integer,
	pulled_name		text,
	javascript		text,
	year			integer,
	div_id			integer,
        team_year		text,
	sport			text,
	division		text,
	primary key (team_id,year)
);

copy ncaa.teams_divisions from '/tmp/ncaa_divisions.csv' with delimiter as ',' csv quote as '"';

-- Temporary fix for 2015

insert into ncaa.teams_divisions
(sport_code,team_name,team_id,pulled_name,javascript,year,div_id,team_year,sport,division)
(
select sport_code,team_name,team_id,pulled_name,javascript,2015,div_id,team_year,sport,division
from ncaa.teams_divisions
where year=2014
and (team_id,2015) not in
(select team_id,year from ncaa.teams_divisions)
);

/*
create table ncaa.teams_divisions (
	team_id		integer,
	division		text,
	primary key (team_id)
);

copy ncaa.teams_divisions from '/tmp/ncaa_teams_divisions.csv' with delimiter as ',' csv header quote as '"';

alter table ncaa.teams_divisions add column div_id integer;

update ncaa.teams_divisions
set div_id=length(division);
*/

commit;
