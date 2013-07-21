# encoding: utf-8
# $KCODE = 'u'
require "./evaldata"

class SentenceClass
	def initialize(sentence,id)
		@sentence = sentence
		@id = id
		@len = sentence.split(//).size
		@pagerankScore = 0
	end
	#内容を返す
	def showSentence
		@sentence
	end
	#何番目の文か
	def showID
		@id
	end
	#文の長さ
	def len
		@len
	end
	#PageRankスコアを代入
	def setPageRank(score)
		@pagerankScore = score
	end
	#PageRankスコアを返す
	def score
		@pagerankScore
	end
end

class KeywordClass
	def initialize(keyword,keywordScore)
		@keyword = keyword
		@keywordScore = keywordScore
		@parentSentenceScore = 0
		@kewordParentSentenceID = []
		@keywordLen = keyword.split(//).size
	end
	#キーワード
	def showKeyword
		@keyword
	end
	#tf-idfスコア
	def showKeywordScore
		@keywordScore
	end
	#キーワードの長さ
	def len
		@keywordLen
	end
	#何番目の文に登場するかをセット
	def setParentSentenceID(sentID)
		@keywordParentSenteceID << sentID
	end
	#何番目の文か表示
	def showParentSentenceID
		@keywordParentSentenceID
	end
	#文単位で継承したスコアを代入
	def setParentSentenceScore(score)
		@parentSentenceScore = score
	end
	#継承スコア
	def showParentSentenceScore
		@parentSentenceScore
	end
end

class WordClass
	def initialize(word,posList)
		@word = word
		@parentKeywordScore = 0
		@posList = posList
		@wordParentSentenceID = []
	end
	#単語を表示
	def showWord
		@word
	end
	#キーワードに含まれていればスコアを継承
	def setParentKeywordScore(score)
		@parentKeywordScore = score
	end
	#継承スコア
	def showParentKeywordScore
		@parentKeywordScore
	end
	#品詞リストを表示
	def showPosList
		@posList
	end
	#何番目の文に初めて登場するかをセット
	def setParentSentenceID(sentID)
		@wordParentSentenceID << sentID
	end
	#何番目の文か表示
	def showParentSentenceID
		@wordParentSentenceID
	end
end

class CharacterClass
	def initialize(char,tf,documentLength)
		@char = char
		@tf = tf.to_f
		@appear = 0.0
		@totalLen = 0.0
		@sentMaxLen = 0
		@sentMinLen = 10000
		@charParentSentenceID = []
		@parentKeywordScore = 0
		@parentKeywordPlace = []
		@avgPlace = 0
		@avg = 0
		@documentLength = documentLength.to_f
		@idf = 0.0
		idf_temp = 0.0
		$dataSet.each{|d|
			tempSent = d[0]
			tempSent = tempSent.tr('ａ-ｚＡ-Ｚ０-９','a-zA-Z0-9')
			# print @char,"\n"
			if /#{@char}/ =~ tempSent
				idf_temp = idf_temp + 1.0
			end
		}
		@idf = Math.log($dataSet.size / idf_temp) +1.0
		#print idf_temp,"\n"
	end
	#1文字を表示
	def showChar
		@char
	end
	#出現数
	def showTF
		@tf
	end
	#idf
	def showIDF
		@idf
	end
	#出現した文の数
	def setAppearSent
		@appear = @appear + 1
	end
	#キーワードに含まれていればスコアを継承
	def setParentKeywordScore(score)
		@parentKeywordScore = score
	end
	#スコア表示
	def showParentKeywordScore
		@parentKeywordScore
	end
	#含まれる文の最大長
	def setSentenceMaxLen(len)
		@sentMaxLen = len
	end
	#文の最大長
	def showSentenceMaxLen
		@sentMaxLen
	end
	#含まれる文の最小長
	def setSentenceMinLen(len)
		@sentMinLen = len
	end
	#文の最小長
	def showSentenceMinLen
		@sentMinLen
	end
	#含まれる文の長さの和
	def setSentenceTotalLen(len)
		@totalLen = @totalLen + len
	end
	#文の長さの和を表示
	def showSentenceTotalLen
		@totalLen
	end
	#含まれる文の平均長
	def showSentenceAvgLen
		@totalLen / @appear
	end
	#含まれる文番号リスト
	def setParentSentenceID(sentID)
		@charParentSentenceID << sentID
	end
	#文番号リストを表示
	def showParentSentenceID
		@charParentSentenceID
	end
	#キーワードの何文字目なのかセット
	def setParentKeywordPlace(place)
		@parentKeywordPlace << place
	end
	#何文字目なのかの平均を表示
	def showAvgPlace
		@avgPlace = 0
		@parentKeywordPlace.each{|p|
			@avgPlace = @avgPlace + p
		}
		if @parentKeywordPlace.length != 0
			@avg = @avgPlace / @parentKeywordPlace.length
		else
			@avg = 10
		end
		return @avg
	end
	#スコアの計算
	def calcScore
		@avgPlace = 0
		@parentKeywordPlace.each{|p|
			@avgPlace = @avgPlace + p
		}
		if @parentKeywordPlace.length != 0
			@avg = @avgPlace / @parentKeywordPlace.length
		else
			@avg = 10
		end
		if @charParentSentenceID[@charParentSentenceID.length-1] != nil
			return ((0.95) ** @charParentSentenceID[@charParentSentenceID.length-1]) * (@appear / @tf) * ((0.95) ** @avg) * (@parentKeywordScore)
		else
			print "debug\n"
			return 0.0
		end
	end
	#キーワードスコアを使わない計算
	def calcCharOnlyScore
		(@appear / @tf) * ((0.95) ** @charParentSentenceID[@charParentSentenceID.length-1])
	end
	#機械学習用
	def calcLearningScore(p,q,r,s)
		@avgPlace = 0
		@parentKeywordPlace.each{|kp|
			@avgPlace = @avgPlace + kp
		}
		if @parentKeywordPlace.length != 0
			@avg = @avgPlace / @parentKeywordPlace.length
		else
			@avg = 5
		end
		if @charParentSentenceID[@charParentSentenceID.length-1] != nil
			# print ((@tf / @documentLength) * @idf) * 1000,"\n"
			score = ((((@tf / @documentLength) * @idf) * 1000) ** p) * ((1.0 / (@charParentSentenceID[@charParentSentenceID.length-1] +1)) ** q) * ((1.0 / @avg) ** r) * ((@totalLen / @appear) ** s)
			# ((0.95) ** @charParentSentenceID[@charParentSentenceID.length-1]) * (@appear / @tf) * ((0.95) ** @avg) * (@parentKeywordScore)
		else
			print @char,"debug\n"
			score = 0.0
		end
		return score
	end
end



#test = "サッカーの女子ワールドカップ"
#s = SentenceClass.new(test,1)

#print s.sent,"\n",s.showID,"\n",s.len,"\n"