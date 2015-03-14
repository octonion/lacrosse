#!/bin/bash

psql lacrosse -f sos/standardized_results.sql

psql lacrosse -c "drop table ncaa._basic_factors;"
psql lacrosse -c "drop table ncaa._parameter_levels;"

psql lacrosse -c "vacuum analyze ncaa.results;"

R --vanilla -f sos/ncaa_lmer.R

psql lacrosse -f sos/normalize_factors.sql
psql lacrosse -f sos/schedule_factors.sql

psql lacrosse -f sos/connectivity.sql > sos/connectivity.txt
psql lacrosse -f sos/current_ranking.sql > sos/current_ranking.txt
psql lacrosse -f sos/division_ranking.sql > sos/division_ranking.txt

psql lacrosse -f sos/test_predictions.sql > sos/test_predictions.txt

psql lacrosse -f sos/predict_daily.sql > sos/predict_daily.txt
psql lacrosse -f sos/predict_spread.sql > sos/predict_spread.txt

psql lacrosse -f sos/predict_weekly.sql > sos/predict_weekly.txt
