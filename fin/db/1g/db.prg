#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/db/1g/db.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.9 $
 * $Log: db.prg,v $
 * Revision 1.9  2004/01/13 19:07:54  sasavranic
 * appsrv konverzija
 *
 * Revision 1.8  2002/11/17 13:06:59  sasa
 * no message
 *
 * Revision 1.7  2002/11/17 11:01:33  sasa
 * no message
 *
 * Revision 1.6  2002/11/16 23:23:25  sasa
 * korekcija koda
 *
 * Revision 1.5  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.4  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.3  2002/06/19 12:11:35  sasa
 * no message
 *
 * Revision 1.2  2002/06/17 11:05:39  ernad
 *
 *
 * gaDBFs ... treci clan: KUMPATH -> P_KUMPATH
 *
 *
 */


/*! \file fmk/fin/db/1g/db.prg
 *  \brief Funkcije za rad sa tabelama
 */
 
/*! \fn SifkPartnBank()
 *  \brief Dodaje u tabelu SifK stavke PARTN i BANK
 */
 
function SifkPartnBank()
*{
O_SIFK
set order to tag "ID2"
seek padr("PARTN",8)+"BANK"
if !found()
 if Pitanje(,"U sifk dodati PARTN/BANK  ?","D")=="D"
    append blank
    replace id with "PARTN" , oznaka with "BANK", naz with "Banke",;
            Veza with "N", Duzina with 16 , Tip with "C"
 endif
endif
use
return NIL
*}


#ifdef C52


/*! \fn OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
 *  \brief Kopira podatke sa mreze radi brzine pregleda dokumenata, sluzi samo za pregled
 *  \param nArea    - podrucje
 *  \param cStaza  
 *  \param cIme 
 *  \param nIndexa
 *  \param cDefault
 */
 
function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
*{
local cPath,cScreen

if cDefault==NIL
  cDefault:="0"
endif

select (nArea)
if gKesiraj $ "CD"
  cPath:=strtran(cStaza,LEFT(cStaza,3),gKesiraj+":\")

  DirMak2(cPath)  // napravi odrediçni direktorij

  if cDefault!="0"
    if !file( cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
     save screen to cScr
     cls
     ? "Molim sacekajte prenos podataka na vas racunar "
     ? "radi brzeg pregleda podataka"
     ?
     ? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     ?
     close all
     Copysve(cIme+"*.DB?",cStaza,cPath)
     Copysve(cIme+"*.CDX",cStaza,cPath)
     ?
     ? "pritisni nesto za nastavak ..."
     inkey(10)
     restore screen from cScr
   endif
  endif

else
  cPath:=cStaza
endif
cPath:=cPath+cIme
use  (cPath)
return NIL
*}

#else


/*! \fn OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
 *  \brief Kopira podatke sa mreze radi brzine pregleda dokumenata, sluzi samo za pregled, specificna za AX verziju programa
 *  \param nArea    - podrucje
 *  \param cStaza  
 *  \param cIme 
 *  \param nIndexa
 *  \param cDefault
 */

function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
*{
//CAX verzija
local cPath,cScreen

if cDefault==NIL
  cDefault:="0"
endif

select (nArea)

if used()
	return
endif
// CAX - samo jednom otvori

if gKesiraj $ "CD"
  cPath:=strtran(cStaza,LEFT(cStaza,3),gKesiraj+":\")

  DirMak2(cPath)  // napravi odrediçni direktorij

  if cDefault!="0"
    if !file( cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
     save screen to cScr
     cls
     ? "Molim sacekajte prenos podataka na vas racunar "
     ? "radi brzeg pregleda podataka"
     ?
     ? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     ?
     close all
     Copysve(cIme+"*.DB?",cStaza,cPath)
     Copysve(cIme+"*.CDX",cStaza,cPath)
     ?
     ? "pritisni nesto za nastavak ..."
     inkey(10)
     restore screen from cScr
   endif
  endif

else
  cPath:=cStaza
endif
cPath:=cPath+cIme
use  (cPath)
return NIL
*}

#endif




/*! \fn Azur(lAuto)
 *  \brief Azuriranje knjizenja
 *  \param lAuto - .t. azuriraj automatski, .f. azuriraj sa pitanjem
 */
 
function Azur(lAuto)
*{
local bErrHan, nC

if Logirati(goModul:oDataBase:cName,"DOK","AZUR")
	lLogAzur:=.t.
else
	lLogAzur:=.f.
endif

if lAuto==NIL
	lAuto:=.f.
endif

if !lAuto .and. Pitanje("pAz","Sigurno zelite izvrsiti azuriranje (D/N)?","N")=="N"
	return
endif

O_KONTO
O_PARTN
O_PRIPR
O_SUBAN
O_ANAL
O_SINT
O_NALOG

O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG


fAzur:=.t.
select PSUBAN
if reccount2()==0; fAzur:=.f.; endif
select PANAL
if reccount2()==0; fAzur:=.f.; endif
select PSINT
if reccount2()==0; fAzur:=.f.; endif

if !fAzur
  Beep(3)
  Msg("Niste izvrsili stampanje naloga ...",10)
  closeret
endif

if lLogAzur
	EventLog(nUser,goModul:oDataBase:cName,"DOK","AZUR",nil,nil,nil,nil,"","",pripr->idfirma+"-"+pripr->idvn+"-"+pripr->brnal,Date(),Date(),"","Azuriranje dokumenta - poceo !")

endif

Box(,5,60)
select PSUBAN; set order to 1; go top

fIzgenerisi:=.f.
if reccount2()>9999 .and. !lAuto
  if Pitanje(,"Staviti na stanje bez provjere ?","N")=="D"
    fizgenerisi:=.t.
  endif
endif

#ifdef CAX


// kod AX-a mora ovo biti odradjeno prije transakcije
if !( SUBAN->(flock()) .and. ANAL->(flock()) .and.  SINT->(flock()) .and.  NALOG->(flock())  )
  Beep(4)
  BoxC()
  Msg("Azuriranje NE moze vrsiti vise korisnika istovremeno !")
  select suban
  dbunlockall()
  select anal
  dbunlockall()
  select sint
  dbunlockall()
  select nalog
  dbunlockall()
  closeret
endif


#xcommand sc_BEGIN TRANSACTION           ;
     =>  if reccount()<=501 ; dbCommitAll(); Ax_Transaction( 1 ) ; endif


#xcommand sc_COMMIT TRANSACTION         ;
      => if AX_Transaction()          ;
       ;  dbCommitAll()                 ;
       ;  AX_Transaction( 2 )           ;
       ; end

#xcommand sc_ROLLBACK TRANSACTION       ;
      => if AX_Transaction()         ;
       ;  dbCommitAll()                ;
       ;  AX_Transaction( 3 )           ;
       ; end

bErrHan:=ERRORBLOCK({|oError| TPSErrHandler(oError)})
BEGIN SEQUENCE
sc_BEGIN TRANSACTION

#endif

do while !eof()
// prodji kroz PSUBAN i vidi da li je nalog zatvoren
// samo u tom slucaju proknjizi nalog u odgovarajuce datoteke

cNal:=IDFirma+IdVn+BrNal
IF "." $ cNal
  MsgBeep("Nalog "+IdFirma+"-"+idvn+"-"+brnal+;
          " sadrzi znak '.' i zato nece biti azuriran!")
  DO WHILE !EOF() .and. cNal==IDFirma+IdVn+BrNal
    SKIP 1
  ENDDO
  LOOP
ENDIF
@ m_x+1,m_y+2 SAY "Azuriram nalog: "+IdFirma+"-"+idvn+"-"+brnal
nSaldo:=0

cEvIdFirma:=idfirma
cEvVrBrNal:=idvn+"-"+brnal
dDatNaloga:=datdok
dDatValute:=datval

do while !eof() .and. cNal==IdFirma+IdVn+BrNal

    if !empty(psuban->idpartner)
      select partn
      hseek psuban->idpartner

      if !found() .and. !fizgenerisi
        Beep(1)
        Msg("Stavka br."+psuban->rbr+": Nepostojeca sifra partnera!")
        IF PSUBAN->idvn=="00" .and. Pitanje(,"Preuzeti nepostojecu sifru iz sezone?","N")=='D'
          PreuzSezSPK("P")
        ELSE
          Boxc()
#ifdef CAX
          MsgBeep("Prekidam transakciju  -1 ?!")
          sc_ROLLBACK TRANSACTION
          BREAK
#else
          select PSUBAN
	  zapp()
          select PANAL
	  zapp()
          select PSINT
	  zapp()
          closeret
#endif
        ENDIF
      endif
    endif
    if !empty(psuban->idkonto)
      select konto; hseek psuban->idkonto
      if !found() .and. !fizgenerisi
        Beep(1)
        Msg("Stavka br."+psuban->rbr+": Nepostojeca sifra konta!")
        IF PSUBAN->idvn=="00" .and. Pitanje(,"Preuzeti nepostojecu sifru iz sezone?","N")=='D'
          PreuzSezSPK("K")
        ELSE
          Boxc()
#ifdef CAX
          MsgBeep("Prekidam transakciju -2 ?!")
          sc_ROLLBACK TRANSACTION
          BREAK
#else
          select PSUBAN; zapp()
          select PANAL; zapp()
          select PSINT; zapp()
          closeret
#endif
        ENDIF
      endif
    endif
    select psuban

    if D_P=="1"
       nSaldo+=IznosBHD
    else
       nSaldo-=IznosBHD
    endif
    skip
enddo

if round(nSaldo,4)<>0 .and. gRavnot=="D"
  Beep(1)
  Msg("Neophodna ravnoteza naloga, azuriranje nece biti izvrseno!")
endif

// nalog je uravnotezen, azuriraj ga !
if round(nSaldo,4)==0  .or. gRavnot=="N" 

#ifndef CAX
  // kod AX-a mora ovo biti odradjeno prije transakcije
  if !( SUBAN->(flock()) .and. ANAL->(flock()) .and.  SINT->(flock()) .and.  NALOG->(flock())  )
    Beep(4)
    BoxC()
    Msg("Azuriranje NE moze vrsiti vise korisnika istovremeno !")
    closeret
  endif
#endif


  @ m_x+3,m_y+2 SAY "NALOZI         "
  select  SUBAN; SET ORDER TO 4  //"4","idFirma+IdVN+BrNal+Rbr"
  seek cNal
  if found()
  	BoxC()
  	Msg("Vec postoji u suban ? "+IdFirma+"-"+IdVn+"-"+BrNal+ "  !")
#ifdef CAX
  	MsgBeep("Prekidam transakciju ?! -4 ")
 	sc_ROLLBACK TRANSACTION
  	BREAK
#ELSE
  	closeret
#ENDIF
  endif


  select  NALOG
  seek cNal
  if found()
  	BoxC()
	Msg("Vec postoji proknjizen nalog "+IdFirma+"-"+IdVn+"-"+BrNal+ "  !")
#ifdef CAX
  MsgBeep("Prekidam transakciju ?! -5 ")
  sc_ROLLBACK TRANSACTION
  BREAK
#ELSE
  closeret
#ENDIF
  endif // found()

  select PNALOG
  seek cNal
  if found()
    Scatter()
    _Sifra:=sifrakorisn
    select NALOG
    append ncnl
    sql_append()
    Gather2()
    GathSql()
    sql_azur(.f.)
  else
    Beep(4)
    Msg("Greska... ponovi stampu naloga ...")
  endif

  @ m_x+3,m_y+2 SAY "ANALITIKA       "
  select PANAL
  seek cNal
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    Scatter()
    select ANAL
    append ncnl
    sql_append()
    Gather2()
    GathSql()
    select PANAL
    skip
  enddo

  @ m_x+3,m_y+2 SAY "SINTETIKA       "
  select PSINT; seek cNal
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    Scatter()
    select SINT
    append ncnl
    sql_append()
    Gather2()
    GathSql()
    select PSINT
    skip
  enddo

  @ m_x+3,m_y+2 SAY "SUBANALITIKA   "
  select SUBAN
  set order to tag "3"
  select PSUBAN
  seek cNal
  nC:=0
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal


    @ m_x+3,m_y+25 SAY ++nc  pict "9999"

    Scatter()
    if _d_p=="1"; nSaldo:=_IznosBHD; else; nSaldo:= -_IznosBHD; endif
    SELECT SUBAN
    SEEK _IdFirma+_IdKonto+_IdPartner+_BrDok    // isti dokument
    nRec:=recno()
    do while  !eof() .and. (_IdFirma+_IdKonto+_IdPartner+_BrDok)== (IdFirma+IdKonto+IdPartner+BrDok)
       if d_P=="1"; nSaldo+= IznosBHD; else; nSaldo -= IznosBHD; endif
       skip
    enddo

    if abs(round(nSaldo,3))<=gnLOSt
      go nRec
      do while  !eof() .and. (_IdFirma+_IdKonto+_IdPartner+_BrDok)== (IdFirma+IdKonto+IdPartner+BrDok)
        field->OtvSt:="9"
        skip
      enddo
      _OtvSt:="9"
    endif

    // dodaj u suban
    append ncnl
    sql_append()
    Gather2()
    GathSql()

    select PSUBAN
    skip
  enddo

if lLogAzur
	EventLog(nUser,goModul:oDataBase:cName,"DOK","AZUR",nSaldo,nil,nil,nil,"","",cEvIdFirma+cEvVrBrNal,dDatNaloga,dDatValute,"","Azuriranje dokumenta - zavrsio !!!")
endif



  // nalog je uravnotezen, moze se izbrisati iz PRIPR
  
  select PRIPR
  seek cNal
  @ m_x+3,m_y+2 SAY "BRISEM PRIPREMU "
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    skip
    ntRec:=RECNO()
    skip -1
    dbdelete2()
    go ntRec
  enddo

endif // saldo == 0

select PSUBAN
enddo

BoxC()


#IFDEF CAX
sc_COMMIT TRANSACTION

select suban; dbunlockall()
select anal; dbunlockall()
select sint; dbunlockall()
select nalog; dbunlockall()

RECOVER USING oError
END SEQUENCE
ERRORBLOCK(bErrHan)
#ENDIF


select PRIPR; __dbpack()

select PSUBAN; zap
select PANAL; zap
select PSINT; zap
select PNALOG; zap

closeret
return
*}


#ifdef CAX

/*! \fn TpsErrHandler(oError)
 *  \brief
 *  \param oError
 */
 
function TpsErrHandler(oError)
*{
MsgBeep("Prekidam transakciju - TPS ERR HND ???")
sc_ROLLBACK TRANSACTION
BoxC()
BREAK oError
return
*}

#endif


/*! \fn Dupli(cIdFirma,cIdVn,cBrNal)
 *  \brief Provjera duplog naloga
 *  \param cIdFirma
 *  \param cIdVn
 *  \param cBrNal
 */
 
function Dupli(cIdFirma,cIdVn,cBrNal)
*{
PushWa()

select NALOG
set order to 1
seek cIdFirma+cIdVN+cBrNal

if found()
   MsgO(" Dupli nalog ! ")
   Beep(3)
   MsgC()
   PopWa()
   return .f.
endif

PopWa()
return .t.
*}


