#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdrtf1.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.9 $
 * $Log: stdrtf1.prg,v $
 * Revision 1.9  2003/03/26 14:54:52  mirsad
 * umjesto "Reg.br." i "Por.br." svuda stavljen ispis "Ident.br."
 *
 * Revision 1.8  2003/03/16 10:07:16  ernad
 * rtf fakture
 *
 * Revision 1.7  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.6  2002/09/16 08:57:04  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.5  2002/07/05 13:02:33  mirsad
 * no message
 *
 * Revision 1.4  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.3  2002/06/21 12:51:22  sasa
 * no message
 *
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 
/*! \file fmk/fakt/dok/1g/stdrtf1.prg
 *  \brief Stampa faktura u RTF formatu varijanta 1
 */


/*! \ingroup ini
  * \var *string FmkIni_KumPath_RTF_PartnerFS
  * \brief Velicina fonta za ispis partnera u rtf-fakturi
  * \param 28 - default vrijednost
  */
*string FmkIni_KumPath_RTF_PartnerFS;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_RTF_PartnerSB
  * \brief Format necega?! Nisam mogao testirati jer nemam instaliran MS Word!
  * \param 90 - default vrijednost
  */
*string FmkIni_KumPath_RTF_PartnerSB;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_RegBrPorBr
  * \brief Da li se ispisuju registarski i poreski broj na fakturi
  * \param D - da, default vrijednost
  * \param N - ne 
  */
*string FmkIni_KumPath_FAKT_RegBrPorBr;


/*! \fn StdRtf1()
 *  \brief Stampa fakture u RTF formatu
 *  \param cImeF
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */

function StdRtf1()
*{
parameters cImeF,cIdFirma,cIdTipDok,cBrDok
local cTxt1,cTxt2,aMemo,nH, coutf:=""
local i,ii,ImeKol:={}, nRedova, fPrvaStr
local cTi,nRab,nUk2:=nRab2:=0
private nStr, nUk:=0, nZaokr

// rtf2
#define CO1 8
#define CO2 16
#define CO3 45
#define CO4 23  
// co3+co4  == sirina naziva
#define CO5 20

// JMJ
#define CO6 10       
#define CO7 14
#define CO8 10.5
#define CO9 10.5
#define COA 18



nRedova:=27  // dodatnih redova na drugoj stani
fPrvaStr:=.t.

if (nH:=fcreate(cImeF))==-1
  Beep(4)
  Msg("Fajl "+cimeF+" se vec koristi !",6)
  return
endif
fclose(nH)

if cIdFirma<>NIL
 O_Edit(.t.)
else
 O_Edit()
endif

cTI:="1"  // tip izvjestaja  1,2
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("c1",@cTI)
select params; use




select PRIPR
if cidfirma=NIL  // poziva se faktura iz pripreme
 IF gNovine=="D"
   FilterPrNovine()
 ENDIF
 cIdTipdok:=idtipdok;cIdFirma:=IdFirma;cBrDok:=BrDok
endif
SEEK cidfirma+cidtipdok+cBrdok
NFOUND CRET


MsgO("Priprema rtf fajla")

cTxt1:=cTxt2:=cTxt3a:=cTxt3b:=cTxt3c:=""

if val(podbr)=0  .and. val(rbr)==1
   aMemo:=ParsMemo(txt)
   if len(aMemo)>0
     cTxt1:=padr(aMemo[1],40)
   endif
   cTxt2:=aMemo[2]
   cTxt3a:=aMemo[3]
   cTxt3b:=aMemo[4]
   cTxt3c:=aMemo[5]
   cTxt2:=ToRtfstr( strtran(ctxt2,""+Chr(10),"") )
else
  Beep(2)
  MsgC()
  Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  return
endif

InitFW()

nTxt2:=len(WWSjeciStr(cTxt2,10,171))


set printer to (cImeF)
set printer on
set console off

WWInit0()
WWFontTbl()
WWStyleTbl()
WWInit1()
WWSetMarg(20,95,15,20)
WWSetPage("A4","P")

cDodatak := RegIPorBr()
cnFS     := IzFMKIni("RTF","PartnerFS","28",KUMPATH)
cnSB     := IzFMKIni("RTF","PartnerSB","90",KUMPATH)

WWTBox(20,54,80,35,"\f2\b\fs"+cnFS+"\qc\sb"+cnSB+"\sa0\sl400 "+;
       ToRtfstr(cTxt3a)+iif(!empty(cTxt3b),"\line "+ToRtfstr(cTxt3b),"")+"\line "+ToRtfstr(cTxt3c)+cDodatak,;
       "0",{0,0,0}, 0,;   // line type, line color, line width
           {0,0,0},;  //  fill foreground
           {0,0,0},"0")     // fill background, fill pattern


WWTBox(109.4,57,85,8,"\f2\fs22\qr "+Mjesto(cIdFirma)+", "+;
       ToRtfstr(dtoc(datdok)+" godine"),;
       "0",{0,0,0}, 0,;   // line type, line color, line width
           {0,0,0},;  //  fill foreground
           {0,0,0},"0")     // fill background, fill pattern


cStr:=idtipdok+" "+brdok
cIdTipDok:=IdTipDok
private cpom:=""
if !(cIdTipDok $ "00#01#19")
 cPom:="G"+cidtipdok+"STR"
 cStr:=&cPom+" "+trim(BrDok)
endif

if gImeF=="D"    // svaki izlazni fajl ima svoje ime
 cOutf:=PRIVPATH+alltrim(idtipdok)+"-"+strtran(alltrim(brdok),"/","-")+".rtf"
endif

WWTBox(109.4,78,85,10,"\f2\b\fs28\qr "+;
       ToRtfstr(cStr),;
       "0",{0,0,0}, 0,;   // line type, line color, line width
           {0,0,0},;  //  fill foreground
           {0,0,0},"0")     // fill background, fill pattern


?? "\par "
Zagl1()  // zaglavlje tabele

nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
PPrazna:=.t.
cDinDem:=dindem

nWWPos:=1

bRDefDet:={|| WWRowDef({ {CO1,{"l","s",0.1},{"r","s",0.1}   } , ;
           {CO2,{"l","s",0.1},{"r","s",0.1}  } , ;
           {CO3+CO4,{"l","s",0.1},{"r","s",0.1}  }, ;
           {CO5,{"l","s",0.1},{"r","s",0.1}  }, ;
           {CO6,{"l","s",0.1},{"r","s",0.1}   }, ;
           {CO7,{"l","s",0.1},{"r","s",0.1}  }, ;
           {CO8,{"l","s",0.1},{"r","s",0.1}   }, ;
           {CO9,{"l","s",0.1},{"r","s",0.1}  }, ;
           {COA,{"l","s",0.1},{"r","s",0.1}  } ;
          }) }

nStr:=1
do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()


   Eval(bRDefDet)

   NSRNPIdRoba()

   if alltrim(podbr)=="."
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif


  if alltrim(podbr)=="." // zaglavlje
    cRNaz:="{\b "+ToRtfstr(cTxt1)+"}"
    nRez:=len(WWSjeciStr(cRNaz,10,CO3+CO4-1))
    nWWPos+=nRez

    if cTI=="1"
      if nWWPos+nTxt2 > nRedova  // preci na drugu stranu
        nWWPos:=1; NStr(fPrvaStr)
        if fPrvaStr; fPrvaStr:=.f.; nRedova+=11; endif
      endif // nWWPos
       ?? "\ql\sb30\sa20\f2\fs20 "+alltrim(Rbr())+"\cell"
       WWCellS({" ",cRNaz,"\ri"+ToP(1)+"\qr "+alltrim(str(kolicina,12,0)),"\ri0 "," "," "," "})
    else
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       nPorez:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok.and. Rbr==cRbr
        if podbr=" ."
          skip; loop
        endif
        nUk2+=round(kolicina*cijena , nZaokr)
        nRab2+=round(kolicina*cijena*rabat/100 , nZaokr)
        nPor2+=round(kolicina*cijena*(1-rabat/100)*Porez/100 , nZaokr)
        skip
       enddo
       nPorez:=nPor2/(nUk2-nRab2)*100
       go nRec

       if nRab2*100/nUk2-int(nRab2*100/nUk2) <> 0
          cRab:=str(nRab2*100/nUk2,4,1)
       else
         cRab:=str(nRab2*100/nUk2,2,0)
       endif

        nWWPos+=iif(nPor2<>0,1,0)
        ?? "\ql\sb30\sa20\f2\fs20 "+alltrim(Rbr())+"\cell"
        if nWWPos+nTxt2 > nRedova  // preci na drugu stranu
          nWWPos:=1; NStr(fPrvaStr)
          if fPrvaStr; fPrvaStr:=.f.; nRedova+=11; endif
        endif // nWWPos
        WWCellS({" ",cRNaz,"\ri"+ToP(1)+"\qr "+alltrim(str(kolicina,12,0)),"\ri0 ",;
            "\qr "+alltrim(str(iif(kolicina==0,0,nUk2/kolicina),12,nZaokr)),;
            cRab+"%",;
            "\qr{\b "+alltrim(str(nUk2,12,nZaokr))+"}" ;
            })
        if nPor2<>0
         WWCellS({" "," ","Porez "+str(nPorez,2,0)+"%"," "," ",;
              " "," ",;
             "\qr{\b "+alltrim(str(nPor2,12,nZaokr))+"}" ;
            })
        endif
    endif //

  else // podbr nije "."
    NSRNPIdRoba()
    if empty(podbr)
      cRNaza:="{\b "+ToRtfstr(trim(ROBA->naz))+"}"
    else
      cRNaza:=ToRtfstr(trim(ROBA->naz))
    endif
    cRnazb:=iif(empty(serbr),"", " "+ToRtfstr("(s.b. "+trim(serbr)+")" ) )
    nRez1:=len(WWSjeciStr(cRnaz1:=(cRNaza+cRnazb),10,CO3+CO4-1))
    if nRez1==1
      cRNaz:=cRnaz1
      nWWPos+=nRez1
    else
     nRez2:=len(WWSjeciStr(cRNaz2:=(cRNaza+"\line"+cRnazb),10,CO3+CO4-1))
     if nRez2>nRez1
       cRnaz:=cRnaz1
       nWWPos+=nRez1
     else
       cRnaz:=cRnaz2
       nWWPos+=nRez2
     endif
    endif


    if rabat-int(rabat) <> 0
      cRab:=str(rabat,4,1)
    else
      cRab:=str(rabat,2,0)
    endif

    nPor2:=cijena*kolicina*(1-Rabat/100)*porez/100
    nWWPos+=iif(nPor2<>0,1,0)
    if nWWPos+nTxt2 > nRedova  // preci na drugu stranu
          nWWPos:=1; NStr(fPrvaStr)
          if fPrvaStr; fPrvaStr:=.f.; nRedova+=11; endif
    endif // nWWPos
    ?? "\ql\sb30\sa20\f2\fs20 "+alltrim(Rbr())+"\cell"
    WWCellS({;
            "\ql \fs18 "+idroba,;
            cRNaz,;
            "\ri"+ToP(1)+"\qr "+alltrim(str(kolicina,12,0)),;
            "\ri0\ql "+ToRtfstr(lower(ROBA->jmj)),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),"\qr "+alltrim(str(cijena,12,nZaokr))," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),cRab+"%"," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),"\qr{\b "+alltrim(str(cijena*kolicina,12,nZaokr))+"}"," ") ;
            })

    if nPor2<>0  .and.  (empty(podbr) .or. (!empty(podbr) .and. cTI=="1"))
         WWCellS({" "," ","Porez "+str(Porez)+"%"," "," ",;
              " "," ",;
             "\qr{\b "+alltrim(str(nPor2,12,nZaokr))+"}" ;
            })
    endif
    nUk+=round(cijena*kolicina+nPor2 , nZaokr)
    nRab+=round(cijena*kolicina*rabat/100 , nZaokr)
  endif
 skip


enddo


WWRowDef({ {CO1+CO2+CO3+CO4+CO5+CO6+CO7+CO8+CO9+COA,{"l","s",0.1},{"t","s",0.4},{"r","s",0.1},{"b","s",0.1} } ;
         })

WWCells({ "\tqr\tx"+ToP(156.8)+"\tqr\tx"+ToP(174.3)+;
         "\tab Ukupno:\tab {\b "+;
         alltrim(str(nUk,12,nZaokr))+;
        "}\line\tab Rabat:\tab {\b "+;
         alltrim(str(nRab,12,nZaokr))+;
        "}";
       })

WWRowDef({ {CO1+CO2+CO3+CO4+CO5+CO6+CO7+CO8+CO9+COA,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4} } ;
         })
WWCells({ "\tqr\tx"+ToP(156.8)+"\tqr\tx"+ToP(174.3)+;
         "\tab {\b U K U P N O:\tab "+;
         alltrim(str(nUk-nRab,12,nZaokr))+;
        "}\line "+iif(empty(picdem),"","slovima:"+;
         ToRtfstr(Slovima(round(nUk-nRab,nZaokr),cDinDem)));
       })

?? "\pard"   // zavrsetak tabele

? "\par"
? cTxt2
if cidtipdok=="10"

 WWTBox(20,264,175.6,5,"\f2\fs20\tqc\tx"+ToP(25)+" \tqc\tx"+ToP(90)+" \tqc\tx"+ToP(150)+;
       " {\i \tab Predao\tab Odobrava\tab Preuzeo:}",;
       "0",{0,0,0}, 0,;   // line type, line color, line width
           {0,0,0},;  //  fill foreground
           {0,0,0},"0")     // fill background, fill pattern

elseif cidtipdok$"20#27"
WWTBox(20,264,175.6,5,"\f2\fs20\tqc\tx"+ToP(25)+" \tqc\tx"+ToP(90)+" \tqc\tx"+ToP(140)+;
       " {\i \tab \tab \tab Direktor}",;
       "0",{0,0,0}, 0,;   // line type, line color, line width
           {0,0,0},;  //  fill foreground
           {0,0,0},"0")     // fill background, fill pattern
endif

WWEnd()

set printer to
set printer off
set console on

MsgC()
Beep(2)

Box(,4,65,.t.)
set cursor off
@ m_x+1,m_y+2 SAY "Faktura je pripremljena za stampu."
@ m_x+3,m_y+2 SAY "Formiran je fajl: "+cImeF
if gImeF=="D"
  cKomLin:="copy "+cimef+" "+coutf
  run &cKomLin
  @ m_x+4,m_y+2 SAY "Takodje je formiran: "+cOutF
endif

if empty(gKomLin)
  inkeySc(0)
else
  save screen to cScr
  run &gKomLin
  restore screen from cScr
endif
BoxC()
*}


/*! \fn Zagl1()
 *  \brief Stampa zaglavlja
 */
 
function Zagl1()
*{
WWRowDef({ {CO1,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} } , ;
           {CO2,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} } , ;
           {CO3+CO4,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} }, ;
           {CO5,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} }, ;
           {CO6,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} }, ;
           {CO7,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} }, ;
           {CO8,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} }, ;
           {CO9,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} }, ;
           {COA,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4},{"t","s",0.4} } ;
         })
WWCellS({"\f2\fs18\qc\sb30\sa20 Rbr","\fs22 Sifra","Naziv robe","Kol.","jmj","Cijena","\fs20 Rab", "Por", "Ukupno"})
return
*}


/*! \fn NStr(fPrvaStr)
 *  \brief Prelazak na novu stranu
 *  \param fPrvaStrana
 */
 
function NStr(fPrvaStr)
*{
WWRowDef({ {CO1+CO2+CO3+CO4+CO5+CO6+CO7+CO8+CO9+COA,{"l","s",0.1},{"t","s",0.4},{"r","s",0.1},{"b","s",0.1} } ;
            })
WWCells({ "\tqr\tx"+ToP(156.8)+"\tqr\tx"+ToP(174.3)+;
            "\tab Ukupno na strani "+alltrim(str(nStr,3))+":\tab {\b "+;
            alltrim(str(nUk,12,nZaokr))+;
           "}";
          })

?? "\pard "   // zavrsetak tabele
if fprvastr
   ? "\sect\sectd"
   WWSetMarg(20,20,15,20)
   WWSetPage("A4","P")
else
   ? "\page\par"
endif
Zagl1()
Eval(bRDefDet)  // detail linija definicija reda
WWCells({" "," ","\ql {\b Prenos sa strane "+alltrim(str(nStr++,3))+".}",;
          " "," "," "," ", " ", ;
        "\qr {\b "+alltrim(str(nUk,12,nZaokr))+"}";
       })
return
*}



/*! \fn RegIPorBr()
 *  \brief Registarski i poreski broj
 */
 
function RegIPorBr()
*{
LOCAL cDodatak:="", cRegBr, cPorBr
  IF IzFMkIni('FAKT',"RegBrPorBr",'D',KUMPATH)=="D"
    cRegBr := IzSifK( "PARTN" , "REGB" , idpartner , .f. )
    cPorBr := IzSifK( "PARTN" , "PORB" , idpartner , .f. )
    IF !EMPTY(cRegBr)
      cDodatak += ( "\line " + ToRtfStr("Ident.br:"+cRegBr) )
    ENDIF
    IF !EMPTY(cPorBr)
      cDodatak += ( "\line " + ToRtfStr("Ident.br:"+cPorBr) )
    ENDIF
  ENDIF
return cDodatak
*}



