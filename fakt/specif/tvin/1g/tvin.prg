#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/specif/tvin/1g/tvin.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.4 $
 * $Log: tvin.prg,v $
 * Revision 1.4  2002/09/13 08:53:31  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/26 18:06:43  ernad
 *
 *
 * ciscenja fakt
 *
 *
 */


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_PrikaziNaruciocaAkoJeRazlicitOdKupca
  * \brief Da li se na dokumentu prikazuje narucilac ako je razlicit od kupca?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_KumPath_FAKT_PrikaziNaruciocaAkoJeRazlicitOdKupca;


/*! \fn KalkNab3m(cIdFirma,cIdRoba,aNabavke)
 *  \brief Nabavke po narudzbi i naruciocu
 *  \param cIdFirma
 *  \param cIdRoba
 *  \param aNabavke  - matrica gdje je k=kolicina na stanju, c=cijena, ki=izabrana kolicina, idn=cifra narucioca, brn=broj narucioca
 */
 
function KalkNab3m(cIdFirma,cIdRoba,aNabavke)
*{
   SELECT FAKT
   SET ORDER TO TAG "3"   // idroba+dtos(datDok)
   nLen:=1
   hseek cidroba
   do while !eof() .and. cIdRoba==idroba .and.;
            _datdok>=datdok
     KDNarNCm(aNabavke)
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
    Box("#IZBOR PO NABAVKAMA ZA '"+cIdRoba+"-"+TRIM(ROBA->naz)+"'",LEN(aNabavke)+1,77)
     GetList:={}
     @ m_x+1, m_y+2 SAY PADC("STANJE",12)+;
                        PADC("NARUCILAC",10)+PADC("BR.NARUDZBE",14)+PADC("KOLICINA",12)
     FOR i:=1 TO LEN(aNabavke)
       @ m_x+1+i, m_y+2 SAY PADC(TRANS(aNabavke[i,1],PicKol),12)+;
                            PADC(aNabavke[i,4],10)+;
                            PADC(aNabavke[i,5],14);
                        GET aNabavke[i,3] PICT PicKol
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
   SELECT PRIPR
return
*}


/*! \fn KDNarNCm(aNabavke)
 *  \brief
 *  \param aNabavke
 */
 
function KDNarNCm(aNabavke)
*{
LOCAL nKolNeto:=0, nPom:=0, nUl:=0, nIzl:=0, nRezerv:=0, nRevers:=0
  IF FAKT->IdFirma == _IdFirma
    if idtipdok="0"  // ulaz
      nUl  += kolicina
    elseif idtipdok="1"   // izlaz faktura
      if !(left(serbr,1)=="*" .and. idtipdok=="10")  // za fakture na osnovu otpremnice ne raŸunaj izlaz
        nIzl += kolicina
      endif
    elseif idtipdok$"20#27"
      if serbr="*"
        nRezerv += kolicina
      endif
    elseif idtipdok=="21"
      nRevers += kolicina
    endif
    nKolNeto:=nUl-nIzl-nRezerv-nRevers
    nPom := ASCAN(aNabavke,{|x| x[4]=idnar.and.x[5]=brojnar})
    IF nPom>0
      aNabavke[nPom,1] += nKolNeto
    ELSE
      AADD( aNabavke , {nKolNeto,cijena,0,idnar,brojnar} )
    ENDIF
  ENDIF
RETURN
*}


/*! \fn IspisPoNar(lPartner,lString,lMVar)
 *  \brief Ispis po naruciocu
 *  \param lPartner
 *  \param lString
 *  \param lMVar
 *  \return cV
 */
 
function IspisPoNar(lPartner, lString, lMVar)
*{
LOCAL cV:=""

IF lPartner==NIL
	lPartner:=.t.
ENDIF
IF lString==NIL
	lString:=.f.
ENDIF
IF lMVar==NIL
	lMVar:=.f.
ENDIF

IF lMVar
    cV := "   Br.nar.:"+_brojnar + IF(lPartner .or. _idpartner<>_idnar .and. IzFMKIni("FAKT","PrikaziNaruciocaAkoJeRazlicitOdKupca","D",KUMPATH)=="D"," Narucioc:"+_idnar,"")
ELSEIF lString
    cV := "   Br.nar.:"+brojnar + IF(lPartner .or. idpartner<>idnar .and. IzFMKIni("FAKT","PrikaziNaruciocaAkoJeRazlicitOdKupca","D",KUMPATH)=="D"," Narucioc:"+idnar,"")
ELSE
    ?? "   Br.nar.:"+brojnar
    IF lPartner .or. idpartner<>idnar .and. IzFMKIni("FAKT","PrikaziNaruciocaAkoJeRazlicitOdKupca","D",KUMPATH)=="D"
      ?? " Narucioc:"+idnar
    ENDIF
ENDIF
return cV
*}

