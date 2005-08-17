
all: 
	make -C dok/1g
	make -C kredit/1g
	make -C main/1g
	make -C main/2g
	make -C db/1g
	make -C db/2g
	make -C rpt/1g
	make -C sif/1g
	make -C param/1g
	make -C ut/1g
	make -C 1g
	
clean:	
	cd dok/1g; make clean
	cd kredit/1g; make clean
	cd main/1g; make clean
	cd main/2g; make clean
	cd db/1g; make clean
	cd db/2g; make clean
	cd rpt/1g; make clean
	cd sif/1g; make clean
	cd param/1g; make clean
	cd ut/1g; make clean
	make -C 1g  clean

zip:
	cd 1g; make zip

commit:
	cd 1g; make commit

