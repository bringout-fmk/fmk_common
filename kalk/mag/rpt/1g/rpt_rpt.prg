#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/rpt_rpt.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_rpt.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/rpt_rpt.prg
 *  \brief Izvjestaj "rekapitulacija prometa u magacinu po tarifama"
 */


/*! \fn RekMagTar()
 *  \brief Izvjestaj "rekapitulacija prometa u magacinu po tarifama"
 */

function RekMagTar()
*{
local  nT1:=nT4:=nT5:=nT6:=nT7:=0
local  nTT1:=nTT4:=nTT5:=nTT6:=nTT7:=0
local  n1:=n4:=n5:=n6:=n7:=0
local  nCol1:=0
local   PicCDEM:=gPicCDEM       // "999999.999"
local   PicProc:=gPicProc       // "999999.99%"
local   PicDEM:=gPicDEM         // "9999999.99"
local   Pickol:=gPicKol         // "999999.999"

dDat1:=dDat2:=ctod("")
qqKonto:=padr("1310;",60)
qqPartn:=qqRoba:=space(60)
cNRUC:="N"
Box(,5,70)
 set cursor on
 do while .t.
  @ m_x+1,m_y+2 SAY "Magacinski konto   " GET qqKonto pict "@!S50"
  @ m_x+2,m_y+2 SAY "Artikli            " GET qqRoba  pict "@!S50"
  @ m_x+3,m_y+2 SAY "Partneri           " GET qqPartn pict "@!S50"
  @ m_x+4,m_y+2 SAY "Izvjestaj za period" GET dDat1
  @ m_x+4,col()+1 SAY "do" GET dDat2
  read;ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"mkonto")
  aUsl2:=Parsiraj(qqRoba,"IdRoba")
  aUsl3:=Parsiraj(qqPartn,"IdPartner")
  if aUsl1<>NIL; exit; endif
 enddo
BoxC()

set softseek off
if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK;O_SIFV
endif
O_ROBA
O_TARIFA
O_KALK;  set order to 6
//CREATE_INDEX("6","idFirma+IDTarifa+idroba",KUMPATH+"KALK")

private cFilt1:=""

cFilt1 := ".t."+IF(EMPTY(dDat1),"",".and.DATDOK>="+cm2str(dDat1))+;
                IF(EMPTY(dDat2),"",".and.DATDOK<="+cm2str(dDat2))+;
                ".and."+aUsl1+".and."+aUsl2+".and."+aUsl3

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

go top   // samo  zaduz prod. i povrat iz prod.

M:="------------ ----------- ----------- ----------- ----------- ----------- ----------- ----------- -----------"

START PRINT CRET


n1:=n2:=n3:=n5:=n5b:=n6:=0

cVT:=.f.

DO WHILE !EOF() .and. IspitajPrekid()
  B:=0
  cIdFirma:=KALK->IdFirma
  Preduzece()
  P_COND
  ? "KALK: REKAPITULACIJA PROMETA PO TARIFAMA ZA PERIOD OD",dDat1,"DO",dDAt2,"      NA DAN:",DATE()

  aUsl2:=Parsiraj(qqRoba,"IdRoba")
  aUsl3:=Parsiraj(qqPartn,"IdPartner")
  if len(aUsl2)>0
    ? "Kriterij za Artikle :",trim(qqRoba)
  endif
  if len(aUsl3)>0
    ? "Kriterij za Partnere:",trim(qqPartn)
  endif

  ?
  ? m
  ? "*  TARIF   *  NV DUG    *  NV POT   *   NABAV.  *  VPV DUG  *  VPV POT  *  RABAT    *  VPV POT  *   VPV    *"
  ? "*   BROJ   *            *           *     VR    *           *           *           *  - RABAT  *  SALDO   *"
  ? m
  nT1:=nT2:=nT3:=nT4:=nT5:=nT6:=nT7:=nT8:=0
  DO WHILE !EOF() .AND. cIdFirma==KALK->IdFirma .and. IspitajPrekid()
     cIdKonto:=IdKonto
     cIdTarifa:=IdTarifa
     select tarifa; hseek cidtarifa
     select kalk
     nVPP:=TARIFA->VPP
     nNVD:=nNVP:=0
     nVPVD:=nVPVP:=0
     nRabatV:=0
     DO WHILE !EOF() .AND. cIdFirma==IdFirma .and. cIdtarifa==IdTarifa .and. IspitajPrekid()

        select KALK

        select roba; hseek kalk->idroba; select kalk
        VtPorezi()
        if _PORVT<>0
           cVT:=.t.
        endif

        if mu_i=="1"
            nNVD+=NC*(Kolicina-GKolicina-gKolicin2)
            nVPVD+=VPC/(1+_PORVT)*(Kolicina-GKolicina-gKolicin2)
        elseif mu_i=="3"
            nVPVD+=VPC/(1+_PORVT)*(Kolicina-GKolicina-gKolicin2)
        elseif mu_i=="5"
           nVPVP+=VPC/(1+_PORVT)*(Kolicina)
           nRabatV+=VPC*RabatV/100*kolicina
        endif

        skip
     ENDDO // tarifa

     if prow()>61+gPStranica; FF; endif
     @ prow()+1,0        SAY space(6)+cIdTarifa
     nCol1:=pcol()+2
     @ prow(),nCol1      SAY n1:=nNVD         PICT   PicDEM
     @ prow(),pcol()+2   SAY n2:=nNVP         PICT   PicDEM
     @ prow(),pcol()+2   SAY n3:=nNVD-nNVP    PICT   PicDEM
     @ prow(),pcol()+2   SAY n4:=nVPVD        PICT   PicDEM
     @ prow(),pcol()+2   SAY n5:=nVPVP        PICT   PicDEM
     @ prow(),pcol()+2   SAY n6:=nRabatV       PICT   PicDEM
     @ prow(),pcol()+2   SAY n7:=nVPVP-nRabatV PICT   PicDEM
     @ prow(),pcol()+2   SAY n8:=nVPVD-nVPVP  PICT   PicDEM
     nT1+=n1;  nT2+=n2;  nT3+=n3; nT4+=n4;  nT5+=n5
     nT6+=n6;  nT7+=n7
     nT8+=n8

  ENDDO // konto

  if prow()>60+gPStranica; FF; endif
  ? m
  ? "UKUPNO:"
  @ prow(),nCol1     SAY  nT1     pict picdem
  @ prow(),pcol()+2  SAY  nT2     pict picdem
  @ prow(),pcol()+2  SAY  nT3     pict picdem
  @ prow(),pcol()+2  SAY  nT4     pict picdem
  @ prow(),pcol()+2  SAY  nT5     pict picdem
  @ prow(),pcol()+2  SAY  nT6     pict picdem
  @ prow(),pcol()+2  SAY  nT7     pict picdem
  @ prow(),pcol()+2  SAY  nT8     pict picdem
  ? m

ENDDO // eof

if cVT
  ?
  ? "Napomena: Za robu visoke tarife VPV je prikazana umanjena za iznos poreza"
  ? "koji je ukalkulisan u cijenu ( jer ta umanjena vrijednost odredjuje osnovicu)"
endif
?
FF

END PRINT

set softseek on
closeret
return
*}
