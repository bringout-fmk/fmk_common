#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/razdb/1g/faktfin.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: faktfin.prg,v $
 * Revision 1.6  2004/01/13 19:07:56  sasavranic
 * appsrv konverzija
 *
 * Revision 1.5  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.4  2003/04/17 11:29:29  mirsad
 * Za varijantu prenosa FAKT->FIN po sastavnicama (kontiranje NV, koristi Cago) sada se porezi mogu dobiti i za varijantu obracuna u ugostiteljstvu "T" tj. uzimajuci u obzir stvarnu razliku u cijeni.
 *
 * Revision 1.3  2003/01/11 14:34:03  mirsad
 * ukinuo f-ju SezRad()
 *
 * Revision 1.2  2002/06/20 10:03:56  sasa
 * no message
 *
 *
 */
 

/*! \file fmk/fin/razdb/1g/faktfin.prg
 *  \brief Prenos podataka FAKT->FIN
 */
 
/*! \fn FaktFin() 
 *  \brief Prenos podataka FAKT->FIN
 */

function FaktFin()
*{
O_PARAMS
private cSection:="(",cHistory:=" "; aHistory:={}

lNCPoSast := ( IzFMKINI("FAKTFIN","NCPoSastavnici","N",KUMPATH)=="D" )
cKonSir   := PADR(IzFMKINI("FAKTFIN","KontoSirovinaIzSastavnice","1010",KUMPATH),7)

gFaktKum:=""
gKalkKum:=""
gDzokerF1:=""

cOdradjeno:="D"
altd()
if file(EXEPATH+'scshell.ini')
        //cBrojLok:=R_IniRead ( 'TekucaLokacija','Broj',  "",EXEPATH+'scshell.INI' )
        cOdradjeno:=R_IniRead ( 'ShemePromjena',alltrim(strtran(strtran(cDirPriv,"\","_"),":","_")),  "N" ,EXEPATH+'scshell.INI' )
        R_IniWrite ( 'ShemePromjena',alltrim(strtran(strtran(cDirPriv,"\","_"),":","_")),  "D" ,EXEPATH+'scshell.INI' )
endif

Rpar("a1",@gFaktKum)
Rpar("a2",@gDzokerF1)
Rpar("a3",@gKalkKum)

gDzokerF1 := TRIM(gDzokerF1)

if empty(gFaktKum) .or. cOdradjeno="N"
  gFaktKum:=trim(strtran(cDirRad,"FIN","FAKT"))+"\"
  Wpar("a1",@gFaktKum)
endif

if empty(gKalkKum) .or. cOdradjeno="N"
  gKalkKum:=trim(strtran(cDirRad,"FIN","KALK"))+"\"
  Wpar("a3",@gKalkKum)
endif


cIdFakt:="10"
dDAtOd:=date()
dDatDo:=date()
qqDok:=space(30)
cSetPAr:="N"
Box(,10,60)
 @ m_x+1,m_y+2 SAY "Vrsta dokumenta u fakt:" GET cIdFakt
 @ m_x+3,m_y+2 SAY "Dokumenti u periodu:" GET dDAtOd
 @ m_x+3,col()+2 SAY "do" GET dDatDo
 @ m_x+5,m_y+2 SAY "Broj dokumenta" GET qqDok

 @ m_x+6,m_y+2 SAY "Podesiti parametre prenosa" GET cSetPAr valid csetpar$"DN" pict "@!"
 read
 if cSetPar=="D"
   gFaktKum:=padr(gFaktKum,35)
   gKalkKum:=padr(gKalkKum,35)
   gDzokerF1:=PADR(gDzokerF1,80)
   USTipke()
   @ m_x+ 8,m_y+2 SAY "FAKT Kumulativ" GET gFaktKum  pict "@S25"
   @ m_x+ 9,m_y+2 SAY "Dzoker F1(formula)" GET gDzokerF1  pict "@S25"
   IF lNCPoSast
     @ m_x+10,m_y+2 SAY "KALK Kumulativ" GET gKalkKum  pict "@S25"
   ENDIF
   READ
   BosTipke()
   gFaktKum:=trim(gFaktKum)
   gKalkKum:=trim(gKalkKum)
   gDzokerF1:=trim(gDzokerF1)
   Wpar("a1",@gFaktKum)
   Wpar("a2",@gDzokerF1)
   Wpar("a3",@gKalkKum)
 endif

BoxC()

select params; use

if lastkey()==K_ESC
	closeret
endif

// ovo dole je ukradeno iz KALK/REKAPK

O_FINMAT
O_KONTO
O_PARTN
O_TDOK
O_ROBA
O_TARIFA

IF lNCPoSast
  O_SAST
  select (F_KALK)
  use (gKalkKum+"KALK")
  set order to tag "1"
ENDIF

select (F_FAKT)
use (gFaktKum+"FAKT")
set order to tag "1"
//"1","IdFirma+idtipdok+brdok+rbr+podbr",KUMPATH+"FAKT")

select FINMAT; zap

aUsl:=Parsiraj(qqDok,"Brdok","C")

private cFilter:="DatDok>="+cm2str(dDatOd)+".and.DatDok<="+cm2str(dDatDo)+".and. idtipdok=="+cm2str(cIdFakt)
if aUsl<>".t."
  cFilter+=".and."+aUsl
endif

select fakt
set filter to &cFilter
go top


nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=nTotb:=0
do whilesc !eof()

   cIdFirma:=IdFirma
   cBrDok:=BrDok
   cIdTipDok:=IdTipdok

   select fakt

   cIdPartner:=idpartner
   if empty(IdPartner)
      Box(,6,66)
      aMemo:=parsmemo(txt)
      if len(aMemo)>=5
        @ m_x+1,m_y+2 SAY "FAKT broj:"+BrDOK
        @ m_x+2,m_y+2 SAY padr(trim(amemo[3]),30)
        @ m_x+3,m_y+2 SAY padr(trim(amemo[4]),30)
        @ m_x+4,m_y+2 SAY padr(trim(amemo[5]),30)
      else
         cTxt:=""
      endif
      @ m_x+6,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
      read
      BoxC()
   endif

   do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdTipDok==IdTipDok

        nFV:=Cijena*Kolicina
        nRabat:=Cijena*kolicina*Rabat/100

        select ROBA; HSEEK FAKT->IdRoba
        select TARIFA; HSEEK roba->idtarifa
        select fakt

        nNV:=0
        IF lNCPoSast .and. ROBA->tip=="P"
          SELECT SAST; HSEEK FAKT->idroba
          DO WHILE !EOF() .and. id==FAKT->idroba
            nNV += FAKT->kolicina*SAST->kolicina*IzKalk(SAST->id2,cKonSir,"NC")
            SKIP 1
          ENDDO
        ENDIF

        select FINMAT
        append blank
        cIdVD := fakt->IdTipdok
        replace IdFirma   with fakt->IdFirma,;
                IdTarifa  with roba->IdTarifa,;
                IdPartner with cIdPartner,;
                IdVD      with cIdVD,;
                BrDok     with fakt->BrDok,;
                DatDok    with fakt->DatDok,;
                FV        with nFV ,;
                NV        with nNV ,;
                Marza     with 0,;
                VPV       with nFV,;
                RABATV    with nRabat,;
                Porez     with IF(cIdVD<>"11",(nFV-nRabat)*fakt->(porez/100),;
                               PorezMP("PP") ),;
                POREZV    with IF(cIdVD<>"11",Porez,;
                               PorezMP("PPU") ),;
                POREZ2    with IF(cIdVD<>"11",0,;
                               PorezMP("PPP") ),;
                idroba    with fakt->idroba,;
                Kolicina  with fakt->Kolicina

         IF cIDVD=="11" .and. lNCPoSast .and.;
            TARIFA->mpp<>0 .and. FIELDPOS("POREZ3")>0
           REPLACE porez3 WITH PorezMP("MPP")
         ENDIF
         select fakt
         skip
   enddo // brdok

enddo

select finmat
if reccount2()>0
 close all
 Kontnal(dDatDo)
else
 MsgBeep("Nema dokumenata za prenos ...")
endif
closeret
*}



/*! \fn PorezMp(cVar)
 *  \brief Porez u maloprodaji
 *  \param cVar
 */
 
function PorezMp(cVar)
*{
local nVrati, nCSP, nD, nMBVBP
local nPor1, nPor2, nPor3
local nMPP, nPPP, nPP, nPPU

nMPP:=tarifa->mpp/100
nPPP:=tarifa->opp/100 
nPP:=tarifa->zpp/100 
nPPU:=tarifa->ppp/100 

nCSP:=nFV-nRabat     // cijena sa porezima

if gUVarPP=="T"
	nPor1:=nCSP*nPPP/(1+nPPP)
	nPor2:=(nCSP-nPor1-nNV)*nMPP/(1+nMPP)
	nPor3:=(nCSP-nPor2)*nPP
	do case
		case cVar=="PP"
			nVrati:=nPor3
		case cVar=="PPP"
			nVrati:=nPor1
		case cVar=="PPU"
			nVrati:=0
		case cVar=="MPP"
			nVrati:=nPor2
	endcase
	return nVrati
endif

if  gUVarPP=="D"
	nD := 1+TARIFA->zpp/100+TARIFA->ppp/100
else
	nD := (1+TARIFA->opp/100)*(1+TARIFA->ppp/100)+TARIFA->zpp/100
endif

do case
	case cVar=="PP"
		nVrati := nCSP*(TARIFA->zpp/100)/nD
	case cVar=="PPU"
		if gUVarPP=="D"
			nVrati := nCSP*(TARIFA->ppp/100)/nD
		else
			nVrati := nCSP*(TARIFA->ppp/100)*(1+TARIFA->opp/100)/nD
		endif
	case cVar=="PPP"
		if gUVarPP=="D" 
			nVrati := nCSP*(TARIFA->opp/100)/((1+TARIFA->opp/100)*nD)
		else
			nVrati := nCSP*(TARIFA->opp/100)/nD
		endif
		
	case cVar=="MPP"
		if gUVarPP=="D"
			nMPVBP := nCSP/((1+TARIFA->opp/100)*nD)
		else
			nMPVBP := nCSP/nD
		endif
		nPom   := nMPVBP-nNV
		nVrati := MAX( nCSP*(TARIFA->dlruc/100)*(TARIFA->mpp/100), TARIFA->mpp*nPom/(100+TARIFA->mpp) )
end case
return nVrati
*}



/*! \fn KontNal(dDatNal)
 *  \brief Kontiranje naloga
 *  \param dDatNal  - datum naloga
 */
 
function KontNal(dDatNal)
*{
local cidfirma,cidvd,cbrdok, lafin, lafin2

O_ROBA
O_FINMAT
O_TRFP2
O_KONCIJ
O_VALUTE

lAFin:=.t.
if lafin
 Beep(1)
 lafin:=Pitanje(,"Formirati FIN nalog?","D")=="D"
endif

cBrNalF:=""

O_NALOG
O_PRIPR

select FINMAT; go top
select trfp2
seek finmat->IdVD+" "
cIdVN:=IdVN   // uzmi vrstu naloga koja ce se uzeti u odnosu na prvu kalkulaciju
             //  koja se kontira

if lAFin
select nalog
seek finmat->idfirma+cidvn+"X"
skip -1
if idvn<>cidvn
     cBrnalF:="0000"
else
     cBrNalF:=brnal
endif
cBrNalF:=NovaSifra(cBrNalF)
select nalog; use
endif

select finmat; go top

Box("brn?",5,55)
//dDatNal:=datdok
set cursor on
  @ m_x+1,m_y+2  SAY "Broj naloga u FIN  "+finmat->idfirma+" - "+cidvn+" -" GET cBrNalF
  @ m_x+5,m_y+2 SAY "(ako je broj naloga prazan - ne vrsi se kontiranje)"
  read; ESC_BCR
BoxC()
nRbr:=0; nRbr2:=0


MsgO("Prenos FAKT -> FIN")

select finmat
private cKonto1:=NIL

do while !eof()    // datoteka finmat

 cIDVD:=IdVD; cBrDok:=BrDok
 if valtype(cKonto1)<>"C"
  private cKonto1:="";cKonto2:="";cKonto3:=""
  private cPartner1:="";cPartner2:=cPartner3:=""
 endif
 do while cIdVD==IdVD .and. cBrDok==BrDok .and. !eof()


     select roba; hseek finmat->idroba

         select trfp2
         seek cIdVD+" "  // nemamo vise sema kontiranja kao u kalk
         do while !empty(cBrNalF) .and. idvd==cIDVD  .and. shema=" " .and. !eof()

          cStavka:=Id
          select finmat
          nIz:=&cStavka
          select trfp2
          if !empty(trfp2->idtarifa) .and. trfp2->idtarifa<>finmat->idtarifa
            // ako u {ifrarniku parametara postoji tarifa prenosi po tarifama
            niz:=0
          endif

          if nIz<>0  // ako je iznos elementa <> 0, dodaj stavku u fpripr

            select pripr

            if trfp2->znak=="-"
              nIz:=-nIz
            endif
               nIz:=round7(nIz,RIGHT(TRFP2->naz,2))  //DEM - pomocna valuta
               nIz2:=nIz

               cIdKonto:=trfp2->Idkonto
            cIdkonto:=STRTRAN(cidkonto,"?1",trim(ckonto1))
            cIdkonto:=STRTRAN(cidkonto,"?2",trim(ckonto2))
            cIdkonto:=STRTRAN(cidkonto,"?3",trim(ckonto3))

            IF "F1" $ cIdKonto
              IF EMPTY(gDzokerF1)
                cPom:=""
              ELSE
                cPom:=&gDzokerF1
              ENDIF
              cIdkonto:=STRTRAN(cidkonto,"F1",cPom)
            ENDIF

            cIdkonto:=padr(cidkonto,7)

            cIdPartner:=space(6)
            if trfp2->Partner=="1"  //  stavi Partnera
                    cidpartner:=FINMAT->IdPartner
            elseif trfp2->Partner=="A"   // stavi  Lice koje se zaduz2
                    cIdpartner:=padr(cPartner1,7)
            elseif trfp2->Partner=="B"   // stavi  Lice koje se zaduz2
                    cIdpartner:=padr(cPartner2,7)
            elseif trfp2->Partner=="C"   // stavi  Lice koje se zaduz2
                    cIdpartner:=padr(cPartner3,7)
            endif

            cBrDok:=space(8)
            dDatDok:=FINMAT->datdok
            if trfp2->Dokument=="1"
                   cBrDok:=FINMAT->brdok
            elseif trfp2->Dokument=="3"
                   dDatDok:=dDatNal
            endif

            fExist:=.f.
            seek FINMAT->IdFirma+cidvn+cBrNalF
            if found()
             fExist:=.f.
             do while FINMAT->idfirma+cidvn+cBrNalF==IdFirma+idvn+BrNal
               if IdKonto==cIdKonto .and. IdPartner==cIdPartner .and.;
                  trfp2->d_p==d_p  .and. idtipdok==FINMAT->idvd .and.;
                  padr(brdok,10)==padr(cBrDok,10) .and. datdok==dDatDok
                  // provjeriti da li se vec nalazi stavka koju dodajemo
                 fExist:=.t.
                 exit
               endif
               skip
             enddo
             if !fExist
               go bottom
               nRbr:=val(Rbr)+1; append blank
             endif
            else
             go bottom
             nRbr:=val(rbr)+1
             append blank
            endif

            replace iznosDEM with iznosDEM+nIz,;
                    iznosBHD with iznosBHD+nIz2,;
                    idKonto  with cIdKonto,;
                    IdPartner  with cIdPartner,;
                    D_P      with trfp2->d_P,;
                    idFirma  with FINMAT->idfirma,;
                    IdVN     with cidvn,;
                    BrNal    with cBrNalF,;
                    IdTipDok with FINMAT->IdVD,;
                    BrDok    with cBrDok,;
                    DatDok   with dDatDok,;
                    opis     with trfp2->naz

             if !fExist
                replace Rbr  with str(nRbr,4)
             endif

           endif // nIz <>0

           select trfp2
           skip
         enddo // trfp2->id==cIDVD


  select FINMAT
  skip
 enddo

enddo

if lAFin
// fpripr ******* zaokruzi

select pripr; go top
do while !eof()
  cPom:=right(trim(opis),1)
  // na desnu stranu opisa stavim npr "ZADUZ MAGACIN          0"
  // onda ce izvrsiti zaokruzenje na 0 decimalnih mjesta
  if cPom $ "0125"
       nLen:=len(trim(opis))
       replace opis with left(trim(opis),nLen-1)
       replace iznosbhd with round(iznosbhd,IF(VAL(cPom)==0.and.cPom!="0",2,val(cPom)))
       replace iznosdem with round(iznosdem,IF(VAL(cPom)==0.and.cPom!="0",2,val(cPom)))
       if cPom="5"
         replace iznosbhd with round2(iznosbhd,2)
         replace iznosdem with round2(iznosdem,2)
       endif
  endif // cpom
  skip
enddo //fpripr

endif // lafin , lafin2

MsgC()

closeret
return
*}


/*! \fn ParsMemo(cTxt)
 *  \brief Pretvara tekst u niz
 *  \param cTxt   - zadati tekst
 */
 
function ParsMemo(cTxt)
*{
local aMemo:={}
local i,cPom,fPoc

 fPoc:=.f.
 cPom:=""
 for i:=1 to len(cTxt)
   if  substr(cTxt,i,1)==Chr(16)
     fPoc:=.t.
   elseif  substr(cTxt,i,1)==Chr(17)
     fPoc:=.f.
     AADD(aMemo,cPom)
     cPom:=""
   elseif fPoc
      cPom:=cPom+substr(cTxt,i,1)
   endif
 next

return aMemo
*}


/*! \fn Round7(nBroj,cTip)
 *  \brief Zaokruzivanje
 *  \param nBroj - Zadati broj
 *  \param cTip  - cTip je string sa dva znaka od kojih prvi uslovljava da li ce se izvrsiti zaokruzivanje, a drugi predstavlja broj decimala na koji ce se izvrsiti zaokruzivanje. Zaokruzivanje se vrsi uvijek izuzev ako je taj prvi znak "." */

function Round7(nBroj,cTip)
*{
LOCAL cTip1:="", cTip2:=""
 AltD()
 cTip1:=LEFT(cTip,1)
 cTip2:=RIGHT(cTip,1)
 IF cTip1!="."
   IF cTip1==";"
     nBroj := ROUND( nBroj , VAL(cTIp2) )
   ELSE
     nBroj := ROUND( nBroj , 2 )
   ENDIF
 ENDIF
RETURN nBroj
*}


/*! \fn RasKon(cRoba,aSifre,aKonta)
 *  \brief Trazi poziciju cRoba u aSifre i ako nadje vraca element iz aKonta koji je na nadjenoj poziciji
 *  \param cRoba
 *  \param aSifre
 *  \param aKonta
 */
 
function RasKon(cRoba,aSifre,aKonta)
*{
local nPom
nPom:=ASCAN(aSifre,cRoba)

return if(nPom>0,aKonta[nPom],"")
*}



/*! \fn PrStopa(nProc)
 *  \brief  Preracunata stopa
 *  \nProc - Broj
 */
 
function PrStopa(nProc)
*{
return (if(nProc==0,0,1/(1+1/(nProc/100))))
*}



/*! \fn IzKalk(cIdRoba,cKonSir,cSta)
 *  \brief
 *  \param cIdRoba
 *  \param cKonSir
 *  \param cSta
 */
 
function IzKalk(cIdRoba,cKonSir,cSta)
*{
local x:=0, nArr:=SELECT(), nNV, nUlaz, nIzlaz
  SELECT KALK
  DO CASE
    CASE cSta=="NC"
      // "idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD"
      SET ORDER TO TAG "3"
      SEEK gFirma+cKonSir+cIdRoba
      nNV:=nUlaz:=nIzlaz:=0
      DO WHILE !EOF() .and. idfirma+mkonto+idroba==gFirma+cKonSir+cIdRoba
        if mu_i=="1" .and. !(idvd $ "12#22#94")
          nUlaz  += kolicina-gkolicina-gkolicin2
          nNV    += nc*(kolicina-gkolicina-gkolicin2)
        elseif mu_i=="5"
          nIzlaz += kolicina
          nNV    -= nc*(kolicina)
        elseif mu_i=="1" .and. (idvd $ "12#22#94")    // povrat
          nIzlaz -= kolicina
          nNV    += nc*(kolicina)
        endif
        SKIP 1
      ENDDO
      IF nUlaz-nIzlaz<>0
        x := nNV/(nUlaz-nIzlaz)
      ENDIF
      IF x<=0
        MsgBeep( "GRESKA! Artikal:"+cIdRoba+", konto:"+cKonSir+", NC="+STR(x)+" !?"+;
                 "#FAKT dok.:"+FAKT->(idfirma+"-"+idtipdok+"-"+brdok)+", stavka br."+FAKT->rbr+;
                 "#Proizvod:"+FAKT->idroba )
      ENDIF
  ENDCASE
  SELECT (nArr)
RETURN x
*}

