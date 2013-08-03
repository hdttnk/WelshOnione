require "dl/import"
require "dl/struct"

#libmecab.dllのpathは自分で変えてね

module MecabFunc
  extend DL::Importable
  typealias('size_t', 'unsigned long')
  path = 'C:/Program Files/MeCab/bin/libmecab.dll'#美しくない！！！
  
  dlload path
  extern "mecab_t* mecab_new2(const char*)"
  extern "const char* mecab_version()"
  extern "const char* mecab_sparse_tostr(mecab_t*, const char*)"
  extern "const char* mecab_strerror(mecab_t*)"
  extern "const char * mecab_nbest_sparse_tostr(mecab_t *,size_t,const char *)"
  extern "void mecab_destroy(mecab_t *)"
  extern "int mecab_nbest_init(mecab_t*, const char*)"
  extern "const char* mecab_nbest_next_tostr (mecab_t*)"
  
  #自己参照構造体をperseしてくれないというかうまくいかない
  #mecab_sparse_tonodeに関してはruby側で嘘ラップすることにした
  #extern "mecab_node_t* mecab_sparse_tonode (mecab_t *, const char *)"
  #mecab_node_t = struct ["struct mecab_node_t *prev" , "struct mecab_node_t  *next","struct mecab_node_t  *enext","struct mecab_node_t  *bnext","char  *surface","char * feature","unsigned int length","unsigned int rlength","unsigned int id","unsigned short rcAttr","unsigned short lcAttr","unsigned short posid","unsigned char char_type","unsigned char stat","unsigned char isbest","float alpha","float beta","float prob","short wcost","long cost"]
  #MECAB_NOR_NODE=0
  #MECAB_UNK_NODE=1
  #MECAB_BOS_NODE=2
  #MECAB_EOS_NODE=3
end

class Mecab
  include MecabFunc
  @mecab=nil
  def initialize(args)
    @mecab=MecabFunc.mecab_new2(args)
  end
  
  def version()
    MecabFunc.mecab_version()
  end
  
  def strerror()
    MecabFunc.mecab_strerror(@mecab)
  end
  
  def sparse_tostr(str)
    MecabFunc.mecab_sparse_tostr(@mecab,str)
  end
  
  def nbest_sparse_tostr(nbest,str)
    MecabFunc.mecab_nbest_sparse_tostr(@mecab,nbest,str)
  end
  
  def nbest_init(str)
    MecabFunc.mecab_nbest_init(@mecab,str)
  end
  
  def nbest_next_tostr()
    MecabFunc.mecab_nbest_next_tostr(@mecab)
  end
  
  def sparse_tonode(str)
    #ruby側でラップすることにした
    #一番最初に帰ってくる先頭は見てはいけません。先頭であることを表す次のノードへのポインタ以外何も保持しないインスタンスです
    prev=nil
    head=Node.new()
    sparse_tostr(str).split("\n").each{|line|
      buf=Node.new(line,prev)
      if prev!=nil
        prev.next=buf
      end
      prev=buf
      
      if head.next==nil
        head.next=buf
      end
    }
    head
  end
  
  def destroy()
    MecabFunc.mecab_destroy(@mecab)
  end
  
  class Node
    @prev=nil
    @next=nil
    
    @surface=nil#形態素の表記
    @pos=nil#品詞
    @root=nil#原形
    @reading=nil#読み
    @pronunciation=nil#発音
	@cost = nil
    #mecab_node_tの情報全部欲しければ
    #http://mecab.sourceforge.net/format.html
    #参照するしかない感じ
    #普通にラップした感じのデータを作る感じで
    #mecabの通常出力をラップします
    attr_accessor :prev,:next,:surface,:pos,:root,:reading,:pronunciation,:cost
    
    def initialize(line=nil,prev=nil)
      @prev=prev
      
      if line != nil
        if line == "EOS"#EOSの時
          @surface=line
          @pos="EOS"
          @root="EOS"
          @reading="EOS"
          @pronunciation="EOS"
        else#それ以外
          linels=line.split("\t")
          @surface=linels[0]
          fetls=linels[1].split(",")
		  n=0
		  while n < 6
			if fetls[n] == nil
				fetls[n] = "*"
			end
			n = n+1
		  end
          @pos=fetls[0..5].join(",")
		  @cost = fetls[9]  #生起コスト出力のため追加
          if fetls[6]==nil
            @root=""
          else
            @root=fetls[6]
          end
          if fetls[7]==nil
            @reading=""
          else
            @reading=fetls[7]
          end
          if fetls[8]==nil
            @pronunciation=""
          else
            @pronunciation=fetls[8]
          end
        end
      end
    end
    
    def hasNext()
      if @next==nil
        false
      else
        true
      end
    end
  end
end

#sample
#begin
#  m=Mecab.new("")
#  puts m.version
#  puts m.sparse_tostr("本日は晴天なり")
#  node = m.sparse_tonode("本日は晴天なり")#この関数は、mecabの起動オプションがデフォルトのときのみ利用してください
#  while node.hasNext
#    node = node.next
#    print node.surface + " : " + node.pos + " : " + node.root + " : " + node.reading + " : " + node.pronunciation + "\n"
#  end
#ensure
#  m.destroy
#end

