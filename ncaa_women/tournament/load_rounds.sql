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

skellam(
exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor,
exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive*d.exp_factor,
'win') as team_p,

skellam(
exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor,
exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive*d.exp_factor,
'lose') as opponent_p

from ncaa_women.rounds r1
join ncaa_women.rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa_women._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa_women._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa_women.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join ncaa_women._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa_women._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa_women.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join ncaa_women._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa_women._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa_women._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_women._factors d
  on (d.parameter,d.level)=('field','defense_home')
join ncaa_women._factors y
  on (y.parameter,y.level)=('year',r1.year::text)
join ncaa_women._basic_factors i
  on (i.factor)=('(Intercept)')
where
  r1.year=2017
);

insert into ncaa_women.matrix_p
(year,field,team_id,opponent_id,team_p,opponent_p)
(select
r1.year,
'away',
r1.team_id,
r2.team_id,

skellam(
exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor*d.exp_factor,
exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*o.exp_factor*hddf.exp_factor*h.defensive,
'win') as team_p,

skellam(
exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor*d.exp_factor,
exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*o.exp_factor*hddf.exp_factor*h.defensive,
'lose') as opponent_p

from ncaa_women.rounds r1
join ncaa_women.rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa_women._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa_women._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa_women.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join ncaa_women._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa_women._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa_women.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join ncaa_women._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa_women._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa_women._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_women._factors d
  on (d.parameter,d.level)=('field','defense_home')
join ncaa_women._factors y
  on (y.parameter,y.level)=('year',r1.year::text)
join ncaa_women._basic_factors i
  on (i.factor)=('(Intercept)')
where
  r1.year=2017
);

insert into ncaa_women.matrix_p
(year,field,team_id,opponent_id,team_p,opponent_p)
(select
r1.year,
'neutral',
r1.team_id,
r2.team_id,

skellam(
exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor,
exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive,
'win') as team_p,

skellam(
exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor,
exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive,
'lose') as opponent_p

from ncaa_women.rounds r1
join ncaa_women.rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa_women._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa_women._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa_women.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join ncaa_women._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa_women._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa_women.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join ncaa_women._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa_women._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa_women._factors y
  on (y.parameter,y.level)=('year',r1.year::text)
join ncaa_women._basic_factors i
  on (i.factor)=('(Intercept)')
where
  r1.year=2017
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
join (select generate_series(1, 6) round_id) gs
  on TRUE
where
  r1.year=2017
);

-- 1-2 round seeds have home

update ncaa_women.matrix_field
set field='home'
from ncaa_women.rounds rt, ncaa_women.rounds ro
where
    (rt.year,rt.team_id)=
    (matrix_field.year,matrix_field.team_id)
and (ro.year,ro.team_id)=
    (matrix_field.year,matrix_field.opponent_id)
and rt.round_id=1
and ro.round_id=1
and matrix_field.round_id between 1 and 2
and rt.seed is not null;

update ncaa_women.matrix_field
set field='away'
from ncaa_women.rounds rt, ncaa_women.rounds ro
where
    (rt.year,rt.team_id)=
    (matrix_field.year,matrix_field.team_id)
and (ro.year,ro.team_id)=
    (matrix_field.year,matrix_field.opponent_id)
and rt.round_id=1
and ro.round_id=1
and matrix_field.round_id between 1 and 2
and ro.seed is not null;

/*
update ncaa_women.matrix_field
set field='home'
from ncaa_women.rounds r
where (r.year,r.team_id)=
      (matrix_field.year,matrix_field.team_id)
and r.round_id=1
and matrix_field.round_id between 1 and 2
and r.seed is not null;

update ncaa_women.matrix_field
set field='away'
from ncaa_women.rounds r
where (r.year,r.team_id)=
      (matrix_field.year,matrix_field.team_id)
and r.round_id=1
and matrix_field.round_id=2
and r.seed is null;
*/

commit;
