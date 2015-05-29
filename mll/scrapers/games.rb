#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

seasons = CSV.open("csv/seasons.csv", "r", {:headers => TRUE})

path = "/html/body/div/div[4]/div/div[3]/div/div/table/tr/td[2]/table[1]/tr[position()>2]"

seasons.each do |season|

  league_id = season["league_id"]
  season_id = season["season_id"]
  ls_name = season["league_season_name"]
  print "#{ls_name} - "

  year = ls_name.split(" ")[-1]

  games = CSV.open("csv/games_#{league_id}_#{season_id}.csv", "w")

  url = season["league_season_url"]
  
  page = agent.get(url)

  found = 0
  page.parser.xpath(path).each do |tr|

    type = tr.attributes["class"].to_s

    row = [league_id, season_id, year]

    location = nil

    case type
    when "light"

      tr.xpath("td").each_with_index do |td,j|

        case j
        when 1,2
          team = td.xpath("a").first.text.scrub.strip rescue nil
          href = td.xpath("a").first.attributes["href"].to_s
          team_id = href.split("=")[1].split("&")[0] rescue nil
          href = href.scrub.strip rescue nil
          team_url = URI.join(url, href).to_s
          score = td.xpath("b").first.text rescue nil
          row += [team_id, team, team_url, score]
        when 5
          text = td.text.scrub.strip rescue nil
          score = text.split("\t")[0].scrub.strip rescue nil
          ot = text.split("\t")[1].scrub.strip rescue nil
          row += [score, ot]
        when 6
          flash_url = nil
          boxscore_url = nil
          game_id = nil
          td.xpath("a").each_with_index do |a,k|
            case k
            when 0
              href = a.attributes["href"].to_s
              game_id = href.split("=")[1]
              href = href.scrub.strip rescue nil
              flash_url = URI.join(url, href).to_s
            when 1
              href = a.attributes["href"].to_s
              href = href.scrub.strip rescue nil
              boxscore_url = URI.join(url, href).to_s
            end
          end
          row += [game_id, flash_url, boxscore_url]
        else
          row << td.text.scrub.strip rescue nil
        end

      end

    else

      tr.xpath("td").each_with_index do |td,j|

        case j
        when 1,2
          team = td.text.scrub.strip rescue nil
          href = td.xpath("a").first.attributes["href"].to_s
          team_id = href.split("=")[1].split("&")[0] rescue nil
          href = href.scrub.strip rescue nil
          team_url = URI.join(url, href).to_s
          row += [team_id, team, team_url, nil]
        when 5
          location = td.text.scrub.strip rescue nil
        else
          row << td.text.scrub.strip rescue nil
        end
        
      end

      row += [nil, nil, nil, nil, nil, nil]

    end

    row += [location]

    games << row
    found += 1

    
    #href = option.attributes["value"].to_s
    #ls_url = URI.join(url, href)

    #league_id = href.split("&")[0].split("=")[1]
    #season_id = href.split("=")[2]
  
    #ls_name = option.text.scrub.strip

    #print "  #{ls_name}\n"
    #found += 1
    #results << [league_id, season_id, ls_url, ls_name]

  end

  games.close
  print " #{found}\n"
  
end

seasons.close
