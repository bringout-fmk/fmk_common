#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/tvin/1g/tvin.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: tvin.prg,v $
 * Revision 1.5  2003/08/01 16:19:23  mirsad
 * tvin, debug, 11-ka i 12-ka, kontrola stanja robe pri unosu
 *
 * Revision 1.4  2003/07/29 15:56:24  mirsad
 * ispravka: pri izlazu više ne razdvaja nabavke po cijeni veæ samo po narudžbi i naruèiocu
 *
 * Revision 1.3  2003/07/18 07:24:54  mirsad
 * stavio u f-ju kontrolu stanja za varijantu po narudzbama za izlazne dokumente (14,41,42)
 *
 * Revision 1.2  2002/06/24 09:33:35  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/specif/tvin/1g/tvin.prg
 *  \brief Izvjestaji tvin
 */

/*! \fn IspisPoNar(lPartner,lString,lMVar)
 *  \brief Prikaz narucioca ako je razlicit od kupca
 *  \param lPartner
 *  \param lString
 *  \param lMVar
 */
 
function IspisPoNar(lPartner,lString,lMVar)
*{
LOCAL cV:=""
  IF lPartner==NIL; lPartner:=.t.; ENDIF
  IF lString==NIL; lString:=.f.; ENDIF
  IF lMVar==NIL; lMVar:=.f.; ENDIF
  IF lMVar
    cV := "   Br.nar.:"+_brojnar + IF(lPartner .or. _idpartner<>_idnar .and. IzFMKIni("KALK","PrikaziNaruciocaAkoJeRazlicitOdKupca","D",KUMPATH)=="D"," Narucioc:"+_idnar,"")
  ELSEIF lString
    cV := "   Br.nar.:"+brojnar + IF(lPartner .or. idpartner<>idnar .and. IzFMKIni("KALK","PrikaziNaruciocaAkoJeRazlicitOdKupca","D",KUMPATH)=="D"," Narucioc:"+idnar,"")
  ELSE
    ?? "   Br.nar.:"+brojnar
    IF lPartner .or. idpartner<>idnar .and. IzFMKIni("KALK","PrikaziNaruciocaAkoJeRazlicitOdKupca","D",KUMPATH)=="D"
      ?? " Narucioc:"+idnar
    ENDIF
  ENDIF
RETURN cV
*}


/*! \fn KalkNab3m(cIdfirma,cIdRoba,cIdKonto,aNabavke)
 *  \brief Nabavke po narudzbi i naruciocu
 *  \param cIdFirma
 *  \param cIdRoba
 *  \param cIdKonto
 *  \param aNabavke matrica {{k1,c1,ki1,idn1,brn1},{k2,c2,ki2,idn2,brn2}...}, gdje je k=kolicina na stanju, c=cijena, ki=izabrana kolicina, idn=sifra narucioca, brn=broj narudzbe
 *  \param nKolS
 */
 
function KalkNab3m(cIdFirma,cIdRoba,cIdKonto,aNabavke,nKolS)
*{
select kalk
set order to 3
seek cidfirma+cidkonto+cidroba+"X"
skip -1
if cidfirma+cidkonto+cidroba==idfirma+mkonto+idroba .and. _datdok<datdok
  Beep(2)
  Msg("Postoji dokument "+idfirma+"-"+idvd+"-"+brdok+" na datum: "+dtoc(datdok),4)
  _ERROR:="1"
endif

nLen:=1

hseek cidfirma+cidkonto+cidroba

do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+mkonto+idroba .and. _datdok>=datdok
  KDNarNCm(aNabavke)
  skip 1
enddo

nKolS:=0
FOR i:=LEN(aNabavke) TO 1 STEP -1
	nKolS+=aNabavke[i,1]
	IF !(aNabavke[i,1]>0)
		ADEL(aNabavke,i)
		ASIZE(aNabavke,LEN(aNabavke)-1)
	ENDIF
NEXT

IF LEN(aNabavke)>0
 @ 12, 0 SAY ""
 Box("#IZBOR PO NABAVKAMA ZA '"+cIdRoba+"-"+TRIM(ROBA->naz)+"'",LEN(aNabavke)+1,77)
  GetList:={}
  @ m_x+1, m_y+2 SAY PADC("STANJE",12)+;
                     PADC("NAB.CIJENA",12)+PADC("NARUCILAC",10)+PADC("BR.NARUDZBE",14)+PADC("KOLICINA",12)
  FOR i:=1 TO LEN(aNabavke)
    @ m_x+1+i, m_y+2 SAY PADC(TRANS(aNabavke[i,1],gPicKol),12)+;
                         PADC(TRANS(aNabavke[i,2],gPicCDem),12)+;
                         PADC(aNabavke[i,4],10)+;
                         PADC(aNabavke[i,5],14);
                     GET aNabavke[i,3] PICT gPicKol
  NEXT
  READ
 BoxC()
ELSE
 MsgBeep("Nema nista na stanju!")
ENDIF

FOR i:=LEN(aNabavke) TO 1 STEP -1
  IF !(ROUND(aNabavke[i,3],8)<>0)
    ADEL(aNabavke,i)
    ASIZE(aNabavke,LEN(aNabavke)-1)
  ENDIF
NEXT

select pripr
RETURN
*}



/*! \fn KDNarNCm(aNabavke)
 *  \brief
 *  \param aNabavke
 */
 
function KDNarNCm(aNabavke,lProsjNC)
*{
local nKolNeto:=0, nPom:=0
if lProsjNC==nil
	lProsjNC:=.f.
endif
if mu_i=="1" .or. mu_i=="5"
	if idvd=="10"
		nKolNeto:=abs(kolicina-gkolicina-gkolicin2)
	else
		nKolNeto:=abs(kolicina)
	endif
	if lProsjNC
		nPom := ASCAN(aNabavke,{|x| x[4]=idnar.and.x[5]=brojnar})
		if (mu_i=="1" .and. kolicina>0) .or. (mu_i=="5" .and. kolicina<0)
			if nPom>0
				aNabavke[nPom,2] := (aNabavke[nPom,2]*aNabavke[nPom,1]+nc*nKolNeto)/(aNabavke[nPom,1]+nKolNeto)
				aNabavke[nPom,1] += nKolNeto
			else
				AADD( aNabavke , {nKolNeto,nc,0,idnar,brojnar} )
			endif
		else
			if nPom>0
				aNabavke[nPom,2] := (aNabavke[nPom,2]*aNabavke[nPom,1]-nc*nKolNeto)/(aNabavke[nPom,1]-nKolNeto)
				aNabavke[nPom,1] -= nKolNeto
			else
				AADD( aNabavke , {-nKolNeto,nc,0,idnar,brojnar} )
			endif
		endif
	else
		nPom := ASCAN(aNabavke,{|x| x[2]=nc.and.x[4]=idnar.and.x[5]=brojnar})
		if (mu_i=="1" .and. kolicina>0) .or. (mu_i=="5" .and. kolicina<0)
			if nPom>0
				aNabavke[nPom,1] += nKolNeto
			else
				AADD( aNabavke , {nKolNeto,nc,0,idnar,brojnar} )
			endif
		else
			if nPom>0
				aNabavke[nPom,1] -= nKolNeto
			else
				AADD( aNabavke , {-nKolNeto,nc,0,idnar,brojnar} )
			endif
		endif

	endif
endif
return
*}


/*! \fn KalkNab3p(cIdFirma,cIdRoba,cIdKonto,aNabavke)
 *  \brief Nabavke po narudzbi i naruciocu
 *  \param cIdFirma
 *  \param cIdroba
 *  \param cIdKonto
 *  \param aNabavke - kao i u predhodnoj funkciji
 *  \param nKolS
 */
function KalkNab3p(cIdFirma,cIdRoba,cIdKonto,aNabavke,nKolS)
*{
select kalk
set order to 4
seek cidfirma+cidkonto+cidroba+"X"
skip -1
if cidfirma+cidkonto+cidroba==idfirma+pkonto+idroba .and. _datdok<datdok
  Beep(2)
  Msg("Postoji dokument "+idfirma+"-"+idvd+"-"+brdok+" na datum: "+dtoc(datdok),4)
  _ERROR:="1"
endif

nLen:=1

hseek cidfirma+cidkonto+cidroba

do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba .and.;
         _datdok>=datdok

  KDNarNCp(aNabavke)
  skip 1
enddo

nKolS:=0
FOR i:=LEN(aNabavke) TO 1 STEP -1
	nKolS+=aNabavke[i,1]
	IF !(aNabavke[i,1]>0)
		ADEL(aNabavke,i)
		ASIZE(aNabavke,LEN(aNabavke)-1)
	ENDIF
NEXT

IF LEN(aNabavke)>0
 @ 12, 0 SAY ""
 Box("#IZBOR PO NABAVKAMA ZA '"+cIdRoba+"-"+TRIM(ROBA->naz)+"'",LEN(aNabavke)+1,77)
  GetList:={}
  @ m_x+1, m_y+2 SAY PADC("STANJE",12)+;
                     PADC("NAB.CIJENA",12)+PADC("NARUCILAC",10)+PADC("BR.NARUDZBE",14)+PADC("KOLICINA",12)
  FOR i:=1 TO LEN(aNabavke)
    @ m_x+1+i, m_y+2 SAY PADC(TRANS(aNabavke[i,1],gPicKol),12)+;
                         PADC(TRANS(aNabavke[i,2],gPicCDem),12)+;
                         PADC(aNabavke[i,4],10)+;
                         PADC(aNabavke[i,5],14);
                     GET aNabavke[i,3] PICT gPicKol
  NEXT
  READ
 BoxC()
ELSE
 MsgBeep("Nema nista na stanju!")
ENDIF

FOR i:=LEN(aNabavke) TO 1 STEP -1
  IF !(ROUND(aNabavke[i,3],8)<>0)
    ADEL(aNabavke,i)
    ASIZE(aNabavke,LEN(aNabavke)-1)
  ENDIF
NEXT

select pripr
RETURN
*}



/*! \fn KDNarNCp(aNabavke)
 *  \brief
 *  \param aNabavke
 */
 
function KDNarNCp(aNabavke,lProsjNC)
*{
local nKolNeto:=0, nPom:=0
if lProsjNC==nil
	lProsjNC:=.f.
endif
if pu_i=="1" .or. pu_i=="5"
	if idvd=="81"
		nKolNeto:=abs(kolicina-gkolicina-gkolicin2)
	else
		nKolNeto:=abs(kolicina)
	endif
	if lProsjNC
		nPom := ASCAN(aNabavke,{|x| x[4]=idnar.and.x[5]=brojnar})
		if (pu_i=="1" .and. kolicina>0) .or. (pu_i=="5" .and. kolicina<0)
			if nPom>0
				aNabavke[nPom,2] := (aNabavke[nPom,2]*aNabavke[nPom,1]+nc*nKolNeto)/(aNabavke[nPom,1]+nKolNeto)
				aNabavke[nPom,1] += nKolNeto
			else
				AADD( aNabavke , {nKolNeto,nc,0,idnar,brojnar} )
			endif
		else
			if nPom>0
				aNabavke[nPom,2] := (aNabavke[nPom,2]*aNabavke[nPom,1]-nc*nKolNeto)/(aNabavke[nPom,1]-nKolNeto)
				aNabavke[nPom,1] -= nKolNeto
			else
				AADD( aNabavke , {-nKolNeto,nc,0,idnar,brojnar} )
			endif
		endif
	else
		nPom := ASCAN(aNabavke,{|x| x[2]=nc.and.x[4]=idnar.and.x[5]=brojnar})
		if (pu_i=="1" .and. kolicina>0) .or. (pu_i=="5" .and. kolicina<0)
			if nPom>0
				aNabavke[nPom,1] += nKolNeto
			else
				AADD( aNabavke , {nKolNeto,nc,0,idnar,brojnar} )
			endif
		else
			if nPom>0
				aNabavke[nPom,1] -= nKolNeto
			else
				AADD( aNabavke , {-nKolNeto,nc,0,idnar,brojnar} )
			endif
		endif
	endif
endif
return
*}



/*! \fn GenStPoNarudzbi(lGenStavke)
 *  \brief Generacija stavki po narudzbi
 *  \param lGenStavke
 */
 
FUNCTION GenStPoNarudzbi(lGenStavke)
*{
IF lGenStavke
    pIzgSt:=.t.
    // vise od jedne stavke
    FOR i:=1 TO LEN(aNabavke)-1
      // generisi sve izuzev posljednje
      APPEND BLANK
      _error    := IF(_error<>"1","0",_error)
      _rbr      := RedniBroj(nRBr)
      _fcj := _nc := aNabavke[i,2]
      _kolicina := aNabavke[i,3]
      _idnar    := aNabavke[i,4]
      _brojnar  := aNabavke[i,5]
      // _vpc      := _nc
      Gather()
      ++nRBr
    NEXT
    // posljednja je tekuca
    _fcj := _nc := aNabavke[i,2]
    _kolicina := aNabavke[i,3]
    _idnar    := aNabavke[i,4]
    _brojnar  := aNabavke[i,5]
    // _vpc      := _nc
  ELSE
    // jedna ili nijedna
    IF LEN(aNabavke)>0
      // jedna
      _fcj := _nc := aNabavke[1,2]
      _kolicina := aNabavke[1,3]
      _idnar    := aNabavke[1,4]
      _brojnar  := aNabavke[1,5]
      // _vpc      := _nc
    ELSE
      // nije izabrana kolicina -> kao da je prekinut unos tipkom Esc
      RETURN (K_ESC)
    ENDIF
  ENDIF

RETURN 1
*}




// sljedece dvije f-je: KalkNab2() i KreDetNC() koriste se u varijanti KALK-a
// za ekonomate (glEkonomat==.t.) a ne u Tvin-u
// --------------------------------------------------------------------------

/*! \fn KalkNab2(cIdFirma,cIdRoba,cIdKonto,aNabavke)
 *  \brief
 *  \param cIdFirma
 *  \param cIdRoba
 *  \param cIdKonto
 *  \param aNabavke
 */
 
function KalkNab2(cIdFirma,cIdRoba,cIdKonto,aNabavke)
*{

select kalk
set order to 3
seek cidfirma+cidkonto+cidroba+"X"
skip -1
if cidfirma+cidkonto+cidroba==idfirma+mkonto+idroba .and. _datdok<datdok
  Beep(2)
  Msg("Postoji dokument "+idfirma+"-"+idvd+"-"+brdok+" na datum: "+dtoc(datdok),4)
  _ERROR:="1"
endif

nLen:=1

hseek cidfirma+cidkonto+cidroba

do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+mkonto+idroba .and.;
         _datdok>=datdok

  KreDetNC(aNabavke)
  skip 1
enddo

FOR i:=LEN(aNabavke) TO 1 STEP -1
  IF !(aNabavke[i,1]>0)
    ADEL(aNabavke,i)
    ASIZE(aNabavke,LEN(aNabavke)-1)
  ENDIF
NEXT

IF LEN(aNabavke)>0
 @ 12, 0 SAY ""
 Box("#IZLAZ PO NABAVKAMA ZA '"+cIdRoba+"-"+TRIM(ROBA->naz)+"'",LEN(aNabavke)+1,77)
  GetList:={}
  @ m_x+1, m_y+2 SAY PADC("STANJE",12)+;
                     PADC("NAB.CIJENA",12)+PADC("KOLICINA",12)
  FOR i:=1 TO LEN(aNabavke)
    @ m_x+1+i, m_y+2 SAY PADC(TRANS(aNabavke[i,1],gPicKol),12)+;
                         PADC(TRANS(aNabavke[i,2],gPicCDem),12);
                     GET aNabavke[i,3] PICT gPicKol
  NEXT
  READ
 BoxC()
ELSE
 MsgBeep("Nema nista na stanju!")
ENDIF

FOR i:=LEN(aNabavke) TO 1 STEP -1
  IF !(ROUND(aNabavke[i,3],8)<>0)
    ADEL(aNabavke,i)
    ASIZE(aNabavke,LEN(aNabavke)-1)
  ENDIF
NEXT

select pripr
RETURN
*}


/*! \fn KreDetNC(aNabavke)
 *  \brief 
 *  \param aNabavke
 */
 
function KreDetNC(aNabavke)
*{
LOCAL nKolNeto:=0, nPom:=0
  if mu_i=="1" .or. mu_i=="5"

    if idvd=="10"
      nKolNeto:=abs(kolicina-gkolicina-gkolicin2)
    else
      nKolNeto:=abs(kolicina)
    endif

    nPom := ASCAN(aNabavke,{|x| x[2]=nc})

    if (mu_i=="1" .and. kolicina>0) .or. (mu_i=="5" .and. kolicina<0)
      IF nPom>0
        aNabavke[nPom,1] += nKolNeto
      ELSE
        AADD( aNabavke , {nKolNeto,nc,0} )
      ENDIF
    else
      IF nPom>0
        aNabavke[nPom,1] -= nKolNeto
      ELSE
        AADD( aNabavke , {-nKolNeto,nc,0} )
      ENDIF
    endif

  endif
RETURN
*}



