require 'sinatra'
require 'tilt/erb'
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

boards = "24"

response = Net::HTTP.get(URI.parse('http://futisforum2.org/index.php?action=.xml;type=rss2;boards=' + boards + ';limit=255'))

feed = RSS::Parser.parse response

s1 = Set.new

feed.items.each do |item|

  if item.title.include? "RoPS"

    body = Net::HTTP.get(URI.parse(item.link)).to_s.gsub!('<br />', ' ').strip

	document = Oga.parse_html(body.unpack("C*").pack("U*"))
	
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
   boards = "24"

   response = Net::HTTP.get(URI.parse('http://futisforum2.org/index.php?action=.xml;type=rss2;boards=' + boards + ';limit=255'))
   
   feed = RSS::Parser.parse response

	s1 = Set.new

	feed.items.each do |item|

	  if item.title.include? "RoPS"

		body = Net::HTTP.get(URI.parse(item.link)).to_s.gsub!('<br />', ' ').strip

		document = Oga.parse_html(body.unpack("C*").pack("U*"))
		
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

   #puts s1.to_a[0]
   data = s1.to_a[s1.length()-1]
   #feed = RSS::Parser.parse response

   #s1 = Set.new
   #@temp = Time.now.to_s  
end

title = "ff2-ascii"

get '/' do
  @title = title
  @div_content = s1
  @count = s1.length()-1
  @footer = footer  
  erb :index, :layout => :basic_layout
end

get '/about/?' do
  @title = title
  erb :about, :layout => :basic_layout
end