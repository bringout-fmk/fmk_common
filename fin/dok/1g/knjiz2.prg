#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/dok/1g/knjiz2.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: knjiz2.prg,v $
 * Revision 1.3  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 * Revision 1.2  2002/06/19 13:46:23  sasa
 * no message
 *
 *
 */

/*! \file fmk/fin/dok/1g/knjiz2.prg
 *  \brief Knjizenje naloga dodatne funkcije
 */


/*! \fn OiNIsplate()
 *  \brief Odobrenje i nalog isplate
 */
 
function OiNIsplate()
*{
LOCAL nRec:=0
 PRIVATE cBrojOiN:="T"     // T,S,O
  SELECT PRIPR
  nRec:=RECNO()

  IF !VarEdit({ {"Koliko obrazaca stampati? (T-samo tekuci, S-sve, O-od tekuceg do kraja)","cBrojOiN","cBrojOiN$'TSO'","@!",} }, 10,0,14,79,;
              'STAMPANJE OBRASCA "ODOBRENJE I NALOG ZA ISPLATU"',;
              "B1")
    RETURN (NIL)
  ENDIF
  IF cBrojOiN=="S"; GO TOP; ENDIF
  START PRINT CRET

  DO WHILE !EOF()
    ?
    gpCOND()
    ? SPACE(gnLMONI)
    gpB_ON(); gp12cpi()
    ?? "ORGAN UPRAVE-SLU"+IF(gKodnaS=="8","¦","@")+"BA"
    gpB_OFF(); gpCOND()
    ?? SPACE(50)+"Ispla"+IF(gKodnaS=="8","†","}")+"eno putem"
    gpB_ON()
    ?? " ZPP-BLAGAJNE"
    gpB_OFF()

    ? SPACE(gnLMONI)+SPACE(77)+"sa "+IF(gKodnaS=="8","§","`")+"iro ra"+IF(gKodnaS=="8","Ÿ","~")+"una"
//    ? SPACE(gnLMONI); gPI_ON()
//    ?? Ocitaj(F_KONTO,idkonto,"naz")
//    gPI_OFF()
    ?
//    ? SPACE(gnLMONI)+REPL("-",60)
//    ? SPACE(gnLMONI)+SPACE(77); gpI_ON()
    ? SPACE(gnLMONI); gPI_ON()
    ?? PADC(ALLTRIM(Ocitaj(F_KONTO,idkonto,"naz")),60); gPI_OFF()
    ?? SPACE(17); gpI_ON()
    ?? PADC(ALLTRIM(idkonto),28); gPI_OFF()
    ? SPACE(gnLMONI)+REPL("-",60)+SPACE(17)+REPL("-",28)
    ?
    ? SPACE(gnLMONI)+"Broj: "; gPI_ON()
    ?? PADC(ALLTRIM(idpartner),54); gPI_OFF()
    ?? SPACE(17)+"Dana"+SPACE(14)+"199   god."
    ? SPACE(gnLMONI)+"      "+REPL("-",54)+SPACE(21)+REPL("-",14)+"   "+"--"
    ? SPACE(gnLMONI)+"Zenica, "; gPI_ON()
    ?? PADC(SrediDat(datdok),52); gPI_OFF()
    ? SPACE(gnLMONI)+"        "+REPL("-",52)
    ?; ?; ?; ?; ?
    ? SPACE(gnLMONI)+SPACE(30); gPB_ON(); gP10cpi()
    ?? "ODOBRENJE I NALOG ZA ISPLATU"; gPB_OFF(); gPCOND()
    ?; ?; ?; ?; ?
    ? SPACE(gnLMONI)+"Kojim se odre"+IF(gKodnaS=="8","Ð","|")+"uje da se izvr"+IF(gKodnaS=="8","ç","{")+"i isplata u korist "; gpI_ON()
    ?? PADC(ALLTRIM(Ocitaj(F_PARTN,idpartner,"TRIM(naz)+', '+mjesto")),57); gpI_OFF()
    ? SPACE(gnLMONI)+"                                                "+REPL("-",57)
    ?
    ? SPACE(gnLMONI)+REPL("-",105)
    ? SPACE(gnLMONI)+"na ime ra"+IF(gKodnaS=="8","Ÿ","~")+"una broj "; gpI_ON()
    ?? PADC(ALLTRIM(brdok),24); gpI_OFF()
    ?? " od "; gPI_ON()
    ?? PADC(DTOC(datval),23); gPI_OFF()
    ?? " za kupljenu robu - izvr"+IF(gKodnaS=="8","ç","{")+"ene usluge"; gPI_ON()
    ? SPACE(gnLMONI)+"                   "+REPL("-",24)+"    "+REPL("-",23)
    ?
    ? SPACE(gnLMONI)+REPL("-",105)
    ? SPACE(gnLMONI)+PADC(ALLTRIM(opis),105); gPI_OFF()
    ? SPACE(gnLMONI)+REPL("-",105)
    ?
    ? SPACE(gnLMONI)+REPL("-",105)
    ? SPACE(gnLMONI)+"na teret ovog organa - slu"+IF(gKodnaS=="8","§","`")+"be i to:        "+ValDomaca()+" "; gPI_ON()
    ?? transform(iznosbhd,gPicBHD); gPI_OFF()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(43)+ValDomaca()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(43)+ValDomaca()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(43)+ValDomaca()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(43)+ValDomaca()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(32)+"UKUPNO     "+ValDomaca()+" "; gPI_ON()
    ?? transform(iznosbhd,gPicBHD); gPI_OFF()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(32)+REPL("-",33)
    ? SPACE(gnLMONI)+SPACE(32)+"ZA ISPLATU "+ValDomaca()+" "; gPI_ON()
    ?? transform(iznosbhd,gPicBHD); gPI_OFF()
    ? SPACE(gnLMONI)+SPACE(43)+"     "+REPL("-",17)
    ? SPACE(gnLMONI)+SPACE(32)+REPL("-",33)
    ?; ?; ?; ?
    ? SPACE(gnLMONI)+SPACE(15)+"Ra"+IF(gKodnaS=="8","Ÿ","~")+"unopolaga"+IF(gKodnaS=="8","Ÿ","~")+SPACE(50)+"Naredbodavac"
    ?; ?
    ? SPACE(gnLMONI)+REPL("-",43)+SPACE(20)+REPL("-",42)
    ?
    FF
    IF cBrojOiN=="T"
      EXIT
    ELSE
      SKIP 1
    ENDIF
  ENDDO
  END PRINT
  GO (nRec)
RETURN (NIL)
*}


/*! \fn KonsultOS()
 *  \brief Sredjivanje otvorenih stavki pri knjizenju, poziv na polju strane valute<a+O>
 */
 
function KonsultOS()
*{
local fgenerisano
LOCAL nNaz:=1, nRec:=RECNO()


if !IzvrsenIn(,,"OASIST", .t. )
  MsgBeep("Ovaj modul nije registrovan za koristenje !")
  return
endif

if readvar()<>"_IZNOSDEM"
  MsgBeep("Morate se pozicionirati na polje strane valute !")
  return
endif

cIdFirma:=gFirma
cIdPartner:=_idpartner
nIznos:=_iznosbhd
cDugPot:=_d_p
cOpis:=_Opis

IF gRJ=="D"
  cIdRj := _idrj
ENDIF

if gTroskovi=="D"
  cFunk := _Funk
  cFond := _Fond
endif

picD:=FormPicL("9 "+gPicBHD,14)
picDEM:=FormPicL("9 "+gPicDEM,9)

cIdKonto:=_idkonto

cIdFirma:=left(cIdFirma,2)

SELECT (F_SUBAN)
IF !USED()
  O_SUBAN
ENDIF

select SUBAN; set order to 1 // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr

//GO TOP
//COUNT TO nPomBS FOR cIdfirma+cIdkonto+cIdpartner == Idfirma+Idkonto+Idpartner .and. otvst != "9"

//IF nPomBS==0
//  Msg("Nema otvorenih stavki!",4)
//  SELECT (F_PRIPR); GO (nRec)
//  RETURN (NIL)
//ENDIF

GO TOP


Box(,19,77)
@ m_x, m_y+25 SAY "KONSULTOVANJE OTVORENIH STAVKI"

// formiraj datoteku
aDbf:={}
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DATVAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DATZPR'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   10 ,  0 })
AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IZNOSBHD'            , 'N' ,  21 ,  2 })
AADD(aDBf,{ 'UPLACENO'            , 'N' ,  21 ,  2 })
AADD(aDBf,{ 'M2'                  , 'C' ,  1 , 0 })
DBCREATE2(PRIVPATH+'OStav.dbf',aDbf)

select (F_OSTAV); use (PRIVPATH+'OStav')
index ON BRISANO TAG "BRISAN"
index on dtos(DatDok)+DTOS(iif(empty(datval),datdok,datval))+Brdok  tag "1"

nUkDugBHD:=nUkPotBHD:=0
select suban; set order to 3

seek cidfirma+cidkonto+cidpartner

dDatDok:=ctod("")

cPrirkto:="1"   // priroda konta
select (F_TRFP2); if !used(); O_TRFP2; endif
HSEEK "99 "+LEFT(cIdKonto,1)
DO WHILE !EOF() .and. IDVD=="99" .and. TRIM(idkonto)!=LEFT(cIdKonto,LEN(TRIM(idkonto)))
  SKIP 1
ENDDO


IF IDVD=="99" .and. TRIM(idkonto)==LEFT(cIdKonto,LEN(TRIM(idkonto)))
  cPrirkto:=D_P
ELSE
  if cidkonto="21"
     cPrirkto:="1"
  else
     cPrirkto:="2"
  endif
ENDIF

select suban

nUDug2:=nUPot2:=0
nUDug:=nUPot:=0
fPrviprolaz:=.t.
DO WHILE !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner

      cBrDok:=BrDok; cOtvSt:=otvst
      dDatDok:=max(datval,datdok)
      nDug2:=nPot2:=0
      nDug:=nPot:=0
      aFaktura:={CTOD(""),CTOD(""),CTOD("")}
      DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner ;
                 .and. brdok==cBrDok
         dDatDok:=min(max(datval,datdok),dDatDok)
         IF D_P=="1"
            nDug+=IznosBHD
            nDug2+=IznosDEM
         ELSE
            nPot+=IznosBHD
            nPot2+=IznosDEM
         ENDIF

         IF D_P==cPrirkto
           aFaktura[1]:=DATDOK
           aFaktura[2]:=DATVAL
         ENDIF

         altd()
         if afaktura[3]<DatDok  // datum zadnje promjene
            aFaktura[3]:=DatDok
         endif

         skip
      enddo


      if round(ndug-npot,2)<>0
          select ostav
          append blank
          //replace iznosbhd with (ndug-npot), datdok with dDatDok, brdok with cbrdok
          replace iznosbhd with (ndug-npot), ;
                  datdok with aFaktura[1],;
                  datval with aFaktura[2],;
                  datzpr with aFaktura[3],;
                  brdok with cbrdok
          if iznosbhd>0
             replace d_p with "1"
          else
             replace d_p with "2", iznosbhd with -iznosbhd
          endif
          select suban
       endif

enddo // partner


ImeKol:={}
AADD(ImeKol,{ "Br.Veze",     {|| BrDok}                          })
AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}                         })
AADD(ImeKol,{ "Dat.Val.",   {|| DatVal}                         })
AADD(ImeKol,{ "Dat.ZPR.",   {|| DatZPR}                         })
AADD(ImeKol,{ PADR("Duguje "+ALLTRIM(ValDomaca()),14), {|| str((iif(D_P=="1",iznosbhd,0)),14,2)}     })
AADD(ImeKol,{ PADR("Potraz."+ALLTRIM(ValDomaca()),14), {|| str((iif(D_P=="2",iznosbhd,0)),14,2)}     })
AADD(ImeKol,{ PADR("Uplaceno",14), {|| str(uplaceno,14,2)}     })

Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

Box(,15,74,.t.)
set cursor on
@ m_x+13,m_y+1 SAY '<Enter> Izaberi/ostavi stavku'
@ m_x+14,m_y+1 SAY '<F10>   Asistent'
@ m_x+15,m_y+1 SAY ""; ?? "  IZNOS Koji zatvaramo: "+IF(cDugPot=="1","duguje","potrazuje")+" "+ALLTRIM(STR(nIznos))


private cPomBrDok:=SPACE(10)

select ostav
go top
ObjDbedit("KOStav",15,74,{|| EdKonsRos()},"","Otvorene stavke.", , , ,{|| m2='3'} ,3)
// )
Boxc()


select ostav

nNaz:=Kurs(_datdok)

altd()
fM3:=.f.
go top
do while !eof()
  if m2="3"
    fm3:=.t.
    exit
  endif
  skip
enddo

fGenerisano:=.f.
IF  fm3 .and. Pitanje("","Izgenerisati stavke u nalogu za knjizenje ?","D")=="D"  // napraviti stavke?

  SELECT (F_OSTAV); go top

  select ostav

  DO WHILE !EOF()
    IF m2=="3"
      replace m2 with ""
      SELECT (F_PRIPR)
      if fgenerisano
         APPEND BLANK
      else
        if !fnovi; go nRec; else; append blank; endif
        // prvi put
        fGenerisano:=.t.
      endif
      Scatter("w")
      widfirma  := cidfirma
      widvn     := _idvn
      wbrnal    := _brnal
      widtipdok := _idtipdok
      wdATvAL   := ctod("")
      wdatdok   := _datdok
      wopis     := ""
      wIdkonto  := cidkonto
      widpartner:= cidpartner
      wOpis     := cOpis
      wk1       := _k1
      wk2       := _k2
      wk3       := K3U256(_k3)
      wk4       := _k4
      wm1       := _m1

      if gRJ=="D"
        widrj     := cIdRj
      endif

      if gTroskovi=="D"
        wFunk := cFunk
        wFond := cFond
      endif

      wrbr      := STR(nRBr,4)
      nRbr++
      wd_p      :=_D_p
      wIznosBhd := ostav->uplaceno
      altd()
      if ostav->uplaceno<>ostav->iznosbhd
        wOpis:=trim(cOpis)+", DIO"
      endif

      wBrDok    := ostav->brdok

      wiznosdem := if( round(nNaz,4)==0 , 0 , wiznosbhd/nNaz )
      Gather("w")
      SELECT (F_OSTAV)
    ENDIF // m2="3"
    SKIP 1


  ENDDO
ENDIF
BoxC()

if fgenerisano
  --nRbr
  select (F_PRIPR);  Scatter()  // uzmi posljednji slog
  if fnovi
    delete // izbrisi
  else
    Gather()   // pa ga za svaki slucaj pohrani
  endif
  _k3 := K3Iz256(_k3)
  ShowGets()
endif

select (F_OSTAV); use

select (F_PRIPR)
if !fgenerisano
   go nRec
endif
RETURN (NIL)
*}



/*! \fn EdKonsROS()
 *  \brief Ispravka broja veze u SUBAN
 */
 
function EdKonsROS()
*{
local oBrDok:=""
local cBrdok:=""
local nTrec
local cDn:="N",nRet:=DE_CONT
LOCAL GetList:={}           // OK?
do case
  case Ch==K_F2
     if pitanje(,"Izvrsiti ispravku broja veze u SUBAN ?","N")=="D"
        oBrDok:=BRDOK
        cBrDok:=BRDOK
        Box(,2,60)
          @ m_x+1,m_Y+2 SAY "Novi broj veze:" GET cBRDok
          read
        BoxC()
        if lastkey()<>K_ESC
           altd()
           select suban; PushWa(); set order to 3
           seek _idfirma+_idkonto+_idpartner+obrdok
           do while !eof() .and. _idfirma+_idkonto+_idpartner+obrdok==idfirma+idkonto+idpartner+brdok
             skip; nTrec:=recno(); skip -1
             replace brdok with cBrDok
             go nTRec
           enddo
           PopWa()
           select ostav
           replace brdok with cBrdok
           nRet:=DE_ABORT
           MsgBeep("Nakon ispravke morate ponovo pokrenuti asistenta sa <a-O>  !")
        endif
     else
       nRet:=DE_REFRESH
     endif
  case Ch==K_CTRL_T
     if pitanje(,"Izbrisati stavku ?","N")=="D"
        delete
        nRet:=DE_REFRESH
     else
       nRet:=DE_CONT
     endif
  case Ch==K_ENTER
     if uplaceno=0
      _Uplaceno:=iznosbhd
     else
      _uplaceno:=uplaceno
     endif
     Box(,2,60)
        @ m_x+1,m_y+2 SAY "Uplaceno po ovom dokumentu:" GET _uplaceno pict "999999999.99"
        read
     Boxc()
     if lastkey()<>K_ESC
       if _uplaceno<>0
          replace m2 with "3", uplaceno with _uplaceno
       else
          replace m2 with "", uplaceno with 0
       endif
     endif

     nRet:=DE_REFRESH
  case Ch=K_F10
        select ostav; go top

        if pitanje(,"Asistent zatvara stavke ?","D")=="D"
             nPIznos:=nIznos  // iznos uplate npr
             go top
             DO WHILE !EOF()
               IF cDugPot<>d_p .and. nPIznos>0
                 _Uplaceno:=min(iznosbhd,nPIznos)
                 replace m2 with "3", uplaceno with _uplaceno
                 nPIznos-=_uplaceno
               ELSE
                 replace m2 with ""
               ENDIF
               SKIP 1
            ENDDO
            go top
            if nPIznos>0  // ostao si u avansu
               append blank
               Scatter("w")
               wbrdok:=padr("AVANS",10)
               if cdugpot=="1"
                 wd_p:="2"
               else
                 wd_p:="1"
               endif
               wiznosbhd:=npiznos
               wuplaceno:=npiznos
               wdatdok:=date()
               wm2:="3"
               Box(,2,60)
                  @ m_x+1,m_y+2 SAY  "Ostatak sredstava knjiziti na dokument:" GET wbrdok
                  read
               Boxc()
               gather("w")

            endif

        endif

     nRet:=DE_REFRESH
endcase
return nRet
*}


