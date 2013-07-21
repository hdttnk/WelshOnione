$KCODE = "u"

require 'open-uri'
require 'rexml/document'
require 'cgi'
require 'tumblr'
#require 'highline'

#USERNAME = HighLine.new.ask("username:")
#PASSWORD = HighLine.new.ask('password:') {|q| q.echo = '*' }

print "検索ワード："
query = CGI.escape(gets)
url = "http://gdata.youtube.com/feeds/api/videos/-/" + query
#url = "http://gdata.youtube.com/feeds/api/videos?vq=" + query + "&start-index=1&max-results=1"
xmlBody = open(url)
xml = REXML::Document.new xmlBody
#print xml.root

=begin
xml.elements.each("feed/entry"){|entry|
	print entry.text("title"),"\n"
	print entry.text("author/name"),"\n"
	print entry.elements["link[@rel='alternate']"].attributes["href"].chomp("&feature=youtube_gdata"),"\n"
	print entry.text("media:group/media:keywords"),"\n\n"
}

tumblr = Tumblr.new("hysteric_blue_and_blue@yahoo.co.jp","Chat0618")
params = Hash.new
params[:embed] = "http://www.youtube.com/watch?v=iYWJTryf3rI"
params[:tags] = "テスト,動画"
tumblr.video(params)
=end

#タグ保存配列
#tags = []

xml.elements.each("feed/entry"){|entry|
	tumblr = Tumblr.new("hideto@cc.uec.ac.jp","Chat0618")
	params = Hash.new
	params[:embed] = entry.elements["link[@rel='alternate']"].attributes["href"].chomp("&feature=youtube_gdata")
	tags = []
	temp = entry.text("media:group/media:keywords").split(",")
	temp.each{|t|
		t = t.strip
		tempary = t.split(//)
		tags << tempary[0]
	}
	s_tags = tags.join(",")
	print s_tags,"\n"
	params[:tags] = s_tags    #entry.text("media:group/media:keywords")
	params[:caption] = entry.text("title") + "<br>" + entry.text("author/name") + "<br>" + entry.text("media:group/media:keywords") + "<br>" +entry.text("media:group/media:description").to_s
	#tumblr.video(params)
	print entry.text("title"),"\n"
	
#	temp = entry.text("title")
#	tempary = temp.split(//)
#	print tempary[0],"\n"
	
	print entry.text("author/name"),"\n"
	print entry.elements["link[@rel='alternate']"].attributes["href"].chomp("&feature=youtube_gdata"),"\n"
	print entry.text("media:group/media:keywords"),"\n"
	print entry.text("media:group/media:description"),"\n\n"
	temp = entry.text("media:group/media:keywords").split(",")
	temp.each{|t|
		t = t.strip
		tempary = t.split(//)
		tags << tempary[0]
	}
}
#tags.each{|tag|
#	print tag,","
#}
print "\n\n"

#tumblr = Tumblr.new("hysteric_blue_and_blue@yahoo.co.jp","Chat0618")
#params = Hash.new
#params[:embed] = "http://www.youtube.com/watch?v=iYWJTryf3rI"
#params[:tags] = "テスト,動画"
#params[:caption] = "test"+"<br>"+"testuser"
#tumblr.video(params)