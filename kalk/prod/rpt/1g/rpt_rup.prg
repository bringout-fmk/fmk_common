#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_rup.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.10 $
 * $Log: rpt_rup.prg,v $
 * Revision 1.10  2004/01/07 13:43:27  sasavranic
 * Korekcija algoritama za tarife, ako je bilo promjene tarifa
 *
 * Revision 1.9  2004/01/06 18:06:12  sasavranic
 * no message
 *
 * Revision 1.8  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.7  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.6  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.5  2003/02/10 02:19:34  mirsad
 * no message
 *
 * Revision 1.4  2002/12/30 01:30:13  mirsad
 * ispravke bugova-Planika
 *
 * Revision 1.3  2002/07/22 14:16:12  mirsad
 * dodao proracun poreza u ugostiteljstvu (varijante "M" i "J")
 *
 * Revision 1.2  2002/06/21 12:12:12  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_rup.prg
 *  \brief Izvjestaj "ukalkulisani porez prodavnice"
 */


/*! \fn RekKPor()
 *  \brief Izvjestaj "ukalkulisani porez prodavnice"
 */

function RekKPor()
*{
local  i:=0
local nT1:=0
local nT4:=0
local nT5:=0
local nT5a:=0
local nT6:=0
local nT7:=0
local nTT1:=0
local nTT4:=0
local nTT5:=0
local nTT5a:=0
local nTT6:=0
local nTT7:=0
local n1:=0
local n4:=0
local n5:=0
local n5a:=0
local n6:=0
local n7:=0
local nCol1:=0
// "999999.999"
local PicCDEM:=gPicCDEM   
// "999999.99%"
local PicProc:=gPicProc      
// "9999999.99"
local PicDEM:=gPicDEM         
// "999999.999"
local Pickol:=gPicKol         
local aPorezi

/*
if glPoreziLegacy
	RekKPorLegacy()
endif
*/

dDat1:=dDat2:=ctod("")
cVDok:="99"
cStope:="N"
qqKonto:=padr("1320;",60)
Box(,5,75)
	set cursor on
 	do while .t.
  		@ m_x+1,m_y+2 SAY "Konto prodavnice:" GET qqKonto pict "@!S50"
  		@ m_x+2,m_y+2 SAY "Tip dokumenta (11/12/13/15/19/80/81/99):" GET cVDok  valid cVDOK $ "11/12/13/15/19/16/22/80/81/99"
  		@ m_x+3,m_y+2 SAY "Kalkulacije od datuma:" GET dDat1
  		@ m_x+3,col()+1 SAY "do" GET dDat2
  		@ m_x+4,m_y+2 SAY "Prikaz stopa ucesca pojedinih tarifa:" GET cStope valid cstope$"DN" pict "@!"
  		read
		ESC_BCR
  	
	aUsl1:=Parsiraj(qqKonto,"Pkonto")
  	if aUsl1<>NIL
		exit
	endif
 enddo
BoxC()

set softseek off
O_KONTO
O_TARIFA
O_KALKREP
set order to 6

if cVDOK=="99"
  cVDOK:="11#80#81#12#13#15#19"
  if cStope=="D"
    cVDOK+="#42#43"
  endif
endif

private cFilt1:=""

if !empty(dDat1) .or. !empty(dDat2)
 cFilt1:=aUsl1 +".and.(IDVD$"+cm2str(cVDOK)+").and.DATDOK>="+cm2str(dDat1)+;
         ".and. DATDOK<="+cm2str(dDat2)
else
 cFilt1:=aUsl1+".and.(IDVD$"+cm2str(cVDOK)+")"
endif

SET FILTER TO &cFilt1

go top   // samo  zaduz prod. i povrat iz prod.
EOF CRET

M:="------------ ------------- ---------- ----------- ----------- --------- --------- ---------- ---------- ----------"

START PRINT CRET


n1:=0
n4:=0
n5:=0
n5a:=0
n6:=0
n7:=0
altd()
aPorezi:={}
DO WHILE !EOF() .and. IspitajPrekid()
  B:=0
  cIdFirma:=KALK->IdFirma
  Preduzece()
  P_COND
  ? "KALK: PREGLED UKALKULISANIH POREZA (PRODAVNICE) ZA PERIOD OD",dDat1,"DO",dDAt2,"      NA DAN:",DATE()
  ?
  ? "Prodavnica: "
  aUsl2:=Parsiraj(qqKonto,"id")
  SELECT KONTO
  GO TOP
  SEEK "132"
  DO WHILE id="132"
    IF Tacno(aUsl2)
      ?? id+" - "+naz
      ? SPACE(12)
    ENDIF
    SKIP
  ENDDO
  ?
  ? m
  ? "*     TARIF *      MPV    *    PPP   *    PPU   *    PP    *   PPP    *   PPU    *   PP     * UKUPNO   * MPV     *"
  ? "*     BROJ  *             *     %    *     %    *     %    *          *          *          * POREZ    * SA Por  *"
  ? m
  nT1:=0
  nT4:=0
  nT5:=0
  nT5a:=0
  nT6:=0
  nT7:=0
  private aTarife:={}, nReal:=0
  SELECT KALK
  DO WHILE !EOF() .AND. cIdFirma==KALK->IdFirma .and. IspitajPrekid()
     cIdKonto:=PKonto
     cIdTarifa:=IdTarifa
     select tarifa
     hseek cIdtarifa
     select kalk
     
     cIdTarifa:=Tarifa(pkonto, idRoba, @aPorezi, cIdTarifa)
     
     
     nMPV:=0
     nMPVSaPP:=0
     nNV:=0
     DO WHILE !EOF() .AND. cIdFirma==IdFirma .and. cIdtarifa==IdTarifa .and. IspitajPrekid()

        select KALK
        if  idvd == "42" .or. idvd == "43"
           	nReal+=mpcsapp*kolicina
        elseif IdVD $ "12#13"   
		// povrat robe se uzima negativno
           	nMPV-=MPC*(Kolicina)
           	nMPVSaPP-=MPCSaPP*(Kolicina)
	   	nNV-=nc*kolicina
        else
           	nMPV+=MPC*(Kolicina)
           	nMPVSaPP+=MPCSaPP*(Kolicina)
	   	nNV+=nc*kolicina
        endif

        skip
     ENDDO

     if cStope=="D"
      AADD(aTarife,{cIdTarifa,nMPVSAPP})
     endif
     if prow()>62+gPStranica
     	ff
     endif
     
 	// porez na promet
	nPorez:=Izn_P_PPP(nMpv, aPorezi, , nMpvSaPP)
	
	if glUgost
		// porez na ruc
		nPorez2:=Izn_P_PRugost( nMpvSaPP, nMpV, nNV, aPorezi)
		// posebni porez
		nPorez3:=Izn_P_PPUgost(nMpvSaPP, nPorez2, aPorezi)
	else
		// porez na usluge
		nPorez2:=Izn_P_PPU(nMpv, aPorezi )
		// posebni porez
		nPorez3:=Izn_P_PP( nMpv, aPorezi )
	endif
    
     

     @ prow()+1,0        SAY space(6)+cIdTarifa
     nCol1:=pcol()+4
     @ prow(),pcol()+4   SAY n1:=nMPV     PICT   PicDEM
     
     @ prow(),pcol()+1   SAY aPorezi[POR_PPP] PICT   PicProc
	
     if glUgost
  		@ prow(),pcol()+1   SAY aPorezi[POR_PRUCMP] pict picproc
     else	
		@ prow(),pcol()+1   SAY aPorezi[POR_PPU] pict picproc
     endif
     @ prow(),pcol()+1   SAY aPorezi[POR_PP] pict picproc
       
     
     @ prow(),pcol()+1   SAY n4:=nPorez   PICT   PicDEM
     @ prow(),pcol()+1   SAY n5:=nPorez2  PICT   PicDEM
     @ prow(),pcol()+1   SAY n5a:=nPorez3 PICT   PicDEM
     @ prow(),pcol()+1   SAY n6:=nPorez+nPorez2+nPorez3  PICTURE   PicDEM
     @ prow(),pcol()+1   SAY n7:=nMPVSAPP PICTURE   PicDEM
     nT1+=n1
     nT4+=n4
     nT5+=n5
     nT5a+=n5a
     nT6+=n6
     nT7+=n7
  ENDDO // konto

  if prow()>60+gPStranica
  	FF
  endif
  ? m
  ? "UKUPNO:"
  @ prow(),nCol1     SAY  nT1     pict picdem
  @ prow(),pcol()+1  SAY  0        pict "@Z "+picdem
  @ prow(),pcol()+1  SAY  0        pict "@Z "+picdem
  @ prow(),pcol()+1  SAY  0        pict "@Z "+picdem
  @ prow(),pcol()+1  SAY  nT4     pict picdem
  @ prow(),pcol()+1  SAY  nT5     pict picdem
  @ prow(),pcol()+1  SAY  nT5a    pict picdem
  @ prow(),pcol()+1  SAY  nT6     pict picdem
  @ prow(),pcol()+1  SAY  nT7     pict picdem
  ? m

  if cStope=="D"
    ?
    ? "Prikaz ucesca pojedinih tarifa:"
    ? m
    for ii:=1 to len(aTarife)
       ? aTarife[ii,1]
       @ prow(),pcol()+1 SAY aTarife[ii,2]/nT7*100 pict "99.999%"
       ?? " * "
       @ prow(),pcol()+1 SAY nReal pict  picdem
       ?? " = "
       @ prow(),pcol()+1 SAY nReal*aTarife[ii,2]/nT7 pict picdem
    next
    ? m
  endif

ENDDO // eof

?
FF

END PRINT

set softseek on

#ifdef CAX
 if gKalks
 	select kalk
	use
 endif
#endif
closeret
return
*}



/*
function RekKPorLegacy()
local  i:=nT1:=nT4:=nT5:=nT5a:=nT6:=nT7:=0
local  nTT1:=nTT4:=nTT5:=nTT5a:=nTT6:=nTT7:=0
local  n1:=n4:=n5:=n5a:=n6:=n7:=0
local  nCol1:=0
local   PicCDEM:=gPicCDEM       // "999999.999"
local   PicProc:=gPicProc       // "999999.99%"
local   PicDEM:=gPicDEM         // "9999999.99"
local   Pickol:=gPicKol         // "999999.999"

private aPorezi
aPorezi:={}

dDat1:=dDat2:=ctod("")
cVDok:="99"
cStope:="N"
qqKonto:=padr("1320;",60)
Box(,5,75)
 set cursor on
 do while .t.
  @ m_x+1,m_y+2 SAY "Konto prodavnice:" GET qqKonto pict "@!S50"
  @ m_x+2,m_y+2 SAY "Tip dokumenta (11/12/13/15/19/80/81/99):" GET cVDok  valid cVDOK $ "11/12/13/15/19/16/22/80/81/99"
  @ m_x+3,m_y+2 SAY "Kalkulacije od datuma:" GET dDat1
  @ m_x+3,col()+1 SAY "do" GET dDat2
  @ m_x+4,m_y+2 SAY "Prikaz stopa ucesca pojedinih tarifa:" GET cStope valid cstope$"DN" pict "@!"
  read;ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"Pkonto")
  if aUsl1<>NIL; exit; endif
 enddo
BoxC()

set softseek off
O_KONTO
O_TARIFA
O_KALKREP;  set order to 6

if cVDOK=="99"
  cVDOK:="11#80#81#12#13#15#19"
  if cStope=="D"
    cVDOK+="#42#43"
  endif
endif

private cFilt1:=""

if !empty(dDat1) .or. !empty(dDat2)
 cFilt1:=aUsl1 +".and.(IDVD$"+cm2str(cVDOK)+").and.DATDOK>="+cm2str(dDat1)+;
         ".and. DATDOK<="+cm2str(dDat2)
else
 cFilt1:=aUsl1+".and.(IDVD$"+cm2str(cVDOK)+")"
endif

SET FILTER TO &cFilt1

go top   // samo  zaduz prod. i povrat iz prod.
EOF CRET

M:="------------ ------------- ---------- ----------- ----------- --------- --------- ---------- ---------- ----------"

START PRINT CRET


n1:=n4:=n5:=n5a:=n6:=n7:=0

DO WHILE !EOF() .and. IspitajPrekid()
  B:=0
  cIdFirma:=KALK->IdFirma
  Preduzece()
  P_COND
  ? "KALK: PREGLED UKALKULISANIH POREZA (PRODAVNICE) ZA PERIOD OD",dDat1,"DO",dDAt2,"      NA DAN:",DATE()
  ?
  ? "Prodavnica: "
  aUsl2:=Parsiraj(qqKonto,"id")
  SELECT KONTO
  GO TOP
  SEEK "132"
  DO WHILE id="132"
    IF Tacno(aUsl2)
      ?? id+" - "+naz
      ? SPACE(12)
    ENDIF
    SKIP
  ENDDO
  ?
  ? m
  ? "*     TARIF *      MPV    *    PPP   *    PPU   *    PP    *   PPP    *   PPU    *   PP     * UKUPNO   * MPV     *"
  ? "*     BROJ  *             *     %    *     %    *     %    *          *          *          * POREZ    * SA Por  *"
  ? m
  nT1:=nT4:=nT5:=nT5a:=nT6:=nT7:=0
  private aTarife:={}, nReal:=0
  SELECT KALK
  DO WHILE !EOF() .AND. cIdFirma==KALK->IdFirma .and. IspitajPrekid()
     cIdKonto:=PKonto
     cIdTarifa:=IdTarifa
     select tarifa; hseek cidtarifa; select kalk
     nOPP:=TARIFA->OPP
     nPPP:=TARIFA->PPP
     nPP :=TARIFA->ZPP

     IF TARIFA->(FIELDPOS("MPP")<>0)
       public _MPP   := TARIFA->MPP/100
       public _DLRUC := TARIFA->DLRUC/100
     ELSE
       public _MPP   := 0
       public _DLRUC := 0
     ENDIF
     _PPP:=nPPP/100
     
     nMPV:=nMPVSaPP:=nNV:=0

     if !glPoreziLegacy
	     Tarifa(pkonto,idroba,@aPorezi)
     endif

     DO WHILE !EOF() .AND. cIdFirma==IdFirma .and. cIdtarifa==IdTarifa .and. IspitajPrekid()

        select KALK
        if  idvd == "42" .or. idvd == "43"
           nReal+=mpcsapp*kolicina
        elseif IdVD $ "12#13"   // povrat robe se uzima negativno
           nMPV-=MPC*(Kolicina)
           nMPVSaPP-=MPCSaPP*(Kolicina)
	   nNV-=nc*kolicina
        else
           nMPV+=MPC*(Kolicina)
           nMPVSaPP+=MPCSaPP*(Kolicina)
	   nNV+=nc*kolicina
        endif

        skip
     ENDDO // tarifa

     if cStope=="D"
      AADD(aTarife,{cIdTarifa,nMPVSAPP})
     endif
     if prow()>62+gPStranica
     	FF
     endif
     
     if glPoreziLegacy

	     IF gUVarPP$"MT"
	       nPorez := nMPVSaPP*nOPP/(100+nOPP)
	     ELSE
	       nPorez := nMPV*nOPP/100
	     ENDIF

	     IF gUVarPP=="T"
	       nPorez2:=(nMPVSaPP-nPorez-nNV)*_mpp/(1+_mpp)
	     ELSEIF gUVarPP$"JM" .and. _mpp>0
	       nPorez2:=nMPVSaPP*_DLRUC*_MPP/(1+_MPP)
	     ELSE
	       nPorez2:=nPPP/100*(nMPV+nPorez)
	     ENDIF

	     IF gUVarPP$"N"
	     	nPorez3:=nMPV*nPP/100
	     ELSE
	     	nPorez3:=nPP/100*(nMPVSaPP-nPorez2)
	     ENDIF

     else

	     if glUgost
		     nPorez:=Izn_P_PPP(nMpv,aPorezi,,nMPVSaPP)
		     nPorez2:=Izn_P_PRugost(nMPVSaPP,nMpv,nNV,aPorezi)
		     nPorez3:=Izn_P_PPUgost(nMPVSaPP,nPorez2,aPorezi)
	     else
		     nPorez:=Izn_P_PPP(nMpv,aPorezi,,nMPVSaPP)
		     nPorez2:=Izn_P_PPU(nMpv,aPorezi)
		     nPorez3:=Izn_P_PP(nMpv,aPorezi)
	     endif

     endif

     @ prow()+1,0        SAY space(6)+cIdTarifa
     nCol1:=pcol()+4
     @ prow(),pcol()+4   SAY n1:=nMPV     PICT   PicDEM
     @ prow(),pcol()+1   SAY nOPP         PICT   PicProc
     @ prow(),pcol()+1   SAY PrPPUMP()    PICT   PicProc
     @ prow(),pcol()+1   SAY nPP          PICT   PicProc
     @ prow(),pcol()+1   SAY n4:=nPorez   PICT   PicDEM
     @ prow(),pcol()+1   SAY n5:=nPorez2  PICT   PicDEM
     @ prow(),pcol()+1   SAY n5a:=nPorez3 PICT   PicDEM
     @ prow(),pcol()+1   SAY n6:=nPorez+nPorez2+nPorez3  PICTURE   PicDEM
     @ prow(),pcol()+1   SAY n7:=nMPVSAPP PICTURE   PicDEM
     nT1+=n1;  nT4+=n4;  nT5+=n5;  nT5a+=n5a;  nT6+=n6
     nT7+=n7
  ENDDO // konto

  if prow()>60+gPStranica
	  FF
  endif
  ? m
  ? "UKUPNO:"
  @ prow(),nCol1     SAY  nT1     pict picdem
  @ prow(),pcol()+1  SAY  0        pict "@Z "+picdem
  @ prow(),pcol()+1  SAY  0        pict "@Z "+picdem
  @ prow(),pcol()+1  SAY  0        pict "@Z "+picdem
  @ prow(),pcol()+1  SAY  nT4     pict picdem
  @ prow(),pcol()+1  SAY  nT5     pict picdem
  @ prow(),pcol()+1  SAY  nT5a    pict picdem
  @ prow(),pcol()+1  SAY  nT6     pict picdem
  @ prow(),pcol()+1  SAY  nT7     pict picdem
  ? m

  if cStope=="D"
    ?
    ? "Prikaz ucesca pojedinih tarifa:"
    ? m
    for ii:=1 to len(aTarife)
       ? aTarife[ii,1]
       @ prow(),pcol()+1 SAY aTarife[ii,2]/nT7*100 pict "99.999%"
       ?? " * "
       @ prow(),pcol()+1 SAY nReal pict  picdem
       ?? " = "
       @ prow(),pcol()+1 SAY nReal*aTarife[ii,2]/nT7 pict picdem
    next
    ? m
  endif

ENDDO // eof

?
FF

END PRINT

set softseek on

#ifdef CAX
	if gKalks
		select kalk
		use
	endif
#endif
closeret
return
*}
*/


