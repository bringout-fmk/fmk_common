#include "ld.ch"


// ----------------------------------------
// vraca bruto osnovu
// ----------------------------------------
function bruto_osn( nIzn, cTipRada )
local nBrt := 0

altd()

// stari obracun
if gVarObracun <> "2"
	nBrt := ROUND2( nIzn * ( parobr->k3 / 100 ), gZaok2 )
	return nBrt
endif

do case
	// nesamostalni rad
	case cTipRada $ " #N"
		nBrt := ROUND2( nIzn * parobr->k5 ,gZaok2 )
	// samostalni rad
	case cTipRada == "S"
		nBrt := ROUND2( nIzn * parobr->k5 ,gZaok2 )
	// rezident
	case cTipRada == "R"
		nBrt := ROUND2( nIzn * parobr->k5 ,gZaok2 )
	// samostalni poslodavac
	case cTipRada == "D"
		nBrt := ROUND2( nIzn * parobr->k5 ,gZaok2 )
	// ugovor o radu
	case cTipRada == "U"
		nBrt := ROUND2( nIzn * parobr->k5 ,gZaok2 )
endcase

return nBrt


// ----------------------------------------
// ispisuje bruto obracun
// ----------------------------------------
function bruto_isp( nNeto, cTipRada )
local cPrn := ""

do case
	// nesamostalni rad
	case cTipRada $ " #N"
		cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
			ALLTRIM(STR(parobr->k5)) + " ="
	// samostalni rad
	case cTipRada == "S"
		cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
			ALLTRIM(STR(parobr->k5)) + " ="
	
	// samostalni poslodavac
	case cTipRada == "D"
		cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
			ALLTRIM(STR(parobr->k5)) + " ="
	
	// rezident
	case cTipRada == "R"
		cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
			ALLTRIM(STR(parobr->k5)) + " ="

	// ugovor o radu
	case cTipRada == "U"
		cPrn := ALLTRIM(STR(nNeto)) + " * " + ;
			ALLTRIM(STR(parobr->k5)) + " ="
	
endcase

return cPrn



// --------------------------------
// ispisuje potpis
// --------------------------------
function p_potpis()
private cP1 := gPotp1
private cP2 := gPotp2

if gPotpRpt == "N"
	return
endif

if !EMPTY(gPotp1)
	? &cP1	
endif

if !EMPTY(gPotp2)
	? &cP2
endif

return



// ------------------------------------------------
// vraca ukupnu vrijednost licnog odbitka
// ------------------------------------------------
function g_licni_odb( cIdRadn )
local nTArea := SELECT()
local nIzn := 0

select radn
seek cIdRadn

if field->klo <> 0
	nIzn := round2( gOsnLOdb * field->klo, gZaok2)
else
	nIzn := 0
endif

select (nTArea)
return nIzn


// ----------------------------------------------------------
// setuj obracun na tip u skladu sa zak.promjenama
// ----------------------------------------------------------
function set_obr_2009()

if YEAR(DATE()) >= 2009 .and. ;
	goModul:oDataBase:cSezona == "2009" .and. ;
	gVarObracun <> "2"

	MsgBeep("Nova je godina. Obracun je podesen u skladu sa#novim zakonskim promjenama !")
	gVarObracun := "2"

endif

return


// -----------------------------------------------
// vraca varijantu obracuna iz tabele ld
// -----------------------------------------------
function get_varobr()
return ld->varobr


// -----------------------------------------------------
// promjena varijante obracuna za tekuci obracun
// -----------------------------------------------------
function chVarObracun()
local nLjudi

if Logirati(goModul:oDataBase:cName,"DOK","CHVAROBRACUNA")
	lLogChVarObr:=.t.
else
	lLogChVarObr:=.f.
endif

Box(,4,60)
	@ m_x+1,m_y+2 SAY "Ova opcija vrsi zamjenu identifikatora varijante"
  	@ m_x+2,m_y+2 SAY "obracuna za tekuci obracun."
  	@ m_x+4,m_y+2 SAY "               <ESC> Izlaz"
  	inkey(0)
BoxC()

if (LastKey() == K_ESC)
	closeret
	return
endif

cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cVarijanta := SPACE(1)

O_RADN
O_LD

Box(,5,50)
	@ m_x+1,m_y+2 SAY "Radna jedinica: "  GET cIdRJ
	@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
	@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
	
	if lViseObr
  		@ m_x+4,m_y+2 SAY "Obracun:"  GET  cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
	endif
	
	@ m_x+5,m_y+2 SAY "Postavi na varijantu:" GET  cVarijanta

	read

	ClvBox()
	ESC_BCR
BoxC()

select ld
seek STR(cGodina,4)+cIdRj+STR(cMjesec,2)+BrojObracuna()

EOF CRET

nLjudi:=0

Box(,1,12)
  
   do while !eof() .and. cGodina==godina .and. cIdRj==idrj .and. cMjesec=mjesec .and. if(lViseObr,cObracun==obr,.t.)

	Scatter()
	_varobr := cVarijanta
	Gather()

 	@ m_x+1,m_y+2 SAY ++nLjudi pict "99999"
 	
	skip

   enddo
 
   if lLogChVarObracun
	EventLog(nUser,goModul:oDataBase:cName,"DOK","CHVAROBRACUN",nLjudi,nil,nil,nil,cIdRj,STR(cMjesec,2),STR(cGodina,4),Date(),Date(),"","Promjena varijante obracuna za tekuci obracun")
   endif

   Beep(1)
   inkey(1)

BoxC()

closeret

return



function NaDiskete()

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := gObracun

O_LD
copy structure extended to struct
use
create (PRIVPATH+"_LD") from struct
close all
O_RADN
copy structure extended to struct
use
create (PRIVPATH+"_RADN") from struct
close all
O_KRED
copy structure extended to struct
ferase(PRIVPATH+"_KRED.CDX")
use
create (PRIVPATH+"_KRED") from struct
#ifdef C50
 index on id to (PRIVPATH+"_kredi1")
#else
 index on id tag ("ID") to (PRIVPATH+"_kred")
#endif
close all
*
O_RADKR
copy structure extended to struct
ferase(PRIVPATH+"_RADKR.CDX")
use
create (PRIVPATH+"_RADKR") from struct
close all

O_KBENEF
O_VPOSLA
O_RJ
O_RADKR
O_KRED
O_RADN
O_LD
cmxAutoOpen(.f.)
O__LD; SET ORDER TO; GO TOP
cmxAutoOpen(.t.)
O__RADN
O__RADKR
O__KRED

private cKBenef:=" ",cVPosla:=" ",cDisk:="A:\"

Box(,6,50)
@ m_x+1,m_y+2 SAY "Radna jedinica : "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+4,m_y+2 SAY "Disketa:"  GET  cDisk
read; ESC_BCR

select ld
set order to 1
hseek str(cGodina,4)+cidrj+str(cMjesec,2)

do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec

 Scatter()  // ld

 select radn; hseek _idradn
 Scatter("r")        // radn
 select _radn
 append blank
 Gather("r")

 SELECT RadKr   // str(godina)+str(mjesec)+idradn+idkred+naosnovu

 HSEEK Str (cGodina,4)+Str (cMjesec)+_IdRadn
 IF Found()
   While !Eof() .and. RADKR->Godina==cGodina .and. RADKR->Mjesec==cMjesec;
         .and. RADKR->IdRadn==_IdRadn
     cIdKred := RADKR->IdKred
     While ! Eof() .and. RADKR->Godina==cGodina .and. RADKR->Mjesec==cMjesec;
           .and. RADKR->(IdRadn+IdKred)==(_IdRadn+cIdKred)
       Scatter ("w")
       SELECT _RADKR
       Append Blank
       Gather ("w")
       SELECT RADKR
       SKIP
     EndDO
     *
     SELECT KRED
     HSEEK cIdKred
     Scatter ("x")
     SELECT _KRED
     HSEEK cIdKred
     IF ! Found()
       Append Blank
       Gather ("x")
     EndIF
     *
     SELECT RADKR
   EndDO
 EndIF

 select _ld
 append blank
 Gather()

 select ld
 skip
enddo

close all

@ m_x+6,m_y+2 SAY "stavi praznu disketu.."
inkey(0)
copy file (PRIVPATH+"_LD.DBF") to (cDisk+"_LD.DBF")
copy file (PRIVPATH+"_RADN.DBF") to (cDisk+"_RADN.DBF")
copy file (PRIVPATH+"_RADKR.DBF") to (cDisk+"_RADKR.DBF")
copy file (PRIVPATH+"_KRED.DBF") to (cDisk+"_KRED.DBF")
#ifdef C50
 copy file (PRIVPATH+"_KREDi1.NTX") to (cDisk+"_KREDi1.NTX")
#else
 copy file (PRIVPATH+"_KRED.CDX") to (cDisk+"_KRED.CDX")
#endif
BoxC()

Beep(1)
Msg("Podaci kopirani na "+cDisk)

closeret



function SaDisketa()

local cOdgov:="N"

private cDisk:="A:\"

Box(,1,50)
 @ m_x+1,m_y+2 SAY "Disketa:"  GET  cDisk
 read; ESC_BCR
Boxc()

copy file (cDisk+"_LD.DBF") to (PRIVPATH+"_LD.DBF")
copy file (cDisk+"_RADN.DBF") to (PRIVPATH+"_RADN.DBF")
copy file (cDisk+"_RADKR.DBF") to (PRIVPATH+"_RADKR.DBF")
copy file (cDisk+"_KRED.DBF") to (PRIVPATH+"_KRED.DBF")
#ifdef C50
 copy file (cDisk+"_KREDi1.NTX") to (PRIVPATH+"_KREDi1.NTX")
#else
 copy file (cDisk+"_KRED.CDX") to (PRIVPATH+"_KRED.CDX")
#endif

O__KRED; GO TOP
O__RADKR; GO TOP
O__RADN; GO TOP
cmxAutoOpen(.f.)
O__LD; SET ORDER TO; GO TOP
cmxAutoOpen(.t.)

cidrj   := idrj
cmjesec := mjesec
cgodina := godina

O_KRED
O_RADKR
O_RADN
O_LD

hseek str(cGodina,4)+cidrj+str(cMjesec,2)
if found()
 Beep(2)
 Msg("Podaci za "+str(cMjesec,2)+"/"+str(cGodina,4)+" rj "+cidrj+" vec postoje")
 closeret
endif

SELECT _LD
GO TOP
Box(,6,40)
nRbr:=0
do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec

 Scatter()  // _ld
 @ m_x+1,m_y+2 SAY "LD ..."
 @ row(),col()+1 SAY ++nrbr pict "9999"
 SELECT LD
 append blank
 Gather()

 SELECT _LD
 SKIP 1
enddo


nRbr := 0
SELECT _RADN
GO TOP
do while !eof()

 Scatter()  // _radn
 @ m_x+2,m_y+2 SAY "RADNICI ..."
 @ row(),col()+1 SAY ++nrbr pict "9999"

 select radn
 hseek _id
 if !found()
  append blank
  Gather()
 elseif cOdgov!="O"
   if cOdgov=="A".or.(cOdgov:=Pitanje2("",'RADNIK:'+_id+'. Zelite li da zamijenite podatke?','N'))$'DA'
     Gather()
   endif
 endif
 select _radn
 skip 1
enddo

nRbr := 0
SELECT _RADKR
GO TOP
While ! Eof()
  Scatter()
  @ m_x+3,m_y+2 SAY "KREDITI ..."
  @ row(),col()+1 SAY ++nrbr pict "9999"
  SELECT RADKR  // str(godina)+str(mjesec)+idradn+idkred+naosnovu
  HSEEK STR (_Godina)+Str (_Mjesec)+_IdRadn+_IdKred+_NaOsnovu
  IF ! Found ()
    Append Blank
  EndIF
  Gather ()
  SELECT _RADKR
  SKIP 1
EndDO

nRbr := 0
SELECT _KRED
GO TOP
While ! Eof()
  Scatter()
  @ m_x+4,m_y+2 SAY "KREDITORI ..."
  @ row(),col()+1 SAY ++nrbr pict "9999"
  SELECT KRED
  HSEEK _Id
  IF ! Found ()
    Append Blank
  EndIF
  Gather ()
  SELECT _KRED
  SKIP 1
EndDO

Beep(3)
@m_x+6,m_y+2 SAY "Prenos je zavrsen !!!"
inkey(0)
BoxC()
closeret


// ------------------------------------------------
// preuzimanje podataka iz drugog obracuna
// ------------------------------------------------
function UzmiObr()
local i, lSveRJ

O_LD

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := " "
cDodati  := "N"

Box(,4,75)
 @ m_x+0,  m_y+2 SAY "PREUZETI PODATKE IZ OBRACUNA:"
 @ m_x+1,  m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
 @ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
 @ m_x+2,  m_y+2 SAY "RJ (prazno-sve):"  GET cIdRJ
 @ m_x+3,  m_y+2 SAY "Obracun: "  GET cObracun VALID cObracun<>gObracun .and. !EMPTY(cObracun)
 @ m_x+4,  m_y+2 SAY "Dodati (iznose) na postojeci obracun: "  GET cDodati pict "@!" valid cDodati $ "DN"
 read; ESC_BCR
BoxC()

lSveRJ:=.f.
if EMPTY(cIDRJ) .and. pitanje(,"Zelite li preuzeti podatke ZA SVE RJ za ovaj mjesec ?","D")=="D"
  lSveRJ:=.t.
endif

select ld
if lSveRJ
  SET ORDER TO TAG "2"
// "str(godina)+str(mjesec)+obr+idradn+idrj"
  seek str(cGodina,4)+str(cMjesec,2)+cObracun
else
// "str(godina)+idrj+str(mjesec)+obr+idradn"
  seek str(cGodina,4)+cIdRj+str(cMjesec,2)+cObracun
endif
if !found()
  Beep(1)
  Msg("Ovaj obracun ne postoji!",4)
  closeret
endif

IF lSveRJ
  do while !eof() .and. STR(godina,4)+str(Mjesec,2)+Obr==str(cGodina,4)+str(cMjesec,2)+cObracun
    nRec:=RECNO()
    Scatter()
    _godina := gGodina
    _mjesec := gMjesec
    _obr    := gObracun
    seek str(gGodina,4)+str(gMjesec,2)+gObracun+_idradn+_idrj
    IF FOUND()
      IF cDodati=="N"
        gather()
      ELSE
        private cpom:=""
        Scatter("w") // stanje u datoteci ld
        for i:=1 to cLDPolja
          cPom:=padl(alltrim(str(i)),2,"0")
          wi&cPom+=_i&cPom
        next
        wuneto+=_uneto
        wuodbici+=_uodbici
        wuiznos+=_uiznos
        Gather("w")
      ENDIF
    ELSE
      append blank
      gather()
    ENDIF
    GO (nRec); skip 1
  enddo
  MsgBeep("Preuzimanje podataka iz obracuna "+cObracun+" za "+STR(cMjesec,2)+"/"+STR(cGodina,4)+",#"+;
          " za sve RJ zavrseno. Novi obracun:"+gObracun+" za "+STR(gMjesec,2)+"/"+STR(gGodina,4))
ELSE
  do while !eof() .and. STR(godina,4)+IdRj+str(Mjesec,2)+Obr==str(cGodina,4)+cIdRj+str(cMjesec,2)+cObracun
    nRec:=RECNO()
    Scatter()
    _godina := gGodina
    _mjesec := gMjesec
    _idrj   := gRJ
    _obr    := gObracun
    seek str(gGodina,4)+gRj+str(gMjesec,2)+gObracun+_idradn
    IF FOUND()
      IF cDodati=="N"
        gather()
      ELSE
        private cpom:=""
        Scatter("w") // stanje u datoteci ld
        for i:=1 to cLDPolja
         cPom:=padl(alltrim(str(i)),2,"0")
         wi&cPom+=_i&cPom
        next
        wuneto+=_uneto
        wuodbici+=_uodbici
        wuiznos+=_uiznos
        Gather("w")
      ENDIF
    ELSE
       append blank
       gather()
    ENDIF
    GO (nRec); skip 1
  enddo
  MsgBeep("Preuzimanje podataka iz obracuna "+cObracun+" za "+STR(cMjesec,2)+"/"+STR(cGodina,4)+",#"+;
          " za RJ:"+cIdRJ+". Novi obracun:"+gObracun+" za "+STR(gMjesec,2)+"/"+STR(gGodina,4)+" za RJ:"+gRJ+".")
ENDIF

CLOSERET





function VisePuta()
*{
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := gObracun

private cKBenef:=" ",cVPosla:=" "

Box(,2,50)
 @ m_x+1, m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
 @ m_x+2, m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
 read; ESC_BCR
BoxC()

// CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")
// ----------- removao ovu liniju 21.11.2000. MS ------------

O_LD
set order to tag "2"

seek str(cgodina,4)+str(cmjesec,2)
start print cret
? Lokal("Radnici obradjeni vise puta za isti mjesec -"),cgodina,"/",cmjesec
?
? Lokal("RADNIK RJ     neto        sati")
? "------ -- ------------- ----------"
do while !eof() .and. str(cgodina,4)+str(cmjesec,2)==str(godina)+str(mjesec)
  cIdRadn:=idradn
  nProlaz:=0
  do while !eof() .and. str(godina)+str(mjesec)==str(godina)+str(mjesec) .and. idradn==cidradn
     ++nProlaz
     skip
  enddo
  if nProlaz>1
     seek str(cgodina,4)+str(cmjesec,2)+cidradn
     do while !eof() .and. str(godina)+str(mjesec)==str(cgodina,4)+str(cmjesec,2) .and. idradn==cidradn
        ? idradn,idrj,uneto,usati
        skip
     enddo
  endif
enddo
end print
closeret
return
*}



FUNC Reindex_all()
RETURN (NIL)


function o_nar()
return

