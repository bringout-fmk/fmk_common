#include "\cl\sigma\fmk\fakt\fakt.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/specif/merkom/1g/merkom.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.6 $
 * $Log: merkom.prg,v $
 * Revision 1.6  2003/03/27 15:13:45  mirsad
 * izvjestaj "specif.prodaje" sada radi kao i uslov za opcinu za tabelarni prikaz liste dokumenata
 *
 * Revision 1.5  2002/09/26 10:15:39  sasa
 * doradjen izvjestaj specifikacija robe za partnera
 *
 * Revision 1.4  2002/09/13 08:48:16  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/19 08:52:50  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/specif/merkom/1g/merkom.prg
 *  \brief Specifikacija po robama i po kupcima
 */


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Da li se koristi sifrarnik opcina i sifra opcine u sifrarniku partnera?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \fn RealKol()
 *  \brief Specifikacija roba ili kolicina za kupca ili obrnuto
 */
 
function RealKol()
*{
private lOpcine:=(IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D")
private cPrikaz
private cSection:="N"
private cHistory:=" "
private aHistory:={}
private cIdPartner
private nStrana:=0
private cLinija

O_FAKT
O_PARTN
O_VALUTE
O_RJ
O_ROBA

if lOpcine
	O_OPS
endif

cIdfirma:=gFirma
dDatOd:=ctod("")
dDatDo:=date()
qqTipDok:=space(20)

Box("#SPECIFIKACIJA PRODAJE PO ARTIKLIMA",11,77)
	O_PARAMS
	RPar("c1",@cIdFirma)
	RPar("d1",@dDatOd)
	RPar("d2",@dDatDo)
	qqIdRoba:=SPACE(20)
	cPrikaz:="2"
	cIdRoba:=SPACE(20)
	cImeKup:=SPACE(20)
	cOpcina:=SPACE(20)
	qqPartn:=SPACE(20)
	RPar("sk",@qqPartn)
//	RPar("vi",@cPrikaz)
	RPar("td",@qqTipDok)
	qqPartn:=PADR(qqPartn,LEN(partn->id))
	qqIdRoba:=PADR(qqIdRoba,20)
	qqTipDok:=PADR(qqTipDok,40)

	do while .t.
 		cIdFirma:=PADR(cIdFirma,2)
// 		@ m_x+1,m_y+2 SAY "Prikaz izvjestaja po partnerima/robi (1/2) " GET cPrikaz valid cPrikaz $ "12"
// 		read
 		@ m_x+2,m_y+2 SAY "RJ            " GET cIdFirma valid {|| empty(cIdFirma) .or. cIdFirma==gFirma .or. P_RJ(@cIdFirma) }
 		@ m_x+3,m_y+2 SAY "Tip dokumenta " GET qqTipDok pict "@!S20"
 		@ m_x+4,m_y+2 SAY "Od datuma "  get dDatOd
 		@ m_x+4,col()+1 SAY "do"  get dDatDo
		@ m_x+7,m_y+2 SAY "Uslov po sifri partnera (prazno svi) "  get qqPartn pict "@!" valid {|| empty(qqPartn).or.P_Firma(@qqPartn)}
 		@ m_x+8,m_y+2 SAY "Uslov po artiklu (prazno svi) "  get qqIdRoba pict "@!"
 		if lOpcine
   			@ m_x+9,m_y+2 SAY "Uslov po opcini (prazno sve) "  get cOpcina pict "@!"
 		endif
 		read
 		ESC_BCR

 		aUslRB:=Parsiraj(qqIdRoba,"IDROBA","C")

 		if lOpcine
   			aUslOpc:=Parsiraj(cOpcina,"IDOPS","C")
 		endif

 		aUslTD:=Parsiraj(qqTipdok,"IdTipdok","C")
 		if (aUslTD<>NIL)
			exit
		endif
	enddo

	qqTipDok:=TRIM(qqTipDok)
	qqPartn:=TRIM(qqPartn)
	qqIdRoba:=TRIM(qqIdRoba)
	qqTipDok:=TRIM(qqTipDok)
	Params2()
	WPar("c1",cIdFirma)
	WPar("d1",dDatOd)
	WPar("d2",dDatDo)
	WPar("vi",cPrikaz)
	WPar("td",qqTipDok)
	select params
	use
BoxC()

select fakt

private cFilter:=".t."

if (!empty(dDatOd) .or. !empty(dDatDo))
	cFilter+=".and.  datdok>=" + Cm2Str(dDatOd) + " .and. datdok<="+Cm2Str(dDatDo)
endif

if (!empty(cIdFirma))
	cFilter+=" .and. IdFirma=" + Cm2Str(cIdFirma)
endif

if (!empty(qqPartn))
	cFilter+=" .and. IdPartner=" + Cm2Str(qqPartn)
endif

if (!empty(qqIdRoba))
	cFilter+=" .and. " + aUslRB
endif

if (!empty(qqTipDok))
	cFilter+=" .and. " + aUslTD
endif

if (cFilter=" .t. .and. ")
	cFilter:=SubStr(cFilter,9)
endif

if (cFilter==".t.")
	set filter to
else
	set filter to &cFilter
endif

EOF CRET

START PRINT CRET


if cPrikaz=="1"
	cLinija:="---- ------ -------------------------- ------------"
else
	cLinija:="---- ----------- "+REPL("-",LEN(roba->naz))+" ------------ ------------"
endif

cIdPartner:=idPartner

ZaglMerkom()

if cPrikaz=="1"
	set order to tag "1"
	seek cIdFirma
	nC:=0
  	nCol1:=10
	nTKolicina:=0
  	do while !eof() .and. IdFirma=cIdFirma
    		nKolicina:=0
    		cIdPartner:=IdPartner
    		do while !eof() .and. IdFirma=cIdFirma .and. idpartner==cIdpartner
      			if lOpcine
        			SELECT partn
				HSEEK fakt->idPartner
				SELECT fakt
        			if !(partn->(&aUslOpc))
           				skip 1
					loop
        			endif
      			endif
      			nKolicina+=kolicina
      			skip 1
		enddo

		if prow()>61	
			FF
			ZaglMerkom()
		endif

    		select partn
		hseek cIdPartner
		select fakt
    		
		if ROUND(nKolicina,4)<>0
      			? SPACE(gnLMarg)
			?? STR(++nC,4)+".", cIdPartner, partn->naz
      			nCol1:=pcol()+1
      			@ prow(),pcol()+1 SAY STR(nKolicina,12,2)
      			nTKolicina+=nKolicina
    		endif
  	enddo
else  // ako je izabrano "2"

	set order to tag "3"
	go top
  	nC:=0
  	nCol1:=10
	nTKolicina:=0
	nTIznos:=0
	do while !eof()
    		nKolicina:=0
		nIznos:=0
   		cIdRoba:=IdRoba
    		do while !eof() .and. idRoba==cIdRoba
			if lOpcine
        			SELECT partn
				HSEEK fakt->idPartner
				SELECT fakt
        			if !(partn->(&aUslOpc))
           				skip 1
					loop
        			endif
      			endif
     			nKolicina+=kolicina
			if fakt->dindem==left(ValBazna(),3)
				nIznos+=ROUND( kolicina*Cijena*(1-Rabat/100)*(1+Porez/100) ,ZAOKRUZENJE)
			else
				nIznos+=ROUND( kolicina*Cijena*1/UBaznuValutu(datdok)*(1-Rabat/100)*(1+Porez/100) ,ZAOKRUZENJE)
			endif

      			skip 1
    		enddo
    		if prow()>61
			FF
			ZaglMerkom()
		endif
    		select roba
		hseek cIdRoba
		select fakt
    		if ROUND(nKolicina,4)<>0
      			? SPACE(gnLMarg)
			?? STR(++nC,4)+".", cIdRoba, roba->naz
      			nCol1:=PCol()+1
      			@ prow(),PCol()+1 SAY STR(nKolicina,12,2)
      			@ prow(),PCol()+1 SAY STR(nIznos,12,2)
      			nTKolicina+=nKolicina
			nTIznos+=nIznos
    		endif
  	enddo
endif

if prow()>59
	FF
	ZaglMerkom()
endif

? space(gnLMarg)
?? cLinija
? space(gnLMarg)
?? " Ukupno"
@ prow(),nCol1 SAY STR(nTKolicina,12,2)
@ prow(),pcol()+1 SAY STR(nTIznos,12,2)
? space(gnLMarg)
?? cLinija

set filter to  // ukini filter

FF
END PRINT

return
*}



/*! \fn ZaglMerkom()
 *  \brief Zaglavlje 
 */
 
function ZaglMerkom()
*{

? SPACE(gnLMarg)
IspisFirme(cIdFirma)
?

set century on

P_12CPI

if cPrikaz=="1"
	? SPACE(gnLMarg)
	?? "Specifikacija prodaje po partnerima na dan",date(),space(8),"Strana:",STR(++nStrana,3)
else
  	? SPACE(gnLMarg)
	?? "Specifikacija prodaje po artiklima na dan",date(),space(8),"Strana:",STR(++nStrana,3)
endif

? SPACE(gnLMarg)
?? "      za period:",dDatOd," - ",dDatDo

? SPACE(gnLMarg)
?? "Izvjestaj za tipove dokumenata : ",TRIM(qqTipDok)

if cPrikaz=="2" .and. !EMPTY(qqPartn)
	? SPACE(gnLMarg)
	?? "Partner: " + qqPartn + " - " + Ocitaj(F_PARTN, qqPartn, "naz")
endif

if lOpcine .and. !empty(cOpcina)
	? SPACE(gnLMarg)
	?? "Opcine: " + TRIM(cOpcina)
endif

set century off

P_12CPI

? SPACE(gnLMarg)
?? cLinija

if cPrikaz=="1"
	? SPACE(gnLMarg)
	?? " Rbr  Sifra     Partner                  Kolicina                           "
else
	? SPACE(gnLMarg)
	?? " Rbr  Sifra      " + PADC("Naziv",Len(ROBA->naz)) + "   Kolicina       Iznos   "
endif

? SPACE(gnLMarg)
?? "                                                                            "
? SPACE(gnLMarg)
?? cLinija

return
*}


