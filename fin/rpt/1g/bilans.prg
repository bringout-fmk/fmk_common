#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rpt/1g/bilans.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: bilans.prg,v $
 * Revision 1.4  2004/01/13 19:07:56  sasavranic
 * appsrv konverzija
 *
 * Revision 1.3  2003/01/27 00:43:52  mirsad
 * ispravke BUG-ova
 *
 * Revision 1.2  2002/06/20 11:31:07  sasa
 * no message
 *
 *
 */
 

/*! \file fmk/fin/rpt/1g/bilans.prg
 *  \brief Bilans stanja bilans ....
 */
 
/*! \fn Bilans()
 *  \brief Menij bilansa
 */
 
function Bilans()
*{
cSecur:=SecurR(KLevel,"BBilans")
if ImaSlovo("X",cSecur)
   MsgBeep("Opcija nedostupna !")
   closeret
endif


IF gVar1=="0"
 private opc[5],Izbor
ELSE
 private opc[4],Izbor
ENDIF

cTip:=ValDomaca()

M6:= "--------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
M7:= "*        *          POｬETNO STANJE       *         TEKU終 PROMET         *        KUMULATIVNI PROMET     *            SALDO             *"
M8:= "  KLASA   ------------------------------- ------------------------------- ------------------------------- -------------------------------"
M9:= "*        *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *    POTRAｦUJE *"
M10:="--------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"

opc[1]:="1. po grupama       "
opc[2]:="2. sintetika"
opc[3]:="3. analitika"
opc[4]:="4. subanalitika"
IF gVar1=="0"; opc[5]:="5. obracun: "+cTip; h[5]:=""; ENDIF
h[1]:=h[2]:=h[3]:=h[4]:=""


Izbor:=1
private PicD:=FormPicL(gPicBHD,15)
DO WHILE .T.
   Izbor:=Menu("bb",opc,Izbor,.f.)
   DO CASE
      CASE Izbor==0
         EXIT

      CASE izbor=1
         cBBV:=cTip; nBBK:=1
         GrupBB()

      CASE izbor=2
         cBBV:=cTip; nBBK:=1
         SintBB()

      CASE izbor=3
         cBBV:=cTip; nBBK:=1
         AnalBB()

      CASE izbor=4
         cBBV:=cTip; nBBK:=1
         SubAnBB()

      CASE izbor=5
         if cTip==ValDomaca()
           PicD:=FormPicL(gPicDEM,15)
           cTip:=ValPomocna()
         else
           PicD:=FormPicL(gPicBHD,15)
           cTip:=ValDomaca()
         endif
         opc[5]:="5. obracun: "+cTip

      CASE izbor=5
         Izbor:=0
   ENDCASE
ENDDO

#ifndef CAX
closeret
#endif

return
*}



/*! \fn SubAnBB()
 *  \brief Subanaliticki bruto bilans
 */
 
function SubAnBB()
*{
cIdFirma:=gFirma

O_KONTO
O_PARTN

qqKonto:=space(100)
dDatOd:=dDatDo:=ctod("")
private cFormat:="2",cPodKlas:="N",cNule:="D"
Box("sanb",9,60)
set cursor on

do while .t.
 @ m_x+1,m_y+2 SAY "SUBANALITICKI BRUTO BILANS"
 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| EMPTY(cIdFirma).or.P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Konto " GET qqKonto    pict "@!S50"
 @ m_x+4,m_y+2 SAY "Od datuma :" get dDatOD
 @ m_x+4,col()+2 SAY "do" GET dDatDo
 @ m_x+6,m_y+2 SAY "Format izvjestaja A3/A4 (1/2)" GET cFormat
 @ m_x+7,m_y+2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas$"DN" PICT "@!"
 @ m_x+8,m_y+2 SAY "Prikaz stavki sa saldom 0 D/N " GET cNule valid cnule $"DN" pict "@!"
 cIdRJ:=""
 IF gRJ=="D"
   cIdRJ:="999999"
   @ m_x+9,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 READ;ESC_BCR
 aUsl1:=Parsiraj(qqKonto,"IdKonto")
 if aUsl1<>NIL; exit; endif
enddo

BoxC()

cidfirma:=trim(cidfirma)

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

IF cFormat=="1"
 private REP1_LEN:=236
 th1:= "---- ------- -------- --------------------------------------------------- -------------- ----------------- --------------------------------- ------------------------------- ------------------------------- -------------------------------"
 th2:= "*R. * KONTO *PARTNER *     NAZIV KONTA ILI PARTNERA                      *    MJESTO    *      ADRESA     *        POｬETNO STANJE           *         TEKU終 PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
 th3:= "                                                                                                           --------------------------------- ------------------------------- ------------------------------- -------------------------------"
 th4:= "*BR.*       *        *                                                   *              *                 *    DUGUJE       *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *   POTRAｦUJE  *"
 th5:= "---- ------- -------- --------------------------------------------------- -------------- ----------------- ----------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
ELSE
 private REP1_LEN:=158
 th1:= "---- ------- -------- -------------------------------------- --------------------------------- ------------------------------- -------------------------------"
 th2:= "*R. * KONTO *PARTNER *    NAZIV KONTA ILI PARTNERA          *        POｬETNO STANJE           *       KUMULATIVNI PROMET      *            SALDO             *"
 th3:= "                                                             --------------------------------- ------------------------------- -------------------------------"
 th4:= "*BR.*       *        *                                      *    DUGUJE       *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *   POTRAｦUJE  *"
 th5:= "---- ------- -------- -------------------------------------- ----------------- --------------- --------------- --------------- --------------- ---------------"
ENDIF

O_SUBAN
O_KONTO
#ifndef CAX
O_BBKLAS
#endif

#ifndef CAX
select BBKLAS; ZAP
#endif

private cFilter:=""

select SUBAN

if gRj=="D" .and. len(cIdrj)<>0
  cFilter+=iif(empty(cFilter),"",".and.") + "idrj="+cm2str(cidrj)
endif

if aUsl1<>".t."
 cFilter+=iif(empty(cFilter),"",".and.")+ aUsl1
endif
if !(empty(dDatOd) .and. empty(dDatDo))
#ifdef CAX
 cFilter+=iif(empty(cFilter),"",".and.")+"Datdok>="+aofVarToString(dDatOd)+".and.DatDok<="+aofVarToString(dDatDo)
#else
 cFilter+=iif(empty(cFilter),"",".and.")+"DATDOK>=CTOD('"+dtoc(dDatOd)+"') .and. DATDOK<=CTOD('"+dtoc(dDatDo)+"')"
#endif
endif

if !empty(cFilter) .and. LEN(cIdFirma)==2
#ifdef CAX
  //aofSetFilter(cFilter)
  AX_SetServerAOF(cFilter,.f.)

#else
  set filter to &cFilter
#endif
endif

#ifdef PROBA
  @ 20,1 SAY cFilter
#ifdef CAX
  msg("Opt level je :"+str(AX_GetAOFoptlevel(),2))
#endif
  altd()
#endif

if LEN(cIdFirma)<2
  SELECT SUBAN
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
  cSort1:="IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr"
  INDEX ON &cSort1 TO "SUBTMP" FOR &cFilt EVAL(TekRec2()) EVERY 1
  GO TOP
  BoxC()
else
  HSEEK cIdFirma
endif

EOF CRET

nStr:=0

BBMnoziSaK()

START PRINT CRET

B:=B1:=B2:=0  // brojaci

select SUBAN

D1S:=D2S:=D3S:=D4S:=0
P1S:=P2S:=P3S:=P4S:=0

D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=0
nCol1:=50
DO WHILESC !EOF() .AND. IdFirma=cIdFirma   // idfirma

   IF prow()==0; ZaglSan(); ENDIF

   // PS - pocetno stanje, TP - tekuci promet, KP - kumulativni promet, S - saldo
   D3PS:=P3PS:=  D3TP:=P3TP:=  D3KP:=P3KP:=  D3S:=P3S:=  0
   cKlKonto:=left(IdKonto,1)
   DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1)   // klasa konto

      cSinKonto:=left(IdKonto,3)
      D2PS:=P2PS:=D2TP:=P2TP:=D2KP:=P2KP:=D2S:=P2S:=0
      DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cSinKonto==left(IdKonto,3)   // sin konto

         cIdKonto:=IdKonto
         D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
         DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cIdKonto==IdKonto // konto

            cIdPartner:=IdPartner
            D0PS:=P0PS:=D0TP:=P0TP:=D0KP:=P0KP:=D0S:=P0S:=0
            DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner // partner
              if cTip==ValDomaca()
               IF D_P="1"; D0KP+=IznosBHD*nBBK; ELSE; P0KP+=IznosBHD*nBBK;ENDIF
              else
               IF D_P="1"; D0KP+=IznosDEM; ELSE; P0KP+=IznosDEM;ENDIF
              endif

              if cTip==ValDomaca()
               IF IdVN="00"
                  IF D_P=="1"; D0PS+=IznosBHD*nBBK; ELSE; P0PS+=IznosBHD*nBBK; ENDIF
               ELSE
                  IF D_P=="1"; D0TP+=IznosBHD*nBBK; ELSE; P0TP+=IznosBHD*nBBK; ENDIF
               ENDIF
              else
               IF IdVN="00"
                  IF D_P=="1"; D0PS+=IznosDEM; ELSE; P0PS+=IznosDEM; ENDIF
               ELSE
                  IF D_P=="1"; D0TP+=IznosDEM; ELSE; P0TP+=IznosDEM; ENDIF
               ENDIF
              endif

              SKIP
            ENDDO // partner

            IF prow()>61+gpStranica;FF;ZaglSan();ENDIF

            IF cNule=="N" .and.  round(D0KP-P0KP,2)==0
               // ne prikazuj
            else
               @ prow()+1,0 SAY  ++B  PICTURE '9999'    // ; ?? "."
               @ prow(),pcol()+1 SAY cIdKonto
               @ prow(),pcol()+1 SAY cIdPartner       // IdPartner(cIdPartner)
               SELECT PARTN; HSEEK cIdPartner
               IF cFormat=="2"
                @ prow(),pcol()+1 SAY PADR(naz,48-LEN (cidpartner))   // difidp
               ELSE
                @ prow(),pcol()+1 SAY naz
                @ prow(),pcol()+1 SAY naz2
                @ prow(),pcol()+1 SAY Mjesto
                @ prow(),pcol()+1 SAY Adresa PICTURE 'XXXXXXXXXXXXXXXXX'
               ENDIF
               select SUBAN
               nCol1:=pcol()+1
               @ prow(),pcol()+1 SAY D0PS PICTURE PicD
               @ prow(),PCOL()+1 SAY P0PS PICTURE PicD
               IF cFormat=="1"
                @ prow(),PCOL()+1 SAY D0TP PICTURE PicD
                @ prow(),PCOL()+1 SAY P0TP PICTURE PicD
               ENDIF
               @ prow(),PCOL()+1 SAY D0KP PICTURE PicD
               @ prow(),PCOL()+1 SAY P0KP PICTURE PicD
               D0S:=D0KP-P0KP
               IF D0S>=0; P0S:=0; else; P0S:=-D0S; D0S:=0; endif
               @ prow(),PCOL()+1 SAY D0S PICTURE PicD
               @ prow(),PCOL()+1 SAY P0S PICTURE PicD

               D1PS+=D0PS;P1PS+=P0PS;D1TP+=D0TP;P1TP+=P0TP;D1KP+=D0KP;P1KP+=P0KP
             endif
         ENDDO // konto

         IF prow()>59+gpStranica;FF;ZaglSan();ENDIF

         @ prow()+1,2 SAY replicate("-",REP1_LEN-2)
         @ prow()+1,2 SAY ++B1 PICTURE '9999'      // ; ?? "."
         @ prow(),pcol()+1 SAY cIdKonto
         select KONTO; HSEEK cIdKonto
         IF cFormat=="1"
          @ prow(),pcol()+1 SAY naz
         ELSE
          @ prow(),pcol()+1 SAY LEFT (naz,47)  // 40
         ENDIF
         select SUBAN

         @ prow(),nCol1     SAY D1PS PICTURE PicD
         @ prow(),PCOL()+1  SAY P1PS PICTURE PicD
         IF cFormat=="1"
          @ prow(),PCOL()+1  SAY D1TP PICTURE PicD
          @ prow(),PCOL()+1  SAY P1TP PICTURE PicD
         ENDIF
         @ prow(),PCOL()+1  SAY D1KP PICTURE PicD
         @ prow(),PCOL()+1  SAY P1KP PICTURE PicD
         D1S:=D1KP-P1KP
         if D1S>=0
           P1S:=0
           D2S+=D1S;D3S+=D1S;D4S+=D1S
         else
           P1S:=-D1S; D1S:=0
           P2S+=P1S;P3S+=P1S;P4S+=P1S
         endif
         @ prow(),PCOL()+1 SAY D1S PICTURE PicD
         @ prow(),PCOL()+1 SAY P1S PICTURE PicD
         @ prow()+1,2 SAY replicate("-",REP1_LEN-2)

         SELECT SUBAN
         D2PS+=D1PS;P2PS+=P1PS;D2TP+=D1TP;P2TP+=P1TP;D2KP+=D1KP;P2KP+=P1KP

      ENDDO  // sin konto

      IF prow()>61+gpStranica; FF ;ZaglSan();ENDIF

      @ prow()+1,4 SAY replicate("=",REP1_LEN-4)
      @ prow()+1,4 SAY ++B2 PICTURE '9999';?? "."
      @ prow(),pcol()+1 SAY cSinKonto
      select KONTO; hseek cSinKonto
      IF cFormat=="1"
       @ prow(),pcol()+1 SAY left(naz,50)
      ELSE
       @ prow(),pcol()+1 SAY left(naz,44)       // 45
      ENDIF
      select SUBAN
      @ prow(),nCol1    SAY D2PS PICTURE PicD
      @ prow(),PCOL()+1 SAY P2PS PICTURE PicD
      IF cFormat=="1"
       @ prow(),PCOL()+1 SAY D2TP PICTURE PicD
       @ prow(),PCOL()+1 SAY P2TP PICTURE PicD
      ENDIF
      @ prow(),PCOL()+1 SAY D2KP PICTURE PicD
      @ prow(),PCOL()+1 SAY P2KP PICTURE PicD
      @ prow(),PCOL()+1 SAY D2S PICTURE PicD
      @ prow(),PCOL()+1 SAY P2S PICTURE PicD
      @ prow()+1,4 SAY replicate("=",REP1_LEN-4)

      SELECT SUBAN

      D3PS+=D2PS;P3PS+=P2PS;D3TP+=D2TP;P3TP+=P2TP;D3KP+=D2KP;P3KP+=P2KP


  ENDDO  // klasa konto

#ifndef CAX
   SELECT BBKLAS
   APPEND BLANK
   REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S
#endif
   SELECT SUBAN
   IF cPodKlas=="D"
    ? th5
    ? "UKUPNO KLASA "+cklkonto
    @ prow(),nCol1    SAY D3PS PICTURE PicD
    @ PROW(),pcol()+1 SAY P3PS PICTURE PicD
    if cFormat=="1"
      @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
      @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
    endif
    @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY D3S PICTURE PicD
    @ PROW(),pcol()+1 SAY P3S PICTURE PicD
    ? th5
   ENDIF
   D4PS+=D3PS;P4PS+=P3PS;D4TP+=D3TP;P4TP+=P3TP;D4KP+=D3KP;P4KP+=P3KP

ENDDO

IF prow()>59+gpStranica;FF;ZaglSan();ENDIF

? th5
@ prow()+1,6 SAY "UKUPNO:"
@ prow(),nCol1 SAY D4PS PICTURE PicD
@ prow(),PCOL()+1 SAY P4PS PICTURE PicD
IF cFormat=="1"
 @ prow(),PCOL()+1 SAY D4TP PICTURE PicD
 @ prow(),PCOL()+1 SAY P4TP PICTURE PicD
ENDIF
@ prow(),PCOL()+1 SAY D4KP PICTURE PicD
@ prow(),PCOL()+1 SAY P4KP PICTURE PicD
@ prow(),PCOL()+1 SAY D4S PICTURE PicD
@ prow(),PCOL()+1 SAY P4S PICTURE PicD
? th5

if prow()>55+gpStranica; FF; ELSE; ?;?; endif

#ifndef CAX
?? "REKAPITULACIJA PO KLASAMA NA DAN:"; @ PROW(),PCOL()+2 SAY DATE()
? M6
? M7
? M8
? M9
? M10

SELECT BBKLAS
GO TOP
nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()
   if prow()>63+gpStranica; FF; endif
   @ prow()+1,4      SAY IdKlasa
   @ prow(),10       SAY PocDug               PICTURE PicD
   @ prow(),PCOL()+1 SAY PocPot               PICTURE PicD
   @ prow(),PCOL()+1 SAY TekPDug              PICTURE PicD
   @ prow(),PCOL()+1 SAY TekPPot              PICTURE PicD
   @ prow(),PCOL()+1 SAY KumPDug              PICTURE PicD
   @ prow(),PCOL()+1 SAY KumPPot              PICTURE PicD
   @ prow(),PCOL()+1 SAY SalPDug              PICTURE PicD
   @ prow(),PCOL()+1 SAY SalPPot              PICTURE PicD

   nPocDug   += PocDug
   nPocPot   += PocPot
   nTekPDug  += TekPDug
   nTekPPot  += TekPPot
   nKumPDug  += KumPDug
   nKumPPot  += KumPPot
   nSalPDug  += SalPDug
   nSalPPot  += SalPPot
   SKIP
ENDDO

if prow()>59+gpStranica; FF; endif
? M10
? "UKUPNO:"
@ prow(),10 SAY  nPocDug    PICTURE PicD
@ prow(),PCOL()+1 SAY  nPocPot    PICTURE PicD
@ prow(),PCOL()+1 SAY  nTekPDug   PICTURE PicD
@ prow(),PCOL()+1 SAY  nTekPPot   PICTURE PicD
@ prow(),PCOL()+1 SAY  nKumPDug   PICTURE PicD
@ prow(),PCOL()+1 SAY  nKumPPot   PICTURE PicD
@ prow(),PCOL()+1 SAY  nSalPDug   PICTURE PicD
@ prow(),PCOL()+1 SAY  nSalPPot   PICTURE PicD
? M10
#endif

FF

END PRINT

RETURN
*}



/*! \fn ZaglSan()
 *  \brief Zaglavlje strane subanalitickog bruto bilansa
 */
 
function ZaglSan()
*{
P_COND2
?? "FIN: SUBANALITIｬKI BRUTO BILANS U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()
@ prow(), REP1_LEN-15 SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 ? "Firma:"
 @ prow(),pcol()+2 SAY cIdFirma
 select PARTN
 HSEEK cIdFirma
 @ prow(),pcol()+2 SAY Naz; @ prow(),pcol()+2 SAY Naz2
endif

IF gRJ=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

? th1
? th2
? th3
? th4
? th5

SELECT SUBAN
RETURN
*}


/*! \fn AnalBB()
 *  \brief Analiticki bruto bilans
 */
 
function AnalBB()
*{
private A1,D4PS,P4PS,D4TP,P4TP,D4KP,P4KP,D4S,P4S

cIdFirma:=gFirma

O_KONTO
O_PARTN

qqKonto:=space(100)
dDatOd:=dDatDo:=ctod("")
private cFormat:="2",cPodKlas:="N"
Box("",8,60)
 set cursor on
do while .t.
 @ m_x+1,m_y+2 SAY "ANALITICKI BRUTO BILANS"
 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| EMPTY(cIdFirma).or.P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Konto " GET qqKonto PICT "@!S50"
 @ m_x+4,m_y+2 SAY "Od datuma :" get dDatOD
 @ m_x+4,col()+2 SAY "do" GET dDatDo
 @ m_x+6,m_y+2 SAY "Format izvjestaja A3/A4 (1/2)" GET cFormat
 @ m_x+7,m_y+2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas$"DN" PICT "@!"
 cIdRJ:=""
 IF gRJ=="D" .and. gSAKrIz=="D"
   cIdRJ:="999999"
   @ m_x+8,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 READ; ESC_BCR
 aUsl1:=Parsiraj(qqKonto,"IdKonto")
 if aUsl1<>NIL; exit; endif
enddo
BoxC()

cidfirma:=trim(cidfirma)

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

IF cFormat=="1"
 M1:= "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M2:= "*REDNI*   KONTO   *                NAZIV ANALITICKOG KONTA                  *        POｬETNO STANJE         *         TEKU終 PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
 M3:= "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M4:= "*BROJ *           *                                                         *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
 M5:= "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
ELSE
 M1:= "------ ----------- ---------------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M2:= "*REDNI*   KONTO   *         NAZIV ANALITICKOG KONTA        *        POｬETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
 M3:= "                                                            ------------------------------- ------------------------------- -------------------------------"
 M4:= "*BROJ *           *                                        *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
 M5:= "------ ----------- ---------------------------------------- --------------- --------------- --------------- --------------- --------------- ---------------"
ENDIF

O_BBKLAS
IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  SintFilt(.f.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_ANAL
ENDIF

select BBKLAS; zap

select ANAL

cFilter:=""

if !(empty(qqkonto))
  if !(empty(dDatOd) .and. empty(dDatDo))
    cFilter += ( iif(empty(cFilter),"",".and.") +;
     aUsl1+".and. DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo) )
  else
    cFilter += ( iif(empty(cFilter),"",".and.") + aUsl1 )
  endif
elseif !(empty(dDatOd) .and. empty(dDatDo))
   cFilter += ( iif(empty(cFilter),"",".and.") +;
     "DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo) )
endif

if LEN(cIdFirma)<2
  SELECT ANAL
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
  cSort1:="IdKonto+dtos(DatNal)"
  INDEX ON &cSort1 TO "ANATMP" FOR &cFilt EVAL(TekRec2()) EVERY 1
  GO TOP
  BoxC()
else
  SET FILTER TO &cFilter
  HSEEK cIdFirma
endif

EOF CRET

nStr:=0

BBMnoziSaK()

START PRINT CRET

B:=0

D1S:=D2S:=D3S:=D4S:=P1S:=P2S:=P3S:=P4S:=0

D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=D4S:=P4S:=0

nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma

   IF prow()==0; BrBil_21(); ENDIF

   cKlKonto:=left(IdKonto,1)
   D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
   DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1) // kl konto

      cSinKonto:=LEFT(idkonto,3)
      D2PS:=P2PS:=D2TP:=P2TP:=D2KP:=P2KP:=D2S:=P2S:=0
      DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cSinKonto==LEFT(idkonto,3) // sin konto

         cIdKonto:=IdKonto

         D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
         DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cIdKonto==IdKonto // konto
            if cTip==ValDomaca(); Dug:=DugBHD*nBBK; Pot:=PotBHD*nBBK; else; Dug:=DUGDEM; Pot:=POTDEM; endif
            D1KP=D1KP+Dug
            P1KP=P1KP+Pot
            IF IdVN="00"
               D1PS+=Dug; P1PS+=Pot
            ELSE
               D1TP+=Dug; P1TP+=Pot
            ENDIF
            SKIP
         ENDDO   // konto

        @ prow()+1,1 SAY ++B PICTURE '9999';?? "."
        @ prow(),10 SAY cIdKonto

        SELECT KONTO
        HSEEK cIdKonto
        IF cFormat=="1"
         @ prow(),19 SAY naz
        ELSE
         @ prow(),19 SAY PADR(naz,40)
        ENDIF
        select ANAL

        nCol1:=pcol()+1
        @ prow(),pcol()+1 SAY D1PS PICTURE PicD
        @ PROW(),pcol()+1 SAY P1PS PICTURE PicD
        IF cFormat=="1"
         @ PROW(),pcol()+1 SAY D1TP PICTURE PicD
         @ PROW(),pcol()+1 SAY P1TP PICTURE PicD
        ENDIF
        @ PROW(),pcol()+1 SAY D1KP PICTURE PicD
        @ PROW(),pcol()+1 SAY P1KP PICTURE PicD

        D1S=D1KP-P1KP
        IF D1S>=0
           P1S:=0
           D2S+=D1S; D3S+=D1S; D4S+=D1S
        ELSE
           P1S:=-D1S; D1S:=0
           P1S:=P1KP-D1KP
           P2S+=P1S
           P3S+=P1S; P4S+=P1S
        ENDIF
        @ prow(),pcol()+1 SAY D1S PICTURE PicD
        @ prow(),pcol()+1 SAY P1S PICTURE PicD

        D2PS=D2PS+D1PS
        P2PS=P2PS+P1PS
        D2TP=D2TP+D1TP
        P2TP=P2TP+P1TP
        D2KP=D2KP+D1KP
        P2KP=P2KP+P1KP
        IF prow()>65+gpStranica; FF;BrBil_21(); ENDIF

      ENDDO  // sinteticki konto
      IF prow()>61+gpStranica; FF; BrBil_21(); ENDIF

      ? M5
      @ prow()+1,10 SAY cSinKonto
      @ prow(),nCol1    SAY D2PS PICTURE PicD
      @ PROW(),pcol()+1 SAY P2PS PICTURE PicD
      IF cFormat=="1"
       @ PROW(),pcol()+1 SAY D2TP PICTURE PicD
       @ PROW(),pcol()+1 SAY P2TP PICTURE PicD
      ENDIF
      @ PROW(),pcol()+1 SAY D2KP PICTURE PicD
      @ PROW(),pcol()+1 SAY P2KP PICTURE PicD
      @ PROW(),pcol()+1 SAY D2S PICTURE PicD
      @ PROW(),pcol()+1 SAY P2S PICTURE PicD
      ? M5

      D3PS=D3PS+D2PS; P3PS=P3PS+P2PS
      D3TP=D3TP+D2TP; P3TP=P3TP+P2TP
      D3KP=D3KP+D2KP; P3KP=P3KP+P2KP

   ENDDO  // klasa konto

   SELECT BBKLAS
   APPEND BLANK
   REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S

   SELECT ANAL

   IF cPodKlas=="D"
    ? M5
    ? "UKUPNO KLASA "+cklkonto
    @ prow(),nCol1    SAY D3PS PICTURE PicD
    @ PROW(),pcol()+1 SAY P3PS PICTURE PicD
    if cFormat=="1"
      @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
      @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
    endif
    @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY D3S PICTURE PicD
    @ PROW(),pcol()+1 SAY P3S PICTURE PicD
    ? M5
   ENDIF
   D4PS+=D3PS; P4PS+=P3PS; D4TP+=D3TP; P4TP+=P3TP; D4KP+=D3KP; P4KP+=P3KP

ENDDO

IF prow()>61+gpStranica; FF ; BrBil_21(); ENDIF
? M5
? "UKUPNO:"
@ prow(),nCol1    SAY D4PS PICTURE PicD
@ PROW(),pcol()+1 SAY P4PS PICTURE PicD
IF cFormat=="1"
 @ PROW(),pcol()+1 SAY D4TP PICTURE PicD
 @ PROW(),pcol()+1 SAY P4TP PICTURE PicD
ENDIF
@ PROW(),pcol()+1 SAY D4KP PICTURE PicD
@ PROW(),pcol()+1 SAY P4KP PICTURE PicD
@ PROW(),pcol()+1 SAY D4S PICTURE PicD
@ PROW(),pcol()+1 SAY P4S PICTURE PicD
? M5

if prow()>55+gpStranica; FF; else; ?;?; endif

?? "REKAPITULACIJA PO KLASAMA NA DAN: ";?? DATE()
?  M6
?  M7
?  M8
?  M9
?  M10

select BBKLAS; go top


nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()
   @ prow()+1,4   SAY IdKlasa
   @ prow(),10       SAY PocDug               PICTURE PicD
   @ PROW(),pcol()+1 SAY PocPot               PICTURE PicD
   @ PROW(),pcol()+1 SAY TekPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY TekPPot              PICTURE PicD
   @ PROW(),pcol()+1 SAY KumPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY KumPPot              PICTURE PicD
   @ PROW(),pcol()+1 SAY SalPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY SalPPot              PICTURE PicD

   nPocDug   += PocDug
   nPocPot   += PocPot
   nTekPDug  += TekPDug
   nTekPPot  += TekPPot
   nKumPDug  += KumPDug
   nKumPPot  += KumPPot
   nSalPDug  += SalPDug
   nSalPPot  += SalPPot
   SKIP
ENDDO

? M10
? "UKUPNO:"
@ prow(),10       SAY  nPocDug    PICTURE PicD
@ PROW(),pcol()+1 SAY  nPocPot    PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPPot   PICTURE PicD
? M10

FF

END PRINT

#ifndef CAX
closeret
#endif
return
*}

/*! \fn BrBil_21()
 *  \brief Zaglavlje analitickog bruto bilansa
 */
 
function BrBil_21()
*{
P_COND2
?? "FIN: ANALITIｬKI BRUTO BILANS U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()
@ prow(), IF(cFormat=="1",220,142) SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 select PARTN
 HSEEK  cIdFirma
 ? "Firma:",cIdFirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

select ANAL

? M1
? M2
? M3
? M4
? M5
RETURN
*}


/*! \fn SintBB()
 *  \brief Sinteticki bruto bilans
 */

function SintBB()
*{
local nPom

cIdFirma:=gFirma

O_PARTN
Box("",8,60)
set cursor on
qqKonto:=space(100)
dDatOd:=dDatDo:=ctod("")
private cFormat:="2",cPodKlas:="N"

do while .t.
 @ m_x+1,m_y+2 SAY "SINTETICKI BRUTO BILANS"
 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma " GET cIdFirma valid {|| empty(cIdFirma) .or. P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Konto " GET qqKonto    pict "@!S50"
 @ m_x+4,m_y+2 SAY "Od datuma :" get dDatOD
 @ m_x+4,col()+2 SAY "do" GET dDatDo
 @ m_x+6,m_y+2 SAY "Format izvjestaja A3/A4 (1/2)" GET cFormat
 @ m_x+7,m_y+2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas$"DN" PICT "@!"
 cIdRJ:=""
 IF gRJ=="D" .and. gSAKrIz=="D"
   cIdRJ:="999999"
   @ m_x+8,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 READ; ESC_BCR
 aUsl1:=Parsiraj(qqKonto,"IdKonto")
 if aUsl1<>NIL; exit; endif
enddo

cidfirma:=trim(cidfirma)

BoxC()

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

if cFormat=="1"
 M1:= "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M2:= "*REDNI*   KONTO   *                  NAZIV SINTETICKOG KONTA                *        POｬETNO STANJE         *         TEKU終 PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
 M3:= "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M4:= "*BROJ *           *                                                         *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
 M5:= "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
else
 M1:= "---- ------------------------------ ------------------------------- ------------------------------- -------------------------------"
 M2:= "    *                              *        POｬETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
 M3:= "    *    SINTETIｬKI KONTO           ------------------------------- ------------------------------- -------------------------------"
 M4:= "    *                              *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
 M5:= "---- ------------------------------ --------------- --------------- --------------- --------------- --------------- ---------------"
endif


O_KONTO
O_BBKLAS

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  SintFilt(.t.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_SINT
ENDIF

select BBKLAS; ZAP
select SINT
cFilter:=""
if !(empty(qqkonto))
  if !(empty(dDatOd) .and. empty(dDatDo))
    cFilter:=aUsl1+".and. DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
  else
    cFilter:=aUsl1
  endif
elseif !(empty(dDatOd) .and. empty(dDatDo))
  cFilter:="DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
endif

if LEN(cIdFirma)<2
  SELECT SINT
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
  cSort1:="IdKonto+dtos(DatNal)"
  INDEX ON &cSort1 TO "SINTMP" FOR &cFilt EVAL(TekRec2()) EVERY 1
  GO TOP
  BoxC()
else
  IF !EMPTY(cFilter)
    SET FILTER TO &cFilter
  ENDIF
  HSEEK cIdFirma
endif

EOF CRET


nStr:=0

BBMnoziSaK()

START PRINT CRET

B:=1

D1S:=D2S:=D3S:=D4S:=P1S:=P2S:=P3S:=P4S:=0


D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=D4S:=P4S:=0
nStr:=0

nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma

   IF prow()==0; BrBil_31(); ENDIF

   cKlKonto:=left(IdKonto,1)

   D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
   DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1)

      cIdKonto:=IdKonto
      D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
      DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cIdKonto==left(IdKonto,3)
         if cTip==ValDomaca(); Dug:=DugBHD*nBBK; Pot:=PotBHD*nBBK; else; Dug:=DUGDEM; Pot:=POTDEM; endif
         D1KP+=Dug
         P1KP+=Pot
         IF IdVN="00"
            D1PS+=Dug; P1PS+=Pot
         ELSE
            D1TP+=Dug; P1TP+=Pot
         ENDIF
         SKIP
      ENDDO // konto

      IF prow()>63+gpStranica; FF ; BrBil_31(); endif

      if cFormat=="1"
       @ prow()+1,1 SAY B PICTURE '9999'; ?? "."
       @ prow(),10 SAY cIdKonto
       select KONTO
       HSEEK cIdKonto
       @ prow(),19 SAY naz
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY D1PS PICTURE PicD
       @ prow(),pcol()+1 SAY P1PS PICTURE PicD
       @ prow(),pcol()+1 SAY D1TP PICTURE PicD
       @ prow(),pcol()+1 SAY P1TP PICTURE PicD
       @ prow(),pcol()+1 SAY D1KP PICTURE PicD
       @ prow(),pcol()+1 SAY P1KP PICTURE PicD
       D1S:=D1KP-P1KP
       IF D1S>=0
         P1S:=0; D3S+=D1S; D4S+=D1S
       ELSE
         P1S:=-D1S; D1S:=0
         P3S+=P1S; P4S+=P1S
       ENDIF
       @ prow(),pcol()+1 SAY D1S PICTURE PicD
       @ prow(),pcol()+1 SAY P1S PICTURE PicD

      else  // cformat=="2" - A4

       @ prow()+1,1 SAY cIdKonto
       select KONTO
       HSEEK cIdKonto

       private aRez:=SjeciStr(naz,30)
       private nColNaz:=pcol()+1
       @ prow(),pcol()+1 SAY padr(aRez[1],30)
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY D1PS PICTURE PicD
       @ prow(),pcol()+1 SAY P1PS PICTURE PicD
       @ prow(),pcol()+1 SAY D1KP PICTURE PicD
       @ prow(),pcol()+1 SAY P1KP PICTURE PicD
       D1S:=D1KP-P1KP
       IF D1S>=0
         P1S:=0; D3S+=D1S; D4S+=D1S
       ELSE
         P1S:=-D1S; D1S:=0
         P3S+=P1S; P4S+=P1S
       ENDIF
       @ prow(),pcol()+1 SAY D1S PICTURE PicD
       @ prow(),pcol()+1 SAY P1S PICTURE PicD

       if len(aRez)==2
        @ prow()+1,nColNaz SAY padr(aRez[2],30)
       endif
      endif // cformat

      SELECT SINT
      D3PS+=D1PS; P3PS+=P1PS; D3TP+=D1TP; P3TP+=P1TP; D3KP+=D1KP; P3KP+=P1KP

      ++B


   ENDDO // klasa konto

   SELECT BBKLAS
   APPEND BLANK
   REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S

   SELECT SINT

   IF cPodKlas=="D"
    ? M5
    ? "UKUPNO KLASA "+cklkonto
    @ prow(),nCol1    SAY D3PS PICTURE PicD
    @ PROW(),pcol()+1 SAY P3PS PICTURE PicD
    if cFormat=="1"
      @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
      @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
    endif
    @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY D3S PICTURE PicD
    @ PROW(),pcol()+1 SAY P3S PICTURE PicD
    ? M5
   ENDIF
   D4PS+=D3PS; P4PS+=P3PS; D4TP+=D3TP; P4TP+=P3TP; D4KP+=D3KP; P4KP+=P3KP

ENDDO

IF prow()>58+gpStranica; FF ; BrBil_31(); endif
? M5
? "UKUPNO:"
@ prow(),nCol1    SAY D4PS PICTURE PicD
@ PROW(),pcol()+1 SAY P4PS PICTURE PicD
if cFormat=="1"
 @ PROW(),pcol()+1 SAY D4TP PICTURE PicD
 @ PROW(),pcol()+1 SAY P4TP PICTURE PicD
endif
@ PROW(),pcol()+1 SAY D4KP PICTURE PicD
@ PROW(),pcol()+1 SAY P4KP PICTURE PicD
@ PROW(),pcol()+1 SAY D4S PICTURE PicD
@ PROW(),pcol()+1 SAY P4S PICTURE PicD
? M5
nPom:=d4ps-p4ps
@ prow()+1,nCol1   SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD

nPom:=d4tp-p4tp
if cFormat=="1"
 @ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
 @ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
endif

nPom:=d4kp-p4kp
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
nPom:=d4s-p4s
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
? M5

FF

?? "REKAPITULACIJA PO KLASAMA NA DAN: "; ?? DATE()
? IF(cFormat=="1", M6, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")
? IF(cFormat=="1", M7, "*        *          POｬETNO STANJE       *        KUMULATIVNI PROMET     *            SALDO             *")
? IF(cFormat=="1", M8, "  KLASA   ------------------------------- ------------------------------- -------------------------------")
? IF(cFormat=="1", M9, "*        *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *    POTRAｦUJE *")
? IF(cFormat=="1",M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")

select BBKLAS; go top


nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()
   @ prow()+1,4      SAY IdKlasa
   @ prow(),10       SAY PocDug               PICTURE PicD
   @ PROW(),pcol()+1 SAY PocPot               PICTURE PicD
   if cFormat=="1"
    @ PROW(),pcol()+1 SAY TekPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY TekPPot              PICTURE PicD
   endif
   @ PROW(),pcol()+1 SAY KumPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY KumPPot              PICTURE PicD
   @ PROW(),pcol()+1 SAY SalPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY SalPPot              PICTURE PicD

   nPocDug   += PocDug
   nPocPot   += PocPot
   nTekPDug  += TekPDug
   nTekPPot  += TekPPot
   nKumPDug  += KumPDug
   nKumPPot  += KumPPot
   nSalPDug  += SalPDug
   nSalPPot  += SalPPot
   SKIP
ENDDO

? IF(cFormat=="1",M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")
? "UKUPNO:"
@ prow(),10       SAY  nPocDug    PICTURE PicD
@ PROW(),pcol()+1 SAY  nPocPot    PICTURE PicD
if cFormat=="1"
 @ PROW(),pcol()+1 SAY  nTekPDug   PICTURE PicD
 @ PROW(),pcol()+1 SAY  nTekPPot   PICTURE PicD
endif
@ PROW(),pcol()+1 SAY  nKumPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPPot   PICTURE PicD
? IF(cFormat=="1",M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")

FF

END PRINT
#ifndef CAX
closeret
#endif
return
*}



/*! \fn BrBil_31()
 *  \brief Zaglavlje sintetickog bruto bilansa
 */

function BrBil_31()
*{
P_COND2
?? "FIN: SINTETICKI BRUTO BILANS U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? "  NA DAN: "; ?? DATE()
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

select SINT
? M1
? M2
? M3
? M4
? M5
RETURN
*}

/*! \fn GrupBB()
 *  \brief Bruto bilans po grupama konta
 */

function GrupBB()
*{
local nPom

cIdFirma:=gFirma

O_PARTN
Box("",6,60)
set cursor on
qqKonto:=space(100)
dDatOd:=dDatDo:=ctod("")
private cPodKlas:="N"

do while .t.
 @ m_x+1,m_y+2 SAY "BRUTO BILANS PO GRUPAMA KONTA"
 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma " GET cIdFirma valid {|| empty(cIdFirma) .or.;
                          P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Konto " GET qqKonto    pict "@!S50"
 @ m_x+4,m_y+2 SAY "Od datuma :" get dDatOD
 @ m_x+4,col()+2 SAY "do" GET dDatDo
 @ m_x+5,m_y+2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas$"DN" PICT "@!"
 cIdRJ:=""
 IF gRJ=="D" .and. gSAKrIz=="D"
   cIdRJ:="999999"
   @ m_x+6,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 READ; ESC_BCR
 aUsl1:=Parsiraj(qqKonto,"IdKonto")
 if aUsl1<>NIL; exit; endif
enddo

cidfirma:=trim(cidfirma)

BoxC()

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

M1:= "------ ----------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
M2:= "*REDNI*   GRUPA   *        POｬETNO STANJE         *         TEKU終 PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
M3:= "          KONTA    ------------------------------- ------------------------------- ------------------------------- -------------------------------"
M4:= "*BROJ *           *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
M5:= "------ ----------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"


O_KONTO
O_BBKLAS

select BBKLAS; ZAP

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  SintFilt(.t.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_SINT
ENDIF

cFilter:=""

if !(empty(qqkonto))
  if !(empty(dDatOd) .and. empty(dDatDo))
    cFilter:=aUsl1+".and. DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
  else
    cFilter:=aUsl1
  endif
elseif !(empty(dDatOd) .and. empty(dDatDo))
    cFilter:="DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
endif

if LEN(cIdFirma)<2
  SELECT SINT
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
  cSort1:="IdKonto+dtos(DatNal)"
  INDEX ON &cSort1 TO "SINTMP" FOR &cFilt EVAL(TekRec2()) EVERY 1
  GO TOP
  BoxC()
else
  IF !EMPTY(cFilter)
    SET FILTER TO &cFilter
  ENDIF
  HSEEK cIdFirma
endif

EOF CRET

nStr:=0

BBMnoziSaK()

START PRINT CRET

B:=1

D1S:=D2S:=D3S:=D4S:=P1S:=P2S:=P3S:=P4S:=0


D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=D4S:=P4S:=0
nStr:=0

nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma

   IF prow()==0; BrBil_41(); ENDIF

   cKlKonto:=left(IdKonto,1)

   D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
   DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1)

      cIdKonto:=LEFT(IdKonto,2)
      D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
      DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cIdKonto==LEFT(IdKonto,2)
         if cTip==ValDomaca(); Dug:=DugBHD*nBBK; Pot:=PotBHD*nBBK; else; Dug:=DUGDEM; Pot:=POTDEM; endif
         D1KP+=Dug
         P1KP+=Pot
         IF IdVN="00"
            D1PS+=Dug; P1PS+=Pot
         ELSE
            D1TP+=Dug; P1TP+=Pot
         ENDIF
         SKIP
      ENDDO // konto

      IF prow()>63+gpStranica; FF ; BrBil_41(); endif

       @ prow()+1,1 SAY B PICTURE '9999'; ?? "."
       @ prow(),10 SAY PADC(cIdKonto,8)
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY D1PS PICTURE PicD
       @ prow(),pcol()+1 SAY P1PS PICTURE PicD
       @ prow(),pcol()+1 SAY D1TP PICTURE PicD
       @ prow(),pcol()+1 SAY P1TP PICTURE PicD
       @ prow(),pcol()+1 SAY D1KP PICTURE PicD
       @ prow(),pcol()+1 SAY P1KP PICTURE PicD
       D1S:=D1KP-P1KP
       IF D1S>=0
         P1S:=0; D3S+=D1S; D4S+=D1S
       ELSE
         P1S:=-D1S; D1S:=0
         P3S+=P1S; P4S+=P1S
       ENDIF
       @ prow(),pcol()+1 SAY D1S PICTURE PicD
       @ prow(),pcol()+1 SAY P1S PICTURE PicD


      SELECT SINT
      D3PS+=D1PS; P3PS+=P1PS; D3TP+=D1TP; P3TP+=P1TP; D3KP+=D1KP; P3KP+=P1KP

      ++B


   ENDDO // klasa konto

   SELECT BBKLAS
   APPEND BLANK
   REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S

   SELECT SINT

   IF cPodKlas=="D"
    ? M5
    ? "UKUPNO KLASA "+cklkonto
    @ prow(),nCol1    SAY D3PS PICTURE PicD
    @ PROW(),pcol()+1 SAY P3PS PICTURE PicD
    @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
    @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
    @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY D3S PICTURE PicD
    @ PROW(),pcol()+1 SAY P3S PICTURE PicD
    ? M5
   ENDIF
   D4PS+=D3PS; P4PS+=P3PS; D4TP+=D3TP; P4TP+=P3TP; D4KP+=D3KP; P4KP+=P3KP

ENDDO

IF prow()>58+gpStranica; FF ; BrBil_41(); endif
? M5
? "UKUPNO:"
@ prow(),nCol1    SAY D4PS PICTURE PicD
@ PROW(),pcol()+1 SAY P4PS PICTURE PicD
@ PROW(),pcol()+1 SAY D4TP PICTURE PicD
@ PROW(),pcol()+1 SAY P4TP PICTURE PicD
@ PROW(),pcol()+1 SAY D4KP PICTURE PicD
@ PROW(),pcol()+1 SAY P4KP PICTURE PicD
@ PROW(),pcol()+1 SAY D4S PICTURE PicD
@ PROW(),pcol()+1 SAY P4S PICTURE PicD
? M5
nPom:=d4ps-p4ps
@ prow()+1,nCol1   SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD

nPom:=d4tp-p4tp                                  
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD

nPom:=d4kp-p4kp
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
nPom:=d4s-p4s
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
? M5

FF

?? "REKAPITULACIJA PO KLASAMA NA DAN: "; ?? DATE()
?  M6
?  M7
?  M8
?  M9
?  M10

select BBKLAS; go top


nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()
   @ prow()+1,4      SAY IdKlasa
   @ prow(),10       SAY PocDug               PICTURE PicD
   @ PROW(),pcol()+1 SAY PocPot               PICTURE PicD
   @ PROW(),pcol()+1 SAY TekPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY TekPPot              PICTURE PicD
   @ PROW(),pcol()+1 SAY KumPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY KumPPot              PICTURE PicD
   @ PROW(),pcol()+1 SAY SalPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY SalPPot              PICTURE PicD

   nPocDug   += PocDug
   nPocPot   += PocPot
   nTekPDug  += TekPDug
   nTekPPot  += TekPPot
   nKumPDug  += KumPDug
   nKumPPot  += KumPPot
   nSalPDug  += SalPDug
   nSalPPot  += SalPPot
   SKIP
ENDDO

? M10
? "UKUPNO:"
@ prow(),10       SAY  nPocDug    PICTURE PicD
@ PROW(),pcol()+1 SAY  nPocPot    PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPPot   PICTURE PicD
? M10

FF

END PRINT
#ifndef CAX
closeret
#endif
return
*}


/*! \fn BrBil_41()
 *  \brief Zaglavlje bruto bilansa po grupama 
 */

function BrBil_41()
*{
P_COND2
?? "FIN.P:BRUTO BILANS PO GRUPAMA KONTA U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? "  NA DAN: "; ?? DATE()
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

select SINT
? M1
? M2
? M3
? M4
? M5
RETURN
*}



/*! \fn BBMnoziSaK()
 *  \brief
 */
 
function BBMnoziSaK()
*{
LOCAL nArr:=SELECT()
  IF cTip==ValDomaca().and.;
     IzFMKIni("FIN","BrutoBilansUDrugojValuti","N",KUMPATH)=="D"
    Box(,5,70)
      @ m_x+2, m_y+2 SAY "Pomocna valuta      " GET cBBV pict "@!" valid ImaUSifVal(cBBV)
      @ m_x+3, m_y+2 SAY "Omjer pomocna/domaca" GET nBBK WHEN {|| nBBK:=OmjerVal2(cBBV,cTip),.t.} PICT "999999999.999999999"
      READ
    BoxC()
  ELSE
    cBBV:=cTip
    nBBK:=1
  ENDIF
 SELECT (nArr)
RETURN
*}


/*! \fn ImaUSifVal(cKartica)
 *  \brief  
 *  \param cKartica
 */

function ImaUSifVal(cKratica)
*{
  LOCAL lIma:=.f., nArr:=SELECT()
   SELECT (F_VALUTE)
   IF !USED(); O_VALUTE; ENDIF
   GO TOP
   DO WHILE !EOF()
     IF naz2==PADR(cKratica,4)
       lIma:=.t.
       EXIT
     ENDIF
     SKIP 1
   ENDDO
   SELECT (nArr)
RETURN lIma
*}

