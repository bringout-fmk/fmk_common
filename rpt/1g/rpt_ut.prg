#include "ld.ch"


function ShowKreditor(cKreditor)
*{
local nArr
nArr:=SELECT()

O_KRED
select kred
seek cKreditor
// ispis
if !EOF()
	? ALLTRIM(field->id) + "-" + (field->naz)
	? "-" + ALLTRIM(field->fil) + "-"
	? ALLTRIM(field->adresa) + ", " + field->ptt + " " + ALLTRIM(field->mjesto)
else
	? Lokal("...Nema unesenih podataka...za kreditora...")
endif

select (nArr)
return
*}


function ShowPPDef()
*{

? SPACE(5) + Lokal("Obracunski radnik:") + SPACE(35) + Lokal("SEF SLUZBE:")
?
? SPACE(5) + "__________________" + SPACE(35) + "__________________"

return
*}


function ShowPPFakultet()
*{
 
? SPACE(5) + Lokal("Likvidator:       ") + SPACE(35) + Lokal("Dekan fakulteta:  ")
?
? SPACE(5) + "__________________" + SPACE(35) + "__________________"

return
*}


/*! \fn ShiwHiredFromTo(dHiredFrom, dHiredTo)
 *  \brief Prikaz podataka angazovan od, angazovan do na izvjestajima, ako je dHiredTo prazno onda prikazuje Trenutno angazovan...
 *  \param dHiredFrom - angazovan od datum
 *  \param dHiredTo - angazovan do datum
 */
function ShowHiredFromTo(dHiredFrom, dHiredTo, cLM)
*{
cHiredFrom:=DToC(dHiredFrom)
cHiredTo:=DToC(dHiredTo)

? cLM + Lokal("Angazovan od: ") + cHiredFrom
?? ",  " + Lokal("Angazovan do: ")

if !EMPTY(DToS(dHiredTo))
	?? cHiredTo 
else
	?? Lokal("Trenutno angazovan")
endif

return
*}

