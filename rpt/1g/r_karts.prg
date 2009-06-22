#include "ld.ch"

static DUZ_STRANA := 64

// -------------------------------------------------
// kartica plate - samostalni poduzetnik
// -------------------------------------------------
function kartpls( cIdRj, cMjesec, cGodina, cIdRadn, cObrac, aNeta )
local nKRedova
local cDoprSpace := SPACE(3)
local cTprLine 
local cDoprLine 
local cMainLine 
private cLMSK := ""	

cTprLine := _gtprline()
cDoprLine := _gdoprline(cDoprSpace)
cMainLine := _gmainline()

// koliko redova ima kartica
nKRedova := kart_redova()

Eval(bZagl)

cUneto := "D"
nRRsati := 0 
nOsnNeto := 0
nOsnOstalo := 0
//nLicOdbitak := g_licni_odb( radn->id )
nLicOdbitak := ld->ulicodb
nKoefOdbitka := radn->klo
cRTipRada := g_tip_rada( ld->idradn, ld->idrj ) 
nRPrKoef := 0
if radn->(FIELDPOS("SP_KOEF")) <> 0
	nRPrKoef := radn->sp_koef
endif

for i:=1 to cLDPolja
	
	cPom := padl(alltrim(str(i)),2,"0")
	
	select tippr
	seek cPom
	
	if tippr->(found()) .and. tippr->aktivan=="D"

		if _i&cpom<>0 .or. _s&cPom<>0
			
			if tippr->(FIELDPOS("TPR_TIP")) <> 0
			  // uzmi osnovice
			  if tippr->tpr_tip == "N"
				nOsnNeto += _i&cPom
			  elseif tippr->tpr_tip == "2"
				nOsnOstalo += _i&cPom
			  elseif tippr->tpr_tip == " "
				// standardni tekuci sistem
				if tippr->uneto == "D"
					nOsnNeto += _i&cPom
				else
					nOsnOstalo += _i&cPom
				endif
			  endif
			else
				// standardni tekuci sistem
				if tippr->uneto == "D"
					nOsnNeto += _i&cPom
				else
					nOsnOstalo += _i&cPom
				endif
			endif
			
				
			if "SUMKREDITA" $ tippr->formula
				
				select radkr
				set order to 1
				seek str(_godina,4) + str(_mjesec,2) + _idradn
				ukredita:=0
				
				
				do while !eof() .and. _godina==godina .and. _mjesec=mjesec .and. idradn==_idradn
					select kred
					hseek radkr->idkred
					select radkr
					aIznosi:=OKreditu(idradn, idkred, naosnovu, _mjesec, _godina)
					ukredita+=iznos
					skip 1
				enddo
				
				select ld
			endif
		endif
	endif
next

if gPrBruto=="D"  
	
	// prikaz bruto iznosa
	
	select (F_POR)
	
	if !used()
		O_POR
	endif
	
	select (F_DOPR)
	
	if !used()
		O_DOPR
	endif
	
	select (F_KBENEF)
	
	if !used()
		O_KBENEF
	endif

	nBO:=0
	nBFO:=0
	
	nOsnZaBr := nOsnNeto
	
	nBo := bruto_osn( nOsnZaBr, cRTipRada, nLicOdbitak, nRPrKoef )

	? cMainLine
	? cLMSK + "1. OSNOVA ZA OBRACUN:"

	@ prow(),60+LEN(cLMSK) SAY nOsnZaBr pict gpici
	
	? cMainLine
	? cLMSK + "2. PROPISANI KOEFICIJENT:"

	@ prow(),60+LEN(cLMSK) SAY nRPrKoef pict gpici
	
	? cMainLine
	? cLMSK + "3. BRUTO OSNOVA :  ", bruto_isp( nOsnZaBr, cRTipRada, nLicOdbitak, nRPrKoef )

	@ prow(),60+LEN(cLMSK) SAY nBo pict gpici
	
	? cMainLine
	
	// razrada doprinosa ....
	
	? cLmSK + cDoprSpace + Lokal("Obracun doprinosa:")
	
	select dopr
	go top
	
	nPom := 0
	nDopr := 0
	nUkDoprIz := 0
	nC1 := 20 + LEN(cLMSK)
	
	do while !eof()
	
		if dopr->tiprada <> "S"
			skip
			loop
		endif

		if dopr->(FIELDPOS("DOP_TIP")) <> 0
			
			if dopr->dop_tip == "N" .or. dopr->dop_tip == " " 
				nOsn := nOsnNeto
			elseif dopr->dop_tip == "2"
				nOsn := nOsnOstalo
			elseif dopr->dop_tip == "P"
				nOsn := nOsnNeto + nOsnOstalo
			endif
		
		endif
		
		PozicOps(DOPR->poopst)
			
		IF !ImaUOp("DOPR",DOPR->id) .or. !lPrikSveDopr .and. !DOPR->ID $ cPrikDopr
			SKIP 1
			LOOP
		ENDIF
		
		if right(id,1)=="X"
			? cDoprLine
		endif
		
		? cLMSK + cDoprSpace + id, "-", naz
		@ prow(),pcol()+1 SAY iznos pict "99.99%"
		
		if empty(idkbenef) 
			// doprinos udara na neto
			if ("BENEF" $ dopr->naz .and. nBFO <> 0)
				@ prow(),pcol()+1 SAY nBFO pict gpici
				nC1:=pcol()+1
				@ prow(),pcol()+1 SAY nPom:=max(dlimit,round(iznos/100*nBFO,gZaok2)) pict gpici
			else
				@ prow(),pcol()+1 SAY nBo pict gpici
				nC1:=pcol()+1
				@ prow(),pcol()+1 SAY nPom:=max(dlimit,round(iznos/100*nBO,gZaok2)) pict gpici
			endif
			
			if dopr->id == "1X"
				nUkDoprIz += nPom
			endif

		else
			nPom0:=ASCAN(aNeta,{|x| x[1]==idkbenef})
			if nPom0<>0
				nPom2:=parobr->k3/100*aNeta[nPom0,2]
			else
				nPom2:=0
			endif
			if round(nPom2,gZaok2)<>0
				@ prow(),pcol()+1 SAY nPom2 pict gpici
				nC1:=pcol()+1
				nPom:=max(dlimit,round(iznos/100*nPom2,gZaok2))
				@ prow(),pcol()+1 SAY nPom pict gpici
			endif
		endif
		
		if right(id,1)=="X"
			
			? cDoprLine
			?
			nDopr += nPom
		
		endif
		
		if !lSkrivena .and. prow()>57+gPStranica
			FF
		endif
		
		skip 1
		
	enddo
	
	? cMainLine
	?  cLMSK + Lokal("UKUPNO ZA ISPLATU")
	@ prow(),60+LEN(cLMSK) SAY nOsnZaBr pict gpici

	? cMainLine

	if !lSkrivena .and. prow()>55+gPStranica
		FF
	endif

endif

// potpis na kartici
kart_potpis()

// skrivena kartica
if lSkrivena
	if prow()<nKRSK+5
		nPom:=nKRSK-PROW()
		FOR i:=1 TO nPom
			?
		NEXT
	else
		FF
	endif
// 2 kartice na jedan list N - obavezno FF
elseif c2K1L == "N"
	FF
// ako je prikaz bruto D obavezno FF
elseif gPrBruto == "D"
	FF
// nova kartica novi list - obavezno FF
elseif lNKNS
	FF
// druga kartica takodjer FF
elseif (nRBRKart%2 == 0) 
	FF
// prva kartica, ali druga ne moze stati
elseif (nRBRKart%2 <> 0) .and. (DUZ_STRANA - prow() < nKRedova )
	--nRBRKart
	FF
endif

return


