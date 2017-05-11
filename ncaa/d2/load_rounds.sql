begin;

-- rounds

drop table if exists ncaa.rounds_d2;

create table ncaa.rounds_d2 (
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

copy ncaa.rounds_d2 from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

-- matchup probabilities

drop table if exists ncaa.matrix_p_d2;

create table ncaa.matrix_p_d2 (
	year				integer,
	field				text,
	team_id				integer,
	opponent_id			integer,
	team_p				float,
	opponent_p			float,
	primary key (year,field,team_id,opponent_id)
);

insert into ncaa.matrix_p_d2
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

from ncaa.rounds_d2 r1
join ncaa.rounds_d2 r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join ncaa._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join ncaa._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa._factors d
  on (d.parameter,d.level)=('field','defense_home')
join ncaa._factors y
  on (y.parameter,y.level)=('year',r1.year::text)
join ncaa._basic_factors i
  on (i.factor)=('(Intercept)')
where
  r1.year=2017
);

insert into ncaa.matrix_p_d2
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

from ncaa.rounds_d2 r1
join ncaa.rounds_d2 r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join ncaa._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join ncaa._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa._factors d
  on (d.parameter,d.level)=('field','defense_home')
join ncaa._factors y
  on (y.parameter,y.level)=('year',r1.year::text)
join ncaa._basic_factors i
  on (i.factor)=('(Intercept)')
where
  r1.year=2017
);

insert into ncaa.matrix_p_d2
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

from ncaa.rounds_d2 r1
join ncaa.rounds_d2 r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ncaa._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join ncaa._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join ncaa.teams_divisions hd
  on (hd.year,hd.team_id)=(h.year,h.team_id)
join ncaa._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa.teams_divisions vd
  on (vd.year,vd.team_id)=(v.year,v.team_id)
join ncaa._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa._factors y
  on (y.parameter,y.level)=('year',r1.year::text)
join ncaa._basic_factors i
  on (i.factor)=('(Intercept)')
where
  r1.year=2017
);

-- Home advantage

drop table if exists ncaa.matrix_field_d2;

create table ncaa.matrix_field_d2 (
	year				integer,
	round_id			integer,
	team_id				integer,
	opponent_id			integer,
	field				text,
	primary key (year,round_id,team_id,opponent_id)
);

insert into ncaa.matrix_field_d2
(year,round_id,team_id,opponent_id,field)
(select
r1.year,
gs.round_id,
r1.team_id,
r2.team_id,
'neutral'
from ncaa.rounds_d2 r1
join ncaa.rounds_d2 r2
  on (r2.year=r1.year and not(r2.team_id=r1.team_id))
join (select generate_series(1, 3) round_id) gs
  on TRUE
where
  r1.year=2017
);

-- Lower seeds have home

update ncaa.matrix_field_d2
set field='home'
from ncaa.rounds_d2 rt, ncaa.rounds_d2 ro
where
    (rt.year,rt.team_id)=
    (matrix_field_d2.year,matrix_field_d2.team_id)
and (ro.year,ro.team_id)=
    (matrix_field_d2.year,matrix_field_d2.opponent_id)
and rt.round_id=1
and ro.round_id=1
and matrix_field_d2.round_id between 1 and 2
and rt.seed < ro.seed;

update ncaa.matrix_field_d2
set field='away'
from ncaa.rounds_d2 rt, ncaa.rounds_d2 ro
where
    (rt.year,rt.team_id)=
    (matrix_field_d2.year,matrix_field_d2.team_id)
and (ro.year,ro.team_id)=
    (matrix_field_d2.year,matrix_field_d2.opponent_id)
and rt.round_id=1
and ro.round_id=1
and matrix_field_d2.round_id between 1 and 2
and rt.seed > ro.seed;

commit;
