#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/razdb/1g/fin.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: fin.prg,v $
 * Revision 1.5  2002/11/22 10:37:04  mirsad
 * sredjivanje makroa za oblasti - ukidanje starog sistema
 *
 * Revision 1.4  2002/06/24 09:19:02  mirsad
 * dokumentovanje
 *
 * Revision 1.3  2002/06/21 14:08:29  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/razdb/1g/fin.prg
 *  \brief Generacija FIN-dokumenata na osnovu kalkulacija (kontiranje)
 */


/*! \fn P_Fin()
 *  \brief Centralna funkcija za formiranje i stampu FIN-naloga
 */

function P_Fin()
*{
private gDatNal:="N",gRavnot:="D",cDatVal:="D",gnLOst:=0
if gafin=="D"
 #ifdef CAX
   close all
 #endif
 KZbira()
 StNal()
 Azur()
endif
return
*}




/*! \fn StNal()
 *  \brief Centralna funkcija za stampu FIN-naloga
 */

static function StNal()
*{
private dDatNal:=date()
StAnalNal()
//StSintNal()
SintStav()
return
*}




/*! \fn StAnalNal()
 *  \brief Stampanje analitickog naloga
 */

static function StAnalNal()
*{
FO_PRIPR
O_KONTO
O_PARTN
O_TNAL
O_TDOK
FO_PSUBAN

PicBHD:="@Z 999999999999.99"
PicDEM:="@Z 9999999.99"
gVar1:=2

M:="---- ------- ------ ---------------------------- ----------- -------- -------- --------------- ---------------"+IF(gVar1==1,"-"," ---------- ----------")

select PSUBAN; ZAP

SELECT PRIPR; set order to 1;go top
if eof(); closeret2; endif

nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
DO WHILE !EOF()
   cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal

   Box("",2,50)
     set cursor on
     @ m_x+1,m_y+2 SAY "Finansijski nalog broj:" GET cIdFirma
     @ m_x+1,col()+1 SAY "-" GET cIdVn
     @ m_x+1,col()+1 SAY "-" GET cBrNal
     if gDatNal=="D"
      @ m_x+2,m_y+2 SAY "Datum naloga:" GET dDatNal
     endif
     read; ESC_BCR
   BoxC()

   HSEEK cIdFirma+cIdVN+cBrNal
   if eof(); closeret2; endif

   START PRINT CRET
   nStr:=0
   nUkDug:=nUkPot:=0
   b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}

   //cVN:=VN; cFirma:=Firma1+Firma2

   cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal
   Zagl11()
   DO WHILE !eof() .and. eval(b2)

         if prow()>61+gPStranica
	 	FF
	 	Zagl11()
	 endif
         P_NRED
         @ prow(),0 SAY RBr
         @ prow(),pcol()+1 SAY IdKonto

         if !empty(IdPartner)
           select PARTN; hseek PRIPR->idpartner
           cStr:=trim(naz)+" "+trim(naz2)
         else
           select KONTO;  hseek PRIPR->idkonto
           cStr:=naz
         endif
         select PRIPR

         aRez:=SjeciStr(cStr,28)

         @ prow(),pcol()+1 SAY IdPartner

         nColStr:=PCOL()+1
         @  prow(),pcol()+1 SAY padr(aRez[1],28) // dole cu nastaviti

      nColDok:=PCOL()+1
      @ prow(),pcol()+1 SAY padr(BrDok,11)
      @ prow(),pcol()+1 SAY DatDok
      if cDatVal=="D"
       @ prow(),pcol()+1 SAY DatVal
      else
       @ prow(),pcol()+1 SAY space(8)
      endif

      nColIzn:=pcol()+1
      IF D_P=="1"
         @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
         @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
         nUkDugBHD+=IznosBHD
      ELSE
         @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
         @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
         nUkPotBHD+=IznosBHD
      ENDIF

      IF gVar1!=1
       if D_P=="1"
          @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
          @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
          nUkDugDEM+=IznosDEM
       else
          @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
          @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
          nUkPotDEM+=IznosDEM
       endif
      ENDIF
      Pok:=0
      for i:=2 to len(aRez)
        P_NRED
        @ prow(),nColStr say aRez[i]
        If i=2
           @ prow(),nColDok say opis
           if !Empty(k1+k2+k3+k4)
             ?? " "+k1+"-"+k2+"-"+k3+"-"+k4
           endif
           Pok:=1
        endif
      next
      If Pok=0 .and. !Empty(opis+k1+k2+k3+k4)
         P_NRED
         @ prow(),nColDok say opis+" "+k1+"-"+k2+"-"+k3+"-"+k4
      endif

         select PSUBAN; Scatter(); select PRIPR; Scatter()

         SELECT PSUBAN
         APPEND BLANK
         Gather()  // stavi sve vrijednosti iz PRIPR u PSUBAN
         select PRIPR
         SKIP
      ENDDO

      IF prow()>59+gPStranica; FF; Zagl11();  endif

      ? M
      ? "Z B I R   N A L O G A:"
      @ prow(),nColIzn SAY nUkDugBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
      @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM
      ? M

      nUkDugBHD:=nUKPotBHD:=nUkDugDEM:=nUKPotDEM:=0

     if gPotpis=="D"
      IF prow()>58+gPStranica; FF; Zagl11();  endif
      ?
      ?; P_12CPI
      @ prow()+1,55 SAY "Obrada AOP "; ?? replicate("_",20)
      @ prow()+1,55 SAY "Kontirao   "; ?? replicate("_",20)
    endif
    FF
    END PRINT

ENDDO   // eof()

closeret2
return
*}




/*! \fn Zagl11()
 *  \brief Zaglavlje analitickog naloga
 */

function Zagl11()
*{
local nArr
P_COND
B_ON
?? UPPER(gTS)+":",gNFirma
?
nArr:=select()
if gNW=="N"
   select partn; hseek cidfirma; select (nArr)
   ? cidfirma,"-",partn->naz
endif
?
? "FIN.P: NALOG ZA KNJIZENJE BROJ :"
@ prow(),PCOL()+2 SAY cIdFirma+" - "+cIdVn+" - "+cBrNal
B_OFF
if gDatNal=="D"
 @ prow(),pcol()+4 SAY "DATUM: "
 ?? dDatNal
endif

select TNAL; hseek cidvn
@ prow(),pcol()+4 SAY naz
@ prow(),pcol()+15 SAY "Str:"+str(++nStr,3)
P_NRED; ?? M
P_NRED; ?? "*R. * KONTO * PART *    NAZIV PARTNERA ILI      *   D  O  K  U  M  E  N  T    *         IZNOS U  "+ValDomaca()+"         *    IZNOS U "+ValPomocna()+"    *"
P_NRED; ?? "              NER                                ----------------------------- ------------------------------- ---------------------"
P_NRED; ?? "*BR *       *      *    NAZIV KONTA             * BROJ VEZE * DATUM  * VALUTA *  DUGUJE "+ValDomaca()+"  * POTRAZUJE "+ValDomaca()+"* DUG. "+ValPomocna()+"* POT."+ValPomocna()+"*"
P_NRED; ?? M
select(nArr)
return
*}




/*! \fn SintStav()
 *  \brief Formiranje sintetickih stavki
 */

static function SintStav()
*{
FO_PSUBAN
FO_PANAL
FO_PSINT
FO_PNALOG
O_KONTO
O_TNAL

select PANAL; zap
select PSINT; zap
select PNALOG; zap

select PSUBAN; set order to 2; go top
if empty(BrNal); closeret2; endif

A:=0
DO WHILE !eof()   // svi nalozi

   nStr:=0
   nD1:=nD2:=nP1:=nP2:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal

   DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog

         cIdkonto:=idkonto

         nDugBHD:=nDugDEM:=0
         nPotBHD:=nPotDEM:=0
         IF D_P="1"
               nDugBHD:=IznosBHD; nDugDEM:=IznosDEM
         ELSE
               nPotBHD:=IznosBHD; nPotDEM:=IznosDEM
         ENDIF

         SELECT PANAL     // analitika
         seek cidfirma+cidvn+cbrnal+cidkonto
         fNasao:=.f.
         DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                    .and. IdKonto==cIdKonto
           if gDatNal=="N"
              if month(psuban->datdok)==month(datnal)
                fNasao:=.t.
                exit
              endif
           else  // sintetika se generise na osnovu datuma naloga
              if month(dDatNal)==month(datnal)
                fNasao:=.t.
                exit
              endif
           endif
           skip
         enddo
         if !fNasao
            append blank
         endif

         REPLACE IdFirma WITH cIdFirma,IdKonto WITH cIdKonto,IdVN WITH cIdVN,;
                 BrNal with cBrNal,;
                 DatNal WITH iif(gDatNal=="D",dDatNal,max(psuban->datdok,datnal)),;
                 DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
                 DugDEM WITH DugDEM+nDugDEM, PotDEM WITH PotDEM+nPotDEM


         
         SELECT PSINT
         seek cidfirma+cidvn+cbrnal+left(cidkonto,3)
         fNasao:=.f.
         DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                   .and. left(cidkonto,3)==idkonto
           if gDatNal=="N"
            if  month(psuban->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
           else // sintetika se generise na osnovu dDatNal
              if month(dDatNal)==month(datnal)
                fNasao:=.t.
                exit
              endif
           endif

           skip
         enddo
         if !fNasao
             append blank
         endif

         REPLACE IdFirma WITH cIdFirma,IdKonto WITH left(cIdKonto,3),IdVN WITH cIdVN,;
              BrNal WITH cBrNal,;
              DatNal WITH iif(gDatNal=="D", dDatNal,  max(psuban->datdok,datnal) ),;
              DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
              DugDEM WITH DugDEM+nDugDEM,PotDEM WITH PotDEM+nPotDEM

         nD1+=nDugBHD; nD2+=nDugDEM; nP1+=nPotBHD; nP2+=nPotDEM

        SELECT PSUBAN
        skip
   ENDDO  // nalog

   SELECT PNALOG    // datoteka naloga
   APPEND BLANK
   REPLACE IdFirma WITH cIdFirma,IdVN WITH cIdVN,BrNal WITH cBrNal,;
           DatNal WITH iif(gDatNal=="D",dDatNal,date()),;
           DugBHD WITH nD1,PotBHD WITH nP1,;
           DugDEM WITH nD2,PotDEM WITH nP2

   private cDN:="N"

   SELECT PSUBAN

ENDDO  // svi nalozi

select PANAL
go top
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo

select PSINT
go top
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo

closeret2
return
*}




/*! \fn Azur()
 *  \brief Azuriranje knjizenja
 */

static function Azur()
*{
FO_PRIPR
FO_SUBAN
FO_ANAL
FO_SINT
FO_NALOG

FO_PSUBAN
FO_PANAL
FO_PSINT
FO_PNALOG

fAzur:=.t.
select PSUBAN; if reccount2()==0; fAzur:=.f.; endif
select PANAL; if reccount2()==0; fAzur:=.f.; endif
select PSINT; if reccount2()==0; fAzur:=.f.; endif
if !fAzur
 //*   Beep(3)
 //*   Msg("Niste izvrsili stampanje naloga ...",10)
 closeret2
endif

if pitanje(,"Izvrsiti azuriranje FIN naloga ?","D")=="N"
 closeret2
endif

Box(,5,60)
select PSUBAN; set order to 1; go top

do while !eof()
// prodji kroz PSUBAN i vidi da li je nalog zatvoren
// samo u tom slucaju proknjizi nalog u odgovarajuce datoteke

cNal:=IDFirma+IdVn+BrNal
@ m_x+1,m_y+2 SAY "Auzriram nalog: "+IdFirma+"-"+idvn+"-"+brnal
nSaldo:=0
do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    if D_P=="1"
       nSaldo+=IznosBHD
    else
       nSaldo-=IznosBHD
    endif
    skip
enddo

if round(nSaldo,4)==0  .or. gRavnot=="N" // nalog je uravnote`en, a`uriraj ga !

  if !( SUBAN->(flock()) .and. ANAL->(flock()) .and.  SINT->(flock()) .and.  NALOG->(flock())  )
    Beep(4)
    BoxC()
    Msg("Azuriranje NE moze vrsiti vise korisnika istovremeno !")
    closeret2
  endif

  @ m_x+3,m_y+2 SAY "NALOZI         "
  select  NALOG
  seek cNal
  if found(); BoxC(); Msg("Vec postoji proknjizen nalog "+IdFirma+"-"+IdVn+"-"+BrNal+ "  !"); closeret2; endif

  select PNALOG; seek cNal
  if found()
    Scatter()
    _sifra:=sifrakorisn
    select NALOG; append ncnl ; Gather2()
  else
    Beep(4)
    Msg("Greska... ponovi stampu naloga ...")
  endif

  
  * nalog je uravnote`en, mo`e se izbrisati iz PRIPR
  
  select PRIPR; seek cNal
  @ m_x+3,m_y+2 SAY "BRISEM PRIPREMU "
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    skip; ntRec:=RECNO(); skip -1; dbdelete2(); go ntRec
  enddo

  
  @ m_x+3,m_y+2 SAY "SUBANALITIKA   "
  select PSUBAN; seek cNal
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal

    Scatter()
    if _d_p=="1"; nSaldo:=_IznosBHD; else; nSaldo:= -_IznosBHD; endif

    SELECT SUBAN; set order to 3
    SEEK _IdFirma+_IdKonto+_IdPartner+_BrDok    // isti dokument

    nRec:=recno()
    do while  !eof() .and. (_IdFirma+_IdKonto+_IdPartner+_BrDok)== (IdFirma+IdKonto+IdPartner+BrDok)
       if d_P=="1"; nSaldo+= IznosBHD; else; nSaldo -= IznosBHD; endif
       skip
    enddo

    if abs(nSaldo)<=gnLOSt
      go nRec
      do while  !eof() .and. (_IdFirma+_IdKonto+_IdPartner+_BrDok)== (IdFirma+IdKonto+IdPartner+BrDok)
        _field->OtvSt:="9"
        skip
      enddo
      _OtvSt:="9"
    endif

    append ncnl; Gather2()

    select PSUBAN; skip
  enddo

  
  @ m_x+3,m_y+2 SAY "ANALITIKA       "
  select PANAL; seek cNal
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    Scatter()
    select ANAL; append ncnl; Gather2()
    select PANAL; skip
  enddo

  
  @ m_x+3,m_y+2 SAY "SINTETIKA       "
  select PSINT; seek cNal
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    Scatter()
    select SINT; append ncnl; Gather2()
    select PSINT; skip
  enddo


endif // saldo == 0

select PSUBAN
enddo

select PRIPR; __dbpack()
select PSUBAN; zap
select PANAL; zap
select PSINT; zap
select PNALOG; zap
BoxC()

closeret2
return
*}





/*! \fn StOSNal(fkum)
 *  \brief Stampa sintetickog naloga
 *  \param fkum - .t. stampa naloga iz anal.dbf, .f. stampa naloga iz panal.dbf
 */

static function StOSNal(fkum)
*{
if fkum==NIL
  fkum:=.t.
endif

PicBHD:='@Z 99999999999999.99'
PicDEM:='@Z 999999999.99'
M:="---- -------- ------- --------------------------------------------- ----------------- ----------------- ------------ ------------"

if fkum  // stampa starog naloga - naloga iz kumulativa - datoteka anal
 select (F_ANAL)
 use anal index anali2 alias PANAL  // alias !!!!
 O_KONTO
 O_PARTN
 O_TNAL
 FO_NALOG

 cIdFirma:=cIdVN:=space(2)
 cBrNal:=space(4)

 Box("",1,35)
  @ m_x+1,m_y+2 SAY "Nalog:" GET cIdFirma
  @ m_x+1,col()+1 SAY "-" GET cIdVN
  @ m_x+1,col()+1 SAY "-" GET cBrNal
  read; ESC_BCR
 BoxC()
 select nalog
 seek cidfirma+cidvn+cbrnal
 NFOUND CRET  // ako ne postoji
 dDatNal:=datnal

 select PANAL
 seek cidfirma+cidvn+cbrNal
 START PRINT CRET

else
 cIdFirma:=idfirma; cidvn:=idvn; cBrNal:=brnal
 seek cidfirma+cidvn+cbrNal
 START PRINT RET
endif

nStr:=0
b1:={|| !eof()}

nCol1:=70

 cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
 b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
 b3:={|| cIdSinKon==LEFT(IdKonto,3)}
 b4:={|| cIdKonto==IdKonto}
 nDug3:=nPot3:=0
 nRbr2:=0 // brojac sint stavki
 nRbr:=0
 nUkUkDugBHD:=nUkUkPotBHD:=nUkUkDugDEM:=nUkUkPotDEM:=0
 Zagl12()
 DO WHILE eval(b1) .and. eval(b2)     // jedan nalog

    IF prow()-gPStranica>63; FF; Zagl12(); ENDIF
    cIdSinKon:=LEFT(IdKonto,3)
    nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
    DO WHILE  eval(b1) .and. eval(b2) .and. eval(b3)  // sinteticki konto

       cIdKonto:=IdKonto
       nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
       IF prow()-gPStranica>63; FF; Zagl12(); ENDIF
       DO WHILE  eval(b1) .and. eval(b2) .and. eval(b4)  // analiticki konto
          select KONTO; hseek cidkonto
          select PANAL
          @ prow()+1,0 SAY  ++nRBr PICTURE '9999'
          @ prow(),pcol()+1 SAY datnal
          @ prow(),pcol()+1 SAY cIdKonto
          @ prow(),pcol()+1 SAY left(KONTO->naz,45)
          nCol1:=pcol()+1
          @ prow(),nCol1 SAY DugBHD PICTURE PicBHD
          @ prow(),pcol()+1 SAY PotBHD PICTURE PicBHD
          @ prow(),pcol()+1 SAY DugDEM PICTURE PicDEM
          @ prow(),pcol()+1 SAY PotDEM PICTURE PicDEM
          nDugBHD+=DugBHD; nDugDEM+=DUGDEM
          nPotBHD+=PotBHD; nPotDEM+=POTDEM
          SKIP
       enddo

       nUkDugBHD+=nDugBHD; nUkPotBHD+=nPotBHD
       nUkDugDEM+=nDugDEM; nUkPotDEM+=nPotDEM
    ENDDO  // siteticki konto

    IF prow()-gPStranica>62; FF; Zagl12(); ENDIF
    ? M
    @ prow()+1,1 SAY ++nRBr2 PICTURE '999'
    @ prow(),pcol()+1 SAY PADR(cIdSinKon,6)
    SELECT KONTO; HSEEK cIdSinKon
    @ prow(),pcol()+1 SAY LEFT(Naz,45)
    SELECT PANAL
    @ prow(),nCol1 SAY nUkDugBHD PICTURE PicBHD
    @ prow(),pcol()+1 SAY nUkPotBHD PICTURE PicBHD
    @ prow(),pcol()+1 SAY nUkDugDEM PICTURE PicDEM
    @ prow(),pcol()+1 SAY nUkPotDEM PICTURE PicDEM
    ? M

    nUkUkDugBHD+=nUkDugBHD
    nUKUkPotBHD+=nUkPotBHD
    nUkUkDugDEM+=nUkDugDEM
    nUkUkPotDEM+=nUkPotDEM

 ENDDO  // nalog

 IF prow()-gPStranica>61; FF; Zagl12(); ENDIF

 ? M
 ? "ZBIR NALOGA:"
 @ prow(),nCol1 SAY nUkUkDugBHD PICTURE PicBHD
 @ prow(),pcol()+1 SAY nUkUkPotBHD PICTURE PicBHD
 @ prow(),pcol()+1 SAY nUkUkDugDEM PICTURE PicDEM
 @ prow(),pcol()+1 SAY nUkUkPotDEM PICTURE PicDEM
 ? M

FF

END PRINT

if fkum
 closeret2
endif
return
*}




/*! \fn Zagl12()
 *  \brief Zaglavlje sintetickog naloga
 */

static function Zagl12()
*{
local nArr
P_COND
?? "FIN.P: ANALITIKA/SINTETIKA -  NALOG ZA KNJIZENJE BROJ : "
@ prow(),PCOL()+2 SAY cIdFirma+" - "+cIdVn+" - "+cBrNal
if gDatNal=="D"
 @ prow(),pcol()+4 SAY "DATUM: "
 ?? dDatNal
endif

SELECT TNAL; HSEEK cIdVN; select PANAL
@ prow(),pcol()+4 SAY tnal->naz
@ prow(),120 SAY "Str:"+str(++nStr,3)

gVar1:="1"
P_NRED; ?? m
P_NRED; ?? "*RED*"+PADC(if(.t.,"","DATUM"),8)+"*           NAZIV KONTA                               *            IZNOS U "+ValDomaca()+"           *"+IF(gVar1=="1","","     IZNOS U "+ValPomocna()+"       *")
P_NRED; ?? "    *        *                                                      ----------------------------------- "+IF(gVar1=="1","","-------------------------")
P_NRED; ?? "*BR *        *                                                     * DUGUJE  "+ValDomaca()+"    * POTRAZUJE  "+ValDomaca()+" *"+IF(gVar1=="1",""," DUG. "+ValPomocna()+"  * POT. "+ValPomocna()+" *")
P_NRED; ?? m

return
*}





/*! \fn KZbira()
 *  \brief Kontrola zbira FIN-naloga
 */

function KZbira()
*{
O_KONTO
O_VALUTE
FO_PRIPR

Box("kzb",12,70,.f.,"Kontrola zbira FIN naloga")
 set cursor on
 cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal

 @ m_x+1,m_y+2 SAY "Nalog broj: "+cidfirma+"-"+cidvn+"-"+cBrNal

 set order to 1
 seek cIdFirma+cIdVn+cBrNal

 private dug:=dug2:=Pot:=Pot2:=0
 do while  !eof() .and. (IdFirma+IdVn+BrNal==cIdFirma+cIdVn+cBrNal)
   if D_P=="1"; dug+=IznosBHD; dug2+=iznosdem; else; pot+=IznosBHD;pot2+=iznosdem; endif
   skip
 enddo
 SKIP -1
 Scatter()

 cPic:="999 999 999 999.99"
 @ m_x+5,m_y+2 SAY "Zbir naloga:"
 @ m_x+6,m_y+2 SAY "     Duguje:"
 @ m_x+6,COL()+2 SAY Dug PICTURE cPic
 @ m_x+6,COL()+2 SAY Dug2 PICTURE cPic
 @ m_x+7,m_y+2 SAY "  Potrazuje:"
 @ m_x+7,COL()+2 SAY Pot  PICTURE cPic
 @ m_x+7,COL()+2 SAY Pot2  PICTURE cPic
 @ m_x+8,m_y+2 SAY "      Saldo:"
 @ m_x+8,COL()+2 SAY Dug-Pot  PICTURE cPic
 @ m_x+8,COL()+2 SAY Dug2-Pot2  PICTURE cPic

 IF round(Dug-Pot,2) <> 0
   private cDN:="D"
   set cursor on
   @ m_x+10,m_y+2 SAY "Zelite li uravnoteziti nalog (D/N) ?" GET cDN valid (cDN $ "DN") pict "@!"
   read
   if cDN=="D"
     _Opis:="GRESKA ZAOKRUZ."
     _BrDok:=""
     _D_P:="2"; _IdKonto:=SPACE(7)
     @ m_x+11,m_y+2 SAY "Staviti na konto ?" GET _IdKonto valid P_Konto(@_IdKonto)
     @ m_x+11,col()+1 SAY "Datum dokumenta:" GET _DatDok
     read
     if lastkey()<>K_ESC
       _Rbr:=str(val(_Rbr)+1,4)
       _IdPartner:=""
       _IznosBHD:=Dug-Pot
       DinDem(NIL,NIL,"_IZNOSBHD")
       append blank
       Gather()
     endif
   endif // cDN=="D"
 endif  // dug-pot<>0
BoxC()

closeret2
return
*}




/*! \fn DinDem(p1,p2,cVar)
 *  \brief Konverzija iznosa domaca<->pomocna valuta
 *  \param p1 -
 *  \param p2 -
 *  \param cVar - naziv polja iznosa koji se pretvara (_IZNOSDEM ili _IZNOSBHD)
 */

function DinDem(p1,p2,cVar)
*{
local nNaz

// nArr:=SELECT()
// select tokval
// seek dtos(_DatDok)
// if !found() .or. eof()
//     skip -1
// endif

// if kurslis=="1"; nNaz:=naz; else;  nNaz:=naz2; endif
nNaz:=Kurs(_datdok)
if cVar=="_IZNOSDEM"
    _IZNOSBHD:=_IZNOSDEM*nnaz
elseif cVar="_IZNOSBHD"
  if round(nNaz,4)==0
    _IZNOSDEM:=0
  else
    _IZNOSDEM:=_IZNOSBHD/nnaz
  endif
endif
// select(nArr)
AEVAL(GetList,{|o| o:display()})
return
*}




/*! \fn PovFin(cidfirma,cidvn,cbrnal)
 *  \brief Povrat finansijskog naloga u pripremu
 *  \param cidfirma - firma
 *  \param cidvn - vrsta naloga
 *  \param cbrnal - broj naloga
 */

function PovFin(cidfirma,cidvn,cbrnal)
*{
local nRec

if Klevel<>"0"
    Beep(2)
    Msg("Nemate pristupa ovoj opciji !",4)
    closeret2
endif

FO_SUBAN
FO_PRIPR
FO_ANAL
FO_SINT
FO_NALOG

SELECT SUBAN; set order to 4
if pcount()==0

cIdFirma:=gFirma
cIdVN:=space(2)
cBrNal:=space(4)

Box("",1,35)
 @ m_x+1,m_y+2 SAY "Nalog:"
 if gNW=="D"
  @ m_x+1,col()+1 SAY cIdFirma
 else
  @ m_x+1,col()+1 GET cIdFirma
 endif
 @ m_x+1,col()+1 SAY "-" GET cIdVN
 @ m_x+1,col()+1 SAY "-" GET cBrNal
 read; ESC_BCR
BoxC()

if Pitanje(,"Nalog "+cIdFirma+"-"+cIdVN+"-"+cBrNal+" povuci u pripremu (D/N) ?","D")=="N"
   closeret2
endif

endif
//if Pitanje(,"Zelite li izbrisati stanje datoteke PRIPR (D/N)?","N") == "D"
//  select PRIPR
//  zap
//endif

if !(suban->(flock()) .and. anal->(flock()) .and. sint->(flock()) .and. nalog->(flock()) )
  Msg("Neko vec koristi datoteke !",6); closeret2
endif

MsgO("SUBAN")

select SUBAN
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
   select PRIPR; Scatter()
   select SUBAN; Scatter()
   select PRIPR
   append ncnl; Gather2()
   select SUBAN
   skip
enddo
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
   skip 1; nRec:=recno(); skip -1
   dbdelete2()
   go nRec
enddo
use

MsgC()

MsgO("ANAL")
select ANAL; set order to 2
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
  skip 1; nRec:=recno(); skip -1
  dbdelete2()
  go nRec
enddo
use
MsgC()

MsgO("SINT")
select sint;  set order to 2
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
  skip 1; nRec:=recno(); skip -1
  dbdelete2()
  go nRec
enddo

use
MsgC()

MsgO("NALOG")
select nalog
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
  skip 1; nRec:=recno(); skip -1
  dbdelete2()
  go nRec
enddo
use
MsgC()
closeret2
return
*}

