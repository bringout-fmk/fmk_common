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

SRCDOSROOT=h:\\CL\\FMK\\KALK\\MAG\\
	
ROBODOC=robodoc

ifndef $(MODUL)
  MODUL=MAG
endif
MODULH=MAG

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


PRGS=ED_10.PRG ED_14.PRG ED_16.PRG ED_18.PRG ED_82.PRG ED_94.PRG ED_95.PRG ED_IM.PRG IZVJ.PRG NIVEL.PRG RPT_10.PRG RPT_10NC.PRG RPT_10SK.PRG RPT_14.PRG RPT_18.PRG RPT_82.PRG RPT_95NV.PRG RPT_95SK.PRG RPT_FLLM.PRG RPT_IM.PRG RPT_KMAG.PRG RPT_LLM.PRG RPT_RFLM.PRG RPT_RUC.PRG VI_KMAG.PRG RPT_REAP.PRG GEN_DOK.PRG VI_KART.PRG KALK_UT.PRG RPT_RDOB.PRG FAK_KAL.PRG KONSIG.PRG ADM_KALK.PRG


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

SOURCES=$(PRGS)

.SUFFIXES: .ASM .OBJ
.SUFFIXES: .C .OBJ	
.SUFFIXES: .PRG .OBJ

PREFDIR=$(MODUL)/
DIR_PRGS=$(addprefix $(PREFDIR), $(PRGS))

all: mod 
mod: $(OBJS)
	echo "MAG_SOURCES=\\" > makefile_doc
	/cl/SC_CLIB/form_makefile_doc.sh $(DIR_PRGS)
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

#########################################################################

ROBODOC=robodoc
ROBOOPTS=C SORT 

PROJECT=MAG

# Your source files.
#

# The various documentation files, derived from the source files.
# HTML
#
HTMLDOCS=$(SOURCES:=.html)
HTMLXREFS=$(HTMLDOCS:.html=.xref)
HTMLXREFSFILE=$(PROJECT).xrefs

# Some common targets
xrefall: xhtml 
docs: html 

# Create the xref files for the various formats.
xhtml: $(HTMLXREFSFILE) 

# Create the documentation files for the various formats.
html: $(PROJECT)_mi.html $(HTMLDOCS) 

# master index file, currently works only for html and latex documentation.
$(PROJECT)_mi.html: $(HTMLXREFSFILE) 
	$(ROBODOC) $< $@ INDEX HTML TITLE "$(PROJECT) Glavni indeks"


# create xrefs file (file with the names of all .xref files).
$(HTMLXREFSFILE) :  $(HTMLXREFS)
	/bin/ls $(HTMLXREFS) > $(PROJECT).xrefs

# Rule to create an .xref file from a source file for the various formats.
%.xref : %
	$(ROBODOC) $<  $(@:.xref=.html) GENXREF $@ HTML INTERNAL

# Rule to create html documentation from a source file.
%.html : % $(SOURCES)
	$(ROBODOC) $< $@ HTML $(ROBOOPTS) XREF $(HTMLXREFSFILE)

# Rule to create latex documentation from a source file.
# We do not include source items, and generate laxtex documents
# than can be included in a master document.

# Use netscape to view the master index file for our project.
htmlview: html
	start $(PROJECT)_mi.html

# Clean-up the mess we made
#
cleandocs:
	rm -f $(HTMLXREFS) 
	rm -f $(HTMLDOCS) 
	rm -f $(HTMLXREFSFILE) 

