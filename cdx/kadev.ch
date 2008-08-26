#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_KADEV_VERZIJA "02.00"
#define D_KADEV_PERIOD '11.94-15.03.07'

#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif

#define F_K_0       1
#define F_K_1       2
#define F_PROMJ     3
#define F_RJ        4
#define F_RMJ       5
#define F_RJRMJ     6
#define F_STRSPR    7
#define F_MZ        8
#define F_K1        9
#define F_K2        10
#define F_ZANIM     11
#define F_RRASP     12
#define F_CIN       13
#define F_VES       14
#define F_NAC       15
#define F_KBENRST   16
#define F_GLOBUSL   17
#define F_OBRAZDEF  18
#define F_USLOVI    19
#define F_RJES      20
#define F_DEFRJES   21
#define F_NERDAN    22
#define F_POM       23

#define I_ID         1
#define I_PREZIME    2
#define I_ID2        3
#define I_RJRMJ      4

#define AOPSTINA_ST  1
#define ASTR_SPR     2
#define AULICA_ST    3
#define AZAPOSLEN    4
#define ABRAC_ST     5
#define AMJESTO_ST   6
#define AMZ_ST       7
#define AZANIMANJE   8
#define ANAZIV_RO    9
#define ASIF_JED     10
#define AVES         11
#define ACIN         12
#define ADUZNOST     13
#define ADAT_ISTUP   14
#define ADAT_S_JED   15
#define APRISUTNOST  16
#define ABROJ_LEG    17
#define ABROJ        17
#define EXE_PATH   FilePath(Arg0())

#command DEL2                                                            ;
      => (nArr)->(DbDelete())                                            ;
        ;(nTmpArr)->(DbDelete())

#xcommand O_K_0     =>  select(F_K_0);     use (KUMPATH+"k_0")    ; set order to tag "1"
#xcommand O_K_1     =>  select(F_K_1);     use (KUMPATH+"k_1")    ; set order to tag "1"
#xcommand O_PROMJ   =>  select(F_PROMJ);   use (SIFPATH+"promj")  ; set order to tag "ID"
#xcommand O_RJ      =>  select(F_RJ);      use (SIFPATH+"rj")     ; set order to tag "ID"
#xcommand O_RMJ     =>  select(F_RMJ);     use (SIFPATH+"rmj")    ; set order to tag "ID"
#xcommand O_RJRMJ   =>  select(F_RJRMJ);   use (SIFPATH+"rjrmj")  ; set order to tag "ID"
#xcommand O_STRSPR  =>  select(F_STRSPR);  use (SIFPATH+"strspr") ; set order to tag "ID"
#xcommand O_MZ      =>  select(F_MZ);      use (SIFPATH+"mz")     ; set order to tag "ID"
#xcommand O_NERDAN  =>  select(F_NERDAN);  use (SIFPATH+"nerdan") ; set order to tag "ID"
#xcommand O_K1      =>  select(F_K1);      use (SIFPATH+"k1")     ; set order to tag "ID"
#xcommand O_K2      =>  select(F_K2);      use (SIFPATH+"k2")     ; set order to tag "ID"
#xcommand O_ZANIM   =>  select(F_ZANIM);   use (SIFPATH+"zanim")  ; set order to tag "ID"
#xcommand O_RRASP   =>  select(F_RRASP);   use (SIFPATH+"rrasp")  ; set order to tag "ID"
#xcommand O_CIN     =>  select(F_CIN);     use (SIFPATH+"cin")    ; set order to tag "ID"
#xcommand O_VES     =>  select(F_VES);     use (SIFPATH+"ves")    ; set order to tag "ID"
#xcommand O_NAC     =>  select(F_NAC);     use (SIFPATH+"nac")    ; set order to tag "ID"
#xcommand O_KBENRST =>  select(F_KBENRST); use (SIFPATH+"kbenrst"); set order to tag "ID"
#xcommand O_RJES    =>  select(F_RJES);    use (SIFPATH+"rjes")   ; set order to tag "ID"
#xcommand O_DEFRJES =>  select(F_DEFRJES); use (SIFPATH+"defrjes"); set order to tag "1"
#xcommand O_GLOBUSL  => select(F_GLOBUSL);  USE (KUMPATH+"globusl") ; set order to tag "1"
#xcommand O_OBRAZDEF => select(F_OBRAZDEF); USE (KUMPATH+"obrazdef"); set order to tag "1"
#xcommand O_USLOVI   => select(F_USLOVI);   USE (KUMPATH+"uslovi")  ; set order to tag "1"


