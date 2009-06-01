/*
 * ----------------------------------------------------------------
 *                         Copyright Sigma-com software 1998-2006
 * ----------------------------------------------------------------
 */
 
#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_FA_VERZIJA "03.10"
#define D_FA_PERIOD  "11.94-01.06.09"
#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif

#define I_ID 1

#command POCNI STAMPU   => if !lSSIP99 .and. !StartPrint()       ;
                           ;close all             ;
                           ;return                ;
                           ;endif

#command ZAVRSI STAMPU  => if !lSSIP99; EndPrint(); endif

#define  ZAOKRUZENJE    2

#define NL  chr(13)+chr(10)

#xcommand O_PRIPR     => select (F_PRIPR);   usex (PRIVPATH+"PRIPR") ; set order to tag "1"
#xcommand O_PRIPR9     => select (F_PRIPR9);   usex (PRIVPATH+"PRIPR9") ; set order to tag "1"
#xcommand O_PRIPRRP   => select (F_PRIPRRP); usex (strtran(cDirPriv,goModul:oDataBase:cSezonDir,SLASH)+"PRIPR")   alias priprrp; set order to tag  "1"
#xcommand O_FAKT      => select (F_FAKT) ;   use  (KUMPATH+"FAKT") ; set order to tag  "1"
#xcommand O__FAKT     => select(F__FAKT)  ; cmxAutoOpen(.f.);  usex (PRIVPATH+"_FAKT") ; cmxAutoOpen(.t.)
#xcommand O__ROBA   => select(F__ROBA);  use  (PRIVPATH+"_ROBA")
#xcommand O_PFAKT     => select (F_FAKT);  use  (KUMPATH+"FAKT") alias PRIPR; set order to tag   "1"
#xcommand O_DOKS      => select(F_DOKS);    use  (KUMPATH+"DOKS")  ; set order to tag "1"
#xcommand O_DOKS2     => select(F_DOKS2);    use  (KUMPATH+"DOKS2")  ; set order to tag "1"

#xcommand O_ROBA    =>  select(F_ROBA  );use (SIFPATH+"ROBA"); set order to tag "ID"
#xcommand O_PARTN    => select (F_PARTN);  use (SIFPATH+"PARTN"); set order to tag "ID"
#xcommand O_FTXT    => select (F_FTXT);    use (SIFPATH+"ftxt")    ; set order to tag "ID"
#xcommand O_TARIFA   => select(F_TARIFA);  use  (SIFPATH+"TARIFA") ; set order to tag "ID"
#xcommand O_VALUTE   => select(F_VALUTE);  use  (SIFPATH+"VALUTE") ; set order to tag "ID"
#xcommand O_RJ       => select (F_RJ); use  (KUMPATH+"RJ")         ; set order to tag "ID"
#xcommand O_UPL      => select (F_UPL); use  (KUMPATH+"UPL")         ; set order to tag "1"
#xcommand O_SAST     => select (F_SAST); use  (SIFPATH+"SAST")    ; set order to tag "ID"
#xcommand O_KONTO    => select(F_KONTO);  use  (SIFPATH+"KONTO"); set order to tag "ID"
#xcommand O_UGOV     => select(F_UGOV);  use  (KUMPATH+"UGOV")     ; set order to tag "ID"
#xcommand O_RUGOV    => select(F_RUGOV);  use  (KUMPATH+"RUGOV")   ; set order to tag "ID"
#xcommand O_POR      => select 95; cmxAutoOpen(.f.); usex (PRIVPATH+"por")  ; cmxAutoOpen(.t.)

#xcommand O_FADO     => select (F_FADO); use  (SIFPATH+"FADO")    ; set order to tag "ID"
#xcommand O_FADE     => select (F_FADE); use  (SIFPATH+"FADE")    ; set order to tag "ID"
#xcommand O_VRSTEP => SELECT (F_VRSTEP); USE (SIFPATH+"VRSTEP"); set order to tag "ID"
#xcommand O_OPS    => SELECT (F_OPS)   ; USE (SIFPATH+"OPS"); set order to tag "ID"

#xcommand O_RELAC  => SELECT (F_RELAC) ; USE (SIFPATH+"RELAC"); set order to tag "ID"
#xcommand O_VOZILA => SELECT (F_VOZILA); USE (SIFPATH+"VOZILA"); set order to tag "ID"
#xcommand O_KALPOS => SELECT (F_KALPOS); USE (KUMPATH+"KALPOS"); set order to tag "1"
#xcommand O_CROBA  => SELECT (F_CROBA) ; USE (gCENTPATH+"CROBA"); set order to tag "IDROBA"

#xcommand O_KONCIJ => select(F_KONCIJ);  use  (SIFPATH+"KONCIJ")     ; set order to tag "ID"
#xcommand O_BARKOD  => select(F_BARKOD);  use (PRIVPATH+"BARKOD"); set order to tag "1"

#xcommand O_POMGN  => select(F_POMGN);  use (KUMPATH+"POMGN"); set order to tag "4"
#xcommand O_SDIM => select(F_SDIM); use (KUMPATH+"SDIM"); set order to tag "1"
#xcommand O__SDIM => select(F__SDIM); use (PRIVPATH+"_SDIM"); set order to tag "1"


