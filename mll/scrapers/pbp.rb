#!/usr/bin/env ruby

require 'csv'
#require 'mechanize'
require 'open-uri'

#agent = Mechanize.new{ |agent| agent.history.max_size=0 }
#agent.user_agent = 'Mozilla/5.0'

base = "http://www.pointstreak.com/flashapp/getlivegamedata.php"

ARGV.each do |game_file|

  games = CSV.open(game_file, "r", {:headers => FALSE})

  games.each do |game|

    year = game[2]
    home = game[5]
    away = game[9]
    date = game[12]

    game_id = game[16]

    if (game_id==nil)
      print "#{year} - #{home} vs #{away} on #{date} - no PBP\n"
      next
    else
      print "#{year} - #{home} vs #{away} on #{date} - PBP\n"
    end

    url = "#{base}?gameid=#{game_id}"

    file_name = "xml/#{game_id}.xml"

    open(file_name, 'wb') do |file|
      file << open(url).read
    end

  end

  games.close

end
