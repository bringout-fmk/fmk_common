#include "ld.ch"

function RekNeto(cVarijanta)
*{
local aLeg:={}
local aPom:={,,}
local cVarSort:="2"

IF cVarijanta==NIL; cVarijanta:="1"; ENDIF

 IF cVarijanta=="3"
  gnLMarg:=0; gTabela:=0; gOstr:="D"; cPKU:="N"; cPKPN:="N"
 ELSE
  gnLMarg:=0; gTabela:=0; gOstr:="D"; cOdvLin:="D"; cPKU:="N"; cPKPN:="N"
 ENDIF
 cPKZI:="N"

IF cVarijanta!="3"

 cIdRj:=gRj; cmjesec:=gMjesec
 cGodina:=gGodina; cPrimR1:=cPrimR2:=cPrimR3:=SPACE(60)
 cObracun:=gObracun

  cPrimR1:=PADR("01;",60)

 O_RADKR
 O_KBENEF
 O_VPOSLA
 O_RJ
 O_RADN

  O_LD

 O_PARAMS
 Private cSection:="4",cHistory:=" ",aHistory:={}
  RPar("t1",@cPrimR1)
  RPar("t2",@cPrimR2)
  RPar("t3",@cPrimR3)
 RPar("t4",@gOstr)
 RPar("t5",@cOdvLin)
 RPar("t6",@gTabela)
 RPar("t7",@cPKU)
 RPar("t8",@cPKPN)
 RPar("VS",@cVarSort)


 Box(,13,75)
 @ m_x+ 1,m_y+2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
 @ m_x+ 2,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
 if lViseObr
   @ m_x+ 2,col()+2 SAY "Obracun: "  GET  cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
 endif
 @ m_x+ 3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
  @ m_x+ 4,m_y+2 SAY "Navedi 1.red primanja: (npr.01;02;)"  GET cPrimR1 pict "@S40"
  @ m_x+ 5,m_y+2 SAY "Navedi 2.red primanja: (npr.01;02;)"  GET cPrimR2 pict "@S40"
  @ m_x+ 6,m_y+2 SAY "Navedi 3.red primanja: (npr.01;02;)"  GET cPrimR3 pict "@S40"
 @ m_x+ 7,m_y+2 SAY "Nacin crtanja tabele     (0/1/2)   "  GET gTabela VALID gTabela>=0.and.gTabela<=2 pict "9"
 @ m_x+ 8,m_y+2 SAY "Ukljuceno ostranicavanje (D/N) ?   "  GET gOstr   VALID gOstr$"DN"    pict "@!"
 @ m_x+ 9,m_y+2 SAY "Odvajati podatke linijom (D/N) ?   "  GET cOdvLin VALID cOdvLin$"DN"  pict "@!"
 @ m_x+10,m_y+2 SAY "Prikazati kolonu 'UKUPNO'(D/N) ?   "  GET cPKU    VALID cPKU$"DN"  pict "@!"
 @ m_x+11,m_y+2 SAY "Prikazati kolone 'Uk.neto','Uk.sati' i 'Uk.neto/Uk.sati'? (D/N)"  GET cPKPN  VALID cPKPN$"DN"  pict "@!"
 @ m_x+12,m_y+2 SAY "Prikazati kolonu 'Za isplatu'? (D/N)"  GET cPKZI  VALID cPKZI$"DN"  pict "@!"
 @ m_x+13,m_y+2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort$"12"  pict "9"
 read; clvbox(); ESC_BCR
 BoxC()

  WPar("t1",cPrimR1)
  WPar("t2",cPrimR2)
  WPar("t3",cPrimR3)
 WPar("t4",gOstr)
 WPar("t5",cOdvLin)
 WPar("t6",gTabela)
 WPar("t7",cPKU)
 WPar("t8",cPKPN)
 WPar("VS",cVarSort)
 SELECT PARAMS; USE

ENDIF

if lViseObr
 O_TIPPRN
else
 O_TIPPR
endif

SELECT LD

IF cVarijanta!="3"

 Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  IF cVarSort=="1"
    cSort1:="IDRADN"
  ELSE
    cSort1:="SortPrez(IDRADN)"
  ENDIF
  cFilt := IF(EMPTY(cIdRj),".t.","IDRJ==cIdRj")+".and."+;
           IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
           IF(EMPTY(cGodina),".t.","GODINA==cGodina")
  if lViseObr .and. !EMPTY(cObracun)
    cFilt += ".and. OBR==cObracun"
  endif
  INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
 BoxC()

 EOF CRET
 GO TOP
// ELSE
//  SET ORDER TO TAG (TagVO("1"))
ENDIF


aKol:={}; nKol:=0

  AADD( aKol , { "SIFRA"     , {|| cIdRadn}, .f., "C",  6, 0, 1, ++nKol} )

AADD( aKol , { "PREZIME I IME RADNIKA", {|| cNaziv }, .f., "C", 27, 0, 1, ++nKol} )

lEPR1:=EMPTY(cPrimR1); lEPR2:=EMPTY(cPrimR2); lEPR3:=EMPTY(cPrimR3)

DO WHILE !( EMPTY(cPrimR1) .and. EMPTY(cPrimR2) .and. EMPTY(cPrimR3) )

  ++nKol; aPom:={"","",""}

  IF !lEPR1
    nPoz1:=AT(";",cPrimR1)
    IF nPoz1>0
      cSifPr:=LEFT(cPrimR1,nPoz1-1)
      cPrimR1:=SUBSTR(cPrimR1,nPoz1+1)
      cVarPr:="SI"+ALLTRIM(STR(VAL(cSifPr)))
      &cVarPr:=0
      cBlk:="{|| "+cVarPr+"}"
    ELSEIF EMPTY(cPrimR1)
      cSifPr:=""
      cBlk:="{|| 0}"
    ELSE
      cSifPr:=TRIM(cPrimR1)
      cPrimR1:=""
      cVarPr:="SI"+ALLTRIM(STR(VAL(cSifPr)))
      &cVarPr:=0
      cBlk:="{|| "+cVarPr+"}"
    ENDIF
    AADD( aKol , { cSifPr , &cBlk. , .t. , "N-" ,  9 , 2 , 1 , nKol } )
    aPom[1]:=cSifPr
  ENDIF

  IF !lEPR2
    nPoz2:=AT(";",cPrimR2)
    IF nPoz2>0
      cSifPr:=LEFT(cPrimR2,nPoz2-1)
      cPrimR2:=SUBSTR(cPrimR2,nPoz2+1)
      cVarPr:="SI"+ALLTRIM(STR(VAL(cSifPr)))
      &cVarPr:=0
      cBlk:="{|| "+cVarPr+"}"
    ELSEIF EMPTY(cPrimR2)
      cSifPr:=""
      cBlk:="{|| 0}"
    ELSE
      cSifPr:=TRIM(cPrimR2)
      cPrimR2:=""
      cVarPr:="SI"+ALLTRIM(STR(VAL(cSifPr)))
      &cVarPr:=0
      cBlk:="{|| "+cVarPr+"}"
    ENDIF
    AADD( aKol , { cSifPr , &cBlk. , .t. , "N-" ,  9 , 2 , 2 , nKol } )
    aPom[2]:=cSifPr
  ENDIF

  IF !lEPR3
    nPoz3:=AT(";",cPrimR3)
    IF nPoz3>0
      cSifPr:=LEFT(cPrimR3,nPoz3-1)
      cPrimR3:=SUBSTR(cPrimR3,nPoz3+1)
      cVarPr:="SI"+ALLTRIM(STR(VAL(cSifPr)))
      &cVarPr:=0
      cBlk:="{|| "+cVarPr+"}"
    ELSEIF EMPTY(cPrimR3)
      cSifPr:=""
      cBlk:="{|| 0}"
    ELSE
      cSifPr:=TRIM(cPrimR3)
      cPrimR3:=""
      cVarPr:="SI"+ALLTRIM(STR(VAL(cSifPr)))
      &cVarPr:=0
      cBlk:="{|| "+cVarPr+"}"
    ENDIF
    AADD( aKol , { cSifPr , &cBlk. , .t. , "N-" ,  9 , 2 , 3 , nKol } )
    aPom[3]:=cSifPr
  ENDIF

  AADD(aLeg,aPom)

ENDDO

siu:=0
IF cVarijanta=="3"
  IF LEN(aPrim)>1
    AADD( aKol , { "UKUPNO" , {|| siu } , .t. , "N-" ,  9 , 2 , IF(!lEPR3,3,IF(!lEPR2,2,1)) , ++nKol } )
  ENDIF
ELSEIF cPKU=="D"
    AADD( aKol , { "UKUPNO" , {|| siu } , .t. , "N-" ,  9 , 2 , IF(!lEPR3,3,IF(!lEPR2,2,1)) , ++nKol } )
ENDIF


IF cPKPN=="D"
    ssn:=0; sin:=0
    AADD( aKol , { "UK.NETO"  , {|| sin } , .t. , "N-" ,  9 , 2 , IF(!lEPR3,3,IF(!lEPR2,2,1)) , ++nKol } )
    AADD( aKol , { "UK.SATI"  , {|| ssn } , .t. , "N-" ,  9 , 2 , IF(!lEPR3,3,IF(!lEPR2,2,1)) , ++nKol } )
    AADD( aKol , { "NETO/SATI", {|| IF(ssn==0,0,sin/ssn) } , .f. , "N-" ,  9 , 2 , IF(!lEPR3,3,IF(!lEPR2,2,1)) , ++nKol } )
ENDIF

IF cPKZI=="D"
    siz:=0
    AADD( aKol , { "ZA ISPLATU"  , {|| siz } , .t. , "N-" , 10 , 2 , IF(!lEPR3,3,IF(!lEPR2,2,1)) , ++nKol } )
ENDIF

FOR i:=1 TO 100
  IF FIELDPOS("I"+RIGHT("00"+ALLTRIM(STR(i)),2))==0; nPoljaPr:=i-1; EXIT; ENDIF
  nPoljaPr:=i
NEXT

PRIVATE cIdRadn:="", cNaziv:=""

IF cVarijanta!="3"
 START PRINT CRET
 ?? space(gnLMarg); ?? Lokal("LD: Izvjestaj na dan"),date()
 ? space(gnLMarg); IspisFirme("")
 ?
 if empty(cidrj)
  ? Lokal("Pregled za sve RJ ukupno:")
 else
  ? Lokal("RJ:"), cidrj+" - "+Ocitaj(F_RJ,cIdRj,"naz")
 endif
 ?? SPACE(2) + Lokal("Mjesec:"),IF(EMPTY(cMjesec),"SVI",str(cmjesec,2))+IspisObr()
 ?? SPACE(4) + Lokal("Godina:"), IF(EMPTY(cGodina),"SVE",str(cGodina,5))
 ?
ENDIF

StampaTabele(aKol,{|| FSvaki4()},,gTabela,,;
     ,"Rekapitulacija neto primanja",;
                             {|| FFor4()},IF(gOstr=="D",,-1),,cOdvLin=="D",,,)

?

? Lokal("LEGENDA:")
? Lokal("U kolonama tabele nalaze se sljedece sifre tipova primanja:")
FOR j:=1 TO 3
  FOR i:=1 TO LEN(aLeg)
    IF !EMPTY(aLeg[i,j])
      ? aLeg[i,j],"-",Ocitaj(SELECT("TIPPR"),aLeg[i,j],"naz")
    ENDIF
  NEXT
NEXT

IF cVarijanta!="3"
 FF
 END PRINT
 CLOSERET
ELSE
 RETURN
ENDIF





FUNCTION FFor4()
 cIdRadn:=IDRADN
 cNaziv:=Ocitaj(F_RADN,cIdRadn,"TRIM(NAZ)+' '+TRIM(IME)")
 FOR i:=1 TO nPoljaPr
   cPom77:="SI"+ALLTRIM(STR(i))
   IF TYPE(cPom77)=="N"; &cPom77:=0; ENDIF
 NEXT
 siu:=0; ssn:=0; sin:=0; siz:=0
 DO WHILE !EOF() .and. IDRADN==cIdRadn
   FOR i:=1 TO nPoljaPr
     cPom77:="SI"+ALLTRIM(STR(i))
     cPom77I:="I"+RIGHT("00"+ALLTRIM(STR(i)),2)
     IF TYPE(cPom77)=="N"
       &cPom77 := &cPom77 + &cPom77I
       siu := siu + &cPom77I
     ENDIF
   NEXT
   IF cPKPN=="D"
     if !(lViseObr .and. obr<>"1")
       ssn += usati
     endif
     sin += uneto
   ENDIF
   IF cPKZI=="D"
     siz += uiznos
   ENDIF
   SKIP 1
 ENDDO
 SKIP -1
RETURN .t.



FUNCTION FFor43()
 LOCAL nUNeto,nBo,nPom,nPor,nPorOps,nDopr
 cIdRadn:=IDRADN
 SELECT RADN; HSEEK cidradn
 SELECT VPOSLA; HSEEK LD->idvposla
 SELECT KBENEF; HSEEK vposla->idkbenef
 SELECT LD
 if !empty(cvposla) .and. cvposla<>left(idvposla,2) .or.;
    !empty(ckbenef) .and. ckbenef<>kbenef->id
   return .f.
 endif
 cNaziv:=Ocitaj(F_RADN,cIdRadn,"TRIM(NAZ)+' '+TRIM(IME)")
 FOR i:=1 TO nPoljaPr
   cPom77:="SI"+ALLTRIM(STR(i))
   IF TYPE(cPom77)=="N"; &cPom77:=0; ENDIF
 NEXT
 siu:=0; ssn:=0; sin:=0
 DO WHILE !EOF() .and. IDRADN==cIdRadn
   FOR i:=1 TO nPoljaPr
     cPom77:="SI"+ALLTRIM(STR(i))
     cPom77I:="I"+RIGHT("00"+ALLTRIM(STR(i)),2)
     IF TYPE(cPom77)=="N"
       &cPom77 := &cPom77 + &cPom77I
       siu := siu + &cPom77I
     ENDIF
   NEXT
   IF cPKPN=="D"
     ssn += usati
     sin += uneto
   ENDIF
   SKIP 1
 ENDDO

 nUNeto:=siu
 nBo:=round2(parobr->k3/100*MAX(nUNeto,PAROBR->prosld*gPDLimit/100),gZaok2)
 SELECT POR; GO TOP
 nPom:=nPor:=nPorOps:=0
 do while !eof()
   nPom:=max(dlimit,iznos/100*MAX(nUNeto,PAROBR->prosld*gPDLimit/100))
   nPor+=nPom
   skip 1
 enddo

 SELECT DOPR; GO TOP
 nPom:=nDopr:=0
 do while !eof()
   nPom:=max(dlimit,iznos/100*nBO)
   if right(id,1)=="X"
    nDopr+=nPom
   endif
   skip 1
 enddo

 nTPor  += nPor
 nTDopr += nDopr
 nT1    += siu

 SELECT LD

 SKIP -1
 ++nRBr
RETURN IF(siu<>0,.t.,.f.)



PROCEDURE FSvaki4()
RETURN

