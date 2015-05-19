begin;

drop table if exists ncaa_pbp._team_game;

create table ncaa_pbp._team_game (
       game_id			 integer,
--       period_id		 integer,
--       event_id			 integer,
       section_id		 integer,
       team_name		 text,
       primary key (game_id,section_id)
);

insert into ncaa_pbp._team_game
(game_id,section_id,team_name)
(
select
distinct
game_id,
--period_id,
--event_id,
(
case when team_text is not null then 0
     when opponent_text is not null then 1
end) as section_id,
substring(split_part(coalesce(team_text,opponent_text),'at goalie for ',2) from 1 for length(split_part(coalesce(team_text,opponent_text),'at goalie for ',2))-1) as team_name
from ncaa_pbp.play_by_play
--where event_id in (0,1)
where TRUE
and split_part(coalesce(team_text,opponent_text),'at goalie for ',2)<>''
);

commit;
