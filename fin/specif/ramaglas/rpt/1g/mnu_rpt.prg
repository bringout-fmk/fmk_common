#include "\cl\sigma\fmk\fin\fin.ch"


/*! \file fmk/fin/specif/ramaglas/rpt/1g/mnu_rpt.prg
 *  \brief Meni izvjestaja za rama glas - "pogonsko knjigovodstvo"
 */

/*! \fn Izvjestaji()
 *  \brief Glavni menij za izbor izvjestaja
 *  \param 
 */
 
function IzvjPogonK()
*{
private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. specifikacija troskova po radnim nalozima")
AADD(opcexe,{|| SpecTrosRN()})

Menu_SC("izPK")

return .f.
*}

