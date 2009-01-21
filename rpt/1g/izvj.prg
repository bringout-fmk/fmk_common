#include "ld.ch"


* prikaz primanja, opcina zenica
*********************************
function PrikPrimanje()
local nIznos:=0
IF "U" $ TYPE("cLMSK"); cLMSK:=""; ENDIF
IF "U" $ TYPE("l2kolone"); l2kolone:=.f.; ENDIF
if tippr->(found()) .and. tippr->aktivan=="D"
 if _i&cpom<>0 .or. _s&cPom<>0
  ? cLMSK+tippr->id+"-"+tippr->naz,tippr->opis
  nC1:=pcol()
  if tippr->uneto=="N"
     nIznos:=abs(_i&cPom)
  else
     nIznos:=_i&cPom
  endif
  if tippr->fiksan $ "DN"
     @ prow(),pcol()+8 SAY _s&cPom  pict gpics; ?? " s"
     @ prow(),60+LEN(cLMSK) say niznos        pict gpici
  elseif tippr->fiksan=="P"
     @ prow(),pcol()+8 SAY _s&cPom  pict "999.99%"
     @ prow(),60+LEN(cLMSK) say niznos        pict gpici
  elseif tippr->fiksan=="B"
     @ prow(),pcol()+8 SAY abs(_s&cPom)  pict "999999"; ?? " b"
     @ prow(),60+LEN(cLMSK) say niznos        pict gpici
  elseif tippr->fiksan=="C"
    if !("SUMKREDITA" $ tippr->formula)
      @ prow(),60+LEN(cLMSK) say niznos        pict gpici
    endif
  endif
  if "SUMKREDITA" $ tippr->formula
    //? m
    //? "  ","Od toga pojedinacni krediti:"
    select radkr; set order to 1
    seek str(_godina,4)+str(_mjesec,2)+_idradn
    ukredita:=0
    IF l2kolone
      P_COND2
    ELSE
      P_COND
    ENDIF
? m2:=cLMSK+" ------------------------------------------- --------- --------- -------"
    ? cLMSK+"    Kreditor   /             na osnovu         Ukupno    Ostalo   Rata"
    ? m2
    do while !eof() .and. _godina==godina .and. _mjesec=mjesec .and. idradn==_idradn
     select kred; hseek radkr->idkred; select radkr
     aIznosi:=OKreditu(idradn, idkred, naosnovu, _mjesec, _godina)
     ? cLMSK,idkred,left(kred->naz,15),PADR(naosnovu,20)
     @ prow(),pcol()+1 SAY aIznosi[1] pict "999999.99" // ukupno
     @ prow(),pcol()+1 SAY aIznosi[1]-aIznosi[2] pict "999999.99"// ukupno-placeno
     @ prow(),pcol()+1 SAY iznos pict "9999.99"
     ukredita+=iznos
     skip
    enddo
    if round(ukredita-niznos,2)<>0
     set device to screen
     Beep(2)
     Msg("Za radnika "+_idradn+" iznos sume kredita ne odgovara stanju baze kredita !",6)
     set device to printer
    endif

     //? m
    IF l2kolone
      P_COND2
    ELSE
      P_12CPI
    ENDIF
    select ld
  endif
  if "_K" == RIGHT( ALLTRIM(tippr->opis) , 2 )
    nKumPrim:=KumPrim(_IdRadn,cPom)

    if substr(alltrim(tippr->opis), 2,1)=="1"
      nKumPrim := nkumprim + radn->n1
    elseif  substr(alltrim(tippr->opis), 2,1)=="2"
      nKumPrim := nkumprim + radn->n2
    elseif  substr(alltrim(tippr->opis), 2,1)=="3"
      nKumPrim := nkumprim + radn->n3
    endif

    IF tippr->uneto=="N"; nKumPrim:=ABS(nKumPrim); ENDIF
    ? m2:=cLMSK+"   ----------------------------- ----------------------------"
        ? cLMSK+"    SUMA IZ PRETHODNIH OBRA¬UNA   UKUPNO (SA OVIM OBRA¬UNOM)"
        ? m2
        ? cLMSK+"   "+PADC(STR(nKumPrim-nIznos),29)+" "+PADC(STR(nKumPrim),28)
        ? m2
  endif
 endif
endif


FUNCTION KumPrim(cIdRadn,cIdPrim)
 LOCAL j:=0, nVrati:=0, nOdGod:=0, nDoGod:=0
 cPom77:=cIdPrim
  IF cIdRadn==NIL; cIdRadn:=""; ENDIF
    SELECT LD
    PushWA()
    SET ORDER TO TAG (TagVO("4"))
    GO BOTTOM; nDoGod:=godina
    GO TOP; nOdGod:=godina
    FOR j:=nOdGod TO nDoGod
      GO TOP
      seek STR(j,4)+cIdRadn
      DO WHILE godina==j .and. cIdRadn==IdRadn
        nVrati += i&cPom77
        SKIP 1
      ENDDO
    NEXT
    SELECT LD
    PopWA()
RETURN nVrati



function Rekap_OLD(fSvi)
*{
local nC1:=20, i
local cTPNaz, cUmPD:="N", nKrug:=1

fPorNaRekap:=IzFmkIni("LD","PoreziNaRekapitulaciji","N",KUMPATH)=="D"

#ifdef CPOR
 cUmPD:="D"
#endif

cIdRj:=gRj; cmjesec:=gMjesec; cGodina:=gGodina
cObracun:=gObracun
cMjesecDo:=cMjesec

if fSvi==NIL
 fSvi:=.f.
endif

O_POR
O_DOPR
O_PAROBR
O_RJ
O_RADN
O_STRSPR
O_KBENEF
O_VPOSLA
O_OPS
O_RADKR
O_KRED

#ifdef CPOR
 IF Pitanje(,"Izvjestaj se pravi za isplacene(D) ili neisplacene(N) radnike?","D")=="D"
   lIsplaceni:=.t.
   O_LD
 ELSE
   lIsplaceni:=.f.
   select (F_LDNO)  ; usex (KUMPATH+"LDNO") alias LD; set order to 1
 ENDIF
#else
 O_LD
#endif

cIdRadn:=space(_LR_); cStrSpr:=space(3); cOpsSt:=space(4); cOpsRad :=space(4)

if fSvi
// za sve radne jedinice
qqRJ:=SPACE(60)
Box(,10,75)

DO WHILE .t.
 #ifdef CPOR
 if lIsplaceni
   @ m_x+2,m_y+2 SAY "Umanjiti poreze i doprinose za preplaceni iznos? (D/N)"  GET cUmPD VALID cUmPD $ "DN" PICT "@!"
 endif
 #endif
 @ m_x+3,m_y+2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
 @ m_x+4,m_y+2 SAY "Za mjesece od:"  GET  cmjesec  pict "99" VALID {|| cMjesecDo:=cMjesec,.t.}
 @ m_x+4,col()+2 SAY "do:"  GET  cMjesecDo  pict "99" VALID cMjesecDo>=cMjesec
 if lViseObr
   @ m_x+4,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
 endif
 @ m_x+5,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
 @ m_x+7,m_y+2 SAY "Strucna Sprema: "  GET  cStrSpr pict "@!" valid empty(cStrSpr) .or. P_StrSpr(@cStrSpr)
 @ m_x+8,m_y+2 SAY "Opstina stanovanja: "  GET  cOpsSt pict "@!" valid empty(cOpsSt) .or. P_Ops(@cOpsSt)
 @ m_x+9,m_y+2 SAY "Opstina rada:       "  GET  cOpsRad  pict "@!" valid empty(cOpsRad) .or. P_Ops(@cOpsRad)

 read; clvbox(); ESC_BCR
 aUsl1:=Parsiraj(qqRJ,"IDRJ")
 aUsl2:=Parsiraj(qqRJ,"ID")
 if aUsl1<>NIL.and.aUsl2<>NIL; exit; endif
ENDDO

BoxC()

if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif

SELECT LD

if lViseObr
  cObracun:=TRIM(cObracun)
else
  cObracun:=""
endif

// CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")
set order to tag (TagVO("2"))

PRIVATE cFilt1:=""
cFilt1 := ".t." + IF(EMPTY(cStrSpr),"",".and.IDSTRSPR=="+cm2str(cStrSpr))+;
		  IF(EMPTY(qqRJ),"",".and."+aUsl1)

IF cMjesec!=cMjesecDo
  cFilt1 := cFilt1 + ".and.mjesec>="+cm2str(cMjesec)+;
                     ".and.mjesec<="+cm2str(cMjesecDo)+;
                     ".and.godina="+cm2str(cGodina)
ENDIF

if lViseObr
  cFilt1 += ".and. OBR="+cm2str(cObracun)
endif

cFilt1 := STRTRAN(cFilt1,".t..and.","")

IF cFilt1==".t."
  SET FILTER TO
ELSE
  SET FILTER TO &cFilt1
ENDIF

IF cMjesec==cMjesecDo
  seek str(cGodina,4)+str(cmjesec,2)+cObracun
  EOF CRET
ELSE
  GO TOP
ENDIF

else
//****** samo jedna radna jedinica
Box(,8,75)
 #ifdef CPOR
 if lIsplaceni
   @ m_x+1,m_y+2 SAY "Umanjiti poreze i doprinose za preplaceni iznos? (D/N)"  GET cUmPD VALID cUmPD $ "DN" PICT "@!"
 endif
 #endif
 @ m_x+2,m_y+2 SAY "Radna jedinica: "  GET cIdRJ
 @ m_x+3,m_y+2 SAY "Za mjesece od:"  GET  cmjesec  pict "99" VALID {|| cMjesecDo:=cMjesec,.t.}
 @ m_x+3,col()+2 SAY "do:"  GET  cMjesecDo  pict "99" VALID cMjesecDo>=cMjesec
 if lViseObr
   @ m_x+3,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
 endif
 @ m_x+4,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
 @ m_x+6,m_y+2 SAY "Strucna Sprema: "  GET  cStrSpr pict "@!" valid empty(cStrSpr) .or. P_StrSpr(@cStrSpr)
 @ m_x+7,m_y+2 SAY "Opstina stanovanja: "  GET  cOpsSt pict "@!" valid empty(cOpsSt) .or. P_Ops(@cOpsSt)
 @ m_x+8,m_y+2 SAY "Opstina rada:       "  GET  cOpsRad  pict "@!" valid empty(cOpsRad) .or. P_Ops(@cOpsRad)
 read; clvbox(); ESC_BCR
BoxC()

if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif

SELECT LD

if lViseObr
  cObracun:=TRIM(cObracun)
else
  cObracun:=""
endif

set order to tag (TagVO("1"))

PRIVATE cFilt1:=""
cFilt1 := ".t." + IF(EMPTY(cStrSpr),"",".and.IDSTRSPR=="+cm2str(cStrSpr))

IF cMjesec!=cMjesecDo
  cFilt1 := cFilt1 + ".and.mjesec>="+cm2str(cMjesec)+;
                     ".and.mjesec<="+cm2str(cMjesecDo)+;
                     ".and.godina="+cm2str(cGodina)
ENDIF

if lViseObr
  cFilt1 += ".and. OBR="+cm2str(cObracun)
endif

cFilt1 := STRTRAN(cFilt1,".t..and.","")

IF cFilt1==".t."
  SET FILTER TO
ELSE
  SET FILTER TO &cFilt1
ENDIF

// IF cMjesec==cMjesecDo
  seek str(cGodina,4)+cidrj+str(cmjesec,2)+cObracun
  EOF CRET
// ELSE
//   GO TOP
// ENDIF

endif
//********************* fsvi

PoDoIzSez(cGodina,cMjesecDo)

nStrana:=0

if !fPorNaRekap
   m:="------------------------  ----------------               -------------------"
else
   m:="------------------------  ---------------  ---------------  -------------"
endif


aDbf:={   {"ID"    ,"C", 1,0},;
          {"IDOPS" ,"C", 4,0},;
          {"IZNOS" ,"N",25,4},;
          {"IZNOS2","N",25,4},;
          {"LJUDI" ,"N", 10,0};
      }

#ifdef CPOR
  AADD(aDbf, {"PIZNOS" ,"N",25,4})
  AADD(aDbf, {"PIZNOS2","N",25,4})
  AADD(aDbf, {"PLJUDI" ,"N", 10,0})
#endif

//id- 1 opsstan
//id- 2 opsrad
DBCREATE2(PRIVPATH+"opsld",aDbf)


select(F_OPSLD) ; usex (PRIVPATH+"opsld")
INDEX ON ID+IDOPS tag "1"
index ON  BRISANO TAG "BRISAN"
use


// napraviti   godina, mjesec, idrj, cid , iznos1, iznos2
aDbf:={    {"GODINA"     ,  "C" , 4, 0 } ,;
           {"MJESEC"     ,  "C" , 2, 0 } ,;
           {"ID"         ,  "C" , 30, 0} ,;
           {"opis"       ,  "C" , 20, 0} ,;
           {"opis2"      ,  "C" , 35, 0} ,;
           {"iznos1"     ,  "N" , 25, 4} ,;
           {"iznos2"     ,  "N" , 25, 4} ;
        }
#ifdef CPOR
  AADD( aDbf , {"idpartner"  ,  "C" , 10, 0} )
#else
  AADD( aDbf , {"idpartner"  ,  "C" ,  6, 0} )
#endif

DBCREATE2(KUMPATH+"REKLD",aDbf)

select (F_REKLD); usex (KUMPATH+"rekld")
index ON  BRISANO+"10" TAG "BRISAN"
index on  godina+mjesec+id  tag "1"
set order to tag "1"
use

O_REKLD
O_OPSLD
select ld

START PRINT CRET
?
P_10CPI

IF IzFMKIni("LD","RekapitulacijaGustoPoVisini","N",KUMPATH)=="D"
  lGusto:=.t.
  gRPL_Gusto()
  nDSGusto:=VAL(IzFMKIni("RekapGustoPoVisini","DodatnihRedovaNaStranici","11",KUMPATH))
  gPStranica+=nDSGusto
ELSE
  lGusto:=.f.
  nDSGusto:=0
ENDIF

ParObr(cmjesec,IF(lViseObr,cObracun,),IF(!fSvi,cIdRj,))      // samo pozicionira bazu PAROBR na odgovaraju†i zapis

private aRekap[cLDPolja,2]

for i:=1 to cLDPolja
  aRekap[i,1]:=0
  aRekap[i,2]:=0
next

nT1:=nT2:=nT3:=nT4:=0
nUNeto:=0
nUNetoOsnova:=0
nUIznos:=nUSati:=nUOdbici:=nUOdbiciP:=nUOdbiciM:=0
nLjudi:=0

private aNeta:={}

select ld

IF cMjesec!=cMjesecDo
 if fSvi
   private bUslov:={|| cgodina==godina .and. mjesec>=cmjesec .and. mjesec<=cMjesecDo .and. IF(lViseObr,obr=cObracun,.t.) }
 else
   private bUslov:={|| cgodina==godina .and. cidrj==idrj .and. mjesec>=cmjesec .and. mjesec<=cMjesecDo .and. IF(lViseObr,obr=cObracun,.t.) }
 endif
ELSE
 if fSvi
   private bUslov:={|| cgodina==godina .and. cmjesec=mjesec .and. IF(lViseObr,obr=cObracun,.t.) }
 else
   private bUslov:={|| cgodina==godina .and. cidrj==idrj .and. cmjesec=mjesec .and. IF(lViseObr,obr=cObracun,.t.) }
 endif
ENDIF

nPorOl:=nUPorOl:=0

aNetoMj:={}

aUkTr:={}

do while !eof() .and. eval(bUSlov) 

 if lViseObr .and. EMPTY(cObracun)
   ScatterS(godina,mjesec,idrj,idradn)
 else
   Scatter()
 endif

 select radn; hseek _idradn
 select vposla; hseek _idvposla

 if (!empty(copsst) .and. copsst<>radn->idopsst)  .or.;
    (!empty(copsrad) .and. copsrad<>radn->idopsrad)
   select ld
   skip 1; loop
 endif

 _ouneto:=MAX(_uneto,PAROBR->prosld*gPDLimit/100)
 altd()
 select por; go top
 nPor:=nPorOl:=0
 do while !eof()  // datoteka por
   PozicOps(POR->poopst)
   IF !ImaUOp("POR",POR->id)
     SKIP 1; LOOP
   ENDIF
   nPor+=round2(max(dlimit,iznos/100*_oUNeto),gZaok2)
   skip
 enddo
 if radn->porol<>0 .and. gDaPorOl=="D" .and. !Obr2_9() // poreska olaksica
   if alltrim(cVarPorOl)=="2"
     nPorOl:=RADN->porol
   elseif alltrim(cVarPorol)=="1"
     nPorOl:=round(parobr->prosld*radn->porol/100,gZaok)
   else
     nPorOl:= &("_I"+cVarPorol)
   endif
   if nPorOl>nPor // poreska olaksica ne moze biti veca od poreza
     nPorOl:=nPor
   endif
   nUPorOl+=nPorOl
 endif

 //**** nafiluj datoteku OPSLD *********************
 select ops; seek radn->idopsst
 select opsld
 seek "1"+radn->idopsst
 if found()
   replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 else
   append blank
   replace id with "1", idops with radn->idopsst, iznos with _ouneto,;
                        iznos2 with iznos2+nPorOl, ljudi with 1
 endif
 seek "3"+ops->idkan
 if found()
   replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 else
   append blank
   replace id with "3", idops with ops->idkan, iznos with _ouneto,;
                        iznos2 with iznos2+nPorOl, ljudi with 1
 endif
 seek "5"+ops->idn0
 if found()
   replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 else
   append blank
   replace id with "5", idops with ops->idn0, iznos with _ouneto,;
                        iznos2 with iznos2+nPorOl, ljudi with 1
 endif
 select ops; seek radn->idopsrad
 select opsld
 seek "2"+radn->idopsrad
 if found()
   replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl , ljudi with ljudi+1
 else
   append blank
   replace id with "2", idops with radn->idopsrad, iznos with _ouneto,;
                        iznos2 with iznos2+nPorOl, ljudi with 1
 endif
 seek "4"+ops->idkan
 if found()
   replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 else
   append blank
   replace id with "4", idops with ops->idkan, iznos with _ouneto,;
                        iznos2 with iznos2+nPorOl, ljudi with 1
 endif
 seek "6"+ops->idn0
 if found()
   replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 else
   append blank
   replace id with "6", idops with ops->idn0, iznos with _ouneto,;
                        iznos2 with iznos2+nPorOl, ljudi with 1
 endif
 select ld
 //*************************



 nPom:=ASCAN(aNeta,{|x| x[1]==vposla->idkbenef})
 if nPom==0
    AADD(aNeta,{vposla->idkbenef,_oUNeto})
 else
    aNeta[nPom,2]+=_oUNeto
 endif

 for i:=1 to cLDPolja
  cPom:=padl(alltrim(str(i)),2,"0")
  select tippr; seek cPom; select ld
  #ifdef CPOR
    n777:=i+cMjesecDO-_mjesec
    aRekap[IF(n777>cLDPolja,cLDPolja,n777),1]+=_s&cPom  // sati
  #else
    aRekap[i,1]+=_s&cPom  // sati
  #endif
  nIznos:=_i&cPom
  #ifdef CPOR
    n777:=i+cMjesecDO-_mjesec
    aRekap[IF(n777>cLDPolja,cLDPolja,n777),2]+=nIznos  // iznos
  #else
    aRekap[i,2]+=nIznos  // iznos
  #endif
  if tippr->uneto=="N" .and. nIznos<>0
    if nIznos>0
      nUOdbiciP+=nIznos
    else
      nUOdbiciM+=nIznos
    endif
  endif
 next

 ++nLjudi
 nUSati+=_USati   // ukupno sati
 nUNeto+=_UNeto  // ukupno neto iznos
 nUNetoOsnova+=_oUNeto  // ukupno neto osnova za obracun por.i dopr.

 cTR := IF( RADN->isplata$"TR#SK", RADN->idbanka,;
                                   SPACE(LEN(RADN->idbanka)) )

 IF LEN(aUkTR)>0 .and. ( nPomTR := ASCAN( aUkTr , {|x| x[1]==cTR} ) ) > 0
   aUkTR[nPomTR,2] += _uiznos
 ELSE
   AADD( aUkTR , { cTR , _uiznos } )
 ENDIF

 nUIznos+=_UIznos  // ukupno iznos

 nUOdbici+=_UOdbici  // ukupno odbici

 IF cMjesec<>cMjesecDo
   nPom:=ASCAN(aNetoMj,{|x| x[1]==mjesec})
   IF nPom>0
     aNetoMj[nPom,2] += _uneto
     aNetoMj[nPom,3] += _usati
   ELSE
     nTObl:=SELECT()
     nTRec := PAROBR->(RECNO())
     ParObr(mjesec,IF(lViseObr,cObracun,),IF(!fSvi,cIdRj,))      // samo pozicionira bazu PAROBR na odgovaraju†i zapis
     AADD(aNetoMj,{mjesec,_uneto,_usati,PAROBR->k3,PAROBR->k1})
     SELECT PAROBR; GO (nTRec)
     SELECT (nTObl)
   ENDIF
 ENDIF

 IF RADN->isplata=="TR"  // isplata na tekuci racun
   Rekapld( "IS_"+RADN->idbanka , cgodina , cmjesecDo ,;
            _UIznos , 0 , RADN->idbanka , RADN->brtekr , RADNIK , .t. )
 ENDIF

 select ld
 skip

enddo 

if nLjudi==0
  nLjudi:=9999999
endif
B_ON
?? "LD: Rekapitulacija primanja"
B_OFF

#ifdef CPOR
 ?? IF(lIsplaceni,"","-neisplaceni radnici-")
#endif

if !empty(cstrspr)
 ?? " za radnike strucne spreme ",cStrSpr
endif
if !empty(cOpsSt)
 ? "Opstina stanovanja:",cOpsSt
endif
if !empty(cOpsRad)
 ? "Opstina rada:",cOpsRad
endif

if fSvi
 select por
 go top
 select rj
 ? "Obuhvacene radne jedinice: "
 IF !EMPTY(qqRJ)
  SET FILTER TO &aUsl2
  GO TOP
  DO WHILE !EOF()
   ?? id+" - "+naz
   ? SPACE(27)
   SKIP 1
  ENDDO
 ELSE
  ?? "SVE"
  ?
 ENDIF
 B_ON
 IF cMjesec==cMjesecDo
   ? "Firma:",gNFirma,"  Mjesec:",str(cmjesec,2)+IspisObr()
   ?? "    Godina:", str(cGodina,4)
   B_OFF
   ? IF(gBodK=="1","Vrijednost boda:","Vr.koeficijenta:"), transform(parobr->vrbod,"99999.99999")
 ELSE
   ? "Firma:",gNFirma,"  Za mjesece od:",str(cmjesec,2),"do",str(cmjesecDo,2)+IspisObr()
   ?? "    Godina:", str(cGodina,4)
   B_OFF
   // ? IF(gBodK=="1","Vrijednost boda:","Vr.koeficijenta:"), transform(parobr->vrbod,"99999.99999")
 ENDIF
 ?

else
 
 select rj
 hseek cIdrj

 select por
 go top

 select ld

 ?
 B_ON
 IF cMjesec==cMjesecDo
   ? "RJ:",cidrj,rj->naz,"  Mjesec:",str(cmjesec,2)+IspisObr()
   ?? "    Godina:", str(cGodina,4)
   B_OFF
   #ifndef CPOR
     ? IF(gBodK=="1","Vrijednost boda:","Vr.koeficijenta:"), transform(parobr->vrbod,"99999.99999")
   #endif
 ELSE
   ? "RJ:",cidrj,rj->naz,"  Za mjesece od:",str(cmjesec,2),"do",str(cmjesecDo,2)+IspisObr()
   ?? "    Godina:", str(cGodina,4)
   B_OFF
 ENDIF
 ?
endif // fsvi
? SPACE(60) + "Porez:" + STR(por->iznos) + "%"
? m
cUNeto:="D"



for i:=1 to cLDPolja

  If prow()>55+gPStranica
    FF
  endif

  //********************* 90 - ke
  cPom:=padl(alltrim(str(i)),2,"0")
  _s&cPom:=aRekap[i,1]   // nafiluj ove varijable radi prora~una dodatnih stavki
  _i&cPom:=aRekap[i,2]
  //**********************

  cPom:=padl(alltrim(str(i)),2,"0")
  select tippr; seek cPom
  if tippr->uneto=="N" .and. cUneto=="D"
    cUneto:="N"
    ? m
    if !fPorNaRekap
       ? "UKUPNO NETO:"; @ prow(),nC1+8  SAY  nUSati  pict gpics; ?? " sati"
       @ prow(),60 SAY nUNeto pict gpici; ?? "",gValuta
    else
       ? "UKUPNO NETO:"; @ prow(),nC1+5  SAY  nUSati  pict gpics; ?? " sati"
       @ prow(),42 SAY nUNeto pict gpici; ?? "",gValuta
       @ prow(),60 SAY nUNeto*(por->iznos/100) pict gpici; ?? "",gValuta
    endif
    // ****** radi 90 - ke
    _UNeto:=nUNeto
    _USati:=nUSati
    //***********
    ? m
  endif


  if tippr->(found()) .and. tippr->aktivan=="D" .and. (aRekap[i,2]<>0 .or. aRekap[i,1]<>0)
#ifdef CPOR
            aRez:=GodMj(_godina,_mjesec,-val(tippr->id)+1)
            cTpnaz:=padr("Za "+;
                         iif(tippr->id='14','<= ','')+;
                         str(arez[2],2)+"/"+str(arez[1],4),;
                         len(tippr->naz))
#else
            cTPNaz:=tippr->naz
#endif
  ? tippr->id+"-"+cTPNaz
  nC1:=pcol()
  if !fPorNaRekap
   if tippr->fiksan $ "DN"
     @ prow(),pcol()+8 SAY aRekap[i,1]  pict gpics; ?? " s"
     @ prow(),60 say aRekap[i,2]      pict gpici
   elseif tippr->fiksan=="P"
     @ prow(),pcol()+8 SAY aRekap[i,1]/nLjudi pict "999.99%"
     @ prow(),60 say aRekap[i,2]        pict gpici
   elseif tippr->fiksan=="C"
     @ prow(),60 say aRekap[i,2]        pict gpici
   elseif tippr->fiksan=="B"
     @ prow(),pcol()+8 SAY aRekap[i,1] pict "999999"; ?? " b"
     @ prow(),60 say aRekap[i,2]      pict gpici
   endif
  else
   if tippr->fiksan $ "DN"
     @ prow(),pcol()+5 SAY aRekap[i,1]  pict gpics; ?? " s"
     @ prow(),42 say aRekap[i,2]      pict gpici
     if tippr->uneto=="D"
        @ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     endif
   elseif tippr->fiksan=="P"
     @ prow(),pcol()+4 SAY aRekap[i,1]/nLjudi pict "999.99%"
     @ prow(),42 say aRekap[i,2]        pict gpici
     if tippr->uneto=="D"
        @ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     endif
   elseif tippr->fiksan=="C"
     @ prow(),42 say aRekap[i,2]        pict gpici
     if tippr->uneto=="D"
        @ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     endif
   elseif tippr->fiksan=="B"
     @ prow(),pcol()+4 SAY aRekap[i,1] pict "999999"; ?? " b"
     @ prow(),42 say aRekap[i,2]      pict gpici
     if tippr->uneto=="D"
        @ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     endif
   endif
  endif
   IF cMjesec==cMjesecDo
     Rekapld("PRIM"+tippr->id,cgodina,cmjesec,aRekap[i,2],aRekap[i,1])
   ELSE
     Rekapld("PRIM"+tippr->id,cgodina,cMjesecDo,aRekap[i,2],aRekap[i,1])
   ENDIF

#ifndef CPOR  // za porodilje to bi bio veliki spisak
    if "SUMKREDITA" $ tippr->formula
      if gReKrOs=="X"
        ? m
        ? "  ","Od toga pojedinacni krediti:"
        SELECT RADKR; SET ORDER TO TAG "3"
        SET FILTER TO STR(cGodina,4)+STR(cMjesec,2)<=STR(godina,4)+STR(mjesec,2) .and.;
                      STR(cGodina,4)+STR(cMjesecDo,2)>=STR(godina,4)+STR(mjesec,2)
        GO TOP
        DO WHILE !EOF()
          cIdKred:=IDKRED
          SELECT KRED; HSEEK cIdKred; SELECT RADKR
          nUkKred := 0
          DO WHILE !EOF() .and. IDKRED==cIdKred
            cNaOsnovu:=NAOSNOVU; cIdRadnKR:=IDRADN
            SELECT RADN; HSEEK cIdRadnKR; SELECT RADKR
            cOpis2   := RADNIK
            nUkKrRad := 0
            DO WHILE !EOF() .and. IDKRED==cIdKred .and. cNaOsnovu==NAOSNOVU .and. cIdRadnKR==IDRADN
              mj:=mjesec
              if fSvi
               select ld; set order to tag (TagVO("2")); hseek  str(cGodina,4)+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
               //"LDi2","str(godina)+str(mjesec)+idradn"
              else
                select ld; hseek  str(cGodina,4)+cidrj+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
              endif // fsvi
              select radkr
              if ld->(found())
                nUkKred  += iznos
                nUkKrRad += iznos
              endif
              SKIP 1
            ENDDO
            if nUkKrRad<>0
              Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cmjesecDo,nUkKrRad,0,cidkred,cnaosnovu,cOpis2,.t.)
            endif
          ENDDO
          IF nUkKred<>0    // ispisati kreditora
            if prow()>55+gPStranica
              FF
            endif
            ? "  ",cidkred,left(kred->naz,22)
            @ prow(),58 SAY nUkKred  pict "("+gpici+")"
          ENDIF
        ENDDO
      else
        ? m
        ? "  ","Od toga pojedinacni krediti:"
        cOpis2:=""
        select radkr; set order to 3  ; go top
        //"RADKRi3","idkred+naosnovu+idradn+str(godina)+str(mjesec)","RADKR")
        do while !eof()
         select kred; hseek radkr->idkred; select radkr
         private cidkred:=idkred, cNaOsnovu:=naosnovu
         select radn; hseek radkr->idradn; select radkr
         cOpis2:= RADNIK
         seek cidkred+cnaosnovu
         private nUkKred:=0
         do while !eof() .and. idkred==cidkred .and. ( cnaosnovu==naosnovu .or. gReKrOs=="N" )
          if fSvi
           select ld; set order to tag (TagVO("2")); hseek  str(cGodina,4)+str(cmjesec,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
           //"LDi2","str(godina)+str(mjesec)+idradn"
          else
            select ld; hseek  str(cGodina,4)+cidrj+str(cmjesec,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
          endif // fsvi
          select radkr
          if ld->(found()) .and. godina==cgodina .and. mjesec=cmjesec
            nUkKred+=iznos
          endif
          IF cMjesecDo>cMjesec
            FOR mj:=cMjesec+1 TO cMjesecDo
              if fSvi
               select ld; set order to tag (TagVO("2")); hseek  str(cGodina,4)+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
               //"LDi2","str(godina)+str(mjesec)+idradn"
              else
                select ld; hseek  str(cGodina,4)+cidrj+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
              endif // fsvi
              select radkr
              if ld->(found()) .and. godina==cgodina .and. mjesec=mj
                nUkKred+=iznos
              endif
            NEXT
          ENDIF
          skip
         enddo
         if nukkred<>0
          If prow()>55+gPStranica
            FF
          endif
          ? "  ",cidkred,left(kred->naz,22),IF(gReKrOs=="N","",cnaosnovu)
          @ prow(),58 SAY nUkKred  pict "("+gpici+")"
          IF cMjesec==cMjesecDo
            Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cmjesec,nukkred,0,cidkred,cnaosnovu, cOpis2)
          ELSE
            Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cMjesecDo,nukkred,0,cidkred,cnaosnovu, cOpis2)
          ENDIF
         endif
        enddo
        select ld
      endif
    endif
#endif  //CPOR

  endif   // tippr aktivan

next  // cldpolja

IF IzFMKIni("LD","Rekap_ZaIsplatuRasclanitiPoTekRacunima","N",KUMPATH)=="D" .and. LEN(aUkTR)>1
  ? m
  ? "ZA ISPLATU:"
  ? "-----------"
  nMArr:=SELECT()
  SELECT KRED
  ASORT(aUkTr,,,{|x,y| x[1]<y[1]})
  FOR i:=1 TO LEN(aUkTR)
    IF EMPTY(aUkTR[i,1])
      ? PADR("B L A G A J N A",LEN(aUkTR[i,1]+KRED->naz)+1)
    ELSE
      HSEEK aUkTR[i,1]
      ? aUkTR[i,1], KRED->naz
    ENDIF
    @ prow(),60 SAY aUkTR[i,2] pict gpici; ?? "",gValuta
  NEXT
  SELECT (nMArr)
ENDIF

? m
if !fPorNaRekap
   ?  "UKUPNO ZA ISPLATU";  @ prow(),60 SAY nUIznos pict gpici; ?? "",gValuta
else
   ?  "UKUPNO ZA ISPLATU";  @ prow(),42 SAY nUIznos pict gpici; ?? "",gValuta
endif

? m
IF !lGusto
  ?
ENDIF

// proizvoljni redovi pocinju sa "9"
?
select tippr; seek "9"
do while !eof() .and. left(id,1)="9"
  If prow()>55+gPStranica
    FF
  endif
  ? tippr->id+"-"+tippr->naz
  cPom:=tippr->formula
  if !fPorNaRekap
     @ prow(),60 say round2(&cPom,gZaok2)      pict gpici
  else
     @ prow(),42 say round2(&cPom,gZaok2)      pict gpici
  endif
  IF cMjesec==cMjesecDo
    Rekapld("PRIM"+tippr->id,cgodina,cmjesec,round2(&cpom,gZaok2),0)
  ELSE
    Rekapld("PRIM"+tippr->id,cgodina,cMjesecDo,round2(&cpom,gZaok2),0)
  ENDIF
  skip
  IF eof() .or. !left(id,1)="9"
    ? m
  ENDIF
enddo


IF cMjesec==cMjesecDo     // za viçe mjeseci nema prikaza poreza i doprinosa
IF !lGusto
  ?
ENDIF
nBO:=0
? "Koef. Bruto osnove (KBO):",transform(parobr->k3,"999.99999%")
?? space(3),"BRUTO OSNOVA = NETO OSNOVA*KBO ="
@ prow(),pcol()+1 SAY nBo:=round2(parobr->k3/100*nUNetoOsnova,gZaok2)  pict gpici
?

#ifdef CPOR
 IF cUmPD=="D"
   IF cMjesec==1
     cGodina2:=cGodina-1; cMjesec2:=12
   ELSE
     cGodina2:=cGodina; cMjesec2:=cMjesec-1
   ENDIF
   SELECT PAROBR
   nParRec:=RECNO()
   HSEEK STR(cMjesec2,2)+cObracun
   SELECT LD
   PushWA()
   USE
   select (F_LDNO); usex (KUMPATH+"LDNO") alias LD

   PRIVATE cFilt1:=""
   cFilt1 := ".t." + IF(EMPTY(cStrSpr),"",".and.IDSTRSPR=="+cm2str(cStrSpr))+;
                     IF(!fSvi.or.EMPTY(qqRJ),"",".and."+aUsl1)
   cFilt1 := STRTRAN(cFilt1,".t..and.","")
   IF cFilt1==".t."
     SET FILTER TO
   ELSE
     SET FILTER TO &cFilt1
   ENDIF

   if fSvi // sve radne jedinice
     set order to 2
     seek str(cGodina2,4)+str(cmjesec2,2)
   else
     set order to 1
     seek str(cGodina2,4)+cidrj+str(cmjesec2,2)
   endif

   nT1:=nT2:=nTPor:=nTDopr:=0
   n01:=0  // van neta plus
   n02:=0  // van neta minus
   do while !eof() .and.  cgodina2==godina .and. cmjesec2=mjesec .and. ( fSvi .or. cidrj==idrj )
    Scatter()
    select radn; hseek _idradn
    select vposla; hseek _idvposla
    select kbenef; hseek vposla->idkbenef
    select ld
    if (!empty(copsst) .and. copsst<>radn->idopsst)  .or.;
       (!empty(copsrad) .and. copsrad<>radn->idopsrad)
      skip 1; loop
    endif


    // neophodno zbog "po opstinama"
    ********************************
    select por; go top
    nPor:=nPorOl:=nUPorOl2:=0
    do while !eof()  // datoteka por
      PozicOps(POR->poopst)
      IF !ImaUOp("POR",POR->id)
        SKIP 1; LOOP
      ENDIF
      nPor+=round2(max(dlimit,iznos/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100)),gZaok2)
      skip
    enddo
    if radn->porol<>0 .and. gDaPorOl=="D" .and. !Obr2_9() // poreska olaksica
      if alltrim(cVarPorOl)=="2"
        nPorOl:=RADN->porol
      elseif alltrim(cVarPorol)=="1"
        nPorOl:=round(parobr->prosld*radn->porol/100,gZaok)
      else
        nPorOl:= &("_I"+cVarPorol)
      endif
      if nPorOl>nPor // poreska olaksica ne moze biti veca od poreza
        nPorOl:=nPor
      endif
      nUPorOl2+=nPorOl
    endif

    //**** nafiluj datoteku OPSLD *********************
    _uneto:=MAX(_uneto,PAROBR->prosld*gPDLimit/100)
    select ops; seek radn->idopsst
    select opsld
    seek "1"+radn->idopsst
    if found()
      replace piznos with piznos+_uneto, piznos2 with piznos2+nPorOl, pljudi WITH pljudi+1
    else
      append blank
      replace id with "1", idops   with radn->idopsst, piznos with _uneto,;
                           piznos2 with piznos2+nPorOl, pljudi WITH 1
    endif
    seek "3"+ops->idkan  // kanton stanovanja
    if found()
      replace piznos with piznos+_uneto, piznos2 with piznos2+nPorOl, pljudi WITH pljudi+1
    else
      append blank
      replace id with "3", idops   with ops->idkan, piznos with _uneto,;
                           piznos2 with piznos2+nPorOl, pljudi WITH 1
    endif
    seek "5"+ops->idn0  // entitet stanovanja
    if found()
      replace piznos with piznos+_uneto, piznos2 with piznos2+nPorOl, pljudi WITH pljudi+1
    else
      append blank
      replace id with "5", idops   with ops->idn0, piznos with _uneto,;
                           piznos2 with piznos2+nPorOl, pljudi WITH 1
    endif


    select ops; seek radn->idopsst
    select opsld
    seek "2"+radn->idopsrad
    if found()
      replace piznos with piznos+_uneto, piznos2 with piznos2+nPorOl, pljudi WITH pljudi+1
    else
      append blank
      replace id with "2", idops   with radn->idopsrad, piznos with _uneto,;
                           piznos2 with piznos2+nPorOl, pljudi WITH 1
    endif
    seek "4"+ops->idkan  // kanton rada
    if found()
      replace piznos with piznos+_uneto, piznos2 with piznos2+nPorOl, pljudi WITH pljudi+1
    else
      append blank
      replace id with "4", idops   with ops->idkan, piznos with _uneto,;
                           piznos2 with piznos2+nPorOl, pljudi WITH 1
    endif
    seek "6"+ops->idn0  // entitet rada
    if found()
      replace piznos with piznos+_uneto, piznos2 with piznos2+nPorOl, pljudi WITH pljudi+1
    else
      append blank
      replace id with "6", idops   with ops->idn0, piznos with _uneto,;
                           piznos2 with piznos2+nPorOl, pljudi WITH 1
    endif
    ********************************

    select ld
    n01:=0; n02:=0
    for i:=1 to cLDPolja
     cPom:=padl(alltrim(str(i)),2,"0")
     select tippr; seek cPom; select ld

     if tippr->(found()) .and. tippr->aktivan=="D"
      nIznos:=_i&cpom
      if cpom=="01"
         n01+=nIznos
      else
         n02+=nIznos
      endif
     endif
    next
    nT1+=n01
    nT2+=n02
    skip 1
   enddo  // LD
   nUNeto2:=nT1+nT2
   nBo2:=round2(parobr->k3/100*nUNeto2,gZaok2)
   // gPDLimit?!
   nPK3:=PAROBR->K3
   USE
   SELECT PAROBR
   GO (nParRec)
   O_LD
   PopWA()
 ENDIF
#endif



select por
go top
nPom:=nPor:=nPor2:=nPorOps:=nPorOps2:=0
nC1:=20

m:="----------------------- -------- ----------- -----------"
if cUmPD=="D"
  m+=" ----------- -----------"
endif

if cUmPD=="D"
  P_12CPI
  ? "----------------------- -------- ----------- ----------- ----------- -----------"
  ? "                                 Obracunska     Porez    Preplaceni     Porez   "
  ? "     Naziv poreza          %      osnovica   po obracunu    porez     za uplatu "
  ? "          (1)             (2)        (3)     (4)=(2)*(3)     (5)     (6)=(4)-(5)"
  ? "----------------------- -------- ----------- ----------- ----------- -----------"
endif

do while !eof()

  If prow()>55+gPStranica
    FF
  endif

   ? id,"-",naz
   @ prow(),pcol()+1 SAY iznos pict "99.99%"
   nC1:=pcol()+1

   if !empty(poopst)
     if poopst=="1"
       ?? " (po opst.stan)"
     elseif poopst=="2"
       ?? " (po opst.stan)"
     elseif poopst=="3"
       ?? " (po kant.stan)"
     elseif poopst=="4"
       ?? " (po kant.rada)"
     elseif poopst=="5"
       ?? " (po ent. stan)"
     elseif poopst=="6"
       ?? " (po ent. rada)"
       ?? " (po opst.rada)"
     endif
     nOOP:=0      // ukupna Osnovica za ObraŸun Poreza za po opçtinama
     nPOLjudi:=0  // ukup.ljudi za po opçtinama
     nPorOps:=0
     nPorOps2:=0
     select opsld
     seek por->poopst
     ? strtran(m,"-","=")
     do while !eof() .and. id==por->poopst   //idopsst
         select ops; hseek opsld->idops; select opsld
         IF !ImaUOp("POR",POR->id)
           SKIP 1; LOOP
         ENDIF
         ? idops,ops->naz
         @ prow(),nc1 SAY iznos picture gpici
         @ prow(),pcol()+1 SAY nPom:=round2(max(por->dlimit,por->iznos/100*iznos),gZaok2) pict gpici
         if cUmPD=="D"
           // ______  PORLD ______________
           @ prow(),pcol()+1 SAY nPom2:=round2(max(por->dlimit,por->iznos/100*piznos),gZaok2) pict gpici
           @ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
           Rekapld("POR"+por->id+idops,cgodina,cmjesec,nPom-nPom2,0,idops,NLjudi())
           nPorOps2+=nPom2
         else
           Rekapld("POR"+por->id+idops,cgodina,cmjesec,nPom,iznos,idops,NLjudi())
         endif
         nOOP += iznos
         nPOLjudi += ljudi
         nPorOps+=nPom
         skip
         if prow()>62+gPStranica; FF; endif
     enddo
     select por
     ? m
     nPor+=nPorOps
     nPor2+=nPorOps2
   endif // poopst
   if !empty(poopst)
     ? m
     ? "Ukupno:"
//     @ prow(),nc1 SAY nUNeto pict gpici
     @ prow(),nc1 SAY nOOP pict gpici
     @ prow(),pcol()+1 SAY nPorOps   pict gpici
     if cUmPD=="D"
       @ prow(),pcol()+1 SAY nPorOps2   pict gpici
       @ prow(),pcol()+1 SAY nPorOps-nPorOps2   pict gpici
       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps-nPorOps2,0,,NLjudi())
     else
//       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps,nUNeto,,NLjudi())
       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps,nOOP,,"("+ALLTRIM(STR(nPOLjudi))+")")
     endif
     ? m
   else
     @ prow(),nc1 SAY nUNeto pict gpici
     @ prow(),pcol()+1 SAY nPom:=round2(max(dlimit,iznos/100*nUNeto),gZaok2) pict gpici
     if cUmPD=="D"
       @ prow(),pcol()+1 SAY nPom2:=round2(max(dlimit,iznos/100*nUNeto2),gZaok2) pict gpici
       @ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
       Rekapld("POR"+por->id,cgodina,cmjesec,nPom-nPom2,0)
       nPor2+=nPom2
     else
       Rekapld("POR"+por->id,cgodina,cmjesec,nPom,nUNeto,,"("+ALLTRIM(STR(nLjudi))+")")
     endif
     nPor+=nPom
   endif


  skip
enddo
if round2(nUPorOl,2)<>0 .and. gDaPorOl=="D" .and. !Obr2_9()
   ? "PORESKE OLAKSICE"
   select por; go top
   nPOlOps:=0
   if !empty(poopst)
      if poopst=="1"
       ?? " (po opst.stan)"
      else
       ?? " (po opst.rada)"
      endif
      nPOlOps:=0
      select opsld
      seek por->poopst
      do while !eof() .and. id==por->poopst
         If prow()>55+gPStranica
           FF
         endif
         select ops; hseek opsld->idops; select opsld
         IF !ImaUOp("POR",POR->id)
           SKIP 1; LOOP
         ENDIF
         ? idops, ops->naz
         @ prow(), nc1 SAY parobr->prosld picture gpici
         @ prow(), pcol()+1 SAY round2(iznos2,gZaok2)    picture gpici
         Rekapld("POROL"+por->id+opsld->idops,cgodina,cmjesec,round2(iznos2,gZaok2),0,opsld->idops,NLjudi())
         skip
         if prow()>62+gPStranica; FF; endif
      enddo
      select por
      ? m
      ? "UKUPNO POR.OL"
   endif // poopst
   @ prow(),nC1 SAY parobr->prosld  pict gpici
   @ prow(),pcol()+1 SAY round2(nUPorOl,gZaok2)    pict gpici
   Rekapld("POROL"+por->id,cgodina,cmjesec,round2(nUPorOl,gZaok2),0,,"("+ALLTRIM(STR(nLjudi))+")")
   if !empty(poopst); ? m; endif

endif
? m
? "Ukupno Porez"
@ prow(),nC1 SAY space(len(gpici))
@ prow(),pcol()+1 SAY nPor-nUPorOl pict gpici
if cUmPD=="D"
  @ prow(),pcol()+1 SAY nPor2              pict gpici
  @ prow(),pcol()+1 SAY nPor-nUPorOl-nPor2 pict gpici
endif
? m
IF !lGusto
 ?
 ?
ENDIF
?
if prow()>55+gpStranica
	FF
endif


m:="----------------------- -------- ----------- -----------"
if cUmPD=="D"
  m+=" ----------- -----------"
endif
select dopr; go top
nPom:=nDopr:=0
nPom2:=nDopr2:=0
nC1:=20

if cUmPD=="D"
  ? "----------------------- -------- ----------- ----------- ----------- -----------"
  ? "                                 Obracunska   Doprinos   Preplaceni   Doprinos  "
  ? "    Naziv doprinosa        %      osnovica   po obracunu  doprinos    za uplatu "
  ? "          (1)             (2)        (3)     (4)=(2)*(3)     (5)     (6)=(4)-(5)"
  ? "----------------------- -------- ----------- ----------- ----------- -----------"
endif

do while !eof()
  if prow()>55+gpStranica; FF; endif

  if right(id,1)=="X"
   ? m
  endif
  ? id,"-",naz

  @ prow(),pcol()+1 SAY iznos pict "99.99%"
  nC1:=pcol()+1

  if empty(idkbenef) // doprinos udara na neto

    altd()
    if !empty(poopst)
      if poopst=="1"
        ?? " (po opst.stan)"
      elseif poopst=="2"
        ?? " (po opst.rada)"
      elseif poopst=="3"
        ?? " (po kant.stan)"
      elseif poopst=="4"
        ?? " (po kant.rada)"
      elseif poopst=="5"
        ?? " (po ent. stan)"
      elseif poopst=="6"
        ?? " (po ent. rada)"
      endif
      ? strtran(m,"-","=")
      nOOD:=0          // ukup.osnovica za obraŸun doprinosa za po opçtinama
      nPOLjudi:=0      // ukup.ljudi za po opçtinama
      nDoprOps:=0
      nDoprOps2:=0
      select opsld
      seek dopr->poopst
      altd()
      do while !eof() .and. id==dopr->poopst
        altd()
        select ops; hseek opsld->idops; select opsld
        IF !ImaUOp("DOPR",DOPR->id)
          SKIP 1; LOOP
        ENDIF
        ? idops,ops->naz
        nBOOps:=round2(iznos*parobr->k3/100,gZaok2)
        @ prow(),nc1 SAY nBOOps picture gpici
        nPom:=round2(max(dopr->dlimit,dopr->iznos/100*nBOOps),gZaok2)
        if cUmPD=="D"
          nBOOps2:=round2(piznos*nPK3/100,gZaok2)
          nPom2:=round2(max(dopr->dlimit,dopr->iznos/100*nBOOps2),gZaok2)
        endif
        if round(dopr->iznos,4)=0 .and. dopr->dlimit>0
          nPom:=dopr->dlimit*opsld->ljudi
          if cUmPD=="D"
            nPom2:=dopr->dlimit*opsld->pljudi
          endif
        endif
        @ prow(),pcol()+1 SAY  nPom picture gpici
        if cUmPD=="D"
          @ prow(),pcol()+1 SAY  nPom2 picture gpici
          @ prow(),pcol()+1 SAY  nPom-nPom2 picture gpici
          Rekapld("DOPR"+dopr->id+idops,cgodina,cmjesec,nPom-nPom2,0,idops,NLjudi())
          nDoprOps2+=nPom2
          nDoprOps+=nPom
        else
          Rekapld("DOPR"+dopr->id+opsld->idops,cgodina,cmjesec,npom,nBOOps,idops,NLjudi())
          nDoprOps+=nPom
        endif
        nOOD += nBOOps
        nPOLjudi += ljudi
        skip
        if prow()>62+gPStranica; FF; endif
      enddo // opsld
      select dopr
      ? m
      ? "UKUPNO ",DOPR->ID
//      @ prow(),nC1 SAY nBO pict gpici
      @ prow(),nC1 SAY nOOD pict gpici
      @ prow(),pcol()+1 SAY nDoprOps pict gpici
      if cUmPD=="D"
        @ prow(),pcol()+1 SAY nDoprOps2 pict gpici
        @ prow(),pcol()+1 SAY nDoprOps-nDoprOps2 pict gpici
        Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nDoprOps-nDoprOps2,0,,NLjudi())
        nPom2:=nDoprOps2
      else
        if nDoprOps>0
//          Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nDoprOps,nBO,,NLjudi())
          Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nDoprOps,nOOD,,"("+ALLTRIM(STR(nPOLjudi))+")")
        endif
      endif
      ? m
      nPom:=nDoprOps
    else
      // doprinosi nisu po opstinama
      altd()
      @ prow(),nC1 SAY nBO pict gpici
      nPom:=round2(max(dlimit,iznos/100*nBO),gZaok2)
      if cUmPD=="D"
        nPom2:=round2(max(dlimit,iznos/100*nBO2),gZaok2)
      endif
      if round(iznos,4)=0 .and. dlimit>0
          nPom:=dlimit*nljudi      // nije po opstinama
          if cUmPD=="D"
            nPom2:=dlimit*nljudi      // nije po opstinama ?!?nLjudi
          endif
      endif
      @ prow(),pcol()+1 SAY nPom pict gpici
      if cUmPD=="D"
        @ prow(),pcol()+1 SAY nPom2 pict gpici
        @ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
        Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nPom-nPom2,0)
      else
        Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nPom,nBO,,"("+ALLTRIM(STR(nLjudi))+")")
      endif
    endif // poopst
  else
  //**************** po stopama beneficiranog radnog staza ?? nije testirano
    nPom0:=ASCAN(aNeta,{|x| x[1]==idkbenef})
    if nPom0<>0
      nPom2:=parobr->k3/100*aNeta[nPom0,2]
    else
      nPom2:=0
    endif
    if round2(nPom2,gZaok2)<>0
      @ prow(),pcol()+1 SAY nPom2 pict gpici
      nC1:=pcol()+1
      @ prow(),pcol()+1 SAY nPom:=round2(max(dlimit,iznos/100*nPom2),gZaok2) pict gpici
    endif
  endif  // ****************  nije testirano

  if right(id,1)=="X"
    ? m
    IF !lGusto
      ?
    ENDIF
    nDopr+=nPom
    if cUmPD=="D"
      nDopr2+=nPom2
    endif
  endif

  skip
  if prow()>56+gPStranica; FF; endif
enddo
? m
? "Ukupno Doprinosi"
@ prow(),nc1 SAY space(len(gpici))
@ prow(),pcol()+1 SAY nDopr  pict gpici
if cUmPD=="D"
  @ prow(),pcol()+1 SAY nDopr2  pict gpici
  @ prow(),pcol()+1 SAY nDopr-nDopr2  pict gpici
endif
? m
IF cUmPD=="D"
  P_10CPI
ENDIF
?
?


m:="---------------------------------"
altd()
if prow()>49+gPStranica; FF; endif
? m
? "     NETO PRIMANJA:"
@ prow(),pcol()+1 SAY nUNeto pict gpici
?? "(za isplatu:"
@ prow(),pcol()+1 SAY nUNeto+nUOdbiciM pict gpici
?? ",Obustave:"
@ prow(),pcol()+1 SAY -nUOdbiciM pict gpici
?? ")"

? " PRIMANJA VAN NETA:"
@ prow(),pcol()+1 SAY nUOdbiciP pict gpici  // dodatna primanja van neta
? "            POREZI:"
IF cUmPD=="D"
  @ prow(),pcol()+1 SAY nPor-nUPorOl-nPor2    pict gpici
ELSE
  @ prow(),pcol()+1 SAY nPor-nUPorOl    pict gpici
ENDIF
? "         DOPRINOSI:"
IF cUmPD=="D"
  @ prow(),pcol()+1 SAY nDopr-nDopr2    pict gpici
ELSE
  @ prow(),pcol()+1 SAY nDopr    pict gpici
ENDIF
? m
IF cUmPD=="D"
  ? " POTREBNA SREDSTVA:"
  @ prow(),pcol()+1 SAY nUNeto+nUOdbiciP+(nPor-nUPorOl)+nDopr-nPor2-nDopr2    pict gpici
ELSE
  ? " POTREBNA SREDSTVA:"
  @ prow(),pcol()+1 SAY nUNeto+nUOdbiciP+(nPor-nUPorOl)+nDopr    pict gpici
ENDIF
? m

?
? "Izvrsena obrada na ",str(nLjudi,5),"radnika"
?
if nUSati==0; nUSati:=999999; endif
? "Prosjecni neto/satu je",alltrim(transform(nUNeto,gpici)),"/",alltrim(str(nUSati)),"=",;
   alltrim(transform(nUNeto/nUsati,gpici)),"*",alltrim(transform(parobr->k1,"999")),"=",;
   alltrim(transform(nUneto/nUsati*parobr->k1,gpici))

ELSE // cMjesec==cMjesecDo // za viçe mjeseci nema prikaza poreza i doprinosa
  // ali se mo§e dobiti bruto osnova i prosjeŸni neto po satu
  // --------------------------------------------------------
  ASORT(aNetoMj,,,{|x,y| x[1]<y[1]})
  ?
  ?     "MJESEC³  UK.NETO  ³UK.SATI³KOEF.BRUTO³FOND SATI³BRUTO OSNOV³PROSJ.NETO "
  ?     " (A)  ³    (B)    ³  (C)  ³   (D)    ³   (E)   ³(B)*(D)/100³(E)*(B)/(C)"
  ? ms:="ÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄ"
  nT1:=nT2:=nT3:=nT4:=nT5:=0
  FOR i:=1 TO LEN(aNetoMj)
    ? STR(aNetoMj[i,1],4,0) +". ³"+;
      TRANS(aNetoMj[i,2],gPicI) +"³"+;
      STR(aNetoMj[i,3],7) +"³"+;
      TRANS(aNetoMj[i,4],"999.99999%") +"³"+;
      STR(aNetoMj[i,5],9) +"³"+;
      TRANS(ROUND2(aNetoMj[i,2]*aNetoMj[i,4]/100,gZaok2),gPicI) +"³"+;
      TRANS(aNetoMj[i,5]*aNetoMj[i,2]/aNetoMj[i,3],gPicI)
      nT1 += aNetoMj[i,2]
      nT2 += aNetoMj[i,3]
      nT3 += aNetoMj[i,5]
      nT4 += ROUND2(aNetoMj[i,2]*aNetoMj[i,4]/100,gZaok2)
      nT5 += aNetoMj[i,5]*aNetoMj[i,2]/aNetoMj[i,3]
  NEXT
  nT5 := nT5/LEN(aNetoMj)
  // nT5 := nT3*nT1/nT2
  ? ms
  ?     "UKUPNO³"+;
      TRANS(nT1,gPicI) +"³"+;
      STR(nT2,7) +"³"+;
      "          "+"³"+;
      STR(nT3,9) +"³"+;
      TRANS(nT4,gPicI) +"³"+;
      TRANS(nT5,gPicI)

ENDIF

?
P_10CPI
if prow()<62+gPStranica
 nPom:=62+gPStranica-prow()
 for i:=1 to nPom
   ?
 next
endif
?  PADC("     Obradio:                                 Direktor:    ",80)
?
?  PADC("_____________________                    __________________",80)
?
FF
IF lGusto
  gRPL_Normal()
  gPStranica-=nDSGusto
ENDIF
END PRINT
CLOSERET


function RekapLD_OLD(cId,ngodina,nmjesec,nizn1,nizn2,cidpartner,copis,copis2,lObavDodaj)
*{

if lObavDodaj==NIL; lObavDodaj:=.f.; ENDIF

if cidpartner=NIL
  cidpartner=""
endif

if copis=NIL
  copis=""
endif
if copis2=NIL
  copis2=""
endif

pushwa()
select rekld
if lObavDodaj
  append blank
else
  seek str(ngodina,4)+str(nmjesec,2)+cid+" "
  if !found()
       append blank
  endif
endif
replace godina with str(ngodina,4),  mjesec with str(nmjesec,2),;
        id    with  cid,;
        iznos1 with nizn1, iznos2 with nizn2,;
        idpartner with cidpartner,;
        opis with copis ,;
        opis2 with cOpis2

popwa()
return
*}


function UKartPl()
*{
local nC1:=20
local i
cIdRadn:=space(_LR_)
cIdRj:=gRj
cMjesec:=gMjesec
cMjesec2:=gmjesec
cGodina:=gGodina
cObracun:=gObracun
cRazdvoji := "N"

O_LD

 copy structure extended to struct
 use
 SELECT 100             // ovo malo siri strukturu
 USE struct             // naime, polja sa satima su premala za
 GO TOP                 // rekapitulairanje vise mjeseci
 While ! Eof()
   IF LEN (Trim (Field_Name))==3 .and. Left (Field_Name, 1)="S"
     REPLACE Field_Len WITH Field_Len + 3
   EndIF
   SKIP
 EndDO
 select Struct; USE
 ferase(PRIVPATH+"_LD.CDX")
 cPom:=PRIVPATH+"_LD"
 create (cPom) from struct
 use (cPom)
 index on idradn+idrj tag "1"
 
 close all
 O_PAROBR
 O_RJ
 O_RADN
 O_VPOSLA
 O_RADKR
 O_KRED
 O__LD
 set order to tag "1"

#ifdef CPOR
 IF lIsplaceni
   O_LD
 ELSE
   select (F_LDNO)  
   usex (KUMPATH+"LDNO") alias LD
   set order to 1
 ENDIF
#else
 O_LD
#endif


 cIdRadn:=space(_LR_)

 cSatiVO:="S"

 Box(,6,77)
   @ m_x+1,m_y+2 SAY "Radna jedinica (prazno-sve rj): "  GET cIdRJ valid empty(cidrj) .or. P_RJ(@cidrj)
   @ m_x+2,m_y+2 SAY "od mjeseca: "  GET  cmjesec  pict "99"
   @ m_x+2,col()+2 SAY "do"  GET  cmjesec2  pict "99"
   if lViseObr
     @ m_x+2,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
   endif
   @ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
   @ m_x+4,m_y+2 SAY "Radnik (prazno-svi radnici):" GET cIdRadn  valid empty(cIdRadn) .or. P_Radn(@cIdRadn)
   @ m_x+5,m_y+2 SAY "Razdvojiti za radnika po RJ:" GET cRazdvoji pict "@!";
                     when Empty (cIdRj) valid cRazdvoji $ "DN"
   read; clvbox(); ESC_BCR
   if lViseObr .and. EMPTY(cObracun)
     @ m_x+6,m_y+2 SAY "Prikaz sati (S-sabrati sve obracune , 1-obracun 1 , 2-obracun 2, ... )" GET cSatiVO VALID cSatiVO$"S123456789" PICT "@!"
     read; ESC_BCR
   endif
  BoxC()

if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif

SELECT LD

if lViseObr .and. !EMPTY(cObracun)
  SET FILTER TO obr=cObracun
endif

cIdRadn:=trim(cidradn)
if empty(cidrj)
  set order to tag (TagVO("4"))
  seek str(cGodina,4)+cIdRadn
  cIdrj:=""
else
  set order to tag (TagVO("3"))
  seek str(cGodina,4)+cidrj+cIdRadn
endif
EOF CRET

nStrana:=0

IF cRazdvoji=="N"
  bZagl:={|| ;
             qqout("OBRACUN"+ IIF(lViseObr,IF(EMPTY(cObracun)," ' '(SVI)"," '"+cObracun+"'"),"")+ Lokal(" PLATE ZA PERIOD") + str(cmjesec,2)+"-"+str(cmjesec2,2)+"/"+str(godina,4)," ZA "+UPPER(TRIM(gTS))+" ",gNFirma),;
             qout("RJ:",idrj,rj->naz),;
             qout(idradn,"-",RADNIK,"Mat.br:",radn->matbr," STR.SPR:",IDSTRSPR),;
             qout( Lokal("Broj knjizice:"), RADN->brknjiz),;
             qout("Vrsta posla:",idvposla,vposla->naz, Lokal("        U radnom odnosu od "), radn->datod);
         }
Else
  bZagl:={|| ;
             qqout( Lokal("OBRACUN") + IIF(lViseObr, IIF(EMPTY(cObracun)," ' '(SVI)"," '"+cObracun+"'"),"")+ Lokal(" PLATE ZA PERIOD") + str(cmjesec,2)+"-"+str(cmjesec2,2)+"/"+str(godina,4)," ZA "+UPPER(TRIM(gTS))+" ",gNFirma),;
             qout(idradn,"-",RADNIK,"Mat.br:",radn->matbr," STR.SPR:",IDSTRSPR),;
             qout("Broj knjizice:",RADN->brknjiz),;
             qout("Vrsta posla:", idvposla, vposla->naz, Lokal("        U radnom odnosu od "), radn->datod);
         }
EndIF

select vposla
hseek ld->idvposla
select rj
hseek ld->idrj
select ld

if pcount()==4
  START PRINT RET
else
  START PRINT CRET
endif

select ld
nT1:=nT2:=nT3:=nT4:=0
do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. idradn=cIdRadn

xIdRadn:=idradn
IF cRazdvoji=="N"
  Scatter("w")
  for i:=1 to cLDPolja
    cPom:=padl(alltrim(str(i)),2,"0")
    ws&cPom:=0
    wi&cPom:=0
    wUNeto:=wUSati:=wUIznos:=0
  next
EndIF

IF cRazdvoji=="N"
  select radn; hseek xidradn
  select vposla; hseek ld->idvposla
  select rj; hseek ld->idrj; select ld
  Eval(bZagl)
EndIF
do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. idradn==xIdRadn

 m:="----------------------- --------  ----------------   ------------------"

 select radn; hseek xidradn; select ld

 if (mjesec<cmjesec .or. mjesec>cmjesec2)
   skip; loop
 endif
 Scatter()
 IF cRazdvoji=="D"
   SELECT _LD
   HSEEK xIdRadn+LD->IdRj
   IF ! Found()
     Append Blank
   EndIF
   Scatter ("w")
   For i:=1 To cLDpolja
     cPom:=padl(alltrim(str(i)),2,"0")
     IF !lViseObr .or. cSatiVO=="S" .or. cSatiVO==_obr
       ws&cPom+=_s&cPom
     ENDIF
     wi&cPom+=_i&cPom
   Next
   wUIznos+=_UIznos
   IF !lViseObr .or. cSatiVO=="S" .or. cSatiVO==_obr
     wUSati+=_USati
   ENDIF
   wUNeto+=_UNeto
   wIdRj := _IdRj
   wIdRadn := xIdRadn
   Gather("w")
   SELECT LD
   SKIP; LOOP
 EndIF
 
 cUneto:="D"
 for i:=1 to cLDPolja
  cPom:=padl(alltrim(str(i)),2,"0")
  select tippr; seek cPom
  IF !lViseObr .or. cSatiVO=="S" .or. cSatiVO==_obr
    ws&cPom+=_s&cPom
  ENDIF
  wi&cPom+=_i&cPom
 next
 select ld
 wUIznos+=_UIznos
 IF !lViseObr .or. cSatiVO=="S" .or. cSatiVO==_obr
   wUSati+=_USati
 ENDIF
 wUNeto+=_UNeto
 skip
enddo

 IF cRazdvoji=="N"
   ? m
   ? Lokal(" Vrsta                  Opis         sati/iznos             ukupno")
   ? m
   cUneto:="D"
   for i:=1 to cLDPolja
     cPom:=padl(alltrim(str(i)),2,"0")
     select tippr; seek cPom
     if tippr->uneto=="N" .and. cUneto=="D"
       cUneto:="N"
       ? m
       ? Lokal("UKUPNO NETO:")
       @ prow(),nC1+8  SAY  wUSati  pict gpics
       ?? Lokal(" sati")
       @ prow(),60 SAY wUNeto pict gpici; ?? "",gValuta
       ? m
     endif

     if tippr->(found()) .and. tippr->aktivan=="D"
      if wi&cpom<>0 .or. ws&cPom<>0
       ? tippr->id+"-"+tippr->naz,tippr->opis
       nC1:=pcol()
       if tippr->fiksan $ "DN"
          @ prow(),pcol()+8 SAY ws&cPom  pict gpics; ?? " s"
          @ prow(),60 say wi&cPom        pict gpici
       elseif tippr->fiksan=="P"
          @ prow(),pcol()+8 SAY ws&cPom  pict "999.99%"
          @ prow(),60 say wi&cPom        pict gpici
       elseif tippr->fiksan=="B"
          @ prow(),pcol()+8 SAY ws&cPom  pict "999999"; ?? " b"
          @ prow(),60 say wi&cPom        pict gpici
       elseif tippr->fiksan=="C"
          @ prow(),60 say wi&cPom        pict gpici
       endif
      endif
     endif
   next
   ? m
   ?  Lokal("UKUPNO ZA ISPLATU")  
   @ prow(),60 SAY wUIznos pict gpici; ?? "",gValuta
   ? m
   if prow()>31
       FF
   else
       ?
       ?
       ?
       ?
   endif
 Else
   SELECT _LD
   GO TOP
   select radn; hseek _LD->idradn
   select vposla; hseek _LD->idvposla
   SELECT _LD
   Eval(bZagl)
   ?
   While ! Eof()
     select rj; hseek _ld->idrj; select _ld
     qout("RJ:",idrj,rj->naz)
     ? m
     ? Lokal(" Vrsta                  Opis         sati/iznos             ukupno")
     ? m
     *
     Scatter("w")
     cUneto:="D"
     for i:=1 to cLDPolja
       cPom:=padl(alltrim(str(i)),2,"0")
       select tippr; seek cPom
       if tippr->uneto=="N" .and. cUneto=="D"
         cUneto:="N"
         ? m
         ? Lokal("UKUPNO NETO:")
	 @ prow(),nC1+8  SAY  wUSati  pict gpics; ?? " sati"
         @ prow(),60 SAY wUNeto pict gpici; ?? "",gValuta
         ? m
       endif

       if tippr->(found()) .and. tippr->aktivan=="D"
        if wi&cpom<>0 .or. ws&cPom<>0
         ? tippr->id+"-"+tippr->naz,tippr->opis
         nC1:=pcol()
         if tippr->fiksan $ "DN"
            @ prow(),pcol()+8 SAY ws&cPom  pict gpics; ?? " s"
            @ prow(),60 say wi&cPom        pict gpici
         elseif tippr->fiksan=="P"
            @ prow(),pcol()+8 SAY ws&cPom  pict "999.99%"
            @ prow(),60 say wi&cPom        pict gpici
         elseif tippr->fiksan=="B"
            @ prow(),pcol()+8 SAY ws&cPom  pict "999999"; ?? " b"
            @ prow(),60 say wi&cPom        pict gpici
         elseif tippr->fiksan=="C"
            @ prow(),60 say wi&cPom        pict gpici
         endif
        endif
       endif
     next
     ? m
     ?  "UKUPNO ZA ISPLATU U RJ", _LD->IdRj
     @ prow(),60 SAY wUIznos pict gpici
     ?? "",gValuta
     ? m
     if prow()>60+gPstranica
         FF
     else
         ?
         ?
     endif
     SELECT _LD
     SKIP
   EndDO
 EndIF
 select ld

enddo

 FF
 END PRINT
closeret


********************************
* rekapitulacija primanja radnika
* nedovrseno
********************************
function RekapRad()
local nC1:=20,i

 cIdRadn:=space(_LR_)
 cIdRj:=gRj
 cMjesec:=gMjesec
 cMjesec2:=gmjesec
 cGodina:=gGodina
 cObracun:=gObracun

 O_PAROBR
 O_RJ
 O_RADN
 O_VPOSLA
 O_RADKR
 O_KRED
 O_LD

 cIdRadn:=space(_LR_)

 Box(,4,75)
   @ m_x+1,m_y+2 SAY "Radna jedinica (prazno-sve rj): "  GET cIdRJ valid empty(cidrj) .or. P_RJ(@cidrj)
   @ m_x+2,m_y+2 SAY "od mjeseca: "  GET  cmjesec  pict "99"
   @ m_x+2,col()+2 SAY "do"  GET  cmjesec2  pict "99"
   if lViseObr
     @ m_x+2,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
   endif
   @ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
   @ m_x+4,m_y+2 SAY "Radnik (prazno-svi radnici): "  GET  cIdRadn  valid empty(cIdRadn) .or. P_Radn(@cIdRadn)
   read; clvbox(); ESC_BCR
 BoxC()

if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif

SELECT LD

if lViseObr .and. !EMPTY(cObracun)
  SET FILTER TO obr=cObracun
endif

cIdRadn:=trim(cidradn)
if empty(cidrj)
  set order to tag (TagVO("4"))
  seek str(cGodina,4)+cIdRadn
  cIdrj:=""
else
  set order to tag (TagVO("3"))
  seek str(cGodina,4)+cidrj+cIdRadn
endif
EOF CRET

nStrana:=0
bZagl:={|| ;
           qqout( Lokal("PREGLED PRIMANJA ZA PERIOD ") + str(cmjesec,2) + "-" + str(cmjesec2,2) + IspisObr()+"/"+str(godina,4)," ZA "+UPPER(TRIM(gTS))+" ",gNFirma),;
           qout("RJ:",idrj,rj->naz),;
           qout(idradn,"-",RADNIK,"Mat.br:",radn->matbr," STR.SPR:",IDSTRSPR),;
           qout("Vrsta posla:",idvposla,vposla->naz,"        U radnom odnosu od ",radn->datod);
       }

select vposla
hseek ld->idvposla
select rj
hseek ld->idrj
select ld

if pcount()==4
  START PRINT RET
else
  START PRINT CRET
endif

//ParObr(cmjesec)
select ld
nT1:=nT2:=nT3:=nT4:=0
do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. idradn=cIdRadn



Scatter("w")
xIdRadn:=idradn
for i:=1 to cLDPolja
   cPom:=padl(alltrim(str(i)),2,"0")
   ws&cPom:=0
   wi&cPom:=0
   wUNeto:=wUSati:=wUIznos:=0
next

select radn; hseek xidradn
select vposla; hseek ld->idvposla
select rj; hseek ld->idrj; select ld
Eval(bZagl)

//nNeto:=0
//nBruto:=bruto
//nBolovanje:=0
? Lokal(" Mjesec      Sati    NETO          BRUTO         Doprinosi         Stopa               Iznos            ")

? Lokal("                                                                  dopr.PIO         naknade bolovanje     ")

do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. idradn==xIdRadn

 m:="----------------------- --------  ----------------   ------------------"

 select radn; hseek xidradn; select ld

// jedan mjesec mjesec
 Scatter()
 cUneto:="D"
 for i:=1 to cLDPolja
  cPom:=padl(alltrim(str(i)),2,"0")
  select tippr; seek cPom
  ws&cPom+=_s&cPom
  wi&cPom+=_i&cPom
 next
 select ld
 wUIznos+=_UIznos
 wUSati+=_USati
 wUNeto+=_UNeto
 skip
? str(mjesec,2)
@ prow(),pcol()+1 SAY _USati pict gpici
@ prow(),pcol()+1 SAY _UNeto  pict gpici
enddo
? "---"
? str(mjesec,2)
@ prow(),pcol()+1 SAY  wUSati  pict gpici
@ prow(),pcol()+1 SAY  wUNeto  pict gpici
?

 select ld

enddo

 FF
END PRINT

CLOSERET


// ------------------------------
// ------------------------------
function SpecifRasp()

gnLMarg:=0; gTabela:=1; gOstr:="D"

cIdRj:=gRj; cmjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun

O_RJ
O_RADN
O_LD
private cFormula:=PADR("UNETO",40)
private cNaziv:=PADR("UKUPNO NETO",20)
cDod:="N"

nDo1 := 85; nDo2 := 150; nDo3 := 200; nDo4 := 250; nDo5  := 300
nDo6 := 0 ; nDo7 := 0  ; nDo8 := 0  ; nDo9 := 0  ; nDo10 := 0
nDo11:= 0 ; nDo12:= 0  ; nDo13:= 0  ; nDo14:= 0  ; nDo15 := 0
nDo16:= 0 ; nDo17:= 0  ; nDo18:= 0  ; nDo19:= 0  ; nDo20 := 0

O_PARAMS
Private cSection:="4",cHistory:=" ",aHistory:={}

RPar("p1",@cNaziv)
RPar("p2",@cFormula)
RPar("p3",@nDo1)
RPar("p4",@nDo2)
RPar("p5",@nDo3)
RPar("p6",@nDo4)
RPar("p7",@nDo5)
RPar("p8",@nDo6)
RPar("p9",@nDo7)
RPar("r0",@nDo8)
RPar("r1",@nDo9)
RPar("r2",@nDo10)
RPar("r3",@nDo11)
RPar("r4",@nDo12)
RPar("r5",@nDo13)
RPar("r6",@nDo14)
RPar("r7",@nDo15)
RPar("r8",@nDo16)
RPar("r9",@nDo17)
RPar("s0",@nDo18)
RPar("s1",@nDo19)
RPar("s2",@nDo20)

Box(,19,77)

@ m_x+1,m_y+2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
if lViseObr
  @ m_x+2,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"

@ m_x+5,m_y+2 SAY "Naziv raspona primanja: "  GET cNaziv
@ m_x+6,m_y+2 SAY "Formula primanja      : "  GET cFormula PICT "@S20"

@ m_x+ 8,m_y+2 SAY "             (0 - raspon se ne prikazuje)"
@ m_x+ 9,m_y+2 SAY " 1. raspon do " GET nDo1 pict "99999"
@ m_x+10,m_y+2 SAY " 2. raspon do " GET nDo2 pict "99999"
@ m_x+11,m_y+2 SAY " 3. raspon do " GET nDo3 pict "99999"
@ m_x+12,m_y+2 SAY " 4. raspon do " GET nDo4 pict "99999"
@ m_x+13,m_y+2 SAY " 5. raspon do " GET nDo5 pict "99999"
@ m_x+14,m_y+2 SAY " 6. raspon do " GET nDo6 pict "99999"
@ m_x+15,m_y+2 SAY " 7. raspon do " GET nDo7 pict "99999"
@ m_x+16,m_y+2 SAY " 8. raspon do " GET nDo8 pict "99999"
@ m_x+17,m_y+2 SAY " 9. raspon do " GET nDo9 pict "99999"
@ m_x+18,m_y+2 SAY "10. raspon do " GET nDo10 pict "99999"

@ m_x+ 9,m_y+25 SAY "11. raspon do " GET nDo11 pict "99999"
@ m_x+10,m_y+25 SAY "12. raspon do " GET nDo12 pict "99999"
@ m_x+11,m_y+25 SAY "13. raspon do " GET nDo13 pict "99999"
@ m_x+12,m_y+25 SAY "14. raspon do " GET nDo14 pict "99999"
@ m_x+13,m_y+25 SAY "15. raspon do " GET nDo15 pict "99999"
@ m_x+14,m_y+25 SAY "16. raspon do " GET nDo16 pict "99999"
@ m_x+15,m_y+25 SAY "17. raspon do " GET nDo17 pict "99999"
@ m_x+16,m_y+25 SAY "18. raspon do " GET nDo18 pict "99999"
@ m_x+17,m_y+25 SAY "19. raspon do " GET nDo19 pict "99999"
@ m_x+18,m_y+25 SAY "20. raspon do " GET nDo20 pict "99999"

read; clvbox(); ESC_BCR

BoxC()

WPar("p1",cNaziv)
WPar("p2",cFormula)
WPar("p3",nDo1)
WPar("p4",nDo2)
WPar("p5",nDo3)
WPar("p6",nDo4)
WPar("p7",nDo5)
WPar("p8",nDo6)
WPar("p9",nDo7)
WPar("r0",nDo8)
WPar("r1",nDo9)
WPar("r2",nDo10)
WPar("r3",nDo11)
WPar("r4",nDo12)
WPar("r5",nDo13)
WPar("r6",nDo14)
WPar("r7",nDo15)
WPar("r8",nDo16)
WPar("r9",nDo17)
WPar("s0",nDo18)
WPar("s1",nDo19)
WPar("s2",nDo20)

select params; use

if lViseObr
  O_TIPPRN
else
  O_TIPPR
endif

aRasponi:={ nDo1 , nDo2 , nDo3, nDo4 , nDo5 , nDo6 , nDo7 , nDo8 , nDo9 ,;
            nDo10 , nDo11 , nDo12 , nDo13 , nDo14 , nDo15 , nDo16 , nDo17 ,;
            nDo18 , nDo19 , nDo20 }

ASORT(aRasponi)

nLast:=0
// nKol:=0
nRed:=0

// aKol:={ { "" , {|| "BR.RADNIKA"  }, .f., "C", 10, 0, 1, ++nKol } }
aKol:={}

aUslRasp:={}
nSumRasp:={}

FOR i:=1 TO LEN(aRasponi)
 IF aRasponi[i]>0
   ++nRed
//   ++nKol

   AADD( nSumRasp , 0 )

//   cPomM:="nSumRasp["+ALLTRIM(STR(nKol-1))+"]"
//   AADD( aKol , { ALLTRIM(cNaziv) , {|| STR(&cPomM.,11)  }, .f., "C", 20, 0, 1, nKol } )
//   AADD( aKol , { "OD "+STR(nLast,5)+" DO "+STR(aRasponi[i],5) , {|| "#"  }, .f., "C", 20, 0, 2, nKol } )
   cPomM:="nSumRasp["+ALLTRIM(STR(nRed))+"]"

   cPom77 := "{|| 'OD "+STR(nLast,5)+" DO "+STR(aRasponi[i],5)+"' }"
   IF nRed==1
    AADD( aKol , { ALLTRIM(cNaziv) , &cPom77. , .f., "C", 40, 0, nRed , 1 } )
    AADD( aKol , { "BROJ RADNIKA"  , {|| &cPomM.   }, .f., "N", 12, 0, nRed , 2 } )
   ELSE
    AADD( aKol , { "" , &cPom77. , .f., "C", 40, 0, nRed , 1 } )
    AADD( aKol , { "" , {|| &cPomM.   }, .f., "N", 12, 0, nRed , 2 } )
   ENDIF

   AADD(aUslRasp,{nLast,aRasponi[i]})
   nLast:=aRasponi[i]
 ENDIF
NEXT

IF LEN(aKol)<2; CLOSERET; ENDIF
ASORT(aKol,,,{|x,y| 100*x[8]+x[7]<100*y[8]+y[7]})

SELECT LD

SET ORDER TO TAG (TagVO("1"))

PRIVATE cFilt1:=""
cFilt1 := "GODINA=="+cm2str(cGodina)+".and.MJESEC=="+cm2str(cMjesec)+;
		  IF(EMPTY(cIdRJ),"",".and.IDRJ=="+cm2str(cIdRJ))
cFilt1 := STRTRAN(cFilt1,".t..and.","")

IF lViseObr .and. !EMPTY(cObracun)
  cFilt1 += (".and. OBR=="+cm2str(cObracun))
ENDIF

IF cFilt1==".t."
  SET FILTER TO
ELSE
  SET FILTER TO &cFilt1
ENDIF

GO TOP

START PRINT CRET

PRIVATE cIdPartner:="", cNPartnera:="", nUkRoba:=0, nUkIznos:=0

?? space(gnLMarg)
?? Lokal("LD: Izvjestaj na dan"), date()
? space(gnLMarg); IspisFirme("")
? space(gnLMarg)
if empty(cidrj)
 ?? Lokal("Pregled za sve RJ ukupno:")
else
 ?? "RJ:", cidrj+" - "+Ocitaj(F_RJ,cIdRj,"naz")
endif
?? "  Mjesec:",str(cmjesec,2)+IspisObr()
?? "    Godina:", str(cGodina,5)

StampaTabele(aKol,{|| FSvaki2()},,gTabela,,;
     ,"Specifikacija po rasponima primanja",;
                             {|| FFor2()},IF(gOstr=="D",,-1),,,,,)

FF
END PRINT

CLOSERET


FUNCTION FFor2()
 DO WHILE !EOF()
   nPrim:=&(cFormula)
   FOR i:=1 TO LEN(aUslRasp)
//     ? aUslRasp[i,1], nPrim, aUslRasp[i,2]
     IF nPrim>aUslRasp[i,1] .and. nPrim<=aUslRasp[i,2]
       ++nSumRasp[i]
     ENDIF
   NEXT
//   ?
   SKIP 1
 ENDDO
 SKIP -1
RETURN .t.


PROCEDURE FSvaki2()
RETURN


// -------------------------------
// -------------------------------
function IspisFirme(cidrj)
local nOArr:=select()

?? "Firma: "
B_ON; ?? gNFirma; B_OFF
if !empty(cidrj)
  select rj; hseek cidrj; select(nOArr)
  ?? "  RJ",rj->naz
endif
return


// ---------------------------------
// ---------------------------------
FUNCTION SortPrez(cId)
 LOCAL cVrati:="", nArr:=SELECT()
 SELECT RADN
 HSEEK cId
 cVrati:=BHSORT(naz+ime+imerod)+id
 SELECT (nArr)
RETURN cVrati


// --------------------------------
// --------------------------------
FUNCTION SortVar(cId)
 LOCAL cVrati:="", nArr:=SELECT()
 SELECT RADKR
 SEEK cId
 SELECT RJES
 SEEK RADKR->naosnovu+RADKR->idradn
 cVrati:=varijanta
 SELECT (nArr)
RETURN cVrati



FUNCTION BHSORT(cInput)
 IF gKodnaS=="7"
   cInput:=STRTRAN(cInput,"[","S"+CHR(255))
   cInput:=STRTRAN(cInput,"\","D"+CHR(255))
   cInput:=STRTRAN(cInput,"^","C"+CHR(254))
   cInput:=STRTRAN(cInput,"]","C"+CHR(255))
   cInput:=STRTRAN(cInput,"@","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"{","s"+CHR(255))
   cInput:=STRTRAN(cInput,"|","d"+CHR(255))
   cInput:=STRTRAN(cInput,"~","c"+CHR(254))
   cInput:=STRTRAN(cInput,"}","c"+CHR(255))
   cInput:=STRTRAN(cInput,"`","z"+CHR(255))
 ELSE  // "8"
   cInput:=STRTRAN(cInput,"æ","S"+CHR(255))
   cInput:=STRTRAN(cInput,"Ñ","D"+CHR(255))
   cInput:=STRTRAN(cInput,"¬","C"+CHR(254))
   cInput:=STRTRAN(cInput,"","C"+CHR(255))
   cInput:=STRTRAN(cInput,"¦","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"ç","s"+CHR(255))
   cInput:=STRTRAN(cInput,"Ð","d"+CHR(255))
   cInput:=STRTRAN(cInput,"Ÿ","c"+CHR(254))
   cInput:=STRTRAN(cInput,"†","c"+CHR(255))
   cInput:=STRTRAN(cInput,"§","z"+CHR(255))
 ENDIF
RETURN PADR(cInput,100)


FUNCTION NLjudi()
RETURN "("+ALLTRIM(STR(opsld->ljudi))+")"


function ImaUOp( cPD, cSif )
local lVrati:=.t.
if ops->(FIELDPOS("DNE")) <> 0
	if UPPER(cPD) = "P"
		// porez
      		lVrati := ! ( cSif $ OPS->pne )
    	else                
		// doprinos
      		lVrati := ! ( cSif $ OPS->dne )
    	endif
endif
return lVrati


// ---------------------------
// ---------------------------
function PozicOps(cSR)
local nArr:=SELECT()
local cO:=""

if cSR == "1"      
	// opstina stanovanja
    	cO := radn->idopsst
elseif cSR == "2"  
	// opstina rada
	cO := radn->idopsrad

//elseif cSR=="3"  // kanton stanovanja
//  *  PushWa(); select ops; set order to tag "KAN"; seek rand->idopsst; cO:=ops->IDKAN;  PopWa()
//  *ELSEIF cSR=="4"  // kanton rada
//  *  PushWa(); select ops; set order to tag "KAN"
//  *  seek rand->idopsrad; cO:=ops->IDKAN;  PopWa()
//  *ELSEIF cSR=="5"  // entitet stanovanja
//  *  PushWa(); select ops; set order to tag "IDN0"; seek rand->idopsst; cO:=ops->idn0;  PopWa()
//  *ELSEIF cSR=="6"  // entitet rada
//  *  PushWa(); select ops; set order to tag "IDN0"; seek rand->idopsrad; cO:=ops->idn0;  PopWa()

else
	// " "
    	cO := CHR(255)
endif

select (F_OPS)

if !USED()
	O_OPS
endif

seek cO

select (nArr)
return

// ----------------------------------------
// ----------------------------------------
FUNCTION ScatterS(cG, cM, cJ, cR, cPrefix)
 private cP7:=cPrefix
  IF cPrefix==NIL
    Scatter()
  ELSE
    Scatter(cPrefix)
  ENDIF
  SKIP 1
  DO WHILE !EOF() .and. mjesec=cM .and. godina=cG .and. idradn=cR .and.;
           idrj=cJ
    IF cPrefix==NIL
      for i:=1 to cLDPolja
        cPom    := padl(alltrim(str(i)),2,"0")
        _i&cPom += i&cPom
      next
      _uneto   += uneto
      _uodbici += uodbici
      _uiznos  += uiznos
    ELSE
      for i:=1 to cLDPolja
        cPom    := padl(alltrim(str(i)),2,"0")
        &cP7.i&cPom += i&cPom
      next
      &cP7.uneto   += uneto
      &cP7.uodbici += uodbici
      &cP7.uiznos  += uiznos
    ENDIF
    SKIP 1
  ENDDO
  SKIP -1
RETURN

// -------------------------------------
// -------------------------------------
FUNCTION IspisObr()
 LOCAL cVrati:=""
 if lViseObr .and. !EMPTY(cObracun)
   cVrati:="/"+cObracun
 endif
RETURN cVrati


FUNCTION Obr2_9()
RETURN lViseObr .and. !EMPTY(cObracun) .and. cObracun<>"1"


FUNCTION TagVO(cT,cI)
  IF cI==NIL; cI:=""; ENDIF
  IF lViseObr .and. cT $ "12"
    IF cI=="I" .or. EMPTY(cObracun)
      cT := cT + "U"
    ENDIF
  ENDIF
RETURN cT



PROC SvratiUFajl()
  FERASE(PRIVPATH+"xoutf.txt")
  SET PRINTER TO (PRIVPATH+"xoutf.txt")
RETURN


FUNC U2Kolone(nViska)
 LOCAL cImeF, nURed
 IF "U" $ TYPE("cLMSK"); cLMSK:=""; ENDIF
 nSirKol:=80+LEN(cLMSK)
 cImeF:=PRIVPATH+"xoutf.txt"
 nURed:=BrLinFajla(cImeF)
 aR    := DioFajlaUNiz(cImeF,1,nURed-nViska,nURed)
 aRPom := DioFajlaUNiz(cImeF,nURed-nViska+1,nViska,nURed)
 aR[1] = PADR(aR[1],nSirKol) + aR[1]
 aR[2] = PADR(aR[2],nSirKol) + aR[2]
 aR[3] = PADR(aR[3],nSirKol) + aR[3]
 aR[4] = PADR(aR[4],nSirKol) + aR[4]
 FOR i:=1 TO LEN(aRPom)
   aR[i+4] = PADR(aR[i+4],nSirKol) + aRPom[i]
 NEXT
RETURN aR


function SetRadnGodObr()
*{


return
*}


