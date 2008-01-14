#include "\dev\fmk\ld\ld.ch"

function PregPrim()
*{
local nC1:=20

cIdRadn:=space(_LR_)
cIdRj:=gRj; cmjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cVarSort:="2"
lKredit:=.f.
cSifKred:=""

nRbr:=0
O_RJ
O_RADN
O_LD

private cTip:="  "

cDod:="N"
cKolona:=SPACE(20)

O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("VS",@cVarSort)

Box(,7,45)
@ m_x+1,m_y+2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
if lViseObr
  @ m_x+2,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+4,m_y+2 SAY "Tip primanja: "  GET  cTip
@ m_x+5,m_y+2 SAY "Prikaz dodatnu kolonu: "  GET  cDod pict "@!" valid cdod $ "DN"
@ m_x+6,m_y+2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort$"12"  pict "9"
read; clvbox(); ESC_BCR
if cDod=="D"
 @ m_x+7,m_y+2 SAY "Naziv kolone:" GET cKolona
 read
endif
ckolona:="radn->"+ckolona
BoxC()

 WPar("VS",cVarSort)
 SELECT PARAMS; USE

if lViseObr
 O_TIPPRN
else
 O_TIPPR
endif

select tippr
hseek ctip
EOF CRET

IF "SUMKREDITA" $ formula
  // radi se o kreditu, upitajmo da li je potreban prikaz samo za
  // jednog kreditora
  // ------------------------------------------------------------
  lKredit:=.t.
  O_KRED
  cSifKred:=SPACE(LEN(id))
  Box(,6,75)
   @ m_x+2, m_y+2 SAY "Izabrani tip primanja je kredit ili se tretira na isti nacin kao i kredit."
   @ m_x+3, m_y+2 SAY "Ako zelite mozete dobiti spisak samo za jednog kreditora."
   @ m_x+5, m_y+2 SAY "Kreditor (prazno-svi zajedno)" GET cSifKred  valid EMPTY(cSifKred).or.P_Kred(@cSifKred) PICT "@!"
   READ
  BoxC()
ENDIF

IF !EMPTY(cSifKred)
  O_RADKR
  SET ORDER TO TAG "1"
ENDIF

select ld

if lViseObr
  cObracun:=TRIM(cObracun)
else
  cObracun:=""
endif

if empty(cidrj)
  cidrj:=""
  IF cVarSort=="1"
    set order to tag (TagVO("2"))
    hseek str(cGodina,4)+str(cmjesec,2)+cObracun
  ELSE
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="SortPrez(IDRADN)"
     cFilt := IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     if lViseObr
       cFilt += ".and. OBR=cObracun"
     endif
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
  ENDIF
else
  IF cVarSort=="1"
    set order to tag (TagVO("1"))
    hseek str(cGodina,4)+cidrj+str(cmjesec,2)+cObracun
  ELSE
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="SortPrez(IDRADN)"
     cFilt := "IDRJ==cIdRj.and."+;
              IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     if lViseObr
       cFilt += ".and. OBR=cObracun"
     endif
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
  ENDIF
endif

EOF CRET

nStrana:=0
m:="----- "+replicate("-",_LR_)+" ---------------------------------- "+IF(lKredit.and.!EMPTY(cSifKred),REPL("-",LEN(RADKR->naosnovu)+1),"-"+REPL("-", LEN(gPicS) ))+" ----------- -----------"
if cdod=="D"
 if type(ckolona) $ "UUIUE"
     Msg("Nepostojeca kolona")
     closeret
 endif
endif
bZagl:={|| ZPregPrim() }

select rj; hseek ld->idrj; select ld

START PRINT CRET
P_10CPI

Eval(bZagl)

nRbr:=0
nT1:=nT2:=nT3:=nT4:=0
nC1:=10

do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec .and.;
         !( lViseObr .and. !EMPTY(cObracun) .and. obr<>cObracun )

 if lViseObr .and. EMPTY(cObracun)
   ScatterS(godina,mjesec,idrj,idradn)
 else
   Scatter()
 endif

 IF lKredit .and. !EMPTY(cSifKred)
   // provjerimo da li otplacuje zadanom kreditoru
   // --------------------------------------------
   SELECT RADKR
   SEEK str(cgodina,4)+str(cmjesec,2)+LD->idradn+cSifKred
   lImaJos:=.f.
   DO WHILE !EOF() .and. str(cgodina,4)+str(cmjesec,2)+LD->idradn+cSifKred == str(godina,4)+str(mjesec,2)+idradn+idkred
     IF placeno>0
       lImaJos:=.t.
       EXIT
     ENDIF
     SKIP 1
   ENDDO
   IF !lImaJos
     SELECT LD; SKIP 1; LOOP
   ELSE
     SELECT LD
   ENDIF
 ENDIF

 select radn; hseek _idradn; select ld

 DO WHILE .t.
   if prow()>62+gPStranica; FF; Eval(bZagl); endif

   if _i&cTip<>0 .or. _s&cTip<>0
     ? str(++nRbr,4)+".",idradn, RADNIK
     nC1:=pcol()+1
     if lKredit .and. !EMPTY(cSifKred)
       @ prow(),pcol()+1 SAY RADKR->naosnovu
     elseif tippr->fiksan=="P"
       @ prow(),pcol()+1 SAY _s&cTip  pict "999.99"
     else
       @ prow(),pcol()+1 SAY _s&cTip  pict gpics
     endif
     IF lKredit .and. !EMPTY(cSifKred)
       @ prow(),pcol()+1 SAY -RADKR->placeno  pict gpici
       nT2 += (-RADKR->placeno)
     ELSE
       @ prow(),pcol()+1 SAY _i&cTip  pict gpici
       nT1+=_s&cTip; nT2+=_i&cTip
     ENDIF
     if cdod=="D"
       @ prow(),pcol()+1 SAY &ckolona
     endif
   endif
   IF lKredit .and. !EMPTY(cSifKred)
     lImaJos:=.f.
     SELECT RADKR; SKIP 1
     DO WHILE !EOF() .and. str(cgodina,4)+str(cmjesec,2)+LD->idradn+cSifKred == str(godina,4)+str(mjesec,2)+idradn+idkred
       IF placeno>0
         lImaJos:=.t.
         EXIT
       ENDIF
       SKIP 1
     ENDDO
     SELECT LD
     IF !lImaJos
       EXIT
     ENDIF
   ELSE
     EXIT
   ENDIF
 ENDDO

 skip 1

enddo

if prow()>60+gPStranica; FF; Eval(bZagl); endif
? m
? SPACE(1) + Lokal("UKUPNO:")
IF lKredit .and. !EMPTY(cSifKred)
  @ prow(),nC1 SAY  SPACE(LEN(RADKR->naosnovu))
ELSE
  @ prow(),nC1 SAY  nT1 pict gpics
ENDIF
@ prow(),pcol()+1 SAY  nT2 pict gpici
? m
?
if IsFakultet()
	ShowPPFakultet()
else
	ShowPPDef()
endif
?
?
FF
END PRINT
CLOSERET
return
*}

function ZPregPrim()

P_12CPI
? UPPER(gTS)+":",gnFirma
?
if empty(cidrj)
 ? Lokal("Pregled za sve RJ ukupno:")
else
 ? Lokal("RJ:"),cidrj,rj->naz
endif

?? SPACE(2) + Lokal("Mjesec:"), str(cmjesec,2) + IspisObr()
?? SPACE(4) + Lokal("Godina:"),str(cGodina,5)
devpos(prow(),74)
?? Lokal("Str."), str(++nStrana,3)
?
#ifdef CPOR
? Lokal("Pregled") + SPACE(1) +IF(lIsplaceni, Lokal("isplacenih iznosa"),Lokal("neisplacenih iznosa"))+ SPACE(1) + Lokal("za tip primanja:"),ctip,tippr->naz
#else
? Lokal("Pregled za tip primanja:"), cTip, tippr->naz
IF lKredit
  ? Lokal("KREDITOR:") + SPACE(1)
  IF !EMPTY(cSifKred)
    ShowKreditor(cSifKred)
  ELSE
    ?? Lokal("SVI POSTOJECI")
  ENDIF
ENDIF
#endif
?
? m
IF lKredit .and. !EMPTY(cSifKred)
  ? " Rbr  "+padc("Sifra ",_LR_)+"          " + Lokal("Naziv radnika") + "               "+PADC("Na osnovu",LEN(RADKR->naosnovu))+"      " + Lokal("Iznos")
ELSE
  ? " Rbr  "+padc("Sifra ",_LR_)+"          " + Lokal("Naziv radnika") + "               "+iif(tippr->fiksan=="P"," %  ","Sati")+"      " + Lokal("Iznos")
ENDIF
? m

return


