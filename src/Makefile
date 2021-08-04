# Makefile

OBJS	= bison.o lex.o main.o

CC	= g++ -L /usr/local/opt/flex/lib
CFLAGS	= -g -Wall -ansi -pedantic

ces:		$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o ces -lfl

lex.o:		lex.c
		$(CC) $(CFLAGS) -c lex.c -o lex.o

lex.c:		ces.l 
		flex ces.l
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o

bison.c:	ces.y
		bison -d -v ces.y
		cp ces.tab.c bison.c
		cmp -s ces.tab.h tok.h || cp ces.tab.h tok.h

main.o:		main.cc
		$(CC) $(CFLAGS) -c main.cc -o main.o

lex.o bison.o main.o	: heading.h
lex.o main.o			: tok.h

clean:
	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h ces.tab.c ces.tab.h ces.output ces
