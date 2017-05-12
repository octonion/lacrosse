begin;

drop table if exists ncaa_women.games;

create table ncaa_women.games (
	year		      integer,
        team_name	      text,
        team_id		      integer,
        opponent_name         text,
        opponent_id           integer,
        game_date             text,
        team_score            integer,
        opponent_score        integer,
        location	      text,
        neutral_site_location text,
        game_length           text,
        attendance            text
);

copy ncaa_women.games from '/tmp/games.csv' with delimiter as ',' csv quote as '"';

alter table ncaa_women.games add column game_id serial primary key;

--update ncaa_women.games
--set game_length = trim(both ' -' from game_length);

update ncaa_women.games
  set game_length = ''
where game_length like '-%';

update ncaa_women.games
  set game_length = ''
where abs(team_score-opponent_score)>1;

commit;
