#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/ostav/1g/ostav.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.9 $
 * $Log: ostav.prg,v $
 * Revision 1.9  2004/03/02 18:37:27  sasavranic
 * no message
 *
 * Revision 1.8  2004/01/19 09:05:16  sasavranic
 * Na komenzaciji uvedena polja za fax #32# i #33#
 *
 * Revision 1.7  2004/01/13 19:07:56  sasavranic
 * appsrv konverzija
 *
 * Revision 1.6  2004/01/10 09:58:47  sasavranic
 * no message
 *
 * Revision 1.5  2003/07/26 14:08:05  mirsad
 * nove šifre za ispis na kompenzaciji: adrese i žiro-raèun za pomoænu valutu
 *
 * Revision 1.4  2002/11/17 11:02:25  sasa
 * no message
 *
 * Revision 1.3  2002/09/25 12:55:53  sasa
 * Dodato aPov7 i aDuz7 varijable za telefon
 *
 * Revision 1.2  2002/06/20 07:46:43  sasa
 * no message
 *
 *
 */
 
/*! \fn Ostav()
 *  \brief Menij otvorenih stavki
 */
 
function Ostav()
*{
private opc[9],Izbor,gNLOst:=0
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("li",@gnLOst)
select params; use

opc[1]:="1. rucno zatvaranje                    "
opc[2]:="2. automatsko zatvaranje"
opc[3]:="3. kartica"
opc[4]:="4. kartica konto/konto2"
opc[5]:="5. specifikacija"
opc[6]:="6. ios"
opc[7]:="7. kartice grupisane po brojevima veze"
opc[8]:="8. kompenzacija"
opc[9]:="9. asistent otvorenih stavki"

Izbor:=1
DO WHILE .T.
   h[1]:="editovanje broja, datuma dokumenta, direktno zatvaranje stavke"
   h[2]:=""
   h[3]:=""
   h[4]:=""
   h[5]:=""
   h[6]:=""
   h[7]:=""
   h[8]:=""
   Izbor:=Menu("OtvS",opc,Izbor,.f.)
   DO CASE
      CASE izbor==0
        exit
      CASE izbor==1
         RucnoZat()
      CASE izbor==2
         AutoZat()
      CASE izbor==3
         SubKart(.t.)
      CASE izbor==4
         SubKart2(.t.)
      CASE izbor==5
         SpecOtSt()  // o.stavke specifikacija
      CASE izbor==6
         IOS()
//      CASE izbor==7
//         PrBrRacOp()
      CASE izbor==7
           StKart(.t.)
      CASE izbor==8
           Kompenzacija()
      CASE izbor==9
           GenAz()
   ENDCASE
ENDDO

closeret
return
*}




/*! \fn SpecOtSt()
 *  \brief Specifikacija otvorenih stavki
 */
 
static function SpecOtSt()
*{
local nKolTot:=85
cIdFirma:=gFirma
nRok:=0
cIdKonto:=space(7)
picBHD:=FormPicL("9 "+gPicBHD,21)
picDEM:=FormPicL("9 "+gPicDEM,21)

cIdRj:="999999"
cFunk:="99999"
cFond:="999"

qqBrDok:=SPACE(40)

O_PARTN
M:="---- "+REPL("-",LEN(PARTN->id))+" ------------------------------------- ----- ----------------- ---------- ---------------------- --------------------"
O_KONTO
dDatOd:=dDatDo:=ctod("")

cPrelomljeno:="D"
Box("Spec",13,75,.f.)

DO WHILE .t.
  set cursor on
  @ m_x+1,m_y+2 SAY "SPECIFIKACIJA OTVORENIH STAVKI"
  if gNW=="D"
    @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
   else
    @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
  endif
  @ m_x+4,m_y+2 SAY "Konto    " GET cIdKonto valid P_KontoFin(@cIDKonto) pict "@!"
  @ m_x+5,m_y+2 SAY "Od datuma" GET dDatOd
  @ m_x+5,col()+2 SAY "do" GET dDatdo
  @ m_x+7,m_y+2 SAY "Uslov za broj veze (prazno-svi) " GET qqBrDok PICT "@!S20"
  @ m_x+8,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"

  UpitK1k4(9,.f.)

  READ; ESC_BCR
  aBV:=Parsiraj(qqBrDok,"UPPER(BRDOK)","C")
  IF aBV<>NIL
    EXIT
  ENDIF
ENDDO

BoxC()

B:=0
*

if cPrelomljeno=="N"
 m+=" --------------------"
endif


nStr:=0

O_SUBAN

CistiK1k4(.f.)

select SUBAN; set order to 3   //IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)

cFilt1:="OTVST==' '"

IF !EMPTY(qqBrDok)
  cFilt1 += ( ".and." + aBV )
ENDIF

IF !EMPTY(dDatOd)
  cFilt1+=".and. IF( EMPTY(datval) , datdok>="+cm2str(dDatOd)+" , datval>="+cm2str(dDatOd)+" )"
ENDIF

IF !EMPTY(dDatDo)
  cFilt1+=".and. IF( EMPTY(datval) , datdok<="+cm2str(dDatDo)+" , datval<="+cm2str(dDatDo)+" )"
ENDIF

altd()

GO TOP

if gRj=="D" .and. len(cIdrj)<>0
  cFilt1 += ( ".and. idrj='"+cidrj+"'" )
endif

if gTroskovi=="D" .and. len(cFunk)<>0
  cFilt1 += ( ".and. Funk='"+cFunk+"'" )
endif

if gTroskovi=="D" .and. len(cFond)<>0
  cFilt1 += ( ".and. Fond='"+cFond+"'" )
endif

SET FILTER TO &cFilt1

seek cidfirma+cidkonto
NFOUND CRET

START PRINT  CRET

nDugBHD:=nPotBHD:=0


DO WHILESC !EOF() .and. cIDFirma==idfirma .AND. cIdKonto=IdKonto
   cIdPartner:=IdPartner
   DO WHILESC  !EOF() .and. cIDFirma==idfirma .AND. cIdKonto=IdKonto .and. cIdPartner=IdPartner


         if prow()==0; ZaglSpK(); endif
         if prow()>63+gPStranica; FF; ZaglSpK(); endif

         cBrDok:=BrDok
         nIznD:=0; nIznP:=0
         do WHILESC  !EOF() .AND. cIdKonto=IdKonto .and. cIdPartner=IdPartner ;
                  .and. cBrDok==BrDok
            if D_P=="1"; nIznD+=IznosBHD; else; nIznP+=IznosBHD; endif
            SKIP
         enddo
         @ prow()+1,0 SAY ++B PICTURE '9999'
         @ prow(),5 SAY cIdPartner

         SELECT PARTN; HSEEK cIdPartner
         @ prow(),pcol()+1 SAY naz; @ prow(),pcol()+1 SAY naz2 PICTURE 'XXXXXXXXXXXX'
         @ prow(),pcol()+1 SAY PTT; @ prow(),pcol()+1 SAY Mjesto
         SELECT SUBAN

         @ prow(),pcol()+1 SAY padr(cBrDok,10)

         if cPrelomljeno=="D"
                 if round(nIznD-nIznP,4)>0
                     nIznD:=nIznD-nIznP
                     nIznP:=0
                 else
                     nIznP:=nIznP-nIznD
                     nIznD:=0
                 endif
         endif

         // @ prow(),85      SAY nIznD PICTURE picBHD
         nKolTot:=pcol()+1
         @ prow(),nKolTot      SAY nIznD PICTURE picBHD

         @ prow(),pcol()+1 SAY nIznP PICTURE picBHD
         if cPrelomljeno=="N"
          @ prow(),pcol()+1 SAY nIznD-nIznP PICTURE picBHD
         endif
         nDugBHD+=nIznD
         nPotBHD+=nIznP


   ENDDO // partner
ENDDO  //  konto

if prow()>63+gPStranica; FF; ZaglSpK(); endif

? M
? "UKUPNO za KONTO:"
@ prow(),nKolTot  SAY nDugBHD PICTURE picBHD
@ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD

if cPrelomljeno=="N"
       @ prow(),pcol()+1 SAY nDugBHD-nPotBHD PICTURE picBHD
else

 ? " S A L D O :"
 if nDugBhd-nPotBHD>0
    nDugBHD:=nDugBHD-nPotBHD
    nPotBHD:=0
 else
    nPotBHD:=nPotBHD-nDugBHD
    nDugBHD:=0
 endif
 @ prow(),nKolTot  SAY nDugBHD PICTURE picBHD
 @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD

endif
? M

nDugBHD:=nPotBHD:=0

FF
END PRINT
closeret
return
*}


/*! \fn ZaglSpK()
 *  \brief Zaglavlje specifikacije
 */
 
function ZaglSpK()
*{
local nDSP:=0
P_COND
?? "FIN.P: SPECIFIKACIJA OTVORENIH STAVKI  ZA KONTO ",cIdKonto
if !(empty(dDatOd) .and. empty(dDatDo))
 ?? " ZA PERIOD ",dDatOd,"-",dDatDo
endif
?? "     NA DAN:",DATE()
IF !EMPTY(qqBrDok)
  ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '"+TRIM(qqBrDok)+"'"
ENDIF

@ prow(),125 SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,partn->naz,partn->naz2
endif

if cPrelomljeno=="N"
  P_COND2
endif

?
PrikK1k4(.f.)

nDSP:=LEN(PARTN->id)

? M
? "*R. *"+PADC("SIFRA",nDSP)+"*       NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *  BROJ    *               IZNOS                      *"+iif(cPrelomljeno=="N","                    *","")
? "     "+SPACE(nDSP)+"                                                                          ---------------------- --------------------"+iif(cPrelomljeno=="N"," --------------------","")
? "*BR.*"+SPACE(nDSP)+"*                                     * BROJ*                 *  VEZE    *         DUGUJE       *      POTRAZUJE    *"+iif(cPrelomljeno=="N","       SALDO        *","")
? M
SELECT SUBAN
RETURN
*}



/*! \fn AutoZat() 
 *  \brief Zatvaranje stavki automatski
 */
 
function AutoZat()
*{
cSecur:=SecurR(KLevel,"OSTAVKE")
if ImaSlovo("X",cSecur)
   MsgBeep("Opcija nedostupna !")
   return
endif
cSecur:=SecurR(KLevel,"SGLEDAJ")
if ImaSlovo("D",cSecur)
   MsgBeep("Opcija nedostupna !")
   return
endif

if Logirati(goModul:oDataBase:cName,"OSTAV","AUTOZAT")
	lLogAZat:=.t.
else
	lLogAZat:=.f.
endif

cIdFirma:=gFirma
cIdKonto:=space(7)
qqPartner:=SPACE(60)
picD:="@Z "+FormPicL("9 "+gPicBHD,18)
picDEM:="@Z "+FormPicL("9 "+gPicDEM,9)

O_PARTN
O_KONTO
Box("AZST",6,65,.f.)
set cursor on

 cPobST:="N"  // pobrisati stavke koje su se uzimale zatvorenim

 @ m_x+1,m_y+2 SAY "AUTOMATSKO ZATVARANJE STAVKI"
 if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+4,m_y+2 SAY "Konto: " GET cIdKonto  valid P_KontoFin(@cIdKonto)
 @ m_x+6,m_y+2 SAY "Pobrisati stare markere zatv.stavki: " GET cPobSt pict "@!" valid cPobSt $ "DN"


 read; ESC_BCR


BoxC()

cIdFirma:=left(cIdFirma,2)

O_SUBAN

select SUBAN; set order to 3
// ORDER 3: SUBANi3: IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)
seek cidfirma+cidkonto
EOF CRET

if cPobSt=="D" .and. Pitanje(,"Zelite li zaista pobrisati markere ??","N")=="D"
	MsgO("Brisem markere ...")
	DO WHILESC !eof() .AND. idfirma==cidfirma .and. cIdKonto=IdKonto // konto

   // partner, brdok
            REPLACE OtvSt WITH " "
            SKIP
	ENDDO
	MSgC()
endif

Box("count",1,30,.f.)
nC:=0
@ m_x+1,m_y+2 SAY "Zatvoreno:"
@ m_x+1,m_y+12 SAY nC  // brojac zatvaranja

seek cidfirma+cidkonto
EOF CRET
DO WHILESC !eof() .AND. idfirma==cidfirma .and. cIdKonto=IdKonto // konto

   cIdPartner=IdPartner; cBrDok=BrDok
   cOtvSt:=" "
   nDugBHD:=nPotBHD:=0
   DO WHILESC !eof() .AND. idfirma==cidfirma .AND. cIdKonto=IdKonto .AND. cIdPartner=IdPartner .AND. cBrDok==BrDok
   // partner, brdok
      IF D_P="1"
         nDugBHD+=IznosBHD
         cOtvSt:="1"
      ELSE
         nPotBHD+=IznosBHD
         cOtvSt:="1"
      ENDIF
      SKIP
   ENDDO // partner, brdok

   IF ABS(round(nDugBHD-nPotBHD,3))<=gnLOSt .AND. cOtvSt=="1"
      SEEK cIdFirma+cIdKonto+cIdPartner+cBrDok
      @ m_x+1,m_y+12 SAY ++nC  // brojac zatvaranja
      DO WHILESC !eof() .AND. cIdKonto=IdKonto .and. cIdPartner=IdPartner .and. cBrDok=BrDok
            REPLACE OtvSt WITH "9"
            SKIP
      ENDDO
   ENDIF

ENDDO

if lLogAZat
	EventLog(nUser,goModul:oDataBase:cName,"OSTAV","AUTOZAT",nDugBHD,nPotBHD,nC,nil,"","","F:"+cIdFirma+"- K:"+cIdKonto,Date(),Date(),"","Automatsko zatvaranje otvorenih stavki")
endif

BoxC() // counter zatvaranja

closeret
return
*}


/*! \fn RucnoZat()
 *  \brief Rucno zatvaranje otvaranih stavki
 */
 
function RucnoZat()
*{

cSecur:=SecurR(KLevel,"OSTAVKE")
if ImaSlovo("X",cSecur)
   MsgBeep("Opcija nedostupna !")
   return
endif
cSecur:=SecurR(KLevel,"SGLEDAJ")
if ImaSlovo("D",cSecur)
   MsgBeep("Opcija nedostupna !")
   return
endif

cIdFirma:=gFirma
O_PARTN
cIdPartner:=space(len(id))
picD:=FormPicL("9 "+gPicBHD,14)
picDEM:=FormPicL("9 "+gPicDEM,9)

if gRJ=="D"
  O_RJ
endif
O_KONTO
cIdKonto:=space(len(id))
Box(,7,66,)
set cursor on

 @ m_x+1,m_y+2 SAY "ISPRAVKA BROJA VEZE - OTVORENE STAVKE"
 if gNW=="D"
  @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma  " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+4,m_y+2 SAY "Konto  " GET cIdKonto  valid  P_KontoFin(@cIdKonto)
 @ m_x+5,m_y+2 SAY "Partner" GET cIdPartner valid empty(cIdPartner) .or. P_Firma(@cIdPartner) pict "@!"
 if gRj=="D"
   cIdRj:=SPACE(LEN(RJ->id))
   @ m_x+6,m_y+2 SAY "RJ" GET cidrj pict "@!" valid empty(cidrj) .or. P_Rj(@cidrj)
 endif
 read; ESC_BCR


BoxC()

if empty(cidpartner); cidpartner:="";endif
cIdFirma:=left(cIdFirma,2)

O_SUBAN


select SUBAN; set order to 1 // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr

IF gRJ=="D" .and. !EMPTY(cIdRJ)
  SET FILTER TO IDRJ==cIdRj
ENDIF


Box(,21,77)

ImeKol:={}
AADD(ImeKol,{ "O",          {|| OtvSt}             })
AADD(ImeKol,{ "Partn.",    {|| IdPartner}         })
AADD(ImeKol,{ "Br.Veze",    {|| BrDok}             })
AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}            })
AADD(ImeKol,{ "Opis",       {|| PADR(opis,20)}, "opis", {|| .t.}, {|| .t.}, "V"  })
AADD(ImeKol,{ PADR("Duguje "+ALLTRIM(ValDomaca()),13), {|| str((iif(D_P=="1",iznosbhd,0)),13,2)}     })
AADD(ImeKol,{ PADR("Potraz."+ALLTRIM(ValDomaca()),13), {|| str((iif(D_P=="2",iznosbhd,0)),13,2)}     })
AADD(ImeKol,{ "M1",         {|| m1}                })
AADD(ImeKol,{ PADR("Iznos "+ALLTRIM(ValPomocna()),14),  {|| str(iznosdem,14,2)}                       })
AADD(ImeKol,{ "nalog",      {|| idvn+"-"+brnal+"/"+rbr}                  })
Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next
Private aPPos:={2,3}  // pozicija kolone partner, broj veze
private  gTBDir:="N"
private  bGoreRed:=NIL
private  bDoleRed:=NIL
private  bDodajRed:=NIL
private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
private  TBAppend:="N"  // mogu dodavati slogove
private  bZaglavlje:=NIL
        // zaglavlje se edituje kada je kursor u prvoj koloni
        // prvog reda
private  TBSkipBlock:={|nSkip| SkipDBBK(nSkip)}
private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                        // ovo se mo§e setovati u when/valid fjama
private  TBScatter:="N"  // uzmi samo teku†e polje
adImeKol:={}
for i:=1 TO LEN(ImeKol); AADD(adImeKol,ImeKol[i]); next
adKol:={}; for i:=1 to len(adImeKol); AADD(adKol,i); next

private bBKUslov:= {|| idFirma+idkonto+idpartner=cidFirma+cidkonto+cidpartner}
private bBkTrazi:= {|| cIdFirma+cIdkonto+cIdPartner}
// Brows ekey uslova


set cursor on

private cPomBrDok:=SPACE(10)

seek eval(bBkUslov)  // pozicioniraj se na pocetak !!      ? MS 16.11.01 ?

OSt_StatLin()
ObjDbEdit("Ost",21,77,{|| EdRos()} ,"","",     ;
           .f. ,NIL, 1, {|| otvst=="9"}, 6, 0, ;  // zadnji par: nGPrazno
            NIL, {|nSkip| SkipDBBK(nSkip)} )

//BrowseKey(m_x+6,m_y+1,m_x+21,m_y+77,ImeKol,{|Ch| EdRos(Ch)},"idFirma+idkonto+idpartner=cidFirma+cidkonto+cidpartner",cidFirma+cidkonto+cidpartner,2,,,{|| otvst=="9"})


BoxC()

closeret
return
*}



/*! \fn EdROS()
 *  \brief Rucno zatvaranje otvorenih stavki 
 */
 
function EdROS()
*{
local cDn:="N",nRet:=DE_CONT

if Logirati(goModul:oDataBase:cName,"OSTAV","RUCNOZAT")
	lLogRucZat:=.t.
else
	lLogRucZat:=.f.
endif


do case
  case Ch==K_ALT_E  .and. fieldpos("_OBRDOK")=0  // nema prebacivanja u
                                                 // asistentu ot.st.
     IF gTBDir=="D"
        gTBDir:="N"
        OSt_StatLin()
        NeTBDirektni()  // ELIB, vrati stari tbrowse
     ELSE
       IF Pitanje(,"Preci u mod direktog unosa podataka u tabelu? (D/N)","D")=="D"
         gTBDir:="D"
         OSt_StatLin()
         DaTBDirektni() // ELIB, promjeni tbrowse na edit rezim
       ENDIF
     ENDIF
  case Ch==K_ENTER .and. gTBDir="N"
     cDn:="N"
     Box(,3,50)
       @ m_x+1,m_y+2 SAY "Ne preporucuje se koristenje ove opcije !"
       @ m_x+3,m_y+2 SAY "Zelite li ipak nastaviti D/N" GET cDN pict "@!" valid cDn $ "DN"
       read
     BoxC()
     if cDN=="D"  .and. gTBDir=="N"
     	if OtvSt<>"9"
        	cMark:=""
		replace OtvSt with "9"
      	else
        	cMark:="9"
		replace OtvSt with ""
      	endif
     	if lLogRucZat
		EventLog(nUser,goModul:oDataBase:cName,"OSTAV","RUCNOZAT",nil,nil,nil,nil,"",cMark,"",Date(),Date(),"","Rucno zatvaranje otvorenih stavki")
	endif
       	nRet:=DE_REFRESH
     else
     	nRet:=DE_CONT
     endif
  case (Ch==ASC("K") .or. Ch==ASC("k"))  .and. gTBDir="N"
      if m1<>"9"
        replace m1 with "9"
      else
        replace m1 with ""
      endif
      nRet:=DE_REFRESH
  case Ch==K_F2    .and. gTBDir="N"
     cBrDok:=BrDok; cOpis:=opis
     dDatDok:=datdok
     dDatVal:=datval
     Box("eddok",5,60,.f.)
       @ m_x+1,m_y+2 SAY "Broj Dokumenta (broj veze):" GET cBrDok
       @ m_x+2,m_y+2 SAY "Opis:" GET cOpis
       @ m_x+4,m_y+2 SAY "Datum dokumenta: "; ?? ddatdok
       @ m_x+5,m_y+2 SAY "Datum valute   :" GET dDatVal
       read
     BoxC()
     if lastkey()<>K_ESC
       replace BrDok with cBrDok, opis with copis, datval with ddatval
     endif
     if lLogRucZat
     	EventLog(nUser,goModul:oDataBase:cName,"OSTAV","RUCNOZAT",nil,nil,nil,nil,"",cBrDok,"Ispravka br.veze",dDatDok,dDatVal,cOpis,"Rucno zatvaranje otvorenih stavki")
     endif
     nRet:=DE_REFRESH
  case Ch==K_F5  .and. gTBDir="N"
     cPomBrDok:=BrDok
  case Ch==K_F6  .and. gTBDir="N"
     if fieldpos("_OBRDOK")<>0  // nalazimo se u asistentu
        StAz()
     else
       if Pitanje(,"Zelite li da vezni broj "+BrDok+" zamijenite brojem "+cPomBrDok+" ?","D")=="D"
         replace BrDok with cPomBrDok
       endif
     endif
     nRet:=DE_REFRESH
 case Ch==K_CTRL_P
     PushWa()
     StKart()
     PopWA()
     nRet:=DE_REFRESH
 case Ch==K_ALT_P
     PushWa()
     StBrVeze()
     PopWA()
     nRet:=DE_REFRESH
endcase
return nRet
*}



/*! \fn OSt_StatLin()
 *  \brief 
 */
 
function OSt_StatLin()
*{
if gTBDir="D"
 @ m_x+16,m_y+1 SAY space(78)
 @ m_x+17,m_y+1 SAY padr("Direktni mod za unos: ispravka opisa",78)
 @ m_x+18,m_y+1 SAY space(78)
 @ m_x+19,m_y+1 SAY REPL("Ä",78)
 @ m_x+20,m_y+1 SAY ""; ?? "Konto:",cIdKonto
else
 @ m_x+16,m_y+1 SAY " <F2>   Ispravka broja dok.       <c-P> Print   <a-P> Print Br.Dok          "
 @ m_x+17,m_y+1 SAY " <K>    Ukljuci/iskljuci racun za kamate         <F5> uzmi broj dok.        "
 @ m_x+18,m_y+1 SAY '<ENTER> Postavi/Ukini zatvaranje                 <F6> "nalijepi" broj dok.  '
 @ m_x+19,m_y+1 SAY REPL("Ä",78)
 @ m_x+20,m_y+1 SAY ""; ?? "Konto:",cIdKonto
endif

return
*}


/*! \fn StKart(fSolo,fTiho,bFilter)
 *  \brief Otvorene stavke grupisane po brojevima veze
 *  \param fSolo
 *  \param fTiho
 *  \param bFilter - npr. {|| Mjesto(cMjesto)}
 */
 
function StKart(fSolo,fTiho,bFilter)
*{
local nCol1:=72,cSvi:="N",cSviD:="N",lEx:=.f.

IF fTiho==NIL; fTiho:=.f.; ENDIF

private cIdPartner

cDokument:=SPACE(8)
picBHD:=FormPicL(gPicBHD,14)
picDEM:=FormPicL(gPicDEM,10)

IF fTiho .or. Pitanje(,"Zelite li prikaz sa datumima dokumenta i valutiranja ? (D/N)","D")=="D"
   lEx:=.t.         // lEx=.t. > varijanta napravljena za EXCLUSIVE
ENDIF

if fsolo==NIL
   fSolo:=.f.  // fsolo=.t. > poziv iz menija
endif

IF gVar1=="0"
 M:="----------- ------------- -------------- -------------- ---------- ---------- ---------- --"
ELSE
 M:="----------- ------------- -------------- -------------- --"
ENDIF

IF lEx
 m := "-------- -------- -------- " + m
ENDIF

nStr:=0
fVeci:=.f.
cPrelomljeno:="N"

if fTiho
 cSvi:="D"
elseif fsolo
 O_SUBAN
 O_PARTN
 O_KONTO
 cIdFirma:=gFirma
 cIdkonto:=space(7)
 cIdPartner:=space(6)
 Box(,5,60)
    if gNW=="D"
      @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
     else
      @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
    endif
    @ m_x+2,m_y+2 SAY "Konto:               " GET cIdkonto   pict "@!"  valid P_kontoFin(@cIdkonto)
    @ m_x+3,m_y+2 SAY "Partner (prazno svi):" GET cIdpartner pict "@!"  valid empty(cIdpartner)  .or. ("." $ cidpartner) .or. (">" $ cidpartner) .or. P_Firma(@cIdPartner)
    @ m_x+5,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"
    read; ESC_BCR
 Boxc()
else
 if Pitanje(,"Zelite li napraviti ovaj izvjestaj za sve partnere ?","N")=="D"
   cSvi:="D"
 endif
endif

if !fTiho .and. Pitanje(,"Prikazati dokumente sa saldom 0 ?","N")=="D"
   cSviD:="D"
endif

if fTiho
 // onda svi
elseif !fsolo
 if type('TB')="O"
    if VALTYPE(aPPos[1])="C"
       private cIdPartner:=aPPos[1]
    else
       private cIdPartner:=EVAL(TB:getColumn(aPPos[1]):Block)
    endif
 endif
else
 if "." $ cidpartner
     cidpartner:=strtran(cidpartner,".","")
    cIdPartner:=trim(cidPartner)
 endif
 if ">" $ cidpartner
     cidpartner:=strtran(cidpartner,">","")
     cIdPartner:=trim(cidPartner)
     fVeci:=.t.
 endif
 if empty(cIdpartner)
      cidpartner:=""
 endif
 cSvi:=cIdpartner
endif

IF fTiho .or. lEx
  // odredjivanje prirode zadanog konta (dug. ili pot.)
  // --------------------------------------------------
  select (F_TRFP2); if !used(); O_TRFP2; endif
  HSEEK "99 "+LEFT(cIdKonto,1)
  DO WHILE !EOF() .and. IDVD=="99" .and. TRIM(idkonto)!=LEFT(cIdKonto,LEN(TRIM(idkonto)))
    SKIP 1
  ENDDO
  IF IDVD=="99" .and. TRIM(idkonto)==LEFT(cIdKonto,LEN(TRIM(idkonto)))
    cDugPot:=D_P
  ELSE
    cDugPot:="1"
    Box(,3,60)
      @ m_x+2,m_y+2 SAY "Konto "+cIdKonto+" duguje / potrazuje (1/2)" get cdugpot  VALID cdugpot$"12" PICT "9"
      READ
    Boxc()
  ENDIF
  CrePom(fTiho)  // kreiraj pomocnu bazu
ENDIF


if !fTiho
  START PRINT RET
endif

nUkDugBHD:=nUkPotBHD:=0
select suban; set order to 3

if cSvi=="D"
 seek cidfirma+cidkonto
else
 seek cidfirma+cidkonto+cidpartner
endif

DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto

    if bFilter<>NIL
      if ! eval(bFilter) ; skip; loop; endif
    endif

    cidPartner:=idpartner
    //ZagkStSif()

    nUDug2:=nUPot2:=0
    nUDug:=nUPot:=0
    fPrviprolaz:=.t.
    DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner

          if bFilter<>NIL
            if ! eval(bFilter) ; skip; loop; endif
          endif
          cBrDok:=BrDok; cOtvSt:=otvst
          nDug2:=nPot2:=0
          nDug:=nPot:=0
          aFaktura:={CTOD(""),CTOD(""),CTOD("")}
          DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner ;
                     .and. brdok==cBrDok
             IF D_P=="1"
                nDug+=IznosBHD
                nDug2+=IznosDEM
             ELSE
                nPot+=IznosBHD
                nPot2+=IznosDEM
             ENDIF
             IF lEx .and. D_P==cDugPot
               aFaktura[1]:=DATDOK
               aFaktura[2]:=DATVAL
             ENDIF

             IF fTiho     // poziv iz procedure RekPPG()
               // za izvjestaj maksuz radjen za Opresu³22.03.01.³
               // ------------------------------------ÀÄ MSÄÄÄÄÄÙ
               if afaktura[3] < iif( empty(DatVal), DatDok, DatVal )
                         // datum zadnje promjene iif ubacen 03.11.2000 eh
                         // ----------------------------------------------
                 aFaktura[3]:=iif( empty(DatVal), DatDok, DatVal )
               endif
             ELSE
               // kao u asist.otv.stavki - koristi npr. Exclusive³22.03.01.³
               // -----------------------------------------------ÀÄ MSÄÄÄÄÄÙ
               if afaktura[3] < DatDok
                  aFaktura[3]:=DatDok
               endif
             ENDIF

             SKIP 1
          ENDDO

          if csvid=="N" .and. round(ndug-npot,2)==0
             // nista
          else
           IF lEx
             fPrviProlaz:=.f.
             if cPrelomljeno=="D"
                if (ndug-npot)>0
                   nDug:=nDug-nPot
                   nPot:=0
                else
                   nPot:=nPot-nDug
                   nDug:=0
                endif
                if (ndug2-npot2)>0
                   nDug2:=nDug2-nPot2
                   nPot2:=0
                else
                   nPot2:=nPot2-nDug2
                   nDug2:=0
                endif
             endif
             SELECT POM; APPEND BLANK
             Scatter()
              _idpartner := cIdPartner
              _datdok    := aFaktura[1]
              _datval    := aFaktura[2]
              _datzpr    := aFaktura[3]
              if empty(_DatDok) .and. empty(_DatVal)  // 03.11.2000 eh
               _DatVal:=_DatZPR
              endif
              _brdok     := cBrDok
              _dug       := nDug
              _pot       := nPot
              _dug2      := nDug2
              _pot2      := nPot2
              _otvst     := cOtvSt
             Gather()
             SELECT SUBAN
           ELSE
             if !fTiho
               IF prow()>52+gPStranica; FF; ZagKStSif(.t.,lEx); fPrviProlaz:=.f.; ENDIF
               if fPrviProlaz
                  ZagkStSif(,lEx)
                  fPrviProlaz:=.f.
               endif
               ? padr(cBrDok,10)
               nCol1:=pcol()+1
             endif
             if cPrelomljeno=="D"
                if (ndug-npot)>0
                   nDug:=nDug-nPot
                   nPot:=0
                else
                   nPot:=nPot-nDug
                   nDug:=0
                endif
                if (ndug2-npot2)>0
                   nDug2:=nDug2-nPot2
                   nPot2:=0
                else
                   nPot2:=nPot2-nDug2
                   nDug2:=0
                endif
             endif
             if !fTiho
               @ prow(),nCol1 SAY nDug PICTURE picBHD
               @ prow(),pcol()+1  SAY nPot PICTURE picBHD
               @ prow(),pcol()+1  SAY nDug-nPot PICTURE picBHD
               IF gVar1=="0"
                @ prow(),pcol()+1  SAY nDug2 PICTURE picdem
                @ prow(),pcol()+1  SAY nPot2 PICTURE picdem
                @ prow(),pcol()+1  SAY nDug2-nPot2 PICTURE picdem
               ENDIF
               @ prow(),pcol()+2  SAY cOtvSt
             endif
             nUDug+=nDug; nUPot+=nPot
             nUDug2+=nDug2; nUPot2+=nPot2
           ENDIF
          endif

    enddo // partner

    if !fTiho
      IF prow()>58+gPStranica; FF; ZagKStSif(.t.,lEx); ENDIF
      if !lEx .and. !fPrviProlaz  // bilo je stavki
       ? M
       ? "UKUPNO:"
       @ prow(),nCol1 SAY nUDug PICTURE picBHD
       @ prow(),pcol()+1 SAY nUPot PICTURE picBHD
       @ prow(),pcol()+1 SAY nUDug-nUPot PICTURE picBHD
       IF gVar1=="0"
        @ prow(),pcol()+1 SAY nUDug2 PICTURE picdem
        @ prow(),pcol()+1 SAY nUPot2 PICTURE picdem
        @ prow(),pcol()+1 SAY nUDug2-nUPot2 PICTURE picdem
       ENDIF
       ? m
      endif
    endif
  if fTiho
    // idu svi
  elseif fsolo // iz menija
    if (!fveci .and. idpartner=cSvi) .or. fVeci
      if !lEx .and. !fPrviProlaz
       ? ;  ? ; ?
      endif
    else
      exit
    endif
  else
   if cSvi<>"D"
     exit
   else
      if !lEx .and. !fPrviProlaz
       ? ;  ? ; ?
      endif
   endif
  endif // fsolo
enddo

IF !fTiho .and. lEx   // ako je EXCLUSIVE, sada tek stampaj
  SELECT POM
  GO TOP
  DO WHILE !EOF()
    fPrviProlaz:=.t.
    cIdPartner:=IDPARTNER
    nUDug:=nUPot:=nUDug2:=nUPot2:=0
    DO WHILESC !EOF() .and. cIdPartner==IdPartner
      IF prow()>52+gPStranica; FF; ZagKStSif(.t.,lEx); fPrviProlaz:=.f.; ENDIF
      if fPrviProlaz
         ZagkStSif(,lEx)
         fPrviProlaz:=.f.
      endif
      SELECT POM
      ? datdok,datval,datzpr, PADR(brdok,10)
      nCol1:=pcol()+1
      ?? " "
      ?? TRANSFORM(dug,picbhd),;
         TRANSFORM(pot,picbhd),;
         TRANSFORM(dug-pot,picbhd)
      IF gVar1=="0"
        ?? " "+TRANSFORM(dug2,picdem),;
               TRANSFORM(pot2,picdem),;
               TRANSFORM(dug2-pot2,picdem)
      ENDIF
      ?? "  "+otvst
      nUDug+=Dug; nUPot+=Pot
      nUDug2+=Dug2; nUPot2+=Pot2
      SKIP 1
    ENDDO
    IF prow()>58+gPStranica; FF; ZagKStSif(.t.,lEx); ENDIF
    SELECT POM
    if !fPrviProlaz  // bilo je stavki
      ? M
      ? "UKUPNO:"
      @ prow(),nCol1 SAY nUDug PICTURE picBHD
      @ prow(),pcol()+1 SAY nUPot PICTURE picBHD
      @ prow(),pcol()+1 SAY nUDug-nUPot PICTURE picBHD
      IF gVar1=="0"
        @ prow(),pcol()+1 SAY nUDug2 PICTURE picdem
        @ prow(),pcol()+1 SAY nUPot2 PICTURE picdem
        @ prow(),pcol()+1 SAY nUDug2-nUPot2 PICTURE picdem
      ENDIF
      ? m
    endif
    ? ; ? ; ?
  ENDDO
ENDIF

if fTiho
  RETURN (NIL)
endif

FF

END PRINT

select (F_POM); use

IF fSolo
  CLOSERET
ELSE
  RETURN (NIL)
ENDIF
*}



/*! \fn CrePom(fTiho)
 *  \brief Kreira pomocnu tabelu
 *  \fTiho
 */
 
function CrePom(fTiho)
*{
IF fTiho==NIL; fTiho:=.f.; ENDIF
select (F_POM); USE
// kreiranje pomocne baze POM.DBF
// ------------------------------
cPom:=PRIVPATH+"POM"
  IF ferase(PRIVPATH+"POM.DBF")==-1
    MsgBeep("Ne mogu izbrisati POM.DBF!")
    ShowFError()
  ENDIF
  IF ferase(PRIVPATH+"POM.CDX")==-1
    MsgBeep("Ne mogu izbrisati POM.CDX!")
    ShowFError()
  ENDIF
  // ferase(cPom+".CDX")
aDbf := {}
AADD(aDBf,{ 'IDPARTNER'   , 'C' ,  6 ,  0 })
AADD(aDBf,{ 'DATDOK'      , 'D' ,  8 ,  0 })
AADD(aDBf,{ 'DATVAL'      , 'D' ,  8 ,  0 })
AADD(aDBf,{ 'BRDOK'       , 'C' , 10 ,  0 })
AADD(aDBf,{ 'DUG'         , 'N' , 17 ,  2 })
AADD(aDBf,{ 'POT'         , 'N' , 17 ,  2 })
AADD(aDBf,{ 'DUG2'        , 'N' , 15 ,  2 })
AADD(aDBf,{ 'POT2'        , 'N' , 15 ,  2 })
AADD(aDBf,{ 'OTVST'       , 'C' ,  1 ,  0 })
AADD(aDBf,{ 'DATZPR'      , 'D' ,  8 ,  0 })  // datum zadnje promjene
IF fTiho
  FOR i:=1 TO LEN(aGod)
    AADD(aDBf,{ 'GOD'+aGod[i,1], 'N' , 15 ,  2 })  // godina valute
  NEXT
  AADD(aDBf,{ 'GOD'+STR(VAL(aGod[i-1,1])-1,4), 'N' , 15 ,  2 })  // godina valute
  AADD(aDBf,{ 'GOD'+STR(VAL(aGod[i-1,1])-2,4), 'N' , 15 ,  2 })  // godina valute
ENDIF
DBCREATE2 (cPom, aDbf)
USEX (cPom)
INDEX ON IDPARTNER+DTOS(DATDOK)+DTOS(IIF(EMPTY(DATVAL),DATDOK,DATVAL))+BRDOK TAG "1"
SET ORDER TO TAG "1" ; GO TOP
return .t.
*}



/*! \fn ZagKStSif(fStrana,lEx)
 *  \brief Zaglavlje kartice OS-a
 *  \param fStrana
 *  \param lEx
 */
 
function ZagKStSif(fStrana,lEx)
*{
IF gVar1=="0"
  IF lEx
    P_COND
  ELSE
    F12CPI
  ENDIF
ELSE
  F10CPI
ENDIF
if fStrana==NIL
  fStrana:=.f.
endif

if nStr=0
  fStrana:=.t.
endif

?? "FIN.P: OTV.STAVKE - PREGLED (GRUPISANO PO BROJEVIMA VEZE)  NA DAN "; ?? DATE()
if fStrana
 @ prow(),110 SAY "Str:"+str(++nStr,3)
endif

SELECT PARTN; HSEEK cIdFirma
? "FIRMA:",cIdFirma,"-",gNFirma

SELECT KONTO; HSEEK cIdKonto

? "KONTO  :",cIdKonto,naz

SELECT PARTN; HSEEK cIdPartner
? "PARTNER:", cIdPartner,TRIM(naz)," ",TRIM(naz2)," ",TRIM(mjesto)

select suban
? M
?
IF lEx
  ?? "Dat.dok.*Dat.val.*Dat.ZPR.* "
ELSE
  ?? "*"
ENDIF
IF gVar1=="0"
 ?? "  BrDok   *   dug "+ValDomaca()+"  *   pot "+ValDomaca()+"   *  saldo  "+ValDomaca()+" * dug "+ValPomocna()+" * pot "+ValPomocna()+" *saldo "+ValPomocna()+"*O*"
ELSE
 ?? "  BrDok   *   dug "+ValDomaca()+"  *   pot "+ValDomaca()+"   *  saldo  "+ValDomaca()+" *O*"
ENDIF
? M

SELECT SUBAN
RETURN
*}



/*! \fn StBrVeze()
 *  \brief Stampa broja veze
 */
 
function StBrVeze()
*{
local nCol1:=35
cDokument:=SPACE(8)
picBHD:=FormPicL(gPicBHD,13)
picDEM:=FormPicL(gPicDEM,10)
IF gVar1=="0"
 M:="-------- -------- "+"------- ---- -- ------------- ------------- ------------- ---------- ---------- ---------- --"
ELSE
 M:="-------- -------- "+"------- ---- -- ------------- ------------- ------------- --"
ENDIF

nStr:=0

START PRINT RET


if VALTYPE(aPPos[1])="C"
   private cIdPartner:=aPPos[1]
else
   private cIdPartner:=EVAL(TB:getColumn(aPPos[1]):Block)
endif
if VALTYPE(aPPos[2])="C"
   private cBrDok:=aPPos[2]
else
   private cBrDok:=EVAL(TB:getColumn(aPPos[2]):Block)
endif

nUkDugBHD:=nUkPotBHD:=0
select suban; set order to 3
seek cidfirma+cidkonto+cidpartner+cBrDok


nDug2:=nPot2:=0
nDug:=nPot:=0
ZagBRVeze()
DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner ;
        .and. brdok==cBrDok

         IF prow()>63+gPStranica; FF; ZagBRVeze(); ENDIF
         ? datdok,datval,idvn,brnal,rbr,idtipdok
         nCol1:=pcol()+1
         IF D_P=="1"
            nDug+=IznosBHD
            nDug2+=IznosDEM
            @ prow(),pcol()+1 SAY iznosbhd pict picbhd
            @ prow(),pcol()+1 SAY space(len(picbhd))
            @ prow(),pcol()+1  SAY nDug-nPot pict picbhd
            IF gVar1=="0"
             @ prow(),pcol()+1 SAY iznosdem pict picdem
             @ prow(),pcol()+1 SAY space(len(picdem))
             @ prow(),pcol()+1  SAY nDug2-nPot2 pict picdem
            ENDIF
         ELSE
            nPot+=IznosBHD
            nPot2+=IznosDEM
            @ prow(),pcol()+1 SAY space(len(picbhd))
            @ prow(),pcol()+1 SAY iznosbhd pict picbhd
            @ prow(),pcol()+1  SAY nDug-nPot  pict picbhd
            IF gVar1=="0"
             @ prow(),pcol()+1 SAY space(len(picdem))
             @ prow(),pcol()+1 SAY iznosdem pict picdem
             @ prow(),pcol()+1  SAY nDug2-nPot2  pict picdem
            ENDIF
         ENDIF
         @ prow(),pcol()+2  SAY OtvSt
         skip
enddo // partner

IF prow()>62+gPStranica; FF; ZagBRVeze(); ENDIF

? m
? "UKUPNO:"
@ prow(),nCol1     SAY nDug PICTURE picBHD
@ prow(),pcol()+1  SAY nPot PICTURE picBHD
@ prow(),pcol()+1  SAY nDug-nPot PICTURE picBHD
IF gVar1=="0"
 @ prow(),pcol()+1  SAY nDug2 PICTURE picdem
 @ prow(),pcol()+1  SAY nPot2 PICTURE picdem
 @ prow(),pcol()+1  SAY nDug2-nPot2 PICTURE picdem
ENDIF
? m

FF
END PRINT
*}


/*! \fn ZagBRVeze()
 *  \brief Zaglavlje izvjestaja broja veze
 */
 
function ZagBRVeze()
*{
IF gVar1=="0"
 P_COND
ELSE
 F12CPI
ENDIF
?? "FIN.P: KARTICA ZA ODREDJENI BROJ VEZE      NA DAN "; ?? DATE()
@ prow(),110 SAY "Str:"+str(++nStr,3)
SELECT PARTN; HSEEK cIdFirma
? "FIRMA:", cIdFirma,naz, naz2

SELECT KONTO; HSEEK cIdKonto
? "KONTO  :", cIdKonto,naz

SELECT PARTN; HSEEK cIdPartner
? "PARTNER:", cIdPartner,TRIM(naz)," ",TRIM(naz2)," ",TRIM(mjesto)

select suban
? "BROJ VEZE :",cBrDok
? M
IF gVar1=="0"
 ? "Dat.dok.*Dat.val."+"*NALOG * Rbr*TD*   dug "+ValDomaca()+"   *  pot "+ValDomaca()+"  *   saldo "+ValDomaca()+"*  dug "+ValPomocna()+"* pot "+ValPomocna()+" *saldo "+ValPomocna()+"* O"
ELSE
 ? "Dat.dok.*Dat.val."+"*NALOG * Rbr*TD*   dug "+ValDomaca()+"   *  pot "+ValDomaca()+"  *   saldo "+ValDomaca()+"* O"
ENDIF
? M

SELECT SUBAN
RETURN
*}




/*! \fn Kompenzacija()
 *  \brief Pravljenje "Izjave o kompenzaciji"
 */
 
function Kompenzacija()
*{
cIdFirma:=gFirma
private picBHD:=FormPicL(gPicBHD,16)
private picDEM:=FormPicL(gPicDEM,12)

if !IzvrsenIn(,,"KOMPEN", .t. )
  MsgBeep("Modul KOMPEN nije registrovan za koristenje !")
  return
endif


O_KONTO ; O_PARTN

dDatOd:=dDatDo:=ctod("")
private qqKonto:=qqKonto2:=qqPartner:=""

if gNW=="D";cIdFirma:=gFirma; endif
cPoVezi:="D"

lIzgen:=.f.
cPrelomljeno:="N"
qqKonto:=padr(qqKonto,7)
qqKonto2:=padr(qqKonto2,7)
qqPartner:=padr(qqPartner,6)

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
RPar("k1",@qqKonto)
RPar("k2",@qqKonto2)
RPar("k3",@qqPartner)
RPar("k4",@dDatOd)
RPar("k5",@dDatDo)
RPar("k6",@cPoVezi)
RPar("k7",@cPrelomljeno)
select params; use

IF Pitanje(,"Izgenerisati stavke za kompenzaciju?","N")=="D"

 lIzgen:=.t.

 Box("",18,65)

  set cursor on
  @ m_x+1,m_y+2 SAY 'KREIRANJE OBRASCA "IZJAVA O KOMPENZACIJI"'

  do while .t.

   if gNW=="D"
     @ m_x+5,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
   else
    @ m_x+5,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
   endif

   @ m_x+6,m_y+2 SAY "Konto duguje   " GET qqKonto  valid P_KontoFin(@qqKonto)
   @ m_x+7,m_y+2 SAY "Konto potrazuje" GET qqKonto2  valid P_KontoFin(@qqKonto2) .and. qqKonto2>qqkonto
   @ m_x+8,m_y+2 SAY "Partner-duznik " GET qqPartner valid P_Firma(@qqPartner)  pict "@!"

   @ m_x+9,m_y+2 SAY "Datum dokumenta od:" GET dDatod
   @ m_x+9,col()+2 SAY "do" GET dDatDo   valid dDatOd<=dDatDo
   @ m_x+11,m_y+2 SAY "Sabrati po brojevima veze D/N ?"  GET cPoVezi valid cPoVezi $ "DN" pict "@!"
   @ m_x+11,col()+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cprelomljeno $ "DN" pict "@!"

   read; ESC_BCR

   exit

  enddo

 BoxC()

 O_PARAMS
 private cSection:="5",cHistory:=" "; aHistory:={}
 WPar("k1",qqKonto)
 WPar("k2",qqKonto2)
 WPar("k3",qqPartner)
 WPar("k4",dDatOd)
 WPar("k5",dDatDo)
 WPar("k6",cPoVezi)
 WPar("k7",cPrelomljeno)
 select params; use

ENDIF

private picBHD:=FormPicL(gPicBHD,14)

IF lIzgen .or. !FILE("TEMP12.DBF")
  aTmp := {}
  AADD( aTmp , { "BRDOK"    , "C" , 10 , 0 } )
  AADD( aTmp , { "IZNOSBHD" , "N" , 17 , 2 } )
  AADD( aTmp , { "MARKER"   , "C" ,  1 , 0 } )
  DBCREATE2("TEMP12.DBF",aTmp)
ENDIF

SELECT 77
USEX TEMP12 ALIAS TEMP12
index on brisano tag "BRISAN"
//ZAP

IF lIzgen .or. !FILE("TEMP60.DBF")
  aTmp := {}
  AADD( aTmp , { "BRDOK"    , "C" , 10 , 0 } )
  AADD( aTmp , { "IZNOSBHD" , "N" , 17 , 2 } )
  AADD( aTmp , { "MARKER"   , "C" ,  1 , 0 } )
  DBCREATE2("TEMP60.DBF",aTmp)
ENDIF

SELECT 78
USEX TEMP60 ALIAS TEMP60
index on brisano tag "BRISAN"
//ZAP

IF lIzgen

O_SUBAN
O_TDOK

select SUBAN
if cPoVezi=="D"
 //SUBANi3","IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)",KUMPATH+"SUBAN")
 set order to 3
endif

private cFilter
cFilter:=".t."+IF(EMPTY(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
               IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))

if cfilter==".t."
  set filter to
else
  set filter to &cFilter
endif
   //HSEEK cIdFirma+qqKonto+qqPartner

nStr:=0

SEEK cidfirma+qqkonto+qqpartner
if !found() // nema na 1200
  SEEK cidfirma+qqkonto2+qqpartner
endif

NFOUND CRET

// START PRINT CRET

nSviD:=nSviP:=nSviD2:=nSviP2:=0

nKonD:=nKonP:=nKonD2:=nKonP2:=0
cIdKonto:=IdKonto

nProlaz:=0

if empty(qqpartner)  // prodji tri puta
   nProlaz:=1
   HSEEK cidfirma+qqkonto
   if eof()
     nProlaz:=2
     HSEEK cidfirma+qqkonto2
   endif
endif

do while .t.

  if !eof() .and. idfirma==cidfirma .and. ;
     ( (nProlaz=0 .and. (idkonto==qqkonto .or. idkonto==qqkonto2))  .or. ;
       (nProlaz=1 .and. idkonto=qqkonto) .or. ;
       (nProlaz=2 .and. idkonto=qqkonto2) ;
     )
  else
    exit
  endif

    nPDugBHD:=nPPotBHD:=nPDugDEM:=nPPotDEM:=0  // prethodni promet
    nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
    nZDugBHD:=nZPotBHD:=nZDugDEM:=nZPotDEM:=0
    cIdPartner:=IdPartner

    fProsao:=.f.
    do whilesc !eof() .and. IdFirma==cIdFirma .and. cIdPartner==idpartner .and. (idkonto==qqkonto .or. idkonto==qqkonto2)

          cIdKonto:=idkonto
          cOtvSt:=OtvSt
          if !(cOtvSt=="9")
              fprosao:=.t.
              SELECT SUBAN
              IF cIdKonto==qqKonto
                SELECT TEMP12
              ELSE
                SELECT TEMP60
              ENDIF
              APPEND BLANK
              REPLACE brdok WITH SUBAN->brdok
              tIdKonto:=cIdKonto
              SELECT SUBAN
          endif // fOtvStr

          nDBHD:=nPBHD:=nDDEM:=nPDEM:=0
          if cPovezi=="D"
             cBrDok:=brdok
             do whilesc !eof() .and. IdFirma==cIdFirma .and. cIdpartner==idpartner .and. (idkonto==qqkonto .or. idkonto==qqkonto2) .and. brdok==cBrdok
                IF D_P=="1"
                  nDBHD+=iznosbhd
                  nDDEM+=iznosdem
                ELSE
                  nPBHD+=iznosbhd
                  nPDEM+=iznosdem
                endif
                skip
             enddo
             if cPrelomljeno=="D"
                 Prelomi(@nDBHD,@nPBHD)
                 Prelomi(@nDDEM,@nPDEM)
             endif
          else
             IF D_P=="1"
               nDBHD+=iznosbhd; nDDEM+=iznosdem
             ELSE
               nPBHD+=iznosbhd; nPDEM+=iznosdem
             endif
          endif
           if cOtvSt=="9"
             nZDugBHD+=nDBHD
             nZPotBHD+=nPBHD
           else // otvorena stavka
//             @ prow(),pcol()+1 SAY nDBHD PICTURE picBHD
//             @ prow(),pcol()+1 SAY nPBHD  PICTURE picBHD
             IF tIdKonto==qqKonto
               SELECT TEMP12
               IF nDBHD>0
                 REPLACE iznosbhd WITH nDBHD
                 IF nPBHD>0
                   Scatter()
                   APPEND BLANK
                   Gather()
                   REPLACE iznosbhd WITH -nPBHD
                 ENDIF
               ELSE
                 REPLACE iznosbhd WITH -nPBHD
               ENDIF
             ELSE
               SELECT TEMP60
               IF nPBHD>0
                 REPLACE iznosbhd WITH nPBHD
                 IF nDBHD>0
                   Scatter()
                   APPEND BLANK
                   Gather()
                   REPLACE iznosbhd WITH -nDBHD
                 ENDIF
               ELSE
                 REPLACE iznosbhd WITH -nDBHD
               ENDIF
             ENDIF
             SELECT SUBAN
             nDugBHD+=nDBHD
             nPotBHD+=nPBHD
           endif

          if cPoVezi<>"D"
            SKIP
          endif
          if nprolaz=0 .or. nProlaz=1
            if (idkonto<>cidkonto .or. idpartner<>cIdpartner) .and. cidkonto==qqkonto
              hseek cidfirma+qqkonto2+cIdpartner
            endif
          endif

     enddo // konto

     nKonD+=nDugBHD;  nKonP+=nPotBHD
     nKonD2+=nDugDEM; nKonP2+=nPotDEM

  if nProlaz=0
     exit
  elseif nprolaz==1
     seek cidfirma+qqkonto+cidpartner+chr(255)
     if qqkonto<>idkonto // nema vise
        nProlaz:=2
        seek cidfirma+qqkonto2
        cIdpartner:=replicate("",len(idpartner))
        if !found()
          exit
        endif
     endif
  endif

  if nprolaz==2
      do while .t.
       seek cidfirma+qqkonto2+cidpartner+chr(255)
       nTRec:=recno()
       if idkonto==qqkonto2
         cIdPartner:=idpartner
         hseek cidfirma+qqkonto+cIdpartner
         if !found() // ove kartice nije bilo
            go nTRec
            exit
         else
            loop  // vrati se traziti
         endif
       endif
       exit
      enddo
  endif

enddo

ENDIF  // kraj linije   IF lIzgen

// browsanje

ImeKol:={ ;
          {"Br.racuna", {|| brdok    }, "brdok"    } ,;
          {"Iznos",     {|| iznosbhd }, "iznosbhd" } ,;
          {"Marker",    {|| IF(marker=="K","ÛÛKÛÛÛ","      ") }, "marker" } ;
        }

Kol:={}; for i:=1 to LEN(ImeKol); AADD(Kol,i); next
Box(,21,77)
@ m_x,m_y+20 SAY 'KREIRANJE OBRASCA "IZJAVA O KOMPENZACIJI"'
@ m_x+18,m_y+1 SAY REPL("Í",77)
@ m_x+19,m_y+1 SAY "<K> - izaberi/ukini racun za kompenzaciju"
@ m_x+20,m_y+1 SAY "<CTRL>+<P> - stampanje kompenzacije               <T> - promijeni tabelu"
@ m_x+21,m_y+1 SAY "<CTRL>+<N> - nova,   <CTRL>+<T> - brisanje,   <ENTER> - ispravka stavke "
FOR i:=1 TO 17
  @ m_x+i, m_y+39 SAY "º"
NEXT

SELECT TEMP60; GO TOP
SELECT TEMP12; GO TOP; m_y+=40

DO WHILE .t.

 IF ALIAS()=="TEMP12"
   m_y-=40
 ELSEIF ALIAS()=="TEMP60"
   m_y+=40
 ENDIF

 ObjDbedit("komp1",15,38,{|| EdKomp()},"", IF(ALIAS()=="TEMP12","DUGUJE "+qqKonto,"POTRAZUJE "+qqKonto2), , , , ,1)
 IF LASTKEY()==K_ESC; EXIT; ENDIF

ENDDO

BoxC()

#IFDEF CAX
  close all
#ENDIF
CLOSERET
return
*}


/*! \fn EdKomp()
 *  \brief Ispravka kompenzacije 
 */
 
function EdKomp()
*{
local nTr2, GetList:={}, nRec:=RECNO(), nX:=m_x, nY:=m_y, nVrati:=DE_CONT

IF ! ( (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0 )
 do case

   case Ch==ASC("K") .or. Ch==ASC("k")      // markiranje racuna
      REPLACE marker WITH IF( marker=="K" , " " , "K" )
     nVrati := DE_REFRESH

   case Ch==K_CTRL_P                        // stampanje kompenzacije
      StKompenz()
     nVrati := DE_CONT

   case Ch==K_CTRL_N                        // dodavanje stavki
      GO BOTTOM; SKIP 1
      Scatter()
      Box(,5,70)
        @ m_x+2, m_y+2 SAY "Br.racuna " GET _brdok
        @ m_x+3, m_y+2 SAY "Iznos     " GET _iznosbhd
        READ
      BoxC()
      IF LASTKEY() == K_ESC
        GO (nRec)
      ELSE
        APPEND BLANK; Gather()
        nVrati := DE_REFRESH
      ENDIF

   case Ch==K_CTRL_T                        // brisanje stavke
      if Pitanje("p01","Zelite izbrisati ovu stavku ?","D")=="D"
        delete
        nVrati := DE_REFRESH
      endif

   case Ch==K_ENTER                         // ispravka stavke
      Scatter()
      Box(,5,70)
        @ m_x+2, m_y+2 SAY "Br.racuna " GET _brdok
        @ m_x+3, m_y+2 SAY "Iznos     " GET _iznosbhd
        READ
      BoxC()
      IF LASTKEY() == K_ESC
        GO (nRec)
      ELSE
        Gather()
        nVrati := DE_REFRESH
      ENDIF

   case Ch==ASC("T") .or. Ch==ASC("t")      // prebacivanje na drugu tabelu
      IF ALIAS()=="TEMP12"
        SELECT TEMP60; GO TOP
      ELSEIF ALIAS()=="TEMP60"
        SELECT TEMP12; GO TOP
      ENDIF
     nVrati := DE_ABORT

 endcase
ENDIF
m_x:=nX
m_y:=nY
return nVrati
*}


/*! \fn StKompenz()
 *  \brief Stampa kompenzacije
 */
 
function StKompenz()
*{
LOCAL a1:={}, a2:={}, GetList:={}
 LOCAL cIdPov:=SPACE(6)
 LOCAL nLM:=5, nLin, nPocetak, i:=0, j:=0, k:=0

 nUkup12:=0; nUkup60:=0; cBrKomp:=SPACE(10); nSaldo:=0; nRokPl:=7
 cVal:="D"; dKomp:=DATE()

 PushWA()

 O_PARAMS
 Private cSection:="4",cHistory:=" ",aHistory:={}
 RPar("ip",@cIdPov)
 RPar("bk",@cBrKomp)

 Box(,8,50)
   @ m_x+2, m_y+2 SAY "Datum kompenzacije: " GET dKomp
   @ m_x+3, m_y+2 SAY "Rok placanja (dana): " GET nRokPl VALID nRokPl>=0 PICT "999"
   @ m_x+4, m_Y+2 SAY "Valuta kompenzacije (D/P): " GET cVal  valid cVal $ "DP"  pict "!@"
   @ m_x+5, m_Y+2 SAY "Broj kompenzacije: " GET cBrKomp
   @ m_x+6, m_Y+2 SAY "Sifra (ID) povjerioca: " GET cIdPov VALID P_Firma(@cIdPov) PICT "@!"
   READ
 BoxC()

 WPar("ip",cIdPov)
 WPar("bk",cBrKomp)
 select params; use

  START PRINT RET
  gp10cpi()

  SELECT (F_PARTN)
  HSEEK cIdPov
  aPov1:=ALLTRIM(naz)
  aPov2:=ALLTRIM(mjesto)
  aPov3:=ALLTRIM(ziror)
  aPov4:=ALLTRIM(dziror)
  aPov5:=IzSifK( "PARTN" , "REGB" , id , .f. )
  aPov6:=IzSifK( "PARTN" , "PORB" , id , .f. )
  aPov7:=ALLTRIM(telefon)
  aPov8:=ALLTRIM(adresa)
  aPov10:=ALLTRIM(fax)

  if cVal=="P"
  	aPov9:=ALLTRIM(IzFmkIni("KOMPEN","RacunPomValute","",KUMPATH))
  else
    	aPov9:=aPov3
  endif

  HSEEK qqPartner
  aDuz5:=IzSifK( "PARTN" , "REGB" , id , .f. )
  aDuz6:=IzSifK( "PARTN" , "PORB" , id , .f. )
  aDuz7:=ALLTRIM(telefon)
  aDuz8:=ALLTRIM(adresa)
  aDuz10:=ALLTRIM(fax)

  if empty(gFKomp)
    for i:=1 to gnTMarg; QOUT(); next
  else
    nLin:=BrLinFajla(PRIVPATH+TRIM(gFKomp))
    nPocetak:=0; nPreskociRedova:=0
    FOR i:=1 TO nLin
      aPom:=SljedLin(PRIVPATH+TRIM(gFKomp),nPocetak)
      nPocetak:=aPom[2]
      cLin:=aPom[1]
      IF nPreskociRedova>0
        --nPreskociRedova
        LOOP
      ENDIF
      IF RIGHT(cLin,4)=="#T1#"
        nLM:=LEN(cLin)-4

        SELECT TEMP12; GO TOP; SELECT TEMP60; GO TOP

        lTemp12:=.t.; lTemp60:=.t.; nBrSt:=0

        SkipT12i60()

        DO WHILE lTemp12 .or. lTemp60

          ++nBrSt

          IF lTemp60
            ? SPACE(nLM) + "³"+STR(nBrSt,4)+".³"+brdok+"³"+STR(iznosbhd,17,2)
            nUkup60+=iznosbhd
          ELSE
            ? SPACE(nLM) + "³     ³"+SPACE(10)+"³"+SPACE(17)
          ENDIF

          SELECT TEMP12
          IF lTemp12
            ?? "³"+STR(nBrSt,4)+".³"+brdok+"³"+STR(iznosbhd,17,2)+"³"
            nUkup12+=iznosbhd
          ELSE
            ?? "³     ³"+SPACE(10)+"³"+SPACE(17)+"³"
          ENDIF
          SKIP 1

          SELECT TEMP60; SKIP 1
          SkipT12i60()

        ENDDO

        FOR j:=nBrSt+1 TO 11
          ? SPACE(nLM) + "³     ³"+SPACE(10)+"³"+SPACE(17)+"³     ³"+SPACE(10)+"³"+SPACE(17)+"³"
        NEXT
        nSaldo:=ABS(nUkup12-nUkup60)

      ELSE
        ?
        DO WHILE .t.
          nPom:=AT("#",cLin)
          IF nPom>0
            cPom:=SUBSTR(cLin,nPom,4)
            IF SUBSTR(cPom,2,2)=="LS"             // uslov za saldo
              IF nSaldo==0 .or. nUkup60>nUkup12
                nPreskociRedova := VAL(SUBSTR(cLin,nPom+4,2)) - 1
                EXIT
              ELSE     // nUkup60<nUkup12
                cLin:=STUFF(cLin,nPom,7,"")
                nPom:=AT("#",cLin)
              ENDIF
            ELSEIF SUBSTR(cPom,2,2)=="2S"             // uslov za saldo
              IF nSaldo==0 .or. nUkup60<nUkup12
                nPreskociRedova := VAL(SUBSTR(cLin,nPom+4,2)) - 1
                EXIT
              ELSE     // nUkup60>nUkup12
                cLin:=STUFF(cLin,nPom,7,"")
                nPom:=AT("#",cLin)
              ENDIF
            ENDIF
          ENDIF
          IF nPom>0
            cPom:=SUBSTR(cLin,nPom,4)
            aPom:=UzmiVar( SUBSTR(cPom,2,2) )
            ?? LEFT(cLin,nPom-1)
            cLin:=SUBSTR(cLin,nPom+4)
            IF !EMPTY(aPom[1])
              PrnKod_ON(aPom[1])
            ENDIF
            IF aPom[1]=="K"
              cPom:=&(aPom[2])
            ELSE
              cPom:=&(aPom[2])
              ?? cPom
            ENDIF
            IF !EMPTY(aPom[1])
              PrnKod_OFF(aPom[1])
            ENDIF
          ELSE
            ?? cLin
            EXIT
          ENDIF
        ENDDO
      ENDIF
    NEXT
  endif
  FF
  END PRINT
 PopWA()
RETURN (NIL)
*}


/*! \fn SkipT12i60()
 *  \brief 
 */
 
static function SkipT12i60()
*{
LOCAL nArr:=SELECT()

  SELECT TEMP12
  DO WHILE marker!="K" .and. !EOF(); SKIP 1; ENDDO
  IF EOF(); lTemp12:=.f.; ENDIF

  SELECT TEMP60
  DO WHILE marker!="K" .and. !EOF(); SKIP 1; ENDDO
  IF EOF(); lTemp60:=.f.; ENDIF

  SELECT (nArr)
RETURN (NIL)
*}


/*! \fn UzmiVar(cVar)
 *  \brief Uzmi varijable 
 *  \param cVar - varijabla
 */
 
function UzmiVar(cVar)
*{
LOCAL cVrati:=""
 DO CASE
   CASE cVar=="01"
       cVrati := { "UI", "PADR(aPov1,22)" }
   CASE cVar=="02"
       cVrati := { "UI", "PADR(PARTN->naz,22)" }
   CASE cVar=="03"
       cVrati := { "UI", "PADR(aPov2,22)" }
   CASE cVar=="04"
       cVrati := { "UI", "PADR(PARTN->mjesto,22)" }
   CASE cVar=="05"
       cVrati := { "UI", "PADR(aPov3,22)" }
   CASE cVar=="06"
       cVrati := { "UI", "PADR(PARTN->ziror,22)" }
   CASE cVar=="07"
       cVrati := { "UI", "PADR(aPov4,22)" }
   CASE cVar=="08"
       cVrati := { "UI", "PADR(PARTN->dziror,22)" }
   CASE cVar=="09"
       cVrati := { "I", "TRIM(cBrKomp)" }
   CASE cVar=="10"
       cVrati := { "I", "STR(nUkup60,21,2)" }
   CASE cVar=="11"
       cVrati := { "I", "STR(nUkup12,21,2)" }
   CASE cVar=="12"
       cVrati := { "I", "STR(nSaldo,17,2)" }
   CASE cVar=="13"
       cVrati := { "UI", "ALLTRIM(STR(nSaldo))" }
   CASE cVar=="14"
       cVrati := { "UI", "IF( cVal=='D' , aPov3 , aPov4 )" }
   CASE cVar=="15"
       cVrati := { "UI", "IF( nRokPl==0 , '  ' , ALLTRIM(STR(nRokPl)) )" }
   CASE cVar=="16"
       cVrati := { "UI", "IF( cVal=='D' , ValDomaca() , ValPomocna() )" }
   CASE cVar=="17"
       cVrati := { "UI", "SrediDat(dKomp)" }
   CASE cVar=="18"
       cVrati := { "UI", "SrediDat(dKomp)" }
   CASE cVar=="19"
       cVrati := { "", "IF( cVal=='D' , ValDomaca() , ValPomocna() )" }
   CASE cVar=="20"
       cVrati := { "", "ValDomaca()" }
   CASE cVar=="21"
       cVrati := { "", "ValPomocna()" }
   CASE cVar=="23"
       cVrati := { "UI", "PADR(aPov5,22)" }
   CASE cVar=="24"
       cVrati := { "UI", "PADR(aDuz5,22)" }
   CASE cVar=="25"
       cVrati := { "UI", "PADR(aPov6,22)" }
   CASE cVar=="26"
       cVrati := { "UI", "PADR(aDuz6,22)" }
   CASE cVar=="27"
       cVrati := { "UI", "PADR(aPov7,22)" }
   CASE cVar=="28"
       cVrati := { "UI", "PADR(aDuz7,22)" }
   CASE cVar=="29"
       cVrati := { "UI", "PADR(aPov8,22)" }
   CASE cVar=="30"
       cVrati := { "UI", "PADR(aDuz8,22)" }
   CASE cVar=="31"
       cVrati := { "UI", "PADR(aPov9,22)" }
   CASE cVar=="32"
       cVrati := { "UI", "PADR(aPov10,22)" }
   CASE cVar=="33"
       cVrati := { "UI", "PADR(aDuz10,22)" }
   CASE cVar=="B1"
       cVrati := { "K", "gPB_ON()" }
   CASE cVar=="B0"
       cVrati := { "K", "gPB_OFF()" }
   CASE cVar=="U1"
       cVrati := { "K", "gPU_ON()" }
   CASE cVar=="U0"
       cVrati := { "K", "gPU_OFF()" }
   CASE cVar=="I1"
       cVrati := { "K", "gPI_ON()" }
   CASE cVar=="I0"
       cVrati := { "K", "gPI_OFF()" }
 ENDCASE
RETURN cVrati
*}


/*! \fn PrnKod_ON(cKod)
 *  \brief
 */
 
function PrnKod_ON(cKod)
*{
LOCAL i:=0
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_ON()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_ON()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_ON()
    ENDCASE
  NEXT
RETURN (NIL)
*}



/*! \fn PrnKod_OFF(cKod)
 *  \brief Iskljucivanje printerskog koda
 *  \param cKod - kod printera
 */
 
function PRNKod_OFF(cKod)
*{
LOCAL i:=0
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_OFF()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_OFF()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_OFF()
    ENDCASE
  NEXT
RETURN (NIL)
*}


/*! \fn GenAZ()
 *  \brief 
 */
 
function GenAZ()
*{
local nSaldo
local nSljRec
local nOdem

if !IzvrsenIn(,,"OASIST", .t. )
	MsgBeep("Ovaj modul nije registrovan za koristenje !")
  	return
endif

private cIdKonto
private cIdFirma
private cIdPartner
private cBrDok

O_KONTO
O_PARTN
O_SUBAN
O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}

// ovo su parametri kartice
cIdFirma:=gFirma
cIdKonto:=space(len(suban->idkonto))
cIdPartner:=space(len(suban->idPartner))
Params1()
RPar("c4",@cIdFirma)
RPar("c5",@cIdKonto)
RPar("c6",@cIdPartner)
select (F_PARAMS)
use

cIdKonto:=padr(cidkonto,len(suban->idkonto))
cIdPartner:=padr(cidpartner,len(suban->idPartner))
cDugPot:="1"

Box(,3,60)
	@ m_x+1,m_y+2 SAY "Konto   " GET cIdKonto   valid p_kontoFin(@cIdKonto)  pict "@!"
  	@ m_x+2,m_y+2 SAY "Partner " GET cIdPartner valid P_Firma(@cIdPartner) pict "@!"
  	@ m_x+3,m_y+2 SAY "Konto duguje / potrazuje" get cdugpot when {|| cDugPot:=iif(cidkonto='54','2','1'), .t.} valid  cdugpot$"12"
  	read
BoxC()

// !!!!! paziti na problem u mreznom radu

select SUBAN
set order to tag "3" //IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)

copy structure extended to OEXT
select (F_OSUBAN)  // privremeno koristim ovu area
use OEXT
dbappend()  // dodaj _recno
replace field_name with  '_RECNO',field_type with 'N', field_len with 8, field_dec with 0
dbappend()  // dodaj _PPk1
replace field_name with  '_PPK1',field_type with 'C', field_len with 1, field_dec with 0
dbappend()  // dodaj _PPk1  // originalni broj dokumenta
replace field_name with  '_OBRDOK',field_type with 'C', field_len with 10, field_dec with 0

use

if FErase(PRIVPATH+'OSUBAN.CDX')==-1
	MsgBeep("Ne mogu izbrisati POM.DBF!")
  	ShowFError()
endif
create (PRIVPATH+"OSUBAN") from OEXT

select (F_OSUBAN)
usex (PRIVPATH+"OSUBAN")
index on IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr  tag "1"
index on idfirma+idkonto+idpartner+brdok  tag "3"
index on dtos(datdok)+dtos(iif(empty(DatVal),DatDok,DatVal))  tag "DATUM"
//OSUBAN
select suban
seek cidfirma+cidkonto+cidpartner
do while !eof() .and. idfirma+idkonto+idpartner=cidfirma+cidkonto+cidpartner
	cBrDok:=Brdok
   	nSaldo:=0
   	do while !eof() .and. cidfirma+cidkonto+cidpartner+cbrdok=idfirma+idkonto+idpartner+brdok
      		if cDugPot=d_p .and. empty(brdok)
         		MsgBeep("Postoje nepopunjen brojevi veze :"+idvn+"-"+brdok+"/"+rbr+"##Morate ih popuniti !")
         		closeret
      		endif
      		if d_p="1"
			nsaldo+=iznosbhd
		else
			nsaldo-=iznosbhd
		endif
      		skip
   	enddo
   	if round(nsaldo,4)<>0 // postoji
      		seek cidfirma+cidkonto+cidpartner+cbrdok
      		do while !eof() .and. cidfirma+cidkonto+cidpartner+cbrdok=idfirma+idkonto+idpartner+brdok
         		select suban
         		Scatter()
         		select osuban
         		append blank
         		__recno:=suban->(recno())
         		__PPk1:=""
         		__OBRDOK:=_Brdok
         		if ((nSaldo>0 .and. cDugPot="2") .or. (nSaldo<0 .and. cDugpot="1")) .and. _d_p<>cDugPot
           			// neko je bez veze zatvorio uplate (ili se mozda radi o avansima)
           			altd()
           			_BrDok:='AVANS'
         		endif
			Gather()
         		select suban
         		skip
      		enddo
   	endif
enddo

select osuban 
set order to tag "DATUM"

do while .t.
	go top
  	fNasao:=.f.
  	nZatvoriti:=0
  	// prvi krug  (nadji ukupno stvorene obaveze)
  	cZatvoriti:=chr(200)+chr(255)
  	do while !eof()
   		if empty(_PPK1) // neobradjeno
    			if !fNasao .and. d_p==cDugPot  // nastanak dugovanja
         			nZatvoriti:=iznosbhd
         			cZatvoriti:=brdok
         			fNasao:=.t.
         			replace _PPK1 with "1" // prosli smo ovo
         			go top // idi od pocetka da saberes czatvoriti
         			loop
    			elseif fNasao .and. cZatvoriti=Brdok
         			if d_p==cdugpot
            				nZatvoriti+=iznosbhd
         			else
            				nZatvoriti-=iznosbhd
         			endif
        			replace _PPK1 with "1" // prosli smo ovo
    			endif
   		endif // empty(_PPk1)
   		skip
  	enddo
	if !fNasao
      		exit // nema se sta zatvoriti
  	endif

  	// drugi krug

  	fNasao:=.f.
  	go top
  	do while !eof()
    		if empty(_PPK1)
     			if d_p<>cDugPot // radi se o uplatama
        			nUplaceno:=iznosbhd
        			if nUplaceno>0 .and. nZatvoriti>0  // pozitivni iznosi
           				if  nZatvoriti>=nUplaceno  // vise treba zatvoriti nego je uplaceno
                				replace brdok with cZatvoriti, _PPk1 with "1"
                				nZatvoriti-=nUplaceno
           				elseif nZatvoriti<nUplaceno
                				// imamo i ostatak sredstava razbij uplatu !!
                				skip
						nSljRec:=recno()
						skip -1
                				nOdem:=iznosdem-nzatvoriti*iznosdem/iznosbhd
                				// alikvotni dio..HA HA HA
                				replace brdok with czatvoriti, _PPk1 with "1", iznosbhd with nzatvoriti, iznosdem with iznosdem-nODem
                				scatter()
                				_iznosbhd:=nuplaceno-nzatvoriti
                				_iznosdem:=nodem
                				if round(_iznosbhd,4)<>0 .and. round(nodem,4)<>0
                 					append blank
                 					_brdok:="AVANS"
                 					__PPK1:=""
                 					gather()
                				endif
                				nzatvoriti:=0
                				go nSljRec 
						loop
					endif
           				if nzatvoriti<=0
						exit
					endif  // zavrsi sa ovim racunom
        			endif  // nuplaceno>0 .and. nzatvoriti>0
     			endif // d_p<>cdugpot
    		endif // _PPk1
    		skip
  	enddo
enddo

// !!! markiraj stavke koje su postale zatvorene
set order to tag "3"
go top
do while !eof()
	cBrDok:=brdok
   	nSaldo:=0
   	nsljrec:=recno()
   	do while !eof() .and. cidfirma+cidkonto+cidpartner+cbrdok=idfirma+idkonto+idpartner+brdok
      		if d_p="1"
			nsaldo+=iznosbhd
		else
			nsaldo-=iznosbhd
		endif
      		skip
   	enddo
   	if round(nsaldo,4)=0
    		go nSljRec
    		do while !eof() .and. cidfirma+cidkonto+cidpartner+cbrdok=idfirma+idkonto+idpartner+brdok
       			replace otvst with "9"
       			skip
    		enddo
   	endif
enddo

select suban
use
select osuban
use
usex (PRIVPATH+"osuban") alias suban

select SUBAN
set order to tag "1" // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr

if reccount()=0
	use
   	MsgBeep("Nema otvorenih stavki")
   	return
endif

Box(,21,77)

ImeKol:={}
AADD(ImeKol,{ "O.Brdok",    {|| _OBrDok}                  })
AADD(ImeKol,{ "Br.Veze",     {|| BrDok}                          })
AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}                         })
AADD(ImeKol,{ "Dat.Val.",   {|| DatVal}                         })
AADD(ImeKol,{ PADR("Duguje "+ALLTRIM(ValDomaca()),18), {|| str((iif(D_P=="1",iznosbhd,0)),18,2)}     })
AADD(ImeKol,{ PADR("Potraz."+ALLTRIM(ValDomaca()),18), {|| str((iif(D_P=="2",iznosbhd,0)),18,2)}     })
AADD(ImeKol,{ "M1",         {|| m1}                          })
AADD(ImeKol,{ PADR("Iznos "+ALLTRIM(ValPomocna()),14),  {|| str(iznosdem,14,2)}                       })
AADD(ImeKol,{ "nalog",    {|| idvn+"-"+brnal+"/"+rbr}                  })
AADD(ImeKol,{ "O",          {|| OtvSt}                          })
AADD(ImeKol,{ "Partner",     {|| IdPartner}                          })
Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next


private  gTBDir:="N"
private  bGoreRed:=NIL
private  bDoleRed:=NIL
private  bDodajRed:=NIL
private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
private  TBAppend:="N"  // mogu dodavati slogove
private  bZaglavlje:=NIL
        // zaglavlje se edituje kada je kursor u prvoj koloni
        // prvog reda
private  TBSkipBlock:={|nSkip| SkipDBBK(nSkip)}
private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                        // ovo se mo§e setovati u when/valid fjama
private  TBScatter:="N"  // uzmi samo teku†e polje
adImeKol:={}
for i:=1 TO LEN(ImeKol); AADD(adImeKol,ImeKol[i]); next
adKol:={}; for i:=1 to len(adImeKol); AADD(adKol,i); next

private bBKUslov:= {|| idFirma+idkonto+idpartner=cidFirma+cidkonto+cidpartner}
private bBkTrazi:= {|| cIdFirma+cIdkonto+cIdPartner}
// Brows ekey uslova
private aPPos:={cIdPartner,1}  // pozicija kolone partner, broj veze

set cursor on
@ m_x+16,m_y+1 SAY "****************  REZULTATI ASISTENTA ************"
@ m_x+17,m_y+1 SAY REPL("Ä",78)
@ m_x+18,m_y+1 SAY " <F2> Ispravka broja dok.       <c-P> Print      <a-P> Print Br.Dok           "
@ m_x+19,m_y+1 SAY " <K> Ukljuci/iskljuci racun za kamate "
@ m_x+20,m_y+1 SAY ' < F6 > Stampanje izvrsenih promjena  '
private cPomBrDok:=SPACE(10)

seek EVAL(bBkTrazi)
ObjDbEdit("Ost",21,77,{|| EdRos()} ,"","",     ;
           .f. ,NIL, 1, {|| brdok<>_obrdok}, 6, 0, ;  // zadnji par: nGPrazno
            NIL, {|nSkip| SkipDBBK(nSkip)} )

//BrowseKey(m_x+6,m_y+1,m_x+21,m_y+77,ImeKol,{|Ch| EdRos(Ch)},"idFirma+idkonto+idpartner=cidFirma+cidkonto+cidpartner",cidFirma+cidkonto+cidpartner,2,,,{|| brdok<>_obrdok})

BoxC()

go top
fPromjene:=.f.
do while !eof()
	if _obrdok<>brdok
     		fPromjene:=.t.
     		exit
  	endif
  	skip
enddo

if fpromjene
	go top
	if pitanje(,"Ostampati rezultate asistenta ?","N")="D"
  		StAz()
	endif
else
	select suban
	use
	return  // izadji - nije bilo promjena
endif

select suban
use

MsgBeep("U slucaju da azurirate rezultate asistenta#program ce izmijeniti sadrzaj subanalitickih podataka !")
if pitanje(,"Zelite li izvrsiti azuriranje rezultata asistenta u bazu SUBAN !!","N")=="D"
	select (F_OSUBAN)
	usex (PRIVPATH+"osuban")
 	O_SUBAN
 	if !flock()
   		MsgBeep("Program ne dozvoljava drugim korisnicima unos podataka !")
 	else
    		select osuban
		go top
    		// prvi krug - provjeriti da neko nije slucajno dirao stavke ??!!-drugi korisnik
    		do while !eof()
       			select suban
			go osuban->_recno
       			if eof() .or. idfirma<>osuban->idfirma .or. idvn<>osuban->idvn .or. brnal<>osuban->brnal .or. idkonto<>osuban->idkonto .or. idpartner<>osuban->idpartner .or. d_p<>osuban->d_p
          			MsgBeep("Izgleda da je drugi korisnik radio na ovom partneru#Prekidam operaciju !!!")
          			closeret
       			endif
       			select osuban
       			skip
    		enddo
    		// drugi krug - sve je cisto brisi iz suban!
    		select osuban
    		go top
    		do while !eof()
      			select suban
			go osuban->_Recno
      			IF !EOF()
				DELETE
			ENDIF
      			select osuban
			skip
    		enddo
    		// treci krug - dodaj iz osuban
    		go top
    		do while !eof()
      			scatter()
      			select suban
      			append blank
      			gather()
      			select osuban
			skip
    		enddo
    		MsgBeep("Promjene su izvrsene - provjerite na kartici")
	endif
endif

closeret
return
*}


/*! \fn StAz()
 *  \brief Stampa promjena
 */
 
function StAz()
*{
aKol:={}
AADD(aKol,{ "Originalni",    {|| _obrdok}, .f., "C", 10,  0, 1, 1    })
AADD(aKol,{ "Br.Veze  " ,    {|| "#"}, .f., "C", 10,  0, 2, 1    })
AADD(aKol,{ "Br.Veze",       {|| BrDok}, .f.,"C", 10,0,1, 2  })

AADD(aKol,{ "Dat.Dok",       {|| DatDok}, .f.,"D", 8,0,1, 3  })
AADD(aKol,{ "Duguje",    {|| str((iif(D_P=="1",iznosbhd,0)),18,2)}, .f.,"C", 18,0,1, 4  })
AADD(aKol,{ "Potrazuje",    {|| str((iif(D_P=="2",iznosbhd,0)),18,2)}, .f.,"C", 18,0,1, 5  })
AADD(aKol,{ "Nalog",    {|| idvn+"-"+brnal+"/"+rbr}, .f.,"C", 20,0,1, 6  })
AADD(aKol,{ "Partner",     {|| IdPartner} , .f.,"C", 10,0,1, 7  })

go top
fPromjene:=.f.
do while !eof()
  if _obrdok<>brdok
     fPromjene:=.t.
     exit
  endif
  skip
enddo

go top
START PRINT CRET
StampaTabele(aKol,,,0,,;
    ,"Rezultati asistenta otvorenih stavki za: "+idkonto+"/"+idpartner+" na datum:"+dtoc(Date()))
END PRINT
return .t.
*}



/*! \fn SkipDBBK(nRequest)
 *  \brief 
 *  \param nRequest
 */
 
function SkipDBBK(nRequest)
*{
local nCount
nCount := 0
if LastRec() != 0
   if .not. eval(bBKUslov)
      seek eval(bBkTrazi)
      if .not.  eval(bBKUslov)
         go bottom
         skip 1
      endif
      nRequest=0
   endif
   if nRequest>0
      do while nCount<nRequest .and. eval(bBKUslov)
         skip 1
         if Eof() .or. !  eval(bBKUslov)
            skip -1
            exit
         endif
         nCount++
      enddo
   elseif nRequest<0
      do while nCount>nRequest .and. eval(bBKUslov)
         skip -1
         if ( Bof() )
            exit
         endif
         nCount--
      enddo
      if !  eval(bBKUslov)
         skip 1
         nCount++
      endif
   endif
endif
return (nCount)
*}


