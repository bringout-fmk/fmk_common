#include "\cl\sigma\fmk\fakt\fakt.ch"

/*! \fn MenuNovine()
 *  \brief Menij za pripremu tiraza
 */
 
function MenuNovine()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. priprema tiraza                  ")
AADD(opcexe, {|| PripTiraz()})
AADD(opc, "2. generacija dostavnica         ")
AADD(opcexe, {|| GenDostav()})
AADD(opc, "3. rekapitulacija pripreme tiraza")
AADD(opcexe, {|| RekPripTir()})
AADD(opc, "4. stampa kompletnog dnevnog tiraza")
AADD(opcexe, {|| StDnTiraz()})

Menu_SC("nov")
return
*}


