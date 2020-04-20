#!/usr/bin/make

.PHONY: all remake clean info

MKF_NAME := $(firstword $(MAKEFILE_LIST))
MKF_BASED_NAME := $(MKF_NAME:%.mkf=%)

ifeq ($(MKF_BASED_NAME),Makefile)
	BINARYNAME   := helloworld
else
	BINARYNAME   := $(MKF_BASED_NAME)
endif

# --------------- no edit below please -------------

ifeq ($(OS),Windows_NT)
	BINARYNAME := $(join $(BINARYNAME),.exe)
else
	BINARYNAME := $(join $(BINARYNAME),_ex)
endif

#BINARYSRC:= helloworld.cpp helppage.c
BINARYSRC := $(wildcard *.c) $(wildcard *.cpp) $(wildcard *.cxx) $(wildcard *.c++) $(wildcard *.cc) $(wildcard *.C)
HEADERS   := $(wildcard *.h) $(wildcard *.hpp) $(wildcard *.hxx) $(wildcard *.h++) $(wildcard *.hh) $(wildcard *.H)
INC_PATHS ?= .
LIB_PATHS ?= .
LIB_NAMES :=
CPPFLAGS  ?= -D DUMMY=1
CFLAGS    ?= -Os      # this is contradictionary, but ...
CXXFLAGS  ?= -ggdb3   # ... still just a demo.

BINARYOBJS:=$(BINARYSRC:.c=.o)
BINARYOBJS:=$(BINARYOBJS:.cpp=.o)
BINARYOBJS:=$(BINARYOBJS:.cxx=.o)
BINARYOBJS:=$(BINARYOBJS:.c++=.o)
BINARYOBJS:=$(BINARYOBJS:.cc=.o)
BINARYOBJS:=$(BINARYOBJS:.C=.o)

# --- auto assigning inc/lib paths (space separated) to appropriate list of -I/-L/-l directives
INCSEARCH      := $(foreach d, $(INC_PATHS), -I$d)
LIB_SHORTNAMES := $(LIB_NAMES:lib%=%)  # cut away the prefix 'lib' from 'libsample.a' -> 'sample.a'
LIB_LINK       := $(foreach d, $(LIB_SHORTNAMES:.a=), -l$d) # cut away the suffix '.a' from 'sample.a' -> 'sample' and prefix '-l' -> '-lsample'


$(BINARYNAME): $(BINARYOBJS)
	@echo "linking $^ (and $(strip $(LIB_LINK))) to $@   by invoking:"
	$(CXX) $(CXXFLAGS) $^ $(LDFLAGS) $(LIBSEARCH) $(LIB_LINK) -o $@

%.o: %.c
	@echo "C-compiling $< to $@   by invoking:"
	$(CXX) $(CFLAGS) -o $@ $(INCSEARCH) -x c -c $<

%.o: %.cpp
	@echo "C++ compiling $< to $@   by invoking:"
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -o $@ $(INCSEARCH) -c $< 


all: $(BINARYNAME)

remake: clean all

clean:
	rm -f $(BINARYNAME) $(BINARYOBJS)

info:
	@echo "compiling all $(BINARYSRC) + $(HEADERS) from current directory and linking to $(BINARYNAME)"
