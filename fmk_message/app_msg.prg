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



/*! \fn InsertIntoAMessage()
 *  \brief Importuje poruke iz svih prodavnica u zbirnu tabelu poruka AMESSAGE (all messages) 
 */ 
function InsertIntoAMessage()
*{
local i
O_AMESSAGE
// da li ovu tabelu treba brisati svaki put ili ne
*select amessage
*zap
O_MESSAGE
select message

cFilter:="read=CToD('') .and. uamessage<>'1'"
set filter to &cFilter
go top
i:=1

// samo daj polja kod kojih je read prazno
do while !EOF() .and. field->read=CTOD('') 
	// uzmi tekuce vrijednosti	
	cFromHost:=field->fromhost
	cFromUser:=field->fromuser
	nRow:=field->row
	cText:=field->text
	dCreated:=field->created
	dSent:=field->sent
	cPriority:=field->priority
	cTo:=field->to
	// markiraj polje uamessage sa 1 ako je zapis prebacen
	Scatter()
	_uamessage:="1"
	Gather()
	select amessage
	// upisi u AMESSAGE.DBF
	append blank
	replace field->fromhost with cFromHost
	replace field->fromuser with cFromUser	
	replace field->row with nRow	
	replace field->text with cText	
	replace field->created with dCreated	
	replace field->sent with dSent	
	replace field->priority with cPriority	
	replace field->to with cTo
	// vrati se na MESSAGE i idi nazad
	? "Importujem poruku " + STR(i) + " fromhost: " + cFromHost + ", fromuser: " + cFromUser 
	select message
	skip
enddo

set filter to

return
*}


/*! \fn DeleteAllOldMsg(lAppSrv)
 *  \brief Brise sve poruke od Date()-cBrojDana pa unazad
 *  \param lAppSrv - ako se poziva kroz appsrv onda brise DATE()-93
 */
function DeleteAllOldMsg(lAppSrv)
*{

if !lAppSrv
	cBrojDana:=SPACE(3)
	cZbirnaTabela:="N"
	Box(,4,43)
	@ 1+m_x, 2+m_y SAY "Brisat ce se sve poruke koje su starije od"
	@ 2+m_x, 2+m_y SAY DToC(DATE()) + "-Broj Dana !"
	@ 3+m_x, 2+m_y SAY "Broj dana:" GET cBrojDana VALID !EMPTY(cBrojDana) PICT "999"
	@ 4+m_x, 2+m_y SAY "Brisati zbirnu tabelu ?" GET cZbirnaTabela VALID cZbirnaTabela$"DN" PICT "@!"
	read
	BoxC()
	if !lAppSrv
		if LastKey()==K_ESC
			return
		endif
	endif
	nBrojDana:=VAL(cBrojDana)
else
	nBrojDana:=93
endif

if cZbirnaTabela=="D"
	O_AMESSAGE
	select amessage
else
	O_MESSAGE
	select message
endif

go top
i:=0

do while !EOF() .and. field->sent<=DATE()-nBrojDana
	delete
	skip
	++i
enddo

if i>0
	if !lAppSrv
		MsgBeep("Pobrisao " + STR(i) + " poruka !")
	else
		? "Pobrisao " + STR(i) + " poruka!"
	endif
else
	if !lAppSrv
		MsgBeep("Nema poruka za brisanje !!!")
	else
		? "Nema poruka za brisanje!!!"
	endif
endif

return
*}



/*! \fn DeleteReadMsg()
 *  \brief Brise sve procitane poruke
 */
function DeleteReadMsg()
*{
O_MESSAGE
select message
go top

i:=0

do while !EOF() .and. field->read<>CToD('')
	delete
	skip
	++i
enddo

if i>0
	MsgBeep("Pobrisao " + STR(i) + " poruka !")
else
	MsgBeep("Nema poruka za brisanje !!!")
endif

return
*}


/*! \fn DeleteSentMsg()
 *  \brief Brise sve poruke koje su poslane
 */
function DeleteSentMsg()
*{
O_MESSAGE
select message
go top

i:=0

// ovo se odnosi samo na knjigovodstvo
do while !EOF() .and. field->to<>""
	delete
	skip
	++i
enddo

if i>0
	MsgBeep("Pobrisao " + STR(i) + " poruka !")
else
	MsgBeep("Nema poruka za brisanje !!!")
endif

return
*}


/*! \fn ImportMsgFrom(cDrive, cSite)
 *  \brief Importuje poruke sa druge lokacije (npr. import poruka sa i:\kase\tops\kum1\message.dbf u c:\kase\tops\kum1\message.dbf)
 *  \param cDrive - oznaka drive-a (npr. I:)
 *  \param cSite - oznaka site-a prodavnice (npr. 50)
 */
function ImportMsgFrom(cDrive, cSite)
*{
O_MESSAGE

// postavi parametre SITE i USER
gSqlSite:=VAL(cSite)
gSqlUser:=1
? "SET SITE = ", gSqlSite

// zamjeni postojeci KUMPATH sa novim
// npr.: c:\kase\tops\kum1 -> i:\kase\tops\kum1
cPath:=STRTRAN(KUMPATH, "C:", cDrive)

SELECT (F_MSGNEW)
USE (cPath+"MESSAGE") ALIAS MSGNEW

if gAppSrv
	? "Putanja: " + cPath
endif

// postavi filter na poruke koje su za slanje
cFilter:="read=CToD('') .and. !EMPTY(to)"
set filter to &cFilter
go top
i:=0

? "Filter na poruke postavljen!"

do while !EOF() .and. field->read=CTOD('') 
	// uzmi tekuce vrijednosti	
	cFromHost:=field->fromhost
	cFromUser:=field->fromuser
	nRow:=field->row
	cText:=field->text
	dCreated:=field->created
	dSent:=field->sent
	cPriority:=field->priority
	cTo:=field->to
	select message
	? "Postoji li poruka?"
	if !IsMsgExistLocaly(cFromHost, cFromUser, PADR(cText,40), dCreated, dSent, cTo)
		++i
		select message
		append blank
		SQL_Append()
		SMReplace("fromhost", cFromHost)
		SMReplace("fromuser", cFromUser)	
		SMReplace("row", nRow)	
		SMReplace("text", cText)	
		SMReplace("created", dCreated)	
		SMReplace("sent", dSent)	
		SMReplace("priority", cPriority)	
		SMReplace("to", cTo)
	 	? "Poruka ne postoji!!!"	
		? "Importujem poruku " + STR(i) + " fromhost: " + cFromHost + ", fromuser: " + cFromUser 
		select msgnew
		skip
	else
		? "Poruka postoji!!!"
		select msgnew
		skip
	endif
enddo

// skini filter
set filter to

? "Skinuo filter! Importovano " + STR(i) + " poruka!"

return
*}


/*! \fn IsMsgExistLocaly(cFromHost, cFromUser, cText, dCreated, dSent, cTo)
 *  \brief Da li poruka postoji lokalno. Ako postoji vraca .T. a ako ne .F.
 *  \param cFromHost
 *  \param cFromUser
 *  \param cText
 *  \param dCreated
 *  \param dSent
 *  \param cTo
 */
function IsMsgExistLocaly(cFromHost, cFromUser, cText, dCreated, dSent, cTo)
*{
select message
// TAG "5"
// fromhost+fromuser+PADR(text,40)+DToS(created)+DToS(sent)+to
set order to tag "5"
seek cFromHost+cFromUser+cText+DToS(dCreated)+DToS(dSent)+cTo

if Found()
	return .t.
else
	return .f.
endif
*}

