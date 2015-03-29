#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'lacrosse';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb lacrosse;"
   eval $cmd
fi

psql lacrosse -f schema/create_schema.sql

tail -q -n+2 csv/ncaa_games_*.csv > /tmp/games.csv
psql lacrosse -f loaders/load_games.sql
rm /tmp/games.csv

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

cp csv/ncaa_schools.csv /tmp/teams.csv
psql lacrosse -f loaders/load_schools.sql
rm /tmp/teams.csv

cp csv/ncaa_divisions.csv /tmp/divisions.csv
psql lacrosse -f loaders/load_divisions.sql
rm /tmp/divisions.csv

#cp ncaa/ncaa_colors.csv /tmp/ncaa_colors.csv
#psql lacrosse -f load_ncaa_colors.sql
#rm /tmp/ncaa_colors.csv
