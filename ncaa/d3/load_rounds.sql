begin;

-- rounds

drop table if exists ncaa.rounds_d3;

create table ncaa.rounds_d3 (
	year				integer,
	round_id			integer,
	seed				integer,
	division_id			integer,
	team_id				integer,
	team_name			text,
	bracket				int[],
	p				float,
	primary key (year,round_id,team_id)
);

copy ncaa.rounds_d3 from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

-- matchup probabilities

drop table if exists ncaa.matrix_p_d3;

create table ncaa.matrix_p_d3 (
	year				integer,
	field				text,
	team_id				integer,
	opponent_id			integer,
	team_p				float,
	opponent_p			float,
	primary key (year,field,team_id,opponent_id)
);

insert into ncaa.matrix_p_d3
(year,field,team_id,opponent_id,team_p,opponent_p)
(select
r1.year,
'home',
r1.team_id,
r2.team_id,
(h.strength*o.exp_factor)^3.2/
((h.strength*o.exp_factor)^3.2+(v.strength*d.exp_factor)^3.2)
  as home_p,
(v.strength*d.exp_factor)^3.2/
((v.strength*d.exp_factor)^3.2+(h.strength*o.exp_factor)^3.2)
  as visitor_p
from ncaa.rounds_d3 r1
join ncaa.rounds_d3 r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa._factors d
  on (d.parameter,d.level)=('field','defense_home')
where
  r1.year=2015
);

insert into ncaa.matrix_p_d3
(year,field,team_id,opponent_id,team_p,opponent_p)
(select
r1.year,
'away',
r1.team_id,
r2.team_id,
(h.strength*d.exp_factor)^3.2/
((h.strength*d.exp_factor)^3.2+(v.strength*o.exp_factor)^3.2)
  as home_p,
(v.strength*o.exp_factor)^3.2/
((v.strength*o.exp_factor)^3.2+(h.strength*d.exp_factor)^3.2)
  as visitor_p
from ncaa.rounds_d3 r1
join ncaa.rounds_d3 r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa._factors d
  on (d.parameter,d.level)=('field','defense_home')
where
  r1.year=2015
);

insert into ncaa.matrix_p_d3
(year,field,team_id,opponent_id,team_p,opponent_p)
(select
r1.year,
'neutral',
r1.team_id,
r2.team_id,
(h.strength)^3.2/
((h.strength)^3.2+(v.strength)^3.2)
  as home_p,
(v.strength)^3.2/
((v.strength)^3.2+(h.strength)^3.2)
  as visitor_p
from ncaa.rounds_d3 r1
join ncaa.rounds_d3 r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
where
  r1.year=2015
);

-- home advantage

-- Determined by:

drop table if exists ncaa.matrix_field_d3;

create table ncaa.matrix_field_d3 (
	year				integer,
	round_id			integer,
	team_id				integer,
	opponent_id			integer,
	field				text,
	primary key (year,round_id,team_id,opponent_id)
);

insert into ncaa.matrix_field_d3
(year,round_id,team_id,opponent_id,field)
(select
r1.year,
gs.round_id,
r1.team_id,
r2.team_id,
'neutral'
from ncaa.rounds_d3 r1
join ncaa.rounds_d3 r2
  on (r2.year=r1.year and not(r2.team_id=r1.team_id))
join (select generate_series(1, 5) round_id) gs
  on TRUE
where
  r1.year=2015
);

-- Lower seeds have home

update ncaa.matrix_field_d3
set field='home'
from ncaa.rounds_d3 rt, ncaa.rounds_d3 ro
where
    (rt.year,rt.team_id)=
    (matrix_field_d3.year,matrix_field_d3.team_id)
and (ro.year,ro.team_id)=
    (matrix_field_d3.year,matrix_field_d3.opponent_id)
and rt.round_id=1
and ro.round_id=1
and matrix_field_d3.round_id between 2 and 4
and rt.seed < ro.seed;

update ncaa.matrix_field_d3
set field='away'
from ncaa.rounds_d3 rt, ncaa.rounds_d3 ro
where
    (rt.year,rt.team_id)=
    (matrix_field_d3.year,matrix_field_d3.team_id)
and (ro.year,ro.team_id)=
    (matrix_field_d3.year,matrix_field_d3.opponent_id)
and rt.round_id=1
and ro.round_id=1
and matrix_field_d3.round_id between 2 and 4
and rt.seed > ro.seed;

-- Denver

--update ncaa.matrix_field_d3
--set field='home'
--where (year,round_id,team_id)=(2015,3,183);

--update ncaa.matrix_field_d3
--set field='away'
--where (year,round_id,opponent_id)=(2015,3,183);

commit;
