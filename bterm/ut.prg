#include "sc.ch"


// ------------------------------------------------------
// Pregled liste exportovanih dokumenata te odabir 
//   zeljenog fajla za import
//  - param cFilter - filter naziva dokumenta
//  - param cPath - putanja do exportovanih dokumenata
// ------------------------------------------------------
function _gFList( cFilter, cPath, cImpFile )

OpcF:={}

// cFilter := "*.txt" 
aFiles:=DIRECTORY(cPath + cFilter)

// da li postoje fajlovi
if LEN(aFiles)==0
	MsgBeep("U direktoriju za prenos nema podataka")
	return 0
endif

// sortiraj po datumu
ASORT(aFiles,,,{|x,y| x[3]>y[3]})
AEVAL(aFiles,{|elem| AADD(OpcF, PADR(elem[1],15)+" "+dtoc(elem[3]))},1)
// sortiraj listu po datumu
ASORT(OpcF,,,{|x,y| RIGHT(x,10)>RIGHT(y,10)})

h:=ARRAY(LEN(OpcF))
for i:=1 to LEN(h)
	h[i]:=""
next

// selekcija fajla
IzbF:=1
lRet := .f.
do while .t. .and. LastKey()!=K_ESC
	IzbF:=Menu("imp", OpcF, IzbF, .f.)
	if IzbF == 0
        	exit
        else
        	cImpFile:=Trim(cPath)+Trim(LEFT(OpcF[IzbF],15))
        	if Pitanje(,"Zelite li izvrsiti import fajla ?","D")=="D"
        		IzbF:=0
			lRet:=.t.
		endif
        endif
enddo
if lRet
	return 1
else
	return 0
endif

return 1
  

/*! \fn TxtErase(cTxtFile, lErase)
 *  \brief Brisanje fajla cTxtFile
 *  \param cTxtFile - fajl za brisanje
 *  \param lErase - .t. ili .f. - brisati ili ne brisati fajl txt nakon importa
 */
function TxtErase(cTxtFile, lErase)
if lErase == nil
	lErase := .f.
endif

// postavi pitanje za brisanje fajla
if lErase .and. Pitanje(,"Pobrisati txt fajl (D/N)?","D")=="N"
	return
endif

if FErase(cTxtFile) == -1
	MsgBeep("Ne mogu izbrisati " + cTxtFile)
	ShowFError()
endif

return


// -----------------------------------------------------
// puni matricu sa redom csv formatiranog
// -----------------------------------------------------
function csvrow2arr( cRow, cDelimiter )
local aArr := {}
local i
local cTmp := ""
local cWord := ""
local nStart := 1

for i := 1 to LEN( cRow )
	
	cTmp := SUBSTR( cRow, nStart, 1 )

	// ako je cTmp = ";" ili je iscurio niz - kraj stringa
	if cTmp == cDelimiter .or. i == LEN(cRow)
		
		// ako je iscurio - dodaj i zadnji karakter u word
		if i == LEN(cRow)
			cWord += cTmp
		endif

		// dodaj u matricu 
		AADD( aArr, cWord )
		cWord := ""
	
	else
		cWord += cTmp
	endif
	
	++ nStart 

next

return aArr


// ----------------------------------------------
// vraca numerik na osnovu txt polja
// ----------------------------------------------
function _g_num( cVal )
cVal := STRTRAN( cVal, ",", "." )
return VAL(cVal)


// -------------------------------------------------------------
// Provjera da li postoje sifre artikla u sifraniku FMK
// -------------------------------------------------------------
function TempArtExist()
O_ROBA
select temp
go top

aRet:={}

do while !EOF()

	cTmpRoba := ALLTRIM(temp->idroba)
	cNazRoba := ""

	// ako u temp postoji "NAZROBA"
	if temp->(FIELDPOS("nazroba")) <> 0
		cNazRoba := ALLTRIM(temp->nazroba)
	endif
	
	select roba
	
	go top
	seek cTmpRoba
	
	// ako nisi nasao dodaj robu u matricu
	if !Found() 
		nRes := ASCAN(aRet, {|aVal| aVal[1] == cTmpRoba})
		if nRes == 0
			AADD(aRet, {cTmpRoba, cNazRoba})
		endif
	endif
	
	select temp
	skip
enddo

return aRet



