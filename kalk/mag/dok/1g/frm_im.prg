#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/frm_im.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: frm_im.prg,v $
 * Revision 1.6  2003/10/11 09:26:51  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.5  2003/10/06 15:00:27  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.4  2002/06/28 23:28:32  ernad
 *
 *
 * prenos IM() -> gendok komponentu
 *
 * Revision 1.3  2002/06/26 17:53:45  ernad
 *
 *
 * ciscenje, inventura magacina
 *
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/frm_im.prg
 *  \brief Unos dokumenta inventure magacina (tip dokumenta IM)
 */



/*! \fn Get1_IM()
 *  \brief Prva strana maske za unos dokumenta tipa IM
 */

function Get1_IM()
*{
local nFaktVPC

_DatFaktP:=_datdok
_DatKurs:=_DatFaktP

@ m_x+8,m_y+2  SAY "Konto koji zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
if gNW<>"X"
	@ m_x+8,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
endif
READ
ESC_RETURN K_ESC

@ m_x+10,m_y+66 SAY "Tarif.br-v"

if lKoristitiBK
	@ m_x+11,m_y+2 SAY "Artikal  " GET _IdRoba PICT "@!S10" WHEN {|| _idRoba:=PADR(_idRoba,VAL(gDuzSifIni)),.t.} VALID {|| P_Roba(@_IdRoba), Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40), _IdTarifa:=iif(fNovi, ROBA->idtarifa, _IdTarifa), .t.}
else
	@ m_x+11,m_y+2 SAY "Artikal  " GET _IdRoba PICT "@!" VALID {|| P_Roba(@_IdRoba), Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40), _IdTarifa:=iif(fNovi, ROBA->idtarifa, _IdTarifa), .t.}
endif
@ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

READ
ESC_RETURN K_ESC
if lKoristitiBK
 	_idRoba:=Left(_idRoba, 10)
endif

SELECT tarifa
HSEEK _IdTarifa
SELECT pripr

DuplRoba()
@ m_x+13,m_y+2   SAY "Knjizna kolicina " GET _GKolicina PICTURE PicKol WHEN {|| IIF(gMetodaNC==" ",.t.,.f.)}
@ m_x+13,col()+2 SAY "Popisana Kolicina" GET _Kolicina PICTURE PicKol
@ m_x+15,m_y+2    SAY "CIJENA" GET _vpc pict picdem

READ
ESC_RETURN K_ESC

_MKonto:=_Idkonto

// inventura
_MU_I:="I"     

_PKonto:=""
_PU_I:=""

nStrana:=3

return LASTKEY()
*}
