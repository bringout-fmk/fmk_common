#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_im.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.5 $
 * $Log: rpt_im.prg,v $
 * Revision 1.5  2004/01/19 13:13:55  sasavranic
 * Pri generaciji IM magacina, pita za cijene VPC ili NC
 *
 * Revision 1.4  2004/01/09 08:49:09  sasavranic
 * Na stampi invent.magacina prikaz VPC ili ne
 *
 * Revision 1.3  2002/06/26 17:53:45  ernad
 *
 *
 * ciscenje, inventura magacina
 *
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/rpt_im.prg
 *  \brief Stampa kalkulacije tipa IM
 */


/*! \fn StKalkIM()
 *  \brief Stampa kalkulacije tipa IM
 */

function StKalkIM()
*{
local nCol1:=0
local nCol2:=0
local nPom:=0

private nPrevoz
private nCarDaz
private nZavTr
private nBankTr
private nSpedTr
private nMarza
private nMarza2

// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

cSamoObraz:=Pitanje(,"Prikaz samo obrasca inventure? (D/N)")

cPrikazCijene:="D"
if cSamoObrazac=="D"
	cPrikazCijene:=Pitanje(,"Prikazati cijenu na obrascu? (D/N)")
endif

cCijenaTip:=Pitanje(,"Na obrascu prikazati VPC (D) ili NC (N)?")

P_10CPI
SELECT konto
HSEEK cIdkonto
SELECT pripr
?? "INVENTURA MAGACIN ",cidkonto,"-",konto->naz
P_COND2
?
? "DOKUMENT BR. :",cIdFirma+"-"+cIdVD+"-"+cBrDok, SPACE(2),"Datum:",DatDok
?
@ prow(),125 SAY "Str:"+str(++nStr,3)


select PRIPR
m:="--- --------------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -----------"
? m
?  "*R * ROBA                                  *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika *  Cijena  *   VISAK  *  MANJAK  *"
?  "*BR* TARIFA                                *  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *          *          *          *"
? m

nTot4:=0
nTot5:=0
nTot6:=0
nTot7:=0
nTot8:=0
nTot9:=0
nTota:=0
nTotb:=0
nTotc:=0
nTotd:=0

private cIdd:=idPartner+brFaktP+idKonto+idKonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVd

    KTroskovi()
    RptSeekRT()
    DokNovaStrana(125, @nStr, 3)
    SKol:=Kolicina
    
    if cCijenaTIP=="N"
    	nCijena:=field->nc
    else
    	nCijena:=field->vpc
    endif
    
    @ prow()+1,0 SAY  Rbr PICTURE "XXX"
    @ prow(),4 SAY  ""
    ?? idroba, trim(ROBA->naz),"(",ROBA->jmj,")"
    
/* niko ne koristi
    if gRokTr=="D"
    	?? space(4),"Rok Tr.:",RokTr
    endif
 */  
 
    @ prow()+1,4 SAY IdTarifa+space(4)
    if cSamoObraz=="D"
      @ prow(),pcol()+30 SAY Kolicina  PICTURE replicate("_",len(PicKol))
      @ prow(),pcol()+1 SAY GKolicina  PICTURE replicate(" ",len(PicKol))
    else
      @ prow(),pcol()+30 SAY Kolicina  PICTURE PicKol
      @ prow(),pcol()+1 SAY GKolicina  PICTURE PicKol
    endif
    nC1:=pcol()+1

    if cSamoObraz=="D"
     @ prow(),pcol()+1 SAY gkolicina*nCijena  PICTURE replicate(" ",len(PicDEM))
     @ prow(),pcol()+1 SAY kolicina*nCijena   PICTURE replicate("_",len(PicDEM))
     @ prow(),pcol()+1 SAY Kolicina-GKolicina  PICTURE replicate(" ",len(PicKol))
    else
     @ prow(),pcol()+1 SAY gkolicina*nCijena PICTURE Picdem // knjizna vrijednost
     @ prow(),pcol()+1 SAY kolicina*nCijena  PICTURE Picdem // popisana vrijednost
     @ prow(),pcol()+1 SAY Kolicina-GKolicina  PICTURE PicKol // visak-manjak
    endif
    if (cPrikazCijene=="D")
    	@ prow(),pcol()+1 SAY nCijena  PICTURE PicCDEM // veleprodajna cij
    else
    	@ prow(),pcol()+1 SAY nCijena  PICTURE replicate(" ", LEN(PicDEM))
    endif
    nTotb+=fcj
    nTotc+=kolicina*nCijena
    nU4 := nCijena*(Kolicina-gKolicina)
    nTot4 += nU4
    if cSamoObraz=="D"
	      @ prow(),pcol()+1 SAY nU4  pict replicate(" ",len(PicDEM))
    else
	      @ prow(),pcol()+1 SAY nU4 pict IF(nU4>0,picdem,replicate(" ",len(PicDEM)))
	      @ prow(),pcol()+1 SAY IF(nU4<0,-nU4,nU4) pict IF(nU4<0,picdem,replicate(" ",len(PicDEM)))
    endif

    skip

enddo

DokNovaStrana(125, @nStr, 5)

if cSamoObraz=="D"
	PrnClanoviKomisije()
  	return
endif

? m
@ prow()+1,0 SAY "Ukupno:"
@ prow(),nc1 SAY nTotb  pict gPicDem
@ prow(),pcol()+1 SAY nTotc  pict gPicDem
@ prow(),pcol()+1 SAY 0      pict gPicDem
@ prow(),pcol()+1 SAY 0      pict gPicDem
@ prow(),pcol()+1 SAY nTot4  pict IF(nTot4>0, gPicDem, REPLICATE(" ", LEN(PicDEM)))
@ prow(),pcol()+1 SAY IF(nTot4<0,-nTot4,nTot4)  pict IF(nTot4<0,gPicDem,replicate(" ",len(gPicDem)))

? m
return
*}

