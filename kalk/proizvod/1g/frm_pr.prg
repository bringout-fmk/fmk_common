#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/proizvod/1g/frm_pr.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: frm_pr.prg,v $
 * Revision 1.2  2002/06/21 13:07:28  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/proizvod/1g/frm_pr.prg
 *  \brief
 */


/*! \fn Get1_PR()
 *  \brief Prva strana maske za unos dokumenta tipa PR
 */

// ovim funkcijama je proslijedjen parametar fnovi kao privatna varijabla
function Get1_PR()
*{
select F_SAST
if !used(); O_SAST; endif
select pripr

if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr==1
 @ m_x+ 6,m_y+2   SAY "Mag .got.proizvoda zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 @  m_x+7,m_y+2   SAY "Mag. sirovina razduzuje    " get _IdKonto2 pict "@!" valid P_Konto(@_IdKonto2)
 @ m_x+12,m_y+2  SAY "Proizvod  " GET _IdRoba pict "@!" ;
                  valid  {|| P_Roba(@_IdRoba),Reci(12,24,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 @ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)
 select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
 select PRIPR  // napuni tarifu

 @ m_x+13,m_y+2   SAY "Kolicina  " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
 read
 _BrFaktP:=_idzaduz2
 // sada trazim trebovanja u proizvod. u toku i filujem u stavke od 100 pa nadalje
 // ove stavke imace  mu_i=="5", mkonto=_idkonto2, nc,nv
 //"KALKi7","idFirma+mkonto+IDZADUZ2+idroba+dtos(datdok)","KALK")

 nTPriPrec:=recno()
 select pripr; go bottom
 if val(rbr)<900 .or. ;
    (val(rbr)>1 .and. Pitanje(,"Zelite li izbrisati izgenerisane sirovine ?","N")=="D")

  do while !bof() .and. val(rbr)>900
    skip -1; nTrec:=recno(); skip
    dbdelete2()
    go nTrec
  enddo

  select ROBA; hseek _idroba
  if roba->tip="P" .and. nRbr==1  // radi se o proizvodu, prva stavka
     nRbr2:=900
     select sast
     hseek  _idroba
     do while !eof() .and. id==_idroba // setaj kroz sast
       select roba; hseek sast->id2
       select pripr
       locate for idroba==sast->id2
       if found()
         replace kolicina with kolicina + pripr->kolicina*sast->kolicina
       else
         select pripr
         append blank
         replace  idfirma with _IdFirma,;
                  rbr     with str(++nRbr2,3),;
                  idvd with "PR",;   // izlazna faktura
                  brdok with _Brdok,;
                  datdok with _Datdok,;
                  idtarifa with ROBA->idtarifa,;
                  brfaktp with "",;
                  datfaktp with _Datdok,;
                  idkonto   with _idkonto,;
                  idkonto2  with _idkonto2,;
                  datkurs with _Datdok,;
                  kolicina with _kolicina*sast->kolicina,;
                  idroba with sast->id2,;
                  nc  with 0,;
                  vpc with 0,;
                  pu_i with "",;
                  mu_i with "5",;
                  error with "0",;
                  mkonto with _idkonto2

         nTTKNrec:=recno()
         //////// kalkulacija nabavne cijene
         //////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
         nKolS:=0;nKolZN:=0;nc1:=nc2:=0; dDatNab:=ctod("")
         if _TBankTr<>"X"  // ako je X onda su stavke vec izgenerisane
          if !empty(gMetodaNC)  .and. !(roba->tip $ "UT")
           MsgO("Racunam stanje na skladistu")
               KalkNab(_idfirma,sast->id2,_idkonto2,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
           MsgC()
          endif
          if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab)+" sirovina "+sast->id2,4);endif
          if _kolicina>=0 .OR. ROUND(_NC,3)==0 .and. !(roba->tip $ "UT")
           if gmetodanc == "2"
             select roba
             replace nc with _nc
             select pripr // nafiluj sifrarnik robe sa nc sirovina, robe
           endif
          endif
          select pripr
          go nTTKNRec
          replace nc with nc2, gkolicina with nKolS

       endif // nova stavka

         endif
       select sast
       skip
     enddo

  endif // roba->tip == "P"

 endif

 select pripr
 go  nTPriPrec
 _DatKurs:=_DatFaktP
 if gNW<>"X"
  @ m_x+10,m_y+42  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 read; ESC_RETURN K_ESC
else

 @ m_x+ 7,m_y+2   SAY "Mag. gotovih proizvoda zaduzuje ";?? _IdKonto
 @ m_x+ 8,m_y+2   SAY "Magacin sirovina razduzuje      ";?? _IdKonto2
 if gNW<>"X"
   @ m_x+10,m_y+42  SAY "Zaduzuje: "; ?? _IdZaduz
 endif

endif // nRbr==1

@ m_x+11,m_y+66 SAY "Tarif.brĿ"

if nRbr<>1
   @ m_x+12,m_y+2  SAY "Sirovina  " GET _IdRoba pict "@!" ;
                  valid  {|| P_Roba(@_IdRoba),Reci(12,24,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
   @ m_x+13,m_y+2   SAY "Kolicina  " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
endif

read; ESC_RETURN K_ESC

if nRbr<>1  // sirovine
 //////// kalkulacija nabavne cijene
 nKolS:=0;nKolZN:=0;nc1:=nc2:=0; dDatNab:=ctod("")
 if _TBankTr<>"X"  // ako je X onda su stavke vec izgenerisane
  if !empty(gMetodaNC)  .and. !(roba->tip $ "UT")
   MsgO("Racunam stanje na skladistu")
       KalkNab(_idfirma,_idroba,_idkonto2,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
   MsgC()
  endif
  if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab)+" sirovina "+sast->id2,4);endif
  if round(nKols-_kolicina,4)<0; MsgBeep("Na stanju je samo :"+str(nkols,15,3)); _error:="1"; endif
 endif // tbanktr
 select pripr
endif

select koncij; seek trim(_idkonto); select pripr

_MKonto:=_Idkonto; _MU_I:="1"
DatPosljK()

if fNovi
 select ROBA; HSEEK _IdRoba
 _VPC:=KoncijVPC()
 if Carina<>0
    _TCarDaz:="%"
    _CarDaz:=carina
 endif
endif

select PRIPR
if _tmarza<>"%"  // procente ne diraj
 _Marza:=0
endif

if nRbr<>1
 @ m_x+15,m_y+2   SAY "N.CJ.(DEM/JM):"
 @ m_x+15,m_y+50  GET _NC PICTURE PicDEM valid _nc>=0
 read
 _Mkonto:=_idkonto2
 _mu_i:="5"
endif

  ************ preracunaj nc proiz ***********
  nTT0Rec:=recno()
  select pripr; set order to 1; go top
  nNV:=0
  do while !eof()
     if val(RBr)>900
       if val(rbr)=nRbr
        nNV+=_NC*_kolicina
       else
        nNV+=NC*kolicina  // ovo je u stvari nabavna vrijednost
       endif
       if nRbr==1 .and. gkolicina<kolicina
           Beep(2)
           Msg("Na stanju "+idkonto2+" se nalazi samo "+str(gkolicina,9,2)+" sirovine "+idroba ,0)
           _error:="1"
       endif
     endif
     skip
  enddo
  if nRbr==1
    _fcj:=nNV/_kolicina
  else
   if !fnovi
     go top
     if val(rbr)=1
       replace fcj with nNv/kolicina
     endif
   endif
  endif
  go nTT0Rec
  ************ preracunaj nc proiz ***********
if nRbr==1
 _fcj:= nNV/_kolicina
 @ m_x+15,m_y+2   SAY "N.CJ.(DEM/JM):"
 @ m_x+15,m_y+50  GET _FCJ PICTURE PicDEM valid _fcj>0 when V_kol10()
 read; ESC_RETURN K_ESC
endif

_FCJ2:=_FCJ*(1-_Rabat/100)

return lastkey()
*}




/*! \fn Get2_PR()
 *  \brief Druga strana maske za unos dokumenta tipa PR
 */

function Get2_PR()
*{
local cSPom:=" (%,A,U,R) "

if nrbr<>1 ; return K_ENTER; endif

private getlist:={}

if empty(_TPrevoz); _TPrevoz:="%"; endif
if empty(_TCarDaz); _TCarDaz:="%"; endif
if empty(_TBankTr); _TBankTr:="%"; endif
if empty(_TSpedTr); _TSpedtr:="%"; endif
if empty(_TZavTr);  _TZavTr:="%" ; endif
if empty(_TMarza);  _TMarza:="%" ; endif

@ m_x+2,m_y+2     SAY cRNT1+cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
@ m_x+2,m_y+40    GET _Prevoz PICTURE  PicDEM

@ m_x+3,m_y+2     SAY cRNT2+cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" pict "@!"
@ m_x+3,m_y+40    GET _BankTr PICTURE PicDEM

@ m_x+4,m_y+2     SAY cRNT3+cSPom GET _TSpedTr valid _TSpedTr $ "%AUR" pict "@!"
@ m_x+4,m_y+40    GET _SpedTr PICTURE PicDEM

@ m_x+5,m_y+2     SAY cRNT4+cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
@ m_x+5,m_y+40    GET _CarDaz PICTURE PicDEM

@ m_x+6,m_y+2     SAY cRNT5+cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
@ m_x+6,m_y+40    GET _ZavTr PICTURE PicDEM ;
                    VALID {|| NabCj(),.t.}

@ m_x+8,m_y+2     SAY "CIJENA KOST.  "
@ m_x+8,m_y+50    GET _NC     PICTURE PicDEM

if koncij->naz<>"N1"  // vodi se po vpc
  private fMarza:=" "
  @ m_x+10,m_y+2    SAY "Magacin. Marza            :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
  @ m_x+10,m_y+40 GET _Marza PICTURE PicDEM
  @ m_x+10,col()+1 GET fMarza pict "@!"
  @ m_x+12,m_y+2    SAY "VELEPRODAJNA CJENA  (VPC)   :"
  @ m_x+12,m_y+50 get _VPC    picture PicDEM;
                 VALID {|| Marza(fMarza),.t.}

  read
  VPCuSif(_vpc)
else
  read
  _Marza:=0; _TMarza:="A"; _VPC:=_NC
endif

if nRbr=1
_MKonto:=_Idkonto; _MU_I:="1"
endif
nStrana:=3

//if nRbr==1 //????
//  go bottom
//endif
return lastkey()
*}


