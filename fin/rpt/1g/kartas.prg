#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rpt/1g/kartas.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: kartas.prg,v $
 * Revision 1.3  2004/01/13 19:07:57  sasavranic
 * appsrv konverzija
 *
 * Revision 1.2  2002/06/20 11:31:07  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/rpt/1g/kartas.prg
 *  \brief Kartice
 */

/*! \fn SinKart()
 *  \brief Sinteticka kartica
 */
 
function SinKart()
*{
cIdFirma:=gFirma
qqKonto:=""
dDatOd:=dDAtDo:=ctod("")
cBrza:="D"

IF gVar1=="0"
 M:="------- ------ ----- -------- ---------------- ----------------- ----------------- ------------- ------------- -------------"
ELSE
 M:="------- ------ ----- -------- ---------------- ----------------- ------------------"
ENDIF


cPredh:="2"


O_PARTN
O_PARAMS
private cSection:="1"; cHistory:=" ";aHistory:={}
Params1()
RPar("c1",@cIdFirma);RPar("c2",@qqKonto); RPar("d1",@dDatOD); RPar("d2",@dDatDo)
RPar("c3",@cBrza)
RPar("c4",@cPredh)
if gNW=="D";cIdFirma:=gFirma; endif


Box("",9,75)
do while .t.
 set cursor on
 @ m_x+1,m_y+2 SAY "KARTICA (SINTETICKI KONTO)"
 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Brza kartica (D/N)               " GET cBrza pict "@!" valid cBrza $ "DN"
 @ m_x+4,m_y+2 SAY "BEZ/SA prethodnim prometom (1/2):" GET cPredh valid cPredh $ "12"
 read; ESC_BCR
 if cBrza=="D"
    qqKonto:=padr(qqKonto,3)
    @ m_x+6,m_y+2 SAY "Konto: " GET qqKonto
 else
    qqKonto:=padr(qqKonto,60)
    @ m_x+6,m_y+2 SAY "Konto: " GET qqKonto PICTURE "@S50"
 endif
 @ m_x+8,m_y+2 SAY "Datum od:" GET dDatOd
 @ m_x+8,col()+2 SAY "do:" GET dDatDo
 cIdRJ:=""
 IF gRJ=="D" .and. gSAKrIz=="D"
   cIdRJ:="999999"
   @ m_x+9,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 read; ESC_BCR

 if cBrza=="N"
  aUsl1:=Parsiraj(qqKonto,"IdKonto","C")
  if aUsl1<>NIL; exit; endif
 else
  exit
 endif
enddo
if Params2()
 WPar("c1",@cIdFirma);WPar("c2",@qqKonto);WPar("d1",@dDatOD); WPar("d2",@dDatDo)
 WPAr("c3",@cBrza)
 WPar("c4",cPredh)
endif
select params; use

BoxC()

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

cSecur:=SecurR(KLevel,"KartSve")
if cBrza=="N" .and. ImaSlovo("X",cSecur)
    MsgBeep("Dozvoljena vam je samo brza kartica !")
    closeret
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  SintFilt(.t.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_SINT
ENDIF
O_KONTO

select SINT

cFilt1 := ".t." +IF(cBrza=="D","",".and."+aUsl1)+;
          IF(EMPTY(dDatOd).or.cPredh=="2","",".and.DATNAL>="+cm2str(dDatOd))+;
          IF(EMPTY(dDatDo),"",".and.DATNAL<="+cm2str(dDatDo))

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

IF cBrza=="D"
  HSEEK cIdFirma+qqKonto
ELSE
  HSEEK cIdFirma
ENDIF

#ifndef CAX
EOF RET
#else
EOF CRET
#endif

nStr:=0
START PRINT CRET

if nStr==0; SinkZagl();endif
nSviD:=nSviP:=nSviD2:=nSviP2:=0
do whilesc !eof() .and. idfirma==cIdFirma

if cBrza=="D"
  if qqKonto<>IdKonto; exit; endif
endif

cIdkonto:=IdKonto
nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0

if prow()>55+gPStranica; FF; SinKZagl(); endif

? m
SELECT KONTO; HSEEK cIdKonto
? "KONTO   ",cIdKonto,konto->naz

select SINT
? m
nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
fPProm:=.t.
do whilesc !eof() .and. idfirma==cIdFirma .and. cIdKonto==IdKonto

  //********* prethodni promet *********************************
  if cPredh=="2"
   if dDatOd>datnal .and. fPProm==.t.
     nDugBHD+=DugBHD; nPotBHD+=PotBHD
     nDugDEM+=DugDEM; nPotDEM+=PotDEM
     skip; loop
   else
     if fPProm
       ? "Prethodno stanje"
       @ prow(),30             SAY nDugBHD     PICTURE PicBHD
       @ prow(),pcol()+2  SAY nPotBHD     PICTURE PicBHD
       @ prow(),pcol()+2  SAY nDugBHD-nPotBHD PICTURE PicBHD
       IF gVar1=="0"
         @ prow(),pcol()+2  SAY nDugDEM     PICTURE PicDEM
         @ prow(),pcol()+2  SAY nPotDEM     PICTURE PicDEM
         @ prow(),pcol()+2  SAY nDugDEM-nPotDEM PICTURE PicDEM
       ENDIF
     endif
     fPProm:=.f.
   endif
  endif

  IF prow()>63+gPStranica; FF; SinKZagl();ENDIF
  ? IdVN
  @ prow(),9 SAY BrNal
  @ prow(),16 SAY RBr
  @ prow(),21 SAY DatNal
  @ prow(),30 SAY DugBHD PICTURE PicBHD
  @ prow(), pcol()+2 SAY PotBHD PICTURE picBHD
  nDugBHD+=DugBHD; nPotBHD+=PotBHD
  nDugDEM+=DugDEM; nPotDEM+=PotDEM
  @ prow(),pcol()+2 SAY nDugBHD-nPotBHD PICTURE PicBHD
  IF gVar1=="0"
   @ prow(),pcol()+2 SAY DugDEM PICTURE PicDEM
   @ prow(),pcol()+2 SAY PotDEM PICTURE picDEM
   @ prow(),pcol()+2 SAY nDugDEM-nPotDEM PICTURE PicDEM
  ENDIF
  SKIP
ENDDO

IF prow()>62+gPStranica; FF; SinKZagl(); ENDIF
? m
? "UKUPNO ZA:"+cIdKonto
@ prow(),30             SAY nDugBHD     PICTURE PicBHD
@ prow(),pcol()+2  SAY nPotBHD     PICTURE PicBHD
@ prow(),pcol()+2  SAY nDugBHD-nPotBHD PICTURE PicBHD
IF gVar1=="0"
 @ prow(),pcol()+2  SAY nDugDEM     PICTURE PicDEM
 @ prow(),pcol()+2  SAY nPotDEM     PICTURE PicDEM
 @ prow(),pcol()+2  SAY nDugDEM-nPotDEM PICTURE PicDEM
ENDIF
? M
nSviD+=nDugBHD; nSviP+=nPotBHD
nSviD2+=nDugDEM; nSviP2+=nPotDEM

if gnRazRed==99
  FF; SinKZagl()
else
  i:=0
  do while prow()<=55+gPstranica.and.gnRazRed>i
    ?; ++i
  enddo
endif

enddo // eof()

if cBrza=="N"
IF prow()>62+gPStranica; FF; SinKZagl(); ENDIF
? M
? "UKUPNO ZA SVA KONTA:"
@ prow(),30             SAY nSviD           PICTURE PicBHD
@ prow(),pcol()+2  SAY nSviP           PICTURE PicBHD
@ prow(),pcol()+2  SAY nSviD-nSviP     PICTURE PicBHD
IF gVar1=="0"
 @ prow(),pcol()+2  SAY nSviD2          PICTURE PicDEM
 @ prow(),pcol()+2  SAY nSviP2          PICTURE PicDEM
 @ prow(),pcol()+2  SAY nSviD2-nSviP2   PICTURE PicDEM
ENDIF
? M
endif // cbrza=="N"

FF
EndPrint()

#ifndef CAX
closeret
#endif
return
*}


/*! \fn SinKZagl()
 *  \brief Zaglavlje sinteticke kartice
 */
 
function SinKZagl()
*{
P_COND
?? "FIN.P: SINTETICKA KARTICA  NA DAN: "; ?? DATE()
if !(empty(dDatOd) .and. empty(dDatDo))
    ?? "   ZA PERIOD OD",dDatOd,"DO",dDatDo
endif
@ prow(),125 SAY "Str."+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

SELECT SINT
IF gVar1=="1"; F12CPI; ENDIF
?  m
IF gVar1=="0"
 ?  "*VRSTA * BROJ *REDNI* DATUM  *           I  Z  N  O  S     U     "+ValDomaca()+"             *      I  Z  N  O  S     U     "+ValPomocna()+"      *"
 ?  "                              ---------------------------------------------------- -----------------------------------------"
 ?  "*NALOGA*NALOGA*BROJ *        *    DUGUJE      *     POTRAZUJE   *      SALDO      *   DUGUJE    *  POTRAZUJE  *    SALDO   *"
ELSE
 ?  "*VRSTA * BROJ *REDNI* DATUM  *           I  Z  N  O  S     U     "+ValDomaca()+"             *"
 ?  "                              -----------------------------------------------------"
 ?  "*NALOGA*NALOGA*BROJ *        *    DUGUJE      *     POTRAZUJE   *      SALDO      *"
ENDIF
?  m

RETURN
*}



/*! \fn SinKart2()
 *  \brief Sinteticka kartica (varijanta po mjesecima)
 */

function SinKart2()
*{
cIdFirma:=gFirma
qqKonto:=""
dDatOd:=dDAtDo:=ctod("")

IF gVar1=="0"
 M:="------------- ---------------- ----------------- ----------------- ------------- ------------- -------------"
ELSE
 M:="------------- ---------------- ----------------- ------------------"
ENDIF

O_PARTN

O_PARAMS
Private cSection:="2",cHistory:=" ",aHistory:={}
Params1()
RPar("c1",@cIdFirma); RPar("c2",@qqKonto); RPar("d1",@dDatOd); RPar("d2",@dDatDo)
if gNW=="D";cIdFirma:=gFirma; endif
qqKonto:=padr(qqKonto,100)

Box("",5,75)
do while .t.
 set cursor on
 @ m_x+1,m_y+2 SAY "KARTICA (SINTETICKI KONTO) PO MJESECIMA"

 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Konto: " GET qqKonto PICTURE "@S50"
 @ m_x+4,m_y+2 SAY "Datum od:" GET dDatOd
 @ m_x+4,col()+2 SAY "do:" GET dDatDo
 cIdRJ:=""
 IF gRJ=="D" .and. gSAKrIz=="D"
   cIdRJ:="999999"
   @ m_x+5,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 READ;  ESC_BCR
 aUsl1:=Parsiraj(qqKonto,"IdKonto","C")
 if aUsl1<>NIL; exit; endif
enddo
BoxC()

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

cIdFirma:=left(cIdFirma,2)
qqKonto:=trim(qqKonto)

if Params2()
 WPar("c1",@cIdFirma); WPar("c2",@qqKonto); WPar("d1",@dDatOd); WPar("d2",@dDatDo)
endif
select params; use


IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  SintFilt(.t.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_SINT
ENDIF
O_KONTO

select SINT

cFilt1 := aUsl1+;
          IF(EMPTY(dDatOd),"",".and.DATNAL>="+cm2str(dDatOd))+;
          IF(EMPTY(dDatDo),"",".and.DATNAL<="+cm2str(dDatDo))

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

hseek cidfirma
#ifndef CAX
EOF RET
#else
EOF CRET
#endif

nStr:=0
START PRINT CRET

if nStr==0; ZaglSink2();endif
nSviD:=nSviP:=nSviD2:=nSviP2:=0

do whilesc idfirma==cidfirma .and. !eof()
cIdkonto:=IdKonto
nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0

if prow()>55+gPStranica; FF; ZaglSink2(); endif

? m
SELECT KONTO; HSEEK cIdKonto
? "KONTO   "; @ prow(),pcol()+1 SAY cIdKonto
@ prow(),pcol()+2 SAY konto->naz
select SINT

? m

nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
do whilesc !eof() .and. idfirma==cidfirma .and. cIdKonto==IdKonto
  IF prow()>63+gPStranica; FF; ZaglSink2();ENDIF
  nMonth:=month(DatNal)
  nDBHD:=nPBHD:=nDDEM:=nPDEM:=0
  nPSDBHD:=nPSPBHD:=nPSDDEM:=nPSPDEM:=0
  do while !eof() .and. idfirma==cidfirma .and. cIdKonto==IdKonto .and. month(datnal)==nMonth
    if idvn=="00"
     nPSDBhd+=DugBHD; nPSPBHD+=PotBHD
     nPSDDEM+=DugDEM; nPSPDEM+=PotDEM
    else
     nDBhd+=DugBHD; nPBHD+=PotBHD
     nDDEM+=DugDEM; nPDEM+=PotDEM
    endif
    skip
  enddo
  if round(nPSDBHD,4)<>0 .or. round(nPSPBHD,4)<>0 // pocetno stanje
          @ prow()+1,3 SAY " PS"
          nC1:=pcol()+8
          @ prow(),pcol()+8 SAY nPSDBHD PICTURE PicBHD
          @ prow(), pcol()+2 SAY nPSPBHD PICTURE picBHD
          nDugBHD+=nPSDBHD; nPotBHD+=nPSPBHD
          nDugDEM+=nPSDDEM; nPotDEM+=nPSPDEM
          @ prow(),pcol()+2 SAY nDugBHD-nPotBHD PICTURE PicBHD
          IF gVar1=="0"
           @ prow(),pcol()+2 SAY nPSDDEM PICTURE PicDEM
           @ prow(),pcol()+2 SAY nPSPDEM PICTURE picDEM
           @ prow(),pcol()+2 SAY nDugDEM-nPotDEM PICTURE PicDEM
          ENDIF
  endif
  @ prow()+1,3 SAY str(nMonth,3)
  nC1:=pcol()+8
  @ prow(),pcol()+8 SAY nDBHD PICTURE PicBHD
  @ prow(), pcol()+2 SAY nPBHD PICTURE picBHD
  nDugBHD+=nDBHD; nPotBHD+=nPBHD
  nDugDEM+=nDDEM; nPotDEM+=nPDEM
  @ prow(),pcol()+2 SAY nDugBHD-nPotBHD PICTURE PicBHD
  IF gVar1=="0"
   @ prow(),pcol()+2 SAY nDDEM PICTURE PicDEM
   @ prow(),pcol()+2 SAY nPDEM PICTURE picDEM
   @ prow(),pcol()+2 SAY nDugDEM-nPotDEM PICTURE PicDEM
  ENDIF
ENDDO

IF prow()>62+gPStranica; FF; ZaglSink2(); ENDIF
? M
? "UKUPNO ZA:"+cIdKonto
@ prow(),nC1            SAY nDugBHD     PICTURE PicBHD
@ prow(),pcol()+2  SAY nPotBHD     PICTURE PicBHD
@ prow(),pcol()+2  SAY nDugBHD-nPotBHD PICTURE PicBHD
IF gVar1=="0"
 @ prow(),pcol()+2  SAY nDugDEM     PICTURE PicDEM
 @ prow(),pcol()+2  SAY nPotDEM     PICTURE PicDEM
 @ prow(),pcol()+2  SAY nDugDEM-nPotDEM PICTURE PicDEM
ENDIF
? M

nSviD+=nDugBHD; nSviP+=nPotBHD
nSviD2+=nDugDEM; nSviP2+=nPotDEM

if gnRazRed==99
  FF; ZaglSink2()
else
  i:=0
  do while prow()<=55+gPstranica.and.gnRazRed>i
    ?; ++i
  enddo
endif

enddo // eof()

IF prow()>62+gPStranica; FF; ZaglSink2(); ENDIF
? M
? "ZA SVA KONTA:"
@ prow(),nC1            SAY nSviD           PICTURE PicBHD
@ prow(),pcol()+2  SAY nSviP           PICTURE PicBHD
@ prow(),pcol()+2  SAY nSviD-nSviP     PICTURE PicBHD
IF gVar1=="0"
 @ prow(),pcol()+2  SAY nSviD2          PICTURE PicDEM
 @ prow(),pcol()+2  SAY nSviP2          PICTURE PicDEM
 @ prow(),pcol()+2  SAY nSviD2-nSviP2   PICTURE PicDEM
ENDIF
? M

FF
END PRINT

#ifndef CAX
closeret
#endif
return
*}


/*! \fn ZaglSinK2()
 *  \brief Zaglavlje sinteticke kartice varijante 2
 */
 
function ZaglSink2()
*{
P_COND
?? "FIN.P: SINTETICKA KARTICA  PO MJESECIMA NA DAN: "; ?? DATE()
if !(empty(dDatOd) .and. empty(dDatDo))
    ?? "   ZA PERIOD OD",dDatOd,"DO",dDatDo
endif
@ prow(),125 SAY "Str."+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,"-",gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cIdFirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

SELECT SINT

IF gVar1=="1"; F10CPI; ENDIF
?  m
IF gVar1=="0"
 ?  "*  MJESEC    *             I Z N O S     U     "+ValDomaca()+"               *       I Z N O S     U     "+ValPomocna()+"         *"
 ?  "              ---------------------------------------------------- -----------------------------------------"
 ?  "*            *    DUGUJE      *     POTRA@UJE   *      SALDO      *   DUGUJE    *  POTRA@UJE  *    SALDO   *"
ELSE
 ?  "*  MJESEC    *             I Z N O S     U     "+ValDomaca()+"               *"
 ?  "              -----------------------------------------------------"
 ?  "*            *    DUGUJE      *     POTRA@UJE   *      SALDO      *"
ENDIF
?  m

RETURN
*}



/*! \fn AnKart()
 *  \brief Analiticka kartica
 */
 
function AnKart()
*{
local nCOpis:=0,cOpis:=""

cIdFirma:=gFirma
qqKonto:=""
cBrza:="D"
cPTD:="N"
IF gVar1=="0"
 M:="------- ------ ----- -------- ---------------- ----------------- ----------------- ------------- ------------- -------------"
ELSE
 M:="------- ------ ----- -------- ---------------- ----------------- ------------------"
ENDIF

O_PARTN
O_KONTO

dDatOd:=dDAtDo:=ctod("")
cPredh:="2"

O_PARAMS
Private cSection:="3",cHistory:=" ",aHistory:={}
Params1()
RPar("c1",@cIdFirma); RPar("c2",@qqKonto); RPar("d1",@dDatOd); RPar("d2",@dDatDo)
RPar("c3",@cBrza)
RPar("c4",@cPredh)
RPar("c8",@cPTD)
if gNW=="D";cIdFirma:=gFirma; endif

Box("",9,65,.f.)
do while .t.
 set cursor on
 @ m_x+1,m_y+2 SAY "ANALITICKA KARTICA"
 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| empty(cIdFirma) .or. P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Brza kartica (D/N/S)" GET cBrza pict "@!" valid cBrza $ "DNS"
 @ m_x+4,m_y+2 SAY "BEZ/SA prethodnim prometom (1/2):" GET cPredh valid cPredh $ "12"
 read; ESC_BCR
 if cBrza=="D"
    qqKonto:=padr(qqKonto,7)
    @ m_x+6,m_y+2 SAY "Konto: " GET qqKonto valid P_Konto(@qqKonto)
 else
    qqKonto:=padr(qqKonto,60)
    @ m_x+6,m_y+2 SAY "Konto: " GET qqKonto PICTURE "@S50"
 endif
 if gNW=="N"
   @ m_x+7,m_y+2 SAY "Prikaz tipa dokumenta (D/N)" GET cPTD pict "@!" valid cPTD $ "DN"
 endif
 @ m_x+8,m_y+2 SAY "Datum od:" GET dDatOd
 @ m_x+8,col()+2 SAY "do:" GET dDatDo
 cIdRJ:=""
 IF gRJ=="D" .and. gSAKrIz=="D"
   cIdRJ:="999999"
   @ m_x+9,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 read; ESC_BCR

 if cBrza=="N".or.cBrza=="S"
  qqKonto:=trim(qqKonto)
  aUsl1:=Parsiraj(qqKonto,"IdKonto","C")
  if aUsl1<>NIL; exit; endif
 else
  exit
 endif
enddo
BoxC()

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

if Params2()
 WPar("c1",padr(cIdFirma,2)); WPar("c2",@qqKonto); WPar("d1",@dDatOd); WPar("d2",@dDatdo)
 WPar("c3",cBrza)
 WPar("c4",cPredh)
 WPar("c8",cPTD)
endif
select params; use

cSecur:=SecurR(KLevel,"KartSve")
if cBrza=="N" .and. ImaSlovo("X",cSecur)
    MsgBeep("Dozvoljena vam je samo brza kartica !")
    closeret
endif


IF gNW=="N".and.cPTD=="D"
  m:=STUFF(m,30,0," -- ------------- ---------- --------------------")
  O_SUBAN; SET ORDER TO 4
  O_TDOK
ENDIF

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  SintFilt(.f.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_ANAL
ENDIF
O_KONTO

select ANAL

IF cBrza=="S"
  #ifndef C50
  SET ORDER TO TAG "3"
  #else
  SET ORDER TO 3
  #endif
ENDIF

cFilt1 := ".t." + IF( cBrza=="D" , "" , ".and."+aUsl1 )+;
          IF(EMPTY(dDatOd).or.cPredh=="2","",".and.DATNAL>="+cm2str(dDatOd))+;
          IF(EMPTY(dDatDo),"",".and.DATNAL<="+cm2str(dDatDo))

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

IF cBrza=="D"
  HSEEK cIdFirma+qqKonto
ELSE
  HSEEK cIdFirma
ENDIF

#ifndef CAX
EOF RET
#else
EOF CRET
#endif

nStr:=0

if cBrza=="S"; m:="------- "+m; endif

START PRINT CRET

if nStr==0; AnalKZagl(); endif

nSviD:=nSviP:=nSviD2:=nSviP2:=0
do whilesc !eof() .and. IdFirma=cIdFirma

if cBrza=="D"
  if qqKonto<>IdKonto; exit; endif
endif

nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
cIdkonto:=IdKonto

if prow()>55+gPStranica; FF; AnalKZagl(); endif
? m
SELECT KONTO; HSEEK cIdKonto; select anal
if cBrza=="S"
  ? "KONTA : ",qqKonto
else
  ? "KONTO   ",cIdKonto,konto->naz
endif
? m

nDugBHD:=nPotBHD:=DugDEM:=nPotDEM:=0
fPProm:=.t.
do whilesc !eof() .and. IdFirma=cIdFirma .and. (cIdKonto==IdKonto .or. cBrza=="S")
  //********* prethodni promet *********************************
  if cPredh=="2"
   if dDatOd>datnal .and. fPProm==.t.
     nDugBHD+=DugBHD; nPotBHD+=PotBHD
     nDugDEM+=DugDEM; nPotDEM+=PotDEM
     skip; loop
   else
     if fPProm
       ? "Prethodno stanje"
       @ prow(),IF(gNW=="N".and.cPTD=="D",30+49,30) SAY nDugBHD     PICTURE PicBHD
       @ prow(),pcol()+2  SAY nPotBHD     PICTURE PicBHD
       @ prow(),pcol()+2  SAY nDugBHD-nPotBHD PICTURE PicBHD
       IF gVar1=="0"
         @ prow(),pcol()+2  SAY nDugDEM     PICTURE PicDEM
         @ prow(),pcol()+2  SAY nPotDEM     PICTURE PicDEM
         @ prow(),pcol()+2  SAY nDugDEM-nPotDEM PICTURE PicDEM
       ENDIF
     endif
     fPProm:=.f.
   endif
  endif

  IF prow()>63+gPStranica; FF; AnalKZagl();ENDIF
  IF cBrza=="S"
    @ prow()+1,3 SAY IdKonto
    @ prow(),11 SAY IdVN
    @ prow(),17 SAY BrNal
    @ prow(),24 SAY RBr
    @ prow(),29 SAY DatNal
  ELSE
    @ prow()+1,3 SAY IdVN
    @ prow(),9 SAY BrNal
    @ prow(),16 SAY RBr
    @ prow(),21 SAY DatNal
  ENDIF
  IF gNW=="N".and.cPTD=="D"
    lPom:=.f.
    SELECT SUBAN; GO TOP
    SEEK ANAL->(idfirma+idvn+brnal)
    DO WHILE !EOF() .and. ANAL->(idfirma+idvn+brnal)==idfirma+idvn+brnal
      IF ANAL->idkonto==idkonto; lPom:=.t.; EXIT; ENDIF
      SKIP 1
    ENDDO
    IF lPom
      SELECT TDOK; HSEEK SUBAN->idtipdok
    ENDIF
    SELECT ANAL
    @ prow(),30+IF(cBrza=="S",8,0) SAY IF( lPom , SUBAN->idtipdok, "??"      )
    @ prow(),pcol()+1 SAY IF( lPom , TDOK->naz      , SPACE(13) )
    @ prow(),pcol()+1 SAY IF( lPom , SUBAN->brdok   , SPACE(10) )
    nCOpis:=pcol()+1
    @ prow(),pcol()+1 SAY IF( lPom , PADR(cOpis:=ALLTRIM(SUBAN->opis),20)    , SPACE(20) )
  ENDIF
  @ prow(),IF(gNW=="N".and.cPTD=="D",30+49,30)+IF(cBrza=="S",8,0) SAY DugBHD PICTURE PicBHD
  @ prow(),pcol()+2 SAY PotBHD PICTURE picBHD
  nDugBHD+=DugBHD; nPotBHD+=PotBHD
  @ prow(),pcol()+2 SAY nDugBHD-nPotBHD PICTURE PicBHD
  IF gVar1=="0"
   @ prow(),pcol()+2 SAY DugDEM PICTURE PicDEM
   @ prow(),pcol()+2 SAY PotDEM PICTURE picDEM
   nDugDEM+=DugDEM; nPotDEM+=PotDEM
   @ prow(),pcol()+2 SAY nDugDEM-nPotDEM PICTURE PicDEM
  ENDIF
  OstatakOpisa(cOpis,nCOpis,{|| IF(prow()>61+gPStranica, EVAL({|| gPFF(),AnalKZagl()}), ) })
  SKIP
ENDDO    //  konto

IF prow()>61+gPStranica; FF; AnalKZagl(); ENDIF
? M
IF cBrza=="S"
  ? "UKUPNO ZA KONTA:"+qqKonto
ELSE
  ? "UKUPNO ZA KONTO:"+cIdKonto
ENDIF
@ prow(),IF(gNW=="N".and.cPTD=="D",30+49,30)+IF(cBrza=="S",8,0) SAY nDugBHD  PICTURE PicBHD
@ prow(),pcol()+2  SAY nPotBHD           PICTURE PicBHD
@ prow(),pcol()+2  SAY nDugBHD-nPotBHD   PICTURE PicBHD

IF gVar1=="0"
 @ prow(),pcol()+2  SAY nDugDEM           PICTURE PicDEM
 @ prow(),pcol()+2  SAY nPotDEM           PICTURE PicDEM
 @ prow(),pcol()+2  SAY nDugDEM-nPotDEM   PICTURE PicDEM
ENDIF
? M

nSviD+=nDugBHD; nSviP+=nPotBHD
nSviD2+=nDugDEM; nSviP2+=nPotDEM

if gnRazRed==99
  FF; AnalKZagl()
else
  i:=0
  do while prow()<=55+gPstranica.and.gnRazRed>i
    ?; ++i
  enddo
endif

enddo // eof()

if cBrza=="N"
 IF prow()>61+gPStranica; FF; AnalKZagl(); ENDIF
 ? M
 ? "UKUPNO ZA SVA KONTA:"
 @ prow(),IF(gNW=="N".and.cPTD=="D",30+49,30) SAY nSviD  PICTURE PicBHD
 @ prow(),pcol()+2  SAY nSviP             PICTURE PicBHD
 @ prow(),pcol()+2  SAY nSviD-nSviP       PICTURE PicBHD

 IF gVar1=="0"
  @ prow(),pcol()+2  SAY nSviD2            PICTURE PicDEM
  @ prow(),pcol()+2  SAY nSviP2            PICTURE PicDEM
  @ prow(),pcol()+2  SAY nSviD2-nSviP2     PICTURE PicDEM
 ENDIF
 ? m
endif

FF

END PRINT

#ifndef CAX
closeret
#endif
return
*}



/*! \fn AnalKZagl()
 *  \brief Zaglavlje analiticke kartice
 */

function AnalKZagl()
*{
P_COND
?? "FIN.P: ANALITICKA KARTICA  NA DAN: "; ?? DATE()
if !(empty(dDatOd) .and. empty(dDatDo))
    ?? "   ZA PERIOD OD",dDatOd,"DO",dDatDo
endif
@ prow(),125 SAY "Str."+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,"-",gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cIdFirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

SELECT ANAL

IF gVar1=="0"
 IF gNW=="N".and.cPTD=="D"
   P_COND2
 ENDIF
 ? IF(cBrza=="S","------- ","")+"------- ------ ----- --------"+IF(gNW=="N".and.cPTD=="D"," ------------------------------------------------","")+" ---------------------------------------------------- -----------------------------------------"
 ? IF(cBrza=="S","*      *","")+"*VRSTA * BROJ *REDNI* DATUM  "+IF(gNW=="N".and.cPTD=="D","*                D O K U M E N T                 ","")+"*             I Z N O S     U     "+ValDomaca()+"               *        I Z N O S     U     "+ValPomocna()+"        *"
 ? IF(cBrza=="S"," KONTO  ","")+"                             "+IF(gNW=="N".and.cPTD=="D"," ------------------------------------------------","")+" ---------------------------------------------------- -----------------------------------------"
 ? IF(cBrza=="S","*      *","")+"*NALOGA*NALOGA*BROJ *        "+IF(gNW=="N".and.cPTD=="D","*     T I P      * VEZ.BROJ *        OPIS        ","")+"*     DUGUJE     *   POTRAZUJE     *       SALDO     *   DUGUJE   *  POTRAZUJE  *    SALDO    *"
ELSE
 IF gNW=="N".and.cPTD=="D"
   P_COND
 ELSE
   F12CPI
 ENDIF
 ? IF(cBrza=="S","------- ","")+"------- ------ ----- --------"+IF(gNW=="N".and.cPTD=="D"," ------------------------------------------------","")+" -----------------------------------------------------"
 ? IF(cBrza=="S","*      *","")+"*VRSTA * BROJ *REDNI* DATUM  "+IF(gNW=="N".and.cPTD=="D","*                D O K U M E N T                 ","")+"*             I Z N O S     U     "+ValDomaca()+"               *"
 ? IF(cBrza=="S"," KONTO  ","")+"                             "+IF(gNW=="N".and.cPTD=="D"," ------------------------------------------------","")+" -----------------------------------------------------"
 ? IF(cBrza=="S","*      *","")+"*NALOGA*NALOGA*BROJ *        "+IF(gNW=="N".and.cPTD=="D","*     T I P      * VEZ.BROJ *        OPIS        ","")+"*     DUGUJE     *   POTRAZUJE     *       SALDO     *"
ENDIF
? M

RETURN
*}


