CFLAGS = -O0 -g -Wall
SRC = main.cpp core.cpp cltime.cpp
FRAMEWORKS = -framework CoreFoundation -framework CoreServices -lboost_serialization
NAME = clutter_core
CC = g++

BASE = $(CC) $(SRC) $(FRAMEWORKS) -o $(NAME) -x c++


all:
	$(BASE)

debug: 
	$(BASE) $(CFLAGS)
