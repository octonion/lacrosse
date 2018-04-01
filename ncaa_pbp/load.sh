#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'lacrosse';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
#   cmd="psql template1 -t -c \"create database lacrosse\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
   cmd="createdb lacrosse"
   eval $cmd
fi

psql lacrosse -f schema/create_schema.sql

# Years with data

cp tsv/ncaa_years.tsv /tmp/years.tsv
psql lacrosse -f loaders/load_years.sql
rm /tmp/years.tsv

# Divisions by year with data

cp tsv/ncaa_years_divisions.tsv /tmp/years_divisions.tsv
psql lacrosse -f loaders/load_years_divisions.sql
rm /tmp/years_divisions.tsv

# Teams

tail -q -n+2 tsv/ncaa_teams_2*.tsv >> /tmp/teams.tsv
psql lacrosse -f loaders/load_teams.sql
rm /tmp/teams.tsv

# Team schedules

tail -q -n+2 tsv/ncaa_team_schedules_*.tsv >> /tmp/schedules.tsv
rpl -e ' *\t' '\t' /tmp/schedules.tsv
grep -v 'does not count' /tmp/schedules.tsv > /tmp/s.tsv
mv /tmp/s.tsv /tmp/schedules.tsv
psql lacrosse -f loaders/load_schedules.sql
rm /tmp/schedules.tsv

# Rosters

tail -q -n+2 tsv/ncaa_team_rosters_*.tsv >> /tmp/rosters.tsv
rpl -e '\t--\t' '\t\t' /tmp/rosters.tsv
rpl -e '\t-\t' '\t\t' /tmp/rosters.tsv
rpl -e '\tN/A\t' '\t\t' /tmp/rosters.tsv
psql lacrosse -f loaders/load_rosters.sql
rm /tmp/rosters.tsv

# Player summaries

tail -q -n+2 tsv/ncaa_player_summaries_*.tsv >> /tmp/player_summaries.tsv
rpl -q '""' '' /tmp/player_summaries.tsv
rpl -q ' ' '' /tmp/player_summaries.tsv
psql lacrosse -f loaders/load_player_summaries.sql
rm /tmp/player_summaries.tsv

exit

# Team summaries

tail -q -n+2 tsv/ncaa_team_summaries_*.tsv >> /tmp/team_summaries.tsv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.tsv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.tsv
rpl -q '""' '' /tmp/team_summaries.tsv
rpl -q ' ' '' /tmp/team_summaries.tsv
psql lacrosse -f loaders/load_team_summaries.sql
rm /tmp/team_summaries.tsv
