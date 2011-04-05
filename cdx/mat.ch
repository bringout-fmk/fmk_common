#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_MAT_VERZIJA "02.00"
#define D_MAT_PERIOD '11.94-24.02.11'

#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif

#xcommand O_PRIPR    =>  select(F_PRIPR   ); usex (PRIVPATH+"PRIPR") ; set order to tag "1"
#xcommand O_PRIPRRP  =>  select (F_PRIPRRP); usex (strtran(cDirPriv,gSezonDir,"\")+"PRIPR") alias priprrp; set order to 1

#xcommand O_SUBAN    =>  select(F_SUBAN); use (KUMPATH+"SUBAN"); set order to tag "1"
#xcommand O_SUBANX   =>  select(F_SUBAN);usex (KUMPATH+"SUBAN"); set order to tag "1"
#xcommand O_SUBAN2   =>  select(F_SUBAN);use (KUMPATH+"SUBAN") alias pripr; set order to tag "4"
#xcommand O_ANAL     =>  select(F_ANAL );use (KUMPATH+"ANAL"); set order to tag "1"
#xcommand O_SINT     =>  select(F_SINT );use (KUMPATH+"SINT"); set order to tag "1"
#xcommand O_NALOG    =>  select(F_NALOG);use (KUMPATH+"NALOG"); set order to tag "1"
#xcommand O_IZDEF    =>  select(F_IZDEF);use (KUMPATH+"IZDEF"); set order to tag "1"
#xcommand O_IZOP     =>  select(F_IZOP );use (KUMPATH+"IZOP"); set order to tag "1"

#xcommand O_PNALOG   => select(F_PNALOG );usex (PRIVPATH+"PNALOG"); set order to tag "1"
#xcommand O_PSUBAN   => select(F_PSUBAN );usex (PRIVPATH+"PSUBAN"); set order to tag "1"
#xcommand O_PSUBAN2  => select(F_PSUBAN );usex (PRIVPATH+"PSUBAN") alias SUBAN; set order to tag "1"
#xcommand O_PANAL    => select(F_PANAL ) ;usex (PRIVPATH+"PANAL") ; set order to tag "1"
#xcommand O_PANAL2   => select(F_PANAL ) ;usex (PRIVPATH+"PANAL") alias ANAL; set order to tag "1"
#xcommand O_PSINT    => select(F_PSINT ) ;usex (PRIVPATH+"PSINT") ; set order to tag "1"
#xcommand O_INVENT   => select(F_INVENT) ;usex (PRIVPATH+"INVENT"); set order to tag "1"

#xcommand O_ROBA     => select (F_ROBA)  ; use (SIFPATH+"ROBA")  ; set order to tag "ID"
#xcommand O_KONTO    => select (F_KONTO) ; use (SIFPATH+"KONTO") ; set order to tag "ID"
#xcommand O_PARTN    => select (F_PARTN) ; use (SIFPATH+"PARTN") ; set order to tag "ID"
#xcommand O_TNAL     => select (F_TNAL)  ; use (SIFPATH+"TNAL")  ; set order to tag "ID"
#xcommand O_TDOK     => select (F_TDOK)  ; use (SIFPATH+"TDOK")  ; set order to tag "ID"
#xcommand O_TARIFA   => select (F_TARIFA); use (SIFPATH+"TARIFA"); set order to tag "ID"
#xcommand O_KARKON   => select (F_KARKON); use (SIFPATH+"KARKON"); set order to tag "ID"
#xcommand O_VALUTE   => select (F_VALUTE); use (SIFPATH+"VALUTE"); set order to tag "ID"


