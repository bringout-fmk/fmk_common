#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/ostav/1g/ios.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: ios.prg,v $
 * Revision 1.3  2004/01/13 19:07:56  sasavranic
 * appsrv konverzija
 *
 * Revision 1.2  2002/06/20 07:46:43  sasa
 * no message
 *
 *
 */
 
/*! \file fmk/fin/ostav/1g/ios.prg
 *  \brief Otvorene stavke
 */
 

/*! \fn IOS()
 *  \brief Izvod otvorenih stavki
 */
 
function IOS()
*{
private opc[4],Izbor

picBHD:="@Z "+( R1:=FormPicL("9 "+gPicBHD,16) )
picDEM:="@Z "+( R2:=FormPicL("9 "+gPicDEM,12) )
R1:=R1+" "+ValDomaca()
R2:=R2+" "+ValPomocna()

private cMjesto:=PADR("ZENICA",20)

O_PARAMS
private cSection:="6",cHistory:=" "; aHistory:={}
Rpar("mj",@cMjesto)

Box(,5,60)
  @ m_x+4,m_y+2 SAY "Napomena: Prije stampanja mora se pokrenuti"
  @ m_x+5,m_y+2 SAY "specifikacija IOS-a "
  @ m_x+1,m_y+2 SAY "Mjesto:" GET cMjesto pict "@!"
  read
BoxC()

IF LASTKEY()!=K_ESC
  Wpar("mj",cMjesto)
ENDIF
SELECT PARAMS; USE

opc[1]:="1. specifikacija ios-a                     "
opc[2]:="2. ios"
opc[3]:="3. ios (nastavak u slucaju prekida rada) "
opc[4]:="4. ios (pojedinacan)"
//opc[5]:="9. kraj posla"

Izbor:=1
DO WHILE .T.
   h[1]:="Specifikacija IOS-a je priprema za stampanje obrazaca IOS-a"
   h[2]:="Stampanje svih IOS-a iz specifikacije"
   h[3]:="Nastavak u slucaju prekida opcije 2."
   h[4]:="Stampanje IOS-a za pojedinacnog partnera"
   h[5]:=""
   Izbor:=Menu("IOS",opc,Izbor,.f.)
   DO CASE
      CASE Izbor==0
         exit
      CASE izbor==1
         SpecIOS()
      CASE izbor==2
         IOSS()
      CASE izbor==3
         IOSPrekid()
      CASE izbor==4
         IOSPojed()
      CASE Izbor==5
         Izbor:=0
   ENDCASE
enddo
return
*}



/*! \fn SpecIOS()
 *  \brief Specifikacija otvorenih stavki
 */
 
procedure SpecIOS()
*{
cIdFirma:=gFirma
cIdKonto:=space(7)
IF gVar1=="0"
 M:="----- ------ ------------------------------------ ----- ----------------- --------------- ---------------- ---------------- ---------------- ------------ ------------ ------------ ------------"
ELSE
 M:="----- ------ ------------------------------------ ----- ----------------- --------------- ---------------- ---------------- -----------------"
ENDIF
O_PARTN
O_KONTO
cPrik0:="D"
Box("",6,60)
@ m_x+1,m_y+6 SAY "SPECIFIKACIJA IOS-a"
if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+4,m_y+2 SAY "Konto: " GET cIdKonto valid P_Konto(@cIdKonto)
@ m_x+6,m_y+2 SAY "Prikaz partnera sa saldom 0 :" GET cPrik0 valid cPrik0 $ "DN" pict "@!"
READ; ESC_BCR
BoxC()

cIdFirma:=LEFT(cIdFirma,2)

O_SUBAN
O_IOS

SELECT IOS; ZAP

SELECT SUBAN; set order to 1

SEEK cIdFirma+cIdKonto
EOF CRET


start print cret

B:=0
nDugBHD:=nUkDugBHD:=nDugDEM:=nUkDugDEM:=0
nPotBHD:=nUkPotBHD:=nPotDEM:=nUkPotDEM:=0


nUkBHDDS:=nUkBHDPS:=0
nUkDEMDS:=nUkDEMPS:=0
DO WHILE !eof() .AND. cIdFirma==IdFirma .and. cIdKonto==IdKonto

   cIdPartner:=IdPartner
   DO WHILE  !eof() .AND. cIdFirma=IdFirma .and. cIdKonto=IdKonto .AND. cIdPartner==IdPartner
      IF OtvSt=" "
         IF D_P="1"
            nDugBHD+=IznosBHD
            nUkDugBHD+=IznosBHD
            nDugDEM+=IznosDEM
            nUkDugDEM+=IznosDEM
         ELSE
            nPotBHD+=IznosBHD
            nUkPotBHD+=IznosBHD
            nPotDEM+=IznosDEM
            nUkPotDEM+=IznosDEM
         ENDIF
      ENDIF
      SKIP
   ENDDO // partner

   nSaldoBHD:=nDugBHD-nPotBHD
   nSaldoDEM:=nDugDEM-nPotDEM
   if cPrik0=="D"  .or. round(nsaldobhd,2)<>0  // ako je iznos <> 0

     if prow()==0; ZagSpecIOS(); endif
     If prow()>61+gPStranica; FF; ZagSpecIOS(); endif
     @ prow()+1,0 SAY ++B PICTURE '9999'
     @ prow(),5 SAY cIdPartner
     SELECT PARTN; HSEEK cIdPartner
     @ prow(),12 SAY naz
     @ prow(),37 SAY naz2 PICTURE 'XXXXXXXXXXXX'
     @ prow(),50 SAY PTT
     @ prow(),56 SAY Mjesto


     // BHD
     @ prow(),73 SAY nDugBHD PICTURE picBHD
     @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD


    SELECT IOS
    APPEND BLANK
    REPLACE IdFirma WITH   cIdFirma,;
           IdKonto WITH   cIdKonto,;
           IdPartner WITH cIdPartner,;
           IznosBHD WITH nSaldoBHD ,;
           IznosDEM WITH nSaldoDEM

   endif // nsaldo<>0
   SELECT SUBAN

   IF nSaldoBHD>=0
      @ prow(),pcol()+1 SAY nSaldoBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY 0 PICTURE picBHD
      nUkBHDDS+=nSaldoBHD
   ELSE
      @ prow(),pcol()+1 SAY 0 PICTURE picBHD
      @ prow(),pcol()+1 SAY -nSaldoBHD PICTURE picBHD
      nUkBHDPS+= -nSaldoBHD
   ENDIF

   IF gVar1=="0"
    // DEM

    @ prow(),pcol()+1 SAY nDugDEM PICTURE picDEM
    @ prow(),pcol()+1 SAY nPotDEM PICTURE picDEM

    IF nSaldoDEM>=0
       @ prow(),pcol()+1 SAY nSaldoDEM PICTURE picDEM
       @ prow(),pcol()+1 SAY 0 PICTURE picDEM
       nUkDEMDS+=nSaldoDEM
    ELSE
       @ prow(),pcol()+1 SAY 0 PICTURE picDEM
       @ prow(),pcol()+1 SAY -nSaldoDEM PICTURE picDEM
       nUkDEMPS+= -nSaldoDEM
    ENDIF
   ENDIF

   nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
   cIdPartner:=IdPartner
ENDDO // konto

if prow()>61+gPStranica; FF; ZagSpecIOS(); endif
@ prow()+1,0 SAY M
@ prow()+1,0 SAY "UKUPNO ZA KONTO:"
@ prow(),73       SAY nUkDugBHD PICTURE picBHD
@ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD

nS:=nUkBHDDS-nUkBHDPS
@ prow(),pcol()+1 SAY iif(nS>=0,nS,0) PICTURE picBHD
@ prow(),pcol()+1 SAY iif(nS<=0,nS,0) PICTURE picBHD

IF gVar1=="0"
 @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
 @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM

 nS:=nUkDEMDS-nUkDEMPS
 @ prow(),pcol()+1 SAY iif(nS>=0,nS,0) PICTURE picDEM
 @ prow(),pcol()+1 SAY iif(nS<=0,nS,0) PICTURE picDEM
ENDIF
@ prow()+1,0 SAY M

FF
END PRINT
closeret
return
*}



/*! \fn ZagSpecIOS() 
 *  \brief Zaglavlje specifikacije otvorenih stavki
 */
 
function ZagSpecIOS()
*{
P_COND
??  "FIN: SPECIFIKACIJA IOS-a     NA DAN "; ?? DATE()
? "FIRMA:"
@ prow(),pcol()+1 SAY cIdFirma
SELECT PARTN; HSEEK cIdFirma
@ prow(),pcol()+1 SAY naz; @ prow(),pcol()+1 SAY naz2

? M
? "*RED.* ÊIFRA*      NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *   KUMULATIVNI PROMET  U  "+ValDomaca()+"  *    S A L D O   U   "+ValDomaca()+"         "+IF(gVar1=="0","*  KUMULAT. PROMET U "+ValPomocna()+" *  S A L D O   U   "+ValPomocna()+"  ","")+"*"
? "                                                                          ________________________________ _________________________________"+IF(gVar1=="0","*_________________________ ________________________","")+"_"
? "*BROJ*      *                                    * BROJ*                 *    DUGUJE     *   POTRAZUJE    *    DUGUJE      *   POTRAZUJE    "+IF(gVar1=="0","*    DUGUJE  * POTRAZUJE  *   DUGUJE   * POTRAZUJE ","")+"*"
? M

SELECT SUBAN
RETURN
*}



/*! \fn IOSS()
 *  \brief IOS specifikacija 
 */
 
function IOSS()
*{
close all
cPrelomljeno:="N"
private cKaoKartica:="D"
memvar->DATUM:=date()
cDinDem:="1"
Box("IOSS",5,60,.f.)
@ m_x+1,m_y+8 SAY "I O S"
@ m_x+2,m_y+2 SAY "UKUCAJTE DATUM IOS-a:"  GET memvar->DATUM
IF gVar1=="0"
 @ m_x+3,m_y+2 SAY "Prikaz "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+" (1/2)"  GET cDinDem valid cdindem $ "12"
ENDIF
@ m_x+4,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"
@ m_x+5,m_y+2 SAY "Prikaz identicno kartici " GET cKaoKartica valid cKaoKartica $ "DN" pict "@!"
READ
BoxC(); ESC_RETURN 0

A:=0; B:=0
nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0

O_PARTN
O_KONTO
O_TNAL
O_SUBAN
O_IOS

start print cret

SELECT IOS; go top
DO WHILE !eof()
   cIdFirma:=IdFirma; cIdKonto:=IdKonto; cIdPartner:=IdPartner
   nIznosBHD:=IznosBHD; nIznosDEM:=IznosDEM
   ZagIOSS(cdindem)
   SKIP
ENDDO

FF
end print
closeret
return 1
*}



/*! \fn IOSPrekid()
 *  \brief Ukoliko dodje do prekida u IOSS nastavlja dalje
 */
 
function IOSPrekid()
*{
memvar->DATUM=DATE()
cIdFirma:=gFirma
cIdKonto:=space(7)
cIdPartner:=space(6)

O_KONTO
O_PARTN
private cKaoKartica:="D"
cPrelomljeno:="N"
cDinDem:="1"
Box("IOSPrek",8,60,.f.)
@ m_x+1,m_y+2 SAY " I O S (NASTAVAK U SLUCAJU PREKIDA RADA)"
@ m_x+2,m_y+2 SAY "Datum IOS-a:" GET memvar->DATUM
if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+4,m_y+2 SAY "Konto      :" GET cIdKonto valid P_Konto(@cIdKonto)
@ m_x+5,m_y+2 SAY "Partner    :" GET cIdPartner valid P_Firma(@cIdPartner) PICT "@!"
IF gVar1=="0"
 @ m_x+6,m_y+2 SAY "Prikaz "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+" (1/2)"  GET cDinDem valid cdindem $ "12"
ENDIF
@ m_x+7,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"
@ m_x+8,m_y+2 SAY "Prikaz identicno kartici " GET cKaoKartica valid cKaoKartica $ "DN" pict "@!"
READ; ESC_BCR
BoxC()
nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0

cIdFirma:=LEFT(cIdFirma,2)

O_TNAL
O_SUBAN
O_IOS

select IOS

SEEK cIdFirma+cIdKonto+cIdPartner

NFOUND CRET

start print cret

A:=0; B:=0
SELECT IOS
DO WHILE !eof()
   cIdFirma=IdFirma; cIdKonto=IdKonto; cIdPartner=IdPartner
   nIznosbHD=IznosBHD; nIznosDEM:=IznosDEM
   ZagIOSS()
   SKIP
ENDDO

FF
END PRINT
closeret
return
*}



/*! \fn IOSPojed()
 *  \brief Pojedinacni IOS
 */
 
function IOSPojed()
*{
memvar->DATUM=date()
cIdFirma:=gFirma
cIdKonto:=space(7)
cIdPartner:=space(6)

O_KONTO
O_PARTN

cDinDem:="1"
private cKaoKartica:="D"
cPrelomljeno:="N"
Box("IOSPoj",8,60,.f.)
@ m_x+1,m_y+2 SAY " I O S (POJEDINACAN)"
@ m_x+2,m_y+2 SAY "Datum IOS-a :" GET memvar->DATUM
if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+4,m_y+2 SAY "Konto       :" GET cIdKonto valid P_Konto(@cIdKonto)
@ m_x+5,m_y+2 SAY "Partner     :" GET cIdPartner valid P_Firma(@cIdPartner) PICT "@!"
IF gVar1=="0"
 @ m_x+6,m_y+2 SAY "Prikaz "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+" (1/2)"  GET cDinDem valid cdindem $ "12"
ENDIF
@ m_x+7,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"
@ m_x+8,m_y+2 SAY "Prikaz identicno kartici " GET cKaoKartica valid cKaoKartica $ "DN" pict "@!"
READ; ESC_BCR
BoxC()
nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0

cIdFirma:=LEFT(cIdFirma,2)

O_TNAL
O_SUBAN
O_IOS

select IOS
SEEK cIdFirma+cIdKonto+cIdPartner
NFOUND CRET

start print cret

B:=0
SELECT IOS
DO WHILE !eof() .AND. cIdFirma=IdFirma .AND. cIdKonto=IdKonto .AND. cIdPartner=IdPartner
   nIznosBHD:=IznosBHD; nIznosDEM:=IznosDEM
   ZagIOSS(cdindem)
   SKIP
ENDDO

FF
end print
closeret
return
*}



/*! \fn ZagIOSS(cDinDem)
 *  \brief Zaglavlje IOS specifikacije
 *  \param cDinDem
 */
 
function ZagIOSS(cDinDem)
*{
local nRbr,nCOpis:=0

@ prow(),58 SAY "OBRAZAC: I O S"
@ prow()+1,1 SAY cIdFirma
SELECT PARTN; HSEEK cIdFirma
@ prow(),5 SAY naz
@ prow(),pcol()+1 SAY naz2
@ prow()+1,5 SAY Mjesto
@ prow()+1,5 SAY Adresa
@ prow()+1,5 SAY ZiroR
?
?
SELECT PARTN; HSEEK cIdPartner
@ prow(),45 SAY cidpartner; ?? " -",naz
@ prow()+1,45 SAY mjesto
@ prow()+1,45 SAY adresa
@ prow()+1,45 SAY ziror
if !empty(telefon)
  @ prow()+1,45 SAY "Telefon: "+telefon
endif
?
?
?
@ prow(),6 SAY "IZVOD OTVORENIH STAVKI NA DAN :"; @ prow(),pcol()+2 SAY memvar->DATUM; @ prow(),pcol()+1 SAY "GODINE"
?
?
@ prow(),0 SAY "VAÊE STANJE NA KONTU" ; @ prow(),pcol()+1 SAY cIdKonto
@ prow(),pcol()+1 SAY " - "+ cIdPartner
@ prow()+1,0 SAY "PREMA NAÊIM POSLOVNIM KNJIGAMA NA DAN:"
@ prow(),39 SAY memvar->DATUM
@ prow(),48 SAY "GODINE"
?
?
@ prow(),0 SAY "POKAZUJE SALDO:"

qqIznosBHD:=nIznosBHD
qqIznosDEM:=nIznosDEM
IF nIznosBHD<0
   qqIznosBHD:= -nIznosBHD
ENDIF
IF nIznosDEM<0
   qqIznosDEM:= -nIznosDEM
ENDIF

if cDinDEM=="1"
 @ prow(),16 SAY qqIznosBHD PICTURE R1
else
 @ prow(),16 SAY qqIznosDEM PICTURE R2
endif
?
?
//IF nIznosBHD<>0
   @ prow(),0 SAY "U"
   IF nIznosBHD>0
      @ prow(),pcol()+1 SAY "NAÊU"
   ELSE
      @ prow(),pcol()+1 SAY "VAÊU"
   ENDIF
   @ prow(),pcol()+1 SAY "KORIST I SASTOJI SE IZ SLIJEDEèIH OTVORENIH STAVKI:"
   P_COND
   M:="       ---- ---------- -------------------- -------- -------- ---------------- ----------------"

   ? M
   ? "       *R. *   BROJ   *    OPIS            * DATUM  * VALUTA *       IZNOS  U  "+iif(cdindem=="1",ValDomaca(),ValPomocna())+"            *"
   ? "       *Br.*          *                    *                 * --------------------------------"
   ? "       *   *  RA¨UNA  *                    * RA¨UNA * RA¨UNA *     DUGUJE     *   POTRA¶UJE   *"
   ? M
   nCol1:=62
   SELECT SUBAN
   if cKaoKartica=="D"
     set order to 1
     altd()
     //"IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr"
   else
     set order to 3
   endif
   SEEK cIdFirma+cIdKonto+cIdPartner
   nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
   nDugBHDZ:=nPotBHDZ:=nDugDEMZ:=nPotDEMZ:=0
   nRbr:=0

   // ako je kartica, onda nikad ne prelamaj
   if cKaoKartica=="D"; cPrelomljeno:="N"; endif

   DO WHILE !eof() .AND. cIdFirma=IdFirma .AND. cIdKonto=IdKonto .AND. cIdPartner==IdPartner
     cBrDok:=brdok
     dDatdok:=datdok; cOpis:=ALLTRIM(opis); dDatVal:=datval
     nDBHD:=nPBHD:=nDDEM:=nPDEM:=0
     cOtvSt:=otvst
     DO WHILE !eof() .AND. cIdFirma=IdFirma .AND. cIdKonto=IdKonto .AND. cIdPartner==IdPartner ;
         .and. (cKaoKartica=="D" .or. brdok==cBrdok)
         IF OtvSt=" "
            if cKaoKartica=="D"
               if prow()>61+gPStranica; FF; endif      // MS 29.11.01
               @ prow()+1,8 SAY ++nRbr PICTURE '999'
               @ prow(),pcol()+1  SAY BrDok
               nCOpis:=pcol()+1
               @ prow(),nCOpis    SAY PADR(Opis,20)
               @ prow(),pcol()+1  SAY DatDok
               @ prow(),pcol()+1  SAY DatVal
               if cDinDem=="1"
                    @ prow(),ncol1    SAY iif(D_P="1",iznosbhd,0)  PICTURE picBHD
                    @ prow(),pcol()+1 SAY iif(D_P="2",iznosbhd,0)  PICTURE picBHD
               else
                    @ prow(),ncol1    SAY iif(D_P="1",iznosdem,0) PICTURE picBHD
                    @ prow(),pcol()+1 SAY iif(D_P="2",iznosdem,0) PICTURE picBHD
               endif
            endif
            IF D_P="1"
               nDBHD+=IznosBHD; nDDEM+=IznosDEM
            ELSE
               nPBHD+=IznosBHD; nPDEM+=IznosDEM
            ENDIF
            cOtvSt:=" "
        else  // zatvorene stavke
            IF D_P="1"
               nDugBHDZ+=IznosBHD; nDugDEMZ+=IznosDEM
            ELSE
               nPotBHDZ+=IznosBHD; nPotDEMZ+=IznosDEM
            ENDIF
        endif
        skip
     enddo
     if cOtvSt==" "
      if cKaoKartica=="N"
       if prow()>61+gPStranica; FF; endif      // MS 29.11.01
       @ prow()+1,8 SAY ++nRbr PICTURE '999'

       @ prow(),pcol()+1  SAY cBrDok
       nCOpis:=pcol()+1
       @ prow(),nCOpis    SAY PADR(cOpis,20)
       @ prow(),pcol()+1  SAY dDatDok
       @ prow(),pcol()+1  SAY dDatVal
      endif
      if cDinDem=="1"
          if cPrelomljeno=="D"
              if nDBHD-nPBHD>0
                nDBHD:=nDBHD-nPBHD
                nPBHD:=0
              else
                nPBHD:=nPBHD-nDBHD
                nDBHD:=0
              endif
          endif
          if cKaoKartica=="N"
           @ prow(),ncol1 SAY nDBHD PICTURE picBHD
           @ prow(),pcol()+1 SAY nPBhD PICTURE picBHD
          endif
      else
          if cPrelomljeno=="D"
              if nDDEM-nPDEM>0
                nDDEM:=nDDEM-nPDEM
                nPBHD:=0
              else
                nPDEM:=nPDEM-nDDEM
                nDDEM:=0
              endif
          endif
          if cKaoKartica=="N"
           @ prow(),ncol1    SAY nDDEM PICTURE picBHD
           @ prow(),pcol()+1 SAY nPDEM PICTURE picBHD
          endif
      endif
      nDugBHD+=nDBHD; nPotBHD+=nPBHD
      nDugDem+=nDDem; nPotDem+=nPDem
     endif
     OstatakOpisa(cOpis,nCOpis)
   ENDDO

   if prow()>61+gPStranica; FF; endif
   @ prow()+1,0 SAY M
   @ prow()+1,8 SAY "UKUPNO:"
   if cDinDEM=="1"
     @ prow(),ncol1    SAY nDugBHD PICTURE picBHD
     @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
   else
     @ prow(),ncol1    SAY nDugBHD PICTURE picBHD
     @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
   endif


   // ako je promet zatvorenih stavki <> 0  prikazi ga ????
   if cDinDEM=="1"
     if round(nDugBHDZ-nPOTBHDZ,4)<>0
       @ prow()+1,0 SAY M
       @ prow()+1,8 SAY "ZATVORENE STAVKE"
       @ prow(),ncol1    SAY nDugBHDZ-nPOTBHDZ PICTURE picBHD
       @ prow(),pcol()+1 SAY  " GREÊKA !!"
     endif
   else
     if round(nDugDEMZ-nPOTDEMZ,4)<>0
       @ prow()+1,0 SAY M
       @ prow()+1,8 SAY "ZATVORENE STAVKE"
       @ prow(),ncol1    SAY nDugDEMZ-nPOTDEMZ PICTURE picBHD
       @ prow(),pcol()+1 SAY " GREÊKA !!"
     endif
   endif


   @ prow()+1,0 SAY M
   @ prow()+1,8 SAY "SALDO:"
   nSaldoBHD:=nDugBHD-nPotBHD
   nSaldoDEM:=nDugDEM-nPotDEM
   if cDINDEM=="1"
    IF nSaldoBHD>=0
      @ prow(),ncol1 SAY nSaldoBHD PICTURE picBHD
      @ prow(),pcol()+1 SAY 0 PICTURE picBHD
    ELSE
      nSaldoBHD:=-nSaldoBHD
      nSaldoDEM:=-nSaldoDEM
      @ prow(),ncol1 SAY 0 PICTURE picBHD
      @ prow(),pcol()+1 SAY nSaldoBHD PICTURE picBHD
    ENDIF
   else
    IF nSaldoDEM>=0
      @ prow(),ncol1 SAY nSaldoDEM PICTURE picBHD
      @ prow(),pcol()+1 SAY 0 PICTURE picBHD
    ELSE
      nSaldoDEM:=-nSaldoDEM
      @ prow(),ncol1 SAY 0 PICTURE picBHD
      @ prow(),pcol()+1 SAY nSaldoDEM PICTURE picBHD
    ENDIF
   endif
   ? m
   F10CPI

   ?

//ENDIF
if prow()>60+gPStranica; FF; endif
?
?
F12CPI
@ prow(),13 SAY "POÊILJALAC IZVODA:"
@ prow(),53 SAY "POTVR—UJEMO SAGLASNOST"
@ prow()+1,50 SAY "OTVORENIH STAVKI:"
?
?
@ prow(),10 SAY "__________________"
@ prow(),50 SAY "______________________"

if prow()>58+gPStranica; FF; endif
?
?
@ prow(),10 SAY "__________________ M.P."
@ prow(),50 SAY "______________________ M.P."
?
?
@ prow(),10 SAY trim(cMjesto)+", "+dtoc(date())
@ prow(),52 SAY "( MJESTO I DATUM )"

if prow()>52+gPStranica; FF; endif
?
?
@ prow(),0 SAY "!! AKO U ROKU OD 15 DANA NE POTVRDITE, OVAJ IOS SMATRAèEMO PRIHVAèENIM !!"
?
?
@ prow(),0 SAY "NAPOMENA: OSPORAVAMO ISKAZANO STANJE U CJELINI _______________ DJELIMI¨NO"
@ prow()+1,0 SAY "ZA IZNOS OD  "+ValDomaca()+"= _______________ IZ SLIJEDEèIH RAZLOGA:"
@ prow()+1,0 SAY "_________________________________________________________________________"
?
?
@ prow(),0 SAY "_________________________________________________________________________"
?
?
?
@ prow(),48 SAY "DU¶NIK:"
@ prow()+1,40 SAY "_______________________ M.P."
@ prow()+1,44 SAY "( MJESTO I DATUM )"

FF

SELECT IOS
RETURN
*}



/*! \fn OstatakOpisa(cO,nCO,bUslov,nSir)
 *  \brief Stampa ostatka opisa
 *  \param cO
 *  \param nCO
 *  \param bUslov
 *  \param nSir
 */
 
function OstatakOpisa(cO,nCO,bUslov,nSir)
*{
IF nSir==NIL; nSir:=20; ENDIF
  DO WHILE LEN(cO)>nSir
    IF bUslov!=NIL; EVAL(bUslov); ENDIF
    cO:=SUBSTR(cO,nSir+1)
    IF !EMPTY(PADR(cO,nSir))
      @ prow()+1,nCO SAY PADR(cO,nSir)
    ENDIF
  ENDDO
RETURN
*}


