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
class Time

  # TODO
  def to_ms

    (self.to_f * 1000.0).to_i

  end

end # end of class

start_time = Time.now

boards = "1"

response = Net::HTTP.get(URI.parse('http://futisforum2.org/index.php?action=.xml;type=rss2;boards=' + boards + ';limit=255'))

feed = RSS::Parser.parse response

s1 = Set.new

feed.items.each do |item|

  if item.title.include? "Suomi"

    body = Net::HTTP.get(URI.parse(item.link)).to_s.gsub!('<br />', ' ').strip
	
	# Funny encoding hack...
	body.force_encoding('iso-8859-1')		
	body = body.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')		
	body.to_s.gsub!('', '€')

	document = Oga.parse_html(body)
	
	document.css('div.post div.quote').each_with_index do |quote, index|
	  quote.replace('"' + quote.text.strip + '" - ')
	end
	
	document.css('div.post div.quoteheader').each_with_index do |quote, index|
	  quote.replace("")
	end
	
	document.css('div.post a').each_with_index do |link, index|
	  link.replace(link.text)
	end
	
	document.css('div.post ul').each_with_index do |l, index|
	  document.css('li').each_with_index do |x, index|
	    x.replace(' ' + x.text + ', ')
	  end
	end

    document.css('div.post').each_with_index do |person, index|	
		
		s1.add(person.text)		
		#puts person.inner_text	  
		#puts index
		puts '-' * 40
    end	

    break

  else
	# DO SOMETHING LATER
  end
end

end_time = Time.now

elapsed_time = end_time.to_ms - start_time.to_ms
footer = "generated in " + (elapsed_time/1000.000).to_s + " seconds"

get '/update' do
   boards = "1"

   response = Net::HTTP.get(URI.parse('http://futisforum2.org/index.php?action=.xml;type=rss2;boards=' + boards + ';limit=255'))
   
   feed = RSS::Parser.parse response

	s2 = Set.new

	feed.items.each do |item|

	  if item.title.include? "Suomi"

		body = Net::HTTP.get(URI.parse(item.link)).to_s.gsub!('<br />', ' ').strip
		
		# Funny encoding hack...
		body.force_encoding('iso-8859-1')		
		body = body.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')		
		body.to_s.gsub!('', '€')

		document = Oga.parse_html(body)
		
		document.css('div.post div.quote').each_with_index do |quote, index|
		  quote.replace(' <div id="test2"><br> "' + quote.text.strip + '"</div><br>')
		end
		
		document.css('div.post div.quoteheader').each_with_index do |quote, index|
		  quote.replace("")
		end
		
		document.css('div.post a').each_with_index do |link, index|
		  link.replace(link.text)
		end
		
		document.css('div.post ul').each_with_index do |l, index|
		  document.css('li').each_with_index do |x, index|
			x.replace(' ' + x.text + ', ')
		  end
		end

		document.css('div.post').each_with_index do |person, index|	
			
			s2.add(person.text + "  |||  ")	
			#puts person.text		
			#puts person.inner_text	  
			#puts index
			puts '-' * 40
		end	

		break

	  else
		# DO SOMETHING LATER
	  end
	end

    data = s2
	
end

title = "ff2-ascii"

get '/' do
  @title = title
  @div_content = s1
  @count = s1.length()-1
  @footer = footer  
  erb :index, :layout => :basic_layout
end

get '/match/?' do
  @title = title
  #@ajax = "test"
  erb :nextmatch, :layout => :basic_layout
end