#!/bin/bash

psql lacrosse -f ncaa_sos/standardized_results_ot.sql

psql lacrosse -c "drop table ncaa._basic_factors;"
psql lacrosse -c "drop table ncaa._parameter_levels;"

psql lacrosse -c "vacuum analyze ncaa.results;"

R --vanilla < ncaa_sos/ncaa_lmer_ot.R

psql lacrosse -f ncaa_sos/normalize_factors.sql
psql lacrosse -f ncaa_sos/schedule_factors.sql

psql lacrosse -f ncaa_sos/connectivity.sql > ncaa_sos/connectivity.txt
psql lacrosse -f ncaa_sos/current_ranking.sql > ncaa_sos/current_ranking.txt
psql lacrosse -f ncaa_sos/division_ranking.sql > ncaa_sos/division_ranking.txt

psql lacrosse -f ncaa_sos/test_predictions.sql > ncaa_sos/test_predictions.txt

psql lacrosse -f ncaa_sos/predict_daily.sql > ncaa_sos/predict_daily.txt
psql lacrosse -f ncaa_sos/predict_spread.sql > ncaa_sos/predict_spread.txt

psql lacrosse -f ncaa_sos/predict_weekly.sql > ncaa_sos/predict_weekly.txt
