#include "\cl\sigma\fmk\fin\fin.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rptm/1g/rpt_ppro.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: rpt_ppro.prg,v $
 * Revision 1.4  2004/01/13 19:07:57  sasavranic
 * appsrv konverzija
 *
 * Revision 1.3  2003/01/27 00:44:19  mirsad
 * ispravke BUG-ova
 *
 * Revision 1.2  2002/06/21 07:40:11  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/rptm/1g/rpt_ppro.prg
 *  \brief Pregled promjena 
 */

/*! \fn PrPromRn()
 *  \brief Pregled promjena na racunu
 */

function PrPromRn()
*{
qqIDVN  := "I1;I2;"
qqKonto := "2000;"
dOd     := dDo := DATE()
cNazivFirme := gNFirma

private picBHD:=FormPicL(gPicBHD,16)
private picDEM:=FormPicL(gPicDEM,12)

O_PARAMS
Private cSection:="o",cHistory:=" ",aHistory:={}
RPar("q1",@qqIDVN)
RPar("q2",@qqKonto)
RPar("q3",@dOd)
RPar("q4",@dDo)
RPar("q5",@cNazivFirme)
SELECT PARAMS; USE

qqIDVN      := PADR( qqIDVN      , 60 )
qqKonto     := PADR( qqKonto     , 60 )
cNazivFirme := PADR( cNazivFirme , 60 )

Box("#PREGLED PROMJENA NA RACUNU",8,75)
 DO WHILE .t.
   @ m_x+2, m_y+2 SAY "Vrste naloga za knjizenje izvoda:" GET qqIDVN  PICT "@S20"
   @ m_x+3, m_y+2 SAY "Konto/konta ziro racuna         :" GET qqKonto PICT "@S20"
   @ m_x+4, m_y+2 SAY "Period od datuma:" GET dOd
   @ m_x+4, col()+2 SAY "do datuma:" GET dDo
   @ m_x+5, m_y+2 SAY "Puni naziv firme:" GET cNazivFirme PICT "@S35"
   READ; ESC_BCR
   aUsl1 := Parsiraj( qqIDVN, "IDVN" )
   aUsl2 := Parsiraj( qqKonto, "IDKONTO" )
   IF aUsl1<>NIL .and. aUsl2<>NIL; EXIT; ENDIF
 ENDDO
BoxC()

qqIDVN      := TRIM( qqIDVN      )
qqKonto     := TRIM( qqKonto     )
cNazivFirme := TRIM( cNazivFirme )

O_PARAMS
Private cSection:="o",cHistory:=" ",aHistory:={}
WPar("q1",qqIDVN)
WPar("q2",qqKonto)
WPar("q3",dOd)
WPar("q4",dDo)
WPar("q5",cNazivFirme)
SELECT PARAMS; USE

O_KONTO
O_PARTN
O_SUBAN
// SET ORDER TO TAG "5"
// idFirma+IdKonto+dtos(DatDok)+idpartner

cFilter := aUsl1
IF !EMPTY(dOd); cFilter += ( ".and. DATDOK>=" + cm2str(dOd) ); ENDIF
IF !EMPTY(dDo); cFilter += ( ".and. DATDOK<=" + cm2str(dDo) ); ENDIF

cSort := "dtos(datdok)"
INDEX ON &cSort TO "SUBTMP" FOR &cFilter
// SET FILTER TO &cFilter

aDug := {}; nDug:=0
aPot := {}; nPot:=0

GO TOP
DO WHILE !EOF()
  IF &aUsl2
    SKIP 1
    LOOP
  ENDIF
  IF d_p=="1"
    AADD( aDug , RedIspisa() )
    nDug += iznosbhd
  ELSE
    AADD( aPot , RedIspisa() )
    nPot += iznosbhd
  ENDIF
  SKIP 1
ENDDO

m := "------ -------- ------ "+REPL("-",40)+" "+REPL("-",16)
z := "R.BR. * DATUM  *PARTN.*"+PADC("NAZIV PARTNERA ILI OPIS PROMJENE",40)+"*"+PADC("UPLATA KM",16)

START PRINT CRET
 nStranica := 0
 ZagPPR("U")
 FOR i:=1 TO LEN(aPot)
   IF prow()>60+gPstranica
     FF
     ZagPPR("U")
   ENDIF
   ? STR(i,5)+". "+aPot[i]
 NEXT
 ? m
 ? "UKUPNO UPLATE"+PADL(TRANSFORM(nPot,picbhd),67)
 ? m
 ?
 IF prow()>60+gPstranica
   FF
   ZagPPR("I")
 ELSE
   ? "PREGLED ISPLATA:"
   ? m; ? z; ? m
 ENDIF
 FOR i:=1 TO LEN(aDug)
   IF prow()>60+gPstranica
     FF
     ZagPPR("I")
   ENDIF
   ? STR(i,5)+". "+aDug[i]
 NEXT
 ? m
 ? "UKUPNO ISPLATE"+PADL(TRANSFORM(nDug,picbhd),66)
 ? m

 FF
END PRINT

CLOSERET
return
*}



/*! \fn RedIspisa()
 *  \brief
 */
 
function RedIspisa()
*{
LOCAL cVrati:=""
  cVrati := DTOC(datdok)+" "+idpartner+" "
  IF EMPTY(idpartner)
    cVrati += PADR( opis , 40 )
  ELSE
    cVrati += PADR( Ocitaj(F_PARTN,idpartner,"naz") , 40 )
  ENDIF
  cVrati += ( " " + TRANSFORM(iznosbhd,picbhd) )
RETURN cVrati
*}



/*! \fn ZagPPR(cI)
 *  \brief Zaglavlje pregleda promjena na racunu
 *  \param cI
 */
 
function ZagPPR(cI)
*{
? cNazivFirme
  ? PADL("Str."+ALLTRIM(STR(++nStranica)),80)
  ? PADC( StrKZN("PREGLED PROMJENA NA RA¨UNU","8",gKodnaS) , 80 )
  ? PADC( "ZA PERIOD "+DTOC(dOd)+" - "+DTOC(dDo) , 80 )
  ?
  IF cI=="U"
    ? "PREGLED UPLATA:"
  ELSE
    ? "PREGLED ISPLATA:"
  ENDIF
  ? m; ? z; ? m
RETURN
*}



/*! \fn StrKZN(cInput,cIz,cU)
 *  \brief Konverzija znakova
 *  \param cInput  - ulazni tekst
 *  \param cIz     - izlaz
 *  \param cU      - ulaz
 */
 
function StrKZN(cInput,cIz,cU)
*{ 
 LOCAL a852:={"Ê","—","¨","è","¶","Á","–","ü","Ü","ß"}
 LOCAL a437:={"[","\","^","]","@","{","|","~","}","`"}
 LOCAL aEng:={"S","D","C","C","Z","s","d","c","c","z"}
 LOCAL i:=0, aIz:={}, aU:={}
 aIz := IF( cIz=="7" , a437 , IF( cIz=="8" , a852 , aEng ) )
 aU  := IF(  cU=="7" , a437 , IF(  cU=="8" , a852 , aEng ) )
 FOR i:=1 TO 10
   cInput:=STRTRAN(cInput,aIz[i],aU[i])
 NEXT
RETURN cInput
*}



