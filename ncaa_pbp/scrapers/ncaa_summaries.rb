#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_sleep = 0
sleep_increment = 3
retries = 4

year = ARGV[0].to_i
division = ARGV[1]

ncaa_teams = CSV.read("tsv/ncaa_teams_#{year}_#{division}.tsv",
                      "r",
                      {:col_sep => "\t", :headers => TRUE})

ncaa_player_summaries = CSV.open(
  "tsv/ncaa_player_summaries_#{year}_#{division}.tsv",
  "w",
  {:col_sep => "\t"})

ncaa_team_summaries = CSV.open(
  "tsv/ncaa_team_summaries_#{year}_#{division}.tsv",
  "w",
  {:col_sep => "\t"})

# Headers for files
#Player	Pos	Goals	Assists	Points	Shots	SOG	Man-Up G	Man-Down G	GB	TO	CT	FO Won	FOs Taken	Pen	Pen Time	G Min	Goals Allowed	Saves	W	L	T	RC	YC	Clears	Att	Clear Pct

ncaa_player_summaries << [
  "year", "year_id", "division_id",
  "team_id", "team_name",
  "player_id", "player_name", "player_url",
  "class_year","position",
  "goals", "assists", "points", "shots", "sog",
  "man-up_g", "man-down_g",
  "gb", "to", "ct", "fo_won", "fos_taken",
  "pen", "pen_time",
  "g_min", "goals_allowed", "saves",
  "w", "l", "t", "rc", "yc", "clears", "att", "clear_pct"
]

ncaa_team_summaries << [
  "year", "year_id", "division_id",
  "team_id", "team_name",
  "player_id", "player_name", "player_url",
  "class_year","position",
  "goals", "assists", "points", "shots", "sog",
  "man-up_g", "man-down_g",
  "gb", "to", "ct", "fo_won", "fos_taken",
  "pen", "pen_time",
  "g_min", "goals_allowed", "saves",
  "w", "l", "t", "rc", "yc", "clears", "att", "clear_pct"
]

players_xpath = '//*[@id="stat_grid"]/tbody/tr'
teams_xpath = '//*[@id="stat_grid"]/tfoot/tr' #[position()>1]'

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sleep_time = base_sleep

ncaa_teams.each do |team|

  year = team["year"]
  year_id = team["year_id"]
  team_id = team["team_id"]
  team_name = team["team_name"]

  stat_url = "http://stats.ncaa.org/team/#{team_id}/stats/#{year_id}"

  #print "Sleep #{sleep_time} ... "
  #sleep sleep_time

  found_players = 0
  missing_id = 0

  tries = 0
  begin
    doc = agent.get(stat_url)
  rescue
    sleep_time += sleep_increment
    print "sleep #{sleep_time} ... "
    sleep sleep_time
    tries += 1
    if (tries > retries)
      next
    else
      retry
    end
  end

  sleep_time = base_sleep

  print "#{year} #{team_name} ..."

  doc.search(players_xpath).each do |player|

    row = [year, year_id, division, team_id, team_name]
    player.search("td").each_with_index do |element,i|
      case i
      when 1
        player_name = element.text.strip

        link = element.search("a").first
        if (link==nil)
          missing_id += 1
          link_url = nil
          player_id = nil
          player_url = nil
        else
          link_url = link.attributes["href"].text
          parameters = link_url.split("/")[-1]

          # player_id

          player_id = parameters.split("=")[2]

          # opponent URL

          player_url = base_url+link_url
        end

        found_players += 1
        row += [player_id, player_name, player_url]
      else
        field_string = element.text.strip

        row += [field_string]
      end
    end

    ncaa_player_summaries << row
    
  end

  print " #{found_players} players, #{missing_id} missing ID"

  found_summaries = 0
  doc.search(teams_xpath).each do |team|

    row = [year, year_id, division, team_id, team_name]
    team.search("td").each_with_index do |element,i|
        field_string = element.text.strip
        row += [field_string]
    end

    found_summaries += 1
    ncaa_team_summaries << row
    
  end

  print ", #{found_summaries} team summaries\n"

end
