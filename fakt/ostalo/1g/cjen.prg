/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/ostalo/1g/cjen.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: cjen.prg,v $
 * Revision 1.2  2002/06/18 13:23:38  sasa
 * no message
 *
 *
 */
 

/*! \file fmk/fakt/ostalo/1g/cjen.prg
 *  \brief Modul CJEN
 */


public gModul:="CJEN"

#ifdef  C52
#include "ini0c52.ch"
#else
#include "ini0.ch"
#endif

//EXTERNAL BTOE

PUBLIC cVer:='01.03'

#ifdef CAX
 PUBLIC cNaslov:="CJEN, 10.95-03.99 AX"
#else
 PUBLIC cNaslov:="CJEN, 10.95-03.99 CDX"
#endif

#include "inibz.ch"
private Izbor:=1

#define NL  chr(13)+chr(10)

SetHF("")

ToggleIns()

SETKEY(K_SH_F1,{|| Calc()})


public gNivoa:=3   // broj nivoa kategorija
public gNivo1:=1
public gNivo2:=2
public gNivo3:=1
public gNivo4:=0
public gNivo5:=0
O_PARAMS
private cSection:="C",cHistory:=" "; aHistory:={}
RPar("n0",@gNivoa)
RPar("n1",@gNivo1)
RPar("n2",@gNivo2)
RPar("n3",@gNivo3)
RPar("n4",@gNivo4)
RPar("n5",@gNivo5)

public gKomlin:=""
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("95",@gKomLin)       // prvenstveno za win 95

select params; use
release cSection,cHistory,aHistory

#IFDEF TRIAL
O_ROBA
select roba
if reccount2()>100
 Beep(4)
 PUBLIC  Normal:="GR+/B,R/N+,,,N/W"
 Box(,6,60)
 @ m_x+1,m_y+2 SAY "Potrebno je registrovati kopiju od strane"
 @ m_x+2,m_y+2 SAY "ovlastenog distributera SIGMA-COM software-a"
 @ m_x+4,m_y+2 SAY "Podaci koje ste unosili NISU izgubljeni !"
 @ m_x+5,m_y+2 SAY "Nakon instalacije registrovane verzije mozete"
 @ m_x+6,m_y+2 SAY "nastaviti sa radom."
 inkey(0)
 Boxc()
 PUBLIC  Normal:="W/B,R/N+,,,N/W"
 quite()
endif
select roba
use
#ENDIF

@ 4,5 SAY ""
private opc[2]
Opc[1]:="1. stampa cjenovnika      "
Opc[2]:="2. parametri"

do while .t.

 h[1]:=""
 h[2]:="..."
 h[3]:=""

Izbor:=menu("osn",opc,Izbor,.f.)

   do case
     case Izbor==0
      if Pitanje("",'Zelite izaci iz programa ?','N')='D'
       EXIT
      else
       Izbor:=1
       @ 4,5 SAY ""
       LOOP
      endif
     case izbor == 1
         Stampa()
     case izbor == 2
         Pars()
   endcase

enddo


quite()
return

********************
********************
function Stampa()


local cImeF:=PRIVPATH+"cjen.rtf"

cS1:="\s1\sb240\sa60\keepn\box\brdrsh\brdrs\brdrw45\brsp20 \b\f2\fs28\lang2057\kerning28"
cS2:="\s2\li284\sb160\sa40"+iif(gNivoa>=2,"\keepn","")+"\box\brdrsh\brdrs\brdrw15 \b\f2"
cS3:="\s3\li567\sb80\sa40"+iif(gNivoa>=3,"\keepn","")+" \b\i\f2"
cS9:="\s4\li851\sb20\tqr\tldot\tx8200\tqr\tldot\tx10000 \f2\fs22"

O_FAKT; set order to 3 // idroba
O_ROBA


qqRoba:=space(100)

qqRoba:=space(100)
qqVPC:=space(60)
Box("",15,68)
cPSort:="N"
private nSLimit:=0
private cSort:=padr("left(id,3)+btoe(naz)",40)
private cTipVPC:="1",nMPosto:=0
private cStanje:="N",cIdFirma:="10"
do while .t.
 @ m_x+1,m_y+2 SAY "Roba "  GET qqRoba   pict "@!S40"
 @ m_x+2,m_y+2 SAY "VPC  "  GET qqVPC    pict "@!S40"
 @ m_x+3,m_y+2 SAY "Proizvoljno sortiranje D/N" GET cPSort valid cPSort $ "DN" pict "@!"
 @ m_x+4,m_y+2 SAY "VPC ( 1-VPC / 2-VPC2 / 3-VPC+x% / 4-VPC2+x% / 5-NC+x% / 6-MPC ) ?" GET cTipVPC valid cTIPVPC $ "123456"
 @ m_x+5,m_y+2 SAY "Prikazati stanje iz FAKT D/N ?" GET cStanje valid cStanje $ "DN" pict "@!"
 read
 if cStanje=="D"
   @ m_x+6,m_y+2 SAY "Firma:" GET cIdFirma
   @ m_x+7,m_y+2 SAY "Prikazati robu sa stanjem vecim od " GET nSLimit pict "999999.99"
   read
 endif
 if cTipVPC$"345"
   @ m_x+6,m_y+2 SAY "Procenat uvecanja(+)/umanjenja(-) "+IF(cTipVPC=="3","VPC",IF(cTipVPC=="4","VPC2","NC")) GET nMPosto pict "999999.99"
   @ m_x+7,m_y+2 SAY "                                                     "
   read
 endif

 if cStanje=="D"
  cZaglavlje:=""
  O_PARAMS
  private cSection:="c",cHistory:=" "; aHistory:={}
  RPar("za",@cZaglavlje)
  cDN:="N"
  @ m_x+11,m_y+2 SAY "Mijenjati zaglavlje izvjestaja:" GET cDN pict "@!" valid cdn $ "DN"
  read
  if cDN=="D"
     ZaglTxt(@cZaglavlje)
  endif
  WPar("za",cZaglavlje)
  select params; use
  select roba
 endif

 if cPSort=="D"
    @ m_x+15, m_y+2 SAY "Sortirati:" GET cSort
    read
 endif

 ESC_BCR
 aUsl1:=Parsiraj(qqRoba,"Id")
 if cTIPVPC=="1" .or. fieldpos("vpc2")==0
  aUsl2:=Parsiraj(qqVPC,"VPC","N")
 else
  aUsl2:=Parsiraj(qqVPC,"VPC2","N")
 endif
 if aUsl1<>NIL; exit; endif
 if aUsl2<>NIL; exit; endif
enddo

BoxC()

if lastkey()==K_ESC; closeret; endif

if cPSort=="D"
  select roba
  use
  cSort:=trim(cSort)
  usex (SIFPATH+"roba")
  dbcreateind(PRIVPATH+"robai9",cSort,{|| &cSort} )
endif

PRIVATE cFilt1:=""
cFilt1 := aUsl1+".and."+aUsl2
cFilt1 := STRTRAN(cFilt1,".t..and.","")
IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

go top

EOF CRET


MsgO("Priprema CJEN.RTF fajla")

//InitFW()
//nTxt2:=len(WWSjeciStr(cTxt2,10,171))

set printer to (cImeF)
set printer on
set console off

Setpxlat()
WWInit0()
WWFontTbl()
?? "{\stylesheet {\f2\fs20 \snext0 Normal;}{\*\cs10 \additive Default Paragraph Font;}"
? "{"+cS1+" \sbasedon0\snext0 heading 1;}"
? "{"+cS2+" \sbasedon0\snext0 heading 2;}"
? "{"+cS3+" \sbasedon0\snext0 heading 3;}"
? "{"+cS9+" \sbasedon0\snext0 heading 9;}"
? "{\s20\qc\sb40\sa0\sl-400\slmult0 \f2\fs20 \sbasedon0\snext20 estyle1;}}"+NL
WWInit1()
?? "\footery1000"
WWSetMarg(17,15,15,26)
WWSetPage("A4","P")
? "{\footer \pard\plain \qc\sb0 \f2\fs20 {- }"
//? "{\footer \pard\plain \qc\sb44 \f2\fs20 {- }"
? "{\field{\*\fldinst {\cs18\b\i\fs20  PAGE }}}{ -}\par }"
nNivo:=0


private nStanje:=0


if cStanje=="N"
 select fakt; use
 select roba
endif

if cStanje=="D"
 cZaglavlje:=strtran(cZaglavlje,chr(13)+Chr(10),"\par ")
 cZaglavlje:=strtran(cZaglavlje,"$DATUM$",dtoc(Date()))+"\par "
 ? "\pard\plain",cS1,trim(czaglavlje)+"\par "
 ? "\pard\plain \nowidctlpar \f48\fs20"
 ? "\par "
 ? "\pard\plain",cS1,"\tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\fs20 kolicina \tab \fs20 cijena\par "
 ? "\pard\plain \nowidctlpar \f48\fs20"
 ? "\par "
endif
do while !eof()

   if nNivo==0
     if nivos(id)==1
      ? cS1,left(id,gnivo1),+".",ToRtfstr(trim(naz))
     elseif nivos(id)==2
      ? cS2,left(id,gnivo1+gnivo2),+".",ToRtfstr(trim(naz))
     elseif nivos(id)==3
      ? cS3,left(id,gnivo1+gnivo2+gnivo3),+".",ToRtfstr(trim(naz))
     else
      ? cS9,left(id,NivoS(id)),+".",ToRtfstr(trim(naz))
     endif
   elseif nNivo==1
      ? "\page"
      ? "\pard\plain",cS1,left(id,gNivo1),+".",ToRtfstr(trim(naz))
   elseif nNivo==2
      ? "\pard\plain\",cS2,left(id,gnivo1+gNivo2),+".",ToRtfstr(trim(naz))
   elseif nNivo==3
      ? "\pard\plain\",cS3,left(id,gnivo1+gNivo2+gNivo3),+".",ToRtfstr(trim(naz))
   elseif nNivo==9

       cIdRoba:=id
       if cStanje=="D"
         select fakt
         nStanje:=0
         hseek cidroba
         do while !eof() .and. cIdRoba==IdRoba
           if idtipdok="0"  // ulaz
               nStanje+=kolicina
           elseif idtipdok="1"   // izlaz faktura
              if !(left(serbr,1)=="*" .and. idtipdok=="10")  // za fakture na osnovu optpremince ne ra~unaj izlaz
               nStanje-=kolicina
              endif
           elseif idtipdok="20"
               if serbr="*"
                 nStanje-=kolicina
               endif
           elseif idtipdok=="21"
               nStanje-=kolicina
           endif
           skip
         enddo
         select roba
         if nSLimit>=nStanje
           skip
           loop
         endif
       endif

      if cTIPVPC$"13" .or. fieldpos("vpc2")==0 .and. cTipVPC$"24"
          cVPC:=transform(vpc*(1+nMPosto/100),"99999.99")
      elseif cTipVPC=="5"
          cVPC:=transform(nc*(1+nMPosto/100),"99999.99")
      elseif cTipVPC=="6"
          cVPC:=transform(mpc,"99999.99")
      else
          cVPC:=transform(vpc2*(1+nMPosto/100),"99999.99")
      endif
      if cStanje=="N"
       ? "\pard\plain\",cS9,trim(id),+".",ToRtfstr(trim(naz))+" ("+lower(roba->jmj)+") ","\tab\tab",cVPC
      else
       ? "\pard\plain\",cS9,trim(id),+".",ToRtfstr(trim(naz)),"\tab "+transform(nstanje,"9999999")+" "+lower(roba->jmj)+" ","\tab",cVPC
      endif
   endif
   skip
   if !eof()
     ?? " \par"
   endif
   nNivo:=NivoS(id)
enddo
WWEnd()

set printer to;set printer off; set console on

MsgC()
Beep(2)

if empty(gKomLin)
   Box(,7,55,.t.)
    set cursor off
    @ m_x+1,m_y+2 SAY "Dokument je pripremljen za stampu"
    inkey(0)
  BoxC()
else
  gKomlinCj:=strtran(upper(gKomlin),"FAKT.RTF","CJEN.RTF")
  save screen to cScr
  run &gKomLinCj
  restore screen from cScr
   Box(,7,55,.t.)
    set cursor off
    @ m_x+1,m_y+2 SAY "Izgenerisan je rtf fajl i poslan u Word"
    inkey(0)
  BoxC()
endif
return

********************************
********************************
function ZaglTxt(cZaglavlje)

cId:="  "
 Box(,9,75)
 setcolor(Invert)
 UsTipke()
 cZaglavlje:=MemoEdit(cZaglavlje,m_x+2,m_y+1,m_x+9,m_y+76)
 BosTipke()
 setcolor(Normal)
 BoxC()
return

*****************************
*****************************
function NivoS(cSif)
local i,nPom,nRet
for i:=1 to len(cSif)
  if substr(cSif,i,1) $ ". "
    exit
  endif
next
--i
if i==gNivo1
    return 1
elseif i==gnivo1+gNivo2
    return 2
elseif i==gnivo1+gNivo2+gNivo3
    return 3
elseif i==gnivo1+gNivo2+gnivo3+gNivo4
    return 4
elseif i==gnivo1+gNivo2+gnivo3+gNivo4+gNivo5
    return 5
else
    return 9
endif



*****************************
*****************************
function Pars()

O_PARAMS
private cSection:="C",cHistory:=" "; aHistory:={}
RPar("n0",@gNivoa)
RPar("n1",@gNivo1)
RPar("n2",@gNivo2)
RPar("n3",@gNivo3)
RPar("n4",@gNivo4)
RPar("n5",@gNivo5)
Box(,7,60)
 set cursor on
 @ m_x+1,m_y+2 SAY "Broj nivoa " GET gNivoa
 @ m_x+2,m_y+2 SAY "Sirina Nivoa 1" GET gNivo1
 @ m_x+3,m_y+2 SAY "Sirina Nivoa 2" GET gNivo2
 @ m_x+4,m_y+2 SAY "Sirina Nivoa 3" GET gNivo3
 @ m_x+5,m_y+2 SAY "Sirina Nivoa 4" GET gNivo4
 @ m_x+6,m_y+2 SAY "Sirina Nivoa 5" GET gNivo5
 read
BoxC()
if lastkey()<>K_ESC
  WPar("n0",@gNivoa)
  WPar("n1",@gNivo1)
  WPar("n2",@gNivo2)
  WPar("n3",@gNivo3)
  WPar("n4",@gNivo4)
  WPar("n5",@gNivo5)
  select params; use
endif
closeret

****************************************************
function SkloniSezonu(cSezona,finverse,fda,fnulirati)
*
* fnulirati
******************************************************
return

***************************************
* koriste je Achoice2, Objdbedit
***************************************
function GProc(Ch)
do case
       CASE Ch==K_F1
          Help()
       CASE Ch==K_SH_F1
         Calc()
       CASE Ch==K_SH_F2
         PPrint()
       CASE Ch==K_SH_F10
         Gparams()
       CASE Ch==K_SH_F5
          Vratisez()
       CASE Ch==K_SH_F6
         LogAgain()
       CASE Ch==K_SH_F7
         KorLoz()
endcase
CLEAR TYPEAHEAD

********************************
function UcitajParams()
*
********************************
return

procedure e(p1,p2,p3,p4)
cjen(p1,p2,p3,p4)
return


#include "p:\clp52\include\rddinit.ch"


#ifdef CAX
function truename(cc)  // sklonjena iz CTP
return cc
#endif

