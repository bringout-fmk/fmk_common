#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/razoff/1g/faktdisk.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: faktdisk.prg,v $
 * Revision 1.5  2002/09/12 07:51:55  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.4  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.3  2002/07/03 12:25:27  sasa
 * Ispravljeno ime funkcije FaktDisk() na PrenosDiskete()
 *
 * Revision 1.2  2002/06/18 13:48:35  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/razoff/1g/faktdisk.prg
 *  \brief Podesavanje i prenos dokumenata FAKT<->FAKT (modem,diskete)
 */

/*! \ingroup ini
  * \var *string FmkIni_ExePath_Svi_Sifk
  * \brief Da li se koriste sifrarnici SIFK i SIFV?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_Svi_Sifk;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_FAKT_OsvjeziBarKod
  * \brief Da li se pri prenosu dokumenata iz FAKT u FAKT (diskete) trebaju osvjezavati i barkodovi u sifrarniku robe?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_PrivPath_FAKT_OsvjeziBarKod;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_PriFAKTuFAKTPrenosuOsvjeziNaziveRobe
  * \brief Da li se pri prenosu dokumenata iz FAKT u FAKT (diskete) trebaju osvjezavati i nazivi roba u sifrarniku robe?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_PriFAKTuFAKTPrenosuOsvjeziNaziveRobe;



/*! \fn PrenosDiskete()
 *  \brief Prenos dokumenta FAKT<->FAKT putem disketa ili modema
 */
 
function PrenosDiskete()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. prenos dokumenata   =>        ")
AADD(opcexe,{|| PrDisk()})
AADD(opc,"2. prijem dokumenata   <= ")
AADD(opcexe,{|| PovDisk()})
AADD(opc,"3. podesavanje prenosa i prijema")
AADD(opcexe,{|| PPPDisk()})
Menu_SC("faktd")
closeret
*}



/*! \fn PrDisk()
 *  \brief Prenos na diskete
 */
 
function PrDisk()
*{
local nRec
PRIVATE cLokPren    := "A:\"
PRIVATE cFZaPredaju := "FAKT"
PRIVATE cFZaPrijem  := "FAKT"
PRIVATE cUslovTDok  := "1;"
PRIVATE cSpecUslov  := ""
PRIVATE cSinSFormula:= "99"
PRIVATE cKonvFirma  := ""
PRIVATE cKonvBrDok  := ""

PPPDisk(.t.)

if pitanje(,"Zelite li izvrsiti prenos FAKT na diskete ?","N")=="N"
  closeret
endif

if Pitanje(,"Nulirati datoteke prenosa prije nastavka ?","D")=="D"
  O_PRIPR
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"_fakt") from (PRIVPATH+"struct")

  O_ROBA
  copy structure extended to (PRIVPATH+"struct")
  use
  create (PRIVPATH+"_roba") from (PRIVPATH+"struct")
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

  O__FAKT  // otvara se bez indeksa
  O__ROBA

  select _fakt; zap
  select _roba; zap

  close all
endif

fSifk:=.f.
if Izfmkini('Svi','Sifk','N')=="D"
   fSifk:=.t.
endif


O__FAKT
IF cSinSFormula!="99"       // bilo:gNovine=="D"
  INDEX ON idfirma+idtipdok+brdok+idroba TO "_FAKTTMP"
ENDIF
O_FAKT

SELECT FAKT; set order to 1  // idFirma+Idtipdok+BrDok+RBr
cidfirma:=gfirma
cIdTipdok:=space(2)
cBrDok:=space(8)

private qqBrDok:=space(80)
private qqIdTipdok:=PADR(cUslovTDok,80)
private qqSpecUslov:=PADR(cSpecUslov,80)
private dDatOd:=CTOD("")
private dDatDo:=DATE()

if !empty(cidtipdok)
 qqIdTipdok:=padr(cidtipdok+";",80)
endif
Box(,4,70)
 DO WHILE .T.
  @ m_x+1,  m_y+2  SAY  "Vrste dokumenata    "  GEt qqIdTipdok pict "@S40"
  @ m_x+2,  m_y+2  SAY  "Brojevi dokumenata  "  GEt qqBrDok pict "@S40"
  @ m_x+3,  m_y+2  SAY  "Spec.dodatni uslov  "  GEt qqSpecUslov pict "@S40"
  @ m_x+4,  m_y+2  SAY  "Obuvaceni period od:" GET dDatOd
  @ m_x+4,col()+2  SAY  "do:" GET dDatDo
  READ
  PRIVATE aUsl1:=Parsiraj(qqBrDok,"BrDok","C")
  PRIVATE aUsl3:=Parsiraj(qqIdTipdok,"IdTipDok","C")
  IF aUsl1<>NIL .and. ausl3<>NIL
    EXIT
  ENDIF
 ENDDO
Boxc()

qqSpecUslov:=TRIM(qqSpecUslov)

if Pitanje(,"Prenijeti u datoteku prenosa fakt sa ovim kriterijom ?","D")=="D"
  select fakt
  if !flock(); Msg("FAKT je zauzeta ",3); closeret; endif

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

  altd()
  go top

  MsgO("Prolaz kroz FAKT...")
  StartPrint(.t.)
  ? "FAKT - U DATOTECI ZA PRENOS SU SLJEDECI DOKUMENTI - FAKT:"
  ?; ? "FIRMA� TIP �  BROJ  �  DATUM "
     ? "-----------------------------"
  do while !eof()
    select FAKT
    IF cSinSFormula!="99"; nDuzSintSifre:=&cSinSFormula; ENDIF
    Scatter()
    select _FAKT
    IF cSinSFormula!="99" .and. nDuzSintSifre>0 .and. nDuzSintSifre<10   // bilo:gNovine=="D"
      _idroba:=LEFT(_idroba,nDuzSintSifre)
      SEEK _idfirma+_idtipdok+_brdok+_idroba
      IF FOUND() .and. rabat=_rabat .and. porez=_porez .and. cijena=_cijena
        REPLACE kolicina WITH kolicina+_kolicina
      ELSE
        append ncnl;  Gather2()
      ENDIF
    ELSE
      append ncnl;  Gather2()
    ENDIF
    select fakt
    SKIP 1; cpFirma:=idfirma; cpTipDok:=idtipdok; cpBrDok:=brdok; SKIP -1
    IF cpFirma+cpTipDok+cpBrDok!=idfirma+idtipdok+brdok
     ? "  "+idfirma+" �  "+idtipdok+" �"+brdok+"�"+DTOC(datdok)
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


if fsifk
   O_SIFK;  O_SIFV
endif
O__ROBA
INDEX ON id TO "_ROBATMP"  // index radi trazenja

select _roba
//append from roba  !! ? kupi i sto treba i sto ne treba

MsgO("Osvjezavam datoteku _Roba ... ")
O__FAKT
select _fakt; go top
// uzmi samo artikle koji su se pojavili u dokumentima !!!!

do while !eof()

  select _roba
  // nafiluj tabelu _ROBA sa siframa iz dokumenta
  seek _fakt->idroba
  if !found()
    select roba
    seek _fakt->idroba
    if found()
     scatter()
     // dodaj u _roba
     select _roba
     append blank
     Gather()
    endif
    if fsifk
      SifkFill(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_fakt->idroba)
    endif
  endif

  select _fakt
  skip
enddo

MsgC()

close all

FILECOPY( PRIVPATH+"OUTF.TXT" , PRIVPATH+"_FAKT.TXT" )

aFajlovi:={ PRIVPATH+"_fakt.*", PRIVPATH+"_roba.*", PRIVPATH+"_SIF?.*"}
Zipuj(aFajlovi,cFZaPredaju,cLokPren)
return
*}




/*! \fn PovDisk()
 *  \brief Povrat podataka 
 */
 
function PovDisk()
*{
local nRec, cDiff:=""
PRIVATE cLokPren    := "A:\"
PRIVATE cFZaPredaju := "FAKT"
PRIVATE cFZaPrijem  := "FAKT"
PRIVATE cUslovTDok  := "1;"
PRIVATE cSpecUslov  := ""
PRIVATE cSinSFormula:= "99"
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

IF !Unzipuj(cFZaPrijem,,cLokPren)   // raspakuje u PRIVPATH
  CLOSERET
ENDIF

close all
if lastkey()==K_ESC; return; endif

save screen to cs
VidiFajl(PRIVPATH+"_FAKT.TXT")
IF Pitanje(,"Zelite li preuzeti prikazane dokumente? (D/N)"," ")=="N"
  restore screen from cs
  RETURN
ENDIF
restore screen from cs

O__FAKT
O_PRIPR

SELECT _FAKT; set order to 0  // idFirma+IdTipdok+BrDok+RBr

if !EMPTY(cKonvFirma+cKonvBrDok)
  aKBrDok:=TokUNiz(cKonvBrDok)
  aKFirma:=TokUNiz(cKonvFirma)
  GO TOP
  DO WHILE !EOF()
    nPosKBrDok := ASCAN( aKBrDok , {|x| x[1]==IDTIPDOK} )
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

cidfirma:=gfirma; cIdTipdok:=space(2); cBrDok:=space(8)

MsgO("Prenos _FAKT -> PRIPR")
select pripr
append from _fakt
MsgC()

IF IzFMKINI("FAKT","OsvjeziBarKod","N",PRIVPATH)=="D"
 cdn1:="D"      // ROBA - DODATI nepostojece sifre ?
 cdn2:="N"      // ROBA - ZAMIJENITI postojece sifre ?
 cdn3:="D"      // ROBA - osvjeziti bar-kodove ?
ELSE
 cdn1:=Pitanje(,"ROBA - DODATI nepostojece sifre ?","D")
 cdn2:=Pitanje(,"ROBA - ZAMIJENITI postojece sifre ?","D")
 cdn3:="N"      // ROBA - osvjeziti bar-kodove ?
ENDIF

lOsvNazRobe := ( IzFMKIni("FAKT","PriFAKTuFAKTPrenosuOsvjeziNaziveRobe","N",KUMPATH)=="D" )

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

cRFajl := PRIVPATH+"FAKT.RF"

UpisiURF("IZVJESTAJ O PROMJENAMA NA SIFRARNIKU ROBE:",cRFajl,.t.,.t.)
UpisiURF("------------------------------------------",cRFajl,.t.,.f.)

do while !eof()
  @ m_x+1,m_y+2 SAY id; ?? "-",naz
  select roba; scatter()
  select _roba
  scatter()
  select roba; hseek _id
  if !found()
    UpisiURF("ROBA: dodajem "+_id+"-"+_naz,cRFajl,.t.,.f.)
    append blank
    gather()
    if fSifk
      SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_id)
    endif
  else
    if cdn2=="D"  // zamjeniti postojece sifre
      cDiff:=""
      IF DiffMFV(,@cDiff)
        UpisiURF("ROBA: osvjezavam "+_id+"-"+_naz+cDiff,cRFajl,.t.,.f.)
      ENDIF
      gather()
      if fsifk
        SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_id)
      endif
    else
      if cdn3=="D"
        Scatter()
        IF _barkod <>_roba->barkod
          UpisiURF("ROBA: osvjezavam "+_id+"-"+_naz,cRFajl,.t.,.f.)
          UpisiURF("     BARKOD: bilo="+TRANS(_barkod,"")+", sada="+TRANS(_ROBA->barkod,""),cRFajl,.t.,.f.)
        ENDIF
        _barkod := _ROBA->barkod
        Gather()
      endif
      if lOsvNazRobe
        Scatter()
        IF _naz <> _roba->naz
          UpisiURF("ROBA: osvjezavam "+_id+"-"+_naz,cRFajl,.t.,.f.)
          UpisiURF("     NAZIV: bilo="+TRANS(_naz,"")+", sada="+TRANS(_ROBA->naz,""),cRFajl,.t.,.f.)
        ENDIF
        _naz := _ROBA->naz
        Gather()
      endif
    endif
  endif
  select _roba
  skip
enddo
Boxc()
endif // cnd1

save screen to cs
VidiFajl(cRFajl)
restore screen from cs

closeret
*}


/*! \fn PPPDisk(lIni)
 *  \brief Podesavanje parametara prenosa
 */
 
function PPPDisk(lIni)
*{
LOCAL GetList:={}
  IF lIni==NIL; lIni:=.f.; ENDIF
  O_PARAMS
  private cSection:="3",cHistory:=" "; aHistory:={}

  IF !lIni
    private cLokPren    := "A:\"
    private cFZaPredaju := "FAKT"
    private cFZaPrijem  := "FAKT"
    private cUslovTDok  := "1;"
    private cSpecUslov  := ""
    private cSinSFormula:= "99"
    private cKonvFirma  := ""
    private cKonvBrDok  := ""
  ENDIF

  RPar("01",@cLokPren    )
  RPar("02",@cFZaPredaju )
  RPar("03",@cFZaPrijem  )
  RPar("04",@cUslovTDok  )
  RPar("05",@cSpecUslov  )
  RPar("06",@cSinSFormula)
  RPar("07",@cKonvFirma  )
  RPar("08",@cKonvBrDok  )

  IF !lIni

    cLokPren    := PADR( cLokPren    , 80 )
    cFZaPredaju := PADR( cFZaPredaju , 80 )
    cFZaPrijem  := PADR( cFZaPrijem  , 80 )
    cUslovTDok  := PADR( cUslovTDok  , 80 )
    cSpecUslov  := PADR( cSpecUslov  , 80 )
    cSinSFormula:= PADR( cSinSFormula, 80 )
    cKonvFirma  := PADR( cKonvFirma  , 80 )
    cKonvBrDok  := PADR( cKonvBrDok  , 80 )

    Box(,13,75)
     @ m_X+ 0,m_y+ 4 SAY "PODESAVANJE PARAMETARA ZA PRENOS I PRIJEM PODATAKA PUTEM DISKETA"
     @ m_X+ 2,m_y+ 2 SAY "Lokacija za prenos            " GET cLokPren    PICT "@!S30"
     @ m_X+ 3,m_y+ 2 SAY "Naziv fajla za predaju        " GET cFZaPredaju PICT "@!S30"
     @ m_X+ 4,m_y+ 2 SAY "Naziv fajla za prijem         " GET cFZaPrijem  PICT "@!S30"
     @ m_X+ 5,m_y+ 2 SAY "Standardno koristeni uslov za "
     @ m_X+ 6,m_y+ 2 SAY "tip dokumenata koji se prenose" GET cUslovTDok  PICT "@!S30"
     @ m_X+ 7,m_y+ 2 SAY "Specificni dodatni uslov      " GET cSpecUslov  PICT "@!S30"
     @ m_X+ 8,m_y+ 2 SAY "Formula za duzinu sintet.sifre" GET cSinSFormula PICT "@!S30"
     @ m_X+ 9,m_y+ 2 SAY "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
     @ m_X+10,m_y+ 2 SAY "Konverzije pri prijemu dokumenata:"
     @ m_X+11,m_y+ 2 SAY "Oznaka firme (F1.F2;F3.F4 ...)  " GET cKonvFirma  PICT "@!S30"
     @ m_X+12,m_y+ 2 SAY "Br.dokumenta (VD1.F1;VD2.F2 ...)" GET cKonvBrDok  PICT "@!S30"
     READ
    BoxC()

    cLokPren    := TRIM( cLokPren    )
    cFZaPredaju := TRIM( cFZaPredaju )
    cFZaPrijem  := TRIM( cFZaPrijem  )
    cUslovTDok  := TRIM( cUslovTDok  )
    cSpecUslov  := TRIM( cSpecUslov  )
    cSinSFormula:= TRIM( cSinSFormula)
    cKonvFirma  := TRIM( cKonvFirma  )
    cKonvBrDok  := TRIM( cKonvBrDok  )

    IF LASTKEY()!=K_ESC
      WPar("01",cLokPren    )
      WPar("02",cFZaPredaju )
      WPar("03",cFZaPrijem  )
      WPar("04",cUslovTDok  )
      WPar("05",cSpecUslov  )
      WPar("06",cSinSFormula)
      WPar("07",cKonvFirma  )
      WPar("08",cKonvBrDok  )
    ENDIF

  ENDIF
  USE
return
*}



