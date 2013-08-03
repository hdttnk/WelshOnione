require "kconv"
require "analysis"
require "keyword"

class PostsController < ApplicationController
  # GET /posts
  # GET /posts.xml
  def index
    # @posts = Post.find(:all, :order => "id desc")
	@posts = Post.paginate(:page => params[:page], :order => "id desc", :per_page => 10)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])
	#????????
	#body = Kconv.tosjis(@post.body)
	#a = Analysis.new(body)
	#@relations = ""
	#a.all_relation.each{|r|
	#	r_utf8 = Kconv.toutf8(r)
	#	@relations = @relations + " " + r_utf8
	#}
	#??A????A????擾
	#a.all_relation.each{|r|
	#	b = Analysis.new(r)
	#	b.all_relation.each{|c|
	#		c_utf8 = Kconv.toutf8(c)
	#		@relations = @relations + " " + c_utf8
	#	}
	#}
	#???????
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])
		
    respond_to do |format|
      if @post.save
		notice = "メモを作成しました"
        utf8_notice = Kconv.toutf8(notice)
		flash[:notice] = utf8_notice
		
		#body = Kconv.tosjis(@post.body)
		#a = Analysis.new(body)
		#s_word_list = a.list.to_s.strip
		#s_word_list = "test"
		#@relations = ""
		#a.all_relation(2).each{|r|
		#	r_utf8 = Kconv.toutf8(r)
		#	@relations = @relations + " " + r_utf8
		#	b = Analysis.new(r)
		#	b.all_relation(3).each{|c|
		#		c_utf8 = Kconv.toutf8(c)
		#		@relations = @relations + " " + c_utf8
		#	}
		#}

	
	body = Kconv.tosjis(@post.body)
    a = Analysis.new(body)
	s_word_list = a.list.to_s.strip
    @relations = []
    body_phrases = a.list
    utf8_body_phrases = []
    body_phrases.each{|p|
      p_utf8 = Kconv.toutf8(p)
      @relations << [p_utf8,0]
      utf8_body_phrases << [p_utf8,0]
    }
	#a.proper_noun.each{|p|  #複合語だけでなく単語も内部キーワードに含めたいとき
	#	p_utf8 = Kconv.toutf8(p)
	#	@relations << [p_utf8,0]
	#	utf8_body_phrases << [p_utf8,0]
	#}
    body_score_list = scoring(utf8_body_phrases)
    high_score_phrases = []
    20.times{|n|
      if body_score_list[n] != nil
        high_score_phrases << body_score_list[n][0]
      end
    }
	word_list = []
	#20.times{|n|
    #  if body_score_list[n] != nil
    #    word_list << body_score_list[n][0][0]
    #  end
    #}
	body_score_list.each{|b|
      if b[0][0] != nil
        word_list << b[0][0]
      end
    }
	s_word_list = word_list.join(",")
=begin
    high_score_sentence = high_score_phrases.join(" ")
    sjis_high_score_sentence = Kconv.tosjis(high_score_sentence)
    p = Analysis.new(sjis_high_score_sentence)
    p.all_relation(3).each{|r|
      r_utf8 = Kconv.toutf8(r)
      @relations << [r_utf8,1]
      b = Analysis.new(r)
      b.all_relation(5).each{|c|
        c_utf8 = Kconv.toutf8(c)
        if c != r
          @relations << [c_utf8,2]
        end
      }
    }
	
	@score_list = {}
	relation = []
	relation = @relations
	relation.delete("|")
	@score_list = scoring(relation)
	@score_ary = @score_list.to_a
	
	relations = []
	20.times{|n|
		if @score_ary[n] != nil
			phrase_utf8 = Kconv.toutf8(@score_ary[n][0][0])
			relations << phrase_utf8
		end
	}
	
	s_relations = relations.join(",")
	

	
		#a.all_relation(2).each{|r|
		#	b = Analysis.new(r)
		#	b.all_relation(2).each{|c|
		#		c_utf8 = Kconv.toutf8(c)
		#		@relations = @relations + " " + c_utf8
		#	}
		#}
		#s_relations = @relations.to_s.strip

	
		@post.attributes = {
			:suggest_list => s_relations
		}
=end
		@post.attributes = {
			:word_list => s_word_list
		}
		@post.save
		
        format.html { redirect_to(@post) }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        notice = "内容を更新しました"
		utf8_notice = Kconv.toutf8(notice)
		flash[:notice] = utf8_notice
		
		#body = Kconv.tosjis(@post.body)
		#a = Analysis.new(body)
		#s_word_list = a.list.to_s.strip
		#@relations = ""
		#a.all_relation(3).each{|r|
		#	r_utf8 = Kconv.toutf8(r)
		#	@relations = @relations + " " + r_utf8
		#	b = Analysis.new(r)
		#	b.all_relation(3).each{|c|
		#		c_utf8 = Kconv.toutf8(c)
		#		@relations = @relations + " " + c_utf8
		#	}
		#}
		
	body = Kconv.tosjis(@post.body)
    a = Analysis.new(body)
	#s_word_list = a.list.to_s.strip
    @relations = []
    body_phrases = a.list
    utf8_body_phrases = []
    body_phrases.each{|p|
      p_utf8 = Kconv.toutf8(p)
      @relations << [p_utf8,0]
      utf8_body_phrases << [p_utf8,0]
    }
	#a.proper_noun.each{|p|  #複合語だけでなく単語も内部キーワードに含めたいとき
	#	p_utf8 = Kconv.toutf8(p)
	#	@relations << [p_utf8,0]
	#	utf8_body_phrases << [p_utf8,0]
	#}
    body_score_list = scoring(utf8_body_phrases)
    high_score_phrases = []
    20.times{|n|
      if body_score_list[n] != nil
        high_score_phrases << body_score_list[n][0]
      end
    }
	word_list = []
	#20.times{|n|
    #  if body_score_list[n] != nil
    #    word_list << body_score_list[n][0][0]
    #  end
    #}
	body_score_list.each{|b|
      if b[0][0] != nil
        word_list << b[0][0]
      end
    }
	s_word_list = word_list.join(",")
	
=begin
    high_score_sentence = high_score_phrases.join(" ")
    sjis_high_score_sentence = Kconv.tosjis(high_score_sentence)
    p = Analysis.new(sjis_high_score_sentence)
    p.all_relation(3).each{|r|
      r_utf8 = Kconv.toutf8(r)
      @relations << [r_utf8,1]
      b = Analysis.new(r)
      b.all_relation(5).each{|c|
        c_utf8 = Kconv.toutf8(c)
        if c != r
          @relations << [c_utf8,2]
        end
      }
    }
	
	@score_list = {}
	relation = []
	relation = @relations
	relation.delete("|")
	@score_list = scoring(relation)
	@score_ary = @score_list.to_a
	
	relations = []
	20.times{|n|
		if @score_ary[n] != nil
			phrase_utf8 = Kconv.toutf8(@score_ary[n][0][0])
			relations << phrase_utf8
		end
	}
	
	s_relations = relations.join(",")
	#s_relations = relations.to_s.strip
	
		#a.all_relation(2).each{|r|
		#	b = Analysis.new(r)
		#	b.all_relation(2).each{|c|
		#		c_utf8 = Kconv.toutf8(c)
		#		@relations = @relations + " " + c_utf8
		#	}
		#}
		
		#s_relations = @relations.to_s.strip
		
		#@post.attributes = {
		#	:suggest_list => s_relations
		#}	
=end
		@post.attributes = {
			:word_list => s_word_list
		}
		@post.save		
		
        format.html { redirect_to(@post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
  
  def tag
	#@posts = Post.find_tagged_with(tag.name)
	#@posts = Post.find_tagged_with(tag.name, :order => "id desc").paginate(:page => params[:page], :per_page => 10)
    @posts = Post.paginate_tagged_with(params[:id], :page => params[:page], :order => "id desc", :per_page => 10)
	@tag = params[:id]
	respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @posts }
    end
  end
  
  def suggest
    @post = Post.new(params[:post])
    body = Kconv.tosjis(@post.body)
    a = Analysis.new(body)
    @relations = []
	@debug_list = []  #
    body_phrases = a.list
    utf8_body_phrases = []
    body_phrases.each{|p|
      p_utf8 = Kconv.toutf8(p)
      @relations << [p_utf8,0]
      utf8_body_phrases << [p_utf8,0]
	  @debug_list << [p_utf8,0]  #
	  
    }
	#a.proper_noun.each{|p|  #複合語だけでなく単語も内部キーワードに含めたいとき
	#	p_utf8 = Kconv.toutf8(p)
	#	@relations << [p_utf8,0]
	#	utf8_body_phrases << [p_utf8,0]
	#	@debug_list << [p_utf8,0]  #
	#}
    body_score_list = scoring(utf8_body_phrases)
    high_score_phrases = []
    20.times{|n|
      if body_score_list[n] != nil
        high_score_phrases << body_score_list[n][0]
      end
    }
	word_list = []
	#20.times{|n|
    #  if body_score_list[n] != nil
    #    word_list << body_score_list[n][0][0]
    #  end
    #}
	body_score_list.each{|b|
      if b[0][0] != nil
        word_list << b[0][0]
      end
    }
    high_score_sentence = high_score_phrases.join(" ")
    sjis_high_score_sentence = Kconv.tosjis(high_score_sentence)
    p = Analysis.new(sjis_high_score_sentence)
    p.all_relation(3).each{|r|
      r_utf8 = Kconv.toutf8(r)
      @relations << [r_utf8,1]
	  @debug_list << [r_utf8,1]  #
      b = Analysis.new(r)
      b.all_relation(5).each{|c|
        c_utf8 = Kconv.toutf8(c)
        if c != r
          @relations << [c_utf8,2]
		  @debug_list << [c_utf8,2]  #
        end
      }
    }
	#body_phrases = a.list
	#utf8_body_phrases = []
	#body_phrases.each{|p|
	#	p_utf8 = Kconv.toutf8(p)
	#	@relations << [p_utf8,0]
	#	utf8_body_phrases << [p_utf8,0]
	#}
	
	#@sentence = "城島 13日の金曜日に入団会見"
	#@sentence = @relations.join(",")
	#@tfidf_array = tfidf(@post.body)
	#s_tfidf = tfidf_array.join(" ")
	#@tfidf = Kconv.toutf8(s_tfidf)
	
	#@tfidf_array.each{|t|
	#	@debug_list << [t,-1]
	#}
	
	@debug_list.sort!
	
	@score_list = {}
	relation = []
	relation = @relations
	relation.delete("|")
	@score_list = scoring(relation)
	@score_ary = @score_list.to_a
	@max_score = @score_ary[0][1]
	
	@body_score_ary = body_score_list.to_a  #内部キーワードのスコアリストを格納
	@max = @body_score_ary[0][1]
#=begin	
	past_word_list = []
	@r_list = []  #関連文書タグを格納
	@past_posts = Post.find(:all)
	@past_posts.each {|past|
		hit = 0.0
		all = 0.0
		if past.word_list != nil
			past_word_list = past.word_list.split(",")
			word_list.each {|a|
				past_word_list.each {|b|
					if a == b
						hit = hit + 1.0
						#@score_ary << [[a,3],-200]
					end
					all = all + 1.0
				}
			}
			temp = word_list.length**2 + past_word_list.length**2
			alpha = Math.sqrt(temp/2.0)
			ratio = alpha*hit/all
			#ratio = 1.0
			if ratio >= 0.2  #一致率の閾値
				past_tags = []
				past_tags = past.tag_list.split(", ")
				past_tags.each {|tag|
					tag.each{|t|
						#@score_ary.unshift([[t,3],-200])
						#if (t != "1") and (t != "2") and (t != "3") and (t != "4") and (t != "5") and (t != "6") and (t != "7") and (t != "8") and (t != "9") and (t != "10") and (t != "11") and (t != "12") and (t != "13") and (t != "14") and (t != "15") and (t != "16") and (t != "17") and (t != "18") and (t != "19") and (t != "20") and (t != "21") and (t != "22") and (t != "23") and (t != "24") and (t != "25") and (t != "26") and (t != "27") and (t != "28") and (t != "29") and (t != "30") and (t != "31") and (t != "32") and (t != "33") and (t != "34") and (t != "35") and (t != "36") and (t != "37") and (t != "38") and (t != "39") and (t != "40") and (t != "41") and (t != "42") and (t != "43") and (t != "44") and (t != "45") and (t != "46") and (t != "47") and (t != "48") and (t != "49") and (t != "50")
							@r_list << t
						#end
					}
				}
				#@score_ary << [[past.body + "との一致率は" + ratio.to_s,3],-200]  #デバッグ
			end
		end
		#@score_ary << [[past.body + "との一致率は" + ratio.to_s,3],-200]  #デバッグ
	}
#=end
	#suggest_list = []
	@suggest_list = []
	temp = []
	@score_ary.each{|s|
		if s[0][0] != nil
			temp << s[0][0]
		end
	}
	20.times{|n|
		if temp[n] != nil
			@suggest_list << temp[n]
		end
	}
	evaluation_list = @suggest_list# + @tfidf_array
	@evaluation_list = evaluation_list.sort_by{rand}
	@evaluation_list.uniq!
	@r_list.uniq!
	#@body_score_ary = a.list  #デバッグ
	
	#@debug = []
	#@debug = a.wordlist
	#@relations = @debug
	
	
	#a.all_relation(5).each{|r|
	#	b = Analysis.new(r)
	#	b.all_relation(10).each{|c|
	#		c_utf8 = Kconv.toutf8(c)
	#		@relations << c_utf8
	#	}
	#}
    render :layout => false
  end
  
	def select
		@post = Post.find(params[:id])
		#page[@post.tag_list].value = "test"
		render :update do |page|
			page[@post.tag_list].value = "test"#params[:result]
		end
	end

end