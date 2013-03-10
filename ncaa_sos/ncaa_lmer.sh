#!/bin/bash

#psql lacrosse -f standardized_results.sql

psql lacrosse -c "drop table ncaa._basic_factors;"
psql lacrosse -c "drop table ncaa._parameter_levels;"
#psql lacrosse -c "drop table ncaa._factors;"
#psql lacrosse -c "drop table ncaa._schedule_factors;"
##psql lacrosse -c "drop table ncaa._game_results;"

R --vanilla < ncaa_lmer.R

sleep 10

psql lacrosse -f normalize_factors.sql
psql lacrosse -f schedule_factors.sql

psql lacrosse -f connectivity.sql > connectivity.txt
psql lacrosse -f current_ranking.sql > current_ranking.txt
psql lacrosse -f division_ranking.sql > division_ranking.txt

psql lacrosse -f test_predictions.sql > test_predictions.txt
