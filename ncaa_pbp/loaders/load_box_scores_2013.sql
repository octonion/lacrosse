begin;

create temporary table bs (
       game_id					integer,
       section_id				integer,
       player_id				integer,
       player_name				text,
       player_url				text,
       starter					boolean,
       position					text,
       goals					integer,
       assists					integer,
       points					integer,
       shots					integer,
       sog					integer,
       man_up_g					integer,
       man_down_g				integer,
       gb					integer,
       turnovers				integer,
       caused_turnovers				integer,
       fo_won					integer,
       fos_taken				integer,
       pen 					integer,
       pen_time					integer,
       g_min					integer,
       goals_allowed				integer,
       saves 					integer,
       w     					integer,
       l     					integer,
       t     					integer,
       rc    					integer,
       yc    					integer
--       clears					integer,
--       att					integer,
--       clear_pct				float
);

copy bs from '/tmp/box_scores.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.box_scores
(
game_id,section_id,player_id,player_name,player_url,starter,position,
goals,assists,points,shots,sog,man_up_g,man_down_g,gb,
turnovers,caused_turnovers,fo_won,fos_taken,
pen,pen_time,g_min,goals_allowed,saves,w,l,t,rc,yc,clears,att,clear_pct)
(
select
game_id,section_id,player_id,player_name,player_url,starter,position,
goals,assists,points,shots,sog,man_up_g,man_down_g,gb,
turnovers,caused_turnovers,fo_won,fos_taken,
pen,pen_time,g_min,goals_allowed,saves,w,l,t,rc,yc,
NULL as clears,
NULL as att,
NULL as clear_pct
from bs
);

commit;
