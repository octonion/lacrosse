begin;

create temporary table ps (
       year					integer,
       year_id					integer,
       division_id				integer,
       team_id					integer,
       team_name				text,
       jersey_number				text,
       player_id				integer,
       player_name				text,
       player_url				text,
       class_year				text,
       gp					integer,
       gs					integer,
       g					integer,
       gs2					integer,
       goals					integer,
       assists					integer,
       points					integer,
       shots					integer,
       shot_pct					float,
       sog					integer,
       sog_pct					float,
       gwg					integer,
       man_up_g					integer,
       man_down_g				integer,
       gb					integer,
       turnovers				integer,
       caused_turnovers				integer,
       fo_won					integer,
       fo_taken					integer,
       fo_pct					float,
       pen 					integer,
       pen_time					text,
       ggp					integer,
       ggs					integer,
       g_min					text,
       goals_allowed				integer,
       gaa					text,
       saves 					integer,
       save_pct					float,
       rc    					integer,
       yc    					integer,
--       clears					integer,
--       att					integer,
--       clear_pct				float,
       primary key (year_id,player_id),
       unique (year,player_id)
);

copy ps from '/tmp/player_summaries.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.player_summaries
(
year,year_id,division_id,team_id,team_name,
jersey_number,player_id,player_name,player_url,class_year,
gp,gs,g,gs2,
goals,assists,points,
shots,shot_pct,sog,sog_pct,gwg,man_up_g,man_down_g,gb,
turnovers,caused_turnovers,fo_won,fo_taken,
pen,pen_time,ggp,ggs,g_min,goals_allowed,gaa,saves,save_pct,rc,yc,
clears,att,clear_pct)
(
select
year,year_id,division_id,team_id,team_name,
jersey_number,player_id,player_name,player_url,class_year,
gp,gs,g,gs2,
goals,assists,points,
shots,shot_pct,sog,sog_pct,gwg,man_up_g,man_down_g,gb,
turnovers,caused_turnovers,fo_won,fo_taken,
pen,pen_time,ggp,ggs,g_min,goals_allowed,gaa,saves,save_pct,rc,yc,
NULL as clears,
NULL as att,
NULL as clear_pct
from ps
);

commit;
