#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/inters/1g/frm_24.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: frm_24.prg,v $
 * Revision 1.2  2002/06/24 08:54:38  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/specif/inters/1g/frm_24.prg
 *  \brief Funkcije za obradu kalkulacija usluga - specificno za Intersped
 */

/*! \fn Get1_24()
 *  \brief Obradjuje kalkulacije usluga
 */

function Get1_24()
*{
_DatFaktP:=_datdok
  @  m_x+5,m_y+2   SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,5,30)
  @  m_x+6,m_y+2   SAY "Dokument - Broj:" get _BrFaktP
  @  m_x+6,col()+2 SAY "Datum:" get _DatFaktP
  _IdZaduz:=""
_DatKurs:=_DatFaktP
 read; ESC_RETURN K_ESC

 _kolicina:=1; _idtarifa:=padr(IzFMKINI("KALK","T24","N1"),len(_idtarifa))

 _tprevoz:=_tbanktr:=_tspedtr:=_tcardaz:=_tzavtr:="U"
 private nTroskovi:=0
 @ m_x+8,m_y+2   SAY "R.br" GET nRBr PICT '999' valid {|| CentrTxt("",24),.t.}
 @ m_x+10,m_y+2   SAY c24T1 GET  _prevoz pict picdem
 @ m_x+10,m_y+40  SAY c24T2 GET  _banktr pict picdem
 @ m_x+11,m_y+2   SAY c24T3 GET  _spedtr pict picdem
 @ m_x+11,m_y+40  SAY c24T4 GET  _cardaz pict picdem
 @ m_x+12,m_y+2   SAY c24T5 GET  _zavtr  pict picdem
 @ m_x+12,m_y+40  SAY c24T6 GET  _mpc     pict picdem
 @ m_x+13,m_y+2   SAY c24T7 GET  _mpcsapp pict picdem;
 valid {|| nTroskovi:=_prevoz+_banktr+_spedtr+_cardaz+_zavtr+_mpc+_mpcsapp,;
          devpos(m_X+15,m_Y+40), qqout("Ukupno troskovi:",nTroskovi), .t. }

 @ m_x+16,m_y+2  SAY "Tarifni stav:"  GET _IdTarifa ;
   valid  {|| P_Tarifa(@_IdTarifa),devpos(m_x+16,m_y+40), qqout("Porez na usluge (%): ",tarifa->vpp),.t.}
 @ m_x+17,m_y+2  SAY "Fakturna vrijednost bez poreza:" GET _fcj pict picdem;
    valid {|| _nc:=iif(_fcj==0,_nc,nTroskovi+(_fcj-nTroskovi)*(1+tarifa->vpp/100)),.t. }
 @ m_x+18,m_y+2  SAY "Fakturna vrijednost sa porezom:" GET _nc pict picdem;
    valid {|| _fcj:=iif(_fcj==0 .or. (_fcj<>0 .and. _nc<>0),nTroskovi+(_nc-nTroskovi)/(1+tarifa->vpp/100),_fcj),;
              ShowGets(),.t.}
 read
 _marza:=_fcj-nTroskovi
 @ m_x+19,m_y+2 SAY "Prihod :" GET _marza pict picdem
 read

nStrana:=3
return lastkey()
*}

