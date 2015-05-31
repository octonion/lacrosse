#!/usr/bin/env ruby

require 'csv'
require 'open-uri'

require 'json'

base = "http://www.pointstreak.com/gamelive/gameinformation.php"

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

    file_name = "json/#{game_id}.json"

    open(file_name, 'wb') do |file|
      json = JSON.parse(open(url).read)
      file << json.to_json
    end

  end

  games.close

end
