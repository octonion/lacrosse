begin;

drop table if exists ncaa_pbp._game_faceoffs;

create table ncaa_pbp._game_faceoffs (
       year			     integer,
       game_id			     integer,
       site			     text,
       team_id			     integer,
       o_div			     integer,
       fo_taken			     integer,
       fo_won			     integer,
       opponent_id		     integer,
       d_div			     integer,
       primary key (game_id,team_id)
);       

insert into ncaa_pbp._game_faceoffs
(year,game_id,site,team_id,o_div,fo_taken,fo_won,opponent_id,d_div)
(
select
ts1.year,
bs1.game_id as game_id,
(case when not(ts1.neutral_site) and ts1.home_game then 'offense_home'
      when not(ts1.neutral_site) and not(ts1.home_game) then 'defense_home'
      when ts1.neutral_site then 'neutral' end) as site,
per1.team_id as team_id,
t1.division_id as o_div,
bs1.fo_taken,
bs1.fo_won,
per2.team_id as opponent_id,
t2.division_id as d_div
--bs2.fo_taken,
--bs2.fo_won
--bs1.game_id,
--per.team_id,
--per.team_name,
--bs.section_id,
--bs.fo_taken,
--bs.fo_won
from ncaa_pbp.box_scores bs1
join ncaa_pbp.box_scores bs2
  on (bs2.game_id,bs2.section_id)=(bs1.game_id,1-bs1.section_id)
join ncaa_pbp.periods per1
  on (per1.game_id,per1.section_id)=(bs1.game_id,bs1.section_id)
join ncaa_pbp.periods per2
  on (per2.game_id,per2.section_id)=(bs2.game_id,bs2.section_id)
join ncaa_pbp.team_schedules ts1
  on (ts1.game_id,ts1.team_id)=(per1.game_id,per1.team_id)
join ncaa_pbp.team_schedules ts2
  on (ts2.game_id,ts2.team_id)=(per2.game_id,per2.team_id)
join ncaa_pbp.teams t1
  on (t1.team_id,t1.year)=(ts1.team_id,ts1.year)
join ncaa_pbp.teams t2
  on (t2.team_id,t2.year)=(ts2.team_id,ts2.year)

--join ncaa_pbp.periods per
--  on (per.game_id,per.section_id)=(bs.game_id,bs.section_id)
--join ncaa_pbp.team_schedules ts1
--  on (ts1.game_id,0)=(per.game_id,per.section_id)
--join ncaa_pbp.team_schedules ts2
--  on (ts2.game_id,1)=(per.game_id,per.section_id)
where
    bs1.player_name='Totals'
and bs2.player_name='Totals'
and bs1.section_id=0
and t1.division_id=1
and t2.division_id=1
and ts1.year=2015

union all

select

ts2.year,
bs2.game_id as game_id,
(case when not(ts2.neutral_site) and ts2.home_game then 'offensive_home'
      when not(ts2.neutral_site) and not(ts2.home_game) then 'defense_home'
      when ts2.neutral_site then 'neutral' end) as site,
per2.team_id as team_id,
t2.division_id as o_div,
bs2.fo_taken,
bs2.fo_won,
per1.team_id as opponent_id,
t1.division_id as d_div
--bs2.fo_taken,
--bs2.fo_won
--bs1.game_id,
--per.team_id,
--per.team_name,
--bs.section_id,
--bs.fo_taken,
--bs.fo_won
from ncaa_pbp.box_scores bs1
join ncaa_pbp.box_scores bs2
  on (bs2.game_id,bs2.section_id)=(bs1.game_id,1-bs1.section_id)
join ncaa_pbp.periods per1
  on (per1.game_id,per1.section_id)=(bs1.game_id,bs1.section_id)
join ncaa_pbp.periods per2
  on (per2.game_id,per2.section_id)=(bs2.game_id,bs2.section_id)
join ncaa_pbp.team_schedules ts1
  on (ts1.game_id,ts1.team_id)=(per1.game_id,per1.team_id)
join ncaa_pbp.team_schedules ts2
  on (ts2.game_id,ts2.team_id)=(per2.game_id,per2.team_id)
join ncaa_pbp.teams t1
  on (t1.team_id,t1.year)=(ts1.team_id,ts1.year)
join ncaa_pbp.teams t2
  on (t2.team_id,t2.year)=(ts2.team_id,ts2.year)

--join ncaa_pbp.periods per
--  on (per.game_id,per.section_id)=(bs.game_id,bs.section_id)
--join ncaa_pbp.team_schedules ts1
--  on (ts1.game_id,0)=(per.game_id,per.section_id)
--join ncaa_pbp.team_schedules ts2
--  on (ts2.game_id,1)=(per.game_id,per.section_id)
where
    bs1.player_name='Totals'
and bs2.player_name='Totals'
and bs1.section_id=0
--and t1.division_id=1
--and t2.division_id=1
--and ts1.year=2015
);

commit;

