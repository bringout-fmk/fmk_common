#include "sc.ch"


/*! \fn RabVrijednost(cIdRab, cTipRab, cIdRoba, nTekIzn)
 *  \brief Vrati vrijednost rabata - pozovi func. GetRabatForArticle()
 */
function RabVrijednost(cIdRab, cTipRab, cIdRoba, nTekIzn)
*{

if Empty(cIdRoba)
	return
endif

nRet := GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIzn)

return nRet
*}


/*! \fn GetDays(cIdRab, cTipRab)
 *  \brief Vrati vrijednost broja dana za rabat - poziva GetDaysForRabat() 
 */
function GetDays(cIdRab, cTipRab)
*{

nRet := GetDaysForRabat(cIdRab, cTipRab)

return nRet
*}

/*! \fn GetSKntForArticle()
 *  \brief Vrati vrijdnost SKONTO za artikal - poziva GetSkontoArtcile()
 */
function SKVrijednost(cIdRab, cTipRab, cIdRoba)
*{

nRet := GetSkontoArticle(cIdRab, cTipRab, cIdRoba)

return nRet
*}


/*! \fn SrediRabate()
 *  \brief Sredjivanje rabata u pripremi
 */
function SrediRabate()
*{
local nOrder
local cBrDok:=""
local cIdTipDok:=""

nObradjeno := 0

select pripr
go top

if (RecCount2() <> 0)
	ImeKol:={}
   	AADD(ImeKol, {"TD", {|| IdTipdok}})
   	AADD(ImeKol, {"Broj", {|| BrDok}})
   	AADD(ImeKol, {"Partner", {|| LEFT(idpartner, 20)}})
   	AADD(ImeKol, {"Tip Rabat", {|| tiprabat}})
   	AADD(ImeKol, {"Skonto", {|| m1}})
   	Kol:={}
   	for i:=1 to LEN(ImeKol)
   		AADD(Kol, i)
 	next

   	Box(,20,75)
	
	@ 1+m_x, 2+m_y SAY "Sredjivanje rabata na dokumentima...      "
	@ 2+m_x, 2+m_y SAY "Opcije:" COLOR "I"
	@ 2+m_x, 10+m_y SAY "<SPACE> - obracunavaj kasu skonto"
	@ 3+m_x, 10+m_y SAY "<R> - postavi tip rabata za dokument"
	
	
	private cFilt := "idfirma=" + Cm2Str(gFirma) + ".and. idtipdok=" + Cm2Str("10") + ".and. rbr = '  1'" 
    	set filter to &cFilt
	go top
    	do while !eof() .and. IdFirma = gFirma .and. IdTipdok $ gcRabDok
      		if m1 <> "Z"
        		replace m1 with " "
      		endif
      		skip
    	enddo
	seek gFirma + "10"
    	BrowseKey(m_x+5,m_y+1,m_x+19,m_y+73,ImeKol,{|Ch| EdRabat(Ch)},"IdFirma+idtipdok = gFirma + '10'", gFirma + "10", 2, , , {|| idfirma=gFirma} )

	BoxC()
	if Pitanje(,"Azurirati rabate ?","N")=="D"
      		select pripr
		set filter to
		nObradjeno := SetRabToAll()
      	endif
else
	// ne postoje dokumenti
	MsgBeep("Nema dokumenata u pripremi")
endif

if (nObradjeno > 0)
	MsgBeep("Obradjeno " + ALLTRIM(TRIM(nObradjeno)) + " racuna...")
endif
    
close all
O_Edit()

select pripr
return .t.
*}


function EdRabat(Ch)
*{
local cDn:="N"
nRet:=DE_CONT
do case
	case Ch==ASC(" ") .or. Ch==K_ENTER
   		Beep(1)
   		if m1=" "
     			replace m1 with "*"
   		else
     			replace m1 with " "
   		endif
   		nRet:=DE_REFRESH
	case chr(Ch) $ "rR" // postavi TipRabata
		private cTipRab:=SPACE(10)
		GetTRabat(@cTipRab)
		replace tiprabat with cTipRab 
		nRet:=DE_REFRESH
endcase
return nRet
*}


function SetRabToAll()
*{
go top
hseek gFirma + "10"

cTipRab := ""
nRet := 0

do while !EOF() .and. idfirma = gFirma .and. idtipdok $ gcRabDok
	// provrti pripremu
	if !Empty(field->tiprabat)
		cTipRab := field->tiprabat
		++ nRet
	endif
	replace tiprabat with PADR(cTipRab, 10)
	replace rabat with RabVrijednost(gcRabDef, tiprabat, idroba, gcRabIDef)
	replace skonto with SKVrijednost(gcRabDef, tiprabat, idroba)
	
	if (rbr == "  1") 
		nDays := GetDays(gcRabDef, tiprabat)
		
		cTxt:= Chr(16) + " " + Chr(17) + Chr(16)
		cTxt += " " + Chr(17) + Chr(16)
		cTxt += " " + Chr(17) + Chr(16)
		cTxt += " " + Chr(17) + Chr(16)
		cTxt += " " + Chr(17) + Chr(16)
		cTxt += " " + Chr(17) + Chr(16)
		cTxt += " " + Chr(17) + Chr(16)
		cTxt += " " + Chr(17) + Chr(16)
		cTxt += DToC(datdok + nDays) + Chr(17) 
		
		replace txt with cTxt
	endif
	
	skip
enddo

return nRet
*}


/*! \fn CheckMemo(aMemo)
 *  \brief Provjerava da li je memo prazan
 */
function CheckMemo(aMemo)
*{
// ako je prazan
altd()
if (LEN(aMemo) < 9)
	aMemo := {}
	for i=1 to 12
		AADD(aMemo, " ")
	next
	aMemo[7] := CToD("")
	aMemo[9] := CToD("")
endif

return
*}


