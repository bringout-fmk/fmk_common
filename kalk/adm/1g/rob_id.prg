#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/adm/1g/rob_id.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rob_id.prg,v $
 * Revision 1.2  2002/06/18 14:02:38  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */

/*! \file fmk/kalk/adm/1g/rob_id.prg
 *  \brief
 */


/*! \fn RobaIdSredi()
 *  \brief Ispravka sifre artikla u dokumentima
 */

function RobaIdSredi()
*{
cSifOld:=space(10)
cSifNew:=space(10)

if !SigmaSif("SIGMASIF")
  return
endif

O_ROBA
O_KALK
if file(SezRad(gDirFakK)+"FAKT.DBF")
  XO_FAKT
  fSrediF:=.t.
else
  fSrediF:=.f.
endif

Box(,10,60)

do while .t.
	@ m_x+6,m_y+2 SAY "                 "
	@ m_x+1,m_Y+2 SAY "ISPRAVKA SIFRE ARTIKLA U DOKUMENTIMA"
	@ m_x+2,m_Y+2 SAY "Stara sifra:" GET cSifOld pict "@!"
	@ m_x+3,m_Y+2 SAY "Nova  sifra:" GET cSifNew pict "@!" valid !empty(cSifNew)
	read
	ESC_BCR

	if !(kalk->(flock())) .or. !(xfakt->(flock())) .or. !(roba->(flock()))
		Msg("Ostali korisnici ne smiju raditi u programu")
		closeret
	endif

	select kalk
	locate for idroba==cSifNew
	
	if found()
		BoxC()
		Msg("Nova sifra se vec nalazi u prometu. prekid !")
		closeret
	endif

	locate for idroba==cSifOld
	nRbr:=0

	do while found()
		_field->idroba:=cSifNew
		@ m_X+5,m_y+2 SAY ++nRbr pict "999"
		continue
	enddo

	if fSrediF
		select xfakt
		locate for idroba==cSifOld
		nRbr:=0
		do while found()
			@ m_X+5,m_y+2 SAY ++nRbr pict "999"
			_field->idroba:=cSifNew
			continue
		enddo
	endif

	select roba
	locate for id==cSifOld
	nRbr:=0
	do while found()
		@ m_X+5,m_y+2 SAY ++nRbr pict "999"
		_field->id:=cSifNew
		continue
	enddo
	Beep(2)
	@ m_x+6,m_y+2 SAY "Sifra promijenjena"
enddo //.t.

BoxC()
closeret
*}


/*! \fn Sljedeci(cIdFirma,cVrsta)
 *  \brief Za zadanu firmu i vrstu dokumenta daje sljedeci slobodan broj dokumenta
 */

function Sljedeci(cIdFirma,cVrsta)
*{
local cBrKalk
if gBrojac=="D"
 select kalk
 set order to 1
 seek cIdFirma+cVrsta+"X"
 skip -1
 if idvd<>cVrsta
   cBrKalk:=space(8)
 else
   cBrKalk:=brdok
 endif
 cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
endif
return cBrKalk
*}
