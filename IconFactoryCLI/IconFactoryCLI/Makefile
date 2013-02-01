CC=clang

all: icnsmaker cleanobj

NSImage+Resize.o: NSImage+Resize.m

IcnsFactory.o: IcnsFactory.m

main.o: main.m

icnsmaker: IcnsFactory.o NSImage+Resize.o main.o
	clang IcnsFactory.o NSImage+Resize.o main.o -o icnsmaker \
		-framework Foundation -framework Cocoa
clean:
	rm -rf *.o icnsmaker

cleanobj: 
	rm -rf *.o

install:
	cp icnsmaker /usr/local/bin

uninstall:
	rm -rf /usr/local/bin/icnsmaker

