#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/razdb/1g/fak_kal.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: fak_kal.prg,v $
 * Revision 1.6  2003/12/01 14:04:16  sasavranic
 * no message
 *
 * Revision 1.5  2003/11/29 13:49:58  sasavranic
 * Uvedena nova funkcija GetNextKalkDoc() za provjeru sljedeceg broja kalkulacije
 *
 * Revision 1.4  2003/07/06 22:20:23  mirsad
 * prenos fakt12->kalk96 obuhvata i varijantu unosa radnog naloga u fakt12
 *
 * Revision 1.3  2003/03/12 09:20:17  mirsad
 * brojac KALK dokumenata po kontima (koristenje sufiksa iz KONCIJ-a)
 *
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/razdb/1g/fak_kal.prg
 *  \brief Prenosi FAKT->KALK za magacinske dokumente
 */


/*! \fn FaKaMag()
 *  \brief Meni opcija za prenos FAKT->KALK za magacinske dokumente
 */

function FaKaMag()
*{
private Opc:={}
private opcexe:={}

AADD(Opc,"1. fakt->kalk (10->14) racun veleprodaje               ")
AADD(opcexe,{|| Prenos() })
AADD(Opc,"2. fakt->kalk (12->96) otpremnica")
AADD(opcexe,{||  PrenosOt()  })
AADD(Opc,"3. fakt->kalk (19->96) izlazi po ostalim osnovama")
AADD(opcexe,{||          PrenosOt("19") })         
AADD(Opc,"4. fakt->kalk (01->10) ulaz od dobavljaca")
AADD(opcexe,{||          PrenosOt("01_10") })          
AADD(Opc,"5. fakt->kalk (0x->16) doprema u magacin")
AADD(opcexe,{||          PrenosOt("0x") })          
private Izbor:=1
Menu_SC("fkma")
CLOSERET



/*! \fn Prenos()
 *  \brief Prenos FAKT 10 -> KALK 14 (veleprodajni racun)
 */
 
function Prenos()
*{
local cIdFirma:=gFirma
local cIdTipDok:="10"
local cBrDok:=SPACE(8)
local cBrKalk:=SPACE(8)
local cFaktFirma:=gFirma
local dDatPl:=ctod("")
local fDoks2:=.f.

PRIVATE lVrsteP := ( IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D" )

O_KONCIJ
O_PRIPR
O_KALK
O_DOKS
if file(KUMPATH+"DOKS2.DBF")
	fDoks2:=.t.
	O_DOKS2
endif
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

dDatKalk:=date()
cIdKonto:=padr("1200",7)
cIdKonto2:=padr("1310",7)
cIdZaduz2:=space(6)

if glBrojacPoKontima
	Box("#FAKT->KALK",3,70)
		@ m_x+2, m_y+2 SAY "Konto razduzuje" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
		read
	BoxC()
	cSufiks:=SufBrKalk(cIdKonto2)
	//cBrKalk:=SljBrKalk("14",cIdFirma,cSufiks)
	cBrKalk:=GetNextKalkDoc(cIdFirma, "14")
else
	//******* izbaceno koristenje stare funkcije !!!
	//cBrKalk:=SljBrKalk("14",cIdFirma)
	cBrKalk:=GetNextKalkDoc(cIdFirma, "14")
endif

Box(,15,60)

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 14 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  //@ m_x+3,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  @ m_x+4,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" when !glBrojacPoKontima valid P_Konto(@cIdKonto2)
  if gNW<>"X"
   @ m_x+4,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif

  cFaktFirma:=IF(cIdKonto2==gKomKonto,gKomFakt,cIdFirma)
  @ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  @ m_x+6,col()+2 SAY "- "+cidtipdok
  @ m_x+6,col()+2 SAY "-" GET cBrDok
  read
  if lastkey()==K_ESC; exit; endif

  select xfakt
  seek cFaktFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
     loop
  else
     IF lVrsteP
       cIdVrsteP := idvrstep
     ENDIF
     aMemo:=parsmemo(txt)
     if len(aMemo)>=5
       @ m_x+10,m_y+2 SAY padr(trim(amemo[3]),30)
       @ m_x+11,m_y+2 SAY padr(trim(amemo[4]),30)
       @ m_x+12,m_y+2 SAY padr(trim(amemo[5]),30)
     else
        cTxt:=""
     endif
     if len(aMemo)>=9
       dDatPl:=ctod(aMemo[9])
     endif

     cIdPartner:=space(6)
     if !empty(idpartner)
       cIdPartner:=idpartner
     endif
     private cBeze:=" "
     @ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
     @ m_x+15,m_y+2 SAY "<ENTER> - prenos" GET cBeze
     read; ESC_BCR

     select PRIPR
     locate for BrFaktP=cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     go bottom
     if brdok==cBrKalk; nRbr:=val(Rbr); endif
     select xfakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF

     if fdoks2
        select doks2; hseek cidfirma+"14"+cbrkalk
        if !found()
           append blank
           replace idvd with "14",;   // izlazna faktura
                   brdok with cBrKalk,;
                   idfirma with cidfirma
        endif
        replace DatVal with dDatPl
        IF lVrsteP
          replace k2 with cIdVrsteP
        ENDIF
        select xFakt

     endif

     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek xfakt->idroba

       select tarifa; hseek roba->idtarifa

       select xfakt
       if alltrim(podbr)=="."  .or. roba->tip $ "UY"
          skip; loop
       endif

       select PRIPR
       APPEND BLANK
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "14",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idpartner with cIdPartner,;
               idtarifa with ROBA->idtarifa,;
               brfaktp with xfakt->brdok,;
               datfaktp with xfakt->datdok,;
               idkonto   with cidkonto,;
               idkonto2  with cidkonto2,;
               idzaduz2  with cidzaduz2,;
               datkurs with xfakt->datdok,;
               kolicina with xfakt->kolicina,;
               idroba with xfakt->idroba,;
               nc  with ROBA->nc,;
               vpc with xfakt->cijena,;
               rabatv with xfakt->rabat,;
               mpc with xfakt->porez
       PrenPoNar()
       //if roba->tip=="V"  // visoka tarifa
       //        replace vpc  with xfakt->cijena/(1+tarifa->opp/100),;
       //                mpc  with tarifa->opp
       //endif
       select xfakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
  endif

enddo
BoxC()
closeret
return
*}




/*! \fn PrenosOt(cIndik)
 *  \brief Prenosi FAKT->KALK (12->96),(19->96),(01->10),(0x->16)
 */

function PrenosOt(cIndik)
*{
local cIdFirma:=gFirma,cIdTipDok:="12",cBrDok:=cBrKalk:=space(8)
local cTipKalk:="96"

IF cIndik!=NIL.and.cIndik=="19"; cIdTipDok:="19"; ENDIF
IF cIndik!=NIL.and.cIndik=="0x"; cIdTipDok:="0x"; ENDIF

if cIndik="01_10"

   cTipKalk:="10"
   cIdtipdok:="01"

elseif cIndik="0x"

   cTipKalk:="16"

endif

O_KONCIJ
O_PRIPR
O_KALK
O_DOKS
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

dDatKalk:=date()

if cIdTipDok=="01"
  cIdKonto:=padr("1310",7)
  cIdKonto2:=padr("",7)
elseif cIdTipDok=="0x"
  cIdKonto:=padr("1310",7)
  cIdKonto2:=padr("",7)
else
  cIdKonto:=padr("",7)
  cIdKonto2:=padr("1310",7)
endif

cIdZaduz2:=space(6)

if glBrojacPoKontima
	Box("#FAKT->KALK",3,70)
		@ m_x+2, m_y+2 SAY "Konto zaduzuje" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
		read
	BoxC()
	cSufiks:=SufBrKalk(cIdKonto)
	//cBrKalk:=SljBrKalk(cTipKalk,cIdFirma,cSufiks)
	cBrKalk:=GetNextKalkDoc(cIdFirma, cTipKalk)
else
	//cBrKalk:=SljBrKalk(cTipKalk,cIdFirma)
	cBrKalk:=GetNextKalkDoc(cIdFirma, cTipKalk)
endif

Box(,15,60)

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije "+cTipKalk+" -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" when !glBrojacPoKontima valid P_Konto(@cIdKonto)
  @ m_x+4,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" valid empty(cidkonto2) .or. P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+4,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif

  cFaktFirma:=cIdFirma
  @ m_x+6,m_y+2 SAY "Broj "+IF(LEFT(cIdTipDok,1)!="0","otpremnice","dokumenta u FAKT")+": " GET  cFaktFirma
  IF LEFT(cIdTipDok,1)!="0"
    @ m_x+6,col()+1 SAY "- "+cidtipdok
  ELSE
    @ m_x+6,col()+1 SAY "- " GET cidtipdok VALID cIdTipDok$"00#01"
  ENDIF
  @ m_x+6,col()+1 SAY "-" GET cBrDok
  read
  if lastkey()==K_ESC; exit; endif


  select xfakt
  seek cFaktFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
     loop
  else
     aMemo:=parsmemo(txt)
     if len(aMemo)>=5
       @ m_x+10,m_y+2 SAY padr(trim(amemo[3]),30)
       @ m_x+11,m_y+2 SAY padr(trim(amemo[4]),30)
       @ m_x+12,m_y+2 SAY padr(trim(amemo[5]),30)
     else
	cTxt:=""
     endif
     cIdPartner:=space(6)
     private cBeze:=" "

     if cTipKalk $ "10"
       @ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
       @ m_x+15,m_y+2 SAY "<ENTER> - prenos" GET cBeze
       read
     endif

     select PRIPR
     locate for BrFaktP=cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     go bottom
     if brdok==cBrKalk; nRbr:=val(Rbr); endif

     SELECT KONCIJ; SEEK TRIM(cIdKonto)

     select xfakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF
     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek xfakt->idroba

       select tarifa; hseek roba->idtarifa

       select xfakt
       if alltrim(podbr)=="."  .or. idroba="U"
          skip
          loop
       endif

       select PRIPR
       APPEND BLANK
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with cTipKalk,;
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idpartner with cIdPartner,;
               idtarifa with ROBA->idtarifa,;
               brfaktp with xfakt->brdok,;
               datfaktp with xfakt->datdok,;
               idkonto   with cidkonto,;
               idkonto2  with cidkonto2,;
               idzaduz2  with cidzaduz2,;
               datkurs with xfakt->datdok,;
               kolicina with xfakt->kolicina,;
               idroba with xfakt->idroba,;
               nc  with ROBA->nc,;
               vpc with xfakt->cijena,;
               rabatv with xfakt->rabat,;
               mpc with xfakt->porez

	if cTipKalk $ "10#16" // kod ulaza puni sa cijenama iz sifranika
		// replace vpc with roba->vpc
		replace vpc with KoncijVPC()
	endif

	if cTipKalk $ "96" .and. xfakt->(fieldpos("idrnal"))<>0
		replace idzaduz2 with xfakt->idRNal
	endif

       PrenPoNar()

       //if roba->tip=="V"  // visoka tarifa
       //        replace vpc  with xfakt->cijena/(1+tarifa->opp/100),;
       //                mpc  with tarifa->opp
       //endif
       select xfakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
  endif

enddo
BoxC()
closeret
return
*}

//******** funkcija se vise ne koristi uvedena GetNextKalkDoc()
function SljBrKalk(cTipKalk,cIdFirma,cSufiks)
*{
local cBrKalk:=space(8)
if cSufiks==nil
	cSufiks:=SPACE(3)
endif
if gBrojac=="D"
	if glBrojacPoKontima
		select doks
		set order to tag "1S"
		seek cIdFirma+cTipKalk+cSufiks+"X"
	else
		select kalk
		set order to 1
		seek cIdFirma+cTipKalk+"X"
	endif
	skip -1
	if cTipKalk<>field->idVD .or. glBrojacPoKontima.and.right(field->brDok,3)<>cSufiks
		cBrKalk:=SPACE(5)+cSufiks
	else
		cBrKalk:=field->brDok
	endif
	if cTipKalk=="16" .and. glEvidOtpis
		cBrKalk:=STRTRAN(cBrKalk,"-X","  ")
	endif
	cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
endif
return cBrKalk
*}

function SufBrKalk(cIdKonto)
*{
local nArr:=SELECT()
local cSufiks:=SPACE(3)
select koncij
seek cIdKonto
if found()
	cSufiks:=field->sufiks
endif
select (nArr)
return cSufiks
*}


function GetNextKalkDoc(cIdFirma, cIdTipDok)
*{
lIdiDalje:=.f.
//select kalk
select doks
set order to 1
seek cIdFirma + cIdTipDok + "X"
// vrati se na zadnji zapis
skip -1

altd()

do while .t.
	for i:=1 to LEN(ALLTRIM(field->brDok)) 
		if !IsNumeric(SubStr(ALLTRIM(field->brDok),i,1))
			lIdiDalje:=.f.
			skip -1
			loop
		else
			lIdiDalje:=.t.
		endif
	next
	if lIdiDalje:=.t.
		cResult:=field->brDok
		exit
	endif
	
enddo

cResult:=UBrojDok(VAL(LEFT(cResult,5))+1, 5, RIGHT(cResult,3))

return cResult
*}


function IsNumeric(cString)
*{
altd()
if AT(cString, "0123456789")<>0
	lResult:=.t.
else
	lResult:=.f.
endif

return lResult
*}

