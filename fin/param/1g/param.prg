#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/param/1g/param.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.3 $
 * $Log: param.prg,v $
 * Revision 1.3  2003/04/12 06:46:43  mirsad
 * ispravka: gBrojac sada je PUBLIC varijabla
 *
 * Revision 1.2  2002/06/20 09:34:50  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/param/1g/param.prg
 *  \brief Parametri
 */


/*! \fn Pars()
 *  \brief Menij za podesavanje parametara
 */

function Pars()
*{
local cK1:=cK2:=cK3:=cK4:="N",cDatVal:="N",gnLOSt:=0,gPotpis:="N"
cSecur:=SecurR(KLevel,"Parametri")
if ImaSlovo("X",cSecur)
    MsgBeep("Opcija nedostupna !")
    return
endif
cSecur:=SecurR(KLevel,"SGLEDAJ")
if ImaSlovo("D",cSecur)
   MsgBeep("Opcija nedostupna !")
   return
endif


O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("k1",@cK1)
RPar("k2",@cK2)
RPar("k3",@cK3)
RPar("k4",@cK4)
RPar("dv",@cDatVal)
RPar("br",@gBrojac)
RPar("li",@gnLOst)
RPar("po",@gPotpis)
RPar("ff",@gFirma)
RPar("ts",@gTS)
RPar("du",@gDUFRJ)
Rpar("fk",@gFKomp)
Rpar("fn",@gNFirma)
Rpar("lm",@gnLMONI)
Rpar("nw",@gNW)
Rpar("bv",@gBezVracanja)
Rpar("bi",@gBuIz)
Rpar("p1",@gPicDEM)
Rpar("p2",@gPicBHD)
Rpar("v1",@gVar1)
Rpar("rr",@gnRazRed)
Rpar("so",@gVSubOp)

gNFirma:=padr(gNFirma,20)
cK1:=padr(cK1,1)
cK2:=padr(cK2,1)
cK3:=padr(cK3,1)
cK4:=padr(cK4,1)
gVar1:=padr(gVar1,1)


Box(,22,70)
 set cursor on
 @ m_x+1,m_y+2 SAY "Firma" GET gFirma
 @ m_x+1,col()+2 SAY "Naziv:" get gNFirma
 @ m_x+1,col()+2 SAY "TIP SUBJ.:" get gTS

 @ m_x+2,m_y+ 2 SAY "Polje K1 D/N" GET cK1 valid cK1 $ "DN" pict "@!"
 @ m_x+2,m_y+18 SAY "Polje K2 D/N" GET cK2 valid cK2 $ "DN" pict "@!"
 @ m_x+2,m_y+34 SAY "Polje K3 D/N" GET cK3 valid cK3 $ "DN" pict "@!"
 @ m_x+2,m_y+50 SAY "Polje K4 D/N" GET cK4 valid cK4 $ "DN" pict "@!"
 @ m_x+3,m_y+ 2 SAY "Dugi uslov za firmu i RJ u suban.specif.? (D/N)" GET gDUFRJ valid gDUFRJ $ "DN" pict "@!"
 @ m_x+4,m_y+ 2 SAY "Onemoguciti povrat azuriranog naloga u pripremu? (D/N)" GET gBezVracanja VALID gBezVracanja $ "DN" pict "@!"

 @ m_x+5,m_y+ 2 SAY "Fajl obrasca kompenzacije" GET gFKomp valid V_FKomp()
 @ m_x+6,m_y+ 2 SAY "Sintetika i analitika se kreiraju u izvjestajima (D/N)?" GET gSAKrIz valid gSAKrIz $ "DN" PICT "@!"
 @ m_x+7,m_y+2  SAY "Datum valutiranja" GET cDatVal valid cDatVal $ "DN" pict "@!"
 @ m_x+8,m_y+2  SAY "Brojac 1-firma,vn,brnal; 2-firma,brnal" GET gBrojac valid gbrojac $ "12"
 @ m_x+9,m_y+2  SAY "Limit za otvorene stavke ("+ValDomaca()+")" GET gnLOst pict "99999.99"
 @ m_x+10,m_y+2 SAY "Koristiti konta-izuzetke u FIN-BUDZET-u (D/N)" GET gBuIz VALID gBuIz$"DN" PICT "@!"
 @ m_x+11,m_y+2 SAY "Potpis na kraju naloga D/N:" GET gPotpis valid gPotpis $ "DN"  pict "@!"
 @ m_x+12,m_y+2 SAY "Neophodna ravoteza naloga D/N:" GET gRavnot valid gRavnot $ "DN" pict "@!"
 @ m_x+13,m_y+2 SAY "Zadati datum naloga D/N:" GET gDatNal valid gDatNal $ "DN" pict "@!"
 @ m_x+14,m_y+2 SAY "Novi korisnicki interfejs D/N" GET gNW valid gNW $ "DN" pict "@!"
 @ m_x+15,m_y+2 SAY "Prikaz iznosa u "+ValPomocna() GET gPicDEM
 @ m_x+16,m_y+2 SAY "Prikaz iznosa u "+ValDomaca() GET gPicBHD
 @ m_x+17,m_y+2 SAY "Varijanta izvjestaja 0-dvovalutno 1-jednovalutno " GET gVar1 VALID gVar1$"01"
 @ m_x+18,m_y+2 SAY "Razmak izmedju kartica - br.redova (99-uvijek nova stranica): " GET gnRazRed PICTURE "99"
 @ m_x+19,m_y+2 SAY "U subanalitici prikazati nazive i konta i partnera D/N" GET gVSubOp valid gVSubOp$"DN" PICTURE "@!"
 @ m_x+20,m_y+2 SAY "Unos radnih jedinica D/N" GET gRJ valid gRj $ "DN" pict "@!"
 @ m_x+21,m_y+2 SAY "Unos ekonom.kategor. D/N" GET gTroskovi valid gTroskovi $ "DN" pict "@!"
 @ m_x+22,m_y+2 SAY "Lijeva marg.za obrazac 'Odobrenje i nalog za isplatu' (br.znakova)" GET gnLMONI PICTURE "999"
 read
BoxC()

if lastkey()<>K_ESC
 WPar("k1",cK1)
 WPar("k2",cK2)
 WPar("k3",cK3)
 WPar("k4",cK4)
 WPar("dv",cDatVal)
 WPar("br",gBrojac)
 WPar("li",gnLOst)
 WPar("po",gPotpis)
 WPar("ff",gFirma)
 WPar("ts",gTS)
 WPar("du",gDUFRJ)
 Wpar("fk",gFKomp)
 Wpar("fn",gNFirma)
 Wpar("lm",gnLMONI)
 Wpar("Ra",gRavnot)
 Wpar("dn",gDatNal)
 Wpar("nw",gNW)
 Wpar("bv",gBezVracanja)
 Wpar("bi",gBuIz)
 Wpar("p1",gPicDEM)
 Wpar("p2",gPicBHD)
 Wpar("v1",gVar1)
 Wpar("tr",gTroskovi)
 Wpar("rj",gRj)
 Wpar("rr",gnRazRed)
 Wpar("so",gVSubOp)
 Wpar("si",gSAKrIz)
endif

closeret

return
*}


/*! \fn V_FKomp()
 *  \brief Ispravka fajla kompenzacije
 */
 
function V_FKomp()
*{
private cKom:="q "+PRIVPATH+gFKomp
if Pitanje(,"Zelite li izvrsiti ispravku obrasca kompenzacije ?","N")=="D"
 if !empty(gFKomp)
   Box(,25,80)
   run &ckom
   BoxC()
 endif
endif
return .t.
*}

