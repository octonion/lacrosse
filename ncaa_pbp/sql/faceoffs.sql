begin;

drop table if exists ncaa_pbp._faceoffs;

create table ncaa_pbp._faceoffs (
       game_id			integer,
       event_id			integer,
       section_id		integer,
       player1			text,
       player2			text,
       winner_player		text,
       winner_team		text,
       penalty			boolean default false,
       primary key (game_id,event_id)
);

insert into ncaa_pbp._faceoffs
(game_id,event_id,section_id,player1,player2,winner_player,winner_team)
(
select

game_id,
event_id,
0 as section_id,
split_part(split_part(split_part(replace(team_text,'Faceoff ',''),'[',1),' won by ',1),' vs ',1),
split_part(split_part(split_part(replace(team_text,'Faceoff ',''),'[',1),' won by ',1),' vs ',2),
split_part(split_part(split_part(replace(team_text,'Faceoff ',''),'[',1),' won by ',1),' vs ',1),
replace(replace(split_part(split_part(replace(team_text,'Faceoff ',''),'[',1),' won by ',2),',',''),'.','')

from ncaa_pbp.play_by_play
where
team_text like 'Faceoff %'
);

insert into ncaa_pbp._faceoffs
(game_id,event_id,section_id,player1,player2,winner_player,winner_team)
(
select

game_id,
event_id,
1 as section_id,
split_part(split_part(split_part(replace(opponent_text,'Faceoff ',''),'[',1),' won by ',1),' vs ',1),
split_part(split_part(split_part(replace(opponent_text,'Faceoff ',''),'[',1),' won by ',1),' vs ',2),
split_part(split_part(split_part(replace(opponent_text,'Faceoff ',''),'[',1),' won by ',1),' vs ',2),
replace(replace(split_part(split_part(replace(opponent_text,'Faceoff ',''),'[',1),' won by ',2),',',''),'.','')

from ncaa_pbp.play_by_play
where
opponent_text like 'Faceoff %'
);

update ncaa_pbp._faceoffs
set winner_team=replace(winner_team,' (on faceoff violation)',''),
    penalty=TRUE
where winner_team like '%faceoff violation%';

update ncaa_pbp._faceoffs
set winner_team=trim(both from winner_team);

commit;
