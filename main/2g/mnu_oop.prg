#include "\dev\fmk\ld\ld.ch"


/*! \fn MnuOstOp()
 *  \brief Menij ostale operacije nad obracunom
 */
function MnuOstOp()
*{
private opc:={}
private opcexe:={}

AADD(opc,   "1. razlike LD-a po novim prosj.satnicama i vrbod-a ")
AADD(opcexe, {|| RazlikaLd()} )
private Izbor:=1

Menu_SC("oop")

return
*}

