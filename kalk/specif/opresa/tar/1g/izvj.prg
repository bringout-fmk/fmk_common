#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/opresa/tar/1g/izvj.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: izvj.prg,v $
 * Revision 1.2  2002/06/24 09:07:04  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/specif/opresa/tar/1g/izvj.prg
 *  \brief Izvjestaji
 */

/*! \fn IzvjTar()
 *  \brief Menij izvjestaja
 */
 
function IzvjTar()
*{
private Opc:={}
private opcexe:={}

  AADD(Opc,"1. kartica                                ")
  AADD(opcexe, {|| Kart41_42()})
  AADD(Opc,"2. kartica v2 (uplata,obaveza,saldo)")
  AADD(opcexe, {|| Kart412v2()})
  AADD(Opc,"5. realizovani porez")
  AADD(opcexe, {|| RekRPor})

private Izbor:=1
Menu_SC("itar")
return .f.
*}


/*! \fn Kart41_42()
 *  \brief Kartica za varijantu "vodi samo tarife", 41-avans, 42-obracun
 *  \param
 */

function Kart41_42()
*{
local PicCDEM:=gPicCDEM
 local PicProc:=gPicProc
 local PicDEM:= gPicDem
 local Pickol:= "@Z "+gpickol

 O_TARIFA
 if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK; O_SIFV
 endif
 O_ROBA
 O_KONTO

 dDatOd:=ctod("")
 dDatDo:=date()

 O_PARTN

 cIdFirma:=gFirma
 cIdRoba:=space(10)
 cidKonto:=padr("1320",7)
 cPredh:="N"

 
 O_PARAMS
 cBrFDa:="N"
 Private cSection:="4",cHistory:=" ",aHistory:={}
 Params1()
 RPar("c1",@cidroba); RPar("c2",@cidkonto); RPar("c3",@cPredh)
 RPar("d1",@dDatOd); RPar("d2",@dDatDo)
 RPar("c4",@cBrFDa)


 Box(,6,50)
  if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  else
   @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
  endif
  @ m_x+2,m_y+2 SAY "Konto " GET cIdKonto VALID P_Konto(@cIdKonto)
  @ m_x+3,m_y+2 SAY "Roba  " GET cIdRoba  VALID EMPTY(cidroba) .or. P_Roba(@cIdRoba) PICT "@!"
  @ m_x+5,m_y+2 SAY "Datum od " GET dDatOd
  @ m_x+5,col()+2 SAY "do" GET dDatDo
  @ m_x+6,m_y+2 SAY "sa prethodnim prometom (D/N)" GET cPredh pict "@!" valid cpredh $ "DN"
  read; ESC_BCR
 BoxC()

 if empty(cidroba) .or. cIdroba=="SIGMAXXXXX"
    if pitanje(,"Niste zadali sifru artikla, izlistati sve kartice ?","N")=="N"
       closeret
    else
       if !empty(cidroba)
           if Pitanje(,"Korekcija nabavnih cijena ???","N")=="D"
              fKNabC:=.t.
           endif
       endif
       cIdr:=""
    endif
 else
    cIdr:=cidroba
 endif

 
 if Params2()
  WPar("c1",cidroba); WPar("c2",cidkonto); WPar("c3",cPredh)
  WPar("d1",dDatOd); WPar("d2",dDatDo)
  WPar("c4",@cBrFDa)
 endif
 select params; use


 O_KALK
 nKolicina:=0
 select kalk
 set order to tag "4"
 // idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD
 // hseek cidfirma+cidkonto+cidroba
 hseek cidfirma+cidkonto+cidr
 EOF CRET

 gaZagFix:={7,4}
 START PRINT CRET

 nLen:=1

 m:="-------- ----------- ------ ------ ---------- ---------- ---------- ----------"

 nTStrana:=0
 Zagl2()

 nCol1:=10
 fPrviProl:=.t.

 DO WHILE !EOF() .and. idFirma+pkonto+idroba=cidfirma+cidkonto+cidr

   cidroba:=idroba
   select roba; hseek cidroba
   select tarifa; hseek roba->idtarifa
   ? m
   ? "Artikal:",cidroba,"-",trim(roba->naz)+" ("+roba->jmj+")"
   ? m
   select kalk

   nAv:=nAvS:=nOb:=nObS:=0

   DO WHILE !EOF() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba

     if datdok<ddatod .and. cPredh=="N"
        skip; loop
     endif
     if datdok>ddatdo .or. ! ( idvd $ "41#42" )
        skip; loop
     endif

     if cPredh=="D" .and. datdok>=dDatod .and. fPrviProl
       //********************* ispis prethodnog stanja ***************
       fPrviprol:=.f.
       ? "Stanje do ",ddatod

       @ prow(),      35 SAY nAvS         pict picdem
       @ prow(),pcol()+1 SAY nAvS         pict picdem
       @ prow(),pcol()+1 SAY nObS         pict picdem
       @ prow(),pcol()+1 SAY nObS         pict picdem
       //********************* ispis prethodnog stanja ***************
     endif

     if prow()-gPStranica>62; FF; Zagl2();endif

     if idvd=="41"    // avans
       nAv  := kolicina * MPCsaPP
       nAvS += nAv
       if datdok>=ddatod
        ? datdok,idvd+"-"+brdok,idtarifa,idpartner
        nCol1:=pcol()+1
        @ prow(),pcol()+1 SAY nAv       pict picdem
        @ prow(),pcol()+1 SAY nAvS      pict picdem
       endif
     else                          // 42 - obracun
       nAv:=0; aOb:=0
       cKalk:=idvd+brdok
       DO WHILE !EOF() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba .and.;
                cKalk==idvd+brdok
         if kolicina>0
           nOb += kolicina * MPCsaPP
         else
           nAv += kolicina * MPCsaPP
         endif
         SKIP 1
       ENDDO
       SKIP -1
       nObS += nOb
       nAvS += nAv
       if datdok>=ddatod
         ? datdok,idvd+"-"+brdok,idtarifa,idpartner
         nCol1:=pcol()+1
         @ prow(),pcol()+1 SAY nAv       pict picdem
         @ prow(),pcol()+1 SAY nAvS      pict picdem
         @ prow(),pcol()+1 SAY nOb       pict picdem
         @ prow(),pcol()+1 SAY nObS      pict picdem
       endif
     endif

     SKIP 1    // KALK
   ENDDO

   if cPredh=="D" .and. fPrviProl
     //********************* ispis prethodnog stanja ***************
     ? "Stanje do ",ddatod

     @ prow(),      35 SAY nAvS         pict picdem
     @ prow(),pcol()+1 SAY nAvS         pict picdem
     @ prow(),pcol()+1 SAY nObS         pict picdem
     @ prow(),pcol()+1 SAY nObS         pict picdem
     //********************* ispis prethodnog stanja ***************
   endif

   ? m
   ? "Iznosi predstavljaju maloprodajnu vrijednost sa ukalkulisanim porezima!"
   ? m

   ?
   ?
   fPrviProl:=.t.

 ENDDO
 FF
 END PRINT
CLOSERET
*}



/*! \fn Zagl2()
 *  \brief Zaglavlje izvjestaja
 */
 
static function Zagl2()
*{
select konto; hseek cidkonto

Preduzece()
P_12CPI
?? "KARTICA za period",ddatod,"-",ddatdo,space(10),"Str:",str(++nTStrana,3)
? "Konto: ",cidkonto,"-",konto->naz
select kalk
P_COND
? m
? "                                                SALDO                 SALDO   "
? " Datum     Dokument  Tarifa  Partn   AVANS      AVANSA    OBRACUN    OBRACUNA "
? m
return (nil)
*}



/*! \fn Kart412v2()
 *  \brief Kartica za varijantu "vodi samo tarife" varijanta 2
 *  \param
 */
 
function Kart412v2()
*{
local PicCDEM:=gPicCDEM
 local PicProc:=gPicProc
 local PicDEM:= gPicDem
 local Pickol:= "@Z "+gpickol

 O_TARIFA
 if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK; O_SIFV
 endif
 O_ROBA
 O_KONTO

 dDatOd:=ctod("")
 dDatDo:=date()


 O_PARTN

 cIdFirma:=gFirma
 cIdRoba:=space(10)
 cidKonto:=padr("1320",7)
 cPredh:="N"

 O_PARAMS
 cBrFDa:="N"
 Private cSection:="4",cHistory:=" ",aHistory:={}
 Params1()
 RPar("c1",@cidroba); RPar("c2",@cidkonto); RPar("c3",@cPredh)
 RPar("d1",@dDatOd); RPar("d2",@dDatDo)
 RPar("c4",@cBrFDa)

 Box(,6,50)
  if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  else
   @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
  endif
  @ m_x+2,m_y+2 SAY "Konto " GET cIdKonto VALID P_Konto(@cIdKonto)
  @ m_x+3,m_y+2 SAY "Roba  " GET cIdRoba  VALID EMPTY(cidroba) .or. P_Roba(@cIdRoba) PICT "@!"
  @ m_x+5,m_y+2 SAY "Datum od " GET dDatOd
  @ m_x+5,col()+2 SAY "do" GET dDatDo
  @ m_x+6,m_y+2 SAY "sa prethodnim prometom (D/N)" GET cPredh pict "@!" valid cpredh $ "DN"
  read; ESC_BCR
 BoxC()

 if empty(cidroba) .or. cIdroba=="SIGMAXXXXX"
    if pitanje(,"Niste zadali sifru artikla, izlistati sve kartice ?","N")=="N"
       closeret
    else
       if !empty(cidroba)
           if Pitanje(,"Korekcija nabavnih cijena ???","N")=="D"
              fKNabC:=.t.
           endif
       endif
       cIdr:=""
    endif
 else
    cIdr:=cidroba
 endif

 if Params2()
  WPar("c1",cidroba); WPar("c2",cidkonto); WPar("c3",cPredh)
  WPar("d1",dDatOd); WPar("d2",dDatDo)
  WPar("c4",@cBrFDa)
 endif
 select params; use

 O_KALK
 nKolicina:=0
 select kalk
 set order to tag "4"
 // idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD
 // hseek cidfirma+cidkonto+cidroba
 hseek cidfirma+cidkonto+cidr
 EOF CRET

 gaZagFix:={7,4}
 START PRINT CRET

 nLen:=1

 m:="-------- ----------- ------ ---------- -------- ------ ---------- ---------- ---------- ----------"

 nTStrana:=0
 Zagl3()

 nCol1:=10
 fPrviProl:=.t.

 do while !eof() .and. idFirma+pkonto+idroba=cidfirma+cidkonto+cidr

   cidroba:=idroba
   select roba; hseek cidroba
   select tarifa; hseek roba->idtarifa
   ? m
   ? "Artikal:",cidroba,"-",trim(roba->naz)+" ("+roba->jmj+")"
   ? m
   select kalk

   // nAv:=nAvS:=nOb:=nObS:=0
   nOsn:=nTotOsn:=0
   nUpl:=nTotUpl:=0
   nObv:=nTotObv:=0

   do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba

     if datdok<ddatod .and. cPredh=="N"
        skip; loop
     endif
     if datdok>ddatdo .or. ! ( idvd $ "41#42" )
        skip; loop
     endif

     if cPredh=="D" .and. datdok>=dDatod .and. fPrviProl
       //********************* ispis prethodnog stanja ***************
       fPrviprol:=.f.
       ? "Stanje do ",ddatod

       @ prow(),      55 SAY nTotOsn         pict picdem
       @ prow(),pcol()+1 SAY nTotUpl         pict picdem
       @ prow(),pcol()+1 SAY nTotObv         pict picdem
       @ prow(),pcol()+1 SAY nTotUpl-nTotObv pict picdem
       //********************* ispis prethodnog stanja ***************
     endif

     if prow()-gPStranica>62; FF; Zagl3();endif

     if idvd=="41"    // avans
       nOsn := kolicina * MPCsaPP
       nTotOsn += nOsn
       nUpl := kolicina*(mpcsapp-mpc)
       nTotUpl += nUpl
       if datdok>=ddatod
        IF IzFMKIni("VodiSamoTarife","KarticaV2_KALK41_BezDatumaIBrojaFakture","N",KUMPATH)=="D"
          ? datdok,idvd+"-"+brdok,idtarifa,SPACE(10),SPACE(8),idpartner
        ELSE
          ? datdok,idvd+"-"+brdok,idtarifa,brfaktp,datfaktp,idpartner
        ENDIF
        nCol1:=pcol()+1
        @ prow(),pcol()+1 SAY nOsn            pict picdem
        @ prow(),pcol()+1 SAY nUpl            pict picdem
        @ prow(),pcol()+1 SAY 0               pict "@Z"+picdem
        @ prow(),pcol()+1 SAY nTotUpl-nTotObv pict picdem
       endif
     else                          // 42 - obracun
       nOsn:=nUpl:=nObv:=0
       aStavke:={}
       cKalk:=idvd+brdok
       do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba .and.;
                cKalk==idvd+brdok
         if kolicina>0
           nObv += kolicina*(MPCsaPP-MPC)
           AADD(aStavke,{0,0,kolicina*(MPCsaPP-MPC),nTotUpl-nTotObv-nObv,brfaktp,datfaktp})
         else
           nUpl += kolicina*(MPCsaPP-MPC)
         endif
         nOsn += kolicina*MPCsaPP
         skip 1
       enddo
       skip -1
       nUpl := MAX(nObv+nUpl,0)     // ovdje se dobija stvarna uplata!
       nTotUpl += nUpl
       nOsn := MAX(nOsn,0)          // ovdje se dobija stvarna osnovica!
       nTotOsn += nOsn
       nTotObv += nObv
       IF nUpl>0
         AADD(aStavke,{nOsn,nUpl,0,nTotUpl-nTotObv,SPACE(10),SPACE(8)})
       ENDIF
       if datdok>=ddatod
         IF IzFMKINI("VodiSamoTarife","SvakaStavkaNaKarticu","D",KUMPATH)=="D"
           FOR i:=1 TO LEN(aStavke)
             ? datdok,idvd+"-"+brdok,idtarifa,aStavke[i,5],aStavke[i,6],idpartner
             nCol1:=pcol()+1
             @ prow(),pcol()+1 SAY aStavke[i,1]    pict picdem
             @ prow(),pcol()+1 SAY aStavke[i,2]    pict picdem
             @ prow(),pcol()+1 SAY aStavke[i,3]    pict picdem
             @ prow(),pcol()+1 SAY aStavke[i,4]    pict picdem
           NEXT
         ELSE
           ? datdok,idvd+"-"+brdok,idtarifa,brfaktp,datfaktp,idpartner
           nCol1:=pcol()+1
           @ prow(),pcol()+1 SAY nOsn            pict picdem
           @ prow(),pcol()+1 SAY nUpl            pict picdem
           @ prow(),pcol()+1 SAY nObv            pict picdem
           @ prow(),pcol()+1 SAY nTotUpl-nTotObv pict picdem
         ENDIF
       endif
     endif

     skip 1    // kalk
   enddo

   if cPredh=="D" .and. fPrviProl  // nema prometa, ali ima prethodno stanje
     ? "Stanje do ",ddatod
   else  // total
     ? m
     ? "UKUPNO:"
   endif
   @ prow(),      55 SAY nTotOsn         pict picdem
   @ prow(),pcol()+1 SAY nTotUpl         pict picdem
   @ prow(),pcol()+1 SAY nTotObv         pict picdem
   @ prow(),pcol()+1 SAY nTotUpl-nTotObv pict picdem
   ? m; ?; ?
   fPrviProl:=.t.
   nTotOsn:=nTotUpl:=nTotObv:=0

 enddo
 FF
 END PRINT
CLOSERET
*}



/*! \fn Zagl3()
 *  \brief Zaglavlje izvjestaja
 */
 
static function Zagl3()
*{
select konto; hseek cidkonto

Preduzece()
P_12CPI
?? "KARTICA za period",ddatod,"-",ddatdo,space(10),"Str:",str(++nTStrana,3)
? "Konto: ",cidkonto,"-",konto->naz
select kalk
P_COND
? m
? "                                F A K T U R A           MPV+POREZ   UPLATA    OBAVEZA      SALDO  "
? " Datum     Dokument  Tarifa     Broj    Datum    Partn   (osnov)    POREZA    (POREZ)     UPL-OBAV"
? m
return (nil)
*}


