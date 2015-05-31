#!/bin/bash

psql lacrosse -c "drop table if exists mll.results;"

psql lacrosse -f sos/standardized_results.sql

psql lacrosse -c "vacuum full verbose analyze mll.results;"

psql lacrosse -c "drop table mll._basic_factors;"
psql lacrosse -c "drop table mll._parameter_levels;"

R --vanilla -f sos/lmer.R

psql lacrosse -c "vacuum full verbose analyze mll._parameter_levels;"
psql lacrosse -c "vacuum full verbose analyze mll._basic_factors;"

psql lacrosse -f sos/normalize_factors.sql
psql lacrosse -c "vacuum full verbose analyze mll._factors;"

psql lacrosse -f sos/schedule_factors.sql
psql lacrosse -c "vacuum full verbose analyze mll._schedule_factors;"

psql lacrosse -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos/current_ranking.csv

psql lacrosse -f sos/predict_daily.sql > sos/predict_daily.txt
cp /tmp/predict_daily.csv sos/predict_daily.csv

psql lacrosse -f sos/predict_weekly.sql > sos/predict_weekly.txt
cp /tmp/predict_weekly.csv sos/predict_weekly.csv
