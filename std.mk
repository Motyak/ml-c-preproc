SHELL := /bin/bash
RM := rm -f
CPPFLAGS := -I .
MAKEFLAGS += -j16

###########################################################

MODULES := \
std/cond \
std/loops \
\
std/Pair \
std/Optional \
std/Stream \
\
std/Iterator \
std/functional \
std/op \
\
std \

MODULES_OBJS := $(MODULES:%=%.ml)

###########################################################

all: main

main: $(MODULES_OBJS)

clean:
	$(RM) std/*.ml std.ml

.PHONY: all main clean

###########################################################

$(MODULES_OBJS): %.ml: %.mlp .FORCE
	./mlcpp.sh -o $@ $< $(CPPFLAGS)

###########################################################

.FORCE: ;

## shall not rely on these ##
# .DELETE_ON_ERROR:
.SUFFIXES:
