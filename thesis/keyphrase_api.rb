$KCODE = "u"

require "rexml/document"
require "kconv"
require "cgi"
require "open-uri"
require "jcode"

nadeshiko = "サッカーの女子ワールドカップ（W杯）ドイツ大会で初優勝し、国民栄誉賞受賞が決まった日本代表（なでしこジャパン）の佐々木則夫監督が2日午後、東京都文京区の日本サッカー協会で記者会見し、「非常に感動している。本当に心が引き締まる思い」と受賞の喜びを語った。大会で印象的だった笑顔とは打って変わって緊張した表情で会見に臨んだ佐々木監督は、受賞の理由について「力の差のある相手に、最後まで諦めずに戦った。東日本大震災があった中で、そういう戦い方が国民に勇気と感動を与えられたのでは」と語った。一方で、「（女子日本代表は）今回の大会で非常に急激な躍進をした。こういう賞をいただいて戸惑いもある」とも述べた。9月には、ロンドン五輪アジア予選が控える。佐々木監督は「しっかり勝ち抜くことがわれわれの責務。アジア予選はつばぜり合いになる。チャンピオンとして戦えば足をすくわれる」とした上で、「北京五輪は4位で悔しい思いをした。ロンドン五輪はそれ以上の物を目指してトライしたい」と力強く宣言した。"

nagatomo = "インテルの日本代表ＤＦ長友佑都（２４）が右肩脱臼の治療のために緊急帰国し、保存療法か、日本で手術を受けるか決断することが１日に分かった。"

genpatsu = "東京電力福島第一原子力発電所事故の賠償を支援する「原子力損害賠償支援機構法」は、３日午前の参院本会議で与党や自民、公明両党などの賛成多数で可決、成立した。同法は近く施行され、巨額の賠償金を抱える東電の資金繰りを支えるために原子力損害賠償支援機構が今月中にも設立される見通しだ。機構は、東電の債務超過を回避して被害者への賠償支払いを着実に行うための相互扶助の仕組みだ。政府の第三者委員会「東京電力に関する経営・財務調査委員会」が９月中に出す資産査定の結果を踏まえ、機構と東電で特別事業計画を策定し、経済産業相の認定後、１０月末をめどに機構から東電に対する資金支援が始まる見込みだ。国が賠償金を仮払いするよう定めた原子力損害賠償仮払い法が７月２９日に成立しており、政府は機構法の成立を受けて被害者への賠償金仮払いを加速する方針だ。"

kodomo = "民主党の岡田幹事長と玄葉政調会長は３日午前、国会内で会談し、子ども手当の見直しについて、自民、公明両党が求めている今年１０月からの子ども手当廃止と児童手当復活には応じられないとの認識で一致した。民主党は２０１２年度から子ども手当を廃止し、自公政権時代の児童手当を復活・拡充する方針を固めており、廃止の時期をめぐる３党の調整は難航しそうだ。岡田、玄葉両氏が１０月廃止には応じられないと判断したのは、児童手当が復活すれば地方負担が生じるため、「地方の理解を得るための時間が足りない」（民主党幹部）と見たためだ。このため、両氏は、９月末で期限が切れる現行の子ども手当「つなぎ法」（中学生まで月１万３０００円支給）を、今年度末まで延長する方針を再確認した。"

sentence = kodomo

#全角英数字は半角に
sentence = sentence.tr('ａ-ｚＡ-Ｚ０-９','a-zA-Z0-9')



#キーフレーズ抽出API
utf8_sentence = CGI.escape(Kconv.toutf8(sentence))
url = "http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=SuvpRFixg64kNxcyisGXYi5M6dec7RbfXUHJRXkY246KVTtHI3djMXUW193ECJE-&sentence=" + utf8_sentence
doc = REXML::Document.new(open(url))

keyphrase_score = []
doc.elements.each("ResultSet/Result"){|element|
	temp_keyphrase = Kconv.toutf8(element.text("Keyphrase"))
	temp_score = element.text("Score").to_i
	keyphrase_score << [temp_keyphrase,temp_score]
}

print sentence,"\n\n"
keyphrase_score.length.times{|n|
	print keyphrase_score[n][0]," -> ",keyphrase_score[n][1],"\n"
}

#形態素解析API
utf8_sentence = CGI.escape(Kconv.toutf8(sentence))
url = "http://jlp.yahooapis.jp/MAService/V1/parse?appid=SuvpRFixg64kNxcyisGXYi5M6dec7RbfXUHJRXkY246KVTtHI3djMXUW193ECJE-&response=surface,reading,pos,feature&results=ma&ma_filter=9&sentence=" + utf8_sentence
doc = REXML::Document.new(open(url))

keitaiso = []
doc.elements.each("ResultSet/ma_result/word_list/word"){|element|
	temp_surface = Kconv.toutf8(element.text("surface"))
	temp_feature = Kconv.toutf8(element.text("feature")).split(",")
	keitaiso << [temp_surface,temp_feature]
}

#形態素にスコア情報を付与
keitaiso.length.times{|m|
	temp_score = 0
	(keyphrase_score.length-1).downto(0){|n|
		if /#{keitaiso[m][0]}/ =~ keyphrase_score[n][0]
			temp_score = keyphrase_score[n][1]
		end
	}
	keitaiso[m] << temp_score
}

#重複数をとる？
keitaiso.uniq!

keitaiso.length.times{|n|
	print keitaiso[n][0]," ---pos---> ",keitaiso[n][1][1]," ---score---> ",keitaiso[n][2],"\n"
}


#1文字ずつの処理
char_array =[]
char_array = sentence.split(//)

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


char_time.each{|c|
	print Kconv.toutf8(c[0])," => ",c[1],"\n"
}

#1文字とスコア付き形態素のマッチング
char_time.each{|c|
	temp_place = 1000
	temp_score = 0
	temp_time = 0
	keitaiso.each{|k|
		temp_bool = false
		k_array = k[0].split(//)
		(k_array.length-1).downto(0){|n|
			if c[0] == k_array[n]
				if k[2] >= temp_score
					#temp_place = n
					temp_score = k[2]
					temp_bool = true
					if temp_place == 1000
						temp_place = n
					elsif temp_place >= n
						temp_place = n
					end
				end
			end
		}
		if temp_bool
			temp_time = temp_time + 1
		end
	}
	c << temp_place
	c << temp_score
	c << temp_time
}

char_time.each{|c|
	print c[0],",",c[1],",",c[2],",",c[3],",",c[4],"\n"
}

#スコア計算
scorelist = []
char_time.each{|c|
	score = 0
	t = c[1]
	p = c[2]
	s = c[3]
	k = c[4]
	score = (s+100)*(0.9**p)*(k+100)/100
	scorelist << [c[0],score]
}

print "\n",sentence,"\n\n"

scorelist = scorelist.sort{|a,b| b[1] <=> a[1]}

scorelist.each{|s|
	print s[0]," ---score---> ",s[1],"\n"
}
