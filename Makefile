test: parse.rb
	./test.sh

racc-c: parse.rb
racc: parse.rb
	ruby parse.rb

parse.rb: parse.y
	racc -g -o parse.rb parse.y
