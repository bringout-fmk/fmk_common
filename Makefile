<<<<<<< HEAD:Makefile
DIRS = fmk_roba fmk_svi fmk_exp_dbf fmk_racuni fmk_lokalizacija  fmk_rabat  fmk_rules  fmk_ugov


all: compile install

compile:
	for d in $(DIRS); do \
	 make -C $$d; \
	done

install:
	../fmk_lib/scripts/cp_fmk_libs_to_hb_lib.sh

clean:
	for d in $(DIRS); do \
	 make -C $$d clean; \
	done
copy4debug:
	for d in $(DIRS); do \
	 cp -v $$d/*.prg /c/sigma; \
	done
=======
<<<<<<< HEAD:Makefile
liball:
	make -C svi
	make -C roba
	make -C event
	make -C security
	make -C rules
	make -C pi
	make -C ugov
	make -C partnst
	make -C rabat/1g
	make -C rn
	make -C exp_dbf
	make -C lokal
	make -C message
	make -C fiscal


cleanall:
	cd svi; make clean
	cd roba; make clean
	cd event; make clean
	cd security; make clean
	cd rules; make clean
	cd ugov; make clean
	cd partnst; make clean
	cd rabat/1g; make clean
	cd rn; make clean
	cd exp_dbf; make clean
	cd lokal; make clean
	cd message; make clean
	cd fiscal; make clean
	rm -f *.obj

fmk: cleanall liball 
=======

liball: 
	make -C dok/1g
	make -C kredit/1g
	make -C korek/1g
	make -C main/2g
	make -C db/1g
	make -C db/2g
	make -C rpt/1g
	make -C sif/1g
	make -C param/1g
	make -C ut/1g
	make -C porkart
	make -C ahon
	make -C por
	make -C 1g exe
	
cleanall:	
	make -C dok/1g clean
	make -C kredit/1g clean
	make -C main/2g clean
	make -C db/1g clean
	make -C db/2g clean
	make -C rpt/1g clean
	make -C sif/1g clean
	make -C param/1g clean
	make -C ut/1g clean
	make -C ahon clean
	make -C porkart clean
	make -C por clean
	make -C 1g clean

ld:   cleanall  liball
>>>>>>> gitweb/clipper:Makefile

>>>>>>> clipper:Makefile
