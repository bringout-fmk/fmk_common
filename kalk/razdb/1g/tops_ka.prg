#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/razdb/1g/tops_ka.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.11 $
 * $Log: tops_ka.prg,v $
 * Revision 1.11  2004/05/28 14:52:11  sasavranic
 * no message
 *
 * Revision 1.10  2003/12/22 14:59:00  sasavranic
 * Uslov za sortiranje rednih brojeva u pripremi...varijanta Jerry
 *
 * Revision 1.9  2003/12/08 11:37:17  sasavranic
 * Ispravljen bug: pri preuzimanju podataka iz tops-a, lReplace nepostojeca var
 *
 * Revision 1.8  2003/11/29 13:49:02  sasavranic
 * Dorade: preuzimanje barkodova pri preuzimanju realizacije iz kalk-a
 *
 * Revision 1.7  2002/07/31 09:55:32  mirsad
 * broj 11-ke koja se formira pri TOPS42->KALK sada se odredjuje na osnovu
 * azuriranih 11-ki a ne 42-ki
 *
 * Revision 1.6  2002/07/31 08:27:04  mirsad
 * omoguæeno vezivanje varijante TOPS->KALK za prod.mjesto
 *
 * Revision 1.5  2002/06/24 09:28:08  mirsad
 * dokumentovanje
 *
 * Revision 1.4  2002/06/24 08:02:27  ernad
 *
 *
 * topska->kolicina<>0
 *
 * Revision 1.3  2002/06/24 07:46:28  ernad
 *
 *
 * kada je topska->kolicina==0 ne prenosi
 *
 * Revision 1.2  2002/06/24 07:39:28  ernad
 *
 *
 * doxy
 *
 *
 */


/*! \file fmk/kalk/razdb/1g/tops_ka.prg
 *  \brief Preuzimanje dokumenata iz TOPS-a u KALK
 */



/*! \ingroup ini
  * \var *string FmkIni_KumPath_POS42uKALK11_Kase
  * \brief Definise koja prodajna mjesta se retroaktivno zaduzuju samo za prodate kolicine
  * \param  - prazno, sva prodajna mjesta, default vrijednost
  * \param  1 - samo prodajno mjesto " 1"
  * \param  1 3 - prodajna mjesta " 1" i " 3"
  */
*string FmkIni_KumPath_POS42uKALK11_Kase;


/*! \fn UzmiIzTopsa()
 *  \brief Preuzimanje podataka iz datoteke TOPSKA te generisanje dokumenta 42 ili 11 (SOFA Vitez)
 */


#define D_MAX_FILES     150


function UzmiIzTopsa()
*{
local Izb3
local OpcF
LOCAL aPom1:={}, aPom2:={}
private HH

l42u11:=( IzFMKINI("KALK","POS42uKALK11","N") == "D" )

// primjer matrice:
// [TOPSuKALK]    |=CHR(124)
// UslovKontoIMarkerZaRazvrstReal=left(idroba,2)="90"|1320KF|KF;left(idroba,2)="91"|1320KF2|KF2
// ----------------------------------------
cRazdvoji := IzFMKIni("TOPSuKALK","UslovKontoIMarkerZaRazvrstReal","-",KUMPATH)

IF cRazdvoji<>"-"
  // razdvajanje realizacije na viçe konta
  // -------------------------------------
  lRazdvoji:=.t.
  aRazdvoji := TOKuNIZ(cRazdvoji,";","|")
  AADD(aRazdvoji,{".t.","","",0})
  FOR i:=1 TO LEN(aRazdvoji)
    DO WHILE LEN(aRazdvoji[i])<4
      DO CASE
        CASE LEN( aRazdvoji[i] ) < 1
                                     AADD( aRazdvoji[i] , ".t." )
        CASE LEN( aRazdvoji[i] ) < 2
                                     AADD( aRazdvoji[i] , "" )
        CASE LEN( aRazdvoji[i] ) < 3
                                     AADD( aRazdvoji[i] , "" )
        CASE LEN( aRazdvoji[i] ) < 4
                                     AADD( aRazdvoji[i] , 0 )
      ENDCASE
    ENDDO
  NEXT
ELSE
  // standardni prenos
  // -----------------
  lRazdvoji:=.f.
ENDIF

O_KONCIJ
go top

if gModemVeza=="D"
	OPCF:={}

 	select koncij
 	do while !eof()
    
  		if !empty(IdProdmjes)
   			BrisiSFajlove(trim(gTopsDest)+trim(koncij->IdProdmjes)+"\")
   			BrisiSFajlove(strtran(trim(gTopsDest)+trim(koncij->IdProdmjes)+"\",":\",":\chk\"))

   			aFiles:=DIRECTORY(trim(gTopsDest)+trim(koncij->IdProdmjes)+"\TK*.dbf")
   			ASORT(aFiles,,,{|x,y| x[3]>y[3]})
			AEVAL(aFiles,  {|elem| AADD(opcF,PADR(trim(koncij->IdProdmjes)+"\"+trim(elem[1]),15)+iif(UChkPostoji(trim(gTopsDest)+trim(koncij->IdProdmjes)+"\"+trim(elem[1])),"R","X")+" "+dtos(elem[3]))},1,D_MAX_FILES)  
  		endif
  		skip
 	enddo

 	ASORT(OPCF,,,{|x,y| right(x,10)>right(y,10)})  // datumi
 	hh:=ARRAY(LEN(OPCF))
 	for i:=1 to len(hh)
   		hh[i]:=""
 	next
 	if len(opcf)==0
   		MsgBeep("U direktoriju za prenos nema podataka")
   		closeret
 	endif
else
	MsgBeep("Pripremi disketu za prenos ....#te pritisni nesto za nastavak")
endif

O_ROBA
O_TARIFA
O_PRIPR
O_KALK

if gModemVeza=="D"
	Izb3:=1
  	fPrenesi:=.f.
  	do while .t.
   		Izb3:=Menu("izdat",opcF,Izb3,.f.)
		if Izb3==0
     			exit
   		else
     			cTopsDBF:=trim(gTopsDEST)+trim(left(opcf[Izb3],15))
     			save screen to cS
     			Vidifajl(strtran(ctopsDBF,".DBF",".TXT"))  // vidi TK1109.TXT
     			restore screen from cS
     			if Pitanje(,"Zelite li izvrsiti prenos ?","D")=="D"
         			fPrenesi:=.t.
         			Izb3:=0
     			else
         			// close all // vrati se u petlju
         			loop
     			endif
   		endif
  	enddo
  	if !fprenesi
        	return .f.
  	endif
else
	// CRC gledamo ako nije modemska veza
 	cTOPSDBF:=trim(gTopsDEST)+"TOPSKA"
 	aPom1 := IscitajCRC( trim(gTopsDest)+"CRCTK.CRC" )
 	aPom2 := IntegDBF(cTopsDBF)
	IF !(aPom1[1]==aPom2[1] .and. aPom1[2]==aPom2[2])
   		Msg("CRCTK.CRC se ne slaze. Greska na disketi !",4)
   		CLOSERET
 	ENDIF
endif

usex (cTopsDBF) NEW alias TOPSKA

go bottom
cBRKALK:=left(strtran(dtoc(datum),".",""),4) + "/" + idpos
// dobija se broj u formi 1210/1     - 1210 - posljednji, najveci datum
cIdVd := TOPSKA->IdVd

if (l42u11)
	cPom:=IzFmkIni("POS42uKALK11","Kase"," ",KUMPATH)
	if !(EMPTY(cPom) .or. topska->idPos$cPom)
		l42u11:=.f.
	endif
endif

IF cIdVD=="42" .and. l42u11
	O_KONTO
  	cIdKonto2:=PADR("1310",7)
  	Box(,3,60)
  		@ m_x+2, m_y+2 SAY "Magacinski konto:" GET cIdKonto2 VALID P_Konto(@cIdKonto2)
  		READ
  	BoxC()
ENDIF

select koncij
locate for idprodmjes==topska->idpos
if !found()
	MsgBeep("U sifrarniku KONTA-TIPOVI CIJENA nije postavljeno#nigdje prodajno mjesto :"+idProdMjes+"#Prenos nije izvrsen.")
  	closeret
endif

select kalk
IF (cIdVD=="42" .and. l42u11)
	seek gFirma+"11"+"X"
  	skip -1
  	if idvd<>"11"
    		cBrKalk:=space(8)
  	else
    		cBrKalk:=brdok
  	endif
  	cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
ELSE
  	seek gfirma+cIdVd+cBRKALK
  	if found()
		Msg("Vec postoji dokument pod brojem "+gfirma+"-"+cIdVd+"-"+cbrkalk+"#Prenos nece biti izvrsen")
		closeret
	endif
ENDIF

select topska
go top
if topska->(FieldPos("barkod"))<>0
	if Pitanje(,"Mjenjati barkod-ove ?","N")=="D"
		lReplace:=.t.
		nReplaceBK:=0
	else
		lReplace:=.f.
	endif
	if lReplace .and. Pitanje(,"Mjenjati sve barkod-ove bez provjere ?","N")=="D"
		lReplaceAll:=.t.
	else
		lReplaceAll:=.f.
	endif
else
	lReplace:=.f.
endif

lSortNR:=.f.

if IsJerry()
	if Pitanje(,"Napraviti sort rednih brojeva","D")=="D"
		select pripr
		go bottom
		lSortNR:=.t.
		nSortNR:=VAL(pripr->rbr)
		go top
		cKalkulacija:=SPACE(8)
		Box(,4,60)
		@ 1+m_x, 2+m_y SAY "Uslov za sortiranje rednih brojeva:"
		@ 2+m_x, 2+m_y SAY "Zadnji redni broj u pripremi: " GET nSortNr PICT "999"
		@ 3+m_x, 2+m_y SAY "0 - od pocetka"
		@ 4+m_x, 2+m_y SAY "Priljepi na broj dokumenta: " GET cKalkulacija
		read
		BoxC()
		if LastKey()==K_ESC
			return
		endif
	endif
endif

nRbr:=0
do while !eof()
	if lRazdvoji
    		FOR i:=1 TO LEN(aRazdvoji)
      			cPom := aRazdvoji[i,1]
      			IF &cPom
        			cBrDok    := TRIM(cBrKalk)+aRazdvoji[i,3]
        			cIdKonto  := aRazdvoji[i,2]
        			IF EMPTY(cIdKonto)
					cIdKonto := KONCIJ->id
				ENDIF
        			aRazdvoji[i,4] := aRazdvoji[i,4]+1
        			cRBr      := STR(aRazdvoji[i,4],3)
        			EXIT
      			ENDIF
    		NEXT
  	else
    		cBrDok    := cBrKalk
    		cIdKonto  := KONCIJ->id
    		if IsJerry() .and. lSortNR
			cRbr:=STR(++nSortNr,3)
			if !EMPTY(cKalkulacija)
				cBrDok:=cKalkulacija
			endif
			if nSortNr>0
				select pripr
				go bottom
			endif
		else
			cRBr      := STR(++nRBr,3)
		endif
  	endif
	
	IF cIdVd=="42" .and. l42u11
		// formiraj 11-ku umjesto 42-ke
		if (topska->kolicina<>0)
			SELECT pripr
			APPEND BLANK
			replace idfirma  with gfirma          ,;
			idvd     with "11"            ,;
			brdok    with cBrDok          ,;
			datdok   with topska->datum   ,;
			datfaktp with topska->datum   ,;
			kolicina with topska->kolicina,;
			idkonto  with cIdKonto        ,;
			idkonto2 with cIdKonto2       ,;
			idroba   with topska->idroba  ,;
			rbr      with cRBr            ,;
			tmarza2  with "%"             ,;
			idtarifa with topska->idtarifa,;
			mpcsapp  with topska->(mpc-stmpc),;
			tprevoz  with "R"
			if IsTehnoprom()
				replace idpartner with topska->idpartner
			endif
		endif
	else
		if (topska->kolicina<>0)		
			SELECT pripr
			APPEND BLANK
			replace idfirma  with gfirma          ,;
			idvd     with topska->IdVd    ,;
			brdok    with cBrDok          ,;
			datdok   with topska->datum   ,;
			datfaktp with topska->datum   ,;
			kolicina with topska->kolicina,;
			idkonto  with cIdKonto        ,;
			idroba   with topska->idroba  ,;
			rbr      with cRBr            ,;
			tmarza2  with "%"             ,;
			idtarifa with topska->idtarifa,;
			mpcsapp  with topska->mpc     ,;
			RABATV   with topska->stmpc
			if (cIdVd=="19")
				REPLACE fcj with topska->stmpc
			endif
			if IsTehnoprom()
				replace idpartner with topska->idpartner
			endif
		endif
	endif
  	
	// a sada barkod ako ga ima
	if lReplace
	    	select roba
	   	set order to tag "ID"
	    	seek topska->idroba
	    	if Found()
	    		cBarKod:=roba->barkod
			if !EMPTY(topska->barkod) .and. topska->barkod<>cBarKod
				MsgBeep("Postoji promjena barkod-a:##Artikal: "+ ALLTRIM(roba->id) + "-" + ALLTRIM(roba->naz) + "##KALK barkod -> " + roba->barkod + "##TOPS barkod -> " + topska->barkod)
				if lReplaceAll .or. Pitanje(,"Zamjeniti barkod u sifrarniku ?","N")=="D"
					replace roba->barkod with topska->barkod
					++nReplaceBK
				endif
			endif
	    	endif
	endif

	select topska
  	skip
enddo

close all

if (lReplace .and. nReplaceBK > 0)
	MsgBeep("Zamjena izvrsena na " + ALLTRIM(STR(nReplaceBK)) + " polja barkod !")
endif

if gModemVeza=="D" .and. fPrenesi
    dirmak2(strtran(trim(gTopsDest),":\",":\chk\"))
    copy file (cTopsDbf) TO (strtran(cTopsDbf,":\",":\chk\"))
    // odradjeno-postavi kopiraj u chk direktorij
endif

IF IzFMKINI("KALK","PrimPak","N",KUMPATH)=="D"
  NaPrPak2()
ENDIF

return
*}


 /*! \fn UChkPostoji(cFullFileName)
  *  \brief Da li u chk direktoriju postoji fajl
  *  \code
  *   UChkPostoji(gKalkDest+"KT1105.DBF")
  *  \endcode
  */
function UChkPostoji(cFullFileName)
*{
if File(strtran(cFullFileName,":\",":\chk\"))
   return .t.
else
   return .f.
endif
*}

