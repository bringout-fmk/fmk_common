#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_all.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.11 $
 * $Log: rpt_all.prg,v $
 * Revision 1.11  2004/01/07 13:43:27  sasavranic
 * Korekcija algoritama za tarife, ako je bilo promjene tarifa
 *
 * Revision 1.10  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.9  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.8  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.7  2003/06/23 09:31:20  sasa
 * prikaz dobavljaca
 *
 * Revision 1.6  2003/02/10 02:19:24  mirsad
 * no message
 *
 * Revision 1.5  2002/07/22 14:15:56  mirsad
 * dodao proracun poreza u ugostiteljstvu (varijante "M" i "J")
 *
 * Revision 1.4  2002/07/22 07:07:45  mirsad
 * dodao f-je za izracunavanje PPU i PPP u maloprodajnim izvještajima
 *
 * Revision 1.3  2002/07/19 14:00:03  mirsad
 * prilagodba za prikaz PRUC MP umjesto PPU MP
 *
 * Revision 1.2  2002/06/21 12:12:43  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_all.prg
 *  \brief Ove funkcije koristi vise izvjestaja (primjer RekTarife)
 */


/*! \fn RekTarife()
 *  \brief Nova funkcija RekTarife - koristi proracun poreza iz roba/tarife.prg
 * prosljedjuje se cidfirma,cidvd,cbrdok
 */
 
function RekTarife()
*{
local aPKonta
local nIznPRuc
private aPorezi
altd()

IF prow()>55+gPStranica
	FF
	@ prow(),123 SAY "Str:"+str(++nStr,3)
endif
nRec:=recno()
select pripr
set order to 2
seek cIdFirma+cIdVd+cBrDok
m:="------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
? m
?  "* Tar.*  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *    PP    * MPVSAPP *"
? m

aPKonta:=PKontoCnt(cIdFirma+cIdvd+cBrDok)
nCntKonto:=len(aPKonta)

aPorezi:={}

for i:=1 to nCntKonto
	seek cIdFirma+cIdVd+cBrdok

	nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
	nTot5:=nTot6:=nTot7:=0
	do while !eof() .and. cIdFirma+cIdVd+cBrDok==idfirma+idvd+brdok
  		if aPKonta[i]<>field->PKONTO
    			skip
    			loop
  		endif

  		cIdtarifa:=idtarifa
  		// mpv
		nU1:=0
		// ppp
		nU2:=0
		// ppu
		nU3:=0
		// pp
		nU4:=0
		// mpv sa porezom
		nU5:=0
		
	  	select tarifa
		hseek cIdtarifa
	  	select pripr
  		do while !eof() .and. cIdfirma+cIdvd+cBrDok==idfirma+idvd+brdok .and. idTarifa==cIdTarifa

	    		if aPKonta[i]<>field->PKONTO
      				skip
      				loop
	    		endif
    	
			select roba
			hseek pripr->idroba
	
			Tarifa(pripr->pkonto, pripr->idRoba, @aPorezi, cIdTarifa)
			select pripr
		
    			VtPorezi()

			nMpc:=DokMpc(field->idvd,aPorezi)
			if field->idvd=="19"
    				// nova cijena
    				nMpcSaPP1:=field->mpcSaPP+field->fcj
    				nMpc1:=MpcBezPor(nMpcSaPP1,aPorezi,,field->nc)
    				aIPor1:=RacPorezeMP(aPorezi,nMpc1,nMpcSaPP1,field->nc)
    
    				// stara cijena
    				nMpcSaPP2:=field->fcj
    				nMpc2:=MpcBezPor(nMpcSaPP2,aPorezi,,field->nc)
    				aIPor2:=RacPorezeMP(aPorezi,nMpc2,nMpcSaPP2,field->nc)
				aIPor:={0,0,0}
				aIPor[1]:=aIPor1[1]-aIPor2[1]
				aIPor[2]:=aIPor1[2]-aIPor2[2]
				aIPor[3]:=aIPor1[3]-aIPor2[3]
			else
				aIPor:=RacPorezeMP(aPorezi,nMpc,field->mpcSaPP,field->nc)
			endif
			nKolicina:=DokKolicina(field->idvd)
			nU1+=nMpc*nKolicina
			nU2+=aIPor[1]*nKolicina
			nU3+=aIPor[2]*nKolicina
			nU4+=aIPor[3]*nKolicina
    			nU5+=field->mpcSaPP*nKolicina
			// ukupna bruto marza
			nTot6+=(nMpc-pripr->nc)*nKolicina
    			skip 1
	  	enddo
		nTot1+=nU1
		nTot2+=nU2
		nTot3+=nU3
		nTot4+=nU4
		nTot5+=nU5
  
		//nTot6+=(mpc-nc)*nKolicina
		? cIdTarifa
  
		@ prow(),pcol()+1   SAY aPorezi[POR_PPP] pict picproc
		@ prow(),pcol()+1   SAY PrPPUMP() pict picproc
		@ prow(),pcol()+1   SAY aPorezi[POR_PP] pict picproc
  
		nCol1:=pcol()+1
		@ prow(),pcol()+1   SAY nU1 pict picdem
		@ prow(),pcol()+1   SAY nU2 pict picdem
		@ prow(),pcol()+1   SAY nU3 pict picdem
		@ prow(),pcol()+1   SAY nU4 pict picdem
		@ prow(),pcol()+1   SAY nU5 pict picdem
	enddo

	if prow()>56+gPStranica
		FF
		@ prow(),123 SAY "Str:"+str(++nStr,3)
	endif
	
	? m
	? "UKUPNO "+aPKonta[i]
	@ prow(),nCol1      SAY nTot1 pict picdem
	@ prow(),pcol()+1   SAY nTot2 pict picdem
	@ prow(),pcol()+1   SAY nTot3 pict picdem
	@ prow(),pcol()+1   SAY nTot4 pict picdem
	@ prow(),pcol()+1   SAY nTot5 pict picdem
	? m
next

set order to 1
go nRec
return
*}

/*
static function RekTar_Leg()
*{
local aPKonta

IF prow()>55+gPStranica; FF; @ prow(),123 SAY "Str:"+str(++nStr,3);  endif
nRec:=recno()
select pripr
set order to 2
seek cidfirma+cidvd+cbrdok
m:="------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
? m
?  "* Tar *  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *    PP    * MPVSAPP *"
? m

aPKonta:=PKontoCnt(cIdFirma+cIdvd+cBrDok)
nCntKonto:=len(aPKonta)

for i:=1 to nCntKonto
seek cIdFirma+cIdVd+cBrdok

nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
do while !eof() .and. cidfirma+cidvd+cbrdok==idfirma+idvd+brdok
  if aPKonta[i]<>field->PKONTO
    skip
    loop
  endif

  cidtarifa:=idtarifa
  nU1:=nU2:=nU2b:=0;nU3:=nU4:=0
  select tarifa; hseek cidtarifa
  select pripr
  do while !eof() .and. cidfirma+cidvd+cbrdok==idfirma+idvd+brdok .and. idtarifa==cidtarifa

    if aPKonta[i]<>field->PKONTO
      skip
      loop
    endif
    select roba; hseek pripr->idroba; select pripr
    VtPorezi()

    if idvd=="IP"
    	nKolicina:=gkolicin2
    else
    	nKolicina:=kolicina
    endif

    nU1+=mpc*nKolicina
    nU2+=PPPMP()*nKolicina

    IF gUVarPP=="T"
      scatter()
      nNc:=pripr->nc
      nPom:=pripr->mpcsapp-nNc-PPPMP()
      nPRUC   := MAX( mpcsapp*_dlruc, nPom) *_mpp/(1+_mpp)
      nMarza2 := nPom-nPRUC
      nU2b+=(mpcsapp-nPRUC)*_ZPP*nKolicina
      nU3+=nPRUC*nKolicina
    ELSEIF gUVarPP=="R"
      scatter()  // formiraj varijable
      Marza2(); nMarza:=_marza   // izracunaj nMarza,nMarza2
      nPom    := nMarza2
      nPRUC   := MAX( mpcsapp*_dlruc , nPom ) *_mpp/(1+_mpp)
      nMarza2 := nPom-nPRUC
      nU2b+=(mpcsapp-nPRUC)*_ZPP*nKolicina
      nU3+=nPRUC*nKolicina
    ELSEIF gUVarPP$"MJ"
      nPRUC:=PPUMP()
      nU3+=nPRUC*nKolicina
      nU2b+=(mpcsapp-nPRUC)*_ZPP*nKolicina
    ELSEIF gUVarPP=="D"
      nU2b+=mpc*(1+_OPP)*_ZPP*nKolicina
      nU3+=PPUMP()*nKolicina
    ELSE
      nU2b+=mpc*_ZPP*nKolicina
      nU3+=PPUMP()*nKolicina
    ENDIF

    nU4+=mpcsapp*nKolicina
    if roba->tip=="V"  // marza mp
      nTot5+=((mpc-vpc)+vpc/(1+_PORVT)-nc)*nKolicina
    else
      nTot5+=(mpc-nc)*nKolicina
    endif
    nTot6+=(vpc/(1+_PORVT)-fcj)*nKolicina
    skip
  enddo
  nTot1+=nu1; nTot2+=nU2;nTot2b+=nU2b; nTot3+=nU3
  nTot4+=nU4
  ? cidtarifa
  @ prow(),pcol()+1   SAY _OPP*100 pict picproc
  @ prow(),pcol()+1   SAY PrPPUMP() pict picproc
  @ prow(),pcol()+1   SAY _ZPP*100 pict picproc
  nCol1:=pcol()+1
  @ prow(),pcol()+1   SAY nu1 pict picdem
  @ prow(),pcol()+1   SAY nu2 pict picdem
  @ prow(),pcol()+1   SAY nu3 pict picdem
  @ prow(),pcol()+1   SAY nu2b pict picdem
  @ prow(),pcol()+1   SAY nu4 pict picdem
enddo
IF prow()>56+gPStranica; FF; @ prow(),123 SAY "Str:"+str(++nStr,3);  endif
? m
? "UKUPNO "+aPKonta[i]
@ prow(),nCol1      SAY nTot1 pict picdem
@ prow(),pcol()+1   SAY nTot2 pict picdem
@ prow(),pcol()+1   SAY nTot3 pict picdem
@ prow(),pcol()+1   SAY nTot2b pict picdem
@ prow(),pcol()+1   SAY nTot4 pict picdem
? m
next

set order to 1
go nRec
return
*}
*/



/*! \fn PKontoCnt(cSeek)
 *  \brief Kreira niz prodavnickih konta koji se nalaze u zadanom dokumentu
 *  \param cSeek - firma + tip dok + broj dok
 */

function PKontoCnt(cSeek)
*{
local nPos, aPKonta
aPKonta:={}
// baza: PRIPR, order: 2
seek cSeek
do while !eof() .and. (IdFirma+Idvd+BrDok)=cSeek
  nPos:= ASCAN(aPKonta, PKonto)
  if nPos<1
    AADD(aPKonta, PKonto)
  endif
  skip
enddo

return aPKonta
*}


/*
function PPUMP(nMarza)
*{
local nVrati
if nMarza=nil
	nMarza:=0
endif
if (gUVarPP$"JM" .and. _mpp>0)
	nVrati := field->mpcSaPP*_dlRUC*_mpp/(1+_mpp)
elseif gUVarPP=="T"
	nVrati := nMarza*_mpp/(1+_mpp)
else
	nVrati := field->mpc*(1+_opp)*_ppp
endif
return nVrati
*}



function PPPMP()
*{
local nVrati
	if (gUVarPP$"MT")
		nVrati := field->mpcsapp*_OPP/(1+_OPP)
	else
		nVrati := field->mpc*_OPP
	endif
return nVrati
*}
*/



function DokKolicina(cIdVd)
*{
local nKol
if cIdVd=="IP"
	nKol:=field->gkolicin2
else
	nKol:=field->kolicina
endif
return nKol
*}



function DokMpc(cIdVd,aPorezi)
*{
local nMpc
if cIdVd=="IP"
	nMpc:=MpcBezPor(field->mpcSaPP,aPorezi,,field->nc)
else
	nMpc:=field->mpc
endif
return nMpc
*}




