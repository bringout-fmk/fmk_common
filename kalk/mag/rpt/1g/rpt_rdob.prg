#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/rpt_rdob.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: rpt_rdob.prg,v $
 * Revision 1.4  2004/05/19 12:16:55  sasavranic
 * no message
 *
 * Revision 1.3  2003/04/02 07:13:46  mirsad
 * dodan uslov za broj prethodnih sezona koje se gledaju da bi se utvrdilo koja je roba nabavljana od zadanog dobavljaca u izvj."pregled robe za dobavljaca"
 *
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/rpt_rdob.prg
 *  \brief Izvjestaj "pregled robe za dobavljaca"
 */


/*! \fn PRobDob()
 *  \brief Izvjestaj "pregled robe za dobavljaca"
 */

function PRobDob()
*{
 if IzFMKIni("Svi","Sifk")=="D"
 	O_SIFK
 	O_SIFV
 endif
 O_ROBA
 O_PARTN
 O_KALK
 SET RELATION TO idroba INTO ROBA

 cIdRoba    := SPACE(LEN(ROBA->id))
 cIdPartner := SPACE(LEN(PARTN->id))
 dOd := CTOD("")
 dDo := DATE()
 nPrSez:=0
 if IsPlanika()
 	cK9:=SPACE(3)
 endif

 Box("#PREGLED ROBE ZA DOBAVLJACA",6,70)
  @ m_x+2, m_y+2 SAY "Artikal (prazno-svi)" GET cIdRoba VALID EMPTY(cIdRoba).or.P_Roba(@cIdRoba) PICT "@!"
  @ m_x+3, m_y+2 SAY "Dobavljac           " GET cIdPartner VALID P_Firma(@cIdPartner) PICT "@!"
  @ m_x+4, m_y+2 SAY "Za period od" GET dOd
  @ m_x+4, col()+2 SAY "do" GET dDo
  @ m_x+5, m_y+2 SAY "Koliko prethodnih sezona gledati? (0/1/2/3)" GET nPrSez VALID nPrSez<4 PICT "9" 
  if IsPlanika()
  	@ m_x+6, m_y+2 SAY "Pregled po K9 " GET cK9 PICT "@!"
  endif
  READ
  ESC_BCR
 BoxC()

 IF EMPTY(cIdRoba)
   lPromVP := ( Pitanje(,"Prikazati stanje samo za artikle sa promjenama(ulaz/izlaz) u VP? (D/N)","D")=="D" )
 ENDIF

 cFilt := "DATDOK>=dOd .and. DATDOK<=dDo"
 IF !EMPTY(cIdRoba)
   cFilt += ".and. IDROBA==cIdRoba"
 ENDIF
 if IsPlanika() .and. !EMPTY(cK9)
 	cFilt += ".and. roba->k9 == cK9"
 endif
 cSort := "idroba+dtos(datdok)"

 Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  INDEX ON &cSort TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
 BoxC()

 IF EMPTY(cIdRoba)
   // kao lager lista
   // ---------------
   START PRINT CRET

   gnLMarg:=0; gTabela:=1; gOstr:="D"
   PRIVATE cRoba:="", nUlaz:=0, nStanje:=0, lImaVP:=.f., nNC:=0, nVPC:=0

   aKol:={ { "ROBA"         , {|| cRoba    }, .f., "C", 56, 0, 1, 1},;
           { "Ulaz (svi"    , {|| nUlaz    }, .f., "N", 12, 3, 1, 2},;
           { "objekti)"     , {|| "#"      }, .f., "C", 12, 0, 2, 2},;
           { "Stanje u"     , {|| IF(lPromVP.and.!lImaVP,"  n e m a   ",STR(nStanje,12,3))  }, .f., "C", 12, 0, 1, 3},;
           { "veleprod."    , {|| "#"      }, .f., "C", 12, 0, 2, 3},;
           { "Poslj.NC"     , {|| nNC      }, .f., "N-", 10, 3, 1, 4},;
           { "VPC"          , {|| nVPC     }, .f., "N-", 10, 2, 1, 5} }

   ?? space(gnLMarg); ?? "KALK: Izvjestaj na dan",date()
   ? space(gnLMarg); IspisFirme("")
   ?
   ? "PREGLED ROBE OD DOBAVLJACA ZA PERIOD OD",dOD,"DO",dDo
   ? "DOBAVLJAC:",cIdPartner,"-",PARTN->naz
   if IsPlanika() .and. !EMPTY(cK9)
   	? "Uslov po K9:", cK9
   endif
   ?
   StampaTabele(aKol,{|| FSvakiPRD()},,gTabela,,;
        ,,;
                                {|| FForPRD1()},IF(gOstr=="D",,-1),,,,,)
   FF
   END PRINT
 ELSE
   // kao kartica
   // -----------
   START PRINT CRET

   gnLMarg:=0; gTabela:=1; gOstr:="D"
   PRIVATE cDokum:="", nUlaz:=0, nUlaz2:=0, nIzlaz:=0, nStanje:=0

   aKol:={ { "Dokument"     , {|| cDokum       }, .f., "C", 14, 0, 1, 1},;
           { "Datum"        , {|| DTOC(DATDOK) }, .f., "C",  8, 0, 1, 2},;
           { "Ulaz od"      , {|| nUlaz        }, .t., "N-", 12, 3, 1, 3},;
           { "zadanog"      , {|| "#"          }, .f., "C", 12, 0, 2, 3},;
           { "dobavljaca"   , {|| "#"          }, .f., "C", 12, 0, 3, 3},;
           { "Ulaz"         , {|| nUlaz2       }, .t., "N", 12, 3, 1, 4},;
           { "Izlaz"        , {|| nIzlaz       }, .t., "N", 12, 3, 1, 5},;
           { "Stanje"       , {|| nStanje      }, .f., "N", 12, 3, 1, 6} }

   ?? space(gnLMarg); ?? "KALK: Izvjestaj na dan",date()
   ? space(gnLMarg); IspisFirme("")
   ?
   ? "PREGLED ROBE OD DOBAVLJACA ZA PERIOD OD",dOD,"DO",dDo
   ? "DOBAVLJAC:",cIdPartner,"-",PARTN->naz
   ? "ROBA:",cIdRoba,"-",ROBA->naz
   ?
   StampaTabele(aKol,{|| FSvakiPRD()},,gTabela,,;
        ,,;
                                {|| FForPRD2()},IF(gOstr=="D",,-1),,,,,)
   FF
   END PRINT
 ENDIF

CLOSERET
return
*}




/*! \fn TekRec2()
 *  \brief Prikaz toka filterisanja glavne baze
 */

function TekRec2()
*{
 nSlog++
 @ m_x+1, m_y+2 SAY PADC(ALLTRIM(STR(nSlog))+"/"+ALLTRIM(STR(nUkupno)),20)
 @ m_x+2, m_y+2 SAY "Obuhvaceno: "+STR(cmxKeysIncluded())
return (nil)
*}


/*! \fn FSvakiPRD()
 *  \brief Predvidjeno za dodatnu obradu slogova - koristi je StampaTabele()
 */

function FSvakiPRD()
*{
return
*}




/*! \fn FForPRD1()
 *  \brief Obrada podataka - koristi je StampaTabele()
 *  \return .t. ako se slog prikazuje, .f. - ako se ne prikazuje u tabeli
 */

function FForPRD1()
*{
local cIdR
local dLastNab

cRoba  := IDROBA+"-"+ROBA->naz+"("+ROBA->jmj+")"
cIdR   := idroba
nUlaz  := nStanje := 0
lImaVP := .f.
lIzProsleGod := .f.
nNC:=0
nVPC:=ROBA->vpc
dLastNab:=CTOD("")

do while !EOF() .and. idroba==cIdR
	if mu_i=="1" .and. !(idvd $ "12#22#94") .and. idpartner==cIdPartner
		nUlaz += kolicina-gkolicina-gkolicin2
		if datdok>dLastNab
			nNC:=fcj2
			dLastNab:=datdok
		endif
	endif
	if pu_i=="1" .and. idpartner==cIdPartner
		nUlaz += kolicina-gkolicina-gkolicin2
		if datdok>dLastNab
			nNC:=fcj2
			dLastNab:=datdok
		endif
	endif

	if !EMPTY(mkonto)
		if mu_i=="1" .and. !(idvd $ "12#22#94")
			nStanje += (kolicina-gkolicina-gkolicin2)
			lImaVP:=.t.
		elseif mu_i=="5"
			nStanje -= (kolicina)
			lImaVP:=.t.
		elseif mu_i=="1" .and. (idvd $ "12#22#94")    // povrat
			nStanje -= (-kolicina)
			lImaVP:=.t.
		elseif mu_i=="8"
		endif
	endif

	skip 1
enddo

skip -1

if nUlaz=0 .and. nPrSez>0
	lIzProsleGod:=ImaUProsGod(nPrSez,cIdPartner,cIdR,@nNC)
endif
return (nUlaz<>0.or.lIzProsleGod)
*}




/*! \fn FForPRD2()
 *  \brief Obrada podataka - koristi je StampaTabele()
 *  \return .t. ako se slog prikazuje, .f. - ako se ne prikazuje u tabeli
 */

function FForPRD2()
*{
 LOCAL cIdR
  cDokum := idfirma+"-"+idvd+"-"+brdok
  nUlaz := nUlaz2 := nIzlaz := 0

  IF mu_i=="1" .and. !(idvd $ "12#22#94") .and. idpartner==cIdPartner
    nUlaz += kolicina-gkolicina-gkolicin2
  ENDIF
  IF pu_i=="1" .and. idpartner==cIdPartner
    nUlaz += kolicina-gkolicina-gkolicin2
  ENDIF

  IF !EMPTY(mkonto)
    if mu_i=="1" .and. !(idvd $ "12#22#94")
      nUlaz2 := (kolicina-gkolicina-gkolicin2)
    elseif mu_i=="5"
      nIzlaz := (kolicina)
    elseif mu_i=="1" .and. (idvd $ "12#22#94")    // povrat
      nIzlaz := (-kolicina)
    elseif mu_i=="8"
      nUlaz2 := nIzlaz := -kolicina
    endif
  ELSE
    if pu_i=="1"
      nUlaz2 := (kolicina-GKolicina-GKolicin2)
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nIzlaz := (kolicina)
    elseif pu_i=="I"
      nIzlaz := (gkolicin2)
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nUlaz2 := (-kolicina)
    endif
  ENDIF

  nStanje += (nUlaz2-nIzlaz)
return .t.
*}



function ImaUProsGod(nPrSez,cIdPartner,cIdRoba,nNC)
*{
local lIma
local cPom
local cSez
local nUlaz
local i
local dLastNab
local nArr
lIma:=.f.
nUlaz:=0
dLastNab:=CTOD("")
nArr:=SELECT()
for i:=1 to nPrSez
	cSez:=STR(VAL(goModul:oDatabase:cSezona)-i,4)
	cPom:="KALK"+cSez
	if select(cPom)=0
		select 0
		use (KUMPATH+cSez+SLASH+"KALK.DBF") alias (cPom)
	else
		select (select(cPom))
	endif
	set order to tag "PARM"
	seek cIdPartner+cIdRoba+"1"
	do while !eof() .and. idPartner+idRoba+mu_i==cIdPartner+cIdRoba+"1"
		if !(idvd $ "12#22#94")
			nUlaz += kolicina-gkolicina-gkolicin2
			if datdok>dLastNab
				nNC:=fcj2
				dLastNab:=datdok
			endif
		endif
		skip 1
	enddo
	set order to tag "PARP"
	seek cIdPartner+cIdRoba+"1"
	do while !eof() .and. idPartner+idRoba+pu_i==cIdPartner+cIdRoba+"1"
		nUlaz += kolicina-gkolicina-gkolicin2
		if datdok>dLastNab
			nNC:=fcj2
			dLastNab:=datdok
		endif
		skip 1
	enddo
	if nUlaz<>0
		lIma:=.t.
		exit
	endif
next
select (nArr)
return lIma
*}

