SHELL := /bin/bash
RM := rm -f
CPPFLAGS := -I .
MAKEFLAGS += -j16

###########################################################

MODULES := \
std/fn/tern \
std/fn/loops \
\
std/fn/Pair \
std/fn/Optional \
std/fn/LazyList \
std/fn/ArgIterator \
\
std/op/cmp \
std/op/sub \
std/op/in \
std/op/pipe \
\
std/fn/curry \
std/fn/delay \
\
std/fn/ascii \
std/fn/ByteStr \
\
std/* \

MODULES_OBJS := $(MODULES:%=%.ml)

###########################################################

all: main

main: $(MODULES_OBJS)

clean:
	$(RM) {std,std/op,std/fn}/*.ml

.PHONY: all main clean

###########################################################

$(MODULES_OBJS): %.ml: %.mlp .FORCE
	./mlcpp.sh -o $@ $< $(CPPFLAGS)

###########################################################

.FORCE: ;

## shall not rely on these ##
# .DELETE_ON_ERROR:
.SUFFIXES:
