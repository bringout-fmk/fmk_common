#include "\cl\sigma\fmk\fin\fin.ch"

/*! \file fmk/fin/razdb/1g/mnu_raz.prg
 *  \brief Menij razmjene podataka
 */
 
/*! \fn MnuRazmjenaPodataka() 
 *  \brief Menij razmjene podataka
 */
function MnuRazmjenaPodataka()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. fakt->fin                   ")
AADD(opcexe, {|| FaktFin()})
AADD(opc, "2. ld->fin ")
AADD(opcexe, {|| LdFin()})

Menu_SC("raz")

return
*}


