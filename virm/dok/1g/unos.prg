#include "\cl\sigma\fmk\virm\virm.ch"

function Unos()
*{
O_SIFK
O_SIFV
O_JPRIH
O_BANKE
O_STAMP
O_VRPRIM
O_PARTN
O_KUMUL
O_PRIPR

ImeKol:={}
Kol:={}
AADD(ImeKol, { "R.br.", {|| _st_+str(rbr,3)} } )
AADD(ImeKol, { "Posaljioc", {|| ko_zr},   "ko_zr" } )
AADD(ImeKol, { "Primalac"   , {|| kome_zr}, "kome_zr" } )
AADD(ImeKol, { "Primalac/Primatelj", {|| left(kome_txt,30) } } )
AADD(ImeKol, { "Iznos"   , {|| Iznos}, "Iznos" } )
AADD(ImeKol, { "Dat.Upl" , {|| dat_upl}, "dat_upl" } )
AADD(ImeKol, { "POd"   , {|| POd}, "POd" } )
AADD(ImeKol, { "PDo"   , {|| PDo}, "PDo" } )
AADD(ImeKol, { "PNABR" , {|| PNABR}, "PNABR" } )
AADD(ImeKol, { "Hitno" , {|| Hitno}, "Hitno" } )
AADD(ImeKol, { "IdJPrih" , {|| IdJprih}, "IdJPrih" } )
AADD(ImeKol, { "VUPl" , {|| VUPl}, "VUPl" } )
AADD(ImeKol, { "IdOps" , {|| IdOps}, "IdOps" } )

for i:=1 to len(ImeKol); AADD(Kol,i); next
@ 12,0 SAY ""
ObjDBedit("PripVir",18,77,{|| EdPripr()},"","PRIPREMA",;
          .f.,{"<c-N>   Nova uplatnica", "<c-T>   Brisi ",;
               "<Enter> Ispravi uplatnicu", "<c-F9>  Brisi sve",;
               "<a-A>   Azuriranje", "<c-P>   Stampanje",;
               "<a-P>   Rekapitulacija","<a-K> Pretvori u DEM", "<c-O>   Ostalo"},2,,,)
CLOSERET


function EdPRIPR()
 local nRec:=RECNO()

 if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
   return DE_CONT
 endif

 select pripr
 do case

  case Ch==K_ALT_P      // rekapitulacija uplata
     Rekapit()
     go (nRec)
     return DE_CONT

  case Ch==K_ALT_M
     cDN:=" "
     Box(,2,70)
       @ m_x+1,m_y+2 SAY "Zelite sve stavke oznaciti odstampane/neodstampane ( /*) ?" ;
             get  cDN valid cdn $ " *" pict "@!"
       read
     BoxC()
     select pripr
     go top
     do while !eof()
       replace _ST_ with cDN
       skip
     enddo
     go top
     return DE_REFRESH



  case Ch==ASC(" ")
     // ako je _ST_ = " " onda stavku treba odstampati
     //        _ST_ = "*" onda stavku ne treba stampati

     if field->_ST_ =  "*"
         replace _st_ with  " "
     else
         replace _st_ with "*"
     endif
     return DE_REFRESH

  case Ch==K_CTRL_T

     if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
      delete
      return DE_REFRESH
     endif
     return DE_CONT

  case Ch==K_CTRL_P
     StVirm()
     return DE_REFRESH

  case Ch==K_CTRL_O
     O_PARAMS
     private cSection:="1",cHistory:=" "; aHistory:={}

     Rpar("da",@gDatum)
     Rpar("fi",@gFirma)
     Rpar("mj",@gMjesto)
     Rpar("oj",@gOrgJed) // iskoristicu ovu varijablu za broj poreskog
                         // obveznika
     gOrgJed:=padr(gOrgJed,13)
     UsTipke()
     set cursor on
      aNiz:={ {"Firma - nalogodavac", "gFirma", "P_Firme(@gFirma)", , },;
              {"Inicijalni datum uplate", "gDatum", , , },;
              {"Mjesto uplate", "gMjesto", , , }, ;
              {"Broj poreskog obveznika", "gOrgJed", , , } ;
            }
      VarEdit(aNiz,12,5,19,74,"OSTALI PARAMETRI","B1")
     BosTipke()
     if lastkey()<>K_ESC
       Wpar("da",gDatum)
       Wpar("fi",gFirma)
       Wpar("mj",gMjesto)
       Wpar("oj",gOrgJed)
       select params; use
     endif
     use
     SELECT PRIPR
     lVrati:=DE_REFRESH
   case Ch==K_CTRL_A
        PushWA()
        select PRIPR
        //go top
        Box("c_A",20,75,.f.,"Ispravka stavki")
        nDug:=0; nPot:=0
        do while !eof()
           skip; nTR2:=RECNO(); skip-1
           Scatter()
           @ m_x+1,m_y+1 CLEAR to m_x+19,m_y+74
           if EditPRIPR(.f.)==0
             exit
           else
             //BrisiPBaze()
           endif
           select PRIPR
           Gather()
           go nTR2
         enddo
         PopWA()
         BoxC()
         return DE_REFRESH

     case Ch==K_CTRL_N  // nove stavke
        nDug:=nPot:=nPrvi:=0
        go bottom
        Box("c-n",20,77,.f.,"Unos novih stavki")
        do while .t.
           Scatter()
           _Rbr:=_Rbr+1
           @ m_x+1,m_y+1 CLEAR to m_x+19,m_y+76
           if EditPRIPR(.t.)==0
             exit
           endif
           inkey(10)
           select PRIPR
           APPEND BLANK
           Gather()
        enddo

        BoxC()
        return DE_REFRESH

   case Ch==K_ENTER
       Box("ent",20,75,.f.)
       Scatter()
       if EditPRIPR(.f.)==0
        BoxC()
        return DE_CONT
       else
        Gather()
        BoxC()
        return DE_REFRESH
       endif

   case Ch=K_CTRL_F9
        if Pitanje(,"Zelite li izbrisati pripremu !!????","N")=="D"
             zap
             //BrisiPBaze()
        endif
        return DE_REFRESH

   case Ch==K_ALT_A
     IF RECCOUNT2()>0
       Azuriraj()
       return DE_REFRESH
     ELSE
       Msg("Nema nista za azuriranje!")
       return DE_CONT
     ENDIF
   case Ch==K_CTRL_P
     // stampaj .........
     return DE_REFRESH

 endcase

return DE_CONT
*}



function EditPripr
*{
parameters  fNovi

//if fnovi; ; endif

set cursor on
@ m_x+1,m_y+2 SAY "Svrha placanja :" GET _svrha_pl pict "@!" valid P_Vrprim(@_svrha_pl)

read
ESC_RETURN 0

if fnovi
    IF EMPTY(gDatum)
      IF gIDU=="D"
        _dat_upl:=date()  // gdatum
      ELSE
        _dat_upl:=gdatum
      ENDIF
    ELSE
      _dat_upl:=gdatum
    ENDIF
   _mjesto :=gmjesto
   _svrha_doz:=PADR(vrprim->pom_txt,LEN(_svrha_doz))
endif

@ m_x+2,m_y+col()+2 SAY "R.br:" GET _Rbr pict "999"


_IdBanka:=left(_ko_zr,3)
@ m_x+3,m_y+2 SAY "Posiljaoc (sifra banke):       " GET _IdBanka valid  OdBanku(gFirma,@_IdBanka)
read
ESC_RETURN 0
_ko_zr:=_IdBanka


_IdBanka2:=left(_kome_zr,3)
select partn; seek gFirma; select pripr
_ko_txt := trim(partn->naz) + ", " + trim(partn->mjesto)+", "+trim(partn->adresa) + ", " + trim(partn->telefon)


if vrprim->IdPartner == padr("JP", len(vrprim->idpartner))
   _bpo := gOrgJed // ova varijabla je iskoristena za broj poreskog obv.
else
  if vrprim->dobav=="D"
   // ako su javni prihodi ovo se zna !
   @ m_x+5,m_y+2 SAY "Primaoc (partner/banka):" GET _u_korist valid P_Firme(@_u_korist)  pict "@!"
   @ m_x+5,col()+2 GET _IdBanka2 valid {|| OdBanku(_u_korist,@_IdBanka2), SetPrimaoc()}
  else
     _kome_txt:=vrprim->naz
     _kome_zr:=vrprim->racun
     @ m_x+5,m_y+2 SAY "Primaoc (partner/banka):" + trim(_kome_txt)
  endif

endif


// na osnovu _IdBanka , _IdBanka2 odrediti racune !!

@ m_x+8,m_y+2 SAY "Svrha doznake:" GET _svrha_doz  pict "@S30"

@ m_x+10,m_y+2 SAY "Mjesto" GET _mjesto  pict "@!"
@ m_x+10,col()+2 SAY "Datum uplate :" GET _dat_upl


@ m_x+8,m_y+50 SAY "Iznos" GET _iznos pict "99999999.99"
@ m_x+8,m_y+col()+1 SAY "Hitno" GET _hitno pict "@!" valid _hitno $ " X"

read

ESC_RETURN 0

 _IznosSTR :=""
 IF gNumT=="D"
   _IznosSTR:="="+IF( _iznos==0.and.gINulu=="N" , SPACE(6) , ALLTRIM(FormNum1(_iznos)) )
 ELSE
   _IznosSTR:="="+IF( _iznos==0.and.gINulu=="N" , SPACE(6) , ALLTRIM(STRTRAN(STR(_iznos),".",",")) )
 ENDIF


if vrprim->Idpartner="JP" // javni prihod
  _VUPl:="0"

  // setovanje varijabli: _kome_zr , _kome_txt, _budzorg
  // pretpostavke: kursor VRPRIM-> podesen na tekuce primanje
  altd()
  SetJPVar()
  _kome_txt:=vrprim->naz

  @ m_x+5,m_y+2 SAY "Primaoc (partner/banka):" + trim(_kome_txt)
  if fnovi

    if len(_IdJPrih)<6
       MsgBeep("Sifra prihoda mora biti 6 cifara ?")
       _IdJPrih := padr(_IdJPrih , 6)
    endif
  endif
  @ m_x+13 ,  m_y+20 SAY replicate("-",56)
  @ m_x+14 , m_y+20 SAY "Broj por.obveznika" GET _bpo
  @ m_x+14 , col()+2 SAY "V.uplate " GET _VUpl
  @ m_x+15 , m_y+20 SAY "Vrsta prihoda     " GET _IdJPrih
  @ m_x+17 , m_y+20 SAY "      Opcina      " GET _IdOps
  @ m_x+15 , m_y+60 SAY "Od:" GET _POd
  @ m_x+16 , m_y+60 SAY "Do:" GET _PDo
  @ m_x+17 , m_y+55 SAY "Budz.org" GET _BudzOrg
  @ m_x+18 , m_y+20 SAY "Poziv na broj:    " GET _PNaBr
  read
  ESC_RETURN 0
else
  @ m_x+13 ,  m_y+20 SAY replicate("",56)

  _BPO := space(len(_BPO))
  _IdOps := space(len(_IdOps)) ;_IdJPrih:=space(len(_IdJPrih))
  _PNabr:= space(len(_PNaBr  ))
  _IdOps:= space(len(_IdOps ))
  _POd := ctod("") ; _PDo := ctod("")
  _VUPL=""
endif

return 1
*}



function SetPrimaoc()
*{
_kome_zr:=_IdBanka2
select partn; seek _u_korist
 //--- Uslov za ispis adrese u polju primaoca (MUP ZE-DO)
 if IzFmkIni("Primaoc","UnosAdrese","N",KUMPATH)=="D"
    _kome_txt:=trim(naz) + ", " + trim(mjesto) + ", " + adresa
 else
    _kome_txt:=trim(naz) + ", " + mjesto
 endif
select pripr

return .t.
*}


function UplDob()
*{
 LOCAL lVrati:=.f.
 SELECT VRPRIM
 GO TOP
 HSEEK _svrha_pl
 IF dobav=="D"; lVrati:=.t.; ENDIF
 SELECT PRIPR
RETURN lVrati
*}



function IniProm()        // autom.popunjavanje nekih podataka
*{
 SELECT VRPRIM
 IF dobav=="D"
   IF EMPTY(_nacpl) .and. EMPTY(_iznos) .and. EMPTY(_svrha_doz)
     _svrha_doz:=PADR(pom_txt,LEN(_svrha_doz))
     _nacpl:=nacin_pl
   ENDIF
   SELECT PARTN
   HSEEK _u_korist

   _kome_txt:= trim(naz) + mjesto
   //_kome_zr := ODBanku(_u_korist,_kome_zr)

 ELSE
   _u_korist:=SPACE(LEN(_u_korist))
   IF EMPTY(_nacpl).and.EMPTY(_iznos).and.EMPTY(_svrha_doz)

     _svrha_doz:=PADR(pom_txt,LEN(_svrha_doz))
     _kome_txt:=naz
     //_nacpl:=nacin_pl
     //_kome_sj:=SPACE(LEN(_kome_sj))

   ENDIF
 ENDIF
 SELECT PRIPR
RETURN .t.
*}


function ValPl()
*{
 LOCAL lVrati:=.f.

 IF _nacpl$"12"
   lVrati:=.t.
   IF EMPTY(_u_korist)
     _kome_zr:=VRPRIM->racun
   ELSE
     _kome_zr:=IF(_nacpl=="1",PARTN->ziror,PARTN->dziror)
   ENDIF
 ENDIF

RETURN lVrati
*}



function Azuriraj()
*{
if Pitanje("p1","Zelite li izvrsiti azuriranje podataka (D/N) ?","N")=="N"
	return
endif
select F_KUMUL
append from PRIPR
select (F_VIPRIPR)
zap
return
*}


function StVirm()
*{
bErr:=ERRORBLOCK({|o| MyErrH(o)})
BEGIN SEQUENCE
 O_IZLAZ; ZAP
RECOVER
 MsgBeep("Vec je aktiviran delphirb ?")
 return
END SEQUENCE
bErr:=ERRORBLOCK(bErr)


nKoliko:=999 // koliko virmana od startne pozicije

cMarkeri:="N"
Box(,2,70)
 @ m_x+1,m_y+2 SAY "Broj virmana od sljedece pozicije:" GET nKoliko pict "999"
 @ m_x+2,m_y+2 SAY "Uzeti u obzir markere            :" GET cMarkeri pict "@!" valid cmarkeri $ "DN"
 read
BoxC()
i:=1
select pripr; set order to tag "1"
if cMarkeri="D"
 go top
endif

do while !eof()
    Scatter()
    if cMarkeri="D" .and. _st_="*"
       skip; loop
    else
       replace _st_ with "*"
    endif
    select izlaz ; append blank
    cWinKonv:=IzFmkIni("DelphiRb","Konverzija","3")
    KonvZnWin(@_ko_txt, cWinKonv)
    KonvZnWin(@_kome_txt, cWinKonv)
    KonvZnWin(@_svrha_doz, cWinKonv)
    KonvZnWin(@_mjesto, cWinKonv)


    // Dorada za DelphiRB6
    //
    // !!! NAPOMENA !!!: ova varijanta samo radi sa DelphiRB6
    //
    // Polja u IZLAZ.DBF koja trebaju biti FullJustified

      _ko_zr    = Razrijedi(_ko_zr)       // z.racun posiljaoca
      _kome_zr  = Razrijedi(_kome_zr)     // z.racun primaoca
      _bpo      = Razrijedi(_bpo)         // broj poreznog obveznika
      _idjprih  = Razrijedi(_idjprih)     // javni prihod
      _idops    = Razrijedi(_idops)       // opstina
      _pnabr    = Razrijedi(_pnabr)       // poziv na broj
      _budzorg  = Razrijedi(_budzorg)     // budzetska organizacija
      _pod      = Razrijedi(DTOC(_pod))         // porezni period od
      _pdo      = Razrijedi(DTOC(_pdo))         // porezni period do
      _dat_upl  = Razrijedi(DTOC(_dat_upl))     // datum uplate

    Gather()
    select pripr
    skip
    if i>=nkoliko
       exit
    endif
    i++
enddo
if eof(); skip -1; endif
select pripr
nTrec:=recno()
use


select izlaz; use

// ovdje treba kod za filovanje datoteke IZLAZ.DBF
if lastkey()!=K_ESC .and.  pitanje(,"Aktivirati Win Report ?","D")=="D"

 #ifdef PROBA
  private cKomLin:="DelphiRB "+IzFmkIni("NalPlac","NazRTM","nalplac", SIFPATH)+" "+PRIVPATH+"  IZLAZ 1"
 #else
  private cKomLin:="DelphiRB "+IzFmkIni("NalPlac","NazRTM","nalplac", SIFPATH)+" "+PRIVPATH+"  IZLAZ 1"
 #endif
 if gTrakas=="D"
   // ispis na perforiranom papiru
   cKomLin += " paghm:"+alltrim(str(i))
 endif
 cPom := alltrim(IzFmkIni("NalPlac","LijevaMargina","-",KUMPATH))
 if cPom!="-"
  cKomLin += " lmarg:"+cPom
 endif
 cPom := alltrim(IzFmkIni("NalPlac","GornjaMargina","-",KUMPATH))
 if cPom!="-"
  cKomLin += " tmarg:"+cPom
 endif

 run &cKomLin

endif

O_PRIPR
go nTRec

return
*}


FUNCTION KonvKod(cLinija)
*{
 LOCAL cVrati:="",nPoz
 DO WHILE .t.
  IF (nPoz:=AT("\",cLinija))!=0
    cVrati+=CHR(VAL(LEFT(cLinija,nPoz-1)))
    cLinija:=SUBSTR(cLinija,nPoz+1)
  ELSE
    EXIT
  ENDIF
 ENDDO
 IF !EMPTY(cLinija); cVrati+=CHR(VAL(cLinija)); ENDIF
RETURN cVrati
*}


FUNCTION FORMDAT1(dUlazni)
*{
 LOCAL cVrati
 SET CENTURY ON
  cVrati:=DTOC(dUlazni)+"."
 SET CENTURY OFF
RETURN cVrati
*}



function FormNum1(nIznos)
*{
 LOCAL cVrati
 cVrati:=TRANSFORM(nIznos,gpici)
 cVrati:=STRTRAN(cVrati,".",":")
 cVrati:=STRTRAN(cVrati,",",".")
 cVrati:=STRTRAN(cVrati,":",",")
RETURN cVrati
*}



function KodPomaka(nMilimetara)
*{
local nPom:=ROUND(nMilimetara*gnInca/25.4,0)
RETURN nPom
*}



function Pomakni(cKodIspred,n216)
*{
// pomakni u  n216 jedinica mjere
local nP0,nPom

do while .t.
  if n216>gnInca
     nP0:=n216%gnInca
     if np0=0
       nP0:=gnInca
     endif
     ?? ckodispred+Chr(nP0)
     n216:=n216-nP0
  else
     if n216<=0
       // ne radi nista
     else
      ?? ckodispred+chr(n216)
     endif
     exit
  endif

enddo
return
*}


function PodesiGlavu(nNaPoz,nSaPoz)
*{
local i
    IF nNaPoz>nSaPoz
      ?? SPACE(nNaPoz-nSaPoz)
    ELSEIF nNaPoz<nSaPoz
      for i:=1 to nSapoz-nNapoz
        ?? Konvkod(gNazad)
      next
    ENDIF
    setprc(prow(),nNaPoz)
RETURN
*}



*********************************
function ToDEMZR(ckmzr)
*
* pretvori ckmzr   u dem ZR
* zadnji dio mora da ima 7 cifri
* takodje mora da pocinje sa 2
*********************************
*{
local nPom, cPom
nPom:=RAT("-",ckmzr)
cPom:=left(cKmZR,nPom)
cPom2:=trim(substr(cKMZR,npom+1))
cpom2:=padl(cPom2,7,"0")
cPom2:=substr(cPom2,2)
return cpom+"2"+cpom2
*}



/*
Odabir zeljene banke ...........
*/
function OdBanku(cIdPartn , cDefault , fsilent)
*{
// Odaberi banku
local n1,n2
local Izbor , nTIzbor
private aBanke
private GetList:={}

if fsilent=NIL
 fsilent:=.t.
endif
n1:=m_x ; n2:=m_y

if cDefault=NIL
 cDefault:="??FFFX"
endif
aBanke:=ASifv("PARTN","BANK",cIdPartn)
PushWa()
select banke


nTIzbor:=1
for i:=1 to len(aBanke)
  if left(aBanke[i], len(cDefault) ) = cDefault
      nTIzbor:=i
      if fSilent
        cDefault:=left(aBanke[nTIzbor],16)
        PopWA()
        return .t.
      endif
  endif
  seek(left(aBanke[i],3))
  aBanke[i]:=padr(trim(aBanke[i])+":"+naz,50)
next
PopWa()
Izbor:=nTIzbor
if len(aBanke)>1
 if !fSilent
    MsgBeep("Partner "+ cIdPartn +" ima racune kod vise banaka, Odaberite banku ")
 endif
 private h[LEN(aBanke)]
 AFILL(h,"")
 do while .t.
  Izbor:=menu("ab-1",aBanke,Izbor,.f.,"1")
  if Izbor=0
    exit
  else
    nTIzbor:=Izbor
    Izbor:=0
  endif
 enddo
 Izbor:=nTIzbor
 m_x := n1 ; m_y := n2

elseif len(aBanke)==1
 cDefault:=left(aBanke[Izbor],16)
 return .t.
else
 cDefault:=""
 select partn; hseek cidpartn; cDefault:=partn->ziror
 if !empty(cDefault)
   return .t.
 else
   MsgBeep("Nema unesena nitijedna banka za partnera "+cIdPartn)
   cDefault:=""
   return .t.
 endif
endif

cDefault:=left(aBanke[Izbor],16)
return .t.
*}



/*!
 @function ASifv
 @abstract Formira matricu vrijednosti ...
 @discussion - poziv ASifv("ROBA","BARK","2MON001")
               => {"32323232323233","4434343434343"}
 @param cDBF ime DBF-a
 @param cOznaka oznaka BARK , GR1 itd
 @param cIDSif   2MON001 - interna sifra
*/
function ASifv(cDBF,cOznaka,cIdSif)
*{
local aSifV:={}

PushWa()
cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)

xVal:=NIL

select sifv
PushWa() // spasi stanje sifv
set order to tag "ID"
//"ID","id+oznaka+IdSif+Naz",SIFPATH+"SIFV"
hseek cDbf + coznaka + cIdSif
do while !eof() .and. ID+Oznaka+IdSif=cDbf+coznaka+cIdSif
  AADD(aSifV,naz)
  skip
enddo

PopWa()   // sifv

PopWa()
return ASifV
*}




**************************************
* po izlasku iz ove funkcije kursor
* jprih.dbf-a treba biti pozicioniran
* na trazeni javni prihod
**************************************
function JPrih(cIdJPrih, cIdOps, cIdKan, cIdEnt)
*{
local fOk
if cIdOps==NIL
  cIdOps:=""
endif
if cIdKan==NIL
  cIdkan:=""
endif
if cIdEnt==NIL
  cIdEnt:=""
endif
PushWA()
//      1- racun  2-naziv     3-budzorg
aRez:={""         , ""         , ""}
select jprih
cPom:=cIdJPrih
for i:=len(cIdJPrih) to 1 step -1
 cPom := left(cIdJPrih,i)
 seek cPom
 if found() .and. len(cPom)==len(cIdJPrih)
    // analiticki prihod
    aRez[2]:= naz
 endif
 if found()
   do while !eof() .and. Id == padr(cPom,len(cIdJPrih))
      fOk:=.t.
      if empty(Racun)
         // nema racuna trazi dalje
         fOk:=.f.
         skip; loop
      endif
      if !empty(cIdOps) .and. cIdOps!=IdOps
        if !empty(IdOps)
           fOk:=.f.
        endif
      endif
      if !empty(cIdKan) .and. cIdKan!=IdKan
        if !empty(IdKan)
          fOk:=.f.
        endif
      endif
      if !empty(cIdEnt) .and. cIdEnt!=IdN0
        if !empty(IdN0)
           fOk:=.f.
        endif
      endif
      if fOk
         if empty(aRez[2]) // nisam jos nasao naziv
           aRez[2]:=Racun
         endif
         aRez[1]:=Racun ; aRez [3]:=BudzOrg
         exit
      endif
      skip
   enddo
   if fOk;   exit; endif
 endif
next
PopWa()
return aRez
*}



/*
 // setovanje varijabli: _kome_zr , _kome_txt, _budzorg
 // pretpostavke: kursor VRPRIM-> podesen na tekuce primanje
*/
function SetJPVar()
*{
 LOCAL cPom2:=""
  _IdJPrih:=TOKEN(vrprim->racun,"-",1)
  cPom:=    TOKEN(vrprim->racun,"-",2) // <- moze biti opcina, kanton ili entitet ili nista
  cPom2:=   TOKEN(vrprim->racun,"-",3) // <- moze se iskoristiti za opcinu
  cPom:=trim(cPom); cPom2:=TRIM(cPom2) //    ako je cPom kanton ili entitet a
  if len(cPom)==3                      //    opcina se popunjava na osnovu
    // nivo opcina                     //    prebivaliçta radnika
    _IdOps:=cPom
    aJPrih := JPrih(_IdJPrih,_IdOps,"","")
   _kome_zr := aJPrih[1]
   //_kome_txt := aJPrih[2]
   _BudzORg:=  aJPrih[3]
  elseif len(cPom)==2
    // nivo kantona
    // _IdOps:=space(3)
    _IdOps:=IF(LEN(cPom2)==3,cPom2,OpcRada())
    aJPrih := JPrih(_IdJPrih,"",cPom,"")
   _kome_zr := aJPrih[1]
   //_kome_txt := aJPrih[2]
   _BudzORg:=  aJPrih[3]
  elseif len(cPom)==1
    // nivo entiteta
    // _IdOps:=space(3)
    _IdOps:=IF(LEN(cPom2)==3,cPom2,OpcRada())
    aJPrih := JPrih(_IdJPrih,"","",cPom)
   _kome_zr := aJPrih[1]
   //_kome_txt := aJPrih[2]
   _BudzORg:=  aJPrih[3]
  elseif len(cPom)==0
    // jedinstveni uplatni racun
    _IdOps:=space(3)
    _IdJprih:=padr(_idjprih,6) // duzina sifre javnog prihoda
    aJPrih := JPrih(_IdJPrih,"","",cPom)
   _kome_zr := aJPrih[1]
   //_kome_txt := aJPrih[2]
   _BudzORg:=  aJPrih[3]
  endif
return
*}



function fillJprih()
*{
// drugi krug; popuni polja vezana za javne prihode ....
select vrprim; set order to tag "ID"
select pripr
go top
do while !eof()
  select vrprim; seek pripr->svrha_pl; select  pripr
  altd()
  Scatter()
  if vrprim->Idpartner="JP" // javni prihod
    SetJPVar()
  endif

  //09.02.2001
  _IznosSTR :=""
  IF gNumT=="D"
   _IznosSTR:="="+IF( _iznos==0.and.gINulu=="N" , SPACE(6) , ALLTRIM(FormNum1(_iznos)) )
  ELSE
   _IznosSTR:="="+IF( _iznos==0.and.gINulu=="N" , SPACE(6) , ALLTRIM(STRTRAN(STR(_iznos),".",",")) )
  ENDIF

  Gather()
  skip
enddo
return
*}



function KonvZnWin(cTekst, cWinKonv)
*{
 LOCAL aNiz:={  {"[","æ",chr(138),"S"}, {"{","ç",chr(154),"s"}, {"}","†",chr(230),"c"}, {"]","", chr(198),"C"}, {"^","¬", chr(200),"C"},;
                {"~","Ÿ",chr(232),"c"}, {"`","§",chr(158),"z"}, {"@","¦",chr(142),"Z"}, {"|","Ð", chr(240),"dj"}, {"\","Ñ", chr(208),"DJ"}  }
 LOCAL i,j

 if cWinKonv=NIL
  cWinKonv:=IzFmkIni("DelphiRb","Konverzija","5")
 endif

 i:=1; j:=1
 if cWinKonv=="1"
    i:=1; j:=2
 elseif cWinKonv=="2"
    i:=1; j:=4  // 7->A
 elseif cWinKonv=="3"
    i:=2; j:=1   // 852->7
 elseif cWinKonv=="4"
    i:=2; j:=4  // 852->A
 elseif cWinKonv=="5"
    i:=2; j:=3  // 852->win1250
 elseif cWinKonv=="6"
    i:=1; j:=3  // 7->win1250
 endif
 if i<>j
  AEVAL(aNiz,{|x| cTekst:=STRTRAN(cTekst,x[i],x[j])})
 endif

RETURN cTekst
*}



function OpcRada()
*{
  LOCAL cVrati:="   ", cOR:="", nArr:=SELECT()
  cOR:=IzFmkIni("VIRM","OpcRada","XXXX",KUMPATH)
  IF EMPTY(cOR); RETURN ""; ENDIF
  SELECT (F_OPS)
  IF !USED()
    O_OPS
    SEEK cOR
    IF FOUND(); cVrati := IDJ; ENDIF
    USE
  ELSE
    PushWA()
     SET ORDER TO TAG "ID"
     SEEK cOR
     IF FOUND(); cVrati := IDJ; ENDIF
    PopWA()
  ENDIF
  SELECT (nArr)
RETURN cVrati
*}



function Rekapit()
*{
 LOCAL aNiz:={},nPom:=0
  SELECT PRIPR
  START PRINT RET
  aNiz:={ {"PRIMALAC"   , {|| kome_txt}  , .f., "C", 55, 0, 1, 1 },;
          {"IZNOS      ", {|| iznos}     , .t., "N", 15, 2, 1, 2 };
        }
  GO TOP
  StampaTabele(aNiz,,gnLMarg,gTabela,{|| .t.},gA43=="4",;
               "REKAPITULACIJA UPLATA",;
               {|| .t.})
 END PRINT
RETURN
*}

*************************************************************
function Razrijedi (cStr)
*
*   Razrijedi (cStr) --> cStrRazr
*      Ubaci u string, izmedju slova, SPACE()
*
*************************************************************
*{
LOCAL cRazrStr, nLenM1, nCnt
cStr := ALLTRIM (cStr)
nLenM1 := LEN (cStr) - 1
cRazrStr := ""
FOR nCnt := 1 TO nLenM1
  cRazrStr += SUBSTR (cStr, nCnt, 1) + " "
NEXT
cRazrStr += RIGHT (cStr, 1)
RETURN (cRazrStr)
*}

