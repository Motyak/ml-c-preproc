SHELL := /bin/bash
RM := rm -f
CPPFLAGS := -I .

###########################################################

MODULES := \
std/fn/tern \
std/op/pipe \
std/fn/delay \
std/op/comp \
std/op/sub \
std/fn/loops \
std/op/in \
std/fn/-len \
std/fn/curry \
std/fn/ascii \
std/fn/ByteStr \
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
