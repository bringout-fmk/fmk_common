#include "sc.ch"


function EventLog(nUser,cModul,cKomponenta,cFunkcija,nN1,nN2,nCount1,nCount2,cC1,cC2,cC3,dDatum1,dDatum2,cSql,cOpis)
*{
local nArr
nArr:=SELECT()

if (gSecurity<>"D")
	return
endif

O_EVENTS
O_EVENTLOG

if nN1==nil
	nN1:=0	
endif

if nN2==nil
	nN2:=0
endif

if nCount1==nil
	nCount1:=0
endif

if nCount2==nil
	nCount2:=0
endif

if cC1==nil
	cC1:=""
endif

if cC2==nil
	cC2:=""
endif

if cC3==nil
	cC3:=""
endif

if cSql==nil
	cSql:=""
endif


select eventlog
go bottom

nLastRec:=(field->id+1)

append blank

replace id with nLastRec
replace user with nUser
replace datum with Date()
replace vrijeme with SubStr(Time(),1,5)
replace objekat with cModul
replace komponenta with cKomponenta
replace funkcija with cFunkcija
replace opis with cOpis
replace sql with cSql
replace n1 with nN1
replace n2 with nN2
replace count1 with nCount1
replace count2 with nCount2
replace c1 with cC1
replace c2 with cC2
replace c3 with cC3
replace d1 with dDatum1
replace d2 with dDatum2


select (nArr)

return
*}



/*! \fn Logirati(cModul,cKomponenta,cFunkcija)
 *  \brief Provjerava da li funkciju treba logirati
 *  \param cModul modul
 *  \param cKomponenta komponenta unutar modula
 *  \param cFunkcija konkretna funkcija
 *  \return .t. or .f.
 */

function Logirati(cModul,cKomponenta,cFunkcija)
*{
local nArr
local lLogirati
nArr:=SELECT()
lLogirati:=.f.

if (gSecurity<>"D")
	return .f.
endif

O_EVENTS

cModul:=PADR(cModul,10,SPACE(1))
cKomponenta:=PADR(cKomponenta,15,SPACE(1))
cFunkcija:=PADR(cFunkcija,30,SPACE(1))

select events
set order to tag "1"

hseek cModul+cKomponenta+cFunkcija

if Found()
	if ((field->logirati=="D") .or. (field->bitnost$"345") .and. (field->logirati=="N"))
		lLogirati:=.t.
	endif

endif
select (nArr)
return lLogirati
*}



function FmkEvVer()
*{
return DBUILD
*}
