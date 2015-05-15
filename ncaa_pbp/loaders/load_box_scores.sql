begin;

drop table if exists ncaa_pbp.box_scores;

create table ncaa_pbp.box_scores (
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
       yc    					integer,
       clears					integer,
       att					integer,
       clear_pct				float
       
-- this will fail if the two teams are in different divisions
-- best fix?
--       primary key (game_id, section_id, player_name, position)
);

copy ncaa_pbp.box_scores from '/tmp/box_scores.csv' with delimiter as e'\t' csv;

commit;
