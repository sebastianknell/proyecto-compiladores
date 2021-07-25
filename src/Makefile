all: run

run:
	# make clean
	flex ces.l
	g++ lex.yy.cc -o main main.cpp
	./main < sample.ces

clean:
	rm lex.yy.cc
	rm main