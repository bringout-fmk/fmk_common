#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/rpt_rpp.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_rpp.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/rpt_rpp.prg
 *  \brief Izvjestaj "pregled poreza na promet u veleprodaji"
 */


/*! \fn RekPorNap()
 *  \brief Izvjestaj "pregled poreza na promet u veleprodaji"
 */

function RekPorNap()
*{
local nT0:=nT1:=nT2:=nT3:=nT4:=0
local nCol1:=0
local PicCDEM:=gPicCDEM       // "999999.999"
local PicProc:=gPicProc       // "999999.99%"
local PicDEM:=gPicDEM         // "9999999.99"
local Pickol:=gPicKol         // "999999.999"

if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK
   O_SIFV
endif
O_ROBA
O_TARIFA
O_PARTN

dDat1:=dDat2:=ctod("")
cIdFirma:=gFirma
qqKonto:=padr("1310;",60)
cPRUC:="N"
Box(,5,75)
 set cursor on
 do while .t.
  if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  else
   @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
  endif
  @ m_x+2,m_y+2 SAY "Magacinski konto:" GET qqKonto pict "@!S50"
  @ m_x+4,m_y+2 SAY "Kalkulacije (14,15,94) od datuma:" GET dDat1
  @ m_x+4,col()+1 SAY "do" GET dDat2
  @ m_x+5,m_y+2 SAY "Prikaz poreza na RUC" GET cPRUC valid cPRUC $ "DN" pict "@!"
  read;ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"MKonto")
  if aUsl1<>NIL; exit; endif
 enddo
BoxC()

O_TARIFA
O_KALK;  set order to 1 //idFirma+IdVD+BrDok+RBr

private cFilt1:=""

cFilt1 := ".t."+IF(EMPTY(dDat1),"",".and.DATDOK>="+cm2str(dDat1))+;
                IF(EMPTY(dDat2),"",".and.DATDOK<="+cm2str(dDat2))+;
                ".and."+aUsl1+".and.(IDVD $ '14#15#94')"

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

hseek cidfirma
EOF CRET

M:="----------- -------- ---------- -------- ------ ------------- ------------- --------------"

START PRINT CRET

B:=0
Preduzece()
P_COND
? "KALK: PREGLED POREZA NA PROMET (VELEPRODAJA) ZA PERIOD",dDat1,"DO",dDAt2,"      NA DAN:",DATE()
if cPRUC=="D"
? "      SA PREGLEDOM POREZA NA RUC"
m:="----------- -------- ---------- -------- ------ ------------- ------------- ------------- ------------- ------------- -------------"
endif

?
? m
if cPRUC=="N"
 ? "* Dokument *  Datum *  Faktura/otpremn. *Tarifa*     VPV     *    POREZ    *    POREZ    *"
 ? "*          *        *   Broj   *  Datum *      *             *      %      *             *"
else
 ? "* Dokument *  Datum *  Faktura/otpremn. *Tarifa*     NV      *     VPV     *   Osnovica  *   Porez na  *     PPP    *    POREZ    *"
 ? "*          *        *   Broj   *  Datum *      *             *             *   P.na RUC  *     RUC     *      %     *             *"
endif
? m

nVPV:=nNV:=nVPVBP:=nPRUC:=0
DO WHILE !EOF() .and. idfirma==cidfirma .and. IspitajPrekid()

     IF idvd=="15"
       nVPV := VPC*(1-RabatV/100)*(-Kolicina)
       nNV  := nc*(-kolicina)
     ELSE
       nVPV := VPC*(1-RabatV/100)*(Kolicina)
       nNV  := nc*kolicina
     ENDIF

     select roba
     select roba; hseek kalk->idroba
     select tarifa; hseek kalk->idtarifa; select kalk
     VtPorezi()
     nVPVBP:=nVPV/(1+_PORVT)

     if prow()>60+gPStranica; FF; endif
     IF ROUND(_PORVT,6)==0
        nPPProc:=mpc
     else
        nPPProc:=_PORVT*100
     ENDIF

     if round(nPPProc,6)<>0 .or. cPRuc=="D"
      ? idvd+"-"+brdok, datdok,brfaktp,datfaktp,idtarifa
      nCol1:=pcol()+4
      if idvd=="14" .or. idvd=="15"
        if cPRUC=="D"
          @ prow(),pcol()+4   SAY nNV      PICT   PicDEM
        endif
        @ prow(),pcol()+4   SAY nVPV      PICT   PicDEM
        if cPRuc=="D"
          @ prow(),pcol()+4   SAY nVPVBP-nNV pict picdem
          if gVarVP=="1"
              nPRUC:=(nVPVBP-nNV)*tarifa->VPP/100
          else
              nPRUC:=(nVPVBP-nNV)*tarifa->VPP/100/(1+tarifa->VPP/100)
          endif
          if nPRUC<0
             nPRUC:=0
          endif
          @ prow(),pcol()+4   SAY nPRUC  pict picdem
        endif
        nPorez:=nVPVBP*nPPProc/100
        @ prow(),pcol()+4   SAY nPPProc       PICT   PicProc
        @ prow(),pcol()+4   SAY nPorez    PICT   PicDEM
        nT1+=nVPV;  nT2+=nPorez
        nT3+=(nVPVBP-nNV); nT4+=nPRUC
        nT0+=nNV
      else
        if cPRUC=="D"
          @ prow(),pcol()+4   SAY -nNV      PICT   PicDEM
        endif
        @ prow(),pcol()+4   SAY -nVPV      PICT   PicDEM
        if cPRuc=="D"
          @ prow(),pcol()+4   SAY -(nVPVBP-nNV) pict picdem
          if gVarVP=="1"
              nPRUC:=-(nVPVBP-nNV)*tarifa->VPP/100
          else
              nPRUC:=-(nVPVBP-nNV)*tarifa->VPP/100/(1+tarifa->VPP/100)
          endif
          if nPRUC>0
             nPRUC:=0
          endif
          @ prow(),pcol()+4   SAY nPRUC  pict picdem
        endif
        @ prow(),pcol()+4   SAY -mpc       PICT   PicProc
        @ prow(),pcol()+4   SAY -nPorez    PICT   PicDEM
        nT1-=nVPV;  nT2-=nPorez
        nT3+=-(nVPVBP-nNV); nT4+=nPRUC
        nT0-=nNV
      endif
     endif
     skip

ENDDO // eof

  ? m
  ? "UKUPNO:"
  @ prow(),nCol1-4 SAY ""
  if cPRUC=="D"
          @ prow(),pcol()+4   SAY nT0      PICT   PicDEM
  endif
  @ prow(),pcol()+4     SAY  nT1     pict picdem
  if cPRUC=="D"
          @ prow(),pcol()+4   SAY nT3      PICT   PicDEM
          @ prow(),pcol()+4   SAY nT4      PICT   PicDEM
  endif
  @ prow(),pcol()+4  SAY  SPACE(LEN(PICPROC))
  @ prow(),pcol()+4  SAY  nT2     pict picdem
  ? m

FF

END PRINT

closeret
return
*}
