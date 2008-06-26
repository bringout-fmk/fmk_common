#include "fmk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/rpt_cjen.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.3 $
 * $Log: rpt_cjen.prg,v $
 * Revision 1.3  2002/08/19 10:04:24  ernad
 *
 *
 * podesenja CLIP
 *
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */
 
function CjenR()
*{
private cKomLin

if Pitanje(,"Formiranje cjenovnika ?","N")=="N"
   return DE_CONT
endif

SELECT ROBA
select (F_BARKOD)

if !used()
	O_BARKOD
endif
SELECT BARKOD
ZAP

SELECT roba
GO TOP
MsgO("Priprema barkod.dbf za cjen")

cIniName:=EXEPATH+'ProIzvj.ini'

//Iscita var Linija1 iz FMK.INI/KUMPATH u PROIZVJ.INI
UzmiIzIni(cIniName,'Varijable','Linija1',IzFmkIni("Zaglavlje","Linija1",gNFirma,KUMPATH),'WRITE')
UzmiIzIni(cIniName,'Varijable','Linija2',IzFmkIni("Zaglavlje","Linija2","-",KUMPATH),'WRITE')
UzmiIzIni(cIniName,'Varijable','Linija3',IzFmkIni("Zaglavlje","Linija3","-",KUMPATH),'WRITE')
UzmiIzIni(cIniName,'Varijable','Linija4',IzFmkIni("Zaglavlje","Linija4","-",KUMPATH),'WRITE')
UzmiIzIni(cIniName,'Varijable','Linija5',IzFmkIni("Zaglavlje","Linija5","-",KUMPATH),'WRITE')
UzmiIzIni(cIniName,'Varijable','CjenBroj',IzFmkIni("Zaglavlje","CjenBroj","-",KUMPATH),'WRITE')
cCjenIzbor:=IzFmkIni("Zaglavlje","CjenIzbor"," ",KUMPATH)

do while !EOF()
  SELECT BARKOD
  APPEND BLANK
  REPLACE ID       WITH  roba->id ,;
          NAZIV    WITH  TRIM(LEFT(ROBA->naz, 40))+" ("+TRIM(ROBA->jmj)+")" ,;
          VPC      WITH  ROBA->vpc,;
          MPC      WITH  ROBA->mpc
  select roba
  skip
enddo
MsgC()

close all

 // Izbor cjenovnika  ( /M/V)

PRIVATE cCjenBroj:=space(15)
PRIVATE cCjenIzbor:=" "

BOX (,4,40)
  @ m_x+1, m_y+2 SAY "Cjenovnik broj : " GET cCjenBroj
  @ m_x+3, m_y+2 SAY "Cjenovnik ( /M/V) : " GET cCjenIzbor VALID cCjenIzbor $ " MV"
  @ m_x+4, m_y+2 SAY "M - sa MPC,V - sa VPC,prazno - sve"
READ
boxc()

UzmiIzIni(cIniName,'Varijable','CjenBroj',cCjenBroj,'WRITE')
UzmiIzIni(KUMPATH+'FMK.INI','Zaglavlje','CjenBroj',cCjenBroj,'WRITE')
UzmiIzIni(KUMPATH+'FMK.INI','Zaglavlje','CjenIzbor',cCjenIzbor,'WRITE')

IF LASTKEY()==K_ESC
	RETURN DE_CONT
endif

if pitanje(,"Aktivirati Win Report ?","N")=="N"
	return
endif

cKomLin:="DelphiRB "+IzFmkIni("Cjen","CjenRTM","cjen", SIFPATH)+TRIM(cCjenIzbor)
if IsPlanika()
	MsgO("kopi -> c:/sigma")
		//kopiraj sa mreznog diska na c:
		COPY FILE (PRIVPATH+"barkod.dbf") TO ("c:\sigma\barkod.dbf")
		COPY FILE (PRIVPATH+"barkod.cdx") TO ("c:\sigma\barkod.cdx")
	MsgC()
	cKomLin += " c:\sigma\  barkod id"
else
	cKomLin += " "+PRIVPATH+"  barkod id"
endif

run &cKomLin
return DE_CONT


// ------------------------------------------------------
// stampa rekapitulacije stara cijena -> nova cijena
// ------------------------------------------------------
function rpt_zanivel()
local nTArea := SELECT()
local cZagl
local cLine
local cRazmak := SPACE(1)
local nCnt

O_ROBA
select roba
set order to tag "ID"
go top

// ako ne postoji polje u robi, nista...
if roba->(fieldpos("zanivel")) == 0
	return
endif

cZagl := PADC("R.br", 6)
cZagl += cRazmak
cZagl += PADC("ID", 10)
cZagl += cRazmak
cZagl += PADC("Naziv", 20)
cZagl += cRazmak
cZagl += PADC("Stara cijena", 15)
cZagl += cRazmak
cZagl += PADC("Nova cijena", 15)

cLine := REPLICATE("-", LEN(cZagl))

START PRINT CRET

? "Pregled promjene cijena u sifrarniku robe"
?
? cLine
? cZagl
? cLine

nCnt := 0

do while !EOF()

	if field->zanivel == 0
		skip
		loop
	endif
	
	++ nCnt
	
	? PADL( STR( nCnt, 5) + ".", 6 ), PADR(field->id, 10), PADR(field->naz, 20), PADL( STR(field->mpc, 12, 2), 15 ), PADL( STR(field->zanivel, 12, 2), 15 )
	
	skip
	
enddo

FF
END PRINT

select (nTArea)

return
