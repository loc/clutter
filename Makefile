all:
	g++ main.cpp core.cpp -framework CoreFoundation -framework CoreServices -g -o clutter
