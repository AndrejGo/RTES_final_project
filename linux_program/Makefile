CC=gcc
SRCDIR=src
INCDIR=inc
CFLAGS=-I$(INCDIR)
CFLAGS+= -lpthread
CFLAGS+= -std=c99
CFLAGS+= -D_BSD_SOURCE
CFLAGS+= -Dsoc_cv_av

server: main.o conn_queue.o handlers.o hardware.o
	$(CC) -o server main.o conn_queue.o handlers.o hardware.o $(CFLAGS)

compress: $(SRCDIR)/compress.c $(INCDIR)/huffman.h $(INCDIR)/pqueue.h
	$(CC) -o compress $(SRCDIR)/compress.c $(CFLAGS)

decompress: $(SRCDIR)/decompress.c $(INCDIR)/huffman.h $(INCDIR)/pqueue.h
	$(CC) -o decompress $(SRCDIR)/decompress.c $(CFLAGS)

conn_queue.o: $(SRCDIR)/conn_queue.c $(INCDIR)/conn_queue.h
	$(CC) -c $(SRCDIR)/conn_queue.c $(CFLAGS)

handlers.o: $(SRCDIR)/handlers.c $(INCDIR)/handlers.h
	$(CC) -c $(SRCDIR)/handlers.c $(CFLAGS)

hardware.o: $(SRCDIR)/hardware.c $(INCDIR)/hardware.h
	$(CC) -c $(SRCDIR)/hardware.c $(CFLAGS)

clean:
	rm -f *.o server compress decompress
