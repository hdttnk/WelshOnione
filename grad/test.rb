require "kconv"
require "analysis"
require "keyword"

sentence = "藤田まこと「JIN」降板 治療へ"
body = Kconv.tosjis(sentence)
a = Analysis.new(body)
@relations = []
a.all_relation(3).each{|r|
	r_utf8 = Kconv.toutf8(r)
	#@relations << r_utf8
	b = Analysis.new(r)
	b.all_relation(3).each{|c|
		c_utf8 = Kconv.toutf8(c)
		if c != r
			@relations << c_utf8
		end
	}
}
a.list.each{|p|
	p_utf8 = Kconv.toutf8(p)
	@relations << p_utf8
}
#@relations.uniq!
#@relations.sort!

print Kconv.tosjis("候補\n")
@relations.each{|r|
  print Kconv.tosjis(r)," "
}

#@score_list = {}
#relation = []
#relation = @relations
#relation.delete("|")
#@score_list = scoring(relation)

#@debug = []
#@debug = a.wordlist
#@relations = @debug


#print "\n\n"
#print "スコア"
#@score_list.each{|key,value|
#  print key,"：",value
#}
 スコア"
#@score_list.each{|key,value|
#  print key,"：",value
#}
 "
#@score_list.each{|key,value|
#  print key,"：",value
#}
 ch{|key,value|
  print key,"：",value
}
