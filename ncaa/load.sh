#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'lacrosse';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb lacrosse;"
   eval $cmd
fi

psql lacrosse -f schema/create_schema.sql

tail -q -n+2 csv/ncaa_games_*.csv > /tmp/ncaa_games.csv
psql lacrosse -f loaders/load_ncaa_games.sql
rm /tmp/ncaa_games.csv

#cat ncaa/ncaa_players_*.csv > /tmp/ncaa_statistics.csv
#rpl ",-," ",," /tmp/ncaa_statistics.csv
#rpl ",-," ",," /tmp/ncaa_statistics.csv
#rpl ".," "," /tmp/ncaa_statistics.csv
#rpl ".0," "," /tmp/ncaa_statistics.csv
#rpl ".00," "," /tmp/ncaa_statistics.csv
#rpl ".000," "," /tmp/ncaa_statistics.csv
#rpl -e ",-\n" ",\n" /tmp/ncaa_statistics.csv
#psql lacrosse -f load_ncaa_statistics.sql
#rm /tmp/ncaa_statistics.csv

#psql lacrosse -f create_ncaa_players.sql

cp csv/ncaa_teams.csv /tmp/ncaa_teams.csv
psql lacrosse -f loaders/load_ncaa_teams.sql
rm /tmp/ncaa_teams.csv

cp csv/ncaa_divisions.csv /tmp/ncaa_divisions.csv
psql lacrosse -f loaders/load_ncaa_divisions.sql
rm /tmp/ncaa_divisions.csv

#cp ncaa/ncaa_colors.csv /tmp/ncaa_colors.csv
#psql lacrosse -f load_ncaa_colors.sql
#rm /tmp/ncaa_colors.csv

cp csv/conferences.tsv /tmp/conferences.tsv
psql lacrosse -f loaders/load_conferences.sql
rm /tmp/conferences.tsv

cp csv/conferences_teams.tsv /tmp/conferences_teams.tsv
psql lacrosse -f loaders/load_conferences_teams.sql
rm /tmp/conferences_teams.tsv
