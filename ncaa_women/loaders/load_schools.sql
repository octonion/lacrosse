begin;

create table ncaa_women.teams (
        team_id               integer,
        team_name             text,
	primary key (team_id)
);

copy ncaa_women.teams from '/tmp/teams.csv' with delimiter as ',' csv;

commit;
