#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/si/1g/gen_dok.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.3 $
 * $Log: gen_dok.prg,v $
 * Revision 1.3  2002/06/24 08:46:11  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/si/1g/gen_dok.prg
 *  \brief Generacija dokumenata sitnog inventara
 */

/*! \fn Otpis16SI()
 *  \brief Otpis 16 sitnog inventara. Kada je izvrsena doprema SI 16kom, napraviti novu 16ku na konto troskovnog mjesta otpisanog SI.
 */
 
function Otpis16SI()
*{
O_KONCIJ
O_PRIPR
O_PRIPR2
O_KALK
if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK
   O_SIFV
endif
O_ROBA

select pripr; go top
private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok
if !(cidvd $ "16") .or. "-X"$cBrDok .or. Pitanje(,"Formirati dokument radi evidentiranja otpisanog dijela? (D/N)","N")=="N"
  close all
  return .f.
endif

cBrUlaz := PADR( TRIM(PRIPR->brdok)+"-X" , 8 )

select pripr
go top
private nRBr:=0
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
  scatter()
  select pripr2
   append blank
    _brdok:=cBrUlaz
    _idkonto:="X-"+TRIM(pripr->idkonto)
    _MKonto:=_idkonto
    _TBankTr:="X"    // izgenerisani dokument
     gather()
  select pripr
  skip
enddo

close all
RETURN .t.
*}

