#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_ip.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.7 $
 * $Log: rpt_ip.prg,v $
 * Revision 1.7  2003/11/11 14:06:34  sasavranic
 * Uvodjenje f-je IspisNaDan()
 *
 * Revision 1.6  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.5  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.4  2003/03/17 07:58:08  mirsad
 * dorada za Biletiæa: obrazac sank liste na osnovu dokumenta IP
 *
 * Revision 1.3  2003/02/03 00:28:17  mirsad
 * Jerry - dorada
 *
 * Revision 1.2  2002/06/21 12:12:43  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_ip.prg
 *  \brief Stampa dokumenta tipa IP
 */


/*! \fn StKalkIP(fZaTops)
 *  \brief Stampa dokumenta tipa IP
 *  \param fZaTops -
 */

function StKalkIP(fZaTops)
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,aPorezi
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()
aPorezi:={}
nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

if fzatops==NIL
	fZaTops:=.f.
endif

if !fZaTops
	cSamoObraz:=Pitanje(,"Prikaz samo obrasca inventure (D-da,N-ne,S-sank lista) ?",,"DNS")
	if cSamoObraz=="S"
		StObrazSL()
		return
	endif
else
	cSamoObraz:="N"
endif

P_10CPI
select konto
hseek cidkonto
select pripr

?? "INVENTURA PRODAVNICA ",cidkonto,"-",konto->naz
IspisNaDan(10)
P_COND
?
? "DOKUMENT BR. :",cIdFirma+"-"+cIdVD+"-"+cBrDok, SPACE(2),"Datum:",DatDok
?
@ prow(),125 SAY "Str:"+str(++nStr,3)

select PRIPR

if (IsJerry())
	m:="--- -------------------------------------------- ------ ---------- ---------- ---------- --------- ----------- ----------- -----------"
	? m
	? "*R *                                            *      *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika * Cijena  *  +VISAK  *"
	? "*BR*               R O B A                      *Tarifa*  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *         *  -MANJAK *"
else
	m:="--- --------------------------------------- ---------- ---------- ---------- --------- ----------- ----------- -----------"
	? m
	? "*R * ROBA                                  *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika * Cijena  *  +VISAK  *"
	? "*BR* TARIFA                                *  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *         *  -MANJAK *"
endif

? m
nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=nTotb:=nTotc:=nTotd:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

	// !!!!!!!!!!!!!!!
	if idpartner+brfaktp+idkonto+idkonto2<>cidd
		Beep(2)
		Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
	endif

	KTroskovi()

	select ROBA
	HSEEK PRIPR->IdRoba
	select TARIFA
	HSEEK PRIPR->IdTarifa
	select PRIPR

	if prow()-gPStranica>59
		FF
		@ prow(),125 SAY "Str:"+str(++nStr,3)
	endif

	SKol:=Kolicina

	@ prow()+1,0 SAY  Rbr PICTURE "XXX"
	@ prow(),4 SAY  ""

	if (IsJerry())
		?? idroba, LEFT(ROBA->naz,LEN(ROBA->naz)-13),"("+ROBA->jmj+")"
	else
		?? idroba, trim(ROBA->naz),"(",ROBA->jmj,")"
	endif

	if gRokTr=="D"
		?? space(4),"Rok Tr.:",RokTr
	endif

	if (IsJerry())
		nPosKol:=1
		@ prow(),pcol()+1 SAY IdTarifa
	else
		nPosKol:=30
		@ prow()+1,4 SAY IdTarifa+space(4)
	endif

	if cSamoObraz=="D"
		@ prow(),pcol()+nPosKol SAY Kolicina  PICTURE replicate("_",len(PicKol))
		@ prow(),pcol()+1 SAY GKolicina  PICTURE replicate(" ",len(PicKol))
	else
		@ prow(),pcol()+nPosKol SAY Kolicina  PICTURE PicKol
		@ prow(),pcol()+1 SAY GKolicina  PICTURE PicKol
	endif

	nC1:=pcol()+1

	if cSamoObraz=="D"
		@ prow(),pcol()+1 SAY fcj           PICTURE replicate(" ",len(PicDEM))
		@ prow(),pcol()+1 SAY kolicina*mpcsapp    PICTURE replicate("_",len(PicDEM))
		@ prow(),pcol()+1 SAY Kolicina-GKolicina  PICTURE replicate(" ",len(PicKol))
	else
		@ prow(),pcol()+1 SAY fcj           PICTURE Picdem // knjizna vrijednost
		@ prow(),pcol()+1 SAY kolicina*mpcsapp    PICTURE Picdem
		@ prow(),pcol()+1 SAY Kolicina-GKolicina  PICTURE PicKol
	endif

	@ prow(),pcol()+1 SAY MPCSAPP             PICTURE PicCDEM

	nTotb+=fcj
	nTotc+=kolicina*mpcsapp
	nTot4+=  (nU4:= MPCSAPP*Kolicina-fcj)

	if cSamoObraz=="D"
		@ prow(),pcol()+1 SAY nU4  pict replicate(" ",len(PicDEM))
	else
		@ prow(),pcol()+1 SAY nU4  pict picdem
	endif

	skip 1

enddo


if prow()-gPStranica>58
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

if cSamoObraz=="D"
	? m
	?
	?
	? space(80),"Clanovi komisije: 1. ___________________"
	? space(80),"                  2. ___________________"
	? space(80),"                  3. ___________________"
	return
endif

? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nc1      SAY nTotb  pict picdem
@ prow(),pcol()+1 SAY nTotc  pict picdem
@ prow(),pcol()+1 SAY 0      pict picdem
@ prow(),pcol()+1 SAY 0      pict picdem
@ prow(),pcol()+1  SAY nTot4  pict picdem
? m

RekTarife()

if !fZaTops
	?
	?
	? "Napomena: Ovaj dokument, ako se azurira smatrace se izlazom za kolicinu manjka !!!"
	?
endif
return
*}




/*! \fn StObrazSL()
 *  \brief Stampa forme obrasca sank liste
 */

function StObrazSL()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2


P_10CPI
select konto; hseek cidkonto; select pripr
?? "INVENTURA PRODAVNICA ",cidkonto,"-",konto->naz
P_COND
?
? "DOKUMENT BR. :",cIdFirma+"-"+cIdVD+"-"+cBrDok, SPACE(2),"Datum:",DatDok
?
@ prow(),125 SAY "Str:"+str(++nStr,3)

select PRIPR

m:="--- -------------------------------------------- ------ ---------- ---------- ---------- --------- ----------- -----------"
? m
? "*R *                                            *      *  Pocetne * Primljena*  Zavrsna * Prodajna * Cijena  *   Iznos  *"
? "*BR*               R O B A                      *Tarifa*  zalihe  *  kolicina*  zaliha  * kolicina *         */realizac.*"
? m
nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=ntotb:=ntotc:=nTotd:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    // !!!!!!!!!!!!!!!
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
    	Beep(2)
    	Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
    endif

    KTroskovi()

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    if prow()-gPStranica>59
    	FF
    	@ prow(),125 SAY "Str:"+str(++nStr,3)
    endif

    SKol:=Kolicina

    @ prow()+1,0 SAY  Rbr PICTURE "XXX"
    @ prow(),4 SAY  ""
    ?? idroba, LEFT(ROBA->naz,LEN(ROBA->naz)-13),"("+ROBA->jmj+")"
    nPosKol:=1
    @ prow(),pcol()+1 SAY IdTarifa
    if gcSLObrazac=="2"
	   @ prow(),pcol()+nPosKol SAY Kolicina  PICTURE PicKol
    else
	   @ prow(),pcol()+nPosKol SAY GKolicina  PICTURE PicKol
    endif
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY MPCSAPP             PICTURE PicCDEM
    nTotb+=fcj
    ntotc+=kolicina*mpcsapp
    nTot4+=  (nU4:= MPCSAPP*Kolicina-fcj)

    @ prow(),pcol()+1 SAY nU4  pict replicate("_",len(PicDEM))
    skip

enddo


if prow()-gPStranica>58
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

? m
return
*}




