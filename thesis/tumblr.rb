require 'net/http'
require 'open-uri'
require 'cgi'
#require 'xmlsimple'

class Tumblr

  def initialize(email=nil, password=nil)
    Net::HTTP.version_1_2
    @email = email
    @password = password
  end

  def to_query_parameter(hash)
    hash.map{|i| i.map{|j| CGI.escape j.to_s}.join('=') }.join('&')
  end

  def method_missing(method_id, *params)
    params[0][:type] = method_id.to_s
    params[0][:email] = @email if @email
    params[0][:password] = @password if @password
    post(params[0])
  end

  def post(params)
    Net::HTTP.start("www.tumblr.com", 80) do |http|
      response = http.post("/api/write", to_query_parameter(params))
    end
  end

#  def get(id, options={})
#    xml = open("http://#{id}.tumblr.com/api/read/?#{to_query_parameter(options)}").read
#    XmlSimple.xml_in(xml, {'ForceArray' => false})
#  end

end