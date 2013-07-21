# encoding: utf-8
# $KCODE = 'u'

require "rexml/document"
require "kconv"
require "cgi"
require "open-uri"
# require "jcode"
require "./defclass"
require "./apis"

#テストデータ
nadeshiko = "サッカーの女子ワールドカップ（W杯）ドイツ大会で初優勝し、国民栄誉賞受賞が決まった日本代表（なでしこジャパン）の佐々木則夫監督が2日午後、東京都文京区の日本サッカー協会で記者会見し、「非常に感動している。本当に心が引き締まる思い」と受賞の喜びを語った。大会で印象的だった笑顔とは打って変わって緊張した表情で会見に臨んだ佐々木監督は、受賞の理由について「力の差のある相手に、最後まで諦めずに戦った。東日本大震災があった中で、そういう戦い方が国民に勇気と感動を与えられたのでは」と語った。一方で、「（女子日本代表は）今回の大会で非常に急激な躍進をした。こういう賞をいただいて戸惑いもある」とも述べた。9月には、ロンドン五輪アジア予選が控える。佐々木監督は「しっかり勝ち抜くことがわれわれの責務。アジア予選はつばぜり合いになる。チャンピオンとして戦えば足をすくわれる」とした上で、「北京五輪は4位で悔しい思いをした。ロンドン五輪はそれ以上の物を目指してトライしたい」と力強く宣言した。"

bicycle = "警察庁が２５日公表した自転車交通総合対策で自転車の原則車道走行を強く打ち出したことで、他省庁や自治体も対応を迫られている。車道走行の実現には安全に走れる環境作りと交通ルールの周知が不可欠。省庁や自治体は警察と連携しながら新たな自転車政策を検討することになるが、これまで一般化していた歩道走行からの転換に戸惑う声もあった。"

daiou = "大王製紙の井川意高（もとたか）元会長による巨額借り入れ問題で、大王本社の役員１７人中１１人が今年６月の株主総会で一斉に退任・降格していたことが２６日、分かった。井川元会長の父で同社顧問の高雄氏は、毎日新聞の取材に「３月の時点で巨額融資の一部を知った」「本社の取締役らも知っていた」と説明しているが、退任・降格の際、こうした状況に関する説明はなかった。事態の公表を避ける一方で、降格人事で処理しようとした可能性があり、同社の手法に批判が集まりそうだ。"

senkaku = "尖閣諸島沖で９月７日、違法操業していた中国漁船が、哨戒中の海上保安庁の巡視船２隻と衝突した。同庁は８日、中国人船長を公務執行妨害容疑で逮捕したが、那覇地検は２５日、日中関係への配慮などを理由に、処分保留のまま釈放した。中国は事件発生直後から「尖閣諸島は日本の領土ではなく、違法操業にはあたらない」などと抗議を繰り返した。河北省の軍事管理区域では、中国人船長の勾留延長が決まった翌日の２０日、不法にビデオ撮影したとして建設会社の日本人社員４人を拘束した。ハイブリッド車の部品などの製造に欠かせないレアアース（希土類）については輸出を規制し、青年交流や条約交渉の中止などの対抗措置を取った。各地では反日デモが起きた。中国人船長釈放は、こうした「報復」と「圧力」に屈したとも受け止められた。日本政府は衝突時のビデオ映像の一般公開を避けていたが、１１月に入り、映像はインターネットの動画投稿サイト「ユーチューブ」に流出した。神戸海上保安部の海上保安官が自ら流出させたことを明らかにし、警視庁などが国家公務員法（守秘義務）違反容疑で捜査している。一連の日本政府の対応は、国内世論の厳しい批判にさらされた。"

#sentence = senkaku




#tempArray.delete(nil)
#tempArray.delete("")
#tempArray.each{|t|
#	print t,"\n"
#}



#デバッグ
#sentenceArray.each{|s|
#	print s.sent,"->",s.showID,"->",s.len,"\n"
#}





#デバッグ
#keywordArray.each{|k|
#	print k.showKeyword," -> ",k.showKeywordScore,"\n"
#}



#デバッグ
#wordArray.each{|w|
#	print w.showWord," -> ",w.showParentSentenceID," -> ",w.showPosList[0]," -> ",w.showParentKeywordScore,"\n"
#}



#デバッグ
#charArray.each{|c|
#	print c.showChar," -> ",c.showTF," -> ",c.showParentSentenceID.join(",")," -> ",c.showParentKeywordScore," -> ",c.showSentenceMaxLen," -> ",c.showSentenceMinLen," -> ",c.showSentenceAvgLen," -> Score: ",c.calcScore,"\n"
#}

#都合の悪い文字(nil)を除去
#charArray.delete_if {|c| c.showParentSentenceID[c.showParentSentenceID.length-1] == nil}

#参考
=begin
charArray = charArray.sort{|a,b| b.calcScore <=> a.calcScore}
maxScore = 0.0
charArray.each{|c|
	if c.calcScore > maxScore
		maxScore = c.calcScore
	end
}
=end
#アルゴリズム1
=begin
charArray.each{|c|
	# if c.calcScore != 0.0
		print c.showChar," -> Score: ",(c.calcScore / maxScore)*100,"\n"
		# print c.showChar," -> Score: ",c.showParentKeywordScore,"\n"
	# end
}
=end

#charArray = charArray.sort{|a,b| b.calcCharOnlyScore <=> a.calcCharOnlyScore}
#maxScore = 0.0
#charArray.each{|c|
#	if c.calcCharOnlyScore > maxScore
#		maxScore = c.calcCharOnlyScore
#	end
#}
#アルゴリズム2
#charArray.each{|c|
#	# if c.calcScore != 0.0
#		print c.showChar," -> Score: ",(c.calcCharOnlyScore / maxScore)*100,"\n"
#	# end
#}

eval2Array = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
eval2Array = [10]

eval2Array.each{|e2v|
$dataSet.each{|ds|
sentence = ds[0]
					sentence.gsub!("(","（")
					sentence.gsub!(")","）")
					# 全角英数字は半角に
					sentence = sentence.tr('ａ-ｚＡ-Ｚ０-９','a-zA-Z0-9')
					# tempArrayに各文を格納
					sentence.gsub!("。","。\n")
					tempArray = sentence.split("\n")
					# 各文をclassにしてsentArrayへ格納
					# sentenceArrayはSentenceClassクラスの配列
					sentenceArray = []
					tempArray.length.times{|n|
						sentenceArray << SentenceClass.new(tempArray[n],n)
					} 
					# ここまでの動作
					# sentenceArrayはSentenceClassクラスの配列
					# SentenceClassクラスは文の出現位置とか長さ
					# キーワード抽出APIの結果を配列に格納
					# KeywordClassクラスを利用
					keywordArray = []
					keywordArray = keyphraseAPI(sentence)
					# 形態素解析の結果をWordClassクラスとして格納
					# wordArray = []
					# wordArray = keitaiso(sentence,keywordArray,sentenceArray)
					# 1文字の処理
					charArray = []
					charArray = charAnalyze(sentence,keywordArray,sentenceArray)
					ds << charArray
}
#0.00〜1.00のパラメータ配列を生成
parameterArray = []
1.upto(9){|n|
	parameterArray << n/10.0
}
#デバッグ

#parameterArray = [0,0.2,0.4,0.6,0.8,1.0]
#parameterArray = [0.0,1.0]

#文字の出現頻度の数え上げ配列を生成？

@rankingArray = []
#最適パラメータを探索
parameterArray.each{|p|
	parameterArray.each{|q|
		parameterArray.each{|r|
			parameterArray.each{|s|
			 if (p == 0.7) and (q == 0.8) and (r == 0.7)  and (s == 0.2)  # パラメータ固定
				# print "p = ",p," , q = ",q," , r = ",r," , s = ",s,"\n"
				totalScore = 0.0
				matchNum = 0.0  # 的中数
				totalAnswer = 0.0
				totalCand = 0.0
				@totalOrder = 0.0
				$dataSet.each{|ds|
				 print "\n",ds[0],"\n"  # 文章の内容を表示
=begin
					sentence = ds[0]
					sentence = sentence.toutf8
					# 全角英数字は半角に
					sentence = sentence.tr('ａ-ｚＡ-Ｚ０-９','a-zA-Z0-9')
					# tempArrayに各文を格納
					sentence.gsub!("。","。\n")
					tempArray = sentence.split("\n")
					# 各文をclassにしてsentArrayへ格納
					# sentenceArrayはSentenceClassクラスの配列
					sentenceArray = []
					tempArray.length.times{|n|
						sentenceArray << SentenceClass.new(tempArray[n],n)
					} 
					# ここまでの動作
					# sentenceArrayはSentenceClassクラスの配列
					# SentenceClassクラスは文の出現位置とか長さ
					# キーワード抽出APIの結果を配列に格納
					# KeywordClassクラスを利用
					keywordArray = []
					keywordArray = keyphraseAPI(sentence)
					# 形態素解析の結果をWordClassクラスとして格納
					# wordArray = []
					# wordArray = keitaiso(sentence,keywordArray,sentenceArray)
					# 1文字の処理
					charArray = []
					charArray = charAnalyze(sentence,keywordArray,sentenceArray)
=end
					charArray = ds[2]
					# 毎回スコア順に並び替え
					charArray = charArray.sort{|a,b| b.calcLearningScore(p,q,r,s) <=> a.calcLearningScore(p,q,r,s)}
					maxScore = 0.0
					charArray.each{|c|
						if c.calcLearningScore(p,q,r,s) > maxScore
							maxScore = c.calcLearningScore(p,q,r,s)
						end
					}
					# 機械学習アルゴリズム
					# charArray.each{|c|
					# 	print c.showChar," -> Score: ",(c.calcScore / maxScore)*100,"\n"
					# }
					# 上位10個(10位タイまで)の結果配列
					# 末尾の順位が10以上あるものは除外？5以上あるものを切り捨てる？
					@topN = e2v
					@topNArray = []
					1.upto(charArray.length){|n|
						if n == 1
							@topNArray << [charArray[n-1],n]
						elsif charArray[n-1].calcLearningScore(p,q,r,s) != charArray[n-2].calcLearningScore(p,q,r,s)
							if n <= @topN
								@topNArray << [charArray[n-1],n]
							else
								break
							end
						else
							if @topNArray[n-2][1] <= @topN
								@topNArray << [charArray[n-1],@topNArray[n-2][1]]
							end
						end
					}
					totalAnswer = totalAnswer + ds[1].length
					@topNArray.each{|t|
						totalCand = totalCand + 1
						# totalAnswer = totalAnswer + ds[1].length
						# print t[0].showChar,"\n"
						ds[1].each{|a|
							# totalAnswer = totalAnswer + 1
							if a[0] == t[0].showChar
								# totalScore = totalScore + 1 * (1.0 +(a[1] / 10.0)) # (t[0].calcLearningScore(p,q,r,s) * (1.0 +(a[1] / 10.0)))
								
								 matchNum = matchNum + 1
								 # if t[1] < 6
								# @totalOrder = @totalOrder + (11 - t[1])
								 # end
								 
								# print t[0].showIDF,"\n"
							end
						}
						# print t[0].showChar,"\n"  # 抽出結果を表示
						 print t[0].showChar," , ",t[1]," , ",(t[0].calcLearningScore(p,q,r,s) / maxScore) * 100,"\n"
					}

				}
				precision = matchNum / totalCand
				recall = matchNum / totalAnswer
				# print totalAnswer,"\n"
				fmeasure = ((2 * precision * recall) / (precision + recall))
				# print "スコア：",totalScore,"  的中数：",matchNum,"  適合率：",precision,"  再現率：",recall,"  F値：",fmeasure,"\n" # ,@top10Array.size,"\n"
				@rankingArray << [[p,q,r,s],totalScore,matchNum,precision,recall,fmeasure]
			 end  # パラメータ固定
			}
		}
	}
}

=begin
print "\n","スコア順\n"
@rankingArray = @rankingArray.sort{|a,b| b[1] <=> a[1]}
maxRankScore = @rankingArray[0][1]
@rankingArray.each{|r|
	print "p = ",r[0][0]," , q = ",r[0][1]," , r = ",r[0][2]," , s = ",r[0][3],"\n"
	print "スコア：",(r[1] / maxRankScore) * 100,"\n"
}
=end

print "出力数：",@topN,"\n"

print "\n","的中数順\n"
@rankingArray = @rankingArray.sort{|a,b| b[2] <=> a[2]}
#maxRankScore = @rankingArray[0][1]
@rankingArray.each{|r|
	print "p = ",r[0][0]," , q = ",r[0][1]," , r = ",r[0][2]," , s = ",r[0][3],"\n"
	# print (r[1] / maxRankScore) * 100,"\n"
	print "的中数：",r[2],"\n"
}
print "\n","適合率順\n"
@rankingArray = @rankingArray.sort{|a,b| b[3] <=> a[3]}
#maxRankScore = @rankingArray[0][1]
@rankingArray.each{|r|
	print "p = ",r[0][0]," , q = ",r[0][1]," , r = ",r[0][2]," , s = ",r[0][3],"\n"
	# print (r[1] / maxRankScore) * 100,"\n"
	print "適合率：",r[3],"\n"
}
print "\n","再現率順\n"
@rankingArray = @rankingArray.sort{|a,b| b[4] <=> a[4]}
#maxRankScore = @rankingArray[0][1]
@rankingArray.each{|r|
	print "p = ",r[0][0]," , q = ",r[0][1]," , r = ",r[0][2]," , s = ",r[0][3],"\n"
	# print (r[1] / maxRankScore) * 100,"\n"
	print "再現率：",r[4],"\n"
}
print "\n","F値順\n"
@rankingArray = @rankingArray.sort{|a,b| b[5] <=> a[5]}
#maxRankScore = @rankingArray[0][1]
@rankingArray.each{|r|
	print "p = ",r[0][0]," , q = ",r[0][1]," , r = ",r[0][2]," , s = ",r[0][3],"\n"
	# print (r[1] / maxRankScore) * 100,"\n"
	print "F値：",r[5],"\n"
}
}

#print "順位合計：",@totalOrder,"\n"