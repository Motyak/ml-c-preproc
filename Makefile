# shell_onrun: same as $(shell) but doesn't evaluate during make autocompletion
# $(1): code to evaluate
# returns: evaluated code on run, the empty str otherwise
define shell_onrun
$(if $(filter .DEFAULT,$(MAKECMDGOALS)),,$(shell $(1)))
endef

SHELL := /bin/bash
RM := rm -rf
CPPFLAGS := -I src
DEPFLAGS = -MMD -MP -MF .deps/$*.d

###########################################################

ENTITIES := \
ListIterator \
List \
Optional \
Pair \

ENTITY_OBJS := $(ENTITIES:%=src/%.ml)
ENTITY_DEPS := $(ENTITIES:%=.deps/%.d)

###########################################################

all: main

main: $(ENTITY_OBJS)

clean:
	$(RM) -rf src/*.ml .deps/*

mrproper:
	$(RM) -rf src/*.ml .deps

.PHONY: all main clean mrproper

###########################################################

$(ENTITY_OBJS) src/utils.ml: src/%.ml: src/%.mlp
	./mlcpp.sh -o $@ $< $(CPPFLAGS) $(DEPFLAGS) \
	&& perl -pe 's|^.*?:|$@:| if $$. == 1' -i .deps/$*.d

-include $(ENTITY_DEPS) .deps/utils.d

###########################################################

# will create all necessary directories after the Makefile is parsed
$(call shell_onrun, mkdir -p .deps)

## shall not rely on these ##
# .DELETE_ON_ERROR:
.SUFFIXES:
