#include "sc.ch"
#include "msg.ch"


/*! \fn Mnu_Poruke()
 *  \brief Glavni menij poruka
 */
function Mnu_Poruke()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. citanje poruka                   ")
AADD(opcexe,{|| ReadMsg(.f.) })
AADD(opc,"2. pisanje poruka")
AADD(opcexe,{|| CreateMsg(gIdPos) })

if (gSamoProdaja=="N" .and. KLevel=="0")
	AADD(opc,"3. brisanje poruka do perioda")
	AADD(opcexe,{|| DeleteAllOldMsg(.f.)})
	AADD(opc,"4. brisanje procitanih poruka")
	AADD(opcexe,{|| DeleteReadMsg()})
	AADD(opc,"5. brisanje poslanih poruka")
	AADD(opcexe,{|| DeleteSentMsg()})
endif

Menu_SC("msg")

return
*}

