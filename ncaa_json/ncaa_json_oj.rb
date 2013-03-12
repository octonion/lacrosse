#!/usr/bin/ruby1.9.3

require "csv"
require "mechanize"
require "oj"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = "Mozilla/5.0"

results = CSV.open("games.csv","w")

#base = "http://data.ncaa.com/scoreboard/football"

#sb_url = "http://data.ncaa.com/scoreboard/football/d1/2012/06/01/scoreboard.json"
#sb_url = "http://data.ncaa.com/jsonp/scoreboard/football/d1/2012/06/01/scoreboard.html"

#divisions = ["fbs","fcs","d2","d3"]
divisions = ["d1","d2","d3"]

#game_date = Date::strptime(testdate, "%d-%m-%Y")

date_start = Date.new(2013,2,1)
date_end = Date.today

for div_date in divisions.product(Array(date_start..date_end)) do

  division = div_date[0]
  game_date = div_date[1]

  sb_base_url = "http://data.ncaa.com/scoreboard/lacrosse-men"
  data_base_url = "http://data.ncaa.com/game/lacrosse-men"

  sb_url = "%s/%s/%s/%02d/%02d/scoreboard.json" % [sb_base_url,division,game_date.year,game_date.month,game_date.day]

  tries = 0
  begin
    page = agent.get_file(sb_url)
  rescue
    print " -> attempt #{tries}\n"
    tries += 1
    retry if (tries<4)
    next
  end

  print "Found scoreboard for #{division} - #{game_date}\n"

  sb_json = Oj.load(page)

  sb_json["scoreboard"].each do |day|

    game_date = day["day"]

    day["games"].each_with_index do |game,i|

      gameinfo_path = game.split("/lacrosse-men/")[1]

      url = "#{data_base_url}/#{gameinfo_path}"

      tries = 0
      begin
        page = agent.get_file(url)
      rescue
        print " -> attempt #{tries}\n"
        tries += 1
        retry if (tries<4)
        next
      end

      gameinfo = Oj.load(page)

      game_id = gameinfo["id"]

      row = Hash["gameinfo"=>gameinfo]

      #test << Hash["game_id"=>game_id]

#      p gameinfo["tabs"]
#      if (gameinfo["tabs"]==nil)
#        next
#      end

      tab_path = gameinfo["tabs"].split("/lacrosse-men/")[1]
      url = "#{data_base_url}/#{tab_path}"

      tries = 0
      begin
        page = agent.get_file(url)
      rescue
        print " -> attempt #{tries}\n"
        tries += 1
        retry if (tries<4)
        next
      end

      tabs = Oj.load(page)
      #p tabs
      tabs.each do |tab|
        type = tab["type"]

        file_path = tab["file"].split("/lacrosse-men/")[1]
        url = "#{data_base_url}/#{file_path}"

        tries = 0
        begin
          #p url
          page = agent.get_file(url)
        rescue
          print " -> attempt #{tries}\n"
          tries += 1
          retry if (tries<4)
          next
        end

        row[type] = Oj.load(page)

      end

      results << [game_id,
                  game_date,
                  division,
                  case row["gameinfo"]
                  when nil
                    nil
                  else 
                    Oj.dump(row["gameinfo"])
                  end,
                  case row["recap"]
                  when nil
                    nil
                  else 
                    Oj.dump(row["recap"])
                  end,
                  case row["boxscore"]
                  when nil
                    nil
                  else 
                    Oj.dump(row["boxscore"])
                  end,
                  case row["summary"]
                  when nil
                    nil
                  else 
                    Oj.dump(row["summary"])
                  end,
                  case row["team-stats"]
                  when nil
                    nil
                  else 
                    Oj.dump(row["team-stats"])
                  end,
                  case row["play-by-play"]
                  when nil
                    nil
                  else 
                    Oj.dump(row["play-by-play"])
                  end
                 ]
    end

    results.flush

  end

end

results.close

exit 0
