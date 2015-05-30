#!/usr/bin/env ruby

require 'csv'
require 'open-uri'

base = "http://www.pointstreak.com/flashapp/teamstats_xml.php"

ARGV.each do |game_file|

  games = CSV.open(game_file, "r", {:headers => FALSE})

  games.each do |game|

    year = game[2]
    home_id = game[4]
    home = game[5]
    away_id = game[8]
    away = game[9]
    date = game[12]

    game_id = game[16]

    if (game_id==nil)
      print "#{year} - #{home} vs #{away} on #{date} - no boxscore\n"
      next
    else
      print "#{year} - #{home} vs #{away} on #{date} - boxscore\n"
    end

    url = "#{base}?homesteamid=#{home_id}&awaysteamid=#{away_id}&gameid=#{game_id}"

    file_name = "xml/boxscore_#{game_id}.xml"

    open(file_name, 'wb') do |file|
      file << open(url).read
    end

  end

  games.close

end
