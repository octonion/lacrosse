#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

nthreads = 1

base_sleep = 0
sleep_increment = 3
retries = 4

year = ARGV[0].to_i
division = ARGV[1].to_i

ncaa_teams = CSV.open("tsv/ncaa_teams_#{year}_#{division}.tsv",
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

#Jersey	Player	Yr	GP	GS	G	GS	Goals	Assists	Points	Shots	Shot PCT	SOG	SOG PCT	GWG	Man-Up G	Man-Down G	GB	TO	CT	FO Won	FOs Taken	FO Pct	Pen	Pen Time	GGP	GGS	G Min	Goals Allowed	GAA	Saves	Save Pct	RC	YC	Clears	Att	Clear Pct
#ncaa_player_summaries << [
#  "year", "year_id",
#  "team_id", "team_name",
#  "position",
#  "player_id", "player_name", "player_url",
#  "class_year",
#  "goals", "assists", "points", "shots", "sog",
#  "man-up_g", "man-down_g", "gb", "to", "ct",
#  "fo_won", "fos_taken",
#  "pen", "pen_time",
#  "g_min", "goals_allowed",
#  "saves", "w", "l", "t", "rc", "yc", "clears", "att", "clear_pct"
#]

#Jersey	Player	Yr	GP	GS	G	GS	Goals	Assists	Points	Shots	Shot PCT	SOG	SOG PCT	GWG	Man-Up G	Man-Down G	GB	TO	CT	FO Won	FOs Taken	FO Pct	Pen	Pen Time	GGP	GGS	G Min	Goals Allowed	GAA	Saves	Save Pct	RC	YC	Clears	Att	Clear Pct
ncaa_player_summaries << [
  "year", "year_id",
  "team_id", "team_name",
  "position",
  "player_id", "player_name", "player_url",
  "class_year",
  "gp", "gs", "g", "gs2",
  "goals", "assists", "points", "shots", "shot_pct",
  "sog", "sog_pct",
  "gwg",
  "man-up_g", "man-down_g",
  "gb", "to", "ct",
  "fo_won", "fos_taken", "fo_pct",
  "pen", "pen_time",
  "ggp", "ggs",
  "g_min", "goals_allowed",
  "gaa",
  "saves", "save_pct",
  "rc", "yc", "clears", "att", "clear_pct"
]

ncaa_team_summaries << [
  "year", "year_id",
  "team_id", "team_name",
  "position",
  "player_name",
  "class_year",
  "gp", "gs", "g", "gs2",
  "goals", "assists", "points", "shots", "shot_pct",
  "sog", "sog_pct",
  "gwg",
  "man-up_g", "man-down_g",
  "gb", "to", "ct",
  "fo_won", "fos_taken", "fo_pct",
  "pen", "pen_time",
  "ggp", "ggs",
  "g_min", "goals_allowed",
  "gaa",
  "saves", "save_pct",
  "rc", "yc", "clears", "att", "clear_pct"
]

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

players_xpath = '//*[@id="stat_grid"]/tbody/tr'

teams_xpath = '//*[@id="stat_grid"]/tfoot/tr' #[position()>1]'

# Get team IDs

teams = []
ncaa_teams.each do |team|
  teams << team
end

n = teams.size

tpt = (n.to_f/nthreads.to_f).ceil

threads = []

# One agent for each thread?

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

teams.each_slice(tpt).with_index do |teams_slice,i|

  threads << Thread.new(teams_slice) do |t_teams|

    t_teams.each_with_index do |team,j|

      sleep_time = base_sleep

      year = team["year"]
      year_id = team["year_id"]
      team_id = team["team_id"]
      team_name = team["team_name"]

      stat_url = "http://stats.ncaa.org/team/#{team_id}/stats/#{year_id}"

      #print "Sleep #{sleep_time} ... "
      sleep sleep_time

      found_players = 0
      missing_id = 0

      tries = 0
      begin
        doc = Nokogiri::HTML(agent.get(stat_url).body)
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

      print "#{i} #{year} #{team_name} ..."

      doc.xpath(players_xpath).each do |player|

        row = [year, year_id, team_id, team_name]
        player.xpath("td").each_with_index do |element,i|
          case i
          when 1
            player_name = element.text.strip.to_nil

            link = element.search("a").first
            if (link==nil)
              missing_id += 1
              link_url = nil
              player_id = nil
              player_url = nil
            else
              link_url = link.attributes["href"].text.to_nil
              parameters = link_url.split("/")[-1]

              # player_id

              player_id = parameters.split("=")[2]

              # opponent URL

              player_url = base_url+link_url
            end

            found_players += 1
            row += [player_id, player_name, player_url]
          else
            field_string = element.text.strip.to_nil

            row += [field_string]
          end
        end

        ncaa_player_summaries << row
    
      end

      print " #{found_players} players, #{missing_id} missing ID"

      found_summaries = 0
      doc.xpath(teams_xpath).each do |team|

        row = [year, year_id, team_id, team_name]
        team.xpath("td").each_with_index do |element,i|
          field_string = element.text.strip.to_nil
          row += [field_string]
        end

        found_summaries += 1
        ncaa_team_summaries << row
    
      end

      print ", #{found_summaries} team summaries\n"

    end

  end

end

threads.each(&:join)

ncaa_team_summaries.close
ncaa_player_summaries.close
