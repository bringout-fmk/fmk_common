#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/dok/1g/stonal.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.8 $
 * $Log: stonal.prg,v $
 * Revision 1.8  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 * Revision 1.7  2003/04/12 06:45:10  mirsad
 * ispravka: gBrojac sada je PUBLIC varijabla
 *
 * Revision 1.6  2003/04/12 06:42:43  mirsad
 * ispravka: gBrojac sada je PUBLIC varijabla
 *
 * Revision 1.5  2002/11/18 04:27:38  mirsad
 * dorade-security
 *
 * Revision 1.4  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.3  2002/06/19 13:46:23  sasa
 * no message
 *
 * Revision 1.2  2002/06/17 09:22:39  ernad
 * headeri, podesavanje Makefile
 *
 *
 */

/*! \file fmk/fin/dok/1g/stonal.prg
 *  \brief Stampa proknjizenih naloga - stampa
 */

/*! \fn MnuStampaAzurNaloga()
 *  \brief Menij za stampu proknjizenih naloga
 */
 
function MnuStampaAzurNaloga()
*{
local izb:=1
cSecur:=SecurR(KLevel,"StAzur")
if ImaSlovo("X",cSecur)
    MsgBeep("Opcija nedostupna !")
    return
endif
private opc[2]
opc[1]:="1. subanalitika        "
opc[2]:="2. analitika/sintetika"

do while .t.
  izb:=menu("onal",opc,izb,.f.)
  do case
     case izb==0
        exit
     case izb==1
       StOANal()
     case izb==2
       StOSNal()
     case izb==3
        izb:=0
  endcase
enddo
return
*}


/*! \fn StOAnal()
 *  \brief Stampanje proknjizenog analitickog naloga
 */
 
function StOANal()
*{
private fK1:=fk2:=fk3:=fk4:=cDatVal:="N",gnLOst:=0,gPotpis:="N"
O_PARAMS
Private cSection:="1",cHistory:=" ",aHistory:={}
Params1()
RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)
RPar("dv",@cDatVal)
RPar("li",@gnLOSt)
RPar("po",@gPotpis)
select params
#ifndef CAX
use
#endif

private dDatNal:=date()

IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
  O_VRSTEP
ENDIF
O_NALOG
O_SUBAN
O_KONTO
O_PARTN
O_TNAL
O_TDOK

SELECT SUBAN
set order to 4
cIdVN:=space(2)
cIdFirma:=gFirma
cBrNal:=space(4)

Box("",2,35)
 set cursor on
 @ m_x+1,m_y+2 SAY "Nalog:"
 if gNW=="D"
  @ m_x+1,col()+1 SAY cIdFirma
 else
  @ m_x+1,col()+1 GET cIdFirma
 endif
 @ m_x+1,col()+1 SAY "-" GET cIdVN
 @ m_x+1,col()+1 SAY "-" GET cBrNal
 if gDatNal=="D"
  @ m_x+2,m_y+2 SAY "Datum naloga:" GET dDatNal
 endif
 read; ESC_BCR
BoxC()

select nalog
seek cidfirma+cidvn+cbrnal
NFOUND CRET  // ako ne postoji
dDatNal:=datnal

SELECT SUBAN
seek cidfirma+cidvn+cbrNal

START PRINT CRET

StSubNal("2")

END PRINT
closeret
return
*}


/*! \fn StOSNal(fKum)
 *  \brief Stampa sintetickog naloga
 *  \param fKum  - if fkum = .t. - stampa naloga iz anal.dbf, if fkum = .f. - stampa naloga iz panal.dbf
 */
 
function StOSNal(fkum)
*{
if fkum==NIL
  fkum:=.t.
endif


PicBHD:="@Z "+FormPicL(gPicBHD,17)
PicDEM:="@Z "+FormPicL(gPicDEM,12)
M:="---- -------- ------- --------------------------------------------- ----------------- -----------------"+IF(gVar1=="1","-"," ------------ ------------")

if fkum  // stampa starog naloga - naloga iz kumulativa - datoteka anal

 select (F_ANAL)
#ifdef CAX
 altd()
 use
 select (F_PANAL); use
#endif
 use ANAL alias PANAL
 set order to tag "2"
 O_KONTO
 O_PARTN
 O_TNAL
 O_NALOG

 cIdVN:=space(2)
 cIdFirma:=gFirma
 cBrNal:=space(4)

 Box("",1,35)
  @ m_x+1,m_y+2 SAY "Nalog:"
  if gNW=="D"
    @ m_x+1,col()+1 SAY cIdFirma
  else
    @ m_x+1,col()+1 GET cIdFirma
  endif
  @ m_x+1,col()+1 SAY "-" GET cIdVN
  @ m_x+1,col()+1 SAY "-" GET cBrNal
  read; ESC_BCR
 BoxC()
 select nalog
 seek cidfirma+cidvn+cbrnal
#ifdef CAX
 if !found(); select panal; use; endif
#endif
 NFOUND CRET  // ako ne postoji
 dDatNal:=datnal

 select PANAL
 seek cidfirma+cidvn+cbrNal
 START PRINT CRET

else
 cIdFirma:=idfirma; cidvn:=idvn; cBrNal:=brnal
 seek cidfirma+cidvn+cbrNal
 START PRINT RET
endif

nStr:=0
b1:={|| !eof()}

nCol1:=70

 cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
 b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
 b3:={|| cIdSinKon==LEFT(IdKonto,3)}
 b4:={|| cIdKonto==IdKonto}
 nDug3:=nPot3:=0
 nRbr2:=0 // brojac sint stavki
 nRbr:=0
 nUkUkDugBHD:=nUkUkPotBHD:=nUkUkDugDEM:=nUkUkPotDEM:=0
 Zagl12()
 DO WHILE eval(b1) .and. eval(b2)     // jedan nalog

    IF prow()>61+gPStranica; FF; Zagl12(); ENDIF
    cIdSinKon:=LEFT(IdKonto,3)
    nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
    DO WHILE  eval(b1) .and. eval(b2) .and. eval(b3)  // sinteticki konto

       cIdKonto:=IdKonto
       nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
       IF prow()>61+gPStranica; FF; Zagl12(); ENDIF
       DO WHILE  eval(b1) .and. eval(b2) .and. eval(b4)  // analiticki konto
          select KONTO; hseek cidkonto
          select PANAL
          P_NRED
          @ prow(),0 SAY  ++nRBr PICTURE '9999'
          @ prow(),pcol()+1 SAY IF(gDatNal=="D",SPACE(8),datnal)
          @ prow(),pcol()+1 SAY cIdKonto
          @ prow(),pcol()+1 SAY left(KONTO->naz,45)
          nCol1:=pcol()+1
          @ prow(),nCol1 SAY DugBHD PICTURE PicBHD
          @ prow(),pcol()+1 SAY PotBHD PICTURE PicBHD
          IF gVar1!="1"
           @ prow(),pcol()+1 SAY DugDEM PICTURE PicDEM
           @ prow(),pcol()+1 SAY PotDEM PICTURE PicDEM
          ENDIF
          nDugBHD+=DugBHD; nDugDEM+=DUGDEM
          nPotBHD+=PotBHD; nPotDEM+=POTDEM
          SKIP
       enddo

       nUkDugBHD+=nDugBHD; nUkPotBHD+=nPotBHD
       nUkDugDEM+=nDugDEM; nUkPotDEM+=nPotDEM
    ENDDO  // siteticki konto

    IF prow()>61+gPStranica; FF; Zagl12(); ENDIF
    P_NRED; ?? M
    P_NRED
    @ prow(),1 SAY ++nRBr2 PICTURE '999'
    @ prow(),pcol()+1 SAY PADR(cIdSinKon,6)
    SELECT KONTO; HSEEK cIdSinKon
    @ prow(),pcol()+1 SAY LEFT(Naz,45)
    SELECT PANAL
    @ prow(),nCol1 SAY nUkDugBHD PICTURE PicBHD
    @ prow(),pcol()+1 SAY nUkPotBHD PICTURE PicBHD
    IF gVar1!="1"
     @ prow(),pcol()+1 SAY nUkDugDEM PICTURE PicDEM
     @ prow(),pcol()+1 SAY nUkPotDEM PICTURE PicDEM
    ENDIF
    P_NRED; ?? M

    nUkUkDugBHD+=nUkDugBHD
    nUKUkPotBHD+=nUkPotBHD
    nUkUkDugDEM+=nUkDugDEM
    nUkUkPotDEM+=nUkPotDEM

 ENDDO  // nalog

 IF prow()>61+gPStranica; FF; Zagl12(); ENDIF

 P_NRED; ?? M
 P_NRED; ?? "ZBIR NALOGA:"
 @ prow(),nCol1 SAY nUkUkDugBHD PICTURE PicBHD
 @ prow(),pcol()+1 SAY nUkUkPotBHD PICTURE PicBHD
 IF gVar1!="1"
  @ prow(),pcol()+1 SAY nUkUkDugDEM PICTURE PicDEM
  @ prow(),pcol()+1 SAY nUkUkPotDEM PICTURE PicDEM
 ENDIF
 P_NRED; ?? M

FF

END PRINT

if fkum
#ifdef CAX
 if !found(); select panal; use; endif
#endif
 closeret
endif
return
*}


/*! \fn Zagl12()
 *  \brief Zaglavlje sintetickog naloga
 */
 
function Zagl12()
*{
local nArr
P_COND
F10CPI
?? gTS+":",gNFirma
if gNW=="N"
   select partn; hseek cidfirma; select panal
   ? cidfirma,"-",partn->naz
endif
?
P_COND
? "FIN.P: ANALITIKA/SINTETIKA -  NALOG ZA KNJIZENJE BROJ : "
@ prow(),PCOL()+2 SAY cIdFirma+" - "+cIdVn+" - "+cBrNal
if gDatNal=="D"
 @ prow(),pcol()+4 SAY "DATUM: "
 ?? dDatNal
endif

SELECT TNAL; HSEEK cIdVN; select PANAL
@ prow(),pcol()+4 SAY tnal->naz
@ prow(),pcol()+15 SAY "Str:"+str(++nStr,3)
P_NRED; ?? m
P_NRED; ?? "*RED*"+PADC(IF(gDatNal=="D","","DATUM"),8)+"*           NAZIV KONTA                               *            IZNOS U "+ValDomaca()+"           *"+IF(gVar1=="1","","     IZNOS U "+ValPomocna()+"       *")
P_NRED; ?? "    *        *                                                      ----------------------------------- "+IF(gVar1=="1","","-------------------------")
P_NRED; ?? "*BR *        *                                                     * DUGUJE  "+ValDomaca()+"    * POTRAZUJE  "+ValDomaca()+" *"+IF(gVar1=="1",""," DUG. "+ValPomocna()+"  * POT. "+ValPomocna()+" *")
P_NRED; ?? m
return
*}

