#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/adm/1g/kor_nc.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: kor_nc.prg,v $
 * Revision 1.2  2002/06/18 14:02:38  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */

/*! \file fmk/kalk/adm/1g/kor_nc.prg
 *  \brief Korekcija gresaka na karticama artikala
 */


/*! \fn KorekNC()
 *  \brief Korekcija nabavne cijene na magacinskim karticama
 */

function KorekNC()
*{
 LOCAL dDok:=date(), nPom:=0, cPom2
 PRIVATE cMagac:="1310   "
 
 IF !SigmaSif("SIGMAPRN")
   return
 endif
 
 O_KONTO
 IF !VarEdit({ {"Magacinski konto","cMagac","P_Konto(@cMagac)",,} }, 12,5,16,74,;
               'DEFINISANJE MAGACINA NA KOME CE BITI IZVRSENE PROMJENE',;
               "B1")
   CLOSERET
 ENDIF
 O_PRIPR
 O_KALK
 GO TOP
 DO WHILE !EOF()
   IF (nc==0.and.!idvd$"11#12".or.fcj==0.and.idvd$"11#12").and.mkonto==cMagac
     Scatter()
     SELECT PRIPR
     DO CASE
       CASE KALK->idvd $ "16#96#82#14#11#12"
         cPom2:="X0000001"
         IF KALK->idvd $ "11#12"
           cPom2:="X"+RIGHT(ALLTRIM(KALK->idkonto),3)+"0001"
         ELSEIF KALK->idvd $ "14"
           cPom2:="X"+PADR(ALLTRIM(KALK->idpartner),6,"0")+"1"
         ENDIF
            _brdok:=cPom2
           _datdok:=dDok
          _brfaktp:=SPACE(10)
         _datfaktp:=dDok
              _rbr:=TraziRbr(KALK->(idfirma+idvd)+cPom2+"XXX")
         _kolicina:=-_kolicina
          APPEND BLANK
          Gather()
          Scatter()
              _rbr:=TraziRbr(KALK->(idfirma+idvd)+cPom2+"XXX")
         _kolicina:=-_kolicina
              nPom:=TraziNC(KALK->(idfirma+cMagac)+idroba,KALK->datdok)
          IF KALK->idvd $ "11#12"
               _fcj:=IF(nPom==0,_vpc/1.2,nPom)
            _marza:=_vpc-_fcj
          ELSE
               _nc:=IF(nPom==0,_vpc/1.2,nPom)
            _marza:=_vpc-_nc
          ENDIF
          APPEND BLANK
          Gather()

     ENDCASE
   ENDIF
   SELECT KALK
   SKIP 1
 ENDDO
CLOSERET
*}


/*! \fn TraziRbr(cKljuc)
 *  \brief Utvrdjuje posljednji redni broj stavke zadanog dokumenta u pripremi
 */

function TraziRbr(cKljuc)
*{
 LOCAL cVrati:="  1"
 SELECT PRIPR; GO TOP
 SEEK cKljuc
 SKIP -1
 IF idfirma+idvd+brdok==LEFT(cKljuc,12)
   cVrati:=STR(VAL(rbr)+1,3)
 ENDIF
return cVrati
*}


/*! \fn TraziNC(cTrazi,dDat)
 *  \brief Utvrdjuje najcescu NC zadane robe na zadanom kontu do zadanog datuma
 */

function TraziNC(cTrazi,dDat)
*{
 LOCAL nSlog:=0, aNiz:={{0,0}}, nPom:=0, nVrati:=0
  SELECT KALK
  nSlog:=RECNO()
  SET ORDER TO 3
  GO TOP
  SEEK cTrazi
  DO WHILE cTrazi==idfirma+mkonto+idroba .and. datdok<=dDat .and. !EOF()
    nPom:=ASCAN(aNiz,{|x| KALK->nc==x[1]})
    IF nPom>0
      aNiz[nPom,2]+=1
    ELSE
      AADD(aNiz,{KALK->nc,1})
    ENDIF
    SKIP 1
  ENDDO
  SET ORDER TO 1
  GO nSlog
  ASORT(aNiz,,,{|x,y| x[2]>y[2]})
  IF aNiz[1,1]>0
    nVrati:=aNiz[1,1]
  ELSEIF LEN(aNiz)>1
    nVrati:=aNiz[2,1]
  ENDIF
  SELECT PRIPR
return nVrati
*}
