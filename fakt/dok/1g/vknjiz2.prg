#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/vknjiz2.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.10 $
 * $Log: vknjiz2.prg,v $
 * Revision 1.10  2003/07/06 21:50:54  mirsad
 * nova varijanta: unos radnog naloga na 12-ki (FMK.INI/KUMPATH/FAKT/RadniNalozi=D)
 *
 * Revision 1.9  2003/04/14 20:27:28  ernad
 * bug: lock requiered pri unosu partnera
 *
 * Revision 1.8  2003/04/12 23:00:39  ernad
 * O_Edit (O_S_PRIREMA)
 *
 * Revision 1.7  2003/01/21 15:01:58  ernad
 * probelm excl fakt - kalk ?! direktorij kalk
 *
 * Revision 1.6  2002/07/05 10:34:34  mirsad
 * no message
 *
 * Revision 1.5  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.4  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.3  2002/07/01 09:02:20  mirsad
 * no message
 *
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/dok/1g/vknjiz2.prg
 *  \brief
 */


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_UnosPartneraObaveznoPoSifri
  * \brief Omogucava varijantu unosa partnera na dokumentu iskljucivo pomocu sifre
  * \param N - ne mora preko sifre, default vrijednost
  * \param D - mora se unijeti sifra partnera
  */
*string FmkIni_KumPath_FAKT_UnosPartneraObaveznoPoSifri;

 
/*! \fn PrZaglavlje()
 *  \brief 
 */

function PrZaglavlje()
*{
private aPom:={"00 - Pocetno stanje     ",;
               "01 - Ulaz / Radni nalog ",;
               "10 - Racun veleprodaje",;
               "11 - Racun maloprodaje",;
               "12 - Otpremnica",;
               "13 - Otpremnica u maloprodaju",;
               "15 - Izlaz iz MP putem VP",;
               "19 - "+Naziv19ke(),;
               "20 - Predracun",;
               "21 - Revers",;
               "22 - Realizovane otpremnice   ",;
               "25 - Knjizna obavijest        ",;
               "26 - Narudzbenica             ",;
               "27 - Predracun MP             "},  h[14]

AFILL(h,"")

private nRokPl:=0

Scatter()
IniVars()

private cOldKeyDok:=_idfirma+_idtipdok+_brdok
private fNovi:=.f.

 if (fTbNoviRed .or. val(_Rbr)=0) .and. (val(_Rbr)<=1 .and. val(_podbr)<1) // prva stavka
   nPom:=IF(VAL(gIMenu)<1,ASC(gIMenu)-55,VAL(gIMenu))
   _IdFirma:=gFirma;_IdTipDok:="10"
   _datdok:=date()
   _zaokr:=2
   _dindem:=left(VAlBazna(),3)
 else
   nPom:=ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})
 endif

 Box(,10,77)

 if (  val(_Rbr)<=1 .and. val(_podbr)<1)
   @ m_x+1,m_y+2 SAY gNFirma
   if reccount2()==0
     _idfirma:=gFirma
     fNovi:=.t.
   endif
   @ m_x+1,col()+2   SAY " RJ:" GET _idfirma  pict "@!";
                     valid {|| empty(_idfirma) .or. _idfirma==gfirma .or. P_RJ(@_idfirma) .and. V_Rj ()}

   read
   if lastkey()==K_ESC
      BoxC(); return .f.
   endif

   nPom:=Menu2(5,30,aPom,nPom)
   set escape off // ne moze se izaci sa escape
   altd()
   if npom<>0
    _IdTipdok:=LEFT(aPom[nPom],2)
   else
     BoxC()
     return .f.  // neuspjesno zavrseno
     //izadji
   endif
   @  m_x+3,m_y+2 SAY PADR(aPom[ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})],40)
   // if lastkey()==K_ESC; PopHT(); endif
   if _idtipdok=="13" .and. gVarNum=="2" .and. gVar13=="2"
     @ m_x+1, 57 SAY "Prodavn.konto" GET _idpartner VALID P_Konto(@_idpartner)
     read
     _idpartner:=LEFT(_idpartner,6)
     IF EMPTY(ALLTRIM(_txt3a+_txt3b+_txt3c)).or._idpartner!=idpartner
      _txt3a:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,1)
      _txt3b:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,2)
      _txt3c:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,3)
     ENDIF
   elseif _idtipdok=="13" .and. gVarNum=="1" .and. gVar13=="2"
     _idpartner := IF( EMPTY(_idpartner) , "P1" , RJIzKonta(_idpartner+" ") )
     @ m_x+1, 57 SAY "RJ - objekat:" GET _idpartner valid P_RJ(@_idpartner) pict "@!"
     read
     _idpartner:=PADR(KontoIzRJ(_idpartner),6)
     IF EMPTY(ALLTRIM(_txt3a+_txt3b+_txt3c)).or._idpartner!=idpartner
      _txt3a:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,1)
      _txt3b:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,2)
      _txt3c:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,3)
     ENDIF
   endif
   if (fTBNoviRed .or. val(_Rbr)=0) .and. (val(_Rbr)<=1 .and.  podbr<"0")

     _M1:=" "  // marker generacije nuliraj
     if gMreznoNum=="N"
        cBroj1:=OdrediNBroj(_idfirma,_idtipdok)   //_brdok
        if _idtipdok=="12"
           cBroj2:=OdrediNBroj(_idfirma,"22")
           if val(left(cBroj1,gNumDio))>=val(left(cBroj2,gNumDio))
              // maximum izmedju broja 22 i 12
              _Brdok:=cBroj1
           else
              _BrDok:=cBroj2
           endif
        else
           _BrDok:=cBroj1
        endif

        select PRIPR
     ELSE
        _BrDok := SPACE (LEN (_BrDok))
     endif
   endif

  do while .t.
   @  m_x+3,m_y+40  SAY "Datum:"   GET _datDok
   @  m_x+3,m_y+col()+2  SAY "Broj:"   GET _BrDok  WHEN gMreznoNum=="N" valid !empty(_BrDok)

   _txt3a:=padr(_txt3a,30)
   _txt3b:=padr(_txt3b,30)
   _txt3c:=padr(_txt3c,30)

   IF gNovine=="D" .or. IzFMKINI("FAKT","UnosPartneraObaveznoPoSifri","N",KUMPATH)=="D"
    @  m_x+5,m_y+2  SAY "Partner " GET _idpartner  picture "@!" valid { || P_Firma(@_idpartner,6,11) , _Txt3a:=padr(_idpartner+".",30) , IzSifre() }
   ELSE
    @  m_x+5,m_y+2  SAY "Partner " GET _Txt3a  picture "@!" valid IzSifre()
    @  m_x+6,m_y+2  SAY "        " GET _Txt3b  picture "@!"
    @  m_x+7,m_y+2  SAY "Mjesto  " GET _Txt3c  picture "@!"
   ENDIF

   if _idtipdok=="10"
     if gDodPar=="1"
      @  m_x+5,m_y+45 SAY "Otpremnica broj:" GET _brotp ;
        when  W_BrOtp(fTBNoviRed)
      @  m_x+6,m_y+45 SAY "          datum:" GET _Datotp
      @  m_x+7,m_y+45 SAY "Ugovor/narudzba:" GET _brNar
     endif

     if gDodPar=="1" .or. gDatVal=="D"
      altd()
      if fTBNoviRed; nRokPl:=gRokPl; endif
      @  m_x+8,m_y+45 SAY "Rok plac.(dana):" GET nRokPl PICT "99" ;
            WHEN FRokPl("0",fTbNoviRed)   VALID FRokPl("1",fTBNoviRed)
      @  m_x+9,m_y+45 SAY "Datum placanja :" GET _DatPl VALID FRokPl("2",fTBNoviRed)
     endif
     if lVrsteP
      @  m_x+10,m_y+38  SAY "Nacin placanja" get _idvrstep  picture "@!" valid P_VRSTEP(@_idvrstep,10,56)
     endif
   endif

   IF !lOpresaPovrati
     @  m_x+9,m_y+2  SAY Valdomaca()+"/"+VAlPomocna() GET _DINDEM pict "@!" valid _dindem $ valdomaca()+valpomocna()
   ENDIF

   //@  m_x+9,col()+2  SAY "Zaokruziti na" get _zaokr pict "9"; ?? " dec.mj"
   //_zaokr:=2

   read
   _txt3a:=trim(_txt3a)
   _txt3b:=trim(_txt3b)
   _txt3c:=trim(_txt3c)

   if gMreznoNum=="D"
     exit
   endif

   // select FAKT; set order to 1
   select DOKS; set order to 1
   hseek _idfirma+_idtipdok+_brDok
   if !found()
      select PRIPR
      exit
   else
      Beep(4)
      Msg("Vec postoji dokument "+_idtipdok+"-"+_brdok,6)
      select PRIPR
   endif
  enddo

  ChSveStavke(fNovi)
 else
   @  m_x+1,m_y+2   SAY gNFirma ; ?? "  RJ:", _IdFirma
   @  m_x+4,m_y+2   SAY PADR(aPom[ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})],35)
   @  m_x+4,m_y+40  SAY "Datum: ";?? _datDok
   @  m_x+4,m_y+col()+2  SAY "Broj: ";?? _BrDok
   _txt2:=""
 endif

 Boxc()
 set escape on

 if !(_idtipdok $ "12#13")
  UzorTxt()
 endif

 SetVars()

if reccount2()==0
  // u direkt editu svako polje se brine o dodavanju slogova !!
  append blank
endif
if val(_rbr)=0; _Rbr:=str(1,3); endif
Gather()  // snimi jarane
return .t.
*}



/*! \fn IniVars()
 *  \brief Ini varijable
 */
 
function IniVars()
*{
set cursor on

// varijable koje se inicijalizuju iz baze
_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""        // txt1  -  naziv robe,usluge
_BrOtp:=space(8)
_DatOtp:=ctod("")
_BrNar:=space(8)
_DatPl:=ctod("")
_VezOtpr := ""

aMemo:=ParsMemo(_txt)
if len(aMemo)>0
  _txt1:=aMemo[1]
endif
if len(aMemo)>=2
  _txt2:=aMemo[2]
endif
if len(aMemo)>=5
  _txt3a:=aMemo[3]; _txt3b:=aMemo[4]; _txt3c:=aMemo[5]
endif
if len(aMemo)>=9
 _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
endif
IF len (aMemo)>=10
  _VezOtpr := aMemo [10]
EndIF
*}



/*! \fn SetVars()
 *  \brief Setuj varijable
 */
 
function SetVars()
*{
if _podbr==" ." .or.  roba->tip="U" .or. (val(_Rbr)<=1 .and. val(_podbr)<1)
    _txt2:=OdsjPLK(_txt2)           // odsjeci na kraju prazne linije
    if ! "Faktura formirana na osnovu" $ _txt2
       _txt2 += CHR(13)+Chr(10)+_VezOtpr
    endif
    _txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
          Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
          Chr(16)+trim(_txt3c)+Chr(17) +;
          Chr(16)+_BrOtp+Chr(17) +;
          Chr(16)+dtoc(_DatOtp)+Chr(17) +;
          Chr(16)+_BrNar+Chr(17) +;
          Chr(16)+dtoc(_DatPl)+Chr(17) +;
          IIF (Empty (_VezOtpr), "", Chr(16)+_VezOtpr+Chr(17))
else
    _txt:=""
endif
return
*}



/*! \fn Tb_V_RBr()
 *  \brief
 */
 
function Tb_V_RBr()
*{
replace Rbr with str(nRbr,3)
return .t.
*}


/*! \fn Tb_W_IdRoba()
 *  \brief
 */
 
function Tb_W_IdRoba()
*{
_idroba:=padr(_idroba,15)
return W_Roba()
*}



/*! \fn Tb_V_IdRoba()
 *  \brief
 */
 
function tb_V_IdRoba()
*{
_idroba:=iif(len(trim(_idroba))<10,left(_idroba,10),_idroba)
V_Roba()
IniVars() // _txt1,2,3....
GetUsl(fTBNoviRed)
SetVars()
NijeDupla(fTbNoviRed)
V_Kolicina()
return tb_V_Cijena()
*}



/*! \fn Tb_V_Kolicina()
 *  \brief
 */
 
function Tb_V_Kolicina()
*{
NSRNPIdRoba()
// select roba; hseek pripr->idroba; select pripr
if gTBDir=="D" .and. roba->tip=="U"
  TBPomjerise:="<"
endif
IF lOpresaPovrati
  _kolicina := - ABS(_kolicina)
ENDIF
return V_Kolicina()
*}


/*! \fn Tb_W_Cijena()
 *  \brief
 */
 
function tb_W_Cijena()
*{
return KLevel<="1"
*}


/*! \fn Tb_V_Cijena()
 *  \brief
 */
 
function Tb_V_Cijena()
*{
if _DINDEM==left(ValSekund(),3)   // preracunaj u KM
      _Cijena:=_Cijena*UBaznuValutu(_datdok)
endif
return .t.
*}


/*! \fn Tb_W_TRabat()
 *  \brief
 */
 
function Tb_W_TRabat()
*{
return !(_idtipdok $ "12#13#11#15#27") .and. _podbr<>" ."
*}



/*! \fn Tb_V_Rabat()
 *  \brief
 */
 
function Tb_V_Rabat()
*{
return .t.
*}




/*! \fn Tb_V_TRabat()
 *  \brief
 */
 
function Tb_V_TRabat()
*{
V_Rabat()
TRabat:="%"
return .t.
*}



/*! \fn Tb_W_Porez()
 *  \brief
 */
 
function Tb_W_Porez()
*{
local nRet

NSRNPIdRoba()
// select roba; hseek pripr->idroba; select pripr
// mora se nonstop seekovati nanovo !!!

nRet:=_podbr<>" ." .and. !(roba->tip $ "KV")  .and. !_idtipdok$"11#15#27"

if nRet
  if roba->tip="U" .and. fTBNoviRed
     select tarifa
     hseek roba->idtarifa
     select pripr
      _Porez:=tarifa->PPP
  endif
endif
return nRet
*}



/*! \fn Tb_V_Porez()
 *  \brief
 */
 
function Tb_V_Porez()
*{
NSRNPIdRoba()
// select roba; hseek pripr->idroba
select tarifa
hseek roba->idtarifa
select pripr
return V_Porez()
*}



/*! \fn ValidRed()
 *  \brief
 */
 
function ValidRed()
*{
TBCanClose:=.t.
if eof()
  return .t.   // nisam na slogu !!
endif

if empty(idroba) .or. kolicina=0
  MsgBeep("Niste unijeli potrebne podatke !!")
  TBCanClose:=.f.
  return TBCanClose
endif

nRec:=recno()
go top
if val(rbr)<>1
  MsgBeep("Dokument mora imati stavku br 1 !?")
  TbCanclose:=.f.
endif
go nRec
return TBCanClose
*}



/*! \fn PrGoreRed()
 *  \brief
 */
 
function PrGoreRed()
*{
if !ValidRed()
   TB:Down()
   return
endif
*}



/*! \fn PrDoleRed()
 *  \brief
 */
 
function PrDoleRed()
*{
local nLen:=len(Picdem)

if !ValidRed()
  TB:Up()
  return .f.
endif

nrec:=recno()
go top
nDug2:=nRab2:=nPor2:=0
cDinDem:=dindem
nC:=17
Beep(1)
@ m_x+nC,m_y+31 SAY ""
?? padc("Uk",nLen),padc("Rabat",nLen), padc("Uk-Rabat",nLen),;
   padc("PP",nLen)

++nC
@ m_x+nC,m_y+31 SAY ""
for i:=1 to  4
  ?? replicate("-",len(Picdem))+" "
next

do while !eof()
  cRbr:=rbr
  nDug:=0; nRab:=0; nPor:=0
  do while rbr==cRbr
    nDug+=round( cijena*kolicina*PrerCij() , ZAOKRUZENJE)
    nRab+=round((cijena*kolicina*PrerCij())*Rabat/100 , ZAOKRUZENJE)
    nPor+=round((cijena*kolicina*PrerCij())*(1-Rabat/100)*Porez/100, ZAOKRUZENJE)
    skip
  enddo
  nDug2+=nDug; nRab2+=nRab; nPor2+=nPor
enddo

++nC
@ m_x+nC,m_y+31  SAY nDug2      pict  Picdem
@ m_x+nC,col()+1 SAY nRab2      pict  Picdem
@ m_x+nC,col()+1 SAY nDug2-nRab2 pict  Picdem
@ m_x+nC,col()+1 SAY nPor2 pict        Picdem

@ m_x+nC+2,m_y+38 SAY "***UKUPNO***"
@ m_x+nC+2,col()+1 SAY nDug2-nRab2+nPor2 pict  Picdem

//@ m_x+nC,col()+1 SAY "("+cDinDem+")"

go nRec
return .t.  // uspjesno otiso u novi red
*}



/*! \fn PrDodajRed()
 *  \brief
 */
 
function PrDodajRed()
*{

local nRrbr

Beep(2)

skip -1
Scatter()
Append blank  // dodaj novi
_IdRoba:=padr("",len(_IdRoba))
if alltrim(_podbr)=="." .and. empty(_idroba)
 nRbr:=RbrUnum(_Rbr)
 _PodBr:=" 1"
elseif _podbr>=" 1"
 nRbr:=RbrUnum(_Rbr)
 _podbr:= str(val(_podbr)+1,2)
else
 nRbr:=RbrUnum(_Rbr)+1
 _PodBr:="  "
endif
_Rbr:=str(nRbr,3)
Gather()

return
*}



/*! \fn TbRobaNaz()
 *  \brief
 */
 
function TbRobaNaz()
*{
NSRNPIdRoba()
// select roba; hseek pripr->idroba; select pripr
return left(Roba->naz,25)
*}


/*! \fn ObracunajPP(cSetPor,dDatDok)
 *  \brief Obracunaj porez na promet 
 *  \param cSetPor
 *  \param dDatDok
 */
 
function ObracunajPP(cSetPor,dDatDok)
*{

select (F_PRIPR)
if !used()
	O_PRIPR
endif
select (F_ROBA)
if !used()
	O_ROBA
endif
select (F_TARIFA)
if !used()
	O_TARIFA
endif

select pripr
go top
if dDatDok=NIL
  dDatDok:=pripr->DatDok
endif
if cSetPor=NIL
  cSetPor:="D"
endif

do while !eof()
 if cSetPor=="D"
  NSRNPIdRoba()
  // select roba; hseek pripr->idroba
  select tarifa; hseek roba->idtarifa
  if found()
    select pripr
    replace porez with tarifa->opp
  endif
 endif
 if datDok<>dDatdok
    replace DatDok with dDatDok
 endif
 select pripr
 skip
enddo

go top
RETURN
*}



/*! \fn UCKalk()
 *  \brief Uzmi cijenu iz Kalk-a
 */
 
function UCKalk()
*{
LOCAL nArr:=SELECT(), aUlazi:={}, GetList:={}, cIdPartner:=_idpartner
  LOCAL cSezona:="RADP", cPKalk:=""
  PUBLIC gDirKalk:=""
  O_PARAMS
  private cSection:="T",cHistory:=" "; aHistory:={}
  RPar("dk",@gDirKalk)
  if empty(gDirKalk)
    gDirKalk:=trim(strtran(goModul:oDataBase:cDirKum,"FAKT","KALK"))+"\"
    WPar("dk",gDirKalk)
  endif
  select 99; use
  Box("#ROBA:"+_IDROBA,4,50)
    @ m_x+2, m_y+2 SAY "Sifra dobavljaca             :" GET cIdPartner
    @ m_x+3, m_y+2 SAY "Sezona ('RADP'-tekuca godina):" GET cSezona
    READ
  BoxC()
  SETLASTKEY(0)
  select (F_KALK)
  IF cSezona=="RADP"
    cPKalk:=gDirKalk+"KALK"
  ELSE
    cPKalk:=gDirKalk+cSezona+"\KALK"
  ENDIF
  IF FILE(cPKalk+".DBF")
    USE (cPKalk)
  ELSE
    MsgBeep("Baza '"+cPKalk+".DBF' ne postoji !")
    SELECT (nArr); RETURN
  ENDIF
  set order to tag "7"   // "7","idroba"
  seek _idroba
  IF !FOUND()
    USE; SELECT (nArr); RETURN
  ENDIF
  DO WHILE !EOF() .and. _idroba==idroba
    IF idpartner==cIdPartner .and. idvd=="10" .and. kolicina>0
      AADD( aUlazi , idfirma+"-"+idvd+"-"+brdok+"³"+;
                     DTOC(datdok)+"³"+;
                     STR(kolicina,11,3)+"³"+;
                     STR(fcj,11,3)                     )
    ENDIF
    SKIP 1
  ENDDO
  USE
  SELECT (nArr)
  IF !( LEN(aUlazi)>0 ); RETURN; ENDIF
  h:=ARRAY(LEN(aUlazi)); AFILL(h,"")
  Box("#POSTOJECI ULAZI (KALK): ÍÍÍÍÍÍÍ <Enter>-izbor ",MIN(LEN(aUlazi),16)+3,51)
   @ m_x+1, m_y+2 SAY "    DOKUMENT   ³ DATUM  ³ KOLICINA  ³  CIJENA    "
   @ m_x+2, m_y+2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ"
   nPom := 1
   @ row()-1, col()-6 SAY ""
   nPom := Menu("KCME",aUlazi,nPom,.f.,,,{m_x+2,m_y+1})
   IF nPom>0
     _cijena  := VAL(ALLTRIM(RIGHT(aUlazi[nPom],11)))
     Menu("KCME",aUlazi,0,.f.)
   ENDIF
  BoxC()
RETURN
*}


/*! \fn ChSveStavke(fNovi)
 *  \brief
 *  \param fNovi
 */
 
function ChSveStavke(fNovi)
*{
LOCAL nRec:=recno()
  set order to 0
  go top
  do while !eof()
    IF IDFIRMA+IDTIPDOK+BRDOK == _IDFIRMA+_IDTIPDOK+_BRDOK .or.;
       !fNovi .and. cOldKeyDok == IDFIRMA+IDTIPDOK+BRDOK
      RLOCK()
      _field->idfirma   := _IdFirma
      _field->datdok    := _DatDok
      _field->IdTipDok  := _IdTipDok
      _field->brdok     := _BrDok
      _field->dindem    := _dindem
      _field->zaokr     := _zaokr
      _field->idpartner := _idpartner
      IF lVrsteP
       _field->idvrstep:=_idvrstep
      ENDIF
      IF glDistrib
       _field->iddist   := _iddist
       _field->idrelac  := _idrelac
       _field->idvozila := _idvozila
       _field->idpm     := _idpm
       _field->marsruta := _marsruta
       _field->ambp     := _ambp
       _field->ambk     := _ambk
      ENDIF
      if glRadNal
      	_field->idRNal:=_idRNal
      endif
      IF !(_idtipdok="0") .and. lPoNarudzbi
       _field->idnar    := _idpartner
      ENDIF
      DBUNLOCK()
    ENDIF
    skip
  enddo
  set order to 1
  go nRec
RETURN
*}



/*! \fn TarifaR(cRegion, cIdRoba, aPorezi)
 *  \brief Tarifa na osnovu region + roba
 *  \param cRegion
 *  \param cIdRoba
 *  \param aPorezi
 *  \note preradjena funkcija jer Fakt nema cIdKonto
 */
 
function TarifaR(cRegion, cIdRoba, aPorezi)
*{
local cTarifa
private cPolje

PushWa()

if empty(cRegion)
 cPolje:="IdTarifa"
else
   if cRegion=="1" .or. cRegion==" "
      cPolje:="IdTarifa"
   elseif cRegion=="2"
      cPolje:="IdTarifa2"
   elseif cRegion=="3"
      cPolje:="IdTarifa3"
   else
      cPolje:="IdTarifa"
   endif
endif

SELECT (F_ROBA)
if !used()
 O_ROBA
endif
seek cIdRoba
cTarifa:=&cPolje

SELECT (F_TARIFA)
if !used()
  O_TARIFA
endif
seek cTarifa

SetAPorezi(@aPorezi)

PopWa()
return tarifa->id
*}


/*! \fn SetAPorezi(aPorezi)
 *  \brief 
 *  \param aPorezi
 */
 
function SetAPorezi(aPorezi)
*{
if (aPorezi==nil)
	aPorezi:={}
endif
if (len(aPorezi)==0)
	//inicijaliziraj poreze
	aPorezi:={0,0,0,0,0,0,0}
endif
aPorezi[POR_PPP]:=tarifa->opp
aPorezi[POR_PP ]:=tarifa->zpp
aPorezi[POR_PPU]:=tarifa->ppp
aPorezi[POR_PRUC]  :=tarifa->vpp
if tarifa->(FIELDPOS("mpp"))<>0
	aPorezi[POR_PRUCMP]:=tarifa->mpp
	aPorezi[POR_DLRUC]:=tarifa->dlruc
else
	aPorezi[POR_PRUCMP]:=0
	aPorezi[POR_DLRUC]:=0
endif
return nil
*}


/*! \fn MpcSaPor(nMpcBP,aPorezi,aPoreziIzn)
 *  \brief Maloprodajna cijena sa porezom
 *  \param nMpcBP
 *  \param aPorezi
 *  \param aPoreziIzn
 */
 
function MpcSaPor(nMpcBP,aPorezi,aPoreziIzn)
*{
local nPom

if gUVarPP=="R"
 nPom:= nMpcBp * ( 1 + (aPorezi[POR_PPP]/100 +aPorezi[POR_PP]/100 ) ) 
elseif gUVarPP=="D"
 nPom:=nMpcBp * ( (1+ aPorezi[POR_PP]/100 + aPorezi[POR_PPU]/100 ) * ;
       (1+ aPorezi[POR_PPP]/100) )
else
 // obicno robno poslovanje
 nPom:= nMpcBp *;
        (  aPorezi[POR_PP]/100  +;
          (aPorezi[POR_PPP]/100+1)*(1+aPorezi[POR_PPU]/100)  )
endif

return nPom
*}


/*! \fn MpcBezPor(nMpcSaPP,aPorezi)
 *  \brief Maloprodajna cijena bez poreza
 *  \param nMpcSaPP
 *  \param aPorezi
 */
 
function MpcBezPor(nMpcSaPP,aPorezi)
*{
local nPom

if gUVarPP=="R" 
   nPom:= nMpcSaPP / ( 1 + (aPorezi[POR_PPP]/100 + aPorezi[POR_PP]/100 ) )

elseif gUVarPP=="D"
  nPom:=nMpcSaPP / ( ( 1+ aPorezi[POR_PP]/100 + aPorezi[POR_PPU]/100 ) * ;
       (1+ aPorezi[POR_PPP]/100) )

else
   nPom:= nMpcSaPP / ;
        (  aPorezi[POR_PP]/100  +;
          (aPorezi[POR_PPP]/100+1)*(1+aPorezi[POR_PPU]/100)  )
endif

return nPom
*}


/*! \fn Izn_P_PPP(nMpcBP,aPorezi,aPoreziIzn)
 *  \brief
 *  \param nMpcBP
 *  \param aPorezi
 *  \param aPoreziIzn
 */
 
function Izn_P_PPP(nMpcBP,aPorezi,aPoreziIzn)
*{
local nPom
nPom:= nMpcBp*(aPorezi[POR_PPP]/100) 

return nPom
*}



/*! \fn Izn_P_PPU(nMpcBP,aPorezi,aPoreziIzn)
 *  \brief
 *  \param nMpcBP
 *  \param aPorezi
 *  \param aPoreziIzn
 */
 
function Izn_P_PPU(nMpcBP, aPorezi, aPoreziIzn)
*{
local nPom
nPom:= nMpcBp*(aPorezi[POR_PPP]/100+1)*(aPorezi[POR_PPU]/100) 
return nPom
*}



/*! \fn Izn_P_PP(nMpcBP, aPorezi, aPoreziIzn)
 *  \brief
 *  \param nMpcBP
 *  \param aPorezi
 *  \param aPoreziIzn
 */
function Izn_P_PP(nMpcBP, aPorezi, aPoreziIzn)
*{
local nPom

if gUVarPP=="R"
 nPom:= nMpcBp * aPorezi[POR_PP]/100  
elseif gUVarPP=="D"
 nPom:= nMpcBp * (1+ aPorezi[POR_PPP]/100 ) * aPorezi[POR_PP]/100
else
 // obicno robno poslovanje
 nPom:= nMpcBp * aPorezi[POR_PP]/100  
endif

return nPom
*}




