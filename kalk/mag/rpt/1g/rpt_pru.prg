#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/rpt_pru.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_pru.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/rpt_pru.prg
 *  \brief Izvjestaj "pregled poreza na RUC"
 */


/*! \fn RekPorMag()
 *  \brief Izvjestaj "pregled poreza na RUC"
 */

function RekPorMag()
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
Box(,5,75)
 set cursor on
 do while .t.
  @ m_x+1,m_y+2 SAY "Magacinski konto " GET qqKonto pict "@!S50"
  @ m_x+2,m_y+2 SAY "Artikli          " GET qqRoba  pict "@!S50"
  @ m_x+3,m_y+2 SAY "Kupci            " GET qqPartn pict "@!S50"
  @ m_x+4,m_y+2 SAY "Kalkulacije (14,15,94) od datuma:" GET dDat1
  @ m_x+4,col()+1 SAY "do" GET dDat2
  @ m_x+5,m_y+2 SAY "U izvjestaj ulaze dokum. sa negativnom RUC D/N ?" GET cNRUC valid cnruc $"DN" pict "@!"
  read;ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"MKonto")
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
                ".and."+aUsl1+".and."+aUsl2+".and."+aUsl3+;
                ".and.(IDVD $ '14#15#94')"

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

go top   // samo  zaduz prod. i povrat iz prod.

M:="------------ ------------- ------------- ------------- ---------- ---------- ---------- ----------"

START PRINT CRET


n1:=n2:=n3:=n5:=n5b:=n6:=0

cVT:=.f.

DO WHILE !EOF() .and. IspitajPrekid()
  B:=0
  cIdFirma:=KALK->IdFirma
  Preduzece()
  P_COND
  ? "KALK: PREGLED POREZA NA RUC PO TARIFNIM BROJEVIMA ZA PERIOD OD",dDat1,"DO",dDAt2,"      NA DAN:",DATE()

  aUsl2:=Parsiraj(qqRoba,"IdRoba")
  aUsl3:=Parsiraj(qqPartn,"IdPartner")
  if len(aUsl2)>0
    ? "Kriterij za Artikle:",trim(qqRoba)
  endif
  if len(aUsl3)>0
    ? "Kriterij za Kupce:",trim(qqPartn)
  endif

  ?
  ? m
  if gVarVP=="1"
   ? "*     TARIF *      NV     *   VPV - RAB *  VPV - NV   *  POREZ   *  POREZ   *RUC-PRUC *   VPV    *"
   ? "*     BROJ  *             *             *    (RUC)    *     %    *  (PRUC)  *         *  SA POR  *"
  else
   ? "*     TARIF *      NV     *   VPV - RAB *  POREZ      *   RUC    *  POREZ   *RUC+PRUC *   VPV    *"
   ? "*     BROJ  *             *             *     %       *          *  (PRUC)  *(VPV-NV) *          *"
  endif
  ? m
  nT1:=nT2:=nT3:=nT5:=nT5B:=nT6:=0
  DO WHILE !EOF() .AND. cIdFirma==KALK->IdFirma .and. IspitajPrekid()
     cIdKonto:=IdKonto
     cIdTarifa:=IdTarifa
     select tarifa; hseek cidtarifa
     select kalk
     nVPP:=TARIFA->VPP
     nVPV:=nNV:=0
     nVPVN:=nNVN:=0
     DO WHILE !EOF() .AND. cIdFirma==IdFirma .and. cIdtarifa==IdTarifa .and. IspitajPrekid()

        select KALK

        
        
        *FUNKCIJA VTPOREZI()
        *if roba->tip=="V"
        *  public _OPP:=0,_PPP:=tarifa->ppp/100
        *  public _PORVT:=tarifa->opp/100
        *elseif roba->tip=="K"
        *  public _OPP:=tarifa->opp/100,_PPP:=tarifa->ppp/100
        *  public _PORVT:=tarifa->opp/100
        *else
        *  public _OPP:=tarifa->opp/100,_PPP:=tarifa->ppp/100
        *  public _PORVT:=0
        *endif
        *RETURN

        select roba; hseek kalk->idroba; select kalk
        VtPorezi()
        if _PORVT<>0
           cVT:=.t.
        endif

        if VPC/(1+_PORVT)*(1-RabatV/100)-NC>=0 .or. cNRUC=="D"     // u osnovicu ulazi pozitivna marza!!!
          if idvd=="14"
            nNV+=NC*(Kolicina)
            nVPV+=VPC/(1+_PORVT)*(1-RabatV/100)*(Kolicina)
          elseif idvd=="15"
            nNV+=NC*(-Kolicina)
            nVPV+=VPC/(1+_PORVT)*(1-RabatV/100)*(-Kolicina)
          else
            nNV-=NC*(Kolicina)
            nVPV-=VPC/(1+_PORVT)*(1-RabatV/100)*(Kolicina)
          endif
        endif

        skip
     ENDDO // tarifa

     if prow()>61+gPStranica; FF; endif
     if gVarVP=="1"
       nPorez:=(nVPV-nNV)*nVPP/100
     else
       nPorez:=(nVPV-nNV)*nVPP/100/(1+nVPP/100)
     endif
     @ prow()+1,0        SAY space(6)+cIdTarifa
     nCol1:=pcol()+4
      @ prow(),pcol()+4   SAY n1:=nNV         PICT   PicDEM
      @ prow(),pcol()+4   SAY n2:=nVPV        PICT   PicDEM
     if gVarVP=="1"
      @ prow(),pcol()+4   SAY n3:=nVPV-nNV    PICT   PicDEM
      @ prow(),pcol()+1   SAY nVPP            PICT   PicProc
      @ prow(),pcol()+1   SAY n5:=nPorez      PICT   PicDEM
      @ prow(),pcol()+1   SAY n5b:=nVPV-nNV-nPorez      PICT   PicDEM
      @ prow(),pcol()+1   SAY n6:=nVPV+nPorez PICTURE   PicDEM
     else
      @ prow(),pcol()+4   SAY nVPP            PICT   PicProc
      @ prow(),pcol()+1   SAY n5b:=nVPV-nNV-nPorez    PICT   PicDEM
      @ prow(),pcol()+1   SAY n5:=nPorez      PICT   PicDEM
      @ prow(),pcol()+1   SAY n3:=nVPV-nNV    PICT   PicDEM
      @ prow(),pcol()+1   SAY n6:=nVPV PICTURE   PicDEM
     endif
     nT1+=n1;  nT2+=n2;  nT3+=n3;  nT5+=n5; nT5b+=n5b
     nT6+=n6
  ENDDO // konto

  if prow()>60+gPStranica; FF; endif
  ? m
  ? "UKUPNO:"
  @ prow(),nCol1     SAY  nT1     pict picdem
  @ prow(),pcol()+4  SAY  nT2     pict picdem
  if gVarVP=="1"
    @ prow(),pcol()+4  SAY  nT3     pict picdem
    @ prow(),pcol()+1  SAY  SPACE(LEN(PICPROC))
    @ prow(),pcol()+1  SAY  nT5     pict picdem
    @ prow(),pcol()+1  SAY  nT5b    pict picdem
    @ prow(),pcol()+1  SAY  nT6     pict picdem
  else
    @ prow(),pcol()+4  SAY  SPACE(LEN(PICPROC))
    @ prow(),pcol()+1  SAY  nT5b    pict picdem
    @ prow(),pcol()+1  SAY  nT5     pict picdem
    @ prow(),pcol()+1  SAY  nT3     pict picdem
    @ prow(),pcol()+1  SAY  nT2     pict picdem
  endif
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
