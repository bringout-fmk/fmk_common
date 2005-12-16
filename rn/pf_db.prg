#include "sc.ch"

/*! \fn drn_create()
 *  \brief kreiranje tabela RN i DRN
 */
function drn_create()
*{
local cDRnName := "DRN" + DBFEXT
local cRnName := "RN" + DBFEXT
local aDRnField:={}
local aRnField:={}

// provjeri da li postoji fajl DRN.DBF
if !FILE(PRIVPATH + cDRnName)
	// drn specifikacija polja
	get_drn_fields(@aDRnField)
        // kreiraj tabelu
	dbcreate2(PRIVPATH + cDRnName, aDRnField)
endif

// provjeri da li postoji fajl RN.DBF
if !FILE(PRIVPATH + cRnName)
	// rn specifikacija polja
	get_rn_fields(@aRnField)
        // kreiraj tabelu
	dbcreate2(PRIVPATH + cRnName, aRnField)
endif

// kreiraj indexe
CREATE_INDEX("1", "brdok", PRIVPATH + "DRN")
CREATE_INDEX("1", "brdok+rbr", PRIVPATH + "RN")

return
*}

/*! \fn get_drn_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
function get_drn_fields(aArr)
*{
AADD(aArr, {"BRDOK",   "C",  "6", "0"})
AADD(aArr, {"DATDOK",  "D",  "8", "0"})
AADD(aArr, {"DATVAL",  "D",  "8", "0"})
AADD(aArr, {"DATISP",  "D",  "8", "0"})
AADD(aArr, {"MJESTO",  "C", "10", "0"})
AADD(aArr, {"KNAZIV",  "C", "20", "0"})
AADD(aArr, {"KADRESA", "C", "20", "0"})
AADD(aArr, {"KPDVBROJ","C", "12", "0"})
AADD(aArr, {"UKBEZPDV","N", "15", "5"})
AADD(aArr, {"UKPOPUST","N", "15", "5"})
AADD(aArr, {"UKPDV",   "N", "15", "5"})
AADD(aArr, {"CSUMRN",  "N",  "6", "0"})
return
*}


/*! \fn get_rn_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
function get_rn_fields(aArr)
*{
AADD(aArr, {"BRDOK",   "C",  "6", "0"})
AADD(aArr, {"RBR",     "C",  "3", "0"})
AADD(aArr, {"PODBR",   "C",  "2", "0"})
AADD(aArr, {"IDROBA",  "C", "10", "0"})
AADD(aArr, {"RNAZIV",  "C", "20", "0"})
AADD(aArr, {"JMJ",     "C",  "3", "0"})
AADD(aArr, {"KOLICINA","N", "15", "5"})
AADD(aArr, {"CIJENA",  "N", "15", "5"})
AADD(aArr, {"POPUST",  "N", "10", "5"})
AADD(aArr, {"PDV",     "N", "10", "5"})
return
*}


function drn_empty()
*{
O_DRN
select drn
zap

O_RN
select rn
zap

return
*}


