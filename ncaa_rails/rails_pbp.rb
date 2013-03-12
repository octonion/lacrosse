#!/usr/bin/ruby1.9.3
# -*- coding: utf-8 -*-

require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'cgi'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

base = "http://stats.ncaa.org/game/play_by_play"

periods = CSV.open("rails_periods.csv","w")
notes = CSV.open("rails_notes.csv","w")
info = CSV.open("rails_info.csv","w")
officials = CSV.open("rails_officials.csv","w")
pbp = CSV.open("rails_pbp.csv","w")

files =[periods,notes,info,officials,pbp]

data = []

ids = []
CSV.open("rails_games.csv").each do |game|
  if not(game[6]==nil)
    game_id = game[6].gsub("/game/index/","").split("?")[0]
    ids << game_id.to_i
  end
end

ids.sort!.uniq!

n = ids.size

#CSV.open("games.csv").each do |game|

found = 0

ids.each_with_index do |game_id,i|

#  if not(game_id==1667152)
#    next
#  end

  #team_id = game[0]
  #team = game[1]
  #date = game[2]
  #opponent = game[3]
  #link = game[6]

  #print "#{date} / #{team} #{opponent}\n"
  print "#{game_id} : #{i}/#{n}; found #{found}/#{n}\n"

  #if not(link==nil)
    
  #  game_id = link.gsub("/game/index/","").split("?")[0]
    url = "#{base}/#{game_id}"

    begin
      page = Nokogiri::HTML(open(url))
    rescue
      print "  - error, skipping\n"
      next
    end

  found += 1

    page.css("table").each_with_index do |table,i|

      if (i>3)
        if (i%2==0)
          next
        else
          file_id = 4
          period = i/2 - 1
        end
      else
        file_id = i
      end

      #if (i==0)
      #  next
      #end

      table.css("tr").each_with_index do |row,j|

        #if [0,1].include?(j)
        #  next
        #end

        if (file_id==4)
          r = [game_id,period,j]
          #r = [team_id,date,game_id,inning]
        else
          r = [game_id,j]
          #r = [team_id,date,game_id]
        end

        row.xpath("td").each_with_index do |d,k|

          l = d.text.delete("^\u{0000}-\u{007F}").strip
          #r += [k,l]
          r += [l]

=begin
          if (i==1 and [1,2].include?(k))

            href = [nil]
            d.xpath("a").each do |a|
              href = [a.attributes["href"].value]
            end
            r += href

          elsif (i==2 and [1].include?(k))

            href = [nil]
            d.xpath("a").each do |a|
              href = [a.attributes["href"].value]
            end
            r += href

          end
=end
      end

      if (r.size < 7)
        next
      else
        if (r[2].is_a? Integer) and (r[2]>0)

          rr = r[0..3]

          rr += [r[4]]
=begin
          sa = r[4].split(',',2)
          if not(sa==[])
            if (sa[0]==r[4])
              last=nil
            else
              last = sa[0].strip
            end
            if (sa[1]==nil)
              sb = sa[0].split(' ',2)
            else
              sb = sa[1].split(' ',2)
            end
            first = sb[0].strip if sb[0]
            event = sb[1].strip if sb[1]
            rr += [last,first,event]
          else
            rr += [nil,nil,nil]
          end
=end

          sa = r[5].split('-',2)
          rr += [sa[0].strip,sa[1].strip]

          rr += [r[6]]
=begin
          sa = r[6].split(',',2)
          if not(sa==[])
            if (sa[0]==r[6])
              last=nil
            else
              last = sa[0].strip
            end
            if (sa[1]==nil)
              sb = sa[0].split(' ',2)
            else
              sb = sa[1].split(' ',2)
            end
            first = sb[0].strip if sb[0]
            event = sb[1].strip if sb[1]
            rr += [last,first,event]
          else
            rr += [nil,nil,nil]
          end
=end

          files[file_id] << rr

        else
          next
        end
      end
    end

  end

  files.each do |file|
    file.flush
  end

end

files.each do |file|
  file.close
end

