#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/proizvod/1g/frmg_rn.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: frmg_rn.prg,v $
 * Revision 1.2  2002/06/21 13:07:28  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/proizvod/1g/frmg_rn.prg
 *  \brief Ispravka broja veze - radni nalozi
 */


/*! \fn BrowseRn()
 *  \brief Ispravka broja veze - radni nalozi
 */

function BrowseRn()
*{
O_KALK
O_KONTO
cmkonto:=space(7)
cIdFirma:=gFirma
Box(,7,66,)
set cursor on

 @ m_x+1,m_y+2 SAY "ISPRAVKA BROJA VEZE - RADNI NALOZI"
 if gNW $ "DX"
  @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+4,m_y+2 SAY "Magacin Konto: " GET cMKonto   valid  P_Konto(@cMKonto)
 read; ESC_BCR

BoxC()

cIdFirma:=left(cIdFirma,2)

O_DOKS

select doks; set order to 2
//CREATE_INDEX("DOKSi2","IdFirma+MKONTO+idzaduz2+idvd+brdok","DOKS")

Box(,19,77)

ImeKol:={}
AADD(ImeKol,{ "F",          {|| IdFirma}                          })
AADD(ImeKol,{ "VD  ",       {|| IdVD}                           })
AADD(ImeKol,{ "Broj  ",     {|| BrDok}                           })
AADD(ImeKol,{ "M.Konto",    {|| mkonto}                    })
AADD(ImeKol,{ "RN     ",    {|| IdZaduz2 }                    })
AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}                          })
AADD(ImeKol,{ "Nab.Vr",     {|| nv}                          })
Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on
@ m_x+1,m_y+1 SAY "<F2> Ispravka dokumenta, <c-P> Print, <a-P> Print Br.Dok"
@ m_x+2,m_y+1 SAY "<ENTER> Postavi/Ukini zatvaranje"
@ m_x+3,m_y+1 SAY ""; ?? "Konto:",cMKonto
BrowseKey(m_x+4,m_y+1,m_x+19,m_y+77,ImeKol,{|Ch| EdBRN(Ch)},"idFirma+mkonto=cidFirma+cmkonto",cidFirma+cmkonto,2,,,{|| .f.})

BoxC()

closeret
return
*}





/*! \fn EdBrn(Ch)
 *  \brief Obrada opcija u browse-u radnih naloga
 */

function EdBrn(Ch)
*{
local cDn:="N",nRet:=DE_CONT
do case
  case Ch==K_F2
     cIdzaduz2:=Idzaduz2
     dDatDok:=datdok
     Box(,5,60,.f.)
       @ m_x+1,m_y+2 SAY "Broj RN:" GET cIdzaduz2 pict "@!"
       read
     BoxC()
     if lastkey()<>K_ESC
       replace idzaduz2 with cidzaduz2
     endif
     select kalk
     seek doks->(idfirma+idvD+brdok)
     do while  !eof() .and. idfirma+idvD+brdok==doks->(idfirma+idvD+brdok)
        skip; nTrec:=recno() ; skip -1
        replace idzaduz2  with cidzaduz2
        go nTrec
     enddo
     select doks

     nRet:=DE_REFRESH
 case Ch==K_CTRL_P
     PushWa()
     cSeek:=idfirma+idvd+brdok
     close all
     Stkalk(.t.,cSeek)
     O_KALK
     O_DOKS
     PopWA()
     nRet:=DE_REFRESH
endcase
return nRet
*}




