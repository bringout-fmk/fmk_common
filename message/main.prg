#include "sc.ch"
#include "msg.ch"



* KREIRANJE PORUKE

/*! \fn CreateMsg()
 *  \brief Kreiranje poruka
 */
function CreateMsg(cIdPos)
*{
private cIdMsg:=" "
// preuzeti poruku iz clipboard-a
if gSamoProdaja=="N" .and. Pitanje(,"Preuzeti poruku iz clipboard-a (D/N)","N")=="D"
	Box(,1,25)
		@ 1+m_x, 2+m_y SAY "Oznaka poruke (0-9)" GET cIdMsg
		read
	BoxC()
	GetMsgFromClipBoard(cIdMsg)
	return
endif

private cUserName:=SPACE(10)
private cPrioritet:="1"
private cTo:=SPACE(3)
private cLinija1:=SPACE(220)
private cLinija2:=SPACE(220)
private cLinija3:=SPACE(220)
private cLinija4:=SPACE(220)
private cLinija5:=SPACE(220)
private cLinija6:=SPACE(220)
private cLinija7:=SPACE(220)
private cLinija8:=SPACE(220)
private cLinija9:=SPACE(220)
private cLinija10:=SPACE(220)
private nBrojac:=1


aLinije:={}

Box(,15,73)
	@ 1+m_x,2+m_y SAY "Pisanje nove poruke:                   "
	@ 2+m_x,2+m_y SAY "Vase ime: " GET cUserName VALID !EMPTY(cUserName)
	@ 3+m_x,2+m_y SAY "Prioritet poruke (1/2/3): " GET cPrioritet PICT "!@S1" VALID !EMPTY(cPrioritet) .and. cPrioritet$"123"
	if (gSamoProdaja=="N")
		cTo:="ALL"
		@ 3+m_x,34+m_y SAY "Poruka se salje (ALL/P/U)" GET cTo VALID cTo$"ALL#P#U" .and. !EMPTY(cTo)
	endif
	@ 5+m_x,2+m_y SAY "Poruka: "
	@ 6+m_x,2+m_y SAY "" GET cLinija1 PICT "@!S70"
	@ 7+m_x,2+m_y SAY "" GET cLinija2 PICT "@!S70"
	@ 8+m_x,2+m_y SAY "" GET cLinija3 PICT "@!S70"
	@ 9+m_x,2+m_y SAY "" GET cLinija4 PICT "@!S70"
	@ 10+m_x,2+m_y SAY "" GET cLinija5 PICT "@!S70"
	@ 11+m_x,2+m_y SAY "" GET cLinija6 PICT "@!S70"
	@ 12+m_x,2+m_y SAY "" GET cLinija7 PICT "@!S70"
	@ 13+m_x,2+m_y SAY "" GET cLinija8 PICT "@!S70"
	@ 14+m_x,2+m_y SAY "" GET cLinija9 PICT "@!S70"
	@ 15+m_x,2+m_y SAY "" GET cLinija10 PICT "@!S70"
	read
BoxC()

if Pitanje(,"Snimiti poruku (D/N) ?","D")=="D"
	// napuni niz aLinije sa linijama teksta
	for i=1 to 10
		cLin:="cLinija" + ALLTRIM(STR(i))
		if Empty(&cLin)
			loop
		endif
		AADD(aLinije, {nBrojac, &cLin})
		++nBrojac
	next
	SaveMessage(aLinije, cIdPos, cUserName, cPrioritet, cTo)
	if (gSamoProdaja=="N" .and. Pitanje(,"Snimiti poruku u clipboard (D/N)","N")=="D")
		Box(,1,25)
			@ 1+m_x, 2+m_y SAY "Oznaka poruke (1-9):" GET cIdMsg
			read
		BoxC()
		SendMsgToClipBoard(cIdMsg, aLinije, cIdPos, cUserName, cPrioritet, cTo)
	endif
	MsgBeep("Poruka snimljena! ")
endif

return
*}



function SaveMessage(aLinijeText, cFrom, cUserName, cPrioritet, cTo)
*{
O_MESSAGE

for i=1 to LEN(aLinijeText)
	append blank
	Sql_Append()
	SmReplace("fromhost",cFrom)
	SmReplace("fromuser",cUserName)
	SmReplace("row",i)
	SmReplace("text",aLinijeText[i, 2])
	SmReplace("created",Date())
	SmReplace("sent",Date())
	SmReplace("priority",cPrioritet)
	SmReplace("to",cTo)
next


return
*}


* CITANJE PORUKA


/*! \fn ReadMsg(lNeprocitane)
 *  \brief Citanje poruka
 *  \param lNeprocitane - samo koje nisu procitane (.t.) ili sve (.f.)
 */
function ReadMsg(lNeprocitane)
*{
local nArr:=SELECT()
local aPoruke
private cFilter:=""
private ImeKol
private Kol

if (gSamoProdaja=="N" .and. Pitanje(,"Prikazati poruke za sve prodavnice (D/N)","N")=="D")
	select (F_AMESSAGE)
	if !USED()
		O_AMESSAGE
	endif
	select amessage
else
	select (F_MESSAGE)
	if !USED()
		O_MESSAGE
	endif
	select message
endif

if (lNeprocitane==.f. .and. Pitanje(,"Pregledati neprocitane/sve poruke (D/N)?","D")=="D")
	lNeprocitane:=.t.
endif

cFilter:="row=1"

if lNeprocitane
	cFilter+=" .and. read=CTOD('')"
endif

if gSamoProdaja=="D"
	// ako je rijec o prodavnici
	// postavi filter po prioritetima korisnika
	if KLevel=="0" //admin
		cFilter+=" .and. !EMPTY(to)"
	endif

	if KLevel=="1" //upravn
		cFilter+=" .and. (to='U' .or. to='ALL')"
	endif
	
	if KLevel=="3" //prod
		cFilter+=" .and. (to='P' .or. to='ALL')"
	endif
else
	// ako je rijec o knjgovodstvu
	Box(,3,43)
		cIzbor:="2"
		@ 1+m_x, 2+m_y SAY "Pregledati - sve poruke       (1)"
		@ 2+m_x, 2+m_y SAY "           - primljene poruke (2)"
		@ 3+m_x, 2+m_y SAY "           - poslane poruke   (3) =>" GET cIzbor VALID !EMPTY(cIzbor) .and. cIzbor$"123"
		read
	BoxC()
	if cIzbor=="1"
		cFilter+=" .and. !EMPTY(to)"
	elseif cIzbor=="2"
		cFilter+=" .and. EMPTY(to)"
	else
		cFilter+=""
	endif
endif

set order to tag "6"
set filter to &cFilter
go top

ImeKol:={}
AADD(ImeKol,{"Poslao",{||fromuser}})
AADD(ImeKol,{"Kreirano",{||created}})
AADD(ImeKol,{"Poslano",{||sent}})
AADD(ImeKol,{PADR("Poruka",10),{||text}})

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

set cursor on
go top

aOpc:={"<Enter> - Odabir","<ESC> - Izlaz","<c+P> - Stampa"}

ObjDBedit(,19,77,{|| ShowMessage()},"     Pregled poruka     ","",.f.,aOpc)

CLOSERET
return
*}



/*! \fn IsNewMsgExists()
 *  \brief Da li postoji nova poruka sa praznim poljem READ
 */
function IsNewMsgExists()
*{


local nArr
nArr:=SELECT()

lVrati:=.f.

O_MESSAGE

go bottom

do while !BOF()
	if gSamoProdaja=="D" .and. field->read==CToD("") .and. !Empty(field->to)
		lVrati:=.t.
		exit
	elseif gSamoProdaja<>"D" .and. field->read==CToD("") .and. Empty(field->to)
		lVrati:=.t.
		exit
	else	
		skip -1
	endif
enddo

select (nArr)

return lVrati
*}



function ShowMessage()
*{
if M->Ch==0
	return (DE_CONT)
endif
if LASTKEY()==K_ESC
	return (DE_ABORT)
endif

do case
    	case Ch==K_ENTER
		MsgInfo()
		return (DE_REFRESH)
 // 	endcase
    	case Ch==K_CTRL_P
		PrintMsg()
		return (DE_REFRESH)
  	endcase

return (DE_CONT)
*}


function MsgInfo()
*{
local nTRec
private cMarkiraj:="N"

nRow:=1
cFrom:=field->fromhost
cFromUser:=field->fromuser
dCreated:=field->created
dSent:=field->sent
dRead:=field->read
cTo:=field->to
aPom:={}

Box(,23,77)
	@ 1+m_x, 2+m_y SAY "Poruku poslao: " + ALLTRIM(cFromUser)
	@ 2+m_x, 2+m_y SAY "Kreirana: " + DToC(dCreated) + ", poslana: " + DToC(dSent) + " procitana: " + DToC(dRead)
	
	@ 3+m_x, 2+m_y SAY REPLICATE("-",76) COLOR "GR+/N"
	nTRec:=RecNo()
	cPorukaTXT:=""
	
	//privremeno skidam filter da bi uzeo sve linije texta ako ih je vise
	set filter to
	//uzmi sve linije text-a
	do while !EOF() .and. field->fromhost=cFrom .and. field->fromuser=cFromUser .and. field->created=dCreated .and. field->sent=dSent .and. field->to=cTo
		if (nRow>1 .and. field->row==1)
			exit
		endif
		cPorukaTXT+=" " + ALLTRIM(field->text)
		++nRow
		skip	
	enddo
	//prikazi u prozoru sve linije poruke zajedno i formatiraj na 70
	aPom:=SjeciStr(cPorukaTXT,76)
	for i:=1 to LEN(aPom)
		@ 3+i+m_x, 2+m_y SAY aPom[i] COLOR "N/W"
	next
	
	set filter to &cFilter
	go nTRec
	@ 23+m_x, 2+m_y SAY "Markiraj poruku kao procitanu (D/N):" GET cMarkiraj PICT "@!" VALID !EMPTY(cMarkiraj) .and. cMarkiraj$"DN"
	read
BoxC()

if cMarkiraj=="D"
	MarkMsgAsRead()
else
	return
endif

return
*}



function MarkMsgAsRead()
*{
local nTRec
local nRow

// opet skidam filter
set filter to

nRow:=1
nTRec:=RecNo()

cFrom:=field->fromhost
cFromUser:=field->fromuser
dCreated:=field->created
dSent:=field->sent
cTo:=field->to

do while !EOF() .and. field->fromhost=cFrom .and. field->fromuser=cFromUser .and. field->created=dCreated .and. field->sent=dSent .and. field->to=cTo
	if (nRow>1 .and. field->row==1)
		exit
	endif
	Scatter()
	_read:=DATE()
	Gather()
	// Ovo ipak ne treba u SQLLOG
	// Sql_Azur(.t.)
	// GathSQL()
	++nRow
	skip
enddo

// vracam filter
set filter to &cFilter

go nTRec

return (DE_REFRESH)
*}



/*! \fn SendMsgToClipboard(idMsg, aLinijeTXT, idPos, fromuser, prioritet, to)
 *  \brief Salje poruku u TMPMSG.DBF
 */
function SendMsgToClipboard(idMsg, aLinijeTXT, idpos, fromuser, prioritet, to)
*{
// ako nema temp tabele kreiraj je
CreTempDBMsg()

O_TMPMSG

select tmpmsg
set order to tag "1"
hseek idMsg

do while !EOF()
	if field->idmsg=idmsg
		delete
		skip
	else
		skip
	endif
enddo

for i=1 to LEN(aLinijeTXT)
	append blank
	replace field->idmsg with idmsg
	replace field->fromhost with idpos
	replace field->fromuser with fromuser
	replace field->row with i
	replace field->text with aLinijeTXT[i, 2]
	replace field->created with DATE()
	replace field->sent with DATE()
	replace field->priority with prioritet
	replace field->to with to
	
next

return
*}


/*! \fn GetMsgFromClipboard(idMsg)
 *  \brief Kopira sadrzaj polja TMPMSG u MESSAGE za zadani idMsg
 *  \param idMsg - oznaka poruke
 */
function GetMsgFromClipboard(idMsg)
*{
O_TMPMSG
O_MESSAGE
altd()
CreTempDBMsg()

lPronasao:=.f.

select tmpmsg
set order to tag "1"
hseek idMsg
do while !EOF()
	if field->idmsg<>idmsg
		skip
		loop
	endif
	lPronasao:=.t.
	// uzmi vrijednosti polja
	cFromHost:=field->fromhost
	cFromUser:=field->fromuser
	nRow:=field->row
	cText:=field->text
	dCreated:=field->created
	dSent:=field->sent
	cPriority:=field->priority
	cTo:=field->to
	
	select message	
	append blank
	Sql_Append()
	SMReplace("fromhost", cFromHost)
	SMReplace("fromuser", cFromUser)
	SMReplace("row", nRow)
	SMReplace("text", cText)
	SMReplace("created", dCreated)
	SMReplace("sent", dSent)
	SMReplace("priority", cPriority)
	SMReplace("to", cTo)
	
	select tmpmsg
	skip
enddo

if lPronasao
	MsgBeep("Poruka " + idmsg + " preuzeta iz clipboard-a!")
else
	MsgBeep("Poruka pod oznakom " + idmsg + " ne postoji!")
endif

return
*}




