#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_olpp.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.5 $
 * $Log: rpt_olpp.prg,v $
 * Revision 1.5  2003/12/22 14:58:26  sasavranic
 * Dodata rekapitulacija tarifa na OLPP
 *
 * Revision 1.4  2003/11/11 14:06:35  sasavranic
 * Uvodjenje f-je IspisNaDan()
 *
 * Revision 1.3  2002/12/30 01:30:24  mirsad
 * ispravke bugova-Planika
 *
 * Revision 1.2  2002/06/21 12:12:29  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_olpp.prg
 *  \brief Izvjestaj "obracunski list poreza na promet" (OLPP)
 */


/*! \fn StOLPP()
 *  \brief Izvjestaj "obracunski list poreza na promet" (OLPP)
 */

function StOLPP()
*{
local ik
local cPrviKTO
local nMirso:=0
local nsMir1:=0
local nsMir2:=0
local ii:=0
local nArr

gOstr:="D"
gnRedova:=gPStranica+64
picdem:="99999999.99"

SELECT PRIPR

cIdFirma := IDFIRMA
cIdVd    := IDVD
cBrDok   := BRDOK

m:="ÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ"

nC1:=10
nC2:=25
nC3:=40
nC4:=0
nC5:=0


// radi 80-ke prodji 2 puta
for ik:=1 to 2
	START PRINT RET
	nU1:=nU2:=nU3:=nU4:=0
	if ik=2 // drugi konto
  		// dodji do drugog konta
   		HSEEK cIdFirma+cIdVD+cBrDok
   		do while !eof()  .and. pkonto==cPrviKTO
     			skip
  		enddo
 	else
   		cPrviKTO := pkonto
 	endif
	ZOlPP()
	private nColR:=10
	aRekPor:={}
	DO WHILE !EOF() .and. cIdfirma+cIdVd+cBrDok==IDFIRMA+IDVD+BRDOK
		if (pkonto==cPrviKTO  .and. ik=2) .or. (pkonto != cPrviKTO  .and. ik=1)
        		// ako se po drugi put nalazis u petlji i stavka je prvi konto
        		// onda preskoci
        		skip
			loop
   		endif
		SELECT ROBA
   		HSEEK PRIPR->IDROBA
   		SELECT PRIPR

   		aPorezi:={}
   		cTarifa:=Tarifa(PRIPR->pkonto,ROBA->id,@aPorezi)

   		nMpCSaPP := mpcsapp

   		if .f. // kolicina==0   // nivelacija:TNAM
     			nMPC1 := MpcBezPor( iznos , aPorezi )
     			nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )
     			// nMPC2:=Iznos/(1+tarifa->ppp/100)
     			// nMPC1:=nMPC2/(1+tarifa->opp/100)
   		else
     			nMPC1 := MpcBezPor( nMPCSaPP , aPorezi )
     			nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )
     			// nMPC2:=nMPCSaPP/(1+tarifa->ppp/100)
     			// nMPC1:=nMPC2/(1+tarifa->opp/100)
   		endif
		if prow()>gnRedova-2 .and. gOstr=="D"
   			FF
			ZOlPP()
   		endif
                // bilo:  EJECTNA0
   		// 1. Redni broj
		? rbr
   		nColR:=pcol()+1
		aRoba:=SjeciStr(roba->naz,20)
   		// 2. Naziv robe
		@ prow(),pcol()+1 SAY aRoba[1]
   		// 3. Jedinica mjere
		@ prow(),pcol()+1 SAY roba->jmj
		nPom:=at("/",idtarifa)
   		IF nPom>0
    			cT1:=padr( left(ctarifa,npom-1),2)
    			cT2:=padr( substr(ctarifa,npom+1) ,2)
   		ELSE
    			cT1:=LEFT(ctarifa,1)+" "
    			cT2:="  "
   		ENDIF
		// 4. Kolicina
		@ prow(),pcol()+1 say kolicina pict pickol
		// 5. MPC Bez PPP - pojedina
		@ prow(),pcol()+1 say nMPC1 pict "99999999.99"
   		nC1:=pcol()+1
		// 6. MPC Bez PPP - ukupna
		@ prow(),pcol()+1 say nMPC1*kolicina pict picdem
		// 7. PPP - tarifni broj
		@ prow(),pcol()+1 say cT1
		// 8. PPP - stopa
		@ prow(),pcol()+1 say tarifa->opp pict "99.9"; ?? "%"
   		nC4:=pcol()+1
		// 9. PPP - iznos
		@ prow(),pcol()+1 say (nMirso:=(nMPC2-nMPC1)*kolicina) pict "999999.99"
   		nsMir1+=nMirso
		// 10. MPC Sa PPP - pojedina
		@ prow(),pcol()+1 say nMPC2 pict "9999999.99"
   		nC2:=pcol()+1
		// 11. MPC Sa PPP - ukupna
		@ prow(),pcol()+1 say nMPC2*kolicina pict picdem
  		// 12. Poseban porez - tarifni broj
		@ prow(),pcol()+1 say cT2
		// 13. Poseban porez - stopa
		@ prow(),pcol()+1 say aPorezi[POR_PP] pict "99.9"; ?? "%"
   		IF .f. // kolicina==0   // nivelacija:TNAM
     			nPor:=MpcBezPor( iznos , aPorezi )
     			// nPor:=iznos/(1+tarifa->opp/100)/(1+tarifa->ppp/100)
   		ELSE
     			nPor:=Izn_P_PP(nMPC1, aPorezi)+Izn_P_PPP(nMPC1, aPorezi)
     			// nPor:=nMPC1*tarifa->opp/100+nMPC2*tarifa->ppp/100
   		ENDIF
   		nC5:=pcol()+1
		// 14. Poseban porez - iznos
		@ prow(),pcol()+1 say nPor*kolicina-nMirso pict "999999.99"
   		nsMir2+=(nPor*kolicina-nMirso)
		// 15. MPC SA PP + Posebni porez - pojedina
		@ prow(),pcol()+1 say nMPCSAPP pict picdem
   		nC3:=pcol()+1
		if .f. // kolicina==0     // nivelacija:TNAM
     			// 16. MPC Sa PP + posebni porez - ukupno
			@ prow(),pcol()+1 say Iznos pict picdem
     			// 17. PP Ukupno
			@ prow(),pcol()+1 say  nPor pict picdem
     			nU1+=nMpc1
			nU2+=nMpc2
     			nU3+=iznos
     			nU4+=nPor
   		else
     			// 16. MPC Sa PP + posebni porez - ukupno
     			@ prow(),pcol()+1 say nMPCSAPP*kolicina pict picdem
     			// 17. PP Ukupno
			@ prow(),pcol()+1 say  nPor*kolicina pict picdem
     			nU1+=nMpc1*kolicina
			nU2+=nMPC2*kolicina
     			nU3+=nMPCsaPP*kolicina
			nU4+=nPor*kolicina
   		endif
		//   aRekPor       TB,  mpcbezpp     ,  ppp   ,  mpcsapp 
   		AADD(aRekPor, { cT1, nMpc1*kolicina, (nMpc2-nMpc1)*kolicina, nMpc2*kolicina})
		for ii=2 to len(aRoba)
    			@ prow()+1,nColR SAY aRoba[ii]
   		next
		skip 1
	ENDDO
	if prow()>gnRedova-4 .and. gOstr=="D"
		FF
		ZOlPP()
	endif
        // bilo:  EJECTNA0
	? m
 	? "Ukupno :"
 	@ prow(),nC1 SAY nu1 pict picdem
 	@ prow(),nC4 SAY nsMir1 pict "999999.99"
 	@ prow(),nC2 SAY nu2 pict picdem
 	@ prow(),nC5 SAY nsMir2 pict "999999.99"
 	@ prow(),nC3 SAY nu3 pict picdem
 	@ prow(),PCol()+1 SAY nu4 pict picdem
 	? STRTRAN(m," ","Ä")
 	?
	// rekap. tarifa
	
	? "---------------------------------"
	? "Rekapitulacija tarifa:"
	? "---------------------------------"
	? "TB      PPP%   PPU%   PP%      MPV          PPP         PPU          PP      MPCSAPP"
	? "------------------------------------------------------------------------------------------"
	nArr:=SELECT()
	select tarifa
	go top
	do while !EOF()
		nCount:=0
		nUkMPCBezPP:=0
		nUkPPP:=0
		nUkPP:=0
		nUkPPU:=0
		nUkMPCSaPP:=0
		altd()
		for i:=1 to LEN(aRekPor)
			if ALLTRIM(field->id)==ALLTRIM(aRekPor[i, 1])	
				++ nCount
				nUkMPCBezPP+=aRekPor[i, 2]
				nUkPPP+=aRekPor[i, 3]
				nUKMPCSaPP+=aRekPor[i, 4]
				nUkPP+=0
				nUkPPU+=0
			endif
		next
		if nCount>0
			? field->id
			@ PRow(), PCol()+1 SAY ALLTRIM(STR(field->opp))+"%"
			@ PRow(), PCol()+1 SAY ALLTRIM(STR(field->ppp))+"%"
			@ PRow(), PCol()+1 SAY ALLTRIM(STR(field->zpp))+"%"
			@ PRow(), PCol()+1 SAY nUkMPCBezPP pict picdem
			@ PRow(), PCol()+1 SAY nUkPPP pict picdem
			@ PRow(), PCol()+1 SAY nUkPP pict picdem
			@ PRow(), PCol()+1 SAY nUkPPU pict picdem
			@ PRow(), PCol()+1 SAY nUkMPCSaPP pict picdem
			skip
		else
			skip
		endif
	enddo
	
	select (nArr)
	FF
	END PRINT
	if cidvd<>"80"    // ako nije 80-ka samo jednom prodji
		exit
	endif

next  // ik

return
*}




/*! \fn ZOLPP()
 *  \brief Zaglavlje izvjestaja "obracunski list poreza na promet" (OLPP)
 */

function ZOLPP()
*{
local cNaslov:=StrKZN("OBRA^UNSKI LIST POREZA NA PROMET","7",gKodnaS),cPom1,cPom2,c
ZagFirma()
IspisNaDan(20)
@ prow()+1,35 SAY cNaslov
?
select partn
hseek pripr->idpartner
select pripr
@ prow()+1,20 SAY "Po dokumentu: "+idvd+"-"+brdok
//cPom1:=partn->naz
//cPom2:=partn->mjesto
//?? cPom1, StrKZN("Sjedi{te:","7",gKodnaS)  //, cPom2
?? StrKZN("Sjedi{te:","7",gKodnaS)
@ prow()+1,33 SAY "Broj: "; ?? brfaktp,"od:",SrediDat(datfaktp)
P_COND2
?  StrKZN("ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿","7",gKodnaS)
?  StrKZN("³  ³                    ³   ³          ³   Prod.cijena bez por.³ Porez na promet  ³ Prodajna cijena sa   ³  Poseban porez   ³  Prod.cij.sa porezom  ³ Porez na ³","7",gKodnaS)
c:="³R.³       Naziv        ³jed³ koli~ina ³   na promet proizvoda ³    proizvoda     ³ porezom na pr.proizv.³                  ³na prom.proiz.i pos.por³  promet  ³"
? StrKZN(c,"7",gKodnaS)
?  StrKZN("³br³                    ³mj.³          ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÅÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÅÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ´          ³","7",gKodnaS)
?  StrKZN("³  ³                    ³   ³          ³ Pojedin.  ³   Ukupna  ³TB³Stopa³ Iznos   ³ Pojedin. ³  Ukupna   ³TB³Stopa³ Iznos   ³  Pojedin. ³  Ukupna   ³  UKUPNO  ³","7",gKodnaS)
?  StrKZN("ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ","7",gKodnaS)
return
*}



