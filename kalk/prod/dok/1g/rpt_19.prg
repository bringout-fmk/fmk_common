#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/rpt_19.prg,v $
 * $Author: mirsadsubasic $ 
 * $Revision: 1.5 $
 * $Log: rpt_19.prg,v $
 * Revision 1.5  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.4  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.3  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.2  2002/06/21 07:49:36  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/prod/dok/1g/rpt_19.prg
 *  \brief Stampa dokumenta tipa 19
 */


/*! \fn StKalk19()
 *  \brief Stampa dokumenta tipa 19
 */

function StKalk19()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2, aPorezi
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

aPorezi:={}
nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

P_10CPI
B_ON
?? "PROMJENA CIJENA U PRODAVNICI"
?
B_OFF
P_COND
? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,", Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner             // izbaciti?  19.5.00
select KONTO; HSEEK cidkonto               // dodano     19.5.00

?  "KONTO zaduzuje :",cIdKonto,"-",naz

select PRIPR

if (cIdVD=="19")
 m:= "--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
 ? m
 ? "*R * ROBA     * Kolicina *  STARA   * RAZLIKA  * PPP   %  *IZN. PPP  * UK. PPP  * RAZLIKA  *  NOVA   *"
 ? "*BR*          *          *MPC SA PP *   MPC    * PPU   %  *IZN. PPU  * UK. PPU  * MPC SA PP*MPC SA PP*"
 ? "*  *          *          *    ä     *    ä     *          *    ä     *    ä     *    ä     *    ä    *"
 ? m
 nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=0
endif

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVd==IdVd

    ViseDokUPripremi(cIdd)
    RptSeekRT()
    KTroskovi()
    VTPOREZI()

    Tarifa(pripr->pkonto,pripr->idroba,@aPorezi)

    // nova cijena
    nMpcSaPP1:=field->mpcSaPP+field->fcj
    nMpc1:=MpcBezPor(nMpcSaPP1,aPorezi,,field->nc)
    aIPor1:=RacPorezeMP(aPorezi,nMpc1,nMpcSaPP1,field->nc)
    
    // stara cijena
    nMpcSaPP2:=field->fcj
    nMpc2:=MpcBezPor(nMpcSaPP2,aPorezi,,field->nc)
    aIPor2:=RacPorezeMP(aPorezi,nMpc2,nMpcSaPP2,field->nc)
    
    DokNovaStrana(125, @nStr, 2)

      nTot3+=  (nU3:= MPC*Kolicina )

      nPor1:=aIPor1[1]-aIPor2[1]
      nPor2:=aIPor1[2]-aIPor2[2]

      nTot4+=  (nU4:=(nPor1+nPor2)*Kolicina)
      nTot5+=  (nU5:= MPcSaPP*Kolicina )
      @ prow()+1,0 SAY  Rbr PICTURE "999"
      @ prow(),4 SAY  ""
      ?? trim(ROBA->naz),"(",ROBA->jmj,")"
      IF lPoNarudzbi
        IspisPoNar()
      ENDIF
      @ prow()+1,4 SAY IdRoba
      @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol
      @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
      nC0:=pcol()+1
      @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
      nC1:=pcol()+1
      @ prow(),pcol()+1 SAY aPorezi[POR_PPP]            PICTURE PicProc
      @ prow(),pcol()+1 SAY nPor1                         PICTURE PicDEM
      @ prow(),pcol()+1 SAY nPor1*Kolicina                PICTURE PicDEM
      @ prow(),pcol()+1 SAY MPCSAPP                       PICTURE PicCDEM
      @ prow(),pcol()+1 SAY MPCSAPP+FCJ                   PICTURE PicCDEM
      @ prow()+1,nC1 SAY PrPPUMP()                        PICTURE PicProc
      @ prow(),pcol()+1 SAY nPor2                         PICTURE PicDEM
      @ prow(),pcol()+1 SAY nPor2*Kolicina                PICTURE PicDEM
      @ prow(),pcol()+1 SAY space(len(PicCDEM))
      @ prow(),pcol()+1 SAY space(len(PicCDEM))

    skip

enddo

DokNovaStrana(125, @nStr, 3)

? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nC0        SAY  nTot3         PICTURE        PicDEM
@ prow(),pcol()+1   SAY  space(len(picdem))
@ prow(),pcol()+1   SAY  space(len(picdem))
@ prow(),pcol()+1   SAY  nTot4         PICTURE        PicDEM
@ prow(),pcol()+1   SAY  nTot5         PICTURE        PicDEM
? m

?
Rektarife()

PrnClanoviKomisije()
return
*}



/*! \fn Obraz19()
 *  \brief Stampa dokumenta tipa 19 - obrazac nivelacije
 */

function Obraz19()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

cProred:="N"
cPodvuceno:="N"
Box(,2,60)
 @ m_x+1,m_y+2 SAY "Prikazati sa proredom:" GET cProred valid cprored $"DN" pict "@!"
 @ m_x+2,m_y+2 SAY "Prikazati podvuceno  :" GET cPodvuceno valid cpodvuceno $ "DN" pict "@!"
 read
 ESC_BCR
BoxC()

START PRINT CRET
Preduzece()

P_10CPI
B_ON
? padl("Prodavnica __________________________",74)
?
?
? PADC("PROMJENA CIJENA U PRODAVNICI ___________________, Datum _________",80)
?
B_OFF

select PRIPR

P_COND
?
@ prow(),110 SAY "Str:"+str(++nStr,3)

if cIdVD == "19"
 m:= "--- --------------------------------------------------- ---------- ---------- ---------- ------------- ------------- -------------"
 ? m
 ? "*R *  Sifra   *        Naziv                           *  STARA   *   NOVA   * promjena *  zaliha     *   iznos     *  ukupno    *"
 ? "*BR*          *                                        *  cijena  *  cijena  *  cijene  * (kolicina)  *   poreza    * promjena   *"
 ? m
 nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=0
endif

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    ViseDokUPripremi(cIdd)

    select ROBA
    HSEEK PRIPR->IdRoba
    select TARIFA
    HSEEK PRIPR->IdTarifa
    select PRIPR
    
    
    DokNovaStrana(110, @nStr, IIF(cProred=="D",2,1))
      
      ?
      if cPodvuceno=="D"
       U_ON
      endif
      ?? rbr+" "+idroba+" "+PADR(trim(ROBA->naz)+" ("+ROBA->jmj+")",40)
      @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
      @ prow(),pcol()+1 SAY MPCSAPP+FCJ          PICTURE PicCDEM
      @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM
      if cPodvuceno=="D"
       U_OFF
      endif
      @ prow(),pcol()+1 SAY "_____________"
      @ prow(),pcol()+1 SAY "_____________"
      @ prow(),pcol()+1 SAY "_____________"
      if cProred=="D"
        ?
      endif
    skip

enddo


DokNovaStrana(110, @nStr, 12)

? m
? " UKUPNO "
? m
?
?
?
P_10CPI

PrnClanoviKomisije()

END PRINT

return
*}




