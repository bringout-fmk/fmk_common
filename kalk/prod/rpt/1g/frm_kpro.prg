#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/frm_kpro.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: frm_kpro.prg,v $
 * Revision 1.2  2002/06/21 12:12:51  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/frm_kpro.prg
 *  \brief Kartica prodavnice koja se poziva iz pripreme dokumenta
 */


/*! \fn KPro()
 *  \brief Kartica prodavnice koja se poziva iz pripreme dokumenta
 */

function KPro()
*{
local nR1,nR2,nR3,cidfirma:=space(2),cidroba:=space(10),ckonto:=space(7)
private GetList:={}

select  roba
nR1:=recno()
select pripr
nR2:=recno()
select tarifa
nR3:=recno()

if empty(pripr->pkonto)
   box(,2,50)
     cidfirma:=gfirma
     @ m_x+1,m_y+2 SAY "KARTICA PRODAVNICA"
     @ m_x+2,m_y+2 SAY "Kartica konto-artikal" GET ckonto
     @ m_x+2,col()+2 SAY "-" GET cidroba
     read
   BoxC()
else
   cidfirma:=pripr->idfirma
   ckonto:=pripr->pkonto
   cidroba:=pripr->idroba
endif

close all
Karticap(cIdFirma,cidroba,ckonto)
OEdit()
select roba
go nR1
select pripr
go nR2
select tarifa
go nR3
select pripr
return
*}

