#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_POR_VERZIJA "03.01"
#define D_POR_PERIOD '06.96-23.01.2009'

#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif

#define _LR_  13
#define _LK_  10

#define F_PRIPNO  23
#define F_LDNO    24
#define F_RJES    25

#xcommand O_LDNO   => select (F_LDNO)  ; usex (KUMPATH+"LDNO"); set order to 1
#xcommand O_PRIPNO => select (F_PRIPNO); usex (PRIVPATH+"PRIPNO")
#xcommand O_RJES => select (F_RJES); usex (KUMPATH+"RJES"); set order to tag "NAOSNOVU"


#xcommand O_RADN    => OKumul(F_RADN, KUMPATH,"RADN",1); set order to 1

#xcommand O_TPRSIHT   => OKumul(F_TPRSIHT, KUMPATH,"TPRSIHT",1); set order to tag "ID"
#xcommand O_NORSIHT   => OKumul(F_NORSIHT, KUMPATH,"NORSIHT",1); set order to tag "ID"
#xcommand O_RADSIHT   => OKumul(F_RADSIHT, KUMPATH,"RADSIHT",1); set order to tag "1"


#xcommand O__RADN    => select (F__RADN);  usex (PRIVPATH+"_RADN")
#xcommand O_RADKR    => OKumul(F_RADKR, KUMPATH,"RADKR",1); set order to  1
#xcommand O_RADKRX   => select (F_RADKR);  usex (KUMPATH+"RADKR") ; set order to  0
#xcommand O__RADKR   => select (F__RADKR);    use (PRIVPATH+"_RADKR")
#xcommand O_LD      => OKumul(F_LD, KUMPATH, "LD",1)   ; set order to 1
#xcommand O_LDX      => select (F_LD);    usex (KUMPATH+"LD") ; set order to 1
#xcommand O__LD     => select (F__LD);    usex (PRIVPATH+"_LD")
#xcommand O_LDSM    => select (F_LDSM);   use (PRIVPATH+"LDSM") ; set order to 1
#xcommand O_LDSMX   => select (F_LDSM);   usex (PRIVPATH+"LDSM") ; set order to 0
#xcommand O_OPSLD  => select 95; usex (PRIVPATH+"opsld") ; set order to 1
#xcommand O_REKLD0 => select (F_REKLD); usex (KUMPATH+"rekld")
#xcommand O_REKLD  => select (F_REKLD); usex (KUMPATH+"rekld") ; set order to 1

#xcommand O_RJ   => select (F_RJ); use  (KUMPATH+"RJ") ; set order to tag "ID"
#xcommand O_KBENEF => select (F_KBENEF); use (SIFPATH+"KBENEF")  ;set order to tag "ID"
#xcommand O_POR   => select (F_POR); use  (SIFPATH+"POR")  ; set order to tag "ID"
#xcommand O_DOPR   => select (F_DOPR); use  (SIFPATH+"DOPR") ; set order to tag "ID"
#xcommand O_OPS   => select (F_OPS); use  (SIFPATH+"OPS")  ; set order to tag "ID"
#xcommand O_KRED  => select (F_KRED); use  (SIFPATH+"KRED")  ; set order to tag "ID"
#xcommand O__KRED => select (F__KRED); use  (PRIVPATH+"_KRED") ; set order to tag "ID"
#xcommand O_STRSPR => select (F_STRSPR); use  (SIFPATH+"STRSPR") ; set order to tag "ID"
#xcommand O_VPOSLA => select (F_VPOSLA); use  (SIFPATH+"VPOSLA")  ; set order to tag "ID"
#xcommand O_PAROBR  => select (F_PAROBR);  use (SIFPATH+"PAROBR") ; set order to tag "ID"
#xcommand O_TIPPR   => select (F_TIPPR);   use (SIFPATH+"TIPPR") ; set order to tag "ID"
#xcommand O_TIPPR2  => select (F_TIPPR2);  use (SIFPATH+"TIPPR2") ; set order to tag "ID"

#xcommand O_TIPPRN  => IF cObracun<>"1".and.!EMPTY(cObracun);
                      ;  select (F_TIPPR2)                  ;
                      ;  use (SIFPATH+"TIPPR2") alias TIPPR ;
                      ;  set order to tag "ID"              ;
                      ;ELSE                                 ;
                      ;  select (F_TIPPR)                   ;
                      ;  use (SIFPATH+"TIPPR")              ;
                      ;  set order to tag "ID"              ;
                      ;ENDIF


#xcommand O_BANKE   => select (F_BANKE) ; use  (SIFPATH+"BANKE")  ; set order to tag "ID"



