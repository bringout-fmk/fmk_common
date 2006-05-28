liball:
	make -C svi
	make -C roba
	make -C event
	make -C security
	make -C pi
	make -C ugov
	make -C partnst
	make -C rabat/1g
	make -C rn
	make -C exp_dbf
	make -C lokal
	make -C message


cleanall:
	cd svi; make clean
	cd roba; make clean
	cd event; make clean
	cd security; make clean
	cd ugov; make clean
	cd partnst; make clean
	cd rabat/1g; make clean
	cd rn; make clean
	cd exp_dbf; make clean
	cd lokal; make clean
	cd message; make clean
	rm -f *.obj

fmk: cleanall liball 

