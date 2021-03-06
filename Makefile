os = $(shell uname -s)

#INCFLAGS      = -I$(ROOTSYS)/include -I$(FASTJETDIR)/include -I$(STARPICOPATH)
INCFLAGS      = -I$(ROOTSYS)/include -I$(FASTJETDIR)/include -I$(STARPICODIR) -I/opt/local/include

ifeq ($(os),Linux)
CXXFLAGS      = 
else
CXXFLAGS      = -O -fPIC -pipe -Wall -Wno-deprecated-writable-strings -Wno-unused-variable -Wno-unused-private-field -Wno-gnu-static-float-init -std=c++11
## for debugging:
# CXXFLAGS      = -g -O0 -fPIC -pipe -Wall -Wno-deprecated-writable-strings -Wno-unused-variable -Wno-unused-private-field -Wno-gnu-static-float-init
endif

ifeq ($(os),Linux)
LDFLAGS       = -g
LDFLAGSS      = -g --shared 
else
LDFLAGS       = -O -Xlinker -bind_at_load -flat_namespace
LDFLAGSS      = -flat_namespace -undefined suppress
LDFLAGSSS     = -bundle
endif

ifeq ($(os),Linux)
CXX          = g++ 
else
CXX          = clang
endif


ROOTLIBS      = $(shell root-config --libs)

LIBPATH       = $(ROOTLIBS) -L$(FASTJETDIR)/lib -L$(STARPICODIR)
LIBS          = -lfastjet -lfastjettools -lTStarJetPico


# for cleanup
SDIR          = src
ODIR          = src/obj
BDIR          = bin


###############################################################################
################### Remake when these headers are touched #####################
###############################################################################


###############################################################################
# standard rules
$(ODIR)/%.o : $(SDIR)/%.cxx $(INCS)
	@echo 
	@echo COMPILING
	$(CXX) $(CXXFLAGS) $(INCFLAGS) -c $< -o $@

$(BDIR)/%  : $(ODIR)/%.o 
	@echo 
	@echo LINKING
	$(CXX) $(LDFLAGS) $(LIBPATH) $(LIBS) $^ -o $@

###############################################################################

###############################################################################
############################# Main Targets ####################################
###############################################################################
all : $(BDIR)/geant_pp_correlation $(BDIR)/star_pp_correlation $(BDIR)/pythia_pp_correlation

$(SDIR)/dict.cxx                : $(SDIR)/ktTrackEff.hh
	cd ${SDIR}; rootcint -f dict.cxx -c -I. ./ktTrackEff.hh

$(ODIR)/dict.o                  : $(SDIR)/dict.cxx
$(ODIR)/ktTrackEff.o            : $(SDIR)/ktTrackEff.cxx $(SDIR)/ktTrackEff.hh
$(ODIR)/corrFunctions.o		: $(SDIR)/corrFunctions.cxx $(SDIR)/corrFunctions.hh

#$(ODIR)/qa_v1.o 		: $(SDIR)/qa_v1.cxx
$(ODIR)/test.o			: $(SDIR)/test.cxx
$(ODIR)/auau_correlation.o	: $(SDIR)/auau_correlation.cxx
$(ODIR)/pp_correlation.o	: $(SDIR)/pp_correlation.cxx
$(ODIR)/geant_pp_correlation.o	: $(SDIR)/geant_pp_correlation.cxx
$(ODIR)/star_pp_correlation.o	: $(SDIR)/star_pp_correlation.cxx
$(ODIR)/pythia_pp_correlation.o	: $(SDIR)/pythia_pp_correlation.cxx
$(ODIR)/event_mixing.o       : $(SDIR)/event_mixing.cxx
$(ODIR)/generate_output.o   : $(SDIR)/generate_output.cxx

#data analysis
#$(BDIR)/qa_v1		: $(ODIR)/qa_v1.o
$(BDIR)/test			: $(ODIR)/test.o $(ODIR)/corrFunctions.o
$(BDIR)/auau_correlation		: $(ODIR)/auau_correlation.o $(ODIR)/corrFunctions.o $(ODIR)/ktTrackEff.o $(ODIR)/dict.o
$(BDIR)/pp_correlation			: $(ODIR)/pp_correlation.o	$(ODIR)/corrFunctions.o $(ODIR)/ktTrackEff.o $(ODIR)/dict.o
$(BDIR)/geant_pp_correlation		: $(ODIR)/geant_pp_correlation.o	$(ODIR)/corrFunctions.o $(ODIR)/ktTrackEff.o $(ODIR)/dict.o
$(BDIR)/star_pp_correlation		: $(ODIR)/star_pp_correlation.o	$(ODIR)/corrFunctions.o $(ODIR)/ktTrackEff.o $(ODIR)/dict.o
$(BDIR)/pythia_pp_correlation		: $(ODIR)/pythia_pp_correlation.o	$(ODIR)/corrFunctions.o $(ODIR)/ktTrackEff.o $(ODIR)/dict.o
$(BDIR)/event_mixing        	: $(ODIR)/event_mixing.o  $(ODIR)/corrFunctions.o  $(ODIR)/ktTrackEff.o  $(ODIR)/dict.o
$(BDIR)/generate_output     : $(ODIR)/generate_output.o $(ODIR)/corrFunctions.o

###############################################################################
##################################### MISC ####################################
###############################################################################

clean :
	@echo 
	@echo CLEANING
	rm -vf $(ODIR)/*.o
	rm -vf $(BDIR)/*
	rm -vf lib/*


