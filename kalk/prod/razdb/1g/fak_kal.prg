#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/razdb/1g/fak_kal.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: fak_kal.prg,v $
 * Revision 1.5  2002/10/17 14:37:31  mirsad
 * nova opcija prenosa dokumenata: FAKT11->KALK42
 * dorada za Vindiju (sa rabatom u MP)
 *
 * Revision 1.4  2002/10/02 12:20:22  sasa
 * Uvodjenje nove opcije kreiranja zbirne 41-ce na osnovu vise 11-ki (Vindija)
 *
 * Revision 1.3  2002/06/26 12:13:49  ernad
 *
 *
 * debug potencijalni bug - pri prenosu 13->11, za Planika se sada uvijek pojavi prodavnicki konto.
 *
 * Revision 1.2  2002/06/21 12:11:49  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/razdb/1g/fak_kal.prg
 *  \brief Prenos maloprodajnih dokumenata iz FAKT u KALK
 */


/*! \fn FaKaProd()
 *  \brief Meni opcija prenosa maloprodajnih dokumenata iz FAKT u KALK
 */

function FaKaProd()
*{
private Opc:={}
private opcexe:={}

AADD(Opc,"1. fakt->kalk (13->11) otpremnica maloprodaje        ")
AADD(opcexe,{||  Prenos13()})
AADD(Opc,"2. fakt->kalk (11->41) racun maloprodaje")
AADD(opcexe,{||          PrenosMP()  })
AADD(Opc,"3. fakt->kalk (11->42) paragon")
AADD(opcexe,{||          PrenosMP2()  })
AADD(Opc,"4. fakt->kalk (01->81) doprema u prod")
AADD(opcexe,{||          Prenos01_2() })
AADD(Opc,"5. fakt->kalk (13->80) prenos iz c.m. u prodavnicu")
AADD(opcexe,{||          Prenos13_2()  })
AADD(Opc,"6. fakt->kalk (15->15) izlaz iz MP putem VP")
AADD(opcexe,{||          Prenos15() })
private Izbor:=1
Menu_SC("fkpr")
CLOSERET
return
*}





/*! \fn Prenos13()
 *  \brief Otprema u mp FAKT -> KALK 11   (13->11)
 */

function Prenos13()
*{
local cIdFirma:=gFirma,cIdTipDok:="13",cBrDok:=cBrKalk:=space(8)

O_PRIPR
O_KONCIJ
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

altd()

dDatKalk:=date()
cIdKonto:=padr("1320",7)
cIdKonto2:=padr("1310",7)
cIdZaduz2:=cIdZaduz:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to 1;seek cidfirma+"11X"
 skip -1
 if idvd<>"11"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 11 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Magac. konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif
  
  if IsPlanika() .or. gVar13u11=="1"
    @ m_x+4,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  endif
  
  if gNW<>"X"
    @ m_x+4,col()+2 SAY "Zaduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  endif

  cFaktFirma:=cIdFirma
  @ m_x+6,m_y+2 SAY "Broj otpremnice u MP: " GET cFaktFirma
  @ m_x+6,col()+1 SAY "- "+cidtipdok
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

     select PRIPR
     LOCATE FOR BrFaktP==cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     if gVar13u11=="2"  .and. EMPTY(xfakt->idpartner)
       @ m_x+10,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
       read
     endif
     go bottom
     if brdok==cBrKalk; nRbr:=val(Rbr); endif
     select xfakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF
     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA
       hseek xfakt->idroba

       select tarifa
       hseek roba->idtarifa
       select koncij
       seek trim(cidkonto)

       select xfakt
       if alltrim(podbr)=="."  .or. idroba="U"
          skip
          loop
       endif

       select PRIPR
       APPEND BLANK
       cPKonto:=IF(gVar13u11=="1",cidkonto,xfakt->idpartner)
       private aPorezi:={}
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "11",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idtarifa with Tarifa(cPKonto, xfakt->idroba , @aPorezi ),;
               brfaktp with xfakt->brdok,;
               datfaktp with xfakt->datdok,;
               idkonto   with cPKonto ,;
               idzaduz  with cidzaduz,;
               idkonto2  with cidkonto2,;
               idzaduz2  with cidzaduz2,;
               datkurs with xfakt->datdok,;
               kolicina with xfakt->kolicina,;
               idroba with xfakt->idroba,;
               nc  with ROBA->nc,;
               vpc with IF(gVar13u11=="1",xfakt->cijena,KoncijVPC()),;
               rabatv with xfakt->rabat,;
               mpc with xfakt->porez,;
               tmarza2 with "A",;
               tprevoz with "A",;
               mpcsapp with IF(gVar13u11=="1",roba->mpc,xfakt->cijena)

       if gVar13u11=="1"
         replace mpcsapp with UzmiMPCSif()
       endif
       if gVar13u11=="2" .and. EMPTY(xfakt->idpartner)
         replace idkonto with cidkonto
       endif

       PrenPoNar()

       select xfakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
     @ m_x+10,m_y+2 SAY space(40)
  endif

enddo
Boxc()
closeret
return
*}


/*! \fn PrenosMP()
 *  \brief Prenos maloprodajnih kalkulacija FAKT->KALK (11->41)
 */

function PrenosMP()
*{

private cIdFirma:=gFirma
private cIdTipDok:="11"
private cBrDok:=SPACE(8)
private cBrKalk:=SPACE(8)
private cFaktFirma

O_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

dDatKalk:=Date()
cIdKonto:=PADR("1320",7)
cIdZaduz:=SPACE(6)
cBrkalk:=space(8)
cZbirno:="N"


if gBrojac=="D"
	select kalk
 	select kalk
	set order to 1
	seek cIdFirma+"41X"
 	skip -1
 	if idvd<>"41"
   		cBrkalk:=SPACE(8)
 	else
   		cBrKalk:=brdok
 	endif
endif

Box(,15,60)
	if gBrojac=="D"
 		cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
	endif

	do while .t.
		nRBr:=0
  		@ m_x+1,m_y+2 SAY "Broj kalkulacije 41 -" GET cBrKalk pict "@!"
  		@ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  		@ m_x+3,m_y+2 SAY "Konto razduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  		if gNW<>"X"
   			@ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  		endif
        	
 		@ m_x+5,m_y+2 SAY "Napraviti zbirnu kalkulaciju (D/N): " GET cZbirno VALID cZbirno$"DN" PICT "@!"
		read
		
		if cZbirno=="N"
  			cFaktFirma:=cIdFirma
  			@ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  			@ m_x+6,col()+2 SAY "- " + cIdTipDok
  			@ m_x+6,col()+2 SAY "-" GET cBrDok
  			read
  		
			if (LastKey()==K_ESC)
				exit
			endif

			select xfakt
  			seek cFaktFirma + cIdTipDok + cBrDok
  		
			if !Found()
     				Beep(4)
     				@ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     				Inkey(4)
     				@ m_x+14,m_y+2 SAY space(30)
     				loop
  			else
     				aMemo:=parsmemo(txt)
      				if len(aMemo)>=5
        				@ m_x+10,m_y+2 SAY padr(trim(aMemo[3]),30)
        				@ m_x+11,m_y+2 SAY padr(trim(aMemo[4]),30)
        				@ m_x+12,m_y+2 SAY padr(trim(aMemo[5]),30)
      				else
         				cTxt:=""
      				endif
      				if (LastKey()==K_ESC)
					exit
				endif
				cIdPartner:=IdPartner
      				@ m_x+14,m_y+2 SAY "Sifra partnera:" GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
      			
				read

     				select PRIPR
     				locate for BrFaktP=cBrDok 
				// da li je faktura vec prenesena
     				if found()
      					Beep(4)
      					@ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      					inkey(4)
      					@ m_x+8,m_y+2 SAY space(30)
      					loop
     				endif
     				go bottom
     				if brdok==cBrKalk
					nRbr:=val(Rbr)
				endif
     				select xfakt
     				if !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       					MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       					LOOP
     				endif
     				do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       					select ROBA
					hseek xfakt->idroba
       					select tarifa
					hseek roba->idtarifa
       					select xfakt
       					if alltrim(podbr)=="."
          					skip
          					loop
       					endif

       					select PRIPR
       					APPEND BLANK
       					replace idfirma with cIdFirma,rbr with str(++nRbr,3),idvd with "41", brdok with cBrKalk, datdok with dDatKalk, idpartner with cIdPartner, idtarifa with ROBA->idtarifa,	brfaktp with xfakt->brdok, datfaktp with xfakt->datdok, idkonto with cidkonto, idzaduz with cidzaduz, datkurs with xfakt->datdok, kolicina with xfakt->kolicina, idroba with xfakt->idroba, mpcsapp with xfakt->cijena,	tmarza2 with "%"

       					PrenPoNar()

       					select xfakt
      					skip
     				enddo
			
  			endif
		else
			cFaktFirma:=cIdFirma
			cIdTipDok:="11"
			dOdDatFakt:=Date()
			dDoDatFakt:=Date()
			
  			@ m_x+7,m_y+2 SAY "ID firma FAKT: " GET cFaktFirma
			@ m_x+8,m_y+2 SAY "Datum fakture: " 
  			@ m_x+8,col()+2 SAY "od " GET dOdDatFakt
  			@ m_x+8,col()+2 SAY "do " GET dDoDatFakt
  			read
  			
			if (LastKey()==K_ESC)
				exit
			endif

			select xfakt
			
			go top
			
  			do while !eof() 				
				if (idfirma==cFaktFirma .and. idtipdok==cIdTipDok .and. datdok>=dOdDatFakt .and. datdok<=dDoDatFakt)
					cIdPartner:=IdPartner
      					@ m_x+14,m_y+2 SAY "Sifra partnera:" GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
      			
					read

					select pripr
	     				
					go bottom
     			
					if brdok==cBrKalk
						nRbr:=val(Rbr)
					endif
     			
					select xfakt
     			
					if !ProvjeriSif("!eof() .and. '" + cFaktFirma + cIdTipDok + "'==IdFirma+IdTipDok","IDROBA", F_ROBA)
       						MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       						LOOP
     					endif
     			
       					select PRIPR
       					
					append blank
       			
					replace idfirma with cIdFirma, rbr with str(++nRbr,3), idvd with "41", brdok with cBrKalk, datdok with dDatKalk, idpartner with cIdPartner, idtarifa with ROBA->idtarifa, brfaktp with xfakt->brdok, datfaktp with xfakt->datdok, idkonto with cIdKonto, idzaduz with cIdZaduz, datkurs with xfakt->datdok, kolicina with xfakt->kolicina, idroba with xfakt->idroba, mpcsapp with xfakt->cijena, tmarza2 with "%"

					PrenPoNar()

       					select xfakt
      					skip
					loop
     				else
					skip
					loop
				endif
			enddo
     		endif	
		
		@ m_x+10,m_y+2 SAY "Dokument je prenesen !!"
		@ m_x+11,m_y+2 SAY "Obavezno pokrenuti asistenta <a+F10>!!!"
     		if gBrojac=="D"
      			cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
     		endif
     		Inkey(4)
     		@ m_x+10,m_y+2 SAY SPACE(30)
		@ m_x+11,m_y+2 SAY SPACE(40)
	enddo
Boxc()

closeret
return

*}





/*! \fn Prenos01_2()
 *  \brief Prenos FAKT->KALK (01->81)
 */

function Prenos01_2()
*{
local cIdFirma:=gFirma,cIdTipDok:="01",cBrDok:=cBrKalk:=space(8)
O_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

dDatKalk:=date()
cIdKonto:=padr("1320",7)
cIdZaduz:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to 1;seek cidfirma+"81X"
 skip -1
 if idvd<>"81"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 81 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Konto razduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  if gNW<>"X"
   @ m_x+3,col()+2 SAY "Zaduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  endif

  cFaktFirma:=cIdFirma
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
     aMemo:=parsmemo(txt)
      if len(aMemo)>=5
        @ m_x+10,m_y+2 SAY padr(trim(amemo[3]),30)
        @ m_x+11,m_y+2 SAY padr(trim(amemo[4]),30)
        @ m_x+12,m_y+2 SAY padr(trim(amemo[5]),30)
      else
         cTxt:=""
      endif
      cIdPartner:=IdPartner
      @ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
      read

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
     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek xfakt->idroba
       select tarifa; hseek roba->idtarifa

       select xfakt
       if alltrim(podbr)=="."
          skip; loop
       endif

       select PRIPR
       APPEND BLANK
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "81",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idpartner with cIdPartner,;
               idtarifa with ROBA->idtarifa,;
               brfaktp with xfakt->brdok,;
               datfaktp with xfakt->datdok,;
               idkonto   with cidkonto,;
               idzaduz  with cidzaduz,;
               datkurs with xfakt->datdok,;
               kolicina with xfakt->kolicina,;
               idroba with xfakt->idroba,;
               mpcsapp with xfakt->cijena,;
               fcj with xfakt->cijena/(1+tarifa->opp/100)/(1+tarifa->ppp/100),;
               tmarza2 with "%"

       PrenPoNar()

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
Boxc()
closeret
return
*}





/*! \fn Prenos13_2()
 *  \brief Otprema u mp->kalk (13->80) prebaci u prodajni objekt
 */

function Prenos13_2()
*{
local cIdFirma:=gFirma,cIdTipDok:="13",cBrDok:=cBrKalk:=space(8)

O_PRIPR
O_KONCIJ
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

dDatKalk:=date()
cIdKonto:=padr("1320999",7)
cIdKonto2:=padr("1320",7)
cIdZaduz2:=cIdZaduz:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to 1;seek cidfirma+"80X"
 skip -1
 if idvd<>"80"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 80 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Zaduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  endif
  @ m_x+4,m_y+2   SAY "CM. konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+4,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif

  cFaktFirma:=cIdFirma
  @ m_x+6,m_y+2 SAY "Broj otpremnice u MP: " GET cFaktFirma
  @ m_x+6,col()+1 SAY "- "+cidtipdok
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


     select PRIPR
     locate for BrFaktP=cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     if gVar13u11=="2"  .and. EMPTY(xfakt->idpartner)
       @ m_x+10,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
       read
     endif
     go bottom
     if brdok==cBrKalk; nRbr:=val(Rbr); endif
     select xfakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF
     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek xfakt->idroba

       select tarifa; hseek roba->idtarifa
       select koncij; seek trim(cidkonto)

       select xfakt
       if alltrim(podbr)=="."  .or. idroba="U"
          skip; loop
       endif
       cPKonto:=cIdKonto
       private aPorezi:={}
       cIdTarifa:=Tarifa(cPKonto, xfakt->idroba , @aPorezi )
       select PRIPR;       APPEND BLANK
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "80",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idtarifa with cIdTarifa,;
	       brfaktp with xfakt->brdok,;
               datfaktp with xfakt->datdok,;
               idkonto   with cidkonto2,;
               idzaduz  with cidzaduz2,;
               idkonto2  with cidkonto,;
               idzaduz2  with cidzaduz,;
               datkurs with xfakt->datdok,;
               kolicina with -xfakt->kolicina,;
               idroba with xfakt->idroba,;
               nc with xfakt->cijena/(1+tarifa->opp/100)/(1+tarifa->ppp/100),;
               mpc with 0,;
               tmarza2 with "A",;
               tprevoz with "A",;
               mpcsapp with xfakt->cijena

       PrenPoNar()

       APPEND BLANK // protustavka
       replace idfirma with cIdFirma,;
               rbr     with str(nRbr,3),;
               idvd with "80",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idtarifa with cIdTarifa,;
               brfaktp with xfakt->brdok,;
               datfaktp with xfakt->datdok,;
               idkonto   with cidkonto,;
               idzaduz  with cidzaduz,;
               idkonto2  with "XXX",;
               idzaduz2  with "",;
               datkurs with xfakt->datdok,;
               kolicina with xfakt->kolicina,;
               idroba with xfakt->idroba,;
               nc with xfakt->cijena/(1+tarifa->opp/100)/(1+tarifa->ppp/100),;
               mpc with 0,;
               tmarza2 with "A",;
               tprevoz with "A",;
               mpcsapp with xfakt->cijena

       PrenPoNar()

       select xfakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
     @ m_x+10,m_y+2 SAY space(40)
  endif

enddo
Boxc()
closeret
return
*}




/*! \fn Prenos15()
 *  \brief Izlaz iz MP putem VP, FAKT15->KALK15
 */

function Prenos15()
*{
local cIdFirma:=gFirma,cIdTipDok:="15",cBrDok:=cBrKalk:=space(8)
local dDatPl:=ctod("")
local fDoks2:=.f.

O_PRIPR
O_KONCIJ
O_KALK
if file(KUMPATH+"DOKS2.DBF"); fDoks2:=.t.; O_DOKS2; endif
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

dDatKalk:=date()
cIdKonto:=padr("1320",7)
cIdKonto2:=padr("1310",7)
cIdZaduz2:=cIdZaduz:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to 1;seek cidfirma+"15X"
 skip -1
 if idvd<>"15"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 15 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Magac. konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif
  @ m_x+4,m_y+2   SAY "Prodavn. konto razduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  if gNW<>"X"
    @ m_x+4,col()+2 SAY "Zaduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  endif

  cFaktFirma:=cIdFirma
  @ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  @ m_x+6,col()+1 SAY "- "+cidtipdok
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
     READ; ESC_BCR

     SELECT PRIPR
     LOCATE FOR BrFaktP=cBrDok // faktura je vec prenesena
     IF FOUND()
       Beep(4)
       @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
       INKEY(4)
       @ m_x+8,m_y+2 SAY SPACE(30)
       LOOP
     ENDIF

     GO BOTTOM
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
        select xFakt
     endif

     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek xfakt->idroba

       select tarifa; hseek roba->idtarifa
       select koncij; seek trim(cidkonto)

       SELECT XFAKT
       IF ALLTRIM(podbr)=="."  .or. idroba="U"
          SKIP
          LOOP
       ENDIF

       select PRIPR
       APPEND BLANK
       replace idfirma   with cIdFirma      ,;
               rbr       with str(++nRbr,3)   ,;
               idvd      with "15"            ,;   // izlaz iz MP putem VP
               brdok     with cBrKalk         ,;
               datdok    with dDatKalk        ,;
               idtarifa  with ROBA->idtarifa  ,;
               brfaktp   with xfakt->brdok    ,;
               datfaktp  with xfakt->datdok   ,;
               idkonto   with cidkonto        ,;
                pkonto    with cIdKonto        ,;
                 pu_i      with "1"             ,;
               idzaduz   with cidzaduz        ,;
               idkonto2  with cidkonto2       ,;
                mkonto    with cIdKonto2       ,;
                 mu_i      with "8"             ,;
               idzaduz2  with cidzaduz2       ,;
               datkurs   with xfakt->datdok   ,;
               kolicina  with -xfakt->kolicina ,;
               idroba    with xfakt->idroba   ,;
               nc        with ROBA->nc        ,;
               vpc       with KoncijVPC()     ,;
               rabatv    with xfakt->rabat    ,;
               mpc       with xfakt->porez    ,;
               tmarza2   with "A"             ,;
               tprevoz   with "R"             ,;
               idpartner with cIdPartner      ,;
               mpcsapp   with xfakt->cijena

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
     @ m_x+10,m_y+2 SAY space(40)
  endif

enddo
Boxc()
closeret
return
*}


/*! \fn PrenosMP2()
 *  \brief Prenos maloprodajnih kalkulacija FAKT->KALK (11->42)
 */

function PrenosMP2()
*{

private cIdFirma:=gFirma
private cIdTipDok:="11"
private cBrDok:=SPACE(8)
private cBrKalk:=SPACE(8)
private cFaktFirma

O_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

dDatKalk:=Date()
cIdKonto:=PADR("1320",7)
cIdZaduz:=SPACE(6)
cBrkalk:=space(8)
cZbirno:="D"


if gBrojac=="D"
	select kalk
 	select kalk
	set order to 1
	seek cIdFirma+"42X"
 	skip -1
 	if idvd<>"42"
   		cBrkalk:=SPACE(8)
 	else
   		cBrKalk:=brdok
 	endif
endif

Box(,15,60)
	if gBrojac=="D"
 		cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
	endif

	do while .t.
		nRBr:=0
  		@ m_x+1,m_y+2 SAY "Broj kalkulacije 42 -" GET cBrKalk pict "@!"
  		@ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  		@ m_x+3,m_y+2 SAY "Konto razduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  		if gNW<>"X"
   			@ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  		endif
        	
 		@ m_x+5,m_y+2 SAY "Napraviti zbirnu kalkulaciju (D/N): " GET cZbirno VALID cZbirno$"DN" PICT "@!"
		read
		
		if cZbirno=="N"
  			cFaktFirma:=cIdFirma
  			@ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  			@ m_x+6,col()+2 SAY "- " + cIdTipDok
  			@ m_x+6,col()+2 SAY "-" GET cBrDok
  			read
  		
			if (LastKey()==K_ESC)
				exit
			endif

			select xfakt
  			seek cFaktFirma + cIdTipDok + cBrDok
  		
			if !Found()
     				Beep(4)
     				@ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     				Inkey(4)
     				@ m_x+14,m_y+2 SAY space(30)
     				loop
  			else
     				aMemo:=parsmemo(txt)
      				if len(aMemo)>=5
        				@ m_x+10,m_y+2 SAY padr(trim(aMemo[3]),30)
        				@ m_x+11,m_y+2 SAY padr(trim(aMemo[4]),30)
        				@ m_x+12,m_y+2 SAY padr(trim(aMemo[5]),30)
      				else
         				cTxt:=""
      				endif
      				if (LastKey()==K_ESC)
					exit
				endif
				cIdPartner:=""

     				select PRIPR
     				locate for BrFaktP=cBrDok 
				// da li je faktura vec prenesena
     				if found()
      					Beep(4)
      					@ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      					inkey(4)
      					@ m_x+8,m_y+2 SAY space(30)
      					loop
     				endif
     				go bottom
     				if brdok==cBrKalk
					nRbr:=val(Rbr)
				endif
     				select xfakt
     				if !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       					MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       					LOOP
     				endif
     				do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       					select ROBA
					hseek xfakt->idroba
       					select tarifa
					hseek roba->idtarifa
       					select xfakt
       					if alltrim(podbr)=="."
          					skip
          					loop
       					endif

       					select PRIPR
					private aPorezi:={}
					Tarifa(cIdKonto,xfakt->idRoba,@aPorezi)
					nMPVBP:=MpcBezPor(xfakt->(kolicina*cijena),aPorezi)
       					APPEND BLANK
       					replace idfirma with cIdFirma,rbr with str(++nRbr,3),idvd with "42", brdok with cBrKalk, datdok with dDatKalk, idpartner with cIdPartner, idtarifa with ROBA->idtarifa,	brfaktp with xfakt->brdok, datfaktp with xfakt->datdok, idkonto with cidkonto, idzaduz with cidzaduz, datkurs with xfakt->datdok, kolicina with xfakt->kolicina, idroba with xfakt->idroba, mpcsapp with xfakt->cijena,	tmarza2 with "%"
					replace rabatv with nMPVBP*xfakt->rabat/(xfakt->kolicina*100)
       					PrenPoNar()

       					select xfakt
      					skip
     				enddo
			
  			endif
		else
			cFaktFirma:=cIdFirma
			cIdTipDok:="11"
			dOdDatFakt:=Date()
			dDoDatFakt:=Date()
			
  			@ m_x+7,m_y+2 SAY "ID firma FAKT: " GET cFaktFirma
			@ m_x+8,m_y+2 SAY "Datum fakture: " 
  			@ m_x+8,col()+2 SAY "od " GET dOdDatFakt
  			@ m_x+8,col()+2 SAY "do " GET dDoDatFakt
  			read
  			
			if (LastKey()==K_ESC)
				exit
			endif

			select xfakt
			
			go top
			
  			do while !eof() 				
				if (idfirma==cFaktFirma .and. idtipdok==cIdTipDok .and. datdok>=dOdDatFakt .and. datdok<=dDoDatFakt)
					cIdPartner:=""

					select pripr
	     				
					go bottom
     			
					if brdok==cBrKalk
						nRbr:=val(Rbr)
					endif
     			
					select xfakt
     			
					if !ProvjeriSif("!eof() .and. '" + cFaktFirma + cIdTipDok + "'==IdFirma+IdTipDok","IDROBA", F_ROBA)
       						MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       						LOOP
     					endif
     			
       					select PRIPR
       					
					private aPorezi:={}
					Tarifa(cIdKonto,xfakt->idRoba,@aPorezi)
					nMPVBP:=MpcBezPor(xfakt->(kolicina*cijena),aPorezi)
					append blank
       			
					replace idfirma with cIdFirma, rbr with str(++nRbr,3), idvd with "42", brdok with cBrKalk, datdok with dDatKalk, idpartner with cIdPartner, idtarifa with ROBA->idtarifa, brfaktp with xfakt->brdok, datfaktp with xfakt->datdok, idkonto with cIdKonto, idzaduz with cIdZaduz, datkurs with xfakt->datdok, kolicina with xfakt->kolicina, idroba with xfakt->idroba, mpcsapp with xfakt->cijena, tmarza2 with "%"
					replace rabatv with nMPVBP*xfakt->rabat/(xfakt->kolicina*100)
					PrenPoNar()

       					select xfakt
      					skip
					loop
     				else
					skip
					loop
				endif
			enddo
     		endif	
		
		@ m_x+10,m_y+2 SAY "Dokument je prenesen !!"
		@ m_x+11,m_y+2 SAY "Obavezno pokrenuti asistenta <a+F10>!!!"
     		if gBrojac=="D"
      			cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
     		endif
     		Inkey(4)
     		@ m_x+10,m_y+2 SAY SPACE(30)
		@ m_x+11,m_y+2 SAY SPACE(40)
	enddo
Boxc()

closeret
return

*}

