#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/rpt_pgp.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_pgp.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/rpt_pgp.prg
 *  \brief
 */


/*! \fn PrometGP()
 *  \brief Izvjestaj "promet grupe partnera"
 */

function PrometGP()
*{
  cgPicKol := IzFMKIni("PrometGrupePartnera","PicKolicina","999999999.999",KUMPATH)
  cgPicDem := IzFMKIni("PrometGrupePartnera","PicIznosa"  ,"999999999.99",KUMPATH)

  nlPK:=LEN(cgPicKol)
  nlPI:=LEN(cgPicDem)

  cIdFirma:=gFirma
  cidKonto:=padr("1310",gDuzKonto)
  private nVPVU:=nVPVI:=nNVU:=nNVI:=0

  if IzFMKIni("Svi","Sifk")=="D"
    O_SIFK; O_SIFV
  else
    MsgBeep("Moraju biti omogucene dodatne karakteristike - sifrarnik SIFK !")
    CLOSERET
  endif
  O_ROBA
  O_KONCIJ
  O_KONTO
  O_PARTN

  private dDatOd:=ctod("")
  private dDatDo:=date()
  qqRoba:=space(60)
  qqIdPartner:=space(60)
  cGP:=" "

  Box("#PROMET GRUPE PARTNERA",10,75)
   do while .t.
     if gNW $ "DX"
       @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
     else
       @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
     endif
     @ m_x+ 3, m_y+2 SAY "Konto " GET cIdKonto valid "." $ cidkonto .or. P_Konto(@cIdKonto)
     @ m_x+ 4, m_y+2 SAY "Artikal (prazno-svi)" GET qqRoba pict "@!S40"
     @ m_x+ 6, m_y+2 SAY "Partner (prazno-svi)" GET qqIdPartner pict "@!S40"
     @ m_x+ 7, m_y+2 SAY "Grupa partnera (prazno-sve)" GET cGP PICT "@!"
     @ m_x+ 9, m_y+2 SAY "Datum od " GET dDatOd
     @ m_x+ 9,col()+2 SAY "do" GET dDatDo
     read; ESC_BCR
     private aUsl1:=Parsiraj(qqRoba,"IdRoba")
     private aUsl4:=Parsiraj(qqIDPartner,"idpartner")
     if aUsl1<>NIL .and. aUsl4<>NIL
       exit
     endif
   enddo
  BoxC()

  fSint:=.f.
  cSintK:=cIdKonto

  if "." $ cidkonto
    cidkonto:=strtran(cidkonto,".","")
    cIdkonto:=trim(cidkonto)
    cSintK:=cIdkonto
    fSint:=.t.
    lSabKon:=(Pitanje(,"Racunati stanje robe kao zbir stanja na svim obuhvacenim kontima? (D/N)","N")=="D")
  endif

  O_KALKREP

  private cFilt:=".t."

  if aUsl1<>".t."
    cFilt+=".and."+aUsl1
  endif

  if aUsl4<>".t."
    cFilt+=".and."+aUsl4
  endif

  if !empty(dDatOd) .or. !empty(dDatDo)
   cFilt+=".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
  endif

  if fSint .and. lSabKon
    cFilt+=".and. MKonto="+cm2str( cSintK )
    cSintK:=""
  endif

  if cFilt==".t."
   set filter to
  else
   set filter to &cFilt
  endif

  select kalk

  if fSint .and. lSabKon
    set order to 6
    //"6","idFirma+IdTarifa+idroba",KUMPATH+"KALK"
    hseek cidfirma
  else
    set order to 3
    hseek cidfirma+cidkonto
  endif

select koncij; seek trim(cidkonto); select kalk

EOF CRET

nLen:=1
m:="----- ---------- -------------------- --- "+REPL("-",nlPK)+" "+REPL("-",nlPI)+" "+REPL("-",nlPK)+" "+REPL("-",nlPI)

gaZagFix:={7,5}

START PRINT CRET

private nTStrana:=0

private bZagl:={|| ZaglPGP()}

Eval(bZagl)
nTUlaz:=nTIzlaz:=0
nTVPVU:=nTVPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
nCol1:=nCol0:=50
private nRbr:=0

cLastPar:=""; cSKGrup:=""
DO WHILE !EOF() .and.;
         IF(fSint.and.lSabKon,idfirma,idfirma+mkonto)=cidfirma+cSintK .and.;
         IspitajPrekid()

cIdRoba:=Idroba
nUlaz:=nIzlaz:=0
nVPVU:=nVPVI:=nNVU:=nNVI:=0
nRabat:=0
SELECT ROBA; HSEEK cidroba

SELECT KALK
IF ROBA->tip $ "TUY"; SKIP 1; LOOP; ENDIF

cIdkonto:=mkonto

DO WHILE !EOF() .and. iif(fSint.and.lSabKon,;
        cidfirma+cidroba==idFirma+idroba,;
        cidfirma+cidkonto+cidroba==idFirma+mkonto+idroba) .and.  IspitajPrekid()

  IF ROBA->tip $ "TU"; SKIP 1; LOOP; ENDIF

  IF !EMPTY(cGP)
    IF !(cLastPar==idpartner)
      cLastPar := idpartner
      // uzmi iz sifk karakteristiku GRUP
      cSKGrup := IzSifK( "PARTN" , "GRUP" , idpartner , .f. )
    ENDIF
    IF cSKGrup!=cGP
      SKIP 1; LOOP
    ENDIF
  ENDIF

  if mu_i=="1"
    if !(idvd $ "12#22#94")
      nUlaz+=kolicina-gkolicina-gkolicin2
      nCol1:=pcol()+1
      if koncij->naz=="P2"
        nVPVU+=round(roba->plc*(kolicina-gkolicina-gkolicin2), gZaokr)
      else
        nVPVU+=round( vpc*(kolicina-gkolicina-gkolicin2) , gZaokr)
      endif
      nNVU+=round( nc*(kolicina-gkolicina-gkolicin2) , gZaokr)
    else
      nIzlaz-=kolicina
      if koncij->naz=="P2"
        nVPVI-=round( roba->plc*kolicina , gZaokr)
      else
        nVPVI-=round( vpc*kolicina , gZaokr)
      endif
      nNVI-=round( nc*kolicina , gZaokr)
    endif
  elseif mu_i=="5"
    nIzlaz+=kolicina
    if koncij->naz=="P2"
      nVPVI+=round( roba->plc*kolicina , gZaokr)
    else
      nVPVI+=round( vpc*kolicina , gZaokr)
    endif
    nRabat+=round(  rabatv/100*vpc*kolicina , gZaokr)
    nNVI+=nc*kolicina
  elseif mu_i=="3"    // nivelacija
    nVPVU+=round( vpc*kolicina , gZaokr)
  elseif mu_i=="8"
    nIzlaz+=  - kolicina
    if koncij->naz=="P2"
      nVPVI+=round( roba->plc*(-kolicina) , gZaokr)
    else
      nVPVI+=round( vpc*(-kolicina) , gZaokr)
    endif
    nRabat+=round(  rabatv/100*vpc*(-kolicina) , gZaokr)
    nNVI+=nc*(-kolicina)
    nUlaz +=  - kolicina
    if koncij->naz=="P2"
      nVPVU+=round(-roba->plc*(kolicina-gkolicina-gkolicin2), gZaokr)
    else
      nVPVU+=round(-vpc*(kolicina-gkolicina-gkolicin2) , gZaokr)
    endif
    nNVU+=round(-nc*(kolicina-gkolicina-gkolicin2) , gZaokr)
  endif

  SKIP 1
ENDDO

if round(nVPVI,4)<>0 .or.;
   round(nNVU,4)<>0  // ne prikazuj stavke 0
  aNaz:=Sjecistr(roba->naz,20)
  if prow()>61+gPStranica; FF; eval(bZagl); endif

  ? str(++nrbr,4)+".", cidroba
  nCr:=pcol()+1

  @ prow(),pcol()+1 SAY aNaz[1]
  @ prow(),pcol()+1 SAY roba->jmj
  nCol0:=pcol()+1

  @ prow(),pcol()+1 SAY nUlaz    PICT cgPicKol
  @ prow(),pcol()+1 SAY nNVU     PICT cgPicDem
  @ prow(),pcol()+1 SAY nIzlaz   PICT cgPicKol
  @ prow(),pcol()+1 SAY nVPVI-nRabat    PICT cgPicDem

  if len(aNaz)>1
    // novi red
    @ prow()+1,0 SAY ""
    @ prow(),nCR  SAY aNaz[2]
  endif

  nTUlaz  += nUlaz ; nTIzlaz += nIzlaz
  nTVPVU  += nVPVU ; nTVPVI  += nVPVI
  nTNVU   += nNVU  ; nTNVI   += nNVI
  nTRabat += nRabat
endif

ENDDO

? m
? "UKUPNO:"
@ prow(),nCol0    SAY nTUlaz    PICT cgPicKol
@ prow(),pcol()+1 SAY nTNVU     PICT cgPicDem
@ prow(),pcol()+1 SAY nTIzlaz   PICT cgPicKol
@ prow(),pcol()+1 SAY nTVPVI-nTRabat    PICT cgPicDem
nCol1:=pcol()+1

? m
FF
END PRINT

#ifdef CAX
 if gKalks; select kalk; use; endif
#endif
CLOSERET
return
*}




/*! \fn ZaglPGP()
 *  \brief Zaglavlje izvjestaja "promet grupe partnera"
 */

function ZaglPGP()
*{
 Preduzece()

 P_12CPI

 SELECT KONTO; HSEEK cidkonto

 SET CENTURY ON
 ?? "KALK: PROMET GRUPE PARTNERA ZA PERIOD",dDatOd,"-",dDatdo,"  na dan", date(), space(4),"Str:",str(++nTStrana,3)
 SET CENTURY OFF

 ? "Grupa partnera:",IF(EMPTY(cGP),"SVE","'"+cGP+"'")
 ? "Magacin:",cidkonto,"-",konto->naz
 SELECT KALK

 ? m
 ? " R.  *  SIFRA   *   NAZIV ARTIKLA    *JMJ*"+PADC("   ULAZ   ",nlPK)+"*"+PADC("  NV ULAZA  ",nlPI)+"*"+PADC("  IZLAZ   ",nlPK)+"*"+PADC(" VPV IZLAZA ",nlPI)+"*"
 ? " BR. * ARTIKLA  *                    *   *"+PADC("          ",nlPK)+"*"+PADC("            ",nlPI)+"*"+PADC("          ",nlPK)+"*"+PADC(" minus RABAT",nlPI)+"*"
 ? "     *    1     *         2          * 3 *"+PADC("     4    ",nlPK)+"*"+PADC("      5     ",nlPI)+"*"+PADC("     6    ",nlPK)+"*"+PADC("      7     ",nlPI)+"*"
 ? m
return (nil)
*}
