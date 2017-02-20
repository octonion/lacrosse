#!/bin/bash

./scrapers2/ncaa_teams.rb MLA $1 $2

./scrapers2/ncaa_team_rosters.rb $1 $2

./scrapers2/ncaa_summaries.rb $1 $2

#./scrapers2/ncaa_team_schedules_mt.rb $1 $2

#./scrapers2/ncaa_periods_stats_mt.rb $1 $2

#./scrapers2/ncaa_team_box_scores_mt.rb $1 $2

#./scrapers2/ncaa_play_by_play_mt.rb $1 $2
