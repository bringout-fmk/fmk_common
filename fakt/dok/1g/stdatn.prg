#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdatn.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.10 $
 * $Log: stdatn.prg,v $
 * Revision 1.10  2004/03/18 09:18:01  sasavranic
 * Uslov za radni nalog na pregledu dokumenata te kartici artikla
 *
 * Revision 1.9  2003/04/25 10:44:36  ernad
 * ispravka za Planiku: parametar Cijena13MPC=D vise ne setuje MPC u sifrarniku pri promjeni cijene u unosu 13-ke
 *
 * Revision 1.8  2003/03/29 09:52:39  mirsad
 * Ispravka bug-a na tabelarnom pregledu dokumenata: nakon omoguæavanja uslova za opæinu za tabelarni prikaz poèeo ispadati u situaciji kada se vraæa dokument u pripremu a ne izabere se prelazak u nju
 *
 * Revision 1.7  2003/03/27 15:13:45  mirsad
 * izvjestaj "specif.prodaje" sada radi kao i uslov za opcinu za tabelarni prikaz liste dokumenata
 *
 * Revision 1.6  2002/12/21 11:53:29  mirsad
 * ispravke: f-ja crypt() zamijenjena sa cryptsc() u prikazu kolone operatera
 *
 * Revision 1.5  2002/09/13 12:34:22  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.4  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/18 09:10:57  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/dok/1g/stdatn.prg
 *  \brief 
 */


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_VrstePlacanja
  * \brief Da li koriste sifre vrsta placanja ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_VrstePlacanja;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Da li se koriste sifre opcina?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Cijena13MPC
  * \brief Da li je MPC cijena koja se pamti u dokumentima tipa 13?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_Cijena13MPC;


/*! \fn StDatN()
 *  \brief Stampa azuriranih dokumenta
 */
 
function StDatN()
*{
local nCol1:=0
local nul,nizl,nRbr
local m
private cImekup,cidfirma,qqTipDok,cBrFakDok,qqPartn

private ddatod,ddatdo

private lVrsteP := ( IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D" )
private lOpcine := ( IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D" )

if lVrsteP
 	O_VRSTEP
endif

IF lOpcine
  	O_OPS
ENDIF

if glRadNal
	O_RNAL
	O_FAKT
endif

O_PARTN
O_DOKS

if lVrsteP
  	SET RELATION TO idvrstep INTO VRSTEP
endif

if lOpcine
  	SET RELATION TO idpartner INTO PARTN
endif

if glRadNal
	SET RELATION TO idfirma+idtipdok+brdok INTO FAKT
endif

if PrazanDBF()
  Beep(1)
  O_VALUTE
  O_FAKT

  select fakt
  go top

  do while !eof()
    select doks
    append blank
    select fakt

    cIDFirma:=idfirma
    private cBrDok:=BrDok,cIdTipDok:=IdTipDok,dDatDok:=datdok
    aMemo:=ParsMemo(txt)
    if len(aMemo)>=5
      cTxt:=trim(amemo[3])+" "+trim(amemo[4])+","+trim(amemo[5])
    else
      cTxt:=""
    endif
    cTxt:=padr(cTxt,30)

    nDug:=nRab:=0
    nDugD:=nRabD:=0
    cDinDem:=dindem
    cRezerv:=" "
    if cidtipdok $ "10#20#27" .and. left(Serbr,1)=="*"
      cRezerv:="*"
    endif
    select doks
    replace idfirma with cidfirma, brdok with cbrdok,;
            rezerv with cRezerv, datdok with ddatdok, idtipdok with cidtipdok,;
            partner with cTxt, dindem with cdindem, ;
            IdPartner with FAKT->IdPartner
    IF lVrsteP
      REPLACE idvrstep WITH FAKT->idvrstep
    ENDIF
    IF FIELDPOS("DATPL")>0
      REPLACE datpl WITH IF(LEN(aMemo)>=9,CTOD(aMemo[9]),CTOD(""))
    ENDIF
    select fakt

    do while !eof() .and. cIdFirma==IdFirma .and. cIdTipdok==IdTipDok .and. cBrDok==BrDok
      if cdindem==left(ValBazna(),3)
        nDug+=ROUND( kolicina*Cijena*(1-Rabat/100)*(1+Porez/100) ,ZAOKRUZENJE)
        nRab+=ROUND( kolicina*Cijena*Rabat/100 ,ZAOKRUZENJE)

      else
        nDugD+=round( kolicina*Cijena*1/UBaznuValutu(datdok)*(1-Rabat/100)*(1+Porez/100) ,ZAOKRUZENJE)
        nRabD+=round( kolicina*Cijena*Rabat/100*1/UBaznuValutu(datdok),ZAOKRUZENJE)
      endif
      skip
    enddo

    select doks
    if cDinDem==left(ValBazna(),3)
      replace iznos with nDug
      replace rabat with nRab
    else
      replace iznos with nDugD
      replace rabat with nRabD
    endif
    replace DINDEM with cDinDEM
    select fakt

  enddo

  select valute; use
  select fakt; use
endif
// generacija izvjestaja

O_VALUTE
O_RJ

qqVrsteP := SPACE(20)
dDatVal0 := dDatVal1 := CTOD("")

cIdfirma:=gFirma
dDatOd:=ctod("")
dDatDo:=date()
qqTipDok:=""
Box(,12+IF(lVrsteP .or. lOpcine .or. glRadNal,6,0),77)

O_PARAMS
private cSection:="N",cHistory:=" "; aHistory:={}
//Params1()
RPar("c1",@cIdFirma)
RPar("c2",@qqTipDok)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
cTabela:="N"
cBrFakDok:=SPACE(40)
cImeKup:=space(20)
cOpcina:=SPACE(30)
if glRadNal
	cRadniNalog:=SPACE(10)
endif
qqPartn:=space(20)
RPar("TA",@cTabela)
RPar("KU",@cImeKup)
RPar("sk",@qqPartn)
RPar("BD",@cBrFakDok)
cImeKup:=padr(cImeKup,20)
qqPartn:=padr(qqPartn,20)

qqTipDok:=padr(qqTipDok,2)

do while .t.
 if gNW$"DR"
   cIdFirma:=padr(cidfirma,2)
   @ m_x+1,m_y+2 SAY "RJ prazno svi" GET cIdFirma valid {|| empty(cidfirma) .or. cidfirma==gfirma .or. P_RJ(@cIdFirma) }
   read
 else
   @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 if !empty(cidfirma)
    @ m_x+2,m_y+2 SAY "Tip dokumenta (prazno svi tipovi)" GET qqTipDok pict "@!"
    qqtipdok:="  "
 else
    cIdfirma:=""
    qqtipdok:="  "
 endif
 @ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
 @ m_x+3,col()+1 SAY "do"  get dDatDo
 @ m_x+5,m_y+2 SAY "Ime kupca pocinje sa (prazno svi)"  get cImeKup pict "@!"
 @ m_x+6,m_y+2 SAY "Uslov po sifri kupca (prazno svi)"  get qqPartn pict "@!" ;
    valid {|| aUslSK:=Parsiraj(@qqPartn,"IDPARTNER","C",NIL,F_PARTN), .t.}
 @ m_x+7,m_y+2 SAY "Broj dokumenta (prazno svi)"  get cBrFakDok pict "@!"
 @ m_x+9,m_y+2 SAY "Tabelarni pregled"  get cTabela valid cTabela $ "DN" pict "@!"
 cRTarifa:="N"
 @ m_x+11,m_y+2 SAY "Rekapitulacija po tarifama ?"  get cRTarifa valid cRtarifa $"DN" pict "@!"
 IF lVrsteP
   @ m_x+12,m_y+2 SAY "----------------------------------------"
   @ m_x+13,m_y+2 SAY "Za fakture (Tip dok.10):"
   @ m_x+14,m_y+2 SAY "Nacin placanja:" GET qqVrsteP
   @ m_x+15,m_y+2 SAY "Datum valutiranja od" GET dDatVal0
   @ m_x+15,col()+2 SAY "do" GET dDatVal1
   @ m_x+16,m_y+2 SAY "----------------------------------------"
 ENDIF
 if lOpcine
   @ m_x+17,m_y+2 SAY "Opcina (prazno-sve): "  get cOpcina
 endif
 if glRadNal
   @ m_x+18,m_y+2 SAY "Radni nalog (prazno-svi): "  get cRadniNalog valid EMPTY(cRadniNalog) .or. P_RNal(@cRadniNalog)
 endif
 
 read
 ESC_BCR
 aUslBFD:=Parsiraj(cBrFakDok,"BRDOK","C")
 aUslSK:=Parsiraj(qqPartn,"IDPARTNER","C")
 aUslVrsteP:=Parsiraj(qqVrsteP,"IDVRSTEP","C")
 if lOpcine
   aUslOpc:=Parsiraj(cOpcina,"IDOPS","C")
 endif
 if glRadNal
 	//aUslRadNal:=
 endif
 if (!lOpcine .or. aUslOpc <> NIL) .and. aUslBFD<>NIL .and. aUslSK<>NIL .and. (!lVrsteP.or.aUslVrsteP<>NIL)
 	exit
 endif
enddo

altd()

qqTipDok:=trim(qqTipDok)
qqPartn:=trim(qqPartn)
Params2()
WPar("c1",cIdFirma)
WPar("c2",qqTipDok)
WPar("d1",dDatOd)
WPar("d2",dDatDo)
WPar("TA",cTabela)
WPar("KU",cImeKup)
WPar("sk",qqPartn)
WPar("BD",cBrFakDok)
select params; use

BoxC()

select doks

Private cFilter:=".t."

IF !EMPTY(dDatVal0) .or. !EMPTY(dDatVal1)
  cFilter+=".and. (!idtipdok='10'.or.datpl>="+cm2str(dDatVal0)+".and. datpl<="+cm2str(dDatVal1)+")"
ENDIF

IF !EMPTY(qqVrsteP)
  cFilter += ".and. (!idtipdok='10'.or."+aUslVrsteP+")"
ENDIF

if !empty(qqTipDok)
   cFilter+=".and. idtipdok=="+cm2str(qqTipDok)
endif
if !empty(dDatOd) .or. !empty(dDatDo)
  cFilter+=".and.  datdok>="+cm2str(dDatOd)+".and. datdok<="+cm2str(dDatDo)
endif

if cTabela=="D"  // tabel prikaz

  if !empty(cimekup)
    cFilter+=".and. partner="+cm2str(trim(cImeKup))
  endif

  cFilter+=".and. IdFirma="+cm2str(cIdFirma)

  if lOpcine
    cFilter+=".and. PARTN->("+aUslOpc+")"
  endif

endif

// ako je rijec o radnim nalozima postavi filter u tabeli FAKT na polje idrnal
if glRadNal .and. !Empty(cRadniNalog)
  	cFilter+=".and. FAKT->idrnal="+Cm2Str(cRadniNalog)
endif

if !empty(cBrFakDok)
  cFilter+=".and."+aUslBFD
endif

if !empty(qqPartn)
  cFilter+=".and."+aUslSK
endif


if cFilter=".t..and."
  cFilter:=substr(cFilter,9)
endif

if cFilter==".t."
  set Filter to
else
  set Filter to &cFilter
endif

#ifdef CAX
  @ 22,77 SAY str(aofGetOptlevel(),2)
#else
  @ 22,77 SAY str(rloptlevel(),2)
#endif

qqTipDok:=trim(qqTipDok)

seek cIdFirma+qqTipDok

EOF CRET


if cTabela=="D"

   ImeKol:={}
   AADD(ImeKol,{ "RJ",       {|| idfirma}                         })
   AADD(ImeKol,{ "VD",       {|| idtipdok}                         })
   AADD(ImeKol,{ "Brdok",    {|| brdok+rezerv}                         })
   AADD(ImeKol,{ "Datum",    {|| Datdok}                         })
   AADD(ImeKol,{ "Partner",    {|| iif(m1="Z","<<dok u pripremi>>",partner)} })
   AADD(ImeKol,{ "Ukupno-Rab ",    {|| iznos} })
   AADD(ImeKol,{ "Rabat",    {|| rabat} })
   AADD(ImeKol,{ "Ukupno",    {|| iznos+rabat} })
   IF lVrsteP
     AADD(ImeKol,{ "Nacin placanja", {|| idvrstep} })
   ENDIF
   IF FIELDPOS("DATPL")>0
     AADD(ImeKol,{ "Datum placanja", {|| datpl} })
   ENDIF
   Kol:={}; for i:=1 to len(ImeKol); AADD(Kol,i); next
   Box(,20,72)
   @ m_x+19,m_y+2 SAY " <ENTER> Stampa dokumenta       ³<P> Povrat dokumenta u pripremu³"
   @ m_x+20,m_y+2 SAY " <R>     Rezervacija/Realizacija³"
   fUPripremu:=.f.

   adImeKol:={}

   private  bGoreRed:=NIL
   private  bDoleRed:=NIL
   private  bDodajRed:=NIL
   private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
   private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
   private  TBAppend:="N"  // mogu dodavati slogove
   private  bZaglavlje:=NIL
           // zaglavlje se edituje kada je kursor u prvoj koloni
           // prvog reda
   private  TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
   private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
   private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
   private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                           // ovo se mo§e setovati u when/valid fjama

   private  TBScatter:="N"  // uzmi samo teku†e polje
   for i:=1 TO LEN(ImeKol); AADD(adImeKol,ImeKol[i]); next
   ASIZE(adImeKol,LEN(adImeKol)+1)
   AINS(adImeKol,6)
   adImeKol[6] := { "ID PARTNER" , {|| idpartner}, "idpartner", ;
                   {|| .t.}, {|| P_Firma(@widpartner)}, "V" }
   adKol:={}; for i:=1 to len(adImeKol); AADD(adKol,i); next

   ObjDbedit("",20,72,{|| EdDatn()},"","Lista dokumenata...", , , , ,2)
   BoxC()
   if fupripremu
     close all
     Knjiz()
   endif
   closeret
endif

gaZagFix:={3,3}
START PRINT CRET
?? space(gnLMarg)
P_COND
?? "FAKT: Stampa dokumenata na dan:",date(),space(10),"za period",dDatOd,"-",dDatDo
? space(gnLMarg)
IspisFirme(cidfirma)
if !empty(qqTipDok)
	?? SPACE(2), "za tipove dokumenta:",trim(qqTipDok)
endif
if glRadNal .and. !Empty(cRadniNalog)
	?? SPACE(2), "uslov po radnom nalogu: ", TRIM(cRadniNalog)
	? GetNameRNal(cRadniNalog)
endif

m:="----- -------- -- -- --------- ------------------------------ ------------ ------------ ------------ ---"
if fieldpos("SIFRA")<>0
	m+=" --"
endif
if lVrsteP
  	m+=" -------"
endif
if fieldpos("DATPL")<>0
  	m+=" --------"
endif

? space(gnLMarg)
?? m
? space(gnLMarg)
?? "  Rbr Dat.Dok  RJ TD Br.Dok   Partner                            Ukupno       Rabat         UKUPNO   VAL"
if fieldpos("SIFRA")<>0
	?? " OP"
endif
if lVrsteP
  	?? " Nac.pl."
endif
if fieldpos("DATPL")<>0
  	?? " Dat.pl. "
endif

? space(gnLMarg)
?? m

nC:=0
nIznos:=nRab:=0
nIznosD:=nRabD:=0
nIznos3:=nRab3:=0
private cRezerv:=" "
cImeKup:=trim(cimekup)
do while !eof() .and. IdFirma=cIdFirma
  cDinDem:=dindem
  if !empty(cimekup)
     if !(partner=cimekup)
        skip; loop
     endif
  endif
  if lOpcine
      SELECT PARTN; HSEEK DOKS->idpartner; SELECT DOKS
      if !(PARTN->(&aUslOpc))
         skip; loop
      endif
  endif

  ? space(gnLMarg); ?? Str(++nC,4)+".",datdok,idfirma,idtipdok,brdok+Rezerv+" "
  IF m1 <> "Z"
     ?? partner
  ELSE
     ?? PADR ("<<dokument u pripremi>>", LEN (partner))
  ENDIF
  nCol1:=pcol()+1
  if cDinDem==left(ValBazna(),3)
   @ prow(),pcol()+1 SAY str(iznos+rabat,12,2)
   @ prow(),pcol()+1 SAY str(Rabat,12,2)
   @ prow(),pcol()+1 SAY str(ROUND(iznos,gFZaok),12,2)
   nIznos+=ROUND(iznos,gFZaok)
   nRab+=rabat
   nIznos3+=ROUND(iznos,gFZaok)
   nRab3+=rabat
  else
   @ prow(),pcol()+1 SAY str(iznos+rabat,12,2)
   @ prow(),pcol()+1 SAY str(Rabat,12,2)
   @ prow(),pcol()+1 SAY str(ROUND(iznos,gFZaok),12,2)
   nIznosD+=ROUND(iznos,gFZaok)
   nRabD+=rabat
   nIznos3+=ROUND(iznos*UBaznuValutu(datdok),gFZaok)
   nRab3+=rabat*UBaznuValutu(datdok)
  endif
  @ prow(),pcol()+1 SAY cDinDEM
  if fieldpos("SIFRA")<>0
    @ prow(),pcol()+1 SAY iif(empty(sifra),space(2),left(CryptSC(sifra),2))
  endif
  if lVrsteP
    @ prow(),pcol()+1 SAY idvrstep+"-"+LEFT(VRSTEP->naz,4)
  endif
  if fieldpos("DATPL")<>0
    @ prow(),pcol()+1 SAY datpl
  endif
  skip
enddo


? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+ValBazna()+":"
@ prow(),nCol1    SAY  STR(nIznos+nRab,12,2)
@ prow(),pcol()+1 SAY  STR(nRab,12,2)
@ prow(),pcol()+1 SAY  STR(nIznos,12,2)
@ prow(),pcol()+1 SAY  LEFT(ValBazna(),3)
? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+ValSekund()+":"
@ prow(),nCol1    SAY  STR(nIznosD+nRabD,12,2)
@ prow(),pcol()+1 SAY  STR(nRabD,12,2)
@ prow(),pcol()+1 SAY  STR(nIznosD,12,2)
@ prow(),pcol()+1 SAY  LEFT(ValSekund(),3)
? space(gnLMarg);?? m
? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+valbazna()+"+"+valsekund()+":"
@ prow(),nCol1    SAY  STR(nIznos3+nRab3,12,2)
@ prow(),pcol()+1 SAY  STR(nRab3,12,2)
@ prow(),pcol()+1 SAY  STR(nIznos3,12,2)
@ prow(),pcol()+1 SAY  LEFT(VAlBazna(),3)
? space(gnLMarg);?? m

set filter to  // ukini filter

if cRTarifa=="D" .and. empty(cImeKup) .and. qqTipDok $ "11#13#27"  // racun maloprodaje ili otpremnice u mp
  // ne moze se zadati za jednog kupca
  O_TARIFA
  O_SIFK; O_SIFV
  O_ROBA
  O_FAKT

  // zakaci se na roba!
  set relation to idroba into roba  
  cFilter+=".and. IdFirma="+cm2str(cIdFirma)

  index on roba->idtarifa to FaktTar for &cFilter  // pomocni index na tarifu!

  IF qqTipDok=="13"
    IF glCij13Mpc
      cpmp:="9"
    ELSEIF EMPTY(g13dcij) .and. gVar13!="2"
     Box(,1,50)
      cpmp:="9"
      @ m_x+1,m_y+2 SAY "Prikaz MPC ( 1/2/3/4/5/6/9 iz fakt-a) " GET cPMP valid cpmp $ "1234569"
      read
     BoxC()
    ELSE
     cPMP:=g13dcij
    ENDIF
  ELSE
    cpmp:="9"
  ENDIF

  RekTarife(cPMP)
  select fakt; use
endif

FF
END PRINT

closeret
*}


/*! \fn EdDatN()
 *  \brief Ispravka azuriranih dokumenata (u tabelarnom pregledu)
 */
 
function EdDatn()
*{
local nRet:=DE_CONT
do case
  case Ch==K_ALT_E
     IF gTBDir=="D"
        gTBDir:="N"
        NeTBDirektni()  // ELIB, vrati stari tbrowse
     ELSE
       IF Pitanje(,"Preci u mod direktog unosa podataka u tabelu? (D/N)","D")=="D"
         gTBDir:="D"
         select(F_PARTN); if !used(); O_PARTN; endif
         select DOKS
         DaTBDirektni() // ELIB, promjeni tbrowse na edit rezim
       ENDIF
     ENDIF
  case Ch==K_ENTER .and. gTBDir=="N"
     select doks
     nTrec:=recno()
     _cIdFirma:=idfirma
     _cIdTipDok:=idtipdok
     _cBrDok:=brdok
     close all
     O_Edit()
     StampTXT(_cidfirma,_cIdTipdok,_cbrdok)
     select (F_DOKS); use
     O_DOKS
     if lOpcine
       O_PARTN
       select DOKS
       set relation to idpartner into PARTN
     endif
     if cFilter==".t."
       set Filter to
     else
       set Filter to &cFilter
     endif
     go nTrec
     nRet:=DE_CONT
  case chr(Ch) $ "pP" .and. gTBDir=="N"  // povrat
     select doks
     nTrec:=recno()
     _cIdFirma:=idfirma
     _cIdTipDok:=idtipdok
     _cBrDok:=brdok
     close all
     Povrat(.f.,_cidfirma,_cIdTipdok,_cbrdok)
     select (F_DOKS)
     use
     O_DOKS
     if lOpcine
       O_PARTN
       select DOKS
       set relation to idpartner into PARTN
     endif
     if cFilter==".t."
       set Filter to
     else
       set Filter to &cFilter
     endif
     go nTrec
     if Pitanje(,"Preci u tabelu pripreme ?","D")=="D"
      fUPripremu:=.t.
      nRet:=DE_ABORT
     else
      nRet:=DE_REFRESH
     endif
  case chr(Ch) $ "rR" .and. gTBDir=="N"  // povrat
     select doks
     nTrec      := recno()
     _cIdFirma  := idfirma
     _cIdTipDok := idtipdok
     _cBrDok    := brdok
     close all
     if _cidtipdok$"20#27"
       Povrat(.t.,_cidfirma,_cIdTipdok,_cbrdok)
     elseif _cidtipdok $ "01#19"
       O_DOKS
       seek _cidfirma+_cidtipdok+_cbrdok
       if rezerv="*"
         cZnak:=""
       else
         cZnak:="*"
       endif
       do while !eof() .and. idfirma+idtipdok+brdok==_cidfirma+_cidtipdok+_cbrdok
          replace rezerv with cZnak
          skip
       enddo
       O_FAKT
       seek  _cidfirma+_cidtipdok+_cbrdok
       do while !eof() .and. idfirma+idtipdok+brdok==_cidfirma+_cidtipdok+_cbrdok
          replace serbr with cznak
          skip
       enddo
       close all
     endif
     select (F_DOKS)
     use
     O_DOKS
     if lOpcine
       O_PARTN
       select DOKS
       set relation to idpartner into PARTN
     endif
     if cFilter==".t."
        set Filter to
     else
        set Filter to &cFilter
     endif
     go nTrec
     nRet:=DE_REFRESH

endcase
return nRet
*}


/*! \fn RekTarife(cPMP,cRegion)
 *  \brief Rekapitulacija po tarifama
 *  \todo Prebaciti u /RPT
 *  \param cPMP
 *  \param cRegion
 */
 
function RekTarife(cPMP,cRegion)
*{
// prosljedjuje cidfirma,cidvd,cbrdok
local nArea:=select()

if cRegion==NIL
	cRegion:=" "
ENDIF

if cPMP==NIL
  cPMP:="0"
endif

private gPicProc:="999999.99%"
private gPicDEM:= "9999999.99"


IF prow()>55+gPStranica; FF; endif
// @ prow(),123 SAY "Str:"+str(++nStr,3);  endif
nRec:=recno()

?
? space(gNlMarg)+"Rekapitulacija po tarifama:"
m:=space(gNlMarg)+"------ ---------- ---------- ----------  ---------- ---------- ---------- ---------- ----------"
? m
? space(gNlMarg)+"* Tar *  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *   PP     * MPVSAPP *"
? m
nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
do while !eof()
  // cidtarifa:=roba->idtarifa
  IF cRegion=="3"
    cidtarifa:=roba->idtarifa3
    bTar:={|| !eof() .and. roba->idtarifa3==cidtarifa}
  ELSEIF cRegion=="2"
    cidtarifa:=roba->idtarifa2
    bTar:={|| !eof() .and. roba->idtarifa2==cidtarifa}
  ELSE
    cidtarifa:=roba->idtarifa
    bTar:={|| !eof() .and. roba->idtarifa==cidtarifa}
  ENDIF
  nU1:=nU2:=nU2b:=0
  nU3:=nU4:=0
  select tarifa
  hseek cidtarifa
  select (nArea)
  do while EVAL(bTar)
    NSRNPIdRoba((nArea)->idroba)
    select (nArea)
    _Cijena:=cijena
    if idtipdok=="13"
         if cPMP=="2"
           _cijena:=roba->mpc2
         elseif cPMP=="3"
           _cijena:=roba->mpc3
         elseif cPMP=="4"
           _cijena:=roba->mpc4
         elseif cPMP=="5"
           _cijena:=roba->mpc5
         elseif cPMP=="6"
           _cijena:=roba->mpc6
         elseif cPMP=="1"
           _cijena:=roba->mpc
         else
           _cijena:=(nArea)->cijena
         endif
    endif
    VtPorezi()

    // TODO: Opet ces imati problem zaokruzenja
    nU1+=round(_cijena*kolicina/(_ZPP+(1+_opp)*(1+_ppp)) ,ZAOKRUZENJE)
    nU2+=round(_cijena*kolicina/(_ZPP+(1+_opp)*(1+_ppp))*_OPP  ,ZAOKRUZENJE)
    nU2b+=round(_cijena*kolicina/(_ZPP+(1+_opp)*(1+_ppp))*_ZPP ,ZAOKRUZENJE)
    nU3+=round(_cijena*kolicina/(_ZPP+(1+_opp)*(1+_ppp))*(1+_opp)*_PPP ,ZAOKRUZENJE)
    nU4+=round(_cijena*kolicina ,ZAOKRUZENJE)
    skip
  enddo
  nTot1+=nu1; nTot2+=nU2;nTot2b+=nU2b; nTot3+=nU3
  nTot4+=nU4
  ? space(gNlMarg)+cidtarifa
  @ prow(),pcol()+1   SAY (_OPP*100) pict gpicproc
  @ prow(),pcol()+1   SAY (_PPP*100) pict gpicproc
  @ prow(),pcol()+1   SAY (_ZPP*100) pict gpicproc
  nCol1:=pcol()+1
  @ prow(),pcol()+1   SAY nu1  pict gpicdem
  @ prow(),pcol()+1   SAY nu2  pict gpicdem
  @ prow(),pcol()+1   SAY nu3  pict gpicdem
  @ prow(),pcol()+1   SAY nu2b pict gpicdem
  @ prow(),pcol()+1   SAY nu4  pict gpicdem
enddo
? m
? space(gNlMarg)+"UKUPNO"
@ prow(),nCol1      SAY nTot1 pict gpicdem
@ prow(),pcol()+1   SAY nTot2 pict gpicdem
@ prow(),pcol()+1   SAY nTot3 pict gpicdem
@ prow(),pcol()+1   SAY nTot2b pict gpicdem
@ prow(),pcol()+1   SAY nTot4 pict gpicdem
? m

return
*}



/*! \fn VTPorezi()
 *  \brief Smjesta poreze iz tarifa u javne varijable
 */

function VTPorezi()
*{
public _ZPP:=0
if roba->tip=="V"
  public _OPP:=0,_PPP:=tarifa->ppp/100
  public _PORVT:=tarifa->opp/100
elseif roba->tip=="K"
  public _OPP:=tarifa->opp/100,_PPP:=tarifa->ppp/100
  public _PORVT:=tarifa->opp/100
else
  public _OPP:=tarifa->opp/100
  public _PPP:=tarifa->ppp/100
  public _ZPP:=tarifa->zpp/100
  public _PORVT:=0
endif
return
*}


/*! \fn RealPartn()
 *  \brief Realizacija po partnerima
 *  \todo Prebaciti u /RPT
 */

function RealPartn()
*{
O_DOKS
O_PARTN
O_VALUTE
O_RJ

cIdfirma:=gFirma
dDatOd:=ctod("")
dDatDo:=date()
qqTipDok:="10;"
Box(,11,77)

O_PARAMS
private cSection:="N",cHistory:=" "; aHistory:={}
//Params1()
RPar("c1",@cIdFirma)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
cTabela:="N"
cBrFakDok:=SPACE(40)
cImeKup:=space(20)
qqPartn:=space(20)
RPar("TA",@cTabela)
RPar("KU",@cImeKup)
RPar("sk",@qqPartn)
RPar("BD",@cBrFakDok)
qqPartn:=padr(qqPartn,20)

qqTipDok:=padr(qqTipDok,40)
do while .t.
 cIdFirma:=padr(cidfirma,2)
 @ m_x+1,m_y+2 SAY "RJ            " GET cIdFirma valid {|| empty(cidfirma) .or. cidfirma==gfirma .or. P_RJ(@cIdFirma) }
 @ m_x+2,m_y+2 SAY "Tip dokumenta " GET qqTipDok pict "@!S20"
 @ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
 @ m_x+3,col()+1 SAY "do"  get dDatDo
 @ m_x+6,m_y+2 SAY "Uslov po sifri kupca (prazno svi)"  get qqPartn pict "@!"
 @ m_x+7,m_y+2 SAY "Broj dokumenta (prazno svi)"  get cBrFakDok pict "@!"
 read
 ESC_BCR
 aUslBFD:=Parsiraj(cBrFakDok,"BRDOK","C")
 aUslSK:=Parsiraj(qqPartn,"IDPARTNER","C")
 aUslTD:=Parsiraj(qqTipdok,"IdTipdok","C")
 altd()
 if aUslBFD<>NIL .and. aUslSK<>NIL .and. aUslTD<>NIL; exit; endif
enddo

qqTipDok:=trim(qqTipDok)
qqPartn:=trim(qqPartn)
Params2()
WPar("c1",cIdFirma)
WPar("d1",dDatOd)
WPar("d2",dDatDo)
WPar("TA",cTabela)
WPar("sk",qqPartn)
WPar("BD",cBrFakDok)
select params; use

BoxC()

select doks

Private cFilter:=".t."

if !empty(dDatOd) .or. !empty(dDatDo)
  cFilter+=".and.  datdok>="+cm2str(dDatOd)+".and. datdok<="+cm2str(dDatDo)
endif

if cTabela=="D"  // tabel prikaz


  cFilter+=".and. IdFirma="+cm2str(cIdFirma)

endif

if !empty(cBrFakDok)
  cFilter+=".and."+aUslBFD
endif

if !empty(qqPartn)
  cFilter+=".and."+aUslSK
endif

if !empty(qqTipDok)
  cFilter+=".and."+aUslTD
endif

if cFilter=".t..and."
  cFilter:=substr(cFilter,9)
endif

if cFilter==".t."
  set Filter to
else
  set Filter to &cFilter
endif



EOF CRET

//gaZagFix:={3,3}
START PRINT CRET


private nStrana:=0
private m:="---- ------ -------------------------- ------------ ------------ ------------"
ZaglRPartn()

set order to 6
//"6","IdFirma+idpartner+idtipdok",KUMPATH+"DOKS"
seek cIdFirma

nC:=0
ncol1:=10
nTIznos:=nTRabat:=0
private cRezerv:=" "
do while !eof() .and. IdFirma=cIdFirma

  nIznos:=0; nRabat:=0
  cIdPartner:=idpartner
  do while !eof() .and. IdFirma=cIdFirma .and. idpartner==cIdpartner

    if DinDem==left(ValBazna(),3)
      nIznos+=ROUND(iznos,ZAOKRUZENJE)
      nRabat+=ROUND(Rabat,ZAOKRUZENJE)
    else
      nIznos+=ROUND(iznos*UBaznuValutu(datdok),ZAOKRUZENJE)
      nRabat+=ROUND(Rabat*UBaznuValutu(datdok),ZAOKRUZENJE)
    endif

    skip
  enddo

  if prow()>61; FF; ZaglRPartn(); endif

  select partn; hseek cidpartner; select doks
  ? space(gnLMarg); ?? Str(++nC,4)+".", cidpartner, partn->naz
  nCol1:=pcol()+1
  @ prow(),pcol()+1 SAY str(nIznos+nRabat,12,2)
  @ prow(),pcol()+1 SAY str(nRabat,12,2)
  @ prow(),pcol()+1 SAY str(nIznos,12,2)

  ntIznos+=nIznos
  ntRabat+=nRabat
enddo

if prow()>59; FF; ZaglRPartn(); endif
? space(gnLMarg);?? m
? space(gnLMarg); ?? " Ukupno"
  @ prow(),nCol1    SAY str(ntIznos+ntRabat,12,2)
  @ prow(),pcol()+1 SAY str(ntRabat,12,2)
  @ prow(),pcol()+1 SAY str(ntIznos,12,2)
? space(gnLMarg);?? m

set filter to  // ukini filter

FF
END PRINT

return
*}



/*! \fn ZaglRPartn()
 *  \brief Zaglavlje izvjestaja realizacije partnera 
 *  \todo Prebaciti u /RPT
 */
 
function ZaglRPartn()
*{
? space(gnLMarg); IspisFirme(cidfirma)
?
set century on
P_12CPI
? space(gnLMarg); ?? "FAKT: Stampa prometa partnera na dan:",date(),space(8),"Strana:",STR(++nStrana,3)
? space(gnLMarg); ?? "      period:",dDatOd,"-",dDatDo
if qqTipDok<>"10;"
 ? space(gnLMarg); ?? "-izvjestaj za tipove dokumenata :",trim(qqTipDok)
endif

set century off
P_12CPI
? space(gnLMarg); ?? m
? space(gnLMarg); ?? " Rbr  Sifra     Partner                  Ukupno        Rabat          UKUPNO"
? space(gnLMarg); ?? "                                           (1)          (2)            (1-2)"
? space(gnLMarg); ?? m

return
*}

