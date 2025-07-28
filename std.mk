SHELL := /bin/bash
RM := rm -f
CPPFLAGS := -I .
MAKEFLAGS += -j16

###########################################################

MODULES := \
std/fn/tern \
std/op/pipe \
std/fn/delay \
\
std/fn/curry \
std/fn/loops \
std/fn/ascii \
std/fn/ByteStr \
std/fn/Pair \
std/fn/Optional \
\
std/fn/Stream \
\
std/op/range \
std/fn/functional \
std/fn/Iterator \
\
std/op/in \
std/op/cmp \
std/op/sub \
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
