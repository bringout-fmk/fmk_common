#include "\dev\fmk\ld\ld.ch"

// --------------------------------------
// report: pregled plata
// --------------------------------------
function PregPl()
local nC1:=20
local cPrBruto := "N"

cIdRadn:=SPACE(_LR_)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cVarSort:="2"

O_KBENEF
O_VPOSLA
O_RJ
O_RADN
O_LD
O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("VS",@cVarSort)

private cKBenef:=" "
private cVPosla:="  "

cIdMinuli:="17"
cKontrola:="N"
Box(,11,75)
@ m_x+1,m_y+2 SAY Lokal( "Radna jedinica (prazno-sve): ")  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
IF lViseObr
  @ m_x+2,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
ENDIF
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+4,m_y+2 SAY "Koeficijent benef.radnog staza (prazno-svi): "  GET  cKBenef valid empty(cKBenef) .or. P_KBenef(@cKBenef)
@ m_x+5,m_y+2 SAY "Vrsta posla (prazno-svi): "  GET  cVPosla
@ m_x+7,m_y+2 SAY "Sifra primanja minuli: "  GET  cIdMinuli pict "@!"
@ m_x+8,m_y+2 SAY Lokal("Sortirati po(1-sifri,2-prezime+ime)")  GET cVarSort VALID cVarSort$"12"  pict "9"
@ m_x+9,m_y+2 SAY "Prikaz bruto iznosa ?" GET cPrBruto ;
			VALID cPrBruto $ "DN" PICT "@!"
@ m_x+11,m_y+2 SAY "Kontrolisati (neto)+(prim.van neta)-(odbici)=(za isplatu) ? (D/N)" GET cKontrola VALID cKontrola$"DN" PICT "@!"
read; clvbox(); ESC_BCR
BoxC()

 WPar("VS",cVarSort)
 SELECT PARAMS
 USE

if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif

if !empty(ckbenef)
 select kbenef
 hseek  ckbenef
endif
if !empty(cVPosla)
 select vposla
 hseek  cvposla
endif

select ld

//1 - "str(godina)+idrj+str(mjesec)+idradn"
//2 - "str(godina)+str(mjesec)+idradn"

if empty(cidrj)
  cidrj:=""
  IF cVarSort=="1"
    set order to tag (TagVO("2"))
    hseek str(cGodina,4)+str(cmjesec,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")
  ELSE
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="SortPrez(IDRADN)"
     cFilt := IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     IF lViseObr .and. !EMPTY(cObracun)
       cFilt += ".and.OBR=cObracun"
     ENDIF
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
  ENDIF
else
  IF cVarSort=="1"
    set order to tag (TagVO("1"))
    hseek str(cGodina,4)+cidrj+str(cmjesec,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")
  ELSE
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="SortPrez(IDRADN)"
     cFilt := "IDRJ==cIdRj.and."+;
              IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     IF lViseObr .and. !EMPTY(cObracun)
       cFilt += ".and.OBR=cObracun"
     ENDIF
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
  ENDIF
endif


EOF CRET

nStrana:=0
IF gVarPP=="2"
  m:="----- ------ ---------------------------------- ------- ----------- ----------- ----------- ----------- ----------- -----------"
ELSE
  m:="----- ------ ---------------------------------- ------- ----------- ----------- -----------"
ENDIF

if cPrBruto == "D"
	m += " " + REPLICATE("-", 12)
endif

bZagl:={|| ZPregPl() }

select rj
hseek ld->idrj
select ld

START PRINT CRET

P_12CPI

Eval(bZagl)

nRbr:=0
nT2a:=nT2b:=0
nT1:=nT2:=nT3:=nT3b:=nT4:=0
nVanP:=0  // van neta plus
nVanM:=0  // van neta minus
do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec .and.!( lViseObr .and. !EMPTY(cObracun) .and. obr<>cObracun )
	
	if lViseObr .and. EMPTY(cObracun)
   		ScatterS(godina,mjesec,idrj,idradn)
 	else
   		Scatter()
 	endif
 	
	select radn
	hseek _idradn
 	select vposla
	hseek _idvposla
 	select kbenef
	hseek vposla->idkbenef
 	select ld
 	
	if !empty(cvposla) .and. cvposla<>left(_idvposla,2)
   		skip
		loop
 	endif
 	
	if !empty(ckbenef) .and. ckbenef<>kbenef->id
   		skip
		loop
 	endif
	
	nVanP:=0
 	nVanM:=0
 	nMinuli:=0
 	
	for i:=1 to cLDPolja
  		
		cPom:=padl(alltrim(str(i)),2,"0")
  		select tippr
		seek cPom
		select ld

  		if tippr->(found()) .and. tippr->aktivan=="D"
   			
			nIznos:=_i&cpom
   			
			if tippr->uneto=="N" .and. nIznos <> 0
       				
				if nIznos > 0
         				nVanP += nIznos
       				else
         				nVanM += nIznos
       				endif
   			
			elseif tippr->uneto=="D" .and. nIznos <> 0
       				
				if cPom == cIdMinuli
           				nMinuli := nIznos
       				endif
   			
			endif
  		endif
 	next

 	if prow()>58+gPStranica
    		FF
    		Eval(bZagl)
 	endif
 
 	? str(++nRbr,4)+".",idradn, RADNIK
 	nC1:=pcol()+1
 	@ prow(),pcol()+1 SAY _usati  pict gpics
 	if gVarPP=="2"
   		@ prow(),pcol()+1 SAY _uneto-nMinuli  pict gpici
   		@ prow(),pcol()+1 SAY nMinuli  pict gpici
 	endif
 	@ prow(),pcol()+1 SAY _uneto  pict gpici
 	
	if gVarPP=="2"
   		@ prow(),pcol()+1 SAY nVanP   pict gpici
   		@ prow(),pcol()+1 SAY nVanM   pict gpici
 	else
   		@ prow(),pcol()+1 SAY nVanP+nVanM   pict gpici
 	endif
 	
	@ prow(),pcol()+1 SAY _uiznos pict gpici

 	if cKontrola=="D" .and. _uiznos<>_uneto+nVanP+nVanM
   		@ prow(),pcol()+1 SAY "ERR"
 	endif

  	nT1+=_usati
  	nT2a+=_uneto-nMinuli
  	nT2b+=nMinuli
  	nT2+=_uneto
	nT3+=nVanP
	nT3b+=nVanM
	nT4+=_uiznos
 	
	skip
enddo

if prow()>58+gpStranica
	FF
    	Eval(bZagl)
endif

? m
? SPACE(1) + Lokal("UKUPNO:")
@ prow(),nC1 SAY  nT1 pict gpics

IF gVarPP="2"
  @ prow(),pcol()+1 SAY  nT2a pict gpici
  @ prow(),pcol()+1 SAY  nT2b pict gpici
ENDIF

@ prow(),pcol()+1 SAY  nT2 pict gpici

IF gVarPP="2"
  @ prow(),pcol()+1 SAY  nT3 pict gpici
  @ prow(),pcol()+1 SAY  nT3b pict gpici
ELSE
  @ prow(),pcol()+1 SAY  nT3+nT3b pict gpici
ENDIF

@ prow(),pcol()+1 SAY  nT4 pict gpici
? m
FF
END PRINT
CLOSERET


function ZPregPl()

?
P_COND
? UPPER(gTS)+":",gnFirma
?
if empty(cidrj)
 ? Lokal("Pregled za sve RJ ukupno:")
else
 ? Lokal("RJ:"), cIdRj, rj->naz
endif
?? SPACE(2) + Lokal("Mjesec:"),str(cmjesec,2)+IspisObr()
?? SPACE(4) + Lokal("Godina:"),str(cGodina,5)
devpos(prow(),74)
?? Lokal("Str."),str(++nStrana,3)
if !empty(cvposla)
  ? Lokal("Vrsta posla:"),cvposla,"-",vposla->naz
endif
if !empty(cKBenef)
  ? Lokal("Stopa beneficiranog r.st:"),ckbenef,"-",kbenef->naz,":",kbenef->iznos
endif
? m
IF gVarPP=="2"
  ? Lokal(" Rbr * Sifra*         Naziv radnika            *  Sati *   Redovan *  Minuli   *   Neto    *       VAN NETA       * ZA ISPLATU*")
  ? Lokal("     *      *                                  *       *     rad   *   rad     *           * Primanja  * Obustave *           *")
ELSE
  ? Lokal(" Rbr * Sifra*         Naziv radnika            *  Sati *   Neto    *  Odbici   * ZA ISPLATU*")
  ? "     *      *                                  *       *           *           *           *"
ENDIF
? m
return



