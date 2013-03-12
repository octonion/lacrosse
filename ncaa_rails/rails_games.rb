#!/usr/bin/ruby1.9.1
# -*- coding: utf-8 -*-

require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'cgi'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

data = []

games = CSV.open("rails_games.csv","w")
rosters = CSV.open("rails_rosters.csv","w")

files = [games,rosters]

#CSV.open("teams.txt").each do |team|
CSV.open("ncaa_teams.csv").each do |team|

  id = team[0]
  name = team[1]

  print "#{name} - #{id}\n"

#http://stats.ncaa.org/team/inst_team_list?sport_code=MLA&division=1
  url = "http://stats.ncaa.org/team/index/11380?&org_id=#{id}"

  begin
    page = Nokogiri::HTML(open(url))
  rescue
    print "Error: Retrying\n"
    retry
  end

  page.css("table").each_with_index do |table,i|

    if (i==0)
      next
    else
      file_id = i-1
    end

    table.css("tr").each_with_index do |row,j|

      if [0,1].include?(j)
        next
      end

      #r = [id,name,j]
      r = [id,name]

      row.xpath("td").each_with_index do |d,k|

        #r << k
        l = d.text.delete("^\u{0000}-\u{007F}").strip
        r << l

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

      end

      files[file_id] << r

    end

  end

  files.each do |file|
    file.flush
  end

end

files.each do |file|
  file.close
end
