begin;

drop table if exists ncaa.teams;

create table ncaa.teams (
        team_id               integer,
        team_name             text,
	primary key (team_id)
);

copy ncaa.teams from '/tmp/ncaa_teams.csv' with delimiter as ',' csv;

commit;
