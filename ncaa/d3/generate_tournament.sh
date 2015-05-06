#!/bin/bash

cp rounds_2015.csv /tmp/rounds.csv
#cp rounds_updated.csv /tmp/rounds.csv
psql lacrosse -f load_rounds.sql
rm /tmp/rounds.csv

psql lacrosse -f update_round.sql

rpl "round_id=1" "round_id=2" update_round.sql
psql lacrosse -f update_round.sql

rpl "round_id=2" "round_id=3" update_round.sql
psql lacrosse -f update_round.sql

rpl "round_id=3" "round_id=4" update_round.sql
psql lacrosse -f update_round.sql

rpl "round_id=4" "round_id=5" update_round.sql
psql lacrosse -f update_round.sql

rpl "round_id=5" "round_id=1" update_round.sql

psql lacrosse -f round_p.sql > round_p.txt
cp /tmp/round_p.csv .

psql lacrosse -f champion_p.sql > champion_p.txt
cp /tmp/champion_p.csv .
