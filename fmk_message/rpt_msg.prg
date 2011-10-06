/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"
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
