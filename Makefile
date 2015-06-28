CFLAGS = -O0 -g -Wall
SRC = main.cpp core.cpp
FRAMEWORKS = -framework CoreFoundation -framework CoreServices 
NAME = clutter
CC = g++

BASE = $(CC) $(SRC) $(FRAMEWORKS) -o $(NAME)


all:
	$(BASE)

debug: 
	$(BASE) $(CFLAGS)
