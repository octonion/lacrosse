#!/bin/bash

psql lacrosse -c "drop table if exists nll.results;"

psql lacrosse -f sos/standardized_results.sql

psql lacrosse -c "vacuum full verbose analyze nll.results;"

psql lacrosse -c "drop table nll._basic_factors;"
psql lacrosse -c "drop table nll._parameter_levels;"

R --vanilla -f sos/lmer.R

psql lacrosse -c "vacuum full verbose analyze nll._parameter_levels;"
psql lacrosse -c "vacuum full verbose analyze nll._basic_factors;"

psql lacrosse -f sos/normalize_factors.sql
psql lacrosse -c "vacuum full verbose analyze nll._factors;"

psql lacrosse -f sos/schedule_factors.sql
psql lacrosse -c "vacuum full verbose analyze nll._schedule_factors;"

psql lacrosse -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos/current_ranking.csv

psql lacrosse -f sos/predict_daily.sql > sos/predict_daily.txt
cp /tmp/predict_daily.csv sos/predict_daily.csv

psql lacrosse -f sos/predict_weekly.sql > sos/predict_weekly.txt
cp /tmp/predict_weekly.csv sos/predict_weekly.csv
