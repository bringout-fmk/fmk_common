#include "ld.ch"


function RekalkPrimanja()
local i
local nArrm
local nLjudi

if Logirati(goModul:oDataBase:cName,"DOK","REKALKPRIMANJA")
	lLogRekPrimanja:=.t.
else
	lLogRekPrimanja:=.f.
endif

Box(,4,60)
	@ m_x+1,m_y+2 SAY "Ova opcija vrsi preracunavanja onih stavki  primanja koja"
  	@ m_x+2,m_y+2 SAY "u svojoj formuli proracuna sadrze paramtre obracuna."
  	@ m_x+4,m_y+2 SAY "               <ESC> Izlaz"
  	inkey(0)
BoxC()

if (LastKey()==K_ESC)
	closeret
	return
endif

cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun

O_RJ
O_POR
O_DOPR
O_RADN
O_PAROBR
O_LD

cIdRadn:=SPACE(_LR_)
cStrSpr:=SPACE(3)

nDimenzija:=0

if lViseObr
	nDimenzija:=1
else
	nDimenzija:=0
endif

Box(,3+nDimenzija,50)
	@ m_x+1,m_y+2 SAY "Radna jedinica: "  GET cIdRJ
	@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
	@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
	if lViseObr
  		@ m_x+4,m_y+2 SAY "Obracun:"  GET  cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
	endif
	read
	ClvBox()
	ESC_BCR
BoxC()


if lViseObr
	O_TIPPRN
else
  	O_TIPPR
endif

select ld
seek STR(cGodina,4)+cIdRj+STR(cMjesec,2)+BrojObracuna()

EOF CRET

private cPom:=""
private lRekalk:=.t.

nLjudi:=0

Box(,1,12)
do while !eof() .and. cGodina==godina .and. cIdRj==idrj .and. cMjesec=mjesec .and. if(lViseObr,cObracun==obr,.t.)

 Scatter()
 ParObr(_mjesec,_godina,IF(lViseObr,_obr,),cIdRj)  // podesi parametre obra~una za ovaj mjesec

 select radn; hseek _idradn
 select ld

 for i:=1 to cLDPolja
  cPom:=padl(alltrim(str(i)),2,"0")
  select tippr; seek cPom; select ld
  if tippr->(found()) .and. tippr->aktivan=="D" .and. "PAROBR" $ upper(tippr->formula)

    _UIznos:=_UIznos-_i&cPom
    if tippr->uneto=="D"           //  izbij ovu stavku
       _Uneto:=_UNeto-_i&cPom      //    ..
    else                           //    ..
       _UOdbici:=_UOdbici-_i&cPom  //    .
    endif                          //    ..

    Izracunaj(@_i&cPom)            //  preracunaj ovu stavku

    // cPom je privatna, varijabla koja je Ÿesto koriçtena i to gotovo
    // uvijek kao privatna varijabla. Jednostavno, sada †u rijeçiti problem
    // ponovnim dodjeljivanjem vrijednosti, a za ovaj problem inaŸe smatram
    // da bi trebalo uvesti konvenciju davanja naziva ovakvim varijablama
    // --------------------------------------------------------------------
    cPom:=padl(alltrim(str(i)),2,"0") // MS 23.03.01.

    _UIznos+=_i&cPom               //  dodaj je nakon preracuna
    if tippr->uneto=="D"           //
       _Uneto+=_i&cPom             //
    else                           //
       _UOdbici+=_i&cPom           //
    endif

  endif

 next

 // test verzija
 _usati:=0
 for i:=1 to cLDPolja
   cPom:=padl(alltrim(str(i)),2,"0")
   select tippr; seek cPom
   if tippr->(found()) .and. tippr->aktivan=="D"
     if tippr->ufs=="D"
       _USati+=_s&cPom
     endif
   endif
 next

 // ako je nova varijanta obraèuna i ovo treba uvrstiti...
 if gVarObracun == "2"

	nKLO := radn->klo
	cTipRada := g_tip_rada( _idradn, _idrj )
	nSPr_koef := 0
	nTrosk := 0
	nBrOsn := 0
	cOpor := " "
	cTrosk := " "
	
	// koristi troskove ?
	if radn->(FIELDPOS("trosk")) <> 0
		cTrosk := radn->trosk
	endif

	// samostalni djelatnik
	if cTipRada == "S"
		if radn->(FIELDPOS("SP_KOEF")) <> 0
			nSPr_koef := radn->sp_koef
		endif
	endif

	// ako su ovi tipovi primanja - nema odbitka !
	if cTipRada $ "A#U#P#S"
		_ULicOdb := 0
	endif

	// bruto osnova
	_UBruto := bruto_osn( _UNeto, cTipRada, _ULicOdb, nSPr_koef, cTrosk ) 

	// ugovor o djelu
	if cTipRada == "U" .and. cTrosk <> "N"
		nTrosk := ROUND2( _UBruto * (gUgTrosk / 100), gZaok2 )
		if lInRS == .t.
			nTrosk := 0
		endif
		_UBruto := _UBruto - nTrosk 
	endif

	// autorski honorar
	if cTipRada == "A" .and. cTrosk <> "N"
		nTrosk := ROUND2( _UBruto * (gAhTrosk / 100), gZaok2 )
		if lInRS == .t.
			nTrosk := 0
		endif
		_UBruto := _UBruto - nTrosk
	endif

	nMinBO := _UBruto
	if cTipRada $ " #I#N"
		nMinBO := min_bruto( _Ubruto, _Usati )
	endif

	// uiznos je sada sa uracunatim brutom i ostalim
	
	// ukupno doprinosi IZ place
	nUDoprIZ := u_dopr_iz( nMinBO, cTipRada )
	_UDopr := nUDoprIZ
	_UDop_St := 31.0

	// poreska osnovica
	nPorOsnovica := ( (_UBruto - _Udopr) - _ulicodb )

	if nPorOsnovica < 0 .or. !radn_oporeziv( _idradn, _idrj )
		nPorOsnovica := 0
	endif

	// porez
	_UPorez := izr_porez( nPorOsnovica, "B" )
	_UPor_st := 10.0

	// nema poreza
	if !radn_oporeziv( _idradn, _idrj )
		_uporez := 0
		_upor_st := 0
	endif

	// neto plata
	_uneto2 := ROUND2( (_ubruto - _udopr) - _uporez , gZaok2)

	if cTipRada $ " #I#N"
		_uneto2 := min_neto( _uneto2, _usati )
	endif

	_uiznos := ROUND2( _uneto2 + _UOdbici, gZaok2 )

	if cTipRada $ "U#A" .and. cTrosk <> "N"
		// kod ovih vrsta dodaj i troskove
		_uIznos := ROUND2( _uiznos + nTrosk, gZaok2 )
	endif

	if cTipRada $ "S"
		// neto je za isplatu
		_uIznos := _UNeto
	endif

 endif

 select ld

 Gather()

 @ m_x+1,m_y+2 SAY ++nljudi pict "99999"

skip

enddo

if lLogRekPrimanja
	EventLog(nUser,goModul:oDataBase:cName,"DOK","REKALKPRIMANJA",nljudi,nil,nil,nil,cIdRj,STR(cMjesec,2),STR(cGodina,4),Date(),Date(),"","Rekalkulacija satnica i primanja")
endif

Beep(1)
inkey(1)
BoxC()
lRekalk:=.f.
closeret
return



function RekalkProcenat()
local i,nArrm,nLjudi

if Logirati(goModul:oDataBase:cName,"DOK","REKALKPROCENAT")
	lLogRekProcenat:=.t.
else
	lLogRekProcenat:=.f.
endif

Box(,4,60)
  @ m_x+1,m_y+2 SAY "Ova opcija vrsi preracunavanje iznosa odredjenog primanja"
  @ m_x+4,m_y+2 SAY "               <ESC> Izlaz"
  inkey(0)
BoxC()

if LastKey()==K_ESC
   closeret
   return
endif

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := gObracun

O_RADN
O_PAROBR
O_TIPPR
O_TIPPR2
O_LD

cIdRadn:=space(_LR_)
cStrSpr:=space(3)
nProcPrim:=0
cTipPP:="  "
cDN:="N"
Box(,7,50)
@ m_x+1,m_y+2 SAY "Radna jedinica: "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
IF lViseObr
  @ m_x+4,m_y+2 SAY "Obracun:"  GET  cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
ENDIF
@ m_x+5,m_y+2 SAY "Sifra tipa primanja " GET  cTipPP valid if(lViseObr.and.cObracun<>"1",P_Tippr2(@cTipPP),P_Tippr(@cTipPP)) .and. !empty(cTipPP)
@ m_x+6,m_y+2 SAY "Procenat za koji se vrsi promjena " GET  nProcPrim pict "999999.999"
@ m_x+7,m_y+2 SAY "Sigurno zelite nastaviti   (D/N) ?" GET  cDN pict "@!" valid cDN $"DN"
read; clvbox(); ESC_BCR
BoxC()

if cDN=="N"
	return
endif

SELECT (F_TIPPR) ; USE
SELECT (F_TIPPR2); USE
if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif

SELECT LD

seek str(cGodina,4)+cidrj+str(cMjesec,2)+IF(lViseObr,cObracun,"")
EOF CRET

private cpom:=""
nLjudi:=0
Box(,1,12)

nStariIznos:=nNoviIznos:=0

do while !eof() .and.  cgodina==godina .and. cidrj==idrj .and.;
         cmjesec=mjesec .and. IF(lViseObr,cObracun==obr,.t.)

 Scatter()
 ParObr(_mjesec,_godina,IF(lViseObr,_obr,),cIdRj)  // podesi parametre obra~una za ovaj mjesec

 select radn; hseek _idradn
 select ld

 for i:=1 to cLDPolja
  cPom:=padl(alltrim(str(i)),2,"0")
  if cPom==cTipPP .and. _i&cPom<>0  // to je to primanje
    select tippr; seek cPom; select ld

    nStariIznos := _i&cPom

    _UIznos:=_UIznos-nStariIznos
    if tippr->uneto=="D"                    //  izbij ovu stavku
       _Uneto:=_UNeto-nStariIznos           //    ..
    else                                    //    ..
       _UOdbici:=_UOdbici-nStariIznos       //    .
    endif                                   //    ..

    nNoviIznos := _i&cPom := round(nStariIznos*(1+nProcPrim/100),gZaok)

    if tippr->fiksan=="P"
      // preraŸunaj i procenat
      _s&cPom :=  ROUND( _s&cPom * nNoviIznos / nStariIznos , 2)
      if _s&cPom=0
        MsgBeep("Istopio se postotak kod radnika:'"+_idradn+"' !")
      endif
      // ponovo izracunaj iznos radi zaokru§enja
      Izracunaj(@_i&cPom)

      cPom:=padl(alltrim(str(i)),2,"0")  // MS 23.03.01.

      nNoviIznos := _i&cPom
    endif

    _UIznos+=nNoviIznos            //  dodaj je nakon preracuna
    if tippr->uneto=="D"           //
       _Uneto+=nNoviIznos          //
    else                           //
       _UOdbici+=nNoviIznos        //
    endif

  endif

 next

 // test verzija
_usati:=0
for i:=1 to cLDPolja
   cPom:=padl(alltrim(str(i)),2,"0")
   select tippr; seek cPom
   if tippr->(found()) .and. tippr->aktivan=="D"
     if tippr->ufs=="D"
       _USati+=_s&cPom
     endif
   endif
next
select ld


 Gather()
 @ m_x+1,m_y+2 SAY ++nljudi pict "99999"
 skip
enddo

if lLogRekProcenat
	EventLog(nUser,goModul:oDataBase:cName,"DOK","REKALKPROCENAT",nljudi,nil,nil,nil,cIdRj,STR(cMjesec,2),STR(cGodina,4),Date(),Date(),"","Rekalkulacija primanja po zadatom procentu")
endif


Beep(1); inkey(1)
BoxC()
closeret
return




function RekalkFormula()
local i,nArrm,nLjudi

if Logirati(goModul:oDataBase:cName,"DOK","REKALKFORMULA")
	lLogRekFormula:=.t.
else
	lLogRekFormula:=.f.
endif


Box(,4,60)
  @ m_x+1,m_y+2 SAY "Ova opcija vrsi preracunavanje odredjenog primanja"
  @ m_x+4,m_y+2 SAY "               <ESC> Izlaz"
  inkey(0)
BoxC()
if lastkey()==K_ESC
   closeret
   return
endif

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := gObracun

O_RADN
O_PAROBR
O_TIPPR
O_TIPPR2
O_LD

cIdRadn:=space(_LR_)
cStrSpr:=space(3)
nProcPrim:=0
cTipPP:="  "
cDN:="N"
Box(,7,50)
@ m_x+1,m_y+2 SAY "Radna jedinica: "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
IF lViseObr
  @ m_x+4,m_y+2 SAY "Obracun:"  GET  cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
ENDIF
@ m_x+5,m_y+2 SAY "Sifra tipa primanja " GET  cTipPP valid if(lViseObr.and.cObracun<>"1",P_Tippr2(@cTipPP),P_Tippr(@cTipPP)) .and. !empty(cTipPP)
@ m_x+7,m_y+2 SAY "Sigurno zelite nastaviti   (D/N) ?" GET  cDN pict "@!" valid cDN $"DN"
read; clvbox(); ESC_BCR
BoxC()

if cDN=="N"
	return
endif

SELECT (F_TIPPR) ; USE
SELECT (F_TIPPR2); USE
if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif
SELECT LD

seek str(cGodina,4)+cidrj+str(cMjesec,2)+IF(lViseObr,cObracun,"")
EOF CRET

private cpom:=""
nLjudi:=0
Box(,1,12)
do while !eof() .and.  cgodina==godina .and. cidrj==idrj .and.;
         cmjesec=mjesec .and. IF(lViseObr,cObracun==obr,.t.)

 Scatter()
 ParObr(_mjesec,_godina,IF(lViseObr,_obr,),cIdRj)  // podesi parametre obra~una za ovaj mjesec

 select radn; hseek _idradn
 select ld

 for i:=1 to cLDPolja
  cPom:=padl(alltrim(str(i)),2,"0")
  if cPom==cTipPP  // to je to primanje
    select tippr; seek cPom; select ld
    _UIznos:=_UIznos-_i&cPom
    if tippr->uneto=="D"           //  izbij ovu stavku
       _Uneto:=_UNeto-_i&cPom      //    ..
    else                           //    ..
       _UOdbici:=_UOdbici-_i&cPom  //    .
    endif                          //    ..


    //_i&cPom:=round(_i&cPom*(1+nProcPrim/100),gZaok)
    Izracunaj(@_i&cPom)

    cPom:=padl(alltrim(str(i)),2,"0")  // MS 23.03.01.

    ///*******Izracunaj(@_i&cPom)            //  preracunaj ovu stavku


    _UIznos+=_i&cPom               //  dodaj je nakon preracuna
    if tippr->uneto=="D"           //
       _Uneto+=_i&cPom             //
    else                           //
       _UOdbici+=_i&cPom           //
    endif

  endif

 next

 // test verzija
_usati:=0
for i:=1 to cLDPolja
   cPom:=padl(alltrim(str(i)),2,"0")
   select tippr; seek cPom
   if tippr->(found()) .and. tippr->aktivan=="D"
     if tippr->ufs=="D"
       _USati+=_s&cPom
     endif
   endif
next
select ld


 Gather()
 @ m_x+1,m_y+2 SAY ++nljudi pict "99999"
 skip
enddo

if lLogRekFormula
	EventLog(nUser,goModul:oDataBase:cName,"DOK","REKALKFORMULA",nljudi,nil,nil,nil,cIdRj,STR(cMjesec,2),STR(cGodina,4),Date(),Date(),"","Rekalkulacija primanja po zadatoj formuli")
endif


Beep(1)
inkey(1)
BoxC()

closeret
return
*}



function RekalkSve()
*{
local i,nArrm,nLjudi

if Logirati(goModul:oDataBase:cName,"DOK","REKALKSVE")
	lLogRekSve:=.t.
else
	lLogRekSve:=.f.
endif


Box(,4,60)
  @ m_x+1,m_y+2 SAY "Ova opcija vrsi preracunavanja:                        "
  @ m_x+2,m_y+2 SAY "NETO SATI, NETO IZNOS, UKUPNO ZA ISPLATU, UKUPNO ODBICI"
  @ m_x+4,m_y+2 SAY "               <ESC> Izlaz"
  inkey(0)
BoxC()
if lastkey()==K_ESC
   closeret
   return
endif

cMjesec  := gMjesec
cGodina  := gGodina
cObracun := gObracun

O_RADN
O_PAROBR
O_LD

cIdRadn:=space(_LR_)
cStrSpr:=space(3)

Box(,3+IF(lViseObr,1,0),50)
 @ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
 @ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
 IF lViseObr
   @ m_x+4,m_y+2 SAY "Obracun:"  GET  cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
 ENDIF
 read; clvbox(); ESC_BCR
BoxC()

if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif

SELECT LD
set order to tag "2"
seek str(cGodina,4)+str(cMjesec,2)+IF(lViseObr,cObracun,"")

EOF CRET

private cpom:=""
nLjudi:=0
Box(,1,12)
do while !eof() .and.  cGodina==godina .and.  cmjesec=mjesec .and.;
         IF(lViseObr,cObracun==obr,.t.)

 Scatter()
 ParObr(_mjesec,_godina,IF(lViseObr,_obr,),_idrj)  // podesi parametre obra~una za ovaj mjesec

 select radn; hseek _idradn
 select ld


 _USati:=0
 _UNeto:=0;_UOdbici:=0
 UkRadnik()  // filuje _USati,_UNeto,_UOdbici
 _UIznos:=_UNeto+_UOdbici

 Gather()
 @ m_x+1,m_y+2 SAY ++nljudi pict "99999"
 skip
enddo

if lLogRekSve
	EventLog(nUser,goModul:oDataBase:cName,"DOK","REKALKSVE",nljudi,nil,nil,nil,nil,STR(cMjesec,2),STR(cGodina,4),Date(),Date(),"","Rekalkulacija neto sati neto primanja")
endif


Beep(1)
inkey(1)
BoxC()

closeret
return


