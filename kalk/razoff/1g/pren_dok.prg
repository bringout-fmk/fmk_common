#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/razoff/1g/pren_dok.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: pren_dok.prg,v $
 * Revision 1.2  2002/06/24 09:37:57  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/razoff/1g/pren_dok.prg
 *  \brief Prenos dokumenata izmedju udaljenih lokacija (diskete, modem)
 */


/*! \fn PrenosDiskete()
 *  \brief Osnovni meni opcija za prenos dokumenata izmedju udaljenih lokacija (diskete, modem)
 */

function PrenosDiskete()
*{
private Opc:={}
private opcexe:={}
AADD(opc,"1. prenos dokumenata   =>            ")
AADD(opcexe, {|| PrDisk()})
AADD(opc,"2. prijem dokumenata   <= ")
AADD(opcexe, {|| PovDisk()})
AADD(opc,"3. podesavanje prenosa i prijema")
AADD(opcexe, {|| PPPDisk() })
AADD(opc,"7. prebaci dokument iz druge firme")
AADD(opcexe, {|| IzKalk2f()})

private Izbor:=1
Menu_SC("disk")
closeret
return
*}




/*! \fn PrDisk()
 *  \brief Prenos podataka na diskete
 */

function PrDisk()
*{
local nRec

PRIVATE cLokPren    := "A:\"
PRIVATE cFZaPredaju := "AKALK"
PRIVATE cFZaPrijem  := "AKALK"
PRIVATE cUslovVDok  := "1;"
PRIVATE cSpecUslov  := ""
PRIVATE cKonvFirma  := ""
PRIVATE cKonvBrDok  := ""

PPPDisk(.t.)

if pitanje(,"Zelite li izvrsiti prenos KALK na diskete ?","N")=="N"
  closeret
endif

if Pitanje(,"Nulirati datoteke prenosa prije nastavka ?","D")=="D"
  O_PRIPR
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"_kalk") from (PRIVPATH+"struct")

  O_ROBA
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"_roba") from (PRIVPATH+"struct")

  O_PARTN
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"_partn") from (PRIVPATH+"struct")

  if Izfmkini('Svi','Sifk','N')=="D"
    O_SIFK
    copy structure extended to (PRIVPATH+"struct")
    use
    create (PRIVPATH+"_SIFK") from (PRIVPATH+"struct")

    O_SIFV
    copy structure extended to (PRIVPATH+"struct")

    use
    create (PRIVPATH+"_SIFV") from (PRIVPATH+"struct")

  endif

  close all

  O__KALK  // otvara se bez indeksa
  O__ROBA
  O__PARTN

  select _kalk; zap
  select _roba; zap
  select _partn; zap

  close all
endif

fSifk:=.f.
if Izfmkini('Svi','Sifk','N')=="D"
   fSifk:=.t.
endif

O__KALK
O_KALK

SELECT KALK; set order to 1  // idFirma+IdVD+BrDok+RBr
cidfirma:=gfirma
cIdVD:=space(2)
cBrDok:=space(8)

private qqBrDok:=space(80)
private qqIdVD:=PADR(cUslovVDok,80)
private qqSpecUslov:=PADR(cSpecUslov,80)
private dDatOd:=CTOD("")
private dDatDo:=DATE()

if !empty(cidVD)
 qqIdVD:=padr(cidVD+";",80)
endif

Box(,4,70)
 DO WHILE .T.
  @ m_x+1,  m_y+2  SAY  "Vrste dokumenata    "  GEt qqIdVD pict "@S40"
  @ m_x+2,  m_y+2  SAY  "Brojevi dokumenata  "  GEt qqBrDok pict "@S40"
  @ m_x+3,  m_y+2  SAY  "Spec.dodatni uslov  "  GEt qqSpecUslov pict "@S40"
  @ m_x+4,  m_y+2  SAY  "Obuvaceni period od:" GET dDatOd
  @ m_x+4,col()+2  SAY  "do:" GET dDatDo
  READ
  PRIVATE aUsl1:=Parsiraj(qqBrDok,"BrDok","C")
  PRIVATE aUsl3:=Parsiraj(qqIdVD,"IdVD","C")
  IF aUsl1<>NIL .and. ausl3<>NIL
    EXIT
  ENDIF
 ENDDO
Boxc()

qqSpecUslov:=TRIM(qqSpecUslov)

if Pitanje(,"Prenijeti u datoteku prenosa KALK sa ovim kriterijom ?","D")=="D"
  select KALK
  if !flock(); Msg("KALK je zauzeta ",3); closeret; endif

  PRIVATE cFilt1:=""
  cFilt1 := "IDFIRMA=="+cm2str(cIdFirma)+".and."+aUsl1+".and."+aUsl3
  if !empty(dDatOd) .or. !empty(dDatDo)
    cFilt1 += ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
  endif

  IF !EMPTY(qqSpecUslov)
    cFilt1 += ".and.("+qqSpecUslov+")"
  ENDIF

  cFilt1 := STRTRAN(cFilt1,".t..and.","")

  IF !(cFilt1==".t.")
    SET FILTER TO &cFilt1
  ENDIF

  go top

  MsgO("Prolaz kroz KALK...")
  StartPrint(.t.)
  ? "KALK - U DATOTECI ZA PRENOS SU SLJEDECI DOKUMENTI - KALK:"
  ?; ? "FIRMA� TIP �  BROJ  �  DATUM "
     ? "-----------------------------"
  do while !eof()
    select KALK
    Scatter()
    select _KALK
      append ncnl;  Gather2()
    select KALK
    SKIP 1; cpFirma:=idfirma; cpTipDok:=idvd; cpBrDok:=brdok; SKIP -1
    IF cpFirma+cpTipDok+cpBrDok!=idfirma+idvd+brdok
     ? "  "+idfirma+" �  "+idvd+" �"+brdok+"�"+DTOC(datdok)
    ENDIF
    skip
  enddo
  EndPrint()

  MsgC()
else
  close all
  return
endif
close all

O_ROBA
O_PARTN

if fsifk
	O_SIFK
	O_SIFV
endif

O__ROBA
INDEX ON id TO "_ROBATMP"  // index radi trazenja

O__PARTN
INDEX ON id TO "_PARTTMP"  // index radi trazenja

select _roba
//append from roba  !! ? kupi i sto treba i sto ne treba

MsgO("Osvjezavam datoteke _Roba i _Partn ... ")
O__KALK
select _KALK; go top
// uzmi samo artikle koji su se pojavili u dokumentima !!!!


do while !eof()

  select _roba
  // nafiluj tabelu _ROBA sa siframa iz dokumenta
  seek _KALK->idroba
  if !found()
    select roba
    seek _KALK->idroba
    if found()
     scatter()
     // dodaj u _roba
     select _roba
     append blank
     Gather()
    endif
    if fsifk
      SifkFill(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_KALK->idroba)
    endif
  endif

  select _partn
  // nafiluj tabelu _PARTN sa siframa iz dokumenta
  seek _KALK->idpartner
  if !found()
    select partn
    seek _KALK->idpartner
    if found()
     scatter()
     // dodaj u _partn
     select _partn
     append blank
     Gather()
    endif
    if fsifk
      SifkFill(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","PARTN",_KALK->idpartner)
    endif
  endif

  select _KALK
  skip
enddo

MsgC()

close all

FILECOPY( PRIVPATH+"OUTF.TXT" , PRIVPATH+"_KALK.TXT" )


aFajlovi:={ PRIVPATH+"_KALK.*",;
            PRIVPATH+"_roba.*",;
            PRIVPATH+"_partn.*",;
            PRIVPATH+"_SIF?.*"}
Zipuj(aFajlovi,cFZaPredaju,cLokPren)
return
*}





/*! \fn PovDisk()
 *  \brief Preuzimanje podataka sa diskete
 */

function PovDisk()
*{
local nRec

PRIVATE cLokPren    := "A:\"
PRIVATE cFZaPredaju := "AKALK"
PRIVATE cFZaPrijem  := "AKALK"
PRIVATE cUslovVDok  := "1;"
PRIVATE cSpecUslov  := ""
PRIVATE cKonvFirma  := ""
PRIVATE cKonvBrDok  := ""

PPPDisk(.t.)

fSifk:=.f.
if Izfmkini('Svi','Sifk','N')=="D"
   fSifk:=.t.
endif

if Klevel<>"0"
    Beep(2)
    Msg("Nemate pristupa ovoj opciji !",4)
    closeret
endif

// if Pitanje(,"Izvrsiti prenos sa disketa ?","N")=="N"
//   closeret
// endif

IF !Unzipuj(cFZaPrijem,,cLokPren)   // raspakuje u PRIVPATH
  CLOSERET
ENDIF

close all
if lastkey()==K_ESC; return; endif

save screen to cs
VidiFajl(PRIVPATH+"_KALK.TXT")
IF Pitanje(,"Zelite li preuzeti prikazane dokumente? (D/N)"," ")=="N"
  restore screen from cs
  RETURN
ENDIF
restore screen from cs

O__KALK
O_PRIPR

SELECT _KALK; set order to 0  // idFirma+IdVD+BrDok+RBr

if !EMPTY(cKonvFirma+cKonvBrDok)
  aKBrDok:=TokUNiz(cKonvBrDok)
  aKFirma:=TokUNiz(cKonvFirma)
  GO TOP
  DO WHILE !EOF()
    nPosKBrDok := ASCAN( aKBrDok , {|x| x[1]==IDVD   } )
    IF nPosKBrDok>0
      cPom777 := aKBrDok[nPosKBrDok,2]
      REPLACE brdok WITH &cPom777
    ENDIF
    nPosKFirma := ASCAN( aKFirma , {|x| x[1]==IDFIRMA} )
    IF nPosKFirma>0
      REPLACE idfirma WITH aKFirma[nPosKFirma,2]
    ENDIF
    SKIP 1
  ENDDO
endif

cidfirma:=gfirma; cIdVD:=space(2); cBrDok:=space(8)

MsgO("Prenos _KALK -> PRIPR")
select pripr
append from _KALK
MsgC()

IF IzFMKINI("KALK","OsvjeziBarKod","N",PRIVPATH)=="D"
 cdn1:="D"      // ROBA - DODATI nepostojece sifre ?
 cdn2:="N"      // ROBA - ZAMIJENITI postojece sifre ?
 cdn3:="D"      // ROBA - osvjeziti bar-kodove ?
ELSE
 cdn1:=Pitanje(,"ROBA - DODATI nepostojece sifre ?","D")
 cdn2:=Pitanje(,"ROBA - ZAMIJENITI postojece sifre ?","D")
 cdn3:="N"      // ROBA - osvjeziti bar-kodove ?
ENDIF

if cdn1=="D"
close all
O_ROBA
if fsifk
   O_SIFK;   O_SIFV
endif
O__ROBA
set order to 0; go top
Box(,1,60)
// prolazimo kroz _ROBA
do while !eof()
  @ m_x+1,m_y+2 SAY id; ?? "-",naz
  select roba; scatter()
  select _roba
  scatter()
  select roba; hseek _id
  if !found()
    append blank
    gather()
    if fSifk
       SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_id)
    endif
  else
    if cdn2=="D"  // zamjeniti postojece sifre
     gather()
     if fsifk
        SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_id)
     endif
    elseif cdn3=="D"
        Scatter()
         _barkod := _ROBA->barkod
        Gather()
    endif
  endif
  select _roba
  skip
enddo
Boxc()
endif // cnd1

if pitanje(,"PARTN - dodati nepostojece sifre ?","D")=="D"
  close all
  O_PARTN
  if fsifk
     O_SIFK;   O_SIFV
  endif
  O__PARTN
  set order to 0; go top
  Box(,1,60)
  do while !eof()
    @ m_x+1,m_y+2 SAY id; ?? "-",naz
    select partn ;   scatter()
    select _partn
    scatter()
    select partn; hseek _id
    if !found()
      append blank
      gather()
      if fSifk
         SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","PARTN",_id)
      endif
    endif
    select _partn
    skip
  enddo
  BoxC()
endif

closeret
return
*}




/*! \fn PPPDisk(lIni)
 *  \param lIni - .t. vec su inicijalizovani parametri, .f. treba inicijalizovati parametre - default vrijednost
 *  \brief Podesavanje parametara prenosa i prijema podataka putem disketa
 */

function PPPDisk(lIni)
*{
 LOCAL GetList:={}
  IF lIni==NIL; lIni:=.f.; ENDIF
  O_PARAMS
  private cSection:="3",cHistory:=" "; aHistory:={}

  IF !lIni
    private cLokPren    := "A:\"
    private cFZaPredaju := "AKALK"
    private cFZaPrijem  := "AKALK"
    private cUslovVDok  := ""
    private cSpecUslov  := ""
    private cKonvFirma  := ""
    private cKonvBrDok  := ""
  ENDIF

  RPar("01",@cLokPren    )
  RPar("02",@cFZaPredaju )
  RPar("03",@cFZaPrijem  )
  RPar("04",@cUslovVDok  )
  RPar("05",@cSpecUslov  )
  RPar("06",@cKonvFirma  )
  RPar("07",@cKonvBrDok  )

  IF !lIni

    cLokPren    := PADR( cLokPren    , 80 )
    cFZaPredaju := PADR( cFZaPredaju , 80 )
    cFZaPrijem  := PADR( cFZaPrijem  , 80 )
    cUslovVDok  := PADR( cUslovVDok  , 80 )
    cSpecUslov  := PADR( cSpecUslov  , 80 )
    cKonvFirma  := PADR( cKonvFirma  , 80 )
    cKonvBrDok  := PADR( cKonvBrDok  , 80 )

    Box(,12,75)
     @ m_X+ 0,m_y+ 4 SAY "PODESAVANJE PARAMETARA ZA PRENOS I PRIJEM PODATAKA PUTEM DISKETA"
     @ m_X+ 2,m_y+ 2 SAY "Lokacija za prenos            " GET cLokPren    PICT "@!S30"
     @ m_X+ 3,m_y+ 2 SAY "Naziv fajla za predaju        " GET cFZaPredaju PICT "@!S30"
     @ m_X+ 4,m_y+ 2 SAY "Naziv fajla za prijem         " GET cFZaPrijem  PICT "@!S30"
     @ m_X+ 5,m_y+ 2 SAY "Standardno koristeni uslov za "
     @ m_X+ 6,m_y+ 2 SAY "tip dokumenata koji se prenose" GET cUslovVDok  PICT "@!S30"
     @ m_X+ 7,m_y+ 2 SAY "Specificni dodatni uslov      " GET cSpecUslov  PICT "@!S30"
     @ m_X+ 8,m_y+ 2 SAY "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
     @ m_X+ 9,m_y+ 2 SAY "Konverzije pri prijemu dokumenata:"
     @ m_X+10,m_y+ 2 SAY "Oznaka firme (F1.F2;F3.F4 ...)  " GET cKonvFirma  PICT "@!S30"
     @ m_X+11,m_y+ 2 SAY "Br.dokumenta (VD1.F1;VD2.F2 ...)" GET cKonvBrDok  PICT "@!S30"
     READ
    BoxC()

    cLokPren    := TRIM( cLokPren    )
    cFZaPredaju := TRIM( cFZaPredaju )
    cFZaPrijem  := TRIM( cFZaPrijem  )
    cUslovVDok  := TRIM( cUslovVDok  )
    cSpecUslov  := TRIM( cSpecUslov  )
    cKonvFirma  := TRIM( cKonvFirma  )
    cKonvBrDok  := TRIM( cKonvBrDok  )

    IF LASTKEY()!=K_ESC
      WPar("01",cLokPren    )
      WPar("02",cFZaPredaju )
      WPar("03",cFZaPrijem  )
      WPar("04",cUslovVDok  )
      WPar("05",cSpecUslov  )
      WPar("06",cKonvFirma  )
      WPar("07",cKonvBrDok  )
    ENDIF

  ENDIF
  USE
return
*}



