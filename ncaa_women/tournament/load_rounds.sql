begin;

-- rounds

drop table if exists ncaa_women.rounds;

create table ncaa_women.rounds (
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

copy ncaa_women.rounds from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

-- matchup probabilities

drop table if exists ncaa_women.matrix_p;

create table ncaa_women.matrix_p (
	year				integer,
	field				text,
	team_id				integer,
	opponent_id			integer,
	team_p				float,
	opponent_p			float,
	primary key (year,field,team_id,opponent_id)
);

insert into ncaa_women.matrix_p
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
from ncaa_women.rounds r1
join ncaa_women.rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa_women._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa_women._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa_women._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_women._factors d
  on (d.parameter,d.level)=('field','defense_home')
where
  r1.year=2015
);

insert into ncaa_women.matrix_p
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
from ncaa_women.rounds r1
join ncaa_women.rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa_women._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa_women._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa_women._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_women._factors d
  on (d.parameter,d.level)=('field','defense_home')
where
  r1.year=2015
);

insert into ncaa_women.matrix_p
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
from ncaa_women.rounds r1
join ncaa_women.rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa_women._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa_women._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
where
  r1.year=2015
);

-- home advantage

-- Determined by:

drop table if exists ncaa_women.matrix_field;

create table ncaa_women.matrix_field (
	year				integer,
	round_id			integer,
	team_id				integer,
	opponent_id			integer,
	field				text,
	primary key (year,round_id,team_id,opponent_id)
);

insert into ncaa_women.matrix_field
(year,round_id,team_id,opponent_id,field)
(select
r1.year,
gs.round_id,
r1.team_id,
r2.team_id,
'neutral'
from ncaa_women.rounds r1
join ncaa_women.rounds r2
  on (r2.year=r1.year and not(r2.team_id=r1.team_id))
join (select generate_series(1, 5) round_id) gs
  on TRUE
where
  r1.year=2015
);

-- 1st, 2nd, 3rd round seeds have home

update ncaa_women.matrix_field
set field='home'
from ncaa_women.rounds r1, ncaa_women.rounds r2
where
    (r1.year,r1.round_id,r1.team_id)=
    (matrix_field.year,1,matrix_field.team_id)
and (r2.year,r2.round_id,r2.team_id)=
    (matrix_field.year,1,matrix_field.opponent_id)
and matrix_field.round_id in (2,3,4)
and ((r1.seed is not null and r2.seed is null) or
     (r1.seed < r2.seed))
;

update ncaa_women.matrix_field
set field='away'
from ncaa_women.rounds r1, ncaa_women.rounds r2
where
    (r1.year,r1.round_id,r1.team_id)=
    (matrix_field.year,1,matrix_field.team_id)
and (r2.year,r2.round_id,r2.team_id)=
    (matrix_field.year,1,matrix_field.opponent_id)
and matrix_field.round_id in (2,3,4)
and ((r1.seed is null and r2.seed is not null) or
     (r1.seed > r2.seed))
;

-- 4th and 5th rounds in Philadelpha; give Penn and Penn St home

-- Penn

update ncaa_women.matrix_field
set field='home'
where (year,round_id,team_id)=(2015,5,540);

update ncaa_women.matrix_field
set field='home'
where (year,round_id,team_id)=(2015,6,540);

update ncaa_women.matrix_field
set field='away'
where (year,round_id,opponent_id)=(2015,5,540);

update ncaa_women.matrix_field
set field='away'
where (year,round_id,opponent_id)=(2015,6,540);

-- Penn St

update ncaa_women.matrix_field
set field='home'
where (year,round_id,team_id)=(2015,5,539);

update ncaa_women.matrix_field
set field='home'
where (year,round_id,team_id)=(2015,6,539);

update ncaa_women.matrix_field
set field='away'
where (year,round_id,opponent_id)=(2015,5,539);

update ncaa_women.matrix_field
set field='away'
where (year,round_id,opponent_id)=(2015,6,539);

-- Penn vs Penn St is neutral

update ncaa_women.matrix_field
set field='neutral'
where (year,round_id,team_id,opponent_id)=(2015,6,539,540);

update ncaa_women.matrix_field
set field='neutral'
where (year,round_id,team_id,opponent_id)=(2015,6,540,539);

commit;
