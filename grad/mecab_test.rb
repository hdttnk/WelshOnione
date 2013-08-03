require "mecab"

begin
	m = Mecab.new("")
	puts m.version
	puts m.sparse_tostr("�{���͐��V�Ȃ�")
	node = m.sparse_tonode("�{���͐��V�Ȃ�")
	while node.hasNext
		node = node.next
		print node.surface + " : " + node.pos + " : " + node.root + " : " + node.reading + " : " + node.pronunciation + "\n"
	end
ensure
	m.destroy
end