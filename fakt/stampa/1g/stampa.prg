#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/stampa/1g/stampa.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.1 $
 * $Log: stampa.prg,v $
 * Revision 1.1  2002/06/26 18:01:29  ernad
 *
 *
 * ciscenja
 *
 *
 */
 

/*! \fn StViseDokMenu(cVarijanta)
 *  \brief Menij stampe vise dokumenata
 *  \param cVarijanta   - varijanta
 */
 
function StViseDokMenu(cVarijanta)
*{
  STATIC nPom:=0
  LOCAL aPom:={}, cKljuc:="", i:=0, nD1:=0, nD2:=0, nD3:=0

  IF "U" $ TYPE("lSSIP99") .or. !VALTYPE(lSSIP99)=="L"; lSSIP99:=.f.; ENDIF

  IF cVarijanta==NIL; cVarijanta:="STAMPANJE"; ENDIF

  SELECT PRIPR; GO TOP
  DO WHILE !EOF()
    cKljuc:=IDFIRMA+IDTIPDOK+LEFT(BRDOK,LEN(BRDOK)-1)+CHR(ASC(RIGHT(BRDOK,1))+1)
    AADD(aPom,IDFIRMA+"-"+IDTIPDOK+"-"+BRDOK)
    SEEK cKljuc
  ENDDO

  IF LEN(aPom)==0; gFiltNov:=""; RETURN .f.; ENDIF

  nD1:=LEN(IDFIRMA); nD2:=LEN(IDTIPDOK); nD3:=LEN(BRDOK)

  FOR i:=1 TO LEN(aPom)
   IF LEN(h)<i; AADD(h,""); ENDIF
  NEXT

  IF cVarijanta=="BRISI"
    IF nPom==0; nPom:=1; ENDIF
    IF nPom>LEN(aPom); nPom:=LEN(aPom); ENDIF
  ELSE
    ++nPom
    IF nPom>LEN(aPom); nPom:=1; ENDIF
  ENDIF

  IF !lSSIP99
    Box(,LEN(aPom)+4,18+IF(cVarijanta=="BRISI",1,0))
     IF cVarijanta=="BRISI"
       @ m_x+1, m_y+2 SAY "IZABERITE DOKUMENT "
       @ m_x+2, m_y+2 SAY "KOJI ZELITE BRISATI"
       @ m_x+3, m_y+2 SAY "컴컴컴컴컴컴컴컴컴�"
     ELSE
       @ m_x+1, m_y+2 SAY "IZABERITE DOKUMENT"
       @ m_x+2, m_y+2 SAY "   ZA STAMPANJE   "
       @ m_x+3, m_y+2 SAY "컴컴컴컴컴컴컴컴컴"
     ENDIF
     nPom:=Menu2(m_x+3,m_y+3,aPom,nPom)
    BoxC()
  ENDIF

  IF nPom>0
    gFiltNov:=LEFT(aPom[nPom],nD1)+SUBSTR(aPom[nPom],nD1+2,nD2)+RIGHT(aPom[nPom],nD3)
    SEEK gFiltNov
  ELSE
    gFiltNov:=""
  ENDIF

return IF(nPom=LEN(aPom).and.cVarijanta!="BRISI".or.nPom==0,.f.,.t.)
*}


/*! \fn FilterPrNovine()
 *  \brief Postavlja filter na zadani dokument sa gFiltNov
 *  \todo Pregledati gdje se koristi, izgleda da je vezano samo za ZIPS ili Opresu
 */
 
function FilterPrNovine()
*{
SET FILTER TO IDFIRMA+IDTIPDOK+BRDOK=gFiltNov
GO TOP
return
*}


