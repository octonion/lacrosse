#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sport_code = ARGV[0]
year = ARGV[1]
division_id = ARGV[2]

ncaa_teams = CSV.open("tsv/ncaa_teams_#{year}_#{division_id}.tsv", "w",
                      {:col_sep => "\t"})

# Header for team file

ncaa_teams << ["sport_code", "year", "year_id", "division_id",
               "team_id", "team_name", "team_url"]

year_division_url = "http://stats.ncaa.org/team/inst_team_list?sport_code=#{sport_code}&academic_year=#{year}&division=#{division_id}&conf_id=-1&schedule_date="

print "\nRetrieving #{sport_code} division #{division_id} teams for #{year} ... "

found_teams = 0

doc = Nokogiri::HTML(agent.get(year_division_url).body)

doc.search("a").each do |link|

  link_url = link.attributes["href"].text

  # Valid team URLs

  if (link_url =~ /^\/team\/\d/)

    # NCAA year_id

    parameters = link_url.split("/")
    year_id = parameters[-1]

    # NCAA team_id

    team_id = parameters[-2]

    # NCAA team name

    team_name = link.text()

    # NCAA team URL

    team_url = base_url+link_url

    ncaa_teams << [sport_code, year, year_id, division_id,
                   team_id, team_name, team_url]
    found_teams += 1

  end

  ncaa_teams.flush

end

ncaa_teams.close

print "found #{found_teams} teams\n\n"
