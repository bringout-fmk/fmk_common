DIRS = fmk_roba fmk_exp_dbf fmk_racuni fmk_lokalizacija  fmk_rabat  fmk_rules  fmk_ugov


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
