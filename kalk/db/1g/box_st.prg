#include "\cl\sigma\fmk\kalk\kalk.ch"



/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/db/1g/box_st.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: box_st.prg,v $
 * Revision 1.2  2002/06/18 14:02:38  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */

/*! \file fmk/kalk/db/1g/box_st.prg
 *  \brief Racunanje i prikaz stanja robe
 */

/*! \fn KalkStanje(cIdRoba)
 *  \brief Racunanje i prikaz stanja robe
 */

function KalkStanje(cIdRoba)
*{
local nUl,nIzl,nRezerv,nRevers,fOtv:=.f.,nIOrd,nFRec, aStanje
local aZN := { CTOD("") , 0 , 0 , 0 } // zadnja nabavka
select roba
select (F_KALK)
if !used()
   O_KALK; fOtv:=.t.
else
  nIOrd:=indexord()
  nFRec:=recno()
endif
// "7","Idroba")
set order to tag "7"
SEEK cIdRoba

aStanje:={}
//{idkonto, nUl,nIzl }         KALK
nUl:=nIzl:=0
do while !eof()  .and. cIdRoba==IdRoba
   nUlaz:=nIzlaz:=0
   IF !EMPTY(mkonto)
     nPos:=ASCAN (aStanje, {|x| x[1]==KALK->mkonto})
     if nPos==0
       AADD (aStanje, {mkonto, 0, 0})
       nPos := LEN (aStanje)
     endif
     if mu_i=="1" .and. !(idvd $ "12#22#94")
       nUlaz  := kolicina-gkolicina-gkolicin2
     elseif mu_i=="5"
       nIzlaz := kolicina
     elseif mu_i=="1" .and. (idvd $ "12#22#94")    // povrat
       nIzlaz := -kolicina
     elseif mu_i=="8"
       nIzlaz := -kolicina
       nUlaz  := -kolicina
     endif
   ELSE
     nPos:=ASCAN (aStanje, {|x| x[1]==KALK->pkonto})
     if nPos==0
       AADD (aStanje, {pkonto, 0, 0})
       nPos := LEN (aStanje)
     endif
     if pu_i=="1"
       nUlaz  := kolicina-GKolicina-GKolicin2
     elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
       nIzlaz := kolicina
     elseif pu_i=="I"
       nIzlaz := gkolicin2
     elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
       nUlaz  := -kolicina
     endif
   ENDIF
   aStanje[nPos,2] += nUlaz
   aStanje[nPos,3] += nIzlaz
   IF idvd=="10" .and. kolicina>0 .and. datdok>=aZN[1]
     aZN[1] := datdok
     aZN[2] := fcj
     aZN[3] := rabat
     aZN[4] := nc
   ENDIF
   skip 1
enddo

PRIVATE ZN_Datum  := aZN[1]           // datum zadnje nabavke
PRIVATE ZN_FakCij := aZN[2]           // fakturna cijena po zadnjoj nabavci
PRIVATE ZN_Rabat  := aZN[3]           // rabat po zadnjoj nabavci
PRIVATE ZN_NabCij := aZN[4]           // nabavna cijena po zadnjoj nabavci

if fotv
 selec kalk; use
else
  dbsetorder(nIOrd)
  go nFRec
endif
select roba
BoxStanje(aStanje, cIdRoba)      // nUl,nIzl
return
*}



/*! \fn BoxStanje(aStanje,cIdRoba)
 *  \brief Prikaz stanja robe
 */

function BoxStanje(aStanje,cIdroba)
*{
local picdem:="9999999.999", nR, nC, nTSta := 0, nTUl := 0, nTIzl := 0,;
      npd, cDiv := " ³ ", nLen, nRPoc:=0

 npd := LEN (picdem)
 nLen := LEN (aStanje)
 nLenKonta := IF( nLen>0 , LEN(aStanje[1,1]) , 7 )

 ASORT(aStanje,,,{|x,y| x[1]<y[1]})

 // ucitajmo dodatne parametre stanja iz FMK.INI u aDodPar
 // ------------------------------------------------------
 aDodPar := {}
 FOR i:=1 TO 6
   cI := ALLTRIM(STR(i))
   cPomZ := IzFMKINI( "BoxStanje" , "ZaglavljeStanje"+cI , "" , KUMPATH )
   cPomF := IzFMKINI( "BoxStanje" , "FormulaStanje"+cI   , "" , KUMPATH )
   IF !EMPTY( cPomF )
     AADD( aDodPar , { cPomZ , cPomF } )
   ENDIF
 NEXT
 nLenDP := IF( LEN(aDodPar)>0 , LEN(aDodPar)+1 , 0 )

 select roba
 //PushWa()
 set order to tag "ID"; seek cIdRoba
 Box( , MIN( 6+nLen+INT((nLenDP)/2) , 23 ) , 75 )
  Beep(1)
  @ m_x+1,m_y+2 SAY "ARTIKAL: "
  @ m_x+1,col() SAY PADR(AllTrim (cidroba)+" - "+roba->naz,51) COLOR "GR+/B"
  @ m_x+3,m_y+2 SAY cDiv + PADC("KONTO",nLenKonta) + cDiv + PADC ("Ulaz", npd) + cDiv+ ;
                    PADC ("Izlaz", npd) + cDiv + ;
                    PADC ("Stanje", npd) + cDiv
  nR := m_x+4
  nRPoc := nR
  FOR nC := 1 TO nLen
//{idfirma, nUl,nIzl,nRevers,nRezerv }
    @ nR,m_y+2 SAY cDiv
    @ nR,col() SAY aStanje [nC][1]
    @ nR,col() SAY cDiv
    @ nR,col() SAY aStanje [nC][2] pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY aStanje [nC][3] pict picdem
    @ nR,col() SAY cDiv
    nPom := aStanje [nC][2]-aStanje [nC][3]
    @ nR,col() SAY nPom pict picdem
    @ nR,col() SAY cDiv
    nTUl  += aStanje [nC][2]
    nTIzl += aStanje [nC][3]
    nTSta += nPom
    nR ++

    IF nC%15 = 0 .and. nC<nLen
      INKEY(0)
      @ m_x+nRPoc, m_y+2 CLEAR TO m_x+nR-1, m_y+70
      nR:=nRPoc
    ENDIF

  NEXT
    @ nR,m_y+2 SAY cDiv + REPL("-",nLenKonta) + cDiv + REPL ("-", npd) + cDiv+ ;
                   REPL ("-", npd) + cDiv + ;
                   REPL ("-", npd) + cDiv
    nR ++
    @ nR,m_y+2 SAY cDiv+PADC("UKUPNO:",nLenKonta)+cDiv
    @ nR,col() SAY nTUl pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY nTIzl pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY nTSta pict picdem
    @ nR,col() SAY cDiv

    // ispis dodatnih parametara stanja
    // --------------------------------
    IF nLenDP>0
      ++nR
      @ nR, m_y+2 SAY REPL("-",74)
      FOR i:=1 TO nLenDP-1

        cPom777 := aDodPar[i,2]

        IF "TARIFA->" $ UPPER(cPom777)
          SELECT (F_TARIFA)
          IF !USED(); O_TARIFA; ENDIF
          SET ORDER TO TAG "ID"
          HSEEK ROBA->idtarifa
          SELECT ROBA
        ENDIF

        IF i%2!=0
          ++nR
          @ nR, m_y+2 SAY PADL( aDodPar[i,1] , 15 ) COLOR "W+/B"
          @ nR, col()+2 SAY &cPom777 COLOR "R/W"
        ELSE
          @ nR, m_y+37 SAY PADL( aDodPar[i,1] , 15 ) COLOR "W+/B"
          @ nR, col()+2 SAY &cPom777 COLOR "R/W"
        ENDIF

      NEXT
    ENDIF

  inkey(0)
 BoxC()
 //PopWa()
return
*}
