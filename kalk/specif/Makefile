VERZIJA=CDX


LIBEXE=/cygdrive/p/l/lib.exe
CLIPPERCOMP=/cl/SC_CLIB/clip52.sh
CLIPPERFLAGS0=/n /DEXT /D$(VERZIJA) /DC52 /u$(VERZIJA)\\STD.CH
CLIPPERROOT=/CLIPPER
LINKEREXE=/cl/SC_CLIB/blink.sh
ASMCOMP=./ASM52.bat
ASMFLAGS=
EXEDEST=/cygdrive/c/SIGMA

CFLAGS=/n /w /c /AL /FPa /Gs /Zl

SRCDOSROOT=C:\\CL\\KALK\\SPECIF\\
	
ROBODOC=robodoc

ifndef $(MODUL)
  MODUL=SPECIF
endif
MODULH=SPECIF


ifndef DEBUG
	DEBUG=0
	#echo "Definisem debug"
endif  

ifeq "${DEBUG}" "1"
	CLIPPERFLAGS=$(CLIPPERFLAGS0) /b /DPROBA 
	DEBUGLINK=file p:\\CLIPPER\\LIB\\CLD.LIB
	DEBUGDIR=\\DEBUG
else
	CLIPPERFLAGS=$(CLIPPERFLAGS0)
	DEBUGLINK=
	DEBUGDIR=
endif


ifeq "${VERZIJA}" "CDX"
	CCOMP=/cl/elib/c52.bat 
else
	F1 = /y
endif

#INCLUDE="p:\\clp52\\include\;p:\\comix\;p:\\l\\c5\\INCLUDE"
#export INCLUDE

PRGS=JERRY.PRG PLANIKA.PRG TVIN.PRG 

CS=
ASMS=


OBJPRGS=$(PRGS:.PRG=.OBJ)
OBJCS=$(CS:.C=.OBJ)
OBJASMS=$(ASMS:.ASM=.OBJ)

PREF=+
LIBCMD=$(addprefix $(PREF), $(OBJPRGS) $(OBJASMS) $(OBJCS) )

#napravi dokumente

DOCS=$(PRGS:.PRG=.html)
XREFS=$(DOCS:.html=.xref)

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

.SUFFIXES: .ASM .OBJ
.SUFFIXES: .C .OBJ	
.SUFFIXES: .PRG .OBJ

all: mod 
mod: $(OBJS)
	rm $(MODUL).lib
	$(LIBEXE) $(MODUL).lib $(LIBCMD) ,,

clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f xref_files
	rm -f $(OBJS) I$(MODULH).OBJ *.bak *.BAK

.PRG.OBJ: 
	$(CLIPPERCOMP) $(SRCDOSROOT)$< $(CLIPPERFLAGS) 
	
.PRG.PPO: 
	$(CLIPPERCOMP) /p $(CLIPPERFLAGS) $<

.ASM.OBJ:
	$(ASMCOMP) $(ASMFLAGS) $< 

.C.OBJ:
	$(CCOMP) $(CFLAGS) $<


#
# create xrefs file (file with the names of all .xref files).
#
SC_CLIB.xrefs : $(XREFS) $(SOURCES)
	/bin/ls *.xref > $@

%.xref: %  
	$(ROBODOC) $< $(@:.xref=.html) INTERNAL -g $@ -v


index.html : SC_CLIB.xrefs $(DOCS)
	$(ROBODOC) $< $@ INDEX HTML

%.html: %
	 $(ROBODOC) $< $@ HTML INTERNAL -x SC_CLIB.xrefs -v


#include makefile_doc
