#include "\dev\fmk\ld\ld.ch"

function AutorskiHonorari()
*{
local nC1:=20

cIdRadn:=space(_LR_)
cIdRj:=gRj; cmjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cVarSort:="2"

cOpcinaSt:=""
cOpsSt:=SPACE(4)

cIzdanje:=SPACE(10)
cK4:=""

nRbr:=0
O_OPS
O_RJ
O_RADN
O_LD

private cTip:="  "

cDod:="N"
cKolona:=SPACE(20)
nPorez:=0

O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("VS",@cVarSort)
//RPar("PZ",@nPorez)
RPar("AH",@cTip)

Box("#IZVJESTAJ: LISTA AUTORSKIH HONORARA",10,65)
@ m_x+1,m_y+2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Opstina stanovanja (prazno-sve): "  GET  cOpsSt pict "@!" valid empty(cOpsSt).or.P_Ops(@cOpsSt)
@ m_x+3,m_y+2 SAY "Izdanje (prazno-sva): "  GET  cIzdanje pict "@!"
@ m_x+4,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
if lViseObr
  @ m_x+4,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif
@ m_x+5,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+6,m_y+2 SAY "Tip primanja: "  GET  cTip
//@ m_x+7,m_y+2 SAY "Porez (%) " GET nPorez PICT "9999.9999"
@ m_x+8,m_y+2 SAY "Prikaz dodatne kolone: "  GET  cDod pict "@!" valid cdod $ "DN"
@ m_x+9,m_y+2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort$"12"  pict "9"
read; clvbox(); ESC_BCR
if cDod=="D"
 @ m_x+10,m_y+2 SAY "Naziv kolone:" GET cKolona
 read
endif
ckolona:="radn->"+ckolona
BoxC()

CreRekLD()

O_REKLD

SELECT PARAMS
WPar("VS",cVarSort)
//WPar("PZ",nPorez)
WPar("AH",cTip)
USE

if empty(cOpsSt)
	cOpcinaSt:="SVE OPSTINE"
	cOpsSt:=""
else
	cOpcinaSt:=ALLTRIM(Ocitaj(F_OPS,cOpsSt,"naz"))
endif

if !empty(cIzdanje)
	cK4:=PADR(IzFmkIni("IzdanjaK4",ALLTRIM(cIzdanje),"XX",KUMPATH),2)
else
	cK4:=""
endif

//nPorez:=nPorez/100

if lViseObr
 O_TIPPRN
else
 O_TIPPR
endif

select tippr
hseek ctip
EOF CRET

select ld
set relation to idradn into radn

if lViseObr
  cObracun:=TRIM(cObracun)
else
  cObracun:=""
endif

if empty(cidrj)
  cidrj:=""
  IF cVarSort=="1"
//    set order to tag (TagVO("2"))
//    hseek str(cGodina,4)+str(cmjesec,2)+cObracun
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="radn->idOpsSt+IDRADN"
     cFilt := "IDRJ==cIdRj.and."+;
              IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     if lViseObr
       cFilt += ".and. OBR=cObracun"
     endif
     if !EMPTY(cOpsSt)
     	cFilt+=".and. radn->idOpsSt=cOpsSt"
     endif
     if !EMPTY(cK4)
     	cFilt+=".and. radn->k4=cK4"
     endif
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
 ELSE
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="radn->idOpsSt+SortPrez(IDRADN)"
     cFilt := IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     if lViseObr
       cFilt += ".and. OBR=cObracun"
     endif
     if !EMPTY(cOpsSt)
     	cFilt+=".and. radn->idOpsSt=cOpsSt"
     endif
     if !EMPTY(cK4)
     	cFilt+=".and. radn->k4=cK4"
     endif
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
  ENDIF
else
  IF cVarSort=="1"
//    set order to tag (TagVO("1"))
//    hseek str(cGodina,4)+cidrj+str(cmjesec,2)+cObracun
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="radn->idOpsSt+IDRADN"
     cFilt := "IDRJ==cIdRj.and."+;
              IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     if lViseObr
       cFilt += ".and. OBR=cObracun"
     endif
     if !EMPTY(cOpsSt)
     	cFilt+=".and. radn->idOpsSt=cOpsSt"
     endif
     if !EMPTY(cK4)
     	cFilt+=".and. radn->k4=cK4"
     endif
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
 ELSE
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="radn->idOpsSt+SortPrez(IDRADN)"
     cFilt := "IDRJ==cIdRj.and."+;
              IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     if lViseObr
       cFilt += ".and. OBR=cObracun"
     endif
     if !EMPTY(cOpsSt)
     	cFilt+=".and. radn->idOpsSt=cOpsSt"
     endif
     if !EMPTY(cK4)
     	cFilt+=".and. radn->k4=cK4"
     endif
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
  ENDIF
endif

EOF CRET

nStrana:=0
m:="----- ----------------------------------- ------------- ----------- --------.----------- ----------- --------.-------------"
if cdod=="D"
 if type(ckolona) $ "UUIUE"
     Msg("Nepostojeca kolona")
     closeret
 endif
endif
bZagl:={|| ZAutorHonor() }

select rj; hseek ld->idrj; select ld

START PRINT CRET

nRbr:=0
nT1:=nT2:=nT3:=nT4:=0
nC1:=10
aPoOps:={}

altd()

do while !eof()

 nRbr:=0
 nT1:=nT2:=nT3:=nT4:=0
 nC1:=10
 cIdOpsSt:=radn->idOpsSt
 cOpcinaSt:=ALLTRIM(Ocitaj(F_OPS,cIdOpsSt,"naz"))
 nStrana:=0
 P_COND
 Eval(bZagl)
 do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec .and. !( lViseObr .and. !EMPTY(cObracun) .and. obr<>cObracun ) .and. radn->idOpsSt=cIdOpsSt
 
 if lViseObr .and. EMPTY(cObracun)
 	ScatterS(godina,mjesec,idrj,idradn)
 else
 	Scatter()
 endif

// select radn; hseek _idradn; select ld
// if (!(radn->idOpsSt=cOpsSt) .or. radn->k4<>cK4)
// 	skip 1
//	loop
// endif

 select ops
 seek radn->idOpsSt
 if fieldpos("ptAh")<>0
 	nPtAh:=field->ptAh/100
 else
 	nPtAh:=30/100
 endif
 if fieldpos("psAh")<>0
 	nPsAh:=field->psAh/100
 else
 	nPsAh:=17.647/100
 endif
 select ld

 DO WHILE .t.
   if prow()>62+gPStranica; FF; Eval(bZagl); endif

   if _i&cTip<>0
     ? str(++nRbr,4)+".", RADNIK, radn->matbr
     nC1:=pcol()+1
     @ prow(),pcol()+1 SAY _i&cTip  pict gpici
     @ prow(),pcol()+1 SAY TRANS(nPtAh*100,"999.999%")
     @ prow(),pcol()+1 SAY nPtAh*_i&cTip  pict gpici
     @ prow(),pcol()+1 SAY (1-nPtAh)*_i&cTip  pict gpici
     @ prow(),pcol()+1 SAY TRANS(nPsAh*100,"999.999%")
     @ prow(),pcol()+1 SAY ROUND(nPsAh*(1-nPtAh)*_i&cTip,2)  pict "99999999.99"
     nT1+=_i&cTip
     nT2+=nPtAh*_i&cTip
     nT3+=(1-nPtAh)*_i&cTip
     nT4+=ROUND(nPsAh*(1-nPtAh)*_i&cTip,2)
     if cdod=="D"
       @ prow(),pcol()+1 SAY &ckolona
     endif
     Rekapld( "IS_"+RADN->idbanka , cgodina , cmjesec ,_i&cTip , 0 , RADN->idbanka , RADN->brtekr , RADNIK , .t. )
   endif
   EXIT
 ENDDO

 skip 1

 enddo

if prow()>60+gPStranica; FF; Eval(bZagl); endif
? m
? " UKUPNO:"
@ prow(),nC1 SAY  nT1 pict gpici
@ prow(),pcol()+1 SAY  space(8)
@ prow(),pcol()+1 SAY  nT2 pict gpici
@ prow(),pcol()+1 SAY  nT3 pict gpici
@ prow(),pcol()+1 SAY  space(8)
@ prow(),pcol()+1 SAY  nT4 pict "99999999.99"
? m
FF
AADD(aPoOps,{cIdOpsSt,nT4})

enddo
?
? "REKAPITULACIJA POREZA PO OPSTINAMA:"
? "-----------------------------------"
nUk:=0
for i:=1 to len(aPoOps)
	? aPoOps[i,1], Ocitaj(F_OPS,aPoOps[i,1],"naz"), TRANS(aPoOps[i,2],"99999999.99")
	nUk+=aPoOps[i,2]
	Rekapld("PORAH"+aPoOps[i,1],cgodina,cmjesec,aPoOps[i,2],0,aPoOps[i,1],)
next
? m:="--------------------------------------"
? "UKUPNO POREZ:            ", TRANS(nUk,"99999999.99")
? m

END PRINT
CLOSERET


********************
********************
function ZAutorHonor()

P_COND
//? UPPER(gTS)+":",gnFirma
B_ON
? "Privredna stampa d.d. Sarajevo           Dzemala Bijedica 185         Identifikacijski broj: 4200088140005"
B_OFF

? "Autorski honorar: "
U_ON
?? PADC(IF(EMPTY(cIzdanje),"sva izdanja",cIzdanje),30)
U_OFF
?
? "Opcina prebivalista: "
U_ON
?? PADC(cOpcinaSt,30)
U_OFF
?

if empty(cidrj)
 ? "Pregled za sve RJ ukupno:"
else
 ? "RJ:",cidrj,rj->naz
endif

?? "  Mjesec:",str(cmjesec,2)+IspisObr()
?? "    Godina:",str(cGodina,5)
devpos(prow(),74)
?? "Str.",str(++nStrana,3)
?
? "Pregled za tip primanja:",ctip,tippr->naz
?
? m
? " Rbr            Naziv radnika               JMBG        Za isplatu      priznati tros.     Poreska            Porez     "
? "                                                          (neto)         (% i iznos)       osnovica         (% i iznos)"
? m
return

