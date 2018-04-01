begin;

drop table if exists ncaa_pbp.player_summaries;

create table ncaa_pbp.player_summaries (
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
       position					text,
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
       clears					integer,
       att					integer,
       clear_pct				float,
       primary key (year_id,player_id),
       unique (year,player_id)
);

copy ncaa_pbp.player_summaries from '/tmp/player_summaries.tsv' with delimiter as E'\t' csv;

commit;
