
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

