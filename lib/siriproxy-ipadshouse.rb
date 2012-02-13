require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'

#############
# This is a plugin for SiriProxy that will allow you to check iPadsHouse news
# Example usage: "iPadsHouse"
#############

class SiriProxy::Plugin::iPadsHouse < SiriProxy::Plugin

	@i = 0 
	#@entry = Array.new
	
	def initialize(config)
    #if you have custom configuration options, process them here!
  end
  
  listen_for /ipadshouse/i do |phrase|
	  ipaNews = "today"
	  ipad(ipadNews) #in the function, request_completed will be called when the thread is finished
	end
	
	def ipa(news)
	  
    say "Checking iPadsHouse for news..."
	  
		doc = Nokogiri::HTML(open("http://www.ipadshouse.com"))
    entry = doc.css("section article")
      	
    if entry.nil?
      say "I'm sorry, I didn't see any iPadsHouse news. I failed you..."
	    request_completed
		end
		
		entry.each do 
		|article|
		
			title = article.css("h2 a").first.content.strip
      		
      if title.nil?
        title = " "
      end
      	
      img = article.css("a img").first
      	
      if img.nil?
        img_url = "http://www.ipadshouse.com/wp-content/themes/ipadhouse/img/logo.png"
      else
      	img_url = img['src']
      end
      	
      descr = article.css(".description").first.content.strip
      		
      if descr.nil?
        descr = " "
      end
      		
      showArticle(title,img_url,descr)
      		
      if @i == 1
        break
      end
      		
    end
      	
    if entry.nil?
      say "Sorry there is no iPadsHouse news. I have failed you."
    else

    end
      	
    request_completed
 
	end
	
	def showArticle(title1, img, desc)
		
		say "Here is the latest from iPadsHouse...", spoken: "Here is the latest from iPadsHouse. " + title1 + "."
		
		object = SiriAddViews.new
    object.make_root(last_ref_id)
    answer = SiriAnswer.new(title1, [
    SiriAnswerLine.new('logo',img), # this just makes things looks nice, but is obviously specific to my username
    SiriAnswerLine.new(desc)])
    object.views << SiriAnswerSnippet.new([answer])
    send_object object
    	
    #@searched = @searched + 1
    	
    response = ask "Would you like to hear more news? You can \"Hear more\", go to the \"Next Story\" or \"Cancel\"" #ask the user for something
    
    if(response =~ /hear|here more/i) #process their response
      say "Detail from the story...", spoken: desc
    	response1 = ask "Would you like to hear more news? You can go to the \"Next Story\" or \"Cancel\""
      #showEntry(@searched)
      if(response1 =~ /next|nick story|door/i)
        say "OK, looking for more news..."
      	@i = 0
      else
      	say "OK, I'll stop with all the iPadsHouse news."
      	@i = 1
      	#break
      	#request_completed
      end
    elsif (response =~ /next|nick story|door/i)
      say "OK, looking for more news..."
      @i = 0
    else
      say "OK, I'll stop with all the iPadsHouse news."
      @i = 1
      #break
      #request_completed
    end
	
	end
	
end
