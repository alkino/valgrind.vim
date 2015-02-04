all: main.c b.h b.o
	gcc -g -o a.out main.c b.o

b.o: b.c b.h
	gcc -g -c -o b.o b.c
clean:
	rm -rf a.out a.o b.o
