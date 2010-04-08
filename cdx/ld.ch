#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_LD_VERZIJA "03.51"
#define D_LD_PERIOD "03.96-25.03.10"
#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif

#define RADNIK radn->(PADR(TRIM(naz)+" ("+TRIM(imerod)+") "+ime,35))
#define RADNZABNK radn->(PADR(TRIM(naz)+" ("+TRIM(imerod)+") "+TRIM(ime), 40))

#xcommand O_RADN    => select (F_RADN); use (KUMPATH + "RADN"); set order to 1

#xcommand O_TPRSIHT => select (F_TPRSIHT); use (KUMPATH + "TPRSIHT"); set order to tag "ID"
#xcommand O_NORSIHT => select (F_NORSIHT); use (KUMPATH + "NORSIHT"); set order to tag "ID"
#xcommand O_RADSIHT => select (F_RADSIHT); use (KUMPATH + "RADSIHT"); set order to tag "1"
#xcommand O__RADN   => select (F__RADN);  usex (PRIVPATH+"_RADN")
#xcommand O_RADKR   => select (F_RADKR);  use (KUMPATH + "RADKR"); set order to  1
#xcommand O_RADKRX  => select (F_RADKR);  use (KUMPATH+"RADKR") ; set order to  0
#xcommand O__RADKR  => select (F__RADKR);  usex (PRIVPATH + "_RADKR")
#xcommand O_LD      => select (F_LD);      use (KUMPATH + "LD"); set order to 1
#xcommand O_LDX     => select (F_LD);    usex (KUMPATH + "LD") ; set order to 1
#xcommand O__LD     => select (F__LD);    usex (PRIVPATH+"_LD")
#xcommand O_LDSM    => select (F_LDSM);   use (PRIVPATH+"LDSM") ; set order to 1
#xcommand O_LDSMX   => select (F_LDSM);   usex (PRIVPATH+"LDSM") ; set order to 0
#xcommand O_OPSLD   => select 95; usex (PRIVPATH+"opsld") ; set order to 1
#xcommand O_REKLD0  => select (F_REKLD); use (KUMPATH+"rekld")
#xcommand O_REKLD   => select (F_REKLD); use (KUMPATH+"rekld") ; set order to 1
#xcommand O_REKLDP  => select (F_REKLDP); use (KUMPATH+"rekldp") ; set order to 1

#xcommand O_RJ      => select (F_RJ); use (KUMPATH+"RJ") ; set order to tag "ID"
#xcommand O_KBENEF  => select (F_KBENEF); use (SIFPATH+"KBENEF")  ;set order to tag "ID"
#xcommand O_POR     => select (F_POR); use (SIFPATH+"POR")  ; set order to tag "ID"
#xcommand O_DOPR    => select (F_DOPR); use (SIFPATH+"DOPR") ; set order to tag "ID"
#xcommand O_OPS     => select (F_OPS); use (SIFPATH+"OPS")  ; set order to tag "ID"
#xcommand O_KRED    => select (F_KRED); use (SIFPATH+"KRED")  ; set order to tag "ID"
#xcommand O__KRED   => select (F__KRED); usex (PRIVPATH+"_KRED") ; set order to tag "ID"
#xcommand O_STRSPR  => select (F_STRSPR); use (SIFPATH+"STRSPR") ; set order to tag "ID"
#xcommand O_VPOSLA  => select (F_VPOSLA); use  (SIFPATH+"VPOSLA")  ; set order to tag "ID"
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


#xcommand O_BANKE   => select (F_BANKE) ; use (SIFPATH+"BANKE")  ; set order to tag "ID"

#xcommand O_OBRACUNI => select (F_OBRACUNI) ; use (KUMPATH+"OBRACUNI"); set order to tag "RJ"

#xcommand O_RADSAT => select (F_RADSAT) ; use (KUMPATH+"RADSAT"); set order to tag "IDRADN"

#xcommand O_IZDANJA => select (F_IZDANJA) ; use (SIFPATH+"IZDANJA"); set order to tag "ID"

#xcommand O_PK_RADN => select (F_PK_RADN) ; use (KUMPATH+"PK_RADN"); set order to tag "1"

#xcommand O_PK_DATA => select (F_PK_DATA) ; use (KUMPATH+"PK_DATA"); set order to tag "1"

