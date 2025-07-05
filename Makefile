SHELL := /bin/bash
RM := rm -rf
CPPFLAGS := -I src

###########################################################

ENTITIES := \
ListIterator \
List \
Optional \
Pair \

ENTITY_SRCS := $(ENTITIES:%=src/%.mlp)
ENTITY_OBJS := $(ENTITIES:%=src/%.ml)

###########################################################

all: main

main: $(ENTITY_OBJS) src/utils.ml

clean:
	$(RM) -rf src/*.ml .deps/*

mrproper:
	$(RM) -rf src/*.ml .deps

.PHONY: all main clean mrproper

###########################################################

$(ENTITY_OBJS) src/utils.ml: src/%.ml: src/%.mlp .FORCE
	./mlcpp.sh -o $@ $< $(CPPFLAGS)

###########################################################

.FORCE: ;

## shall not rely on these ##
# .DELETE_ON_ERROR:
.SUFFIXES:
