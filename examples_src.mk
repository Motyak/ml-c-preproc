SHELL := /bin/bash
RM := rm -f
CPPFLAGS := -I examples/src

###########################################################

MODULES := \
utils \
Pair \
Optional \
List \
ListIterator \
Queue \
Stream \
myprog \
myprog2 \
myprog3 \

MODULES_OBJS := $(MODULES:%=examples/src/%.ml)

###########################################################

all: main

main: $(MODULES_OBJS)

clean:
	$(RM) examples/src/*.ml

.PHONY: all main clean

###########################################################

$(MODULES_OBJS): examples/src/%.ml: examples/src/%.mlp .FORCE
	./mlcpp.sh -o $@ $< $(CPPFLAGS)

###########################################################

.FORCE: ;

## shall not rely on these ##
# .DELETE_ON_ERROR:
.SUFFIXES:
