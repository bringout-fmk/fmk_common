#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/dok/1g/stdatn.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: stdatn.prg,v $
 * Revision 1.4  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 * Revision 1.3  2003/04/12 06:43:38  mirsad
 * ispravka: gBrojac sada je PUBLIC varijabla
 *
 * Revision 1.2  2002/06/19 13:46:23  sasa
 * no message
 *
 *
 */
 

/*! \file fmk/fin/dok/1g/stdatn.prg
 *  \brief Stampanje naloga
 */
 
/*! \fn StDatn()
 *  \brief Stampanje naloga
 */

function StDatn()
*{
LOCAL nDug:=0.00,nPot:=0.00

cInteg:="N"
nSort:=1

cIdVN:="  "
Box(,7,60)
 @ m_x+1,m_Y+2 SAY "Provjeriti integritet podataka"
 @ m_x+2,m_Y+2 SAY "u odnosu na datoteku naloga D/N ?"  GET cInteg  pict "@!" valid cinteg $ "DN"
 @ m_x+4,m_Y+2 SAY "Sortiranje dokumenata po:  1-(firma,vn,brnal) "
 @ m_x+5,m_Y+2 SAY "2-(firma,brnal,vn),    3-(datnal,firma,vn,brnal) " GET nSort pict "9"
 @ m_x+7,m_Y+2 SAY "Vrsta naloga (prazno-svi) " GET cIDVN pict "@!"
 read; ESC_BCR
BoxC()

O_NALOG
if cinteg=="D"
   O_SUBAN; set order to 4
   O_ANAL; set order to 2
   O_SINT; set order to 2
endif

SELECT NALOG; set order to nSort
GO TOP

EOF CRET

START PRINT CRET

m:="---- --- --- ----- -------- ---------------- ----------------"+IF(gVar1=="0"," ------------ ------------","-")
if fieldpos("SIFRA")<>0
  m+=" ------"
endif
if cInteg=="D"; m:=m+" ---  --- ----"; endif

nRBr:=0

nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0

picBHD:="@Z "+FormPicL(gPicBHD,16)
picDEM:="@Z "+FormPicL(gPicDEM,12)

DO WHILE !EOF()

   IF prow()==0
      IF gVar1=="0"
       P_COND
      ELSE
       F10CPI
      ENDIF
      ?? "LISTA FIN. DOKUMENATA (NALOGA) NA DAN:",DATE()
      ? m
      ? "*RED*FIR* V * BR  * DAT    *   DUGUJE       *   POTRAZUJE    *"+IF(gVar1=="0","   DUGUJE   * POTRAZUJE *","")
      if fieldpos("SIFRA")<>0
        ?? "  OP. *"
      endif
      if cInteg=="D"; ?? "  1  * 2 * 3 *"; endif
      ? "*BRD*MA * N * NAL * NAL    *    "+ValDomaca()+"        *      "+ValDomaca()+"      *"+IF(gVar1=="0","    "+ValPomocna()+"    *    "+ValPomocna()+"   *","")
      if fieldpos("SIFRA")<>0
        ?? "      *"
      endif
      if cInteg=="D"; ?? "     *   *   *"; endif
      if fieldpos("SIFRA")<>0
      endif
      ? m
   ENDIF

      if !empty(cIdVN) .and. idvn<>cIDVN; skip; loop; endif

      IF prow()>63; FF; ENDIF
      @ prow()+1,0 SAY ++nRBr PICTURE "9999"
      @ prow(),pcol()+2 SAY IdFirma
      @ prow(),pcol()+2 SAY IdVN
      @ prow(),pcol()+2 SAY BrNal
      @ prow(),pcol()+1 SAY DatNal
      @ prow(),28       SAY DugBHD picture picBHD
      @ prow(),pcol()+1 SAY PotBHD picture picBHD
      IF gVar1=="0"
       @ prow(),pcol()+1 SAY DugDEM picture picDEM
       @ prow(),pcol()+1 SAY PotDEM picture picDEM
      ENDIF
      if fieldpos("SIFRA")<>0
        @ prow(),pcol()+1 SAY iif(empty(sifra),space(2),left(crypt(sifra),2))
      endif
      if cInteg=="D"

          select SUBAN; seek NALOG->(IDFirma+Idvn+Brnal)
          nDug:=0.00; nPot:=0.00
          do while (IDFirma+Idvn+Brnal)==NALOG->(IDFirma+Idvn+Brnal)  .and. !eof()
             if d_p="1"
                nDug+=iznosbhd
             else
                nPot+=iznosbhd
             endif
             skip
          enddo
          select NALOG
          if STR(nDug,20,2)==STR(DugBHd,20,2) .and. STR(nPot,20,2)==STR(PotBHD,20,2)
              ?? "     "
          else
              ?? " ERR "
          endif
          select ANAL
          seek NALOG->(IDFirma+Idvn+Brnal)
          nDug:=0.00; nPot:=0.00
          do while (IDFirma+Idvn+Brnal)==NALOG->(IDFirma+Idvn+Brnal) .and. !eof()
             nDug+=dugbhd
             nPot+=potbhd
             skip
          enddo
          select NALOG
          if STR(nDug,20,2)==STR(DugBHd,20,2) .and. STR(nPot,20,2)==STR(PotBHD,20,2)
              ?? "     "
          else
              ?? " ERR "
          endif
          select SINT
          seek NALOG->(IDFirma+Idvn+Brnal)
          nDug:=0.00; nPot:=0.00
          do while (IDFirma+Idvn+Brnal)==NALOG->(IDFirma+Idvn+Brnal) .and. !eof()
             nDug+=dugbhd
             nPot+=potbhd
             skip
          enddo
          select NALOG
          if STR(nDug,20,2)==STR(DugBHd,20,2) .and. STR(nPot,20,2)==STR(PotBHD,20,2)
              ?? "     "
          else
              ?? " ERR "
          endif

      endif

      nDugBHD+=DugBHD
      nPotBHD+=PotBHD
      nDugDEM+=DugDEM
      nPotDEM+=PotDEM
      SKIP
ENDDO
IF prow()>63; FF; ENDIF
? m
? "UKUPNO:"
@ prow(),28 SAY nDugBHD picture picBHD
@ prow(),pcol()+1 SAY nPotBHD picture picBHD
IF gVar1=="0"
 @ prow(),pcol()+1 SAY nDugDEM picture picDEM
 @ prow(),pcol()+1 SAY nPotDEM picture picDEM
ENDIF
? m

FF
END PRINT

#ifndef CAX
closeret
#endif
return
*}


/*! \fn DnevnikNaloga()
 *  \brief Dnevnik naloga
 */
 
function DnevnikNaloga()
*{
LOCAL cMjGod:=""
 private fK1:=fk2:=fk3:=fk4:=cDatVal:="N",gnLOst:=0,gPotpis:="N"
 private nColIzn:=20
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

  dOd:=CTOD("01.01."+STR(YEAR(DATE()),4))
  dDo:=DATE()

  SET KEY K_F5 TO VidiNaloge()

  Box(,3,77)
    @ m_x+4, m_y+30   SAY "<F5> - sredjivanje datuma naloga"
    @ m_x+2, m_y+2    SAY "Obuhvatiti naloge u periodu od" GET dOd
    @ m_x+2, col()+2 SAY "do" GET dDo VALID dDo>=dOd
    READ; ESC_BCR
  BoxC()

  SET KEY K_F5 TO

  IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
    O_VRSTEP
  ENDIF
  O_TNAL
  O_TDOK
  O_PARTN
  O_KONTO
  O_NALOG
  O_SUBAN

  SELECT SUBAN; SET ORDER TO TAG "4"
  SELECT NALOG; SET ORDER TO TAG "3"

  IF !EMPTY(dOd) .or. !EMPTY(dDo)
    SET FILTER TO DATNAL>=dOd .and. DATNAL<=dDo
  ENDIF

  GO TOP

  START PRINT CRET

  nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0  // sve strane ukupno

  nStr:=0
  nRbrDN:=0
  cIdFirma := IDFIRMA; cIdVN := IDVN; cBrNal := BRNAL; dDatNal := DATNAL
  PicBHD:="@Z "+FormPicL(gPicBHD,15)
  PicDEM:="@Z "+FormPicL(gPicDEM,10)

  lJerry := ( IzFMKIni("FIN","JednovalutniNalogJerry","N",KUMPATH) == "D" )

  IF gNW=="N"
    M:="------ ---------- --- "+"---- ------- ------ ----------------------------"+IF(gVar1=="1".and.lJerry,"-- "+REPL("-",20),"")+" -- ------------- ----------- -------- -------- --------------- ---------------"+IF(gVar1=="1","-"," ---------- ----------")
  ELSE
    M:="------ ---------- --- "+"---- ------- ------ ----------------------------"+IF(gVar1=="1".and.lJerry,"-- "+REPL("-",20),"")+" ----------- -------- -------- --------------- ---------------"+IF(gVar1=="1","-"," ---------- ----------")
  ENDIF
  cMjGod:=STR(MONTH(dDatNal),2)+STR(YEAR(dDatNal),4)
  Zagl11()

  nTSDugBHD:=nTSPotBHD:=nTSDugDEM:=nTSPotDEM:=0   // tekuca strana

  DO WHILE !EOF()
    IF prow()<6; Zagl11(); endif    // prow()<6 => nije odstampano zaglavlje
    cIdFirma := IDFIRMA
    cIdVN    := IDVN
    cBrNal   := BRNAL
    dDatNal  := DATNAL
    IF cMjGod != STR(MONTH(dDatNal),2)+STR(YEAR(dDatNal),4)
      // zavrçi stranu
      PrenosDNal()
      // stampaj zaglavlje (nova stranica)
      Zagl11()
    ENDIF
    cMjGod:=STR(MONTH(dDatNal),2)+STR(YEAR(dDatNal),4)
    SELECT SUBAN
    HSEEK cIdFirma+cIdVN+cBrNal
    StSubNal("3")
    SELECT NALOG
    SKIP 1
  ENDDO

  IF prow()>5  // znaci da je pocela nova stranica tj.odstampano je zaglavlje
    PrenosDNal()
  ENDIF

  END PRINT

CLOSERET
return
*}


/*! \fn NazMjeseca(nMjesec)
 *  \brief Vraca naziv mjeseca za zadati nMjesec (np. 1 => Januar)
 *  \param nMjesec - oznaka mjeseca - integer
 */
 
function NazMjeseca(nMjesec)
*{
LOCAL aVrati:={"Januar","Februar","Mart","April","Maj","Juni","Juli",;
                "Avgust","Septembar","Oktobar","Novembar","Decembar"}
RETURN IF( nMjesec>0.and.nMjesec<13 , aVrati[nMjesec] , "" )
*}


/*! \fn VidiNaloge()
 *  \brief Pregled naloga
 */
 
function VidiNaloge()
*{
O_NALOG; SET ORDER TO TAG "3"; GO TOP
  ImeKol:={ ;
          {"Firma",         {|| IDFIRMA }, "IDFIRMA" } ,;
          {"Vrsta naloga",  {|| IDVN    }, "IDVN"    } ,;
          {"Broj naloga",   {|| BRNAL   }, "BRNAL"   } ,;
          {"Datum naloga",  {|| DATNAL  }, "DATNAL"  } ;
        }

  Kol:={}; for i:=1 to len(ImeKol); AADD(Kol,i); next

  Box(,20,45)
   ObjDbedit("Nal",20,45,{|| EdNal()},"<Enter> - ispravka","Nalozi...", , , , ,)
  BoxC()
CLOSERET
return
*}


/*! \fn EdNal()
 *  \brief Ispravka datuma na nalogu 
 */
 
function EdNal()
*{
LOCAL nVrati:=DE_CONT, dDatNal:=NALOG->datnal, GetList:={}
  IF Ch==K_ENTER
    Box(,4,77)
      @ m_x+2, m_y+2 SAY "Stari datum naloga: "+DTOC(dDatNal)
      @ m_x+3, m_y+2 SAY "Novi datum naloga :" GET dDatNal
      READ
    BoxC()
    IF LASTKEY()!=K_ESC
      SELECT NALOG
      Scatter()
       _datnal:=dDatNal
      Gather()
      nVrati:=DE_REFRESH
    ENDIF
  ENDIF
RETURN nVrati
*}

