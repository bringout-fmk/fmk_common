#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */
 

function P_TRFP(cId,dx,dy)
*{
Private imekol,kol
ImeKol:={  ;
           { "Kalk",  {|| padc(IdVD,4)} ,    "IdVD"                  },;
           { padc("Shema",5),    {|| padc(shema,5)},      "shema"                    },;
           { padc("ID",10),    {|| id },      "id"                    },;
           { padc("Naziv",20), {|| naz},     "naz"                   },;
           { "Konto  ", {|| idkonto},        "Idkonto" , {|| .t.} , {|| ("KO" $ widkonto) .or. ("KP" $ widkonto) .or. ("KK" $ widkonto) .or. ("?" $ widkonto) .or. ("A" $ widkonto) .or. ("B" $ widkonto) .or. ("F" $ widkonto) .or. ("IDKONT" $ widkonto) .or.  P_konto(@wIdkonto) }   },;
           { "Tarifa", {|| idtarifa},        "IdTarifa"              },;
           { "D/P",   {|| padc(D_P,3)},      "D_P"                   },;
           { "Znak",    {|| padc(Znak,4)},        "ZNAK"                  },;
           { "Dokument", {|| padc(Dokument,8)},   "Dokument"              },;
           { "Partner", {|| padc(Partner,7)},     "Partner"               },;
           { "IDVN",    {|| padc(idvn,4)},        "idvn"                  };
        }
Kol:={1,2,3,4,5,6,7,8,9,10,11}

IF TRFP->(FIELDPOS("PORJ")<>0)
  AADD( ImeKol, { "Po RJ(D/S/N)",{|| porj},"porj",{|| .t.}, {|| wporj$"DSN"} } )
  AADD( Kol , LEN(Kol)+1 )
ENDIF

private cShema:=" "
private cKavd:="  "
private cFiltTRFP:=""

if Pitanje(,"Zelite li postaviti filter za odredjenu shemu","N")=="D"
  
  Box(,1,60)
     @ m_x+1,m_y+2 SAY "Odabir sheme:" GET cShema  pict "@!"
     @ m_x+1,col()+2 SAY "vrsta kalkulacije (prazno sve)" GET cKavd pict "@!"
     read
  Boxc()
  
  select TRFP
  cFiltTRFP := "SHEMA='"+ cShema + "'" +IIF(EMPTY(cKaVD),"",".and.IDVD=='"+cKaVD+"'")
  set filter to &cFiltTRFP
  go top
  
else
  select trfp
  set filter to
endif
return PostojiSifra(F_TRFP,1,15,76,"Parametri prenosa u FP",@cId,dx,dy,{|Ch| TRfpb(Ch)})
select trfp
set filter to

*}

function TrfpB(Ch)
*{
local cShema2:="1"
local cTekShema
local cIdvd:=""
local nRec:=0
local cDirSa:=PADR("C:\SIGMA\SIF0\", 20)
local cPobSt:="D"

if Ch==K_CTRL_F4

  cidvd:=idvd
  cTekShema:=shema
  Box(,1,60)
   @ m_x+1,m_y+1 SAY "Napraviti novu shemu kontiranja za dokumente "+cidvd GET cShema valid cShema<>shema
   read
   IF LASTKEY()==K_ESC; BoxC(); RETURN DE_CONT; ENDIF
  BoxC()
  go top
  do while !eof()
    if idvd==cidvd  .and. shema==cTekShema
      Scatter()
      skip
      nRec:=recno()
      skip -1
      _Shema:=cShema
      appblank2(.f.,.t.)
      Gather()
      go nRec
    else
      skip
    endif
  enddo
  return DE_REFRESH
elseif Ch==K_CTRL_F5

  cidvd:="  "
  cShema2:=" "
  if IsPdv()
  	cShema2:="E"
  endif
  
  if Pitanje(,"Preuzeti sheme kontiranja?","D")=="D"

    
    Box(,3,70)
     @ m_x+1,  m_y+2 SAY "Preuzeti podatke sa:" GET cDirSa VALID PostTRFP(cDirSa)
     @ m_x+2,  m_y+2 SAY "Odabir sheme:" GET cShema2  pict "@!"
     @ m_x+2,col()+2 SAY "vrsta kalkulacije (prazno sve)" GET cIdVd pict "@!"
     @ m_x+3,  m_y+2 SAY "Pobrisati postojecu shemu za izabrane kalkulacije? (D/N)" GET cPobSt VALID cPobSt $ "DN" PICT "@!"
     read
     IF LASTKEY()==K_ESC
     BoxC()
     RETURN DE_CONT
     ENDIF
    BoxC()

  else
    if Pitanje(,"Vratiti sheme koje su postojale prije zadnjeg preuzimanja shema?","N")=="D"
       UndoSheme()
       RETURN DE_REFRESH
    else
       RETURN DE_CONT
    endif
  endif

  UndoSheme(.t.)

  SELECT TRFP
  SET FILTER TO
  
  if cPobSt=="D"
    go top
    do while !eof()
      if (Idvd==cIdVD .or. EMPTY(cIdVd))  .and. shema==cShema2
        skip
	nRec:=recno()
	skip -1
        delete
        go nRec
      else
        skip
      endif
    enddo
  endif

  use (TRIM(cDirSa)+"TRFP.DBF") alias TRFPN new
  set order to tag "ID"

  go top
  nCnt:=0
  do while !eof()
    if (TRFPN->idvd==cIdVd .or. EMPTY(cIdVd)) .and. TRFPN->shema==cShema2
      Scatter()
      select TRFP
       nCnt++
       appblank2(.f.,.t.)
       Gather()
      select TRFPN
    endif
    skip 1
  enddo
  use
  select TRFP
  MsgBeep("Dodano u TRFP " + STR(nCnt) + " stavki##" +;
          "Ne zaboravite na odgovarajuca konta u sifrarnik#"+;
	  "konta-tipovi cijena dodati Shema='" + cShema2 + "'" )
  return DE_REFRESH
endif
return DE_CONT
*}

FUNCTION UndoSheme(lKopi)
*{
LOCAL cPom:="170771.POM", cStari:=SIFPATH+"TRFP.ST", cTekuci:=SIFPATH+"TRFP.DBF"
  LOCAL cStari2:=SIFPATH+"TRFPI1.ST", cTekuci2:=SIFPATH+"TRFP.CDX"
  IF lKopi==NIL; lKopi:=.f.; ENDIF
  IF lKopi
    SELECT TRFP
    PushWA()
    USE
    COPY FILE (cTekuci) TO (cStari)
    COPY FILE (cTekuci2) TO (cStari2)
    O_TRFP
    PopWA()
  ELSE
    IF FILE(cStari).and.FILE(cStari2)
      SELECT TRFP
      PushWA()
      USE
      FRENAME(cStari ,cPom); FRENAME(cTekuci, cStari);  FRENAME(cPom,cTekuci)
      FRENAME(cStari2,cPom); FRENAME(cTekuci2,cStari2); FRENAME(cPom,cTekuci2)
      O_TRFP
      PopWA()
    ENDIF
  ENDIF
RETURN
*}

FUNCTION PostTRFP(cDirSa)
*{
LOCAL lVrati:=.f.
 IF FILE(TRIM(cDirSa)+"TRFP.DBF")
   IF FILE(TRIM(cDirSa)+"TRFP.CDX")
     lVrati:=.t.
   ELSE
     Msg("Na zadanoj poziciji ne postoji fajl TRFP.CDX !")
   ENDIF
 ELSE
   Msg("Na zadanoj poziciji ne postoji fajl TRFP.DBF !")
 ENDIF
RETURN lVrati
*}


function v_setform()
*{
local cscsr
if file(SIFPATH+gSetForm+"TRXX.ZIP") .and. pitanje(,"Sifranik parametara kontiranja iz arhive br. "+gSetForm+" ?","N")=="D"
 private ckomlin:="unzip  -o -d "+SIFPATH+gSetForm+"TRXX.ZIP "+SIFPATH
 save screen to cscr
 cls
 ! &cKomLin
 restore screen from cscr
 select F_TRFP
 if !used(); O_TRFP; endif
 P_Trfp()
 select F_TRMP
 if !used(); O_TRMP; endif
 //P_Trmp()
 select trfp; use
 select trmp; use
 select params
elseif  pitanje(,"Tekuce parametre kontiranja staviti u arhivu br. "+gSetForm+" ?","N")=="D"
 private ckomlin:="zip "+SIFPATH+gSetForm+"TRXX.ZIP "+SIFPATH+"TR??.DBF "+SIFPATH+"TR??I?.NTX"
 save screen to cscr
 cls
 ! &cKomLin
 restore screen from cscr
endif
return .t.
*}
