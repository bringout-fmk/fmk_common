
include /sclib/Makefile_clipper

PREF2=/clip/
SVI1A=$(addprefix $(PREF2), $(FMKLIBS) )


LIB=libsclib.a
SLIB=libsclib.dll.a

all:
	make -C svi
	make -C roba
	make -C event
	make -C security
	make -C pi
	make -C ugov
	make -C partnst


clean:
	cd svi; make clean
	cd roba; make clean
	cd event; make clean
	cd security; make clean
	cd ugov; make clean
	cd partnst; make clean
	rm -f *.obj


