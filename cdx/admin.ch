#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_ADMIN_VERZIJA "02.15"
#define D_ADMIN_PERIOD '06.96-17.01.11'

#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif


#define I_ID 1
#define DE_ADD  5
#define DE_DEL  6
#define F_KKONTO    9
#define F_KROBA    10
#define F_K2ROBA   13
#define F_KPARTN   14
#define F_IMP_PARM 15
#define F__TMP	   16

#xcommand OX_KONTO => select (F_KONTO);  usex (SIFPATH+"KONTO");  set order to tag "ID"
#xcommand OX_ROBA => select (F_ROBA);  usex (SIFPATH+"ROBA")    ; set order to tag "ID"
#xcommand O_KKONTO => select (F_KKONTO);  use (SIFPATH+"KKONTO"); set order to tag "ID"
#xcommand O_KROBA => select (F_KROBA);  use (SIFPATH+"KROBA") ; set order to tag "ID"
#xcommand O_K2ROBA => select (F_K2ROBA); use (SIFPATH+"K2ROBA"); set order to tag "ID"
#xcommand O_KPARTN => select (F_KPARTN); use (SIFPATH+"KPARTN"); set order to tag "ID"
#xcommand O_IMP_PARM => select (F_IMP_PARM); use (SIFPATH+"IMP_PARM"); set order to tag "1"
#xcommand O__TMP => select (F__TMP); use (PRIVPATH+"_TMP")

