#include "\cl\sigma\fmk\os\os.ch"


function Unos()
*{
private cId:=space(10),cIdRj:=space(4)

Box("#UNOS PROMJENA NAD OSNOVNIM SREDSTVIMA",19,77)
do while .t.

BoxCLS()

O_K1
O_OS
O_RJ
O_KONTO
O_AMORT
O_REVAL
O_PROMJ
set cursor on
cPicSif:=IF(gPicSif="V","@!","")

 IF gIBJ=="D"

   @ m_x+1,m_y+2 SAY "Sredstvo:      " GET cId  VALID P_OS(@CID,1,35) PICT cPicSif
   @ m_x+2,m_y+2 SAY "Radna jedinica: " GET cIdRj  ;
      WHEN {|| cIdRj:=os->idrj,.t. }  ;
      VALID P_RJ(@CIDRJ,2,35)
   read; ESC_BCR

 ELSE

   DO WHILE .t.

     @ m_x+1,m_y+2 SAY "Sredstvo:      " GET cId PICT cPicSif
     @ m_x+2,m_y+2 SAY "Radna jedinica: " GET cIdRj
     read; ESC_BCR
     SELECT OS
     SEEK cId
     DO WHILE !EOF() .and. cId==OS->ID .and. cIdRJ!=OS->IDRJ
       SKIP 1
     ENDDO
     IF cID!=OS->ID .or. cIdRJ!=OS->IDRJ
       Msg("Izabrano sredstvo ne postoji!",5)
     ELSE
       SELECT RJ
       SEEK cIdRj
       @ m_x+1,m_y+35 SAY OS->naz
       @ m_x+2,m_y+35 SAY RJ->naz
       EXIT
     ENDIF

   ENDDO

 ENDIF

 select amort; hseek os->idam
 select os
 if cidrj<>os->idrj
   IF Pitanje(,"Jeste li sigurni da zelite promijeniti radnu jedinicu ovom sredstvu? (D/N)"," ")=="D"
     replace idrj with cidrj
   ELSE
     cIdRj:=idrj
     SELECT RJ; SEEK cIdRj; SELECT OS
     @ m_x+2,m_y+2 SAY "Radna jedinica: " GET cIdRj
     @ m_x+2,m_y+35 SAY RJ->naz
     CLEAR GETS
   ENDIF
 endif
 @ m_x+3,m_y+2 SAY "Datum nabavke: "; ?? os->datum
 if !empty(os->datotp)
   @ m_x+3,m_y+38 SAY "Datum otpisa: "; ?? os->datotp
 endif
 @ m_x+4,m_y+2 SAY "Nabavna vr.:"; ?? transform(nabvr,gpici)
 @ m_x+4,col()+2 SAY "Ispravka vr.:"; ?? transform(otpvr,gpici)
 aVr:={nabvr,otpvr,0}

 // recno(), datum, DatOtp, NabVr, OtpVr, KumAmVr
 aSred := { {0,datum,datotp,nabvr,otpvr,0} }
 altd()

 private dDatNab:=os->datum
 private dDatOtp:=os->datotp,cOpisOtp:=os->opisotp
 select promj

ImeKol:={}
AADD(ImeKol,{ "DATUM",         {|| DATUM}                          })
AADD(ImeKol,{ "OPIS",          {|| OPIS}                          })
//AADD(ImeKol,{ "tip",           {|| tip}                          })
AADD(ImeKol,{ PADR("Nabvr",11), {|| transform(nabvr,gpici)}     })
AADD(ImeKol,{ PADR("OtpVr",11), {|| transform(otpvr,gpici)}     })
AADD(ImeKol,{ PADR("Kumul.SadVr",11), {|| transform(PSadVr(),gpici)}     })
Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on

@ m_x+20,m_y+2 SAY "<ENT> Ispravka, <c-T> Brisi, <c-N> Nove prom, <c-O> Otpis, <c-I> Novi ID"

ShowSadVr()

DO WHILE .t.
  BrowseKey(m_x+8,m_y+1,m_x+19,m_y+77,ImeKol,{|Ch| Edos(Ch)},"id==cid",cid,2,;
            ,,{|| PSadVr()<0})
  IF aVr[1]-aVr[2]>=0
    IF aVr[3]<0
      MsgBeep("Greska: sadasnja vrijednost sa uracunatom amortizacijom manja od nule! #Ispravite gresku!")
    ELSE
      EXIT
    ENDIF
  ELSE
    MsgBeep("Greska: sadasnja vrijednost manja od nule ! Ispravite gresku !")
  ENDIF
  EXIT  // ipak necu zabraniti izlazak jer bi to moglo jos zakomplikovati rad
ENDDO

close all
enddo
BoxC()

closeret
return
*}



function EdOS(Ch)
*{
local cDn:="N",nRet:=DE_CONT, nRec0:=RECNO()
do case
  case Ch==K_ENTER .or. Ch==K_CTRL_N
     IF CH=K_CTRL_N
       GO BOTTOM
       SKIP 1
     ENDIF
     Scatter()
     Box(,5,50)
       @ m_x+1,m_y+2 SAY "Datum:"  get _datum valid V_Datum()
       @ m_x+2,m_y+2 SAY "Opis:"  get _opis
       @ m_x+4,m_y+2 SAY "nab vr" get _nabvr
       @ m_x+5,m_y+2 SAY "OTP vr" get _otpvr
       read
     BoxC()
     IF LASTKEY()==K_ESC
       GO (nRec0)
       nRet:=DE_CONT
     ELSE
       IF CH==K_CTRL_N
         APPEND BLANK
       ENDIF
       _ID:=cid
       Gather()
       ShowSadVr()
       nRet:=DE_REFRESH
     ENDIF
  case Ch==K_CTRL_T
     if pitanje(,"Sigurno zelite izbrisati promjenu ?","N")=="D"
       delete
       ShowSadVr()
     endif
     return DE_REFRESH
  case Ch==K_CTRL_O
     select os
     nKolotp:=kolicina
     Box(,5,50)
       @ m_x+1,m_y+2 SAY "Otpis sredstva"
       @ m_x+3,m_y+2 SAY "Datum: " GET dDatOtp  valid dDatOtp>dDatNab .or. empty(dDatOtp)
       @ m_x+4,m_y+2 SAY "Opis : " GET cOpisOtp
       if kolicina>1
        @ m_x+5,m_y+2 SAY "Kolicina koja se otpisuje:" GET nkolotp pict "999999.99" valid nkolotp<=kolicina .and. nkolotp>=1
       endif
       read
     BoxC()

     // ESC_RETURN  DE_CONT   - bug 09.05.02 MS
     IF LASTKEY()==K_ESC
       SELECT PROMJ
       RETURN DE_CONT
     ENDIF

     fRastavljeno:=.f.
     if nkolotp<kolicina
       select os
       scatter()
       nNabVrJ:=_nabvr/_kolicina
       nOtpVrJ:=_otpvr/_kolicina

       // postojeci inv broj
       _kolicina:=_kolicina-nkolotp
       _nabvr:=nnabvrj*_kolicina
       _otpvr:=notpvrj*_kolicina
       gather()

       // novi inv broj
       appblank2(.f.,.t.)  //NC DL
       _kolicina:=nkolotp
       _nabvr:=nnabvrj*nkolotp
       _otpvr:=notpvrj*nkolotp
       _id:=left(_id,9)+"O"
       _datotp:=ddatotp
       _opisotp:=copisotp
       gather()

       fRastavljeno:=.t.
     else
      select os
      replace datotp with ddatotp,opisotp with cOpisOtp
     endif
     select promj
     @ m_x+5,m_y+38 SAY "Datum otpisa: "; ?? os->datotp
     if frastavljeno
         Msg("Postojeci inv broj je rastavljen na dva-otpisani i neotpisani")
         return DE_ABORT
     else
        RETURN DE_REFRESH
     endif
  case Ch==K_CTRL_I
     Box(,4,50)
       private cNovi:=space(10)
       @ m_x+1,m_y+2 SAY "Promjena inventurnog broja:"
       @ m_x+3,m_y+2 SAY "Novi inventurni broj:" GET cnovi valid !empty(cnovi)
       read
     BoxC()
     ESC_RETURN DE_CONT

       select os
       seek cnovi
       if found()
         Beep(1)
         Msg("Vec postoji sredstvo sa istim inventurnim brojem !")
       else
         select promj
         seek cid
         private nRec:=0
         do while !eof() .and. cid==id
           skip; nRec:=recno(); skip -1
           replace id with cnovi
           go nRec
         enddo
         seek cnovi

         select os
         seek cid
         replace id with cnovi
         cId:=cnovi
       endif
       select promj
       RETURN DE_REFRESH
  otherwise
     return DE_CONT
endcase
return nRet
*}



// 1) izracunaj i prikazi sadasnju vrijednost
// 2) izracunaj i kumulativ amortizacije u aSred
// ---------------------------------------
function ShowSadVr()
*{
 local nArr:=SELECT(), nRec:=0, i:=0
  SELECT PROMJ
  nRec:=RECNO()
  SEEK cID
  aVr[1]:=OS->nabvr
  aVr[2]:=OS->otpvr
  FOR i:=LEN(aSred) TO 1 STEP -1
    IF aSred[i,1]>0 .and. aSred[i,1]<999999
      ADEL(aSred,i)
      ASIZE(aSred,LEN(aSred)-1)
    ENDIF
  NEXT
  DO WHILE !EOF() .and. ID==cID
    aVr[1] += nabvr; aVr[2] += otpvr
    AADD( aSred , {RECNO(),datum,OS->datotp,nabvr,otpvr,0} )
    SKIP 1
  ENDDO
  ASORT(aSred,,,{|x,y| x[2]<y[2]})
  FOR i:=1 TO LEN(aSred)
    _nabvr:=aSred[i,4]
    _otpvr:=aSred[i,5]
    _amd:=_amp:=nOstalo:=0
    _datum:=aSred[i,2]
    _datotp:=aSred[i,3]
    IzrAm(_datum,iif(!empty(_datotp),min(gDatObr,_datotp),gDatObr),100)     // napuni _amp
    aSred[i,6]=_amp
  NEXT
  SKIP -1
  IF ID==cId; aVr[3]:=PSadVr(); ENDIF
  @ m_x+6, m_y+1 SAY " UKUPNO:   Nab.vr.="         COLOR "W+/B"
  @ row(),col()  SAY TRANS(aVr[1],"9999999.99")        COLOR "GR+/B"
  @ row(),col()  SAY ",    Otp.vr.="         COLOR "W+/B"
  @ row(),col()  SAY TRANS(aVr[2],"9999999.99")        COLOR "GR+/B"
  @ row(),col()  SAY ",    Sad.vr.="         COLOR "W+/B"
  @ row(),col()  SAY TRANS(aVr[1]-aVr[2],"9999999.99") COLOR IF(aVr[1]-aVr[2]<0,"GR+/R","GR+/B")
  @ m_x+7, m_y+1 SAY "           Sadasnja vrijednost sa uracunatom amortizacijom=" COLOR "W+/B"
  @ row(),col()  SAY TRANS(aVr[3],"9999999.99")        COLOR IF(aVr[3]<0,"GR+/R","GR+/B")
  GO (nRec)
 SELECT (nArr)
return
*}


function PSadVr()
*{
local n:=0, i:=0
for i:=1 to LEN(aSred)
	n += ( aSred[i,4]-aSred[i,5]-aSred[i,6] )
	if i==LEN(aSred)
		aVr[3]:=n
	endif
	if aSred[i,1]==RECNO()
		exit
	endif
	altd()
next
return n
*}



function V_Datum()
*{
local nRet:=.t.
if _datum<=dDatNab
	Beep(1)
	Msg("Datum promjene mora biti veci od datuma nabavke !")
	nRet:=.f.
endif
if !empty(dDatOtp) .and. _Datum>=dDatOtp
	Beep(1)
	Msg("Datum promjene mora biti manji od datuma otpisa !")
	nRet:=.f.
endif
return nRet
*}

