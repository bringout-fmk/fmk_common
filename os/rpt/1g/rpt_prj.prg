#include "\cl\sigma\fmk\os\os.ch"


function PregRj()
*{
local lPartner

O_RJ
O_OS

lPartner:=IsPartner()

cIdrj:=space(4)
cON:="N"
cKolP:="N"
cPocinju:="N"

cBrojSobe:=space(6)
lBrojSobe:=.f.
cFiltK1:=SPACE(40)
cFiltDob:=SPACE(40)
cOpis:="N"

Box(,7+IF(lPartner,1,0),77)
 DO WHILE .t.
  @ m_x+1,m_y+2 SAY "Radna jedinica:" get cidrj valid p_rj(@cIdrj)
  @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
  @ m_x+2,m_y+2 SAY "Prikaz svih neotpisanih (N) / otpisanih(O) /"
  @ m_x+3,m_y+2 SAY "samo novonabavljenih (B)    / iz proteklih godina (G)"   get cON pict "@!" valid con $ "ONBG"
  @ m_x+4,m_y+2 SAY "Prikazati kolicine na popisnoj listi D/N" GET cKolP valid cKolP $ "DN" pict "@!"
  @ m_x+5,m_y+2 SAY "Prikazati kolonu 'opis' ? (D/N)" GET cOpis valid cOpis $ "DN" pict "@!"

  if fieldpos("brsoba")<>0
    lBrojSobe:=.t.
    @ m_x+6,m_y+2 SAY "Broj sobe (prazno sve) " GET cBrojSobe  pict "@!"
  endif

  @ m_x+7,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"

  if lPartner
    @ m_x+8,m_y+2 SAY "Filter po dobavljacima:" GET cFiltDob pict "@!S20"
  endif

  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  aUsl2:=Parsiraj(cFiltDob,"idPartner")
  if aUsl1<>nil .and. aUsl2<>nil
    exit
  endif
 ENDDO
BoxC()

if lBrojSobe .and. EMPTY(cBrojSobe)
  lBrojSobe := ( Pitanje(,"Zelite li da bude prikazan broj sobe? (D/N)","N") == "D" )
endif

IF ! ( lBrojSobe .and. EMPTY(cBrojSobe) ) .and.;
   IzFMKIni("Opresa","PopisnaListaPoKontima","N")=="D"
  lPoKontima:=.t.
ELSE
  lPoKontima:=.f.
ENDIF

lPoAmortStopama:=(IzFmkIni("OsRptPrj","PoAmortStopama","N",PRIVPATH)=="D")

if cpocinju=="D"
  cIdRj:=trim(cidrj)
endif

start print cret

m:="----- ---------- ----------------------------"+IF(cOpis=="D"," "+REPL("-",LEN(OS->opis)),"")+"  ---- ------- -------------"
if lPoAmortStopama
	select os
	if cIdRj==""
		set order to tag "5" // idam+idrj+id
	else
		INDEX ON idrj+idam+id TO "TMPOS"
	endif
elseif lBrojSobe .and. EMPTY(cBrojSobe)
	m:="----- ------ ---------- ----------------------------"+IF(cOpis=="D"," "+REPL("-",LEN(OS->opis)),"")+"  ---- ------- -------------"
	select os
	set order to  2 //idrj+id+dtos(datum)
	INDEX ON idrj+brsoba+id+dtos(datum) TO "TMPOS"
elseif lPoKontima
	select os
	INDEX ON idkonto+id TO "TMPOS"
elseif cIdRj==""
	select os
	set order to tag "1" // id+idam+dtos(datum)
else
	select os
	set order to  2 //idrj+id+dtos(datum)
endif

if !EMPTY(cFiltK1) .or. !EMPTY(cFiltDob)
  cFilter:=aUsl1+".and."+aUsl2
  select os
  set filter to &cFilter
endif

ZglPrj()

if !lPoKontima
  seek cidrj
endif

private nrbr:=0
cLastKonto:=""

do while !eof() .and. ( idrj=cidrj .or. lPoKontima)

 if lPoKontima .and. !(idrj=cidrj)
   skip; loop
 endif

 if (cON="B" .and. year(gdatobr)<>year(datum))  // nije novonabavljeno
   skip ; loop                                  // prikazi samo novonabavlj.
 endif

 if (cON="G" .and. year(gdatobr)=year(datum))  // iz protekle godine
   skip; loop                                   // prikazi samo novonabavlj.
 endif
 // sasa 30.01.04, bilo datotp=gdatobr a sada datotp<=gdatobr
 if (!empty(datotp) .and. year(datotp)<=year(gdatobr)) .and. cON $ "NB"
     // otpisano sredstvo , a zelim prikaz neotpisanih
     skip ; loop
 endif
 // sasa 30.01.04, 
 if (empty(datotp) .and. year(datotp)<year(gdatobr)) .and. cON=="O"
     // neotpisano, a zelim prikaz otpisanih
     skip ; loop
 endif

 if !empty(cBrojsobe)
    if cbrojsobe<>os->brsoba
       skip; loop
    endif
 endif

 if lPoKontima .and. ( nrbr=0 .or. cLastKonto<>idkonto )  // prvo sredstvo,
                                                          // ispiçi zaglavlje
   if nrbr>0
     ? m
     ?
     // FF; ZglPrj()
   endif

   if prow()>59; FF; ZglPrj(); endif

   ?
   ? "KONTO:",idkonto
   ? REPL("-",14)
   nRbr:=0

 endif

 if prow()>62; FF; ZglPrj(); endif
 
 altd()
 
 if lBrojSobe .and. EMPTY(cBrojSobe)
   ? str(++nrbr,4)+".",brsoba,id,naz
 else
   ? str(++nrbr,4)+".",id,naz
 endif
 IF cOpis=="D"
   ?? "",opis
 ENDIF
 ?? "",jmj

 if cKolP=="D"
  @  prow(),pcol()+1 SAY kolicina pict "9999.99"
 else
  @  prow(),pcol()+1 SAY space(7)
 endif

 cLastKonto := idkonto

 @ prow(),pcol()+1 SAY " ____________"
 skip
enddo

? m

if prow()>56; FF; ZglPrj(); endif
?
? "     Zaduzeno lice:                                     Clanovi komisije:"
?
? "     _______________                                  1.___________________"
?
? "                                                      2.___________________"
?
? "                                                      3.___________________"
FF
end print

closeret
return
*}



function ZglPrj()
*{
LOCAL nArr:=SELECT()
P_10CPI
?? UPPER(gTS)+":",gNFirma
?
? "OS: Pregled osnovnih "
if cON=="N"
   ?? "sredstava u upotrebi"
elseif cON=="B"
   ?? "novonabavljenih sredstava u toku godine"
else
   ?? "sredstava otpisanih u toku godine"
endif
select rj; seek cidrj; select (nArr)
?? "     Datum:",gDatObr

? "Radna jedinica:",cidrj,rj->naz
if cpocinju=="D"
  ?? space(6),"(SVEUKUPNO)"
endif

if !EMPTY(cFiltK1)
  ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"
endif

if !EMPTY(cFiltDob)
  ? "Filter za dobavljace pravljen po uslovu: '"+TRIM(cFiltDob)+"'"
endif

if !empty(cBrojSobe)
  ?
  ? "Prikaz za sobu br:", cBrojSobe
  ?
endif

IF cOpis=="D"
  P_COND
ENDIF

? m
if lBrojSobe .and. EMPTY(cBrojSobe)
 ? " Rbr. Br.sobe Inv.broj        Sredstvo               "+IF(cOpis=="D",PADC("Opis",1+LEN(OS->opis)),"")+" jmj  kol  "
else
 ? " Rbr.  Inv.broj        Sredstvo              "+IF(cOpis=="D",PADC("Opis",1+LEN(OS->opis)),"")+"  jmj  kol  "
endif
? m
return
*}

