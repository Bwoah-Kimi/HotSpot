#
# Thanks to Greg Link from Penn State University
# for his math acceleration engine.
#

# Uncomment the following math acceleration flags
# relevant to your target and set the appropriate
# path and flag options

#SUPERLU: [0-1]
ifndef SUPERLU
SUPERLU = 0
endif

ifeq ($(SUPERLU), 1)
#SuperLUroot	= /usr/lib/x86_64-linux-gnu
BLASLIB    	= -lblas
SUPERLULIB 	= -lsuperlu
SLU_HEADER  = /usr/include/superlu/

MATHACCEL	= none
INCDIR		= $(SLU_HEADER)
LIBDIR		=
LIBS  		= -lm $(BLASLIB) $(SUPERLULIB)
EXTRAFLAGS	=
else
# default - no math acceleration
MATHACCEL	= none
INCDIR		=
LIBDIR		=
LIBS		= -lm
EXTRAFLAGS	=
endif

# Intel Machines - acceleration with the Intel
# Math Kernel Library (MKL)
#MATHACCEL	= intel
#INCDIR		= /bigdisk/ks4kk/mkl/10.1.0.015/include
#LIBDIR		= /bigdisk/ks4kk/mkl/10.1.0.015/lib/em64t
#LIBS		= -lmkl_lapack -lmkl -lguide -lm -lpthread
#EXTRAFLAGS	=

# AMD Machines - acceleration with the AMD
# Core Math Library (ACML)
#MATHACCEL	= amd
#INCDIR		= /uf1/ks4kk/lib/acml3.6.0/gfortran32/include
#LIBDIR		= /uf1/ks4kk/lib/acml3.6.0/gfortran32/lib
#LIBS		= -lacml -lgfortran -lm
#EXTRAFLAGS	=

# Apple Machines - acceleration with the Apple
# Velocity Engine (AltiVec)
#MATHACCEL	= apple
#INCDIR		=
#LIBDIR		=
#LIBS		= -framework vecLib -lm
#EXTRAFLAGS	=

# Sun Machines - acceleration with the SUN
# performance library (sunperf)
#MATHACCEL	= sun
#INCDIR		=
#LIBDIR		=
#LIBS		= -library=sunperf
#EXTRAFLAGS	= -dalign

# basic compiler flags - special case for sun
ifeq ($(MATHACCEL), sun)
CC 			= CC
ifeq ($(DEBUG), 1)
OFLAGS		= -g -erroff=badargtypel2w
else
ifeq ($(DEBUG), 2)
OFLAGS		= -xpg -g -erroff=badargtypel2w
else
OFLAGS		= -xO4 -erroff=badargtypel2w
endif	# DEBUG = 2
endif	# DEBUG = 1
else	# MATHACCEL != sun
CC 			= gcc
ifeq ($(DEBUG), 1)
OFLAGS		= -O0 -ggdb -Wall
else
ifeq ($(DEBUG), 2)
OFLAGS		= -O3 -pg -ggdb -Wall
else
OFLAGS		= -O3
endif	# DEBUG = 2
endif	# DEBUG = 1
endif	# end MATHACCEL
RM			= rm -f
AR			= ar qcv
RANLIB		= ranlib
OEXT		= o
LEXT		= a
# Verbosity level [0-3]
ifndef VERBOSE
VERBOSE	= 1
endif

# Numerical ID for each acceleration engine
ifeq ($(MATHACCEL), none)
ACCELNUM = 0
endif
ifeq ($(MATHACCEL), intel)
ACCELNUM = 1
endif
ifeq ($(MATHACCEL), amd)
ACCELNUM = 2
endif
ifeq ($(MATHACCEL), apple)
ACCELNUM = 3
endif
ifeq ($(MATHACCEL), sun)
ACCELNUM = 4
endif

ifdef INCDIR
INCDIRFLAG = -I$(INCDIR)
endif

ifdef LIBDIR
LIBDIRFLAG = -L$(LIBDIR)
endif

SRC_DIR := src
OBJ_DIR := obj
BIN_DIR := bin
INCLUDE_DIR := include

CFLAGS	= $(OFLAGS) $(EXTRAFLAGS) $(INCDIRFLAG) $(LIBDIRFLAG) -I$(INCLUDE_DIR) -DVERBOSE=$(VERBOSE) -DMATHACCEL=$(ACCELNUM) -DSUPERLU=$(SUPERLU)

# sources, objects, headers and inputs


# Microchannel Files
UCHANSRC = $(SRC_DIR)/microchannel.c
UCHANOBJ = $(OBJ_DIR)/microchannel.$(OEXT)
UCHANHDR = $(INCLUDE_DIR)/microchannel.h
UCHANIN = example.microchannel_config

# Materials Files
MSRC = $(SRC_DIR)/materials.c
MOBJ = $(OBJ_DIR)/materials.$(OEXT)
MHDR = $(INCLUDE_DIR)/materials.h
MIN = test.materials

# HotFloorplan
FLPSRC	= $(SRC_DIR)/flp.c $(SRC_DIR)/flp_desc.c $(SRC_DIR)/npe.c $(SRC_DIR)/shape.c
FLPOBJ	= $(OBJ_DIR)/flp.$(OEXT) $(OBJ_DIR)/flp_desc.$(OEXT) $(OBJ_DIR)/npe.$(OEXT) $(OBJ_DIR)/shape.$(OEXT)
FLPHDR	= $(INCLUDE_DIR)/flp.h $(INCLUDE_DIR)/npe.h $(INCLUDE_DIR)/shape.h
FLPIN = ev6.desc avg.p

# HotSpot
TEMPSRC	= $(SRC_DIR)/temperature.c $(SRC_DIR)/RCutil.c
TEMPOBJ	= $(OBJ_DIR)/temperature.$(OEXT) $(OBJ_DIR)/RCutil.$(OEXT)
TEMPHDR = $(INCLUDE_DIR)/temperature.h
TEMPIN	=

#	Package model
PACKSRC	=	$(SRC_DIR)/package.c
PACKOBJ	=	$(OBJ_DIR)/package.$(OEXT)
PACKHDR	=	$(INCLUDE_DIR)/package.h
PACKIN	=	package.config

# HotSpot block model
BLKSRC = $(SRC_DIR)/temperature_block.c
BLKOBJ = $(OBJ_DIR)/temperature_block.$(OEXT)
BLKHDR	= $(INCLUDE_DIR)/temperature_block.h
BLKIN	= ev6.flp gcc.ptrace

# HotSpot grid model
GRIDSRC = $(SRC_DIR)/temperature_grid.c
GRIDOBJ = $(OBJ_DIR)/temperature_grid.$(OEXT)
GRIDHDR	= $(INCLUDE_DIR)/temperature_grid.h
GRIDIN	= layer.lcf example.lcf example.flp example.ptrace

# Miscellaneous
MISCSRC = $(SRC_DIR)/util.c $(SRC_DIR)/wire.c
MISCOBJ = $(OBJ_DIR)/util.$(OEXT) $(OBJ_DIR)/wire.$(OEXT)
MISCHDR = $(INCLUDE_DIR)/util.h $(INCLUDE_DIR)/wire.h
MISCIN	= hotspot.config

# all objects
OBJ	= $(UCHANOBJ) $(MOBJ) $(TEMPOBJ) $(PACKOBJ) $(BLKOBJ) $(GRIDOBJ) $(FLPOBJ) $(MISCOBJ)

# targets
all:	hotspot hotfloorplan lib

hotspot:	$(OBJ_DIR)/hotspot.$(OEXT) $(OBJ)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) -o $(BIN_DIR)/hotspot $(OBJ_DIR)/hotspot.$(OEXT) $(OBJ) $(LIBS)

ifdef LIBDIR
		@echo
		@echo
		@echo "...Done. Do not forget to include $(LIBDIR) in your LD_LIBRARY_PATH"
endif

hotfloorplan:	$(OBJ_DIR)/hotfloorplan.$(OEXT) $(OBJ)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) -o $(BIN_DIR)/hotfloorplan $(OBJ_DIR)/hotfloorplan.$(OEXT) $(OBJ) $(LIBS)
ifdef LIBDIR
		@echo
		@echo
		@echo "...Done. Do not forget to include $(LIBDIR) in your LD_LIBRARY_PATH"
endif

lib: 	hotspot hotfloorplan
	$(RM) $(OBJ_DIR)/libhotspot.$(LEXT)
	$(AR) $(OBJ_DIR)/libhotspot.$(LEXT) $(OBJ)
	$(RANLIB) $(OBJ_DIR)/libhotspot.$(LEXT)

#pull in dependency info for existing .o files
-include $(OBJ:.o=.d)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

.c.$(OEXT):
	$(CC) $(CFLAGS) -c $*.c
	$(CC) -MM $(CFLAGS) $*.c > $*.d

.cpp.$(OEXT):
	$(CC) $(CFLAGS) -c $*.cpp

filelist:
	@echo $(FLPSRC) $(TEMPSRC) $(PACKSRC) $(BLKSRC) $(GRIDSRC) $(MISCSRC) \
		  $(FLPHDR) $(TEMPHDR) $(PACKHDR) $(BLKHDR) $(GRIDHDR) $(MISCHDR) \
		  $(FLPIN) $(TEMPIN) $(PACKIN) $(BLKIN) $(GRIDIN) $(MISCIN) \
		  $(INCLUDE_DIR)/hotspot.h $(SRC_DIR)/hotspot.c $(INCLUDE_DIR)/hotfloorplan.h $(SRC_DIR)/hotfloorplan.c \
		  $(SRC_DIR)/sim-template_block.c \
		  tofig.pl grid_thermal_map.pl \
		  Makefile
clean:
	$(RM) -r $(OBJ_DIR) $(BIN_DIR) *.$(OEXT) *.obj *.d  core *~ Makefile.bak 

cleano:
	$(RM) -r $(OBJ_DIR) *.$(OEXT) *.obj
