#include "sc.ch"
#include "msg.ch"


function PrintMsg()
*{
nTRec:=RECNO()

START PRINT CRET

cPorukaTXT:=""
nRow:=1
cFrom:=field->fromhost
cFromUser:=field->fromuser
dCreated:=field->created
dSent:=field->sent
dRead:=field->read
cTo:=field->to
aPom:={}

? "PREGLED - STAMPA PORUKA:"
? REPLICATE("-",70)
?
? "Poruku poslao: " + ALLTRIM(cFromUser) 
? "Datum kreiranja: " + DToC(dCreated) + ", datum slanja: " + DToC(dSent) + ", procitana: " + DToC(dRead)
?
? REPLICATE("-",70)
?
set filter to

do while !EOF() .and. field->fromhost=cFrom .and. field->fromuser=cFromUser .and. field->created=dCreated .and. field->sent=dSent .and. field->to=cTo
	if (nRow>1 .and. field->row==1)
		exit
	endif
	cPorukaTXT+=" " + ALLTRIM(field->text)
	++nRow
	skip	
enddo

aPom:=SjeciStr(cPorukaTXT,50)
for i:=1 to LEN(aPom)
	? aPom[i]
next

?
? REPLICATE("-",70)

set filter to &cFilter
go nTRec


FF
END PRINT

return
*}
