SHELL := /bin/bash
RM := rm -f
CPPFLAGS := -I src

###########################################################

MODULES := \
utils \
Pair \
Optional \
List \
ListIterator \
myprog \

MODULES_OBJS := $(MODULES:%=src/%.ml)

###########################################################

all: main

main: $(MODULES_OBJS)

clean:
	$(RM) src/*.ml

.PHONY: all main clean

###########################################################

$(MODULES_OBJS): src/%.ml: src/%.mlp .FORCE
	./mlcpp.sh -o $@ $< $(CPPFLAGS)

###########################################################

.FORCE: ;

## shall not rely on these ##
# .DELETE_ON_ERROR:
.SUFFIXES:
