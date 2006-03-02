#include "sc.ch"

static cij_decimala:=3
static izn_decimala:=2
static kol_decimala:=3
static lZaokruziti := .t.
static cLauncher1 := 'start "C:\Program Files\OpenOffice.org 2.0\program\scalc.exe"'
// zamjeniti tarabu sa brojem
static cLauncher2 := ""
static cLauncher := "officexp"
// 4 : 852 => US ASCII
static cKonverzija := "4"



// kreiraj tabelu u privpath
function t_exp_create(aFields)
*{
local cExpTbl := "R_EXPORT.DBF"
close all

ferase( PRIVPATH + cExpTbl )

// kreiraj tabelu
dbcreate2(PRIVPATH + cExpTbl, aFields)

return
*}


// export tabele
function tbl_export(cLauncher)
*{

close all

cLauncher := ALLTRIM(cLauncher)

if (cLauncher == "start")
	cKom := cLauncher + " " + PRIVPATH
else
   	cKom := cLauncher + " " + PRIVPATH + "r_export.dbf"
endif

MsgBeep("Tabela " + PRIVPATH + "R_EXPORT.DBF je formirana##" +;
        "Sa opcijom Open file se ova tabela ubacuje u excel #" +;
	"Nakon importa uradite Save as, i odaberite format fajla XLS ! ##" +;
	"Tako dobijeni xls fajl mozete mijenjati #"+;
	"prema svojim potrebama ...")
	
if Pitanje(, "Odmah pokrenuti spreadsheet aplikaciju ?", "D") == "D"	
	run &cKom
endif

return
*}


function set_launcher(cLauncher)
*{
local cPom

cPom = UPPER(ALLTRIM(cLauncher))


if (cPom == "OO") .or.  (cPom == "OOO") .or.  (cPom == "OPENOFFICE")
	cLauncher := cLauncher1
	return .f.
	
elseif (LEFT(cPom,6) == "OFFICE" )
        // OFFICEXP, OFFICE97, OFFICE2003
	cLauncher := msoff_start(SUBSTR(cPom, 7))
	return .f.
elseif (LEFT(cPom,5) == "EXCEL") 
        // EXCELXP, EXCEL97 
	cLauncher := msoff_start(SUBSTR(cPom, 6))
	return .f.
endif

return .t.
*}



function msoff_start(cVersion)
*{
local cPom :=  'start "C:\Program Files\Microsoft Office\Office#\excel.exe"'

if (cVersion == "XP")
  // office XP
  return STRTRAN(cPom,  "#", "10")
elseif (cVersion == "2000")
  // office 2000
  return STRTRAN(cPom, "#", "9")
elseif (EMPTY(cVersion))
  // instalacija office u /office/ direktoriju
  return STRTRAN(cPom, "#", "")
elseif (cVersion == "2003")
  // office 2003
  return STRTRAN(cPom, "#", "11")
elseif (cVersion == "97")
  // office 97
  return STRTRAN(cPom, "#", "8")
else
  // office najnoviji 2005?2006
  return STRTRAN(cPom, "#", "12")
endif

return
*}



// export funkcija
function exp_report()
*{

cLauncher := PADR(cLauncher, 70)

Box(, 10, 70)
	@ m_x+1, m_y+2 SAY "Parametri exporta:" COLOR "I"
	
	@ m_x+2, m_y+2  SAY "Konverzija slova (0-8) " GET cKonverzija PICT "9"
  	
  	@ m_x+3, m_y+2 SAY "Pokreni oo/office97/officexp/office2003 ?" GET cLauncher PICT "@S26" VALID set_launcher(@cLauncher)
  
  	read
BoxC()

if LastKey()==K_ESC
	closeret
endif

return cLauncher
*}


