#include "\cl\sigma\fmk\fin\fin.ch"
 /*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rpt/1g/rpt_dug.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.5 $
 * $Log: rpt_dug.prg,v $
 * Revision 1.5  2004/02/09 11:09:37  sasavranic
 * Ispravljen uslov za opcinu na "F. pregled dugovanja partnera"
 *
 * Revision 1.4  2004/01/13 19:07:57  sasavranic
 * appsrv konverzija
 *
 *
 */


/*! \file fmk/fin/rpt/1g/rpt_dug.prg
 *  \brief Dugovanja partnera
 */

/*! \fn SpecDugPartnera()
 *  \brief Specifikacija dugovanja partnera
 */

function SpecDugPartnera()
*{
local nCol1:=72
local cSvi:="N"
private cIdPartner

cDokument:=SPACE(8)
picBHD:=FormPicL(gPicBHD,14)
picDEM:=FormPicL(gPicDEM,10)

IF gVar1=="0"
	m:="----------- ------------- -------------- -------------- ---------- ---------- ---------- -------------------------"
ELSE
 	m:="----------- ------------- -------------- -------------- -------------------------"
ENDIF

m := "-------- -------- " + m

nStr:=0
fVeci:=.f.
cPrelomljeno:="N"

O_SUBAN
O_PARTN
O_KONTO

cIdFirma:=gFirma
cIdkonto:=space(7)
cIdPartner:=space(6)
dNaDan:=DATE()
cOpcine:=SPACE(20)
cSaRokom:="D"
nDoDana1:=8
nDoDana2:=15
nDoDana3:=30
nDoDana4:=60

PICPIC:="9999999999.99"

Box(,11,60)
if gNW=="D"
      	@ m_x+1,m_y+2 SAY "Firma "
	?? gFirma,"-",gNFirma
else
	@ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+2,m_y+2 SAY "Konto:               " GET cIdkonto   pict "@!"  valid P_konto(@cIdkonto)
@ m_x+3,m_y+2 SAY "Izvjestaj se pravi na dan:" GET dNaDan
@ m_x+4,m_y+2 SAY "Interval 1: do (dana)" GET nDoDana1 PICT "999"
@ m_x+5,m_y+2 SAY "Interval 2: do (dana)" GET nDoDana2 PICT "999"
@ m_x+6,m_y+2 SAY "Interval 3: do (dana)" GET nDoDana3 PICT "999"
@ m_x+7,m_y+2 SAY "Interval 4: do (dana)" GET nDoDana4 PICT "999"
@ m_x+10,m_y+2 SAY "Prikaz iznosa (format)" GET PICPIC PICT "@!"
@ m_x+11,m_y+2 SAY "Uslov po opcini (prazno - nista)" GET cOpcine
read
ESC_BCR
BoxC()
altd()
if EMPTY(cIdPartner)
	cIdPartner:=""
endif
cSvi:=cIdPartner

// odredjivanje prirode zadanog konta (dug. ili pot.)
// --------------------------------------------------
select (F_TRFP2)
if !used()
	O_TRFP2
endif
HSEEK "99 "+LEFT(cIdKonto,1)
DO WHILE !EOF() .and. IDVD=="99" .and. TRIM(idkonto)!=LEFT(cIdKonto,LEN(TRIM(idkonto)))
	SKIP 1
ENDDO
IF IDVD=="99" .and. TRIM(idkonto)==LEFT(cIdKonto,LEN(TRIM(idkonto)))
	cDugPot:=D_P
ELSE
	cDugPot:="1"
    	Box(,3,60)
      	@ m_x+2,m_y+2 SAY "Konto "+cIdKonto+" duguje / potrazuje (1/2)" get cdugpot  VALID cdugpot$"12" PICT "9"
      	READ
    	Boxc()
ENDIF

CrePom()  // kreiraj pomocnu bazu

gaZagFix:={4,5}

START PRINT RET

nUkDugBHD:=0
nUkPotBHD:=0

select suban
set order to 3

seek cIdFirma+cIdKonto+cIdPartner

DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto
	cIdPartner:=idpartner
	nUDug2:=0
	nUPot2:=0
    	nUDug:=0
	nUPot:=0
    	fPrviProlaz:=.t.
    	DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner
		cBrDok:=BrDok
		cOtvSt:=otvst
          	nDug2:=0
		nPot2:=0
          	nDug:=0
		nPot:=0
          	aFaktura:={CTOD(""),CTOD(""),CTOD("")}
          	DO WHILESC !EOF() .and. idfirma==cIdfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner .and. brdok==cBrDok
             		IF D_P=="1"
                		nDug+=IznosBHD
                		nDug2+=IznosDEM
            		ELSE
                		nPot+=IznosBHD
                		nPot2+=IznosDEM
             		ENDIF
             		IF D_P==cDugPot
               			aFaktura[1]:=DATDOK
               			aFaktura[2]:=DATVAL
             		ENDIF
             		if aFaktura[3]<DatDok  // datum zadnje promjene
                		aFaktura[3]:=DatDok
             		endif

             		SKIP 1
          	ENDDO

          	if round(nDug-nPot,2)==0
             		// nista
          	else
             		fPrviProlaz:=.f.
             		if cPrelomljeno=="D"
                		if (nDug-nPot)>0
                   			nDug:=nDug-nPot
                   			nPot:=0
                		else
                   			nPot:=nPot-nDug
                   			nDug:=0
                		endif
                		if (nDug2-nPot2)>0
                   			nDug2:=nDug2-nPot2
                   			nPot2:=0
                		else
                   			nPot2:=nPot2-nDug2
                   			nDug2:=0
                		endif
             		endif
             		SELECT POM
			APPEND BLANK
             		Scatter()
              		_idpartner := cIdPartner
              		_datdok    := aFaktura[1]
              		_datval    := aFaktura[2]
              		_datzpr    := aFaktura[3]
              		_brdok     := cBrDok
              		_dug       := nDug
              		_pot       := nPot
              		_dug2      := nDug2
              		_pot2      := nPot2
              		_otvst     := IF(IF(EMPTY(_datval),_datdok>dNaDan,_datval>dNaDan)," ","1")
             		Gather()
             		SELECT SUBAN
          	endif
	enddo // partner
	
	IF prow()>58+gPStranica
		FF
		ZaglDuznici()
	ENDIF
	
	if (!fVeci .and. idpartner=cSvi) .or. fVeci
    	else
      		exit
    	endif
enddo

SELECT POM

INDEX ON IDPARTNER+OTVST+Rocnost()+DTOS(DATDOK)+DTOS(IIF(EMPTY(DATVAL),DATDOK,DATVAL))+BRDOK TAG "2"

SET ORDER TO TAG "2" 
GO TOP

nTUDug:=nTUPot:=nTUDug2:=nTUPot2:=0
nTUkUVD:=nTUkUVP:=nTUkUVD2:=nTUkUVP2:=0
nTUkVVD:=nTUkVVP:=nTUkVVD2:=nTUkVVP2:=0

anInterUV:={ { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 1
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 2
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 3
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 4
             { {0,0} , {0,0} , {0,0} , {0,0} } }        // preko intervala 4

//  D,TD    P,TP   D2,TD2  P2,TP2
anInterVV:={ { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 1
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 2
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 3
             { {0,0} , {0,0} , {0,0} , {0,0} },;        // do - interval 4
             { {0,0} , {0,0} , {0,0} , {0,0} } }        // preko intervala 4

cLastIdPartner:=""
fPrviProlaz:=.t.

altd()
do while !EOF()
  	cIdPartner:=idpartner
	// a sada provjeri opcine
	// nadji partnera
	if !EMPTY(cOpcine)
		select partn
		hseek cIdPartner
		if AT(ALLTRIM(partn->idops), cOpcine)==0
			select pom
			skip
			loop
		endif
  		select pom
	endif
	
	nUDug:=nUPot:=nUDug2:=nUPot2:=0
  	nUkUVD:=nUkUVP:=nUkUVD2:=nUkUVP2:=0
  	nUkVVD:=nUkVVP:=nUkVVD2:=nUkVVP2:=0
	
	cFaza:=otvst
	
   	FOR i:=1 TO LEN(anInterUV)
     		FOR j:=1 TO LEN(anInterUV[i])
       			anInterVV[i,j,1]:=0
     		NEXT
   	NEXT
   	
	nFaza:=RRocnost()
	
	DO WHILESC !EOF() .and. cIdPartner==IdPartner
    		if fPrviProlaz
       			ZaglDuznici()
       			fPrviProlaz:=.f.
    		endif
    		SELECT POM
    		IF cLastIdPartner!=cIdPartner .or. LEN(cLastIdPartner)<1
			Pljuc(cIdPartner)
      			PPljuc(Ocitaj(F_PARTN,cIdPartner,"naz"))
      			cLastIdPartner:=cIdPartner
    		ENDIF
    		IF otvst<>" "
      			nUkVVD  += Dug 
			nUkVVP  += Pot
			nUkVVD2 += Dug2
			nUkVVP2 += Pot2
       			anInterVV[nFaza,1,1] += dug
       			anInterVV[nFaza,2,1] += pot
       			anInterVV[nFaza,3,1] += dug2
       			anInterVV[nFaza,4,1] += pot2
    		ENDIF
    		nUDug+=Dug
		nUPot+=Pot
    		nUDug2+=Dug2
		nUPot2+=Pot2
    		SKIP 1
                //  znaci da treba
    		IF cFaza==otvst .or. !EOF() .or. cIdPartner==idpartner //<-³ prikazati
         		SKIP -1
         		anInterVV[nFaza,1,2] += anInterVV[nFaza,1,1]
         		anInterVV[nFaza,2,2] += anInterVV[nFaza,2,1]
         		anInterVV[nFaza,3,2] += anInterVV[nFaza,3,1]
         		anInterVV[nFaza,4,2] += anInterVV[nFaza,4,1]
         		SKIP 1
        		nTUkVVD  += nUkVVD 
			nTUkVVP  += nUkVVP
        		nTUkVVD2 += nUkVVD2
			nTUkVVP2 += nUkVVP2
      		ENDIF
      		cFaza:=otvst
        	nFaza:=RRocnost()
      		SKIP -1
      		IF cFaza<>" "
        		anInterVV[nFaza,1,2] += anInterVV[nFaza,1,1]
        		anInterVV[nFaza,2,2] += anInterVV[nFaza,2,1]
        		anInterVV[nFaza,3,2] += anInterVV[nFaza,3,1]
        		anInterVV[nFaza,4,2] += anInterVV[nFaza,4,1]
      		ENDIF
      		SKIP 1
      		nFaza:=RRocnost()

	ENDDO

	
	SELECT POM
	if !fPrviProlaz  // bilo je stavki
		nIznosRok:=0
		nSaldo:=nUDug-nUPot
		FOR i:=1 TO LEN(anInterVV)
			nIznosRok+=anInterVV[i,1,1]-anInterVV[i,2,1]
			nIznosStavke:=nSaldo-nIznosRok
			PPljuc(TRANSFORM(nIznosStavke,PICPIC))
		NEXT
		PPljuc(TRANSFORM(nUkVVD-nUkVVP,PICPIC))
		PPljuc(TRANSFORM(nSaldo,PICPIC))
		IF prow()>52+gPStranica
			FF
			ZaglDuznici()
			fPrviProlaz:=.f.
		ENDIF
    	
	endif

	nTUDug += nUDug
	nTUDug2 += nUDug2
	nTUPot += nUPot
	nTUPot2 += nUPot2
	
	IF prow()>58+gPStranica
		FF
		ZaglDuznici(.t.)
	ENDIF

ENDDO

? "ÃÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
Pljuc( PADR( "UKUPNO" , LEN(POM->IDPARTNER+PARTN->naz)+1 ) )
FOR i:=1 TO LEN(anInterVV)
	PPljuc(TRANSFORM(anInterVV[i,1,2]-anInterVV[i,2,2],PICPIC))
NEXT
PPljuc(TRANSFORM(nTUkVVD-nTUkVVP,PICPIC))
PPljuc(TRANSFORM(nTUDug-nTUPot  ,PICPIC))
? "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"

FF
END PRINT

select (F_POM)
use

CLOSERET
return
*}

/*! \fn ZaglDuznici(fStrana, lSvi)
 *  \brief Zaglavlje izvjestaja duznika
 *  \param fStrana
 *  \param lSvi
 */

function ZaglDuznici(fStrana, lSvi)
*{
local nArr
nArr:=SELECT()

P_COND2

IF lSvi==NIL
	lSvi:=.f.
ENDIF

if fStrana==NIL
	fStrana:=.f.
endif

if nStr=0
  fStrana:=.t.
endif

?? "FIN.P:  Specifikacija Dugovanja partnera po rocnim intervalima "; ?? dNaDan

SELECT PARTN
HSEEK cIdFirma

? "FIRMA:",cIdFirma,"-",gNFirma

SELECT KONTO
HSEEK cIdKonto

? "KONTO  :",cIdKonto,naz
? "ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
? "³      ³                         ³                     V  A  N      V  A  L  U  T  E                                 ³             ³"
? "³SIFRA ³     NAZIV  PARTNERA     ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ´  UKUPNO     ³"
? "³PARTN.³                         ³DO"+STR(nDoDana1,3)+" D.     ³DO"+STR(nDoDana2,3)+" D.     ³DO"+STR(nDoDana3,3)+" D.     ³DO"+STR(nDoDana4,3)+" D.     ³PR."+STR(nDoDana4,2)+" D.     ³ UKUPNO      ³             ³"
? "ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄ´"

select (nArr)
return
*}




