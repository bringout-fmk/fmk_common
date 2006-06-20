#include "sc.ch"


// ------------------------------
// parametri generacije ugovora
// ------------------------------
static function g_ug_params(cUPartner, dDatDok, cFUArtikal, cSamoAktivni, nN1, nN2, nN3)
private cSection:="U"
private cHistory:=" "
private aHistory:={}

O_PARAMS

dDatDok:=ctod("")
cFUArtikal:=SPACE(LEN(ROBA->id))
cSamoAktivni:="D"
nN1 := 0
nN2 := 0
nN3 := 0

if gVFU == "1"
	cUPartner := SPACE(16)
else
	cUPartner := SPACE(20)
endif

RPar("uP",@cUPartner)
RPar("dU",@dDatDok)
RPar("P1",@nN1)
RPar("P2",@nN2)
RPar("P3",@nN3)
RPar("P4",@cFUArtikal)
RPar("P5",@cSamoAktivni)

Box("#PARAMETRI ZA GENERACIJU FAKTURA PO UGOVORIMA",7,70)

@ m_x+1, m_y+2 SAY "Datum fakture" GET dDAtDok

@ m_x+3, m_y+2 SAY "Parametar N1" GET nN1 PICT "99999.999"
@ m_x+4, m_y+2 SAY "Parametar N2" GET nN2 PICT "99999.999"
@ m_x+5, m_y+2 SAY "Parametar N3" GET nN3 PICT "99999.999"

@ m_x+7, m_y+2 SAY "Generisati fakture samo na osnovu aktivnih ugovora? (D/N)" GET cSamoAktivni VALID cSamoAktivni$"DN" PICT "@!"

read
BoxC()

ESC_RETURN 0

WPar("uP",cUPartner)
WPar("dU",dDatDok)
WPar("P1",nN1)
WPar("P2",nN2)
WPar("P3",nN3)
WPar("P4",cFUArtikal)
WPar("P5",cSamoAktivni)
use

return 1


// -------------------------------------------
// generacija ugovora - varijanta 2
// -------------------------------------------
function gen_ug_2()
local lSumirajSifru
local lSamoAktivni
local nDokGen
local cUPartner
local dDatDok
local cFUArtikal
local cSamoAktivni
local nN1
local nN2
local nN3

// otvori tabele
o_ugov()

// otvori parametre generacije
if g_ug_params(@cUPartner, @dDatDok, @cFUArtikal, @cSamoAktivni, @nN1, @nN2, @nN3) == 0
	return
endif

nDokGen:=val(IzFMkIni('Fakt_Ugovori',"Dokumenata_Izgenerisati",'1'))

if nDokgen=0
	nDokGen:=1
endif

lSamoAktivni := (cSamoAktivni == "D")
lSumirajSifru := IzFMKIni('FAKT_Ugovori',"SumirajIstuSifru",'D') == "D" 

SELECT UGOV

if lSamoAktivni
	set filter to aktivan=="D"
endif

GO TOP

for nTekUg:=1 to nDokGen

	SELECT UGOV

	if nTekUg=1
  		cUPartner:=LEFT(cUPartner,IF(gVFU=="1",15,19))+chr(254)
	else
  		// ne browsaj
  		skip 1 // saltaj ugovore
  		IF EOF()
			EXIT
		ENDIF
	endif

	if empty(cUPartner)
  		exit
	endif

	if nTekug=1 // kada je vise ugovora, samo prvi browsaj
		P_ugov(cUPartner)
	endif

	IF gVFU=="1"
  		cUPartner:=ugov->(id+idpartner)
	ELSE
  		cUPartner:=ugov->(naz)
	ENDIF

	O_FAKT
	O_PRIPR

	if reccount2()<>0 .and. nTekug=1
  		Msg("Neki dokument vec postoji u pripremi")
  		closeret
	endif

	SELECT PRIPR

    	cIdTipdok:=ugov->idtipdok

   	select pripr
   	seek gFirma+cidtipdok+"È"
   	skip -1
   	if idtipdok <> cIdTipdok
     		seek "È" // idi na kraj, nema zeljenih dokumenata
   	endif

   	select fakt
   	seek gFirma+cidtipdok+"È"
   	skip -1

   	if idtipdok <> cIdTipdok
     		seek "È" // idi na kraj, nema zeljenih  dokumenata
   	endif	

   	if pripr->brdok > fakt->brdok
     		select pripr  // odaberi tabelu u kojoj ima vise dokumenata
   	endif

	if cidtipdok<>idtipdok
      		cBrDok:=UBrojDok(1,gNumDio,"")
   	else
      		cBrDok:=UBrojDok( val(left(brdok,gNumDio))+1, gNumDio, ;
                        right(brdok,len(brdok)-gNumDio))
   	endif

	select ugov
	
	if lSamoAktivni .and. aktivan!="D"
		if nTekUg > 2 
    			--nTekUg
    		endif
    		loop
	endif

	// prvi krug odredjuje glavnicu
	nGlavnica:=0  
	nRbr:=0
	cIdUgov:=id
	select rugov
	seek cIdUgov

	
	// jedna stavka moze biti glavnica za ostale
	do while !eof() .and. ( id == cIdUgov )
   		select roba
		hseek rugov->idroba
   		select rugov
   		if K1=="G"
			// nGlavnica+=kolicina*roba->vpc
     			nGlavnica+=kolicina * 10
   		endif
   		skip
	enddo

	seek cIdUgov

	do while !eof() .and. (id == cIdUgov)

		nCijena:=0
		
		SELECT PRIPR
		
		IF lSumirajSifru .and. (IdFirma+idtipdok+brdok+idroba == gFirma+cIDTipDok+PADR(cBrDok,LEN(brdok))+RUGOV->idroba)
		
     			Scatter()
     			_kolicina += RUGOV->kolicina
     			Gather()
     			SELECT RUGOV
			SKIP 1
			LOOP
   		
		ELSE
     			append blank
			Scatter()
   		ENDIF

		if nRbr == 0
    			select PARTN
			hseek ugov->idpartner
    			_txt3b:=_txt3c:=""
    			_txt3a:=ugov->idpartner+"."
    			IzSifre()
    			select ftxt
			hseek ugov->iddodtxt
			cDodTxt:=TRIM(naz)
    			hseek ugov->idtxt
    			private _Txt1:=""
			select roba
			hseek rugov->idroba
    			if roba->tip=="U"
      				_txt1:=roba->naz
    			else
     				_txt1:=" "
    			endif
    			IF IzFMKINI("Fakt_Ugovori","UNapomenuSamoBrUgovora","D")=="D"
      				cVezaUgovor := "Veza: "+trim(ugov->id)
    			ELSE
      				cVezaUgovor := "Veza: UGOVOR: "+trim(ugov->id)+" od "+dtoc(ugov->datod)
    			ENDIF
    			_txt:=Chr(16)+_txt1 +Chr(17)+;
         		Chr(16)+trim(ftxt->naz)+chr(13)+chr(10)+;
         		cVezaUgovor+chr(13)+chr(10)+;
         		cDodTxt+Chr(17)+Chr(16)+_Txt3a+;
			Chr(17)+ Chr(16)+_Txt3b+Chr(17)+;
         		Chr(16)+_Txt3c+Chr(17)
		endif
		select pripr
		
		private nKolicina:=rugov->kolicina
		
		if rugov->k1="A"  
			
			// onda je kolicina= A2-A1  
			// (novo stanje - staro stanje)
      			
			nA2:=0
      			Box(,5,60)
        		@ m_y+1,m_y+2 say ugov->naz
        		@ m_x+3,m_y+2 SAY "A: Stara vrijednost:"
			?? ugov->A2
        		@ m_x+5,m_y+2 SAY "A: Nova vrijednost (0 ne mjenjaj):" GET nA2 pict "999999.99"
        		read
      			BoxC()
      			if nA2<>0
        	 		select ugov
         			replace a1 with a2 
				replace a2 with nA2
         			select pripr
      			endif

      			nKolicina:=ugov->(a2-a1)
   		
		elseif rugov->k1="B"
      			
			nB2:=0
      			Box(,5,60,,ugov->naz)
        		@ m_x+1,m_y+2 say ugov->naz
        		@ m_x+3,m_y+2 SAY "B: Stara vrijednost:"; ?? ugov->B2
        		@ m_x+5,m_y+2 SAY "B: Nova vrijednost (0 ne mjenjaj):" GET nB2 pict "999999.99"
        		read
      			BoxC()
      			if nB2<>0
         			select ugov
         			replace B1 with B2 
				replace B2 with nB2
         			select pripr
      			endif
      			nKolicina:=ugov->(b2-b1)
   		
		elseif rugov->k1="%"  
			// procenat na neku stavku
      			nKolicina:=1
      			nCijena:=rugov->kolicina*nGlavnica/100
   		
		elseif rugov->k1="1"   
			// kolicinu popunjava ulazni parametar n1
       			nKolicina:=nN1
   		
		elseif rugov->k1="2"   
			// kolicinu popunjava ulazni parametar n2
       			nKolicina:=nN2
   		
		elseif rugov->k1="3"   
			// kolicinu popunjava ulazni parametar n3
       			nKolicina:=nN3
   		endif

   		private _Txt1:=""

   		select roba
		hseek rugov->idroba
   
   		if nRbr<>0 .and. roba->tip=="U"
      			_txt1:=roba->naz
     			 _txt:=Chr(16)+_txt1 +Chr(17)
   		endif

   		_idfirma:= gFirma
  		_zaokr:=ugov->zaokr
   		_rbr:=str(++nRbr,3)
   		_idtipdok:=cidtipdok
   		_brdok:=cBrDok
   		_datdok:=dDatDok
   		_datpl:=dDatDok
   		_kolicina:=nKolicina
   		_idroba:=rugov->idroba
   		
		select roba
		hseek _idroba

   		Odredi_IDROBA()

   		SELECT PRIPR
	
		_cijena := rugov->cijena
		
		// uzmi cijenu iz RUGOV
		if _cijena == 0
   			setujcijenu()
		endif
		
		if nCijena <> 0
     			_cijena := nCijena
   		endif
   		
		_rabat:=rugov->rabat
   		_porez:=rugov->porez
   		_dindem:=ugov->dindem
   		
		select pripr
   		Gather()
		select rugov
   		skip
	enddo
next

closeret
return


