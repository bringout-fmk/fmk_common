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

select pripr
go top

if (RecCount2() <> 0)
	ImeKol:={}
   	AADD(ImeKol,{ "TD",       {|| IdTipdok}               })
   	AADD(ImeKol,{ "Broj",     {|| BrDok}                  })
   	AADD(ImeKol,{ "Partner",  {|| left(idpartner,20)}       })
   	AADD(ImeKol,{ "TipRabat", {|| tiprabat }, {|| .t.}, {|| .t.}              })
   	AADD(ImeKol,{ "Skonto",   {|| m1 }                })
   	Kol:={}
   	for i:=1 to len(ImeKol)
   		AADD(Kol, i)
 	next

   	Box(,20,75)
	cFilter := "idfirma=" + Cm2Str(gFirma) + ".and. idtipdok=" + Cm2Str("10") + ".and. rbr = '  1'" 
    	set filter to &cFilter 
	go top
    	do while !eof() .and. IdFirma+IdTipdok = gFirma + "10"
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
      		do while !eof() .and. IdFirma+IdTipdok = gFirma + "10"
         		skip
			nTrec0:=recno()
			skip -1
         		if m1="*"
				_skonto := SKVrijednost(gcRabDef, _tiprabat, _idroba)
			endif
			_rabat := RabVrijednost(gcRabDef, _tiprabat, _idroba, gcRabIDef)
          	       	go nTrec0
      		enddo   
		set filter to
      	endif
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
endcase
return nRet
*}


