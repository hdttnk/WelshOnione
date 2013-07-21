# encoding: utf-8
# $KCODE = 'u'

#文を引数にしてKeywordClassクラスの配列を返す
def keyphraseAPI(sentence)
	utf8_sentence = CGI.escape(Kconv.toutf8(sentence))
	url = "http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=SuvpRFixg64kNxcyisGXYi5M6dec7RbfXUHJRXkY246KVTtHI3djMXUW193ECJE-&sentence=" + utf8_sentence
	doc = REXML::Document.new(open(url))
	keyphrase_score = []
	doc.elements.each("ResultSet/Result"){|element|
		temp_keyphrase = Kconv.toutf8(element.text("Keyphrase"))
		temp_score = element.text("Score").to_i
#keyphrase_score << [temp_keyphrase,temp_score]
		keyphrase_score << KeywordClass.new(temp_keyphrase,temp_score)
	}
	return keyphrase_score
end

#文を形態素解析してWordClassクラスの配列を返す
def keitaiso(sentence,keyphraseScoreArray,sentenceArray)
	utf8_sentence = CGI.escape(Kconv.toutf8(sentence))
	url = "http://jlp.yahooapis.jp/MAService/V1/parse?appid=SuvpRFixg64kNxcyisGXYi5M6dec7RbfXUHJRXkY246KVTtHI3djMXUW193ECJE-&response=surface,reading,pos,feature&results=ma&ma_filter=9&sentence=" + utf8_sentence
	doc = REXML::Document.new(open(url))
	keitaiso = []
	doc.elements.each("ResultSet/ma_result/word_list/word"){|element|
		temp_surface = Kconv.toutf8(element.text("surface"))
		temp_feature = Kconv.toutf8(element.text("feature")).split(",")
		keitaiso << WordClass.new(temp_surface,temp_feature)
	}
	#形態素にスコア情報を付与
	keitaiso.length.times{|m|
		temp_score = 0
		(keyphraseScoreArray.length-1).downto(0){|n|
			if /#{keitaiso[m].showWord}/ =~ keyphraseScoreArray[n].showKeyword
				keitaiso[m].setParentKeywordScore(keyphraseScoreArray[n].showKeywordScore)
			end
		}
		#含まれる文のID
		(sentenceArray.length-1).downto(0){|l|
			if /#{keitaiso[m].showWord}/ =~ sentenceArray[l].showSentence
				keitaiso[m].setParentSentenceID(sentenceArray[l].showID)
				#PageRankスコアの継承もこのへんで？
			end
		}
	}
	#重複数をとる？
	keitaiso.uniq!
	return keitaiso
end

#1文字に切り分けて解析した結果をCharacterClassクラスの配列として返す
def charAnalyze(sentence,keyphraseScoreArray,sentenceArray)
	#とりあえず1文字ずつ切り分けて格納
	documentLength = 0
	char_array = []
	char_array = sentence.split(//)
	char_array.delete("\n")
	documentLength = char_array.size
	#出現回数と併せて格納
	char_time = []
	char_array.length.times{|m|
		i=0
		char_array.length.times{|n|
			if char_array[m] == char_array[n]
				i=i+1
			end
		}
		char_time << [char_array[m],i]
	}
	char_time.uniq!
	#CharacterClassクラスの配列charArray
	charArray = []
	char_time.each{|c|
		charArray << CharacterClass.new(c[0],c[1],documentLength)
	}
	#1文字にスコア情報を付与
	charArray.length.times{|m|
		temp_score = 0
		(keyphraseScoreArray.length-1).downto(0){|n|
			if /#{charArray[m].showChar}/ =~ keyphraseScoreArray[n].showKeyword
				if charArray[m].showParentKeywordScore < keyphraseScoreArray[n].showKeywordScore
					charArray[m].setParentKeywordScore(keyphraseScoreArray[n].showKeywordScore)
				end
				#キーワードの長さとかもセット
				phraseArray = []
				phraseArray = keyphraseScoreArray[n].showKeyword.split(//)
				(phraseArray.length-1).downto(0){|x|
					if charArray[m].showChar == phraseArray[x]
						charArray[m].setParentKeywordPlace(x+1)
					end
				}
			end
		}
		#含まれる文のID
		(sentenceArray.length-1).downto(0){|l|
			if /#{charArray[m].showChar}/ =~ sentenceArray[l].showSentence
				charArray[m].setParentSentenceID(sentenceArray[l].showID)
				#文の長さもセット
				if charArray[m].showSentenceMaxLen < sentenceArray[l].len
					charArray[m].setSentenceMaxLen(sentenceArray[l].len)
				end
				if charArray[m].showSentenceMinLen > sentenceArray[l].len
					charArray[m].setSentenceMinLen(sentenceArray[l].len)
				end
				charArray[m].setSentenceTotalLen(sentenceArray[l].len)
				charArray[m].setAppearSent
				#PageRankスコアの継承もこのへんで？
			end
		}
	}
	return charArray
end