require "mecab"

begin
	m = Mecab.new("")
	puts m.version
	puts m.sparse_tostr("本日は晴天なり")
	node = m.sparse_tonode("本日は晴天なり")
	while node.hasNext
		node = node.next
		print node.surface + " : " + node.pos + " : " + node.root + " : " + node.reading + " : " + node.pronunciation + "\n"
	end
ensure
	m.destroy
end