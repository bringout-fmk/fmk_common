#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/rpt_41.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.10 $
 * $Log: rpt_41.prg,v $
 * Revision 1.10  2004/05/13 10:28:40  sasavranic
 * Uvedena varijanta racunanja PRUCMP bez izbijanja PPP (sl.novine)
 *
 * Revision 1.9  2003/12/24 10:38:54  sasavranic
 * Uracunaj i snizenje ako ga je bilo na pregledu prometa za vise objekata - Planika
 *
 * Revision 1.8  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.7  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.6  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.5  2003/02/10 02:18:49  mirsad
 * no message
 *
 * Revision 1.4  2002/07/19 13:57:23  mirsad
 * lPrikPRUC ubacio kao globalnu varijablu
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
 

/*! \file fmk/kalk/prod/dok/1g/rpt_41.prg
 *  \brief Stampa dokumenta tipa 41
 */


/*! \fn StKalk41()
 *  \brief Stampa dokumenta tipa 41
 */

function StKalk41()
*{
local nCol0:=nCol1:=nCol2:=0
local nPom:=0

Private nMarza,nMarza2,nPRUC,aPorezi
nMarza:=nMarza2:=nPRUC:=0
aPorezi:={}

lVoSaTa := ( IzFmkIni("KALK","VodiSamoTarife","N",PRIVPATH)=="D" )

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
Naslov4x()

select PRIPR

 m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
if cidvd<>'47' .and. !lVoSaTa
  m+=" ---------- ---------- ---------- ----------"
  IF lPrikPRUC
    m += " ----------"
  ENDIF
endif
? m

if cIdVd='47' .or. lVoSaTa
 ? "*R * ROBA     * Kolicina *    MPC   *   PPP %  *   PPU%   *   PP%    *  MPC     *"
 ? "*BR*          *          *          *   PPU    *   PPU    *   PP     *  SA Por  *"
 ? "*  *          *          *     ä    *     ä    *    ä     *          *    ä     *"
else
 IF lPrikPRUC
   ? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  * POREZ NA *    MPC   *   PPP %  *   PPU%   *   PP%    *MPC sa por*          *  MPC     *"
   ? "*BR*          *          *   U MP   *         *  MARZU   *          *   PPP    *   PPU    *   PP     * -Popust  *  Popust  *  SA Por  *"
   ? "*  *          *          *    ä     *         *     ä    *     ä    *     ä    *    ä     *          *    ä     *    ä     *    ä     *"
 ELSE
   ? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  *    MPC   *   PPP %  *   PPU%   *   PP%    *MPC sa por*          *  MPC     *"
   ? "*BR*          *          *   U MP   *         *          *   PPP    *   PPU    *   PP     * -Popust  *  Popust  *  SA Por  *"
   ? "*  *          *          *    ä     *         *     ä    *     ä    *    ä     *          *    ä     *    ä     *    ä     *"
 ENDIF
endif
? m
nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=0
nTot4a:=0

IF lVoSaTa
  private cIdd:=idpartner+idkonto+idkonto2
ELSE
  private cIdd:=idpartner+brfaktp+idkonto+idkonto2
ENDIF

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    IF lVoSaTa .and. idpartner+idkonto+idkonto2<>cidd .or.;
       !lVoSaTa .and. idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    ENDIF

    // formiraj varijable _....
    Scatter() 
    RptSeekRT()

    // izracunaj nMarza2
    Marza2R()   
    KTroskovi()

altd()    
Tarifa(pkonto, idRoba, @aPorezi)
aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)
nPor1:=aIPor[1]
nPor2:=aIPor[2]
nPor3:=aIPor[3]
nPRUC:=nPor2
// nMarza2:=nMarza2-nPRUC // ?!

    VTPorezi()

    DokNovaStrana(125, @nStr, 2)

    nTot3+=  (nU3:= IF(ROBA->tip="U",0,NC)*kolicina )
    nTot4+=  (nU4:= nMarza2*Kolicina )
    nTot4a+=  (nU4a:= nPRUC*Kolicina )
    nTot5+=  (nU5:= MPC*Kolicina )
    
    nTot6+=  (nU6:=(nPor1+nPor2+nPor3)*Kolicina)
    nTot7+=  (nU7:= MPcSaPP*Kolicina )

    nTot8+=  (nU8:= (MPcSaPP-RabatV)*Kolicina )
    nTot9+=  (nU9:= RabatV*Kolicina )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""
    ?? trim(ROBA->naz),"(",ROBA->jmj,")"
    IF lPoNarudzbi
    	IspisPoNar(IF(cIdVd=="41",.f.,))
    ENDIF
    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina PICTURE PicKol

    nCol0:=pcol()

    @ prow(),nCol0 SAY ""
    IF IDVD<>'47' .and. !lVoSaTa
     IF ROBA->tip="U"
       @ prow(),pcol()+1 SAY 0                   PICTURE PicCDEM
     ELSE
       @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
     ENDIF
     @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
     IF lPrikPRUC
       @ prow(),pcol()+1 SAY nPRUC             PICTURE PicCDEM
     ENDIF
    ENDIF
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY aPorezi[POR_PPP]      PICTURE PicProc
    @ prow(),pcol()+1 SAY PrPPUMP()             PICTURE PicProc
    @ prow(),pcol()+1 SAY aPorezi[POR_PP]     PICTURE PicProc
    if IDVD<>"47" .and. !lVoSaTa
     @ prow(),pcol()+1 SAY MPCSAPP-RabatV       PICTURE PicCDEM
     @ prow(),pcol()+1 SAY RabatV               PICTURE PicCDEM
    endif
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    @ prow()+1,4 SAY idTarifa
    @ prow(), nCol0 SAY ""
    IF cIDVD<>'47' .and. !lVoSaTa
     IF ROBA->tip="U"
       @ prow(), pcol()+1  SAY  0                picture picdem
     ELSE
       @ prow(), pcol()+1  SAY  nc*kolicina      picture picdem
     ENDIF
     @ prow(), pcol()+1  SAY  nmarza2*kolicina      picture picdem
     IF lPrikPRUC
       @ prow(),pcol()+1 SAY nPRUC*kolicina       PICTURE PicDEM
     ENDIF
    ENDIF
    @ prow(), pcol()+1 SAY  mpc*kolicina      picture picdem

    @ prow(),nCol1    SAY  nPor1*kolicina    picture piccdem
    @ prow(),pcol()+1 SAY  nPor2*kolicina    picture piccdem
    @ prow(),pcol()+1 SAY  nPor3*kolicina   PICTURE PiccDEM
    if IDVD<>"47" .and. !lVoSaTa
	@ prow(),pcol()+1 SAY  (mpcsapp-RabatV)*kolicina   picture picdem
	@ prow(),pcol()+1 SAY  RabatV*kolicina   picture picdem
    endif
    @ prow(),pcol()+1 SAY  mpcsapp*kolicina   picture picdem

    skip 1

enddo


DokNovaStrana(125, @nStr, 3)
? m
@ prow()+1,0        SAY "Ukupno:"

@ prow(),nCol0  say  ""
IF cIDVD<>'47' .and. !lVoSaTa
 @ prow(),pcol()+1      SAY  nTot3        picture       PicDEM
 @ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
 IF lPrikPRUC
   @ prow(),pcol()+1   SAY  nTot4a        picture       PicDEM
 ENDIF
endif
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
if cIDVD<>"47" .and. !lVoSaTa
	@ prow(),pcol()+1   SAY  nTot8        picture        PicDEM
	@ prow(),pcol()+1   SAY  nTot9        picture        PicDEM
endif
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

// Rekapitulacija tarifa

DokNovaStrana(125, @nStr, 10)
nRec:=recno()

RekTar41(cIdFirma, cIdVd, cBrDok, @nStr)

set order to 1
go nRec
return
*}




/*
 * Rekapitulacija tarifa - nova fja 
 */
function RekTar41(cIdFirma, cIdVd, cBrDok, nStr)
*{
local nTot1
local nTot2
local nTot3
local nTot4
local nTot5
local nTotP
local aPorezi

select pripr
set order to 2
seek cIdfirma+cIdvd+cBrdok

m:="------ ---------- ---------- ----------  ---------- ---------- ---------- ---------- ---------- ----------"
? m
? "* Tar *  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *   PP     *  Popust * MPVSAPP *"
? m
nTot1:=0
nTot2:=0
nTot3:=0
nTot4:=0
nTot5:=0
nTot6:=0
nTot7:=0
nTot8:=0
// popust
nTotP:=0 

aPorezi:={}
altd()
do while !eof() .and. cIdfirma+cIdvd+cBrDok==idfirma+idvd+brdok
  cIdTarifa:=idtarifa
  nU1:=0
  nU2:=0
  nU2b:=0
  nU3:=0
  nU4:=0
  nU5:=0
  nUp:=0
  select tarifa
  hseek cIdtarifa
	
  Tarifa(pripr->pkonto, pripr->idRoba, @aPorezi)

  select pripr
  fVTV:=.f.
  do while !eof() .and. cIdfirma+cIdVd+cBrDok==idFirma+idVd+brDok .and. idTarifa==cIdTarifa
	
	select roba
	hseek pripr->idroba
	select pripr
	VtPorezi()
	
	Tarifa(pripr->pkonto, pripr->idRoba, @aPorezi)
    
    	// mpc bez poreza
	nU1+=pripr->mpc*kolicina

	aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    	// porez na promet
    	nU2+=aIPor[1]*kolicina
    	nU3+=aIPor[2]*kolicina
    	nU4+=aIPor[3]*kolicina

	nU5+= pripr->MpcSaPP * kolicina
    	nUP+= rabatv*kolicina
	
	nTot6 += (pripr->mpc - pripr->nc ) * kolicina
    
    	skip
  enddo
  
  nTot1+=nU1
  nTot2+=nU2
  nTot3+=nU3
  nTot4+=nU4
  nTot5+=nU5
  nTotP+=nUP
  
  ? cIdtarifa

  @ prow(),pcol()+1   SAY aPorezi[POR_PPP] pict picproc
  @ prow(),pcol()+1   SAY PrPPUMP() pict picproc
  @ prow(),pcol()+1   SAY aPorezi[POR_PP] pict picproc
  
  nCol1:=pcol()
  @ prow(),nCol1 +1   SAY nU1 pict picdem
  @ prow(),pcol()+1   SAY nU2 pict picdem
  @ prow(),pcol()+1   SAY nU3 pict picdem
  @ prow(),pcol()+1   SAY nU4 pict picdem
  @ prow(),pcol()+1   SAY nUp pict picdem
  @ prow(),pcol()+1   SAY nU5 pict picdem
enddo

DokNovaStrana(125, @nStr, 4)
? m
? "UKUPNO"
@ prow(),nCol1+1    SAY nTot1 pict picdem
@ prow(),pcol()+1   SAY nTot2 pict picdem
@ prow(),pcol()+1   SAY nTot3 pict picdem
@ prow(),pcol()+1   SAY nTot4 pict picdem
// popust
@ prow(),pcol()+1   SAY nTotP pict picdem  
@ prow(),pcol()+1   SAY nTot5 pict picdem
? m
if cIdVd<>"47" .and. !lVoSaTa .and. !IsJerry()
	? "RUC:"
	@ prow(),pcol()+1 SAY nTot6 pict picdem
? m
endif

return
*}



/*! \fn Naslov4x()
 *  \brief Naslovi za dokumente tipa 4x
 */
 
function Naslov4x()
*{
local cSvediDatFakt
B_ON
  IF CIDVD=="41"
    IF lVoSaTa
      ?? "AVANS POREZA NA REALIZACIJU PO TARIFAMA"
    ELSE
      ?? "IZLAZ IZ PRODAVNICE - KUPAC"
    ENDIF
  ELSEIF CIDVD=="49"
    ?? "IZLAZ IZ PRODAVNICE PO OSTALIM OSNOVAMA"
  ELSEIF cIdVd=="43"
    ?? "IZLAZ IZ PRODAVNICE - KOMISIONA - PARAGON BLOK"
  ELSEIF cIdVd=="47"
    ?? "PREGLED PRODAJE"
  ELSE
    IF lVoSaTa .and. cIdVd=="42"
      ?? "OBRACUN REALIZACIJE"
    ELSE
      ?? "IZLAZ IZ PRODAVNICE - PARAGON BLOK"
    ENDIF
  ENDIF
  B_OFF

  P_COND
  ?
  IF IsJerry()
    cSvediDatFakt := IzFmkIni("KALK","Jerry_KALK4x_SvediDatum","F",KUMPATH)
    ?
    ?? "KALK BR: "
    B_ON
    ?? cIdFirma+"-"+cIdVD+"-"+cBrDok
    B_OFF
    ?? "   ", P_TipDok(cIdVD,-2), SPACE(2),"Datum:",IF(cSvediDatFakt=="F",DatFaktP,DatDok)
    @ prow(),125 SAY "Str:"+str(++nStr,3)
    ?
  ELSE
    ?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
    @ prow(),125 SAY "Str:"+str(++nStr,3)
  ENDIF

  select PARTN; HSEEK cIdPartner

  IF IsJerry()
    if cidvd=="41" .and. !lVoSaTa
     ?  "KUPAC: "
     B_ON
     ?? cIdPartner,"-",naz
     B_OFF
     ?? SPACE(6),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP
    elseif cidvd=="43"
     ?  "DOBAVLJAC KOMIS.ROBE: "
     B_ON
     ?? cIdPartner,"-",naz
     B_OFF
    endif
    ?
  ELSE
    if cidvd=="41" .and. !lVoSaTa
     ?  "KUPAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP
    elseif cidvd=="43"
     ?  "DOBAVLJAC KOMIS.ROBE:",cIdPartner,"-",naz
    endif
  ENDIF

  select KONTO; HSEEK cIdKonto
  ?  "Prodavnicki konto razduzuje:",cIdKonto,"-",naz
return nil
*}



