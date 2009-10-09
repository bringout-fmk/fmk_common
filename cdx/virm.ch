#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_VIRM_VERZIJA "02.06"
#define D_VIRM_PERIOD '06.96-30.03.09'

#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif

#define I_ID 1

#xcommand O_PRIPR    => select (F_VIPRIPR)  ; usex (PRIVPATH+"PRIPR") ; set order to 1
#xcommand O_KUMUL    => select (F_KUMUL)  ; use  (KUMPATH+"KUMUL")  ; set order to 1
#xcommand O_VRPRIM   => select (F_VRPRIM) ; use  (KUMPATH+"VRPRIM") ; set order to tag "ID"
#xcommand O_STAMP    => select (F_STAMP)  ; use  (SIFPATH+"STAMP")  ; set order to tag "ID"

#xcommand O_PRIPR2   => select (F_VIPRIP2) ; usex (PRIVPATH+"PRIPR2") ; set order to 1
#xcommand O_KUMUL2   => select (F_KUMUL2) ; use  (KUMPATH+"KUMUL2")  ; set order to 1
#xcommand O_VRPRIM2  => select (F_VRPRIM2); use  (KUMPATH+"VRPRIM2") ; set order to tag "ID"
#xcommand O_STAMP2   => select (F_STAMP2) ; use  (SIFPATH+"STAMP2")  ; set order to tag "ID"

#xcommand O_PARTN    => select (F_PARTN)  ; use (SIFPATH+"PARTN")  ; set order to tag "ID"
#xcommand O_VALUTE   => select (F_VALUTE) ; use (SIFPATH+"VALUTE") ; set order to tag "ID"
#xcommand O_LDVIRM   => select (F_LDVIRM) ; use (KUMPATH+"LDVIRM") ; set order to tag "ID"

#xcommand O_KALVIR   => select (F_KALVIR) ; use (KUMPATH+"KALVIR") ; set order to tag "ID"


#xcommand O_JPRIH   => select (F_JPRIH) ; use  (SIFPATH+"JPRIH")  ; set order to tag "ID"
#xcommand O_OPS   => select (F_OPS) ; use  (SIFPATH+"OPS")  ; set order to tag "ID"
#xcommand O_BANKE   => select (F_BANKE) ; use  (SIFPATH+"BANKE")  ; set order to tag "ID"
#xcommand O_IZLAZ   => select (F_IZLAZ) ; usex (PRIVPATH+"IZLAZ") ; set order to 1

#define FF_PRIPR      31  // neisknjizeni podaci
#define FF_SUBAN     32
#define FF_ANAL     33
#define FF_SINT     34
#define FF_BBKLAS    35
#define FF_IOS     36
#define FF_KONTO     37
#define FF_PARTN     38
#define FF_TNAL     39
#define FF_TDOK     40
#define FF_NALOG     41
#define FF_PNALOG    42
#define FF_PSUBAN    43
#define FF_PANAL    44
#define FF_PSINT    45
#define FF_VALUTE    46
#define FF_PKONTO   47

#xcommand FO_PRIPR   => select (FF_PRIPR);   usex (gDirFin+"PRIPR") alias fpripr ;  set order to 1
#xcommand FO_SUBAN   => select (FF_SUBAN);  use  (gDirFik+"SUBAN")  alias fsuban ;  set order to 1
#xcommand FO_ANAL    => select (FF_ANAL);  use  (gDirFik+"ANAL")    ;  set order to 1
#xcommand FO_SINT    => select (FF_SINT);  use  (gDirFik+"SINT")    ;  set order to 1
#xcommand FO_BBKLAS  => select (FF_BBKLAS);  usex (gDirFin+"BBKLAS");  set order to 1
#xcommand FO_IOS     => select (FF_IOS);  usex (gDirFin+"IOS")      ;  set order to 1
#xcommand FO_KONTO   => select (FF_KONTO);  use (SIFPATH+"KONTO")   ;  set order to tag "ID"
#xcommand FO_PARTN   => select (FF_PARTN);  use (SIFPATH+"PARTN")   ;  set order to tag "ID"
#xcommand FO_TNAL    => select (FF_TNAL);  use (SIFPATH+"TNAL")     ;  set order to tag "ID"
#xcommand FO_TDOK    => select (FF_TDOK);  use (SIFPATH+"TDOK")     ;  set order to tag "ID"
#xcommand FO_NALOG   => select (FF_NALOG);  use  (gDirFik+"NALOG")  ;  set order to 1
#xcommand FO_PNALOG  => select (FF_PNALOG); usex (gDirFin+"PNALOG") ;  set order to 1
#xcommand FO_PSUBAN  => select (FF_PSUBAN); usex (gDirFin+"PSUBAN") ;  set order to 1
#xcommand FO_PANAL   => select (FF_PANAL); usex (gDirFin+"PANAL")   ;  set order to 1
#xcommand FO_PSINT   => select (FF_PSINT); usex (gDirFin+"PSINT")   ;  set order to 1
#xcommand FO_VALUTE  => select (FF_VALUTE); use  (SIFPATH+"VALUTE")  ;  set order to tag "ID"
#xcommand FO_PKONTO  => select (FF_PKONTO); use  (SIFPATH+"pkonto")  ;  set order to tag "ID"

#xcommand O_KALK    => select (31);  use  (gDirKalk+"\KALK")
#xcommand O_TARIFA  => select (32);  use  (cDirSif+"\TARIFA"); set order to tag "ID"
#xcommand O_REKLD   => select (31);  use  (gDirld+"REKLD") ;  set order to tag "1"
#xcommand O_KRED    => select (32);  use  (cDirSif+"\KRED"); set order to tag "ID"

