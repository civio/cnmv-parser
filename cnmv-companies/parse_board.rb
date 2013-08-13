require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

def number_to_english(s)
    s.gsub('.','').gsub(',', '.')
end

def parse_file(filename)
    # Some weird encoding issue going on CNMV site, not fully sure about this
    content = open(filename).read.force_encoding('UTF-8')
    
    doc = Nokogiri::HTML(content)
    company_name = doc.css('#ctl00_lblSubtitulo').text
    board = doc.css('#ctl00_ContentPrincipal_gridConsejo')
    members = board.css('tr')[1..-2]    # skip first and last: header/footer

    members.each do |member|
        columns = member.css('td').map{|s| s.text.strip}
        person_name = columns[0]
        role = columns[3]
        shares = number_to_english(columns[1])
        from = columns[2]
        puts CSV::generate_line([person_name, role, company_name, from, shares])
    end
end

puts 'Source,Role,Company,From,Share %'

Dir['staging/*_board.html'].each {|filename| parse_file(filename)}
