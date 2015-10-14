# encoding: UTF-8

require 'sinatra'
require 'tilt/erb'
require 'bundler/setup'
require 'cowsay'
require 'time'
require 'net/http'
require 'rss'
require 'set'
require 'oga'


# TODO
class Forum

    # The constructor.
    def initialize
        # EMPTY
    end

    # Get and parse the data.
    def data(boards, team, is_string)

        s1 = Set.new

        response = Net::HTTP.get(URI.parse('http://futisforum2.org/index.php?action=.xml;type=rss2;boards=' +
                                 boards +
                                 ';limit=255'))

        feed = RSS::Parser.parse response

        feed.items.each do |item|

            if item.title.include? team

                body = Net::HTTP.get(URI.parse(item.link)).to_s.gsub!('<br />', ' ').strip

                # Funny encoding hack...
                body.force_encoding('iso-8859-1')
                body = body.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
                body.to_s.gsub!('', '€')
				body.to_s.gsub!('', '"')

                document = Oga.parse_html(body)

                document.css('div.post div.quote').each do |quote|
                    quote.replace('"' + quote.text.strip + '" - ')
                end

                document.css('div.post div.quoteheader').each do |quote|
                    quote.replace("")
                end

                document.css('div.post a').each do |link|
                    link.replace(link.text)
                end

                document.css('div.post ul').each do |l|
                    document.css('li').each do |x|
                        x.replace(' ' + x.text + ', ')
                    end
                end

                document.css('div.post').each do |person|

                    if is_string == true
                        s1.add(person.text + "  |||  ")
                    else
                        s1.add(person.text)
                    end

                    #puts '-' * 40
                end

                break

            else
                # DO SOMETHING LATER
            end

        end
        return s1
    end
end # end of class


# TODO
f = Forum.new

##############################################################################
title = "ff2-ascii"

# TODO
get '/update' do
    data = f.data("11", "RoPS", true)
end

# TODO
get '/' do
    @title = title
    @div_content = f.data("24", "HJK", false)
    @count = @div_content.length()-1
    #@footer = footer
    erb :index, :layout => :basic_layout
end

# TODO
get '/match/?' do
    @title = title
    @temp= "temp"
    erb :nextmatch, :layout => :basic_layout
end