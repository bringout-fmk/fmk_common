#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/proizvod/1g/frm_rn.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: frm_rn.prg,v $
 * Revision 1.2  2002/06/21 13:07:28  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/proizvod/1g/frm_rn.prg
 *  \brief Maska za unos dokumenta tipa RN
 */


/*! \fn Get1_RN()
 *  \brief Prva strana maske za unos dokumenta tipa RN
 */

function Get1_RN()
*{
// ovim funkcijama je proslije|en parametar fnovi kao privatna varijabla
if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr>900
  beep(2)
  Msg("Razduzenja materijala se ne mogu ispravljati")
  keyboard K_ESC
  nStrana:=3
  return  lastkey()
endif

if nRbr==1  .or. !fnovi .or. gMagacin=="1"
 @  m_x+6,m_y+2   SAY "ZATVORITI RADNI NALOG:" get _IdZaduz2 pict "@!"
 @  m_x+7,m_y+2   SAY "Mag. proivod. u toku :" get _IdKonto2 pict "@!" valid P_Konto(@_IdKonto2)
 @ m_x+10,m_y+2   SAY "Mag. gotovih proizvoda zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 read
 _BrFaktP:=_idzaduz2
 // sada trazim trebovanja u proizvod. u toku i filujem u stavke od 100 pa nadalje
 // ove stavke imace  mu_i=="5", mkonto=_idkonto2, nc,nv
 //"KALKi7","idFirma+mkonto+IDZADUZ2+idroba+dtos(datdok)","KALK")

 nTPriPrec:=recno()


 select pripr; go bottom

 do while !bof() .and. val(rbr)>900
    skip -1; nTrec:=recno(); skip
    dbdelete2()
    go nTrec
 enddo

 select doks; set order to 2
 //CREATE_INDEX("DOKSi2","IdFirma+MKONTO+idzaduz2+idvd+brdok","DOKS")

 seek _idfirma+_idkonto+_idzaduz2+"RN"
 // npr: 10 5100 564   RN
 if found()
   Beep(2)
   Msg("Vec postoji dokument RN broj "+doks->brdok+" za ovaj radni nalog")
   select pripr
   keyboard K_ESC
   nStrana:=3
   return  lastkey()
 endif

 seek _idfirma+_idkonto2+_idzaduz2  //  10 5000 564
 nII:=0
 nCntR:=0
 do while !eof() .and.;
                 (_idfirma+_idkonto2+_idzaduz2 = idfirma+mkonto+idzaduz2)

    select kalk; set order to 1
    seek doks->(idfirma+idvd+brdok)
    nKolicina:=0   ; nNabV:=0
    do while !eof() .and. doks->(idfirma+idvd+brdok) == (idfirma+idvd+brdok)

          //CREATE_INDEX(PRIVPATH+"PRIPRi3","idFirma+idvd+brdok+idroba+rbr",PRIVPATH+"PRIPR")
          select pripr; SET ORDER TO 3
          seek _idfirma+_idvd+_brdok+kalk->idroba+"9"
          // nadji odgovoarajucu stavku iznad 900

          if !found()
             ++nCntR
             append blank
             replace idfirma with _idfirma, idvd with _idvd, brdok with _brdok,;
                     rbr  with str(900+nCntR,3), idroba with kalk->idroba,;
                     mkonto with kalk->mkonto,;
                     mu_i with "5",;
                     error with "0",;
                     datdok with _datdok,;
                     datfaktp with _datdok,;
                     DATKURS WITH _DATDOK,;
                     idzaduz2 with _idzaduz2,;
                     idkonto with _idkonto, idkonto2 with _idkonto2,;
                     idtarifa with "XXXXXX",;
                     brfaktp with _brfaktp



          endif

          if KALK->mu_i=="1"
              replace kolicina with kalk->kolicina+kolicina,;
                      nc with nc+kalk->(kolicina*nc)
          elseif KALK->mu_i="5"
              replace kolicina with -kalk->kolicina+kolicina,;
                      nc with nc-kalk->(kolicina*nc)
          endif

          select pripr; set order to 1
          select kalk
          skip

    enddo

    select doks; skip
 enddo

 select pripr; set order to 1; go top
 nNV:=0
 do while !eof()
     if val(RBr)>900
       nNV+=NC  // ovo je u stvari nabavna vrijednost
       replace NC with NC/Kolicina,;
               vpc with NC,;
               fcj with nc
     endif
     skip
 enddo

 go  nTPriPrec
 select pripr
 _DatKurs:=_DatFaktP
 if gNW<>"X"
  @ m_x+10,m_y+42  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 read; ESC_RETURN K_ESC
else

 @ m_x+10,m_y+2   SAY "Mag. gotovih proizvoda zaduzuje ";?? _IdKonto
 if gNW<>"X"
   @ m_x+10,m_y+42  SAY "Zaduzuje: "; ?? _IdZaduz
 endif
endif


@ m_x+11,m_y+66 SAY "Tarif.brĿ"
@ m_x+12,m_y+2  SAY "Proizvod  " GET _IdRoba pict "@!" ;
                  valid  {|| P_Roba(@_IdRoba),Reci(12,25,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

read; ESC_RETURN K_ESC
select koncij; hseek trim(_idkonto); select pripr

_MKonto:=_Idkonto; _MU_I:="1"
DatPosljK()

select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
select PRIPR  // napuni tarifu

@ m_x+13,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
read
if fNovi
 select ROBA; HSEEK _IdRoba
 if koncij->naz=="P2"
   _VPC:=PlC
 else
   _VPC:=KoncijVPC()
 endif
 if Carina<>0
    _TCarDaz:="%"
    _CarDaz:=carina
 endif
endif

select PRIPR
if _tmarza<>"%"  // procente ne diraj
 _Marza:=0
endif

if nRbr==1
 _fcj:=_fcj2:= nNV/_kolicina
endif

@ m_x+15,m_y+2   SAY "N.CJ.(DEM/JM):"
@ m_x+15,m_y+50  GET _FCJ PICTURE PicDEM valid _fcj>0 when {|| _fcj:=iif(nRbr>1 .and. fnovi,_vpc,_fcj),V_kol10()}


if gNW<>"X"
  @ m_x+18,m_y+2   SAY "Transport. kalo:"
  @ m_x+18,m_y+40  GET _GKolicina PICTURE PicKol

  @ m_x+19,m_y+2   SAY "Ostalo kalo:    "
  @ m_x+19,m_y+40  GET _GKolicin2 PICTURE PicKol
endif

read; ESC_RETURN K_ESC

_FCJ2:=_FCJ*(1-_Rabat/100)

return lastkey()
*}




/*! \fn Get2_RN()
 *  \brief Druga strana maske za unos dokumenta tipa RN
 */

function Get2_RN()
*{
local cSPom:=" (%,A,U,R) "
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
  if koncij->naz=="P2"
   @ m_x+12,m_y+2    SAY "PLANSKA CIJENA (PLC)        :"
  else
   @ m_x+12,m_y+2    SAY "VELEPRODAJNA CJENA  (VPC)   :"
  endif
  @ m_x+12,m_y+50 get _VPC    picture PicDEM;
                 VALID {|| Marza(fMarza),.t.}

  read
  if koncij->naz=="P2"
     if roba->plc==0
       if Pitanje(,"Staviti PLC  u sifrarnik ?","D")=="D"
         select roba
         replace plc with _vpc
         select pripr
       endif
     endif
  else
     if KoncijVPC()==0 .or. round(KoncijVPC(),4)<>round(_vpc,4)
       SetujVPC( _vpc , round(KoncijVPC(),4) <> round(_vpc,4) )
     else
       if (_vpc<>KoncijVPC()) ; Beep(1); Msg("Cijena u sifrarniku je "+str(KoncijVPC(),11,3),6); endif
     endif
  endif // p2
else
  read
  _Marza:=0; _TMarza:="A"; _VPC:=_NC
endif

_MKonto:=_Idkonto; _MU_I:="1"
nStrana:=3
return lastkey()
*}


