require "mecab"
require "keyword"
require "kconv"

class Analysis
  def initialize(body)
    @body = body
  end
  
  def getbody
    @body
  end
  
  def wordlist
	begin
		m = Mecab.new("-Ocsv")
		word_list = []
		#body = Kconv.toutf8(@body)
		#touten = Kconv.tosjis("、")
		#line = @body.gsub("\s",touten)
		#line = @body
		line = Kconv.toutf8(@body)
		line.chomp!
		node = m.sparse_tonode(line)
		while node.hasNext
			node = node.next
			poslist = []  #品詞タグを分割して配列へ格納
			u_node = Kconv.toutf8(node.pos)
			pos = u_node.split(",")
			poslist.concat(pos)
		
			if (poslist[0] == "名詞") or (poslist[0] == "接頭詞")
				n_utf8 = Kconv.toutf8(node.surface)
				word_list << node.cost.to_s
				#word_list << n_utf8  #node.surface
			elsif poslist[0] == "動詞"
				v_utf8 = Kconv.toutf8(node.root)
				word_list << v_utf8  #node.root
			end
		end
	ensure
		m.destroy
	end
	word_list.uniq!
	return word_list
  end
  
	def proper_noun
		begin
			m = Mecab.new("-Ocsv")
			proper_noun_list = []
			n = 0
			body = Kconv.toutf8(@body)
			#body = Kconv.tosjis(@body)
			touten = Kconv.toutf8("、")
			line = body.gsub("\s",touten)
			line.chomp!
			node = m.sparse_tonode(line)
			while node.hasNext
				node = node.next
				poslist = []  #品詞タグを分割して配列へ格納
				u_node = Kconv.toutf8(node.pos)
				pos = u_node.split(",")
				poslist.concat(pos)
				if (poslist[0] == "名詞") and (poslist[1] != "数")  #数字などをはじく
					if (poslist[4] == "未知語") or (poslist[1] == "固有名詞") #or (poslist[1] == "一般")
						proper_noun_list << node.surface
					end
				end
			end
		ensure
			m.destroy
		end
		return proper_noun_list
	end
  
  def list
    begin
      m = Mecab.new("-Ocsv")
      poslist = []
      wordpos = []  #[[loc0,word0,poslist[0]],[loc1,word1,poslist[1]],...[locn,wordn,poslist[n]]]の配列
      n = 0
	  body = Kconv.toutf8(@body)
	  #body = Kconv.tosjis(@body)
	  touten = Kconv.toutf8("、")
      line = body.gsub("\s",touten)
      line.chomp!
      node = m.sparse_tonode(line)
      while node.hasNext
        node = node.next
        poslist = []  #品詞タグを分割して配列へ格納
		u_node = Kconv.toutf8(node.pos)
        pos = u_node.split(",")
        poslist.concat(pos)
		
        if (poslist[0] == "名詞") or (poslist[0] == "接頭詞")
			if poslist[1] != "特殊"
				if poslist[1] != "引用文字列"
					if poslist[1] != "形容動詞語幹"
						if poslist[2] != "形容動詞語幹"
							if poslist[1] != "動詞非自立的"
								if poslist[1] != "ナイ形容詞語幹"
									if poslist[1] != "非自立"
										if poslist[1] != "代名詞"
											if poslist[1] != "副詞可能"
												if poslist[2] != "副詞可能"
													if (poslist[1] != "形容詞接続") and (poslist[1] != "動詞接続")
														wordpos << [n,node.surface,poslist]
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
        n = n+1
      end
  
      #この時点ではwordposに[出現場所,単語名,PoSタグ配列]
      #この3つで特徴付け
  
      #単語の数え上げ
      wordlist = []
      wordpos.each {|x|
        wordlist << x[1]
      }
      wordcount = []  #数え上げ配列(単語)
      temp = nil
      wordlist.delete(nil)
      wordlist.sort!

      #数え上げ
      wordlist.each {|x|
        if x == temp
          wordcount.fill(wordcount.last + 1,-1)
        else
          temp = x
          wordcount << 1
        end
      }
  
      #全てユニークに
      wordlist.uniq!
	  
	  word_list = ""  #DB格納用
	  wordlist.each{|w|
		w_utf8 = Kconv.toutf8(w)
		word_list = word_list + " " + w_utf8
	  }
  
	  
      #隣接する名詞同士の結合
      @phraselist = []  #名詞句の格納配列
      postaglist = []  #品詞タグの格納配列
      n = 0
      loc = -2
      while n < wordpos.length
        if loc != wordpos[n][0]-1
          @phraselist << wordpos[n][1]
          postaglist << wordpos[n][2]
        else  #名詞句の生成
          wordtemp = @phraselist[n-1] + wordpos[n][1]
          @phraselist << wordtemp
          @phraselist[n-1] = nil
          postaglist << postaglist[n-1].concat(wordpos[n][2])
          postaglist[n-1] = nil
        end
        loc = wordpos[n][0]
        n = n+1
      end
  
      #名詞句の出現回数を数える準備
      @phrasecount = []  #数え上げ配列(名詞句)
      temp = nil
      @phraselist.delete(nil)
      postaglist.delete(nil)
      @wordhash = {}
      n = 0
      while n < @phraselist.length
        @wordhash.store(@phraselist[n],postaglist[n])
        n = n+1
      end
      @phraselist.sort!

      #数え上げ
      @phraselist.each {|x|
        if x == temp
          @phrasecount.fill(@phrasecount.last + 1,-1)
        else
          temp = x
          @phrasecount << 1
        end
      }
  
      #全てユニークに
      @phraselist.uniq!
  
    ensure
      m.destroy
    end
	return @phraselist  #単語リスト出力時はword_list
  end 
  
  def feature
    wordfeature = []  #[名詞句、tf、df、関連語配列、posタグ配列]
    n = 0
    while n < @phraselist.length
      key = Keyword.new(@phraselist[n])
      wordfeature << [@phraselist[n],@phrasecount[n],key.relation,@wordhash[@phraselist[n]]]	#key.totaldoc,
      n = n+1
    end
    
    return wordfeature
    
  end
  
  def all_relation(num)
		a = list
    relation = []
    @phraselist.each {|w|
		key = Keyword.new(w)
		relation.concat(key.relation(num))
		#relation << "|"
    }
    return relation
  end
  
end

def scoring(phraselist)
  #m=0
  #phraselist.sort_by{|p|
	#[p[0],m += 1]
  #}
  phraselist.sort!
  termcount = phraselist.length  #tf-idf計算用
  #temp = nil
 
 
#  phraselist.length.times{|n|
#	if n != 0
#		#phraselist[n][0] = "debug"
#		if phraselist[n][0] == phraselist[n-1][0]
#			if phraselist[n][1] >= phraselist[n-1][1]
#				phraselist[n][1] = phraselist[n-1][1]
#				#phraselist[n][1] = 0  #デバッグ
#				#phraselist[n][0] = "debug"
#			else
#				phraselist[n-1][1] = phraselist[n][1]
#				#phraselist[n][0] = "debug"
#			end
#		end
#	end
#  }
#  phraselist.length.times{|n|
#	n = phraselist.length - n - 1
#	if n != phraselist.length - 1
#		if phraselist[n][0] == phraselist[n+1][0]
#			if phraselist[n][1] <= phraselist[n+1][1]
#				phraselist[n+1][1] = phraselist[n][1]
#			else
#				phraselist[n][1] = phraselist[n+1][1]
#			end
#		end
#	end
#  }  
  
  scorelist = {}
  wordcount = []
  temp = nil
  phraselist.each {|p|
    case p[1]
    when 0 then
      score = 100  #内部キーワードの初期スコアは100(基準)
    when 1 then
      score = 75  #1次関連語は90
    when 2 then
      score = 50  #2次関連語は80
    end
    if p[0] == temp
      wordcount.fill(wordcount.last + 1,-1)
    else
      temp = p[0]
      wordcount << 1
    end
	p[2] = p[1]  #キーワードの色分けのため追加
	p[1] = score
  }
  #phraselist.uniq!
  
  temp = []
  phraselist.length.times{|n|
	if n != 0
		if phraselist[n][0] == phraselist[n-1][0]
			temp << n
			#phraselist[n][0] = "debug"
		end
	end
  }
  temp.length.downto(1){|t|
	t = t-1
	phraselist.delete_at(temp[t])
  }

  phraselist.length.times {|n|
	phraselist[n] << wordcount[n]  #phrasecount[n][3]に出現数を格納
    #print phraselist[n],"：",wordcount[n],"\n"
    begin
		#score = 100
		m = Mecab.new("-Ocsv")
		line = Kconv.tosjis(phraselist[n][0])
		#print line,"\n"
		line.chomp!
		node = m.sparse_tonode(line)
		i = -1
		score = 0.0
		#costs = ""
		#score = phraselist[n][1]
		costs = 0.0
		tf_idf = 1.0
		while node.hasNext
			node = node.next
			poslist = []  #品詞タグを分割して配列へ格納
			u_node = Kconv.toutf8(node.pos)
			pos = u_node.split(",")
			poslist.concat(pos)
			if (poslist[0] == "名詞") or (poslist[0] == "接頭詞")
				if (poslist[1] == "一般")  #or (poslist[1] == "数")
					score = score + phraselist[n][1] * 1.0  #0.8
				elsif (poslist[1] == "固有名詞")  #or (poslist[1] == "未知語")
					score = score + phraselist[n][1] * 1.0
					#if (poslist[2] == "一般") or (poslist[4] == "未知語")
					#	score = score + phraselist[n][1] * 0.8
					#elsif poslist[2] == "人名"
					#	score = score + phraselist[n][1] * 0.9
					#elsif poslist[2] == "地域"
					#	score = score + phraselist[n][1] * 0.8
					#else
					#	score = score = phraselist[n][1] * 1.0
					#end
				elsif (poslist[1] == "サ変接続") or (poslist[1] == "接続詞的")
					score = score + phraselist[n][1] * 0.75  #0.5
				elsif (poslist[1] == "数")  #or (poslist[1] == "接続詞的")  #or (poslist[1] == "副詞可能")
					score = score + phraselist[n][1] * 0.5  #0.3
				elsif (poslist[0] == "接頭詞") or (poslist[1] == "接尾")
					score = score + phraselist[n][1] * 1.0
				else
					score = score + phraselist[n][1] * 0.25  #0.1
				end
			elsif poslist[0] != "EOS"
				score = score + phraselist[n][1] * 0
				#phraselist[n] << poslist[0]
			else
				#score = score + phraselist[n][1] * 0.3
			end
			#if costs !=  node.cost
				#costs = costs +  node.cost.to_i  #数値として扱うには".to_i"
			#else
			#	costs = node.cost
			#end
			if poslist[0] != "EOS"
				costs = costs +  (node.cost.to_i) ** 2.0
			end
			i = i+1
		end
		if i != 0  #「0で割れない」のエラーが出るため
			score = score/i  #複合語のスコアは平均値
			#phrasecost = costs/i  #生起コストでidfの代用(この行のパラメータが重要)
			#score = (wordcount[n] - 1) * (0.1) * score + score  #候補中に多く出現するフレーズはスコア上乗せ
			#score = score/phrasecost  #idfを用いた計算
			tf = phraselist[n][3].to_f/termcount.to_f
			idf = Math.sqrt(costs)  #複合語のコストは、各単語のコストの2乗和の平方根
			tf_idf = tf * idf
		else
			score = -1  #エラーが出る場合(たぶん"空白"のとき)はスコア0
		end
		#phraselist[n] << costs  #デバッグ
		if score == nil  #デバッグ
			score = -1
		end
		scorelist.store([phraselist[n][0],phraselist[n][2]],score * tf_idf)  #キーワードの色分けのためphraselist[n][2]を追加
	ensure
		m.destroy
	end
  }
  scorelist = scorelist.sort_by{|key,value| -value}
  #scorelist.sort{|a,b|
	#b[1] <=> a[1]
  #}
  return scorelist
end
  
#body = "パリーグは楽天がCS第2ステージに進出"
#a = Analysis.new(body)
#a.feature.each {|f|
#  print f,"\n"
#}
#puts a.feature

#print "\n\n\n"

#a.all_relation.each{|b|
#  print b," "
#}

#print "\n\n\n"

#a.all_relation.each{|c|
#  d = Analysis.new(c)
  
#  d.all_relation.each{|e|
#    print e," "
#  }
#}
