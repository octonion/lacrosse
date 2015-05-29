#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'lacrosse';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb lacrosse;"
   eval $cmd
fi

psql lacrosse -f schema/create_schema.sql

cat csv/games_*.csv >> /tmp/games.csv
rpl -q '""' '' /tmp/games.csv
psql lacrosse -f loaders/load_games.sql
rm /tmp/games.csv

psql lacrosse -f schema/create_teams.sql
