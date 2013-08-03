require "rexml/document"
require "kconv"
require "cgi"
require "open-uri"
require "net/http"

class Keyword
  def initialize(word)
    @word = word
  end
  
  def getword
    @word
  end
  
  def relation(num)
	#Net::HTTP.version_1_2
	#$proxy_addr = ""
	#$proxy_port = 80
    utf8_query = CGI.escape(Kconv.toutf8(@word))
    url = "http://search.yahooapis.jp/AssistSearchService/V1/webunitSearch?appid=SuvpRFixg64kNxcyisGXYi5M6dec7RbfXUHJRXkY246KVTtHI3djMXUW193ECJE-&query=" + utf8_query + "&results=" + num.to_s
	#doc = REXML::Document.new(open(url))
	doc = REXML::Document.new(OpenURI.open_uri(url,{ :proxy => 'http://proxy:3128' }))  #kujira
	#host = "search.yahooapis.jp"
	#request = "/AssistSearchService/V1/webunitSearch?appid=SuvpRFixg64kNxcyisGXYi5M6dec7RbfXUHJRXkY246KVTtHI3djMXUW193ECJE-"#&query=" + utf8_query + "&results=" + num.to_s
    #http = Net::HTTP::Proxy("",80).new(host)
	#response = http.post(request, "query=#{utf8_query}")
	#doc = REXML::Document.new response.body
	#doc = REXML::Document.new(Net::HTTP::Proxy("",80).get(host,request))  #プロキシ設定
	phraselist = []
    temp = []
    doc.elements.each("ResultSet/Result") {|element|
      temp = Kconv.tosjis(element.text).split(" ")
      phraselist.concat(temp)
    }
	#phraselist << @word
    phraselist.uniq!
    return phraselist
  end

  def totaldoc
    utf8_query = CGI.escape(Kconv.toutf8(@word))
    url = "http://search.yahooapis.jp/WebSearchService/V1/webSearch?appid=SuvpRFixg64kNxcyisGXYi5M6dec7RbfXUHJRXkY246KVTtHI3djMXUW193ECJE-&query=" + utf8_query + "&results=1"
    doc = REXML::Document.new(open(url))
    total_document = 0
    total_document = doc.elements["ResultSet"].attributes["totalResultsAvailable"].to_i
    return total_document
  end


end

def tfidf(sentence)
	utf8_sentence = CGI.escape(Kconv.toutf8(sentence))
	url = "http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=SuvpRFixg64kNxcyisGXYi5M6dec7RbfXUHJRXkY246KVTtHI3djMXUW193ECJE-&sentence=" + utf8_sentence
	doc = REXML::Document.new(open(url))
	tfidflist = []
    temp = ""
    doc.elements.each("ResultSet/Result/Keyphrase") {|element|
      temp = Kconv.toutf8(element.text)
      tfidflist << temp
    }
    return tfidflist
end


	
#query = Keyword.new("\217\237\227\230\202\314\217\227\220_")
#print query.getword
#print query.relation

#query.relation.each {|x|
#  print x,"\n"
#}

#print query.totaldoc