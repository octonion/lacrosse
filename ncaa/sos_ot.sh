#!/bin/bash

psql lacrosse -c "drop table if exists ncaa.results;"

psql lacrosse -f sos/standardized_results_ot.sql

psql lacrosse -c "vacuum full verbose analyze ncaa.results;"

psql lacrosse -c "drop table ncaa._basic_factors;"
psql lacrosse -c "drop table ncaa._parameter_levels;"

R --vanilla -f sos/ncaa_lmer_ot.R

psql lacrosse -c "vacuum full verbose analyze ncaa._parameter_levels;"
psql lacrosse -c "vacuum full verbose analyze ncaa._basic_factors;"

psql lacrosse -f sos/normalize_factors.sql
psql lacrosse -c "vacuum full verbose analyze ncaa._factors;"

psql lacrosse -f sos/schedule_factors.sql
psql lacrosse -c "vacuum full verbose analyze ncaa._schedule_factors;"

psql lacrosse -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos/current_ranking.csv

psql lacrosse -f sos/connectivity.sql > sos/connectivity.txt

psql lacrosse -f sos/division_ranking.sql > sos/division_ranking.txt

psql lacrosse -f sos/test_predictions.sql > sos/test_predictions.txt

psql lacrosse -f sos/predict_daily.sql > sos/predict_daily.txt
cp /tmp/predict_daily.csv sos/predict_daily.csv

psql lacrosse -f sos/predict_spread.sql > sos/predict_spread.txt

psql lacrosse -f sos/predict_weekly.sql > sos/predict_weekly.txt
cp /tmp/predict_weekly.csv sos/predict_weekly.csv
