#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_KAM_VERZIJA "02.03"
#define D_KAM_PERIOD '06.96-12.12.06'

#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif

#xcommand O_PRIPR  =>   SELECT (F_KAMPRIPR) ; usex (PRIVPATH+"pripr") ; set order to 1
#xcommand O_KAMAT  =>   SELECT (F_KAMAT) ; usex (KUMPATH+"KAMAT") ; set order to 1

#xcommand O_KS   => select (F_KS); use  (SIFPATH+"KS") ; set order to tag "ID"
#xcommand O_KS2   => select (F_KS2); use  (SIFPATH+"KS2"); set order to tag "ID"

#xcommand O_KONTO    => select (F_KONTO);  use (SIFPATH+"KONTO"); set order to tag "ID"
#xcommand O_PARTN    => select (F_PARTN);  use (SIFPATH+"PARTN"); set order to tag "ID"

#xcommand FO_SUBAN   => select (F_SUBAN);  use  (gDirFin+"SUBAN") alias fsuban; set order to tag "1"

