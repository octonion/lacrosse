#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

require 'open-uri'
require 'addressable/uri'

class URI::Parser
  def split url
    a = Addressable::URI::parse url
    [a.scheme, a.userinfo, a.host, a.port, nil, a.path, nil, a.query, a.fragment]
  end
end

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

results = CSV.open("csv/seasons.csv", "w")
results << ["league_id", "season_id", "league_season_url", "league_season_name"]

path = '//*[@id="content-block-wtt-main"]/div/table[1]/tr[2]/td[1]/div/form/select/option[position()>1]'

url = "http://nll_stats.stats.pointstreak.com/leagueschedule.html"

page = agent.get(url)

found = 0
page.parser.xpath(path).each do |option|
  href = option.attributes["value"].to_s
  ls_url = URI.join(url, href)

  league_id = href.split("&")[0].split("=")[1]
  season_id = href.split("=")[2]
  
  ls_name = option.text.scrub.strip

  print "  #{ls_name}\n"
  found += 1
  results << [league_id, season_id, ls_url, ls_name]
  
end

results.close

print "Found #{found} league seasons\n"
