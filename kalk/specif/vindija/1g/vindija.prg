#include "\cl\sigma\fmk\kalk\kalk.ch"


/*! \file fmk/kalk/specif/vindija/1g/vindija.prg
 *  \brief Specificnosti za Vindiju
 */


/*! \fn PregledProdaje()
 *  \brief Pregled prodaje - Vindija
 */

function PregProdaje()
*{
  O_PARTN

  cPA:="N"
  dOd:=CTOD("")
  dDo:=DATE()
  qGrupe:=qPodgrupe:=qKupac:=qOpstina:=qKonta:=SPACE(80)
  cMPVP:="S"

  cSaPSiPM:="D"

  Box("#PREGLED PRODAJE - IZVJESTAJNI USLOVI",10,75)
   DO WHILE .t.
     @ m_x+2, m_y+2 SAY "Grupe   " GET qGrupe    PICT "@S40!"
     @ m_x+3, m_y+2 SAY "Podgrupe" GET qPodgrupe PICT "@S40!"
     @ m_x+4, m_y+2 SAY "Za period od" GET dOd
     @ m_x+4, col()+1 SAY "do" GET dDo
     @ m_x+5, m_y+2 SAY "Usporedni prikaz prethodne sedmice i 4 sedmice prije? (D/N)" GET cSaPSiPM PICT "@!" VALID cSaPSiPM$"DN"
     @ m_x+6, m_y+2 SAY "Kupci (prazno-svi)" GET qKupac PICT "@S40!"
     @ m_x+7, m_y+2 SAY "Opstine prodaje (prazno-sve)" GET qOpstina PICT "@S40!"
     @ m_x+8, m_y+2 SAY "Prikaz pojedinacnih artikala (D/N)" GET cPA VALID cPA$"DN" PICT "@!"
     @ m_x+9, m_y+2 SAY "Izdvojiti ( M-maloprodaju / V-veleprodaju / S-sve )" GET cMPVP VALID cMPVP$"MVS" PICT "@!"
     @ m_x+10, m_y+2 SAY "Konta " GET qKonta PICT "@S40!"
     READ; ESC_BCR
     aUslG  := Parsiraj( qGrupe    , "cG"  )
     aUslPG := Parsiraj( qPodgrupe , "cPG" )
     aUslKupac := Parsiraj( qKupac , "idPartner" )
     aUslMKonta := Parsiraj( qKonta , "mKonto" )
     aUslPKonta := Parsiraj( qKonta , "pKonto" )
     aUslOpstina := Parsiraj( qOpstina , "idOps" )
     IF aUslG<>NIL .and. aUslPG<>NIL .and. aUslKupac<>NIL .and. aUslOpstina<>NIL .and. aUslMKonta<>NIL .and. aUslPKonta<>NIL
       EXIT
     ENDIF
   ENDDO
  BoxC()

  O_KALK
  O_ROBA
  O_SIFK
  O_SIFV
  SET ORDER TO TAG "ID"

  CrePom2()

  SELECT KALK
  SET ORDER TO TAG "7"   // idroba
  GO TOP

  DO WHILE !EOF()
    cIdRoba:=idroba
    cG:=cPG:=""
    SELECT ROBA; HSEEK cIdRoba
    SELECT SIFV
     HSEEK "ROBA    "+"GR1 "+PADR(cIdRoba,15)
      IF FOUND(); cG  := TRIM(naz); ENDIF
     HSEEK "ROBA    "+"GR2 "+PADR(cIdRoba,15)
      IF FOUND(); cPG := TRIM(naz); ENDIF
    cJMJ:=ROBA->jmj
    nKJMJ  := SJMJ(1,cIdRoba,@cJMJ)
    SELECT KALK

    // ako roba nije obuhvacena izvjestajnim uslovima, preskoci je
    // -----------------------------------------------------------
    IF !&aUslG .or. !&aUslPG .or. !(&aUslMKonta .or. &aUslPKonta)
      SEEK NovaSifra(cIdRoba)
      SKIP -1
      SKIP 1
      LOOP
    ENDIF

    // izracunaj prodanu kolicinu: nKol
    //       i prodanu vrijednost: nIznos
    // ----------------------------------
    nKol:=nIznos:=0
    nKolP1S:=nKolP4S:=0
    DO WHILE !EOF() .and. IDROBA==cIdRoba
      select partn
      hseek kalk->idPartner
      select kalk
      if cSaPSiPM=="D"
	      IF !(DInRange(datdok,dOd,dDo).or.DInRange(datdok,dOd-7,dDo-7).or.DInRange(datdok,dOd-28,dDo-28)) .or. !(&aUslKupac) .or. !(partn->(&aUslOpstina))
	        SKIP 1
		LOOP
	      ENDIF
      else
	      IF !(DInRange(datdok,dOd,dDo)) .or. !(&aUslKupac) .or. !(partn->(&aUslOpstina))
	        SKIP 1
		LOOP
	      ENDIF
      endif
      IF cMPVP$"SM" .and. pu_i=="5" .and. idvd $ "41#42#43"
        // maloprodaja
	if DInRange(datdok,dOd,dDo)
        	nKol   += kolicina
        	nIznos += ( kolicina*mpc )
	elseif DInRange(datdok,dOd-7,dDo-7)
        	nKolP1S+= kolicina
	elseif DInRange(datdok,dOd-28,dDo-28)
        	nKolP4S+= kolicina
	endif
      ELSEIF cMPVP$"SV" .and. mu_i=="5" .and. idvd $ "14#94"
        // veleprodaja
	if DInRange(datdok,dOd,dDo)
        	nKol   += kolicina
        	nIznos += ( kolicina*VPC*(1-RABATV/100) )
	elseif DInRange(datdok,dOd-7,dDo-7)
        	nKolP1S+= kolicina
	elseif DInRange(datdok,dOd-28,dDo-28)
        	nKolP4S+= kolicina
	endif
      ENDIF
      SKIP 1
    ENDDO

    IF nIznos<>0 .or. nKol<>0
      SELECT PRODAJA
       APPEND BLANK
        REPLACE IDROBA     WITH  cIdRoba           ,;
                IDG        WITH  cG                ,;
                IDPG       WITH  cPG               ,;
                NAZ        WITH  ROBA->naz         ,;
                BJMJ       WITH  cJMJ              ,;
                BKOLICINA  WITH  nKol*nKJMJ        ,;
                BKOLP1S    WITH  nKolP1S*nKJMJ     ,;
                BKOLP4S    WITH  nKolP4S*nKJMJ     ,;
                JMJ        WITH  ROBA->jmj         ,;
                KOLICINA   WITH  nKol              ,;
                CIJENA     WITH  ROBA->vpc         ,;
                IZNOS      WITH  nIznos
    ENDIF

    SELECT KALK
  ENDDO

  // slijedi stampa izvjestaja na osnovu formirane baze prodaje
  // ----------------------------------------------------------
  SELECT PRODAJA
  GO TOP

  START PRINT CRET

   Preduzece(0)
   ?
   ? "Izvjestaj o prodaji"+IF(cMPVP=="M"," (samo u maloprodaji)",IF(cMPVP=="V"," (samo u veleprodaji)",""))+" za period od",dOd,"do",dDo
   ?
   IF !EMPTY(qGrupe)
     ? "Izdvojene grupe po uslovu '"+RTRIM(qGrupe)+"'"
   ENDIF
   IF !EMPTY(qPodgrupe)
     ? "Izdvojene podgrupe po uslovu '"+RTRIM(qPodgrupe)+"'"
   ENDIF
   IF !EMPTY(qKupac)
     ? "Izdvojeni kupci po uslovu '"+RTRIM(qKupac)+"'"
   ENDIF
   IF !EMPTY(qOpstina)
     ? "Izdvojene opstine prodaje po uslovu '"+RTRIM(qOpstina)+"'"
   ENDIF
   IF !EMPTY(qKonta)
     ? "Izdvojena konta prodaje po uslovu '"+RTRIM(qKonta)+"'"
   ENDIF
   ?

   gnLMarg:=0; gTabela:=1; gOstr:="N"

   cIDG  := IDG
   cIDPG := IDPG

   nKol1 := nKol1P1S := nKol1P4S := nIznos1 := 0
   nKol2 := nKol2P1S := nKol2P4S := nIznos2 := 0
   nKol9 := nKol9P1S := nKol9P4S := nIznos9 := 0

   gaSubTotal:={}
   gaDodStavke:={}

   nKol:=0
   aKol:={}

   lPA := (cPA=="D")

   IF lPA
     AADD(aKol, { "Artikal"       , {|| NAZ       }, .f., "C", 40, 0, 1, ++nKol} )
   ELSE
     AADD(aKol, { "GRUPA/PODGRUPA", {|| ""        }, .f., "C", 65, 0, 1, ++nKol} )
   ENDIF
   AADD(aKol, { "Kolicina"      , {|| BKOLICINA }, lPA, "N", 13, 3, 1, ++nKol} )
   
   if cSaPSiPM=="D"
   	AADD(aKol, { "Kolicina"      , {|| BKOLP1S }, lPA, "N", 13, 3, 1, ++nKol} )
   	AADD(aKol, { "prije 7 dana"  , {|| "#"     }, .f., "C", 13, 0, 2,   nKol} )
   	AADD(aKol, { "Omjer kolic."  , {|| SDiv(BKOLP1S,BKOLICINA) }, .f., "N", 13, 3, 1, ++nKol} )
   	AADD(aKol, { "sada/pr.7d"  , {|| "#"     }, .f., "C", 13, 0, 2,   nKol} )
   	AADD(aKol, { "Kolicina"      , {|| BKOLP4S }, lPA, "N", 13, 3, 1, ++nKol} )
   	AADD(aKol, { "prije 28 dana"  , {|| "#"     }, .f., "C", 13, 0, 2,   nKol} )
   	AADD(aKol, { "Omjer kolic."  , {|| SDiv(BKOLP4S,BKOLICINA) }, .f., "N", 13, 3, 1, ++nKol} )
   	AADD(aKol, { "sada/pr.28d"  , {|| "#"     }, .f., "C", 13, 0, 2,   nKol} )
   endif
   
   AADD(aKol, { "BJMJ"          , {|| BJMJ      }, .f., "C", 10, 0, 1, ++nKol} )
   
   IF lPA .and. cSaPSiPM<>"D"
     AADD(aKol, { "Cijena bez"    , {|| CIJENA    }, .f., "N", 13, 3, 1, ++nKol} )
     AADD(aKol, { "poreza"        , {|| "#"       }, .f., "C", 13, 0, 2,   nKol} )
     AADD(aKol, { "JMJ"           , {|| JMJ       }, .f., "C", 10, 0, 1, ++nKol} )
   ENDIF

   if cSaPSiPM<>"D"
   	AADD(aKol, { "Vrijednost"    , {|| IZNOS     }, lPA, "N", 13, 3, 1, ++nKol} )
   endif

   aGr:={}
   StampaTabele(aKol,,,gTabela,,,,IF(lPA,{|| ForPPr()},{|| ForPPr2()}),;
                IF(gOstr=="D",,-1),,,,,,.f.)

   ?
   IF PROW()>56+gPStranica-LEN(aGr); FF; endif
   ? "Rekapitulacija po grupama:"
   if cSaPSiPM=="D"
	   ? REPL("-",40)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",10)+" "+REPL("-",13)
	   ? PADC("GRUPA",40)+" "+PADC("KOLICINA",13)+" "+PADC("KOLIC.PR.7d",13)+" "+PADC("OMJER SADA/7d",13)+" "+PADC("KOLIC.PR.28d",13)+" "+PADC("OMJ. SADA/28d",13)+" "+PADC("BJMJ",10)+" "+PADC("VRIJEDNOST",13)
	   ? REPL("-",40)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",10)+" "+REPL("-",13)
	   nIznos:=nKol:=nKolP1S:=nKolP4S:=0
	   FOR i:=1 TO LEN(aGr)
	      ? PADR(aGr[i,1],40),;
	        TRANS(aGr[i,2],"999999999.999"),;
	        TRANS(aGr[i,3],"999999999.999"),;
	        TRANS(SDiv(aGr[i,3],aGr[i,2]),"999999999.999"),;
	        TRANS(aGr[i,4],"999999999.999"),;
	        TRANS(SDiv(aGr[i,4],aGr[i,2]),"999999999.999"),;
	        PADR(aGr[i,5],10),;
	        TRANS(aGr[i,6],"999999999.999")
	     nKol   += aGr[i,2]
	     nKolP1S+= aGr[i,3]
	     nKolP4S+= aGr[i,4]
	     nIznos += aGr[i,6]
	   NEXT
	   ? REPL("-",40)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",10)+" "+REPL("-",13)
	   ? PADR("UKUPNO",40)+" "+STR(nKol,13,3)+" "+STR(nKolP1S,13,3)+" "+STR(SDiv(nKolP1S,nKol),13,3)+" "+STR(nKolP4S,13,3)+" "+STR(SDiv(nKolP4S,nKol),13,3)+" "+SPACE(10)+" "+STR(nIznos,13,3)
	   ? REPL("-",40)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",13)+" "+REPL("-",10)+" "+REPL("-",13)
   else
	   ? REPL("-",40)+" "+REPL("-",13)+" "+REPL("-",10)+" "+REPL("-",13)
	   ? PADC("GRUPA",40)+" "+PADC("KOLICINA",13)+" "+PADC("BJMJ",10)+" "+PADC("VRIJEDNOST",13)
	   ? REPL("-",40)+" "+REPL("-",13)+" "+REPL("-",10)+" "+REPL("-",13)
	   nIznos:=nKol:=0
	   FOR i:=1 TO LEN(aGr)
	      ? PADR(aGr[i,1],40),;
	        TRANS(aGr[i,2],"999999999.999"),;
	        PADR(aGr[i,3],10),;
	        TRANS(aGr[i,4],"999999999.999")
	     nKol   += aGr[i,2]
	     nIznos += aGr[i,4]
	   NEXT
	   ? REPL("-",40)+" "+REPL("-",13)+" "+REPL("-",10)+" "+REPL("-",13)
	   ? PADR("UKUPNO",40)+" "+STR(nKol,13,3)+" "+SPACE(10)+" "+STR(nIznos,13,3)
	   ? REPL("-",40)+" "+REPL("-",13)+" "+REPL("-",10)+" "+REPL("-",13)
   endif

   FF

  END PRINT

CLOSERET
return
*}



// -------------------------------------------------------------
// kreiranje i otvaranje pomocne baze POM.DBF za pregled prodaje
// -------------------------------------------------------------
static function CrePom2()
*{
  select 0      // idi na slobodno podrucje
  cPom:=PRIVPATH+"PRODAJA"
  IF FILE(cPom+".DBF") .and. ferase(cPom+".DBF")==-1
    MsgBeep("Ne mogu izbrisati fajl PRODAJA.DBF!")
    ShowFError()
  ENDIF
  IF FILE(cPom+".CDX") .and. ferase(cPom+".CDX")==-1
    MsgBeep("Ne mogu izbrisati fajl PRODAJA.CDX!")
    ShowFError()
  ENDIF
  // ferase(cPom+".CDX")
  aDbf := {}
  AADD(aDBf,{ 'IDROBA'      , 'C' , 10 ,  0 })
  AADD(aDBf,{ 'IDG'         , 'C' , 10 ,  0 })
  AADD(aDBf,{ 'IDPG'        , 'C' , 10 ,  0 })
  AADD(aDBf,{ 'NAZ'         , 'C' , 40 ,  0 })
  AADD(aDBf,{ 'BJMJ'        , 'C' , 10 ,  0 })
  AADD(aDBf,{ 'BKOLICINA'   , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'BKOLP4S'     , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'BKOLP1S'     , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'JMJ'         , 'C' ,  4 ,  0 })
  AADD(aDBf,{ 'KOLICINA'    , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'CIJENA'      , 'N' , 10 ,  4 })
  AADD(aDBf,{ 'IZNOS'       , 'N' , 18 ,  8 })
  DBCREATE2 (cPom, aDbf)
  USEX (cPom)
  INDEX ON IDG+IDPG+IDROBA TAG "1"
  INDEX ON IDG+IDPG+NAZ    TAG "2"
  SET ORDER TO TAG "1" ; GO TOP
RETURN .T.
*}


// sa artiklima
// ------------
function ForPPr()
*{
 LOCAL lVrati:=.t.
  gaSubTotal  := {}
  gaDodStavke := {}
  cIDG  := IDG
  cIDPG := IDPG
  cST1  := OpisSubGr(cIdG)
  cST2  := OpisSubPG(cIdG,cIdPG)
  nKol1 += bkolicina; nIznos1 += iznos
  nKol2 += bkolicina; nIznos2 += iznos
  nKol1P1S += bkolp1s
  nKol2P1S += bkolp1s
  nKol1P4S += bkolp4s
  nKol2P4S += bkolp4s
  cBJMJ := BJMJ
 SKIP 1
  IF cIDG<>IDG .or. EOF()
    // stampaj subtot.podgrupa
    // stampaj subtot.grupa
    if cSaPSiPM=="D"
	    gaSubTotal :={ {,nKol2,nKol2P1S,SDiv(nKol2P1S,nKol2),nKol2P4S,SDiv(nKol2P4S,nKol2),cBJMJ,,,nIznos2 , cST2 },;
	                   {,nKol1,nKol1P1S,SDiv(nKol1P1S,nKol1),nKol1P4S,SDiv(nKol1P4S,nKol1),cBJMJ,,,nIznos1 , cST1 } }
	    AADD(aGr,{cST1,nKol1,nKol1P1S,nKol1P4S,cBJMJ,nIznos1})
    else
	    gaSubTotal :={ {,nKol2,cBJMJ,,,nIznos2 , cST2 },;
	                   {,nKol1,cBJMJ,,,nIznos1 , cST1 } }
	    AADD(aGr,{cST1,nKol1,cBJMJ,nIznos1})
    endif
    nKol1 := nIznos1 := 0
    nKol2 := nIznos2 := 0
    nKol1P1S:=nKol2P1S:=0
    nKol1P4S:=nKol2P4S:=0
  ELSEIF cIDPG<>IDPG
    // stampaj subtot.podgrupa
    if cSaPSiPM=="D"
	    gaSubTotal :={ {,nKol2,nKol2P1S,SDiv(nKol2P1S,nKol2),nKol2P4S,SDiv(nKol2P4S,nKol2),cBJMJ,,,nIznos2 , cST2 } }
    else
	    gaSubTotal :={ {,nKol2,cBJMJ,,,nIznos2 , cST2 } }
    endif
    nKol2 := nIznos2 := 0
    nKol2P1S:=nKol2P4S:=0
  ELSE
    gaSubTotal:={}
  ENDIF
 SKIP -1
RETURN lVrati
*}


// bez artikala
// ------------
function ForPPr2()
*{
 LOCAL lVrati:=.t.
  gaSubTotal  := {}
  gaDodStavke := {}
  cIDG  := IDG
  cIDPG := IDPG
  cST1  := OpisSubGr(cIdG)
  cST2  := OpisSubPG(cIdG,cIdPG)
  cST9  := "S V E    U K U P N O"
  nKol1 += bkolicina; nIznos1 += iznos
  nKol2 += bkolicina; nIznos2 += iznos
  nKol9 += bkolicina; nIznos9 += iznos
  nKol1P1S += bkolp1s
  nKol2P1S += bkolp1s
  nKol9P1S += bkolp1s
  nKol1P4S += bkolp4s
  nKol2P4S += bkolp4s
  nKol9P4S += bkolp4s
  cBJMJ := BJMJ
 SKIP 1
  IF cIDG<>IDG .or. EOF()
    // stampaj subtot.podgrupa
    // stampaj subtot.grupa
    if cSaPSiPM=="D"
	    gaSubTotal :={ {,nKol2,nKol2P1S,SDiv(nKol2P1S,nKol2),nKol2P4S,SDiv(nKol2P4S,nKol2),cBJMJ,nIznos2 , cST2 },;
	                   {,nKol1,nKol1P1S,SDiv(nKol1P1S,nKol1),nKol1P4S,SDiv(nKol1P4S,nKol1),cBJMJ,nIznos1 , cST1 } }
	    AADD(aGr,{cST1,nKol1,nKol1P1S,nKol1P4S,cBJMJ,nIznos1})
    else
	    gaSubTotal :={ {,nKol2,cBJMJ,nIznos2 , cST2 },;
	                   {,nKol1,cBJMJ,nIznos1 , cST1 } }
	    AADD(aGr,{cST1,nKol1,cBJMJ,nIznos1})
    endif
    nKol1 := nIznos1 := 0
    nKol2 := nIznos2 := 0
    nKol1P1S:=nKol2P1S:=0
    nKol1P4S:=nKol2P4S:=0
    // stampaj sve ukupno
    IF EOF()
	    if cSaPSiPM=="D"
		    AADD(gaSubTotal, {,nKol9,nKol9P1S,SDiv(nKol9P1S,nKol9),nKol9P4S,SDiv(nKol9P4S,nKol9),cBJMJ,nIznos9 , cST9 } )
	    else
		    AADD(gaSubTotal, {,nKol9,cBJMJ,nIznos9 , cST9 } )
	    endif
    ENDIF
  ELSEIF cIDPG<>IDPG
    // stampaj subtot.podgrupa
    if cSaPSiPM=="D"
	    gaSubTotal :={ {,nKol2,nKol2P1S,SDiv(nKol2P1S,nKol2),nKol2P4S,SDiv(nKol2P4S,nKol2),cBJMJ,nIznos2 , cST2 } }
    else
	    gaSubTotal :={ {,nKol2,cBJMJ,nIznos2 , cST2 } }
    endif
    nKol2 := nIznos2 := 0
    nKol2P1S:=0
    nKol2P4S:=0
  ELSE
    gaSubTotal:={}
  ENDIF
 SKIP -1
RETURN .f.
*}

static function OpisSubGr(cId)
*{
local cVrati
cVrati:="UKUPNO GRUPA '"+cId+"-"+IzFmkIni("VINDIJA","NazGr"+cId,"",KUMPATH)+"'"
return cVrati
*}

static function OpisSubPG(cIdG,cIdPG)
*{
local cVrati
cVrati:="PODGRUPA '"+cIdPG+"-"+IzFmkIni("VINDIJA","NazPG"+cIdG+cIdPG,"",KUMPATH)+"'"
return cVrati
*}


function SDiv(nDjelilac,nDijeljenik)
*{
local nV
if nDjelilac<>0
	nV:=nDijeljenik/nDjelilac
else
	nV:=0
endif
return nV
*}

