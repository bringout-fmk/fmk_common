#include "fmk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/rpt_sast.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.3 $
 * $Log: rpt_sast.prg,v $
 * Revision 1.3  2003/05/27 15:32:30  mirsad
 * vraæanje posljednje verzije pregleda normativa
 *
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */
 


/*! \fn ISast()
 *  \brief Pregled sastavnica 
 */
 
function ISast()
*{
local nArr:=SELECT()
qqProiz      := SPACE(60)
cBrisi       := "N"
cSamoBezSast := "N"
cNCVPC       := "D"

do while .t.
Box(,7,60)
 @ m_x+1,m_y+2 SAY "Proizvodi :" GET qqProiz  pict "@!S30"
 @ m_x+3,m_y+2 SAY "Brisanje prekinutih sastavnica ? (D/N)" GET cBrisi  pict "@!" valid cBrisi $ "DN"
 @ m_x+5,m_y+2 SAY "Prikazati samo proizvode bez sastavnica ? (D/N)" GET cSamoBezSast  pict "@!" valid cSamoBezSast $ "DN"
 @ m_x+7,m_y+2 SAY "Prikazati NC i VPC ? (D/N)" GET cNCVPC VALID cNCVPC$"DN" PICT "@!"
 read
BoxC()

IF LASTKEY()==K_ESC
	return
ENDIF

private aUsl1:=Parsiraj(qqProiz,"Id")
if aUsl1<>NIL; exit; endif
enddo

select (nArr)
PushWA()

select (F_ROBA)
if !used()
	O_ROBA
endif

select (F_SAST)
if !used()
	O_SAST
else
	use
	O_SAST
endif

if cBrisi=="D"
  select sast; set order to; go top
  do while !eof()
     skip; nTrec:=recno(); skip -1
     select roba; hseek sast->id  // nema "svog proizvoda"
     if !found()
       select sast; delete
     endif
     select sast
     go nTRec
  enddo
  select sast; set order to tag "ID"; go top
endif

START PRINT CRET

if cSamoBezSast=="D"

  SELECT ROBA

  if len(aUsl1)<>0
    aUsl1+=".and. tip=='P'"
    set filter to &(aUsl1)
  else
    set filter to tip=="P"
  endif

  m:="----------------------------------------------------------------------------------------------"
  nCol1:=60
  P_10CPI
  ? "Pregled proizvoda koji nemaju definisane sastavnice"
  ?
  ? gNFirma,space(20),"na dan",date()
  GO TOP
  P_12CPI
  ?
  nRBr:=0
  do WHILE !EOF()
    cId:=id
    SELECT SAST; HSEEK ROBA->ID
    IF !FOUND()
      if prow()>62+gPStranica; FF; endif
      ? STR(++nRBr,3)+".", roba->id, LEFT(roba->naz, 40), roba->jmj
    ENDIF
    SELECT ROBA
    SKIP 1
  enddo
  ? m

else

  if len(aUsl1)<>0
    set filter to &(aUsl1)
  else
    set filter to
  endif
  IF cNCVPC=="D"
    m:="----------------------------------------------------------------------------------------------"
    z:="                                                              Kolicina         NV        VPV"
  ELSE
    m:="------------------------------------------------------------------------"
    z:="                                                              Kolicina"
  ENDIF
  nCol1 := 20+LEN(ROBA->(id+naz))
  P_10CPI
  ? "Pregled sastavnica-normativa za proizvode"
  ?
  ? gNFirma,space(20),"na dan",date()
  go top
  P_COND
  DO WHILE !EOF()
    aPom:={}
    cId:=id
    select roba; hseek sast->id; select sast
    AADD(aPom,"")
    AADD(aPom,m)
    AADD(aPom,roba->id + " " + LEFT(roba->naz, 40) + " " + roba->jmj)
    AADD(aPom,m)
    AADD(aPom,z)
    AADD(aPom,m)
    nRbr:=0
    nNC:=0
    nVPC:=0
    DO WHILE cID==ID .AND. !EOF()
      SELECT ROBA; HSEEK SAST->ID2; SELECT SAST
      AADD( aPom , str(++nrbr,5)+". "+;
                   roba->id+" "+;
                   LEFT(roba->naz, 40)+" "+;
                   TRANSFORM(kolicina,"999999.9999")+" "+;
                   IF(cNCVPC=="D",TRANSFORM(roba->nc*kolicina ,picdem)+" "+;
                   TRANSFORM(roba->vpc*kolicina,picdem),"");
          )
      nNC+=roba->nc*kolicina
      nVPC+=roba->vpc*kolicina
      SKIP 1
    ENDDO
    IF cNCVPC=="D"
      AADD( aPom , m )
      AADD( aPom , PADR(" Ukupno:",nCol1)+" "+;
                   TRANSFORM(nNC,picdem)+" "+;
                   TRANSFORM(nVPC,picdem);
                    )
    ENDIF
    AADD( aPom , m )
    if prow()+LEN(aPom)>62+gPStranica; FF; endif
    FOR i:=1 TO LEN(aPom); ? aPom[i]; NEXT
  ENDDO

endif

FF
END PRINT
select (nArr)
PopWA()
return
*}


