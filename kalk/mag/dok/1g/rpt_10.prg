#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_10.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.6 $
 * $Log: rpt_10.prg,v $
 * Revision 1.6  2003/08/01 16:18:12  mirsad
 * no message
 *
 * Revision 1.5  2003/04/12 06:57:08  mirsad
 * omogucen prenos KALK10,11,81->FAKT poput KALK->TOPS za udaljene lokacije
 *
 * Revision 1.4  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.3  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 * Revision 1.2  2002/06/17 14:48:21  ernad
 *
 *
 * ciscenje
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/rpt_10.prg
 *  \brief Stampa dokumenta tipa 10
 */


/*! \fn StKalk10_2()
 *  \brief Stampa dokumenta tipa 10, varijanta sa troskovima u kolonama
 */

function StKalk10_2()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_COND2
?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

?  "DOBAVLJAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO; HSEEK cIdKonto
?  "MAGACINSKI KONTO zaduzuje :",cIdKonto,"-",naz


 m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

 ? m
 ? "*R * ROBA     *  FCJ     * NOR.KALO * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     *"+iif(gVarVP=="1"," MARZA.   "," RUC+PRUC ")+"*  VPC    *"
 ? "*BR* TARIFA   *  KOLICINA* PRE.KALO * SKONTO   *          *          *          *          *          *          *          *         *"
 ? "*  *          *    ä     *    ä     *   ä      *    ä     *    ä     *     ä    *    ä     *    ä     *    ä     *    ä     *   ä     *"
 ? m
 nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=0
 nTotB:=0

select pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2



do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    ViseDokUPripremi(cIdd)
    RptSeekRT()
    KTroskovi()



    DokNovaStrana(125, @nStr, 2)

    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nTot+=  (nU:=round(FCj*Kolicina,gZaokr))
    if gKalo=="1"
        nTot1+= (nU1:=round(FCj2*(GKolicina+GKolicin2),gZaokr))
    else
        // stanex
        nTot1+= (nU1:=round(NC*(GKolicina+GKolicin2),gZaokr))
    endif
    nTot2+= (nU2:=round(-Rabat/100*FCJ*Kolicina,gZaokr))
    nTot3+= (nU3:=round(nPrevoz*SKol,gZaokr))
    nTot4+= (nU4:=round(nBankTr*SKol,gZaokr))
    nTot5+= (nU5:=round(nSpedTr*SKol,gZaokr))
    nTot6+= (nU6:=round(nCarDaz*SKol,gZaokr))
    nTot7+= (nU7:=round(nZavTr* SKol,gZaokr))
    nTot8+= (nU8:=round(NC *    (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    nTot9+= (nU9:=round(nMarza* (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    nTotA+= (nUA:=round(VPC   * (Kolicina-Gkolicina-GKolicin2),gZaokr) )

    if gVarVP=="1"
      nTotB+= round(nU9*tarifa->vpp/100 ,gZaokr) // porez na razliku u cijeni
    else
      private cistaMar:=round(nU9/(1+tarifa->vpp/100) ,gZaokr)
      nTotB+=round( cistaMar*tarifa->vpp/100,gZaokr)  // porez na razliku u cijeni
    endif

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(ROBA->naz),"(",ROBA->jmj,")"
    if roba->(fieldpos("KATBR"))<>0
       ?? " KATBR:", roba->katbr
    endif
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    @ prow()+1,4 SAY IdRoba
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY FCJ                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY GKolicina             PICTURE PicKol
    @ prow(),pcol()+1 SAY -Rabat                PICTURE PicProc
    @ prow(),pcol()+1 SAY nPrevoz/FCJ2*100      PICTURE PicProc
    @ prow(),pcol()+1 SAY nBankTr/FCJ2*100      PICTURE PicProc
    @ prow(),pcol()+1 SAY nSpedTr/FCJ2*100      PICTURE PicProc
    @ prow(),pcol()+1 SAY nCarDaz/FCJ2*100      PICTURE PicProc
    @ prow(),pcol()+1 SAY nZavTr/FCJ2*100       PICTURE PicProc
    @ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nMarza/NC*100         PICTURE PicProc
    @ prow(),pcol()+1 SAY VPC                   PICTURE PicCDEM

    @ prow()+1,4 SAY IdTarifa
    @ prow(),nCol1    SAY Kolicina             PICTURE PicCDEM
    @ prow(),pcol()+1 SAY GKolicin2            PICTURE PicKol
    @ prow(),pcol()+1 SAY -Rabat/100*FCJ       PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nPrevoz              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nBankTr              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nSpedTr              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nCarDaz              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nZavTr               PICTURE PicCDEM
    @ prow(),pcol()+1 SAY 0                    PICTURE PicDEM
    @ prow(),pcol()+1 SAY nMarza               PICTURE PicCDEM

    @ prow()+1,nCol1   SAY nU          picture         PICDEM
    @ prow(),pcol()+1  SAY nU1         picture         PICDEM
    @ prow(),pcol()+1  SAY nU2         picture         PICDEM
    @ prow(),pcol()+1  SAY nU3         picture         PICDEM
    @ prow(),pcol()+1  SAY nU4         picture         PICDEM
    @ prow(),pcol()+1  SAY nU5         picture         PICDEM
    @ prow(),pcol()+1  SAY nU6         picture         PICDEM
    @ prow(),pcol()+1  SAY nU7         picture         PICDEM
    @ prow(),pcol()+1  SAY nU8         picture         PICDEM
    @ prow(),pcol()+1  SAY nU9         picture         PICDEM
    @ prow(),pcol()+1  SAY nUA         picture         PICDEM


  skip
enddo


DokNovaStrana(125, @nStr, 5)
? m


@ prow()+1,0        SAY "Ukupno:"
  @ prow(),nCol1     SAY nTot          picture         PICDEM
  @ prow(),pcol()+1  SAY nTot1         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot2         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot3         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot4         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot5         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot6         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot7         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot8         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot9         picture         PICDEM
  @ prow(),pcol()+1  SAY nTotA         picture         PICDEM

if g10Porez=="D" .or. gVarVP=="2"
 ? m
 if gVarVP=="1"
  ? "Ukalkulisani porez na ruc (PRUC):"
  @ prow(),pcol()+1 SAY nTotB pict picdem
  @ prow(),pcol()+15 SAY "RUC - PRUC ="
  @ prow(),pcol()+1 SAY alltrim(transform(nTot9,picdem))
  @ prow(),pcol()+1 SAY "-"
  @ prow(),pcol()+1 SAY alltrim(transform(nTotB,picdem))
  @ prow(),pcol()+1 SAY "="
  @ prow(),pcol()+1 SAY nTot9-nTotB pict picdem
 else
  ? "RUC ="
  @ prow(),pcol()+1 SAY alltrim(transform(nTot9-nTotB,picdem)); ?? ","
  @ prow(),pcol()+15 SAY "PRUC ="
  @ prow(),pcol()+1 SAY alltrim(transform(nTotB,picdem)); ?? ","
  @ prow(),pcol()+15 SAY "RUC + PRUC ="
  @ prow(),pcol()+1 SAY alltrim(transform(nTot9,picdem))
 endif
endif
? m
return
*}



/*! \fn StKalk10_3()
 *  \brief Stampa kalkulacije 10 - magacin po vp, DEFAULT VARIJANTA
 */

function StKalk10_3(lBezNC)
*{
local nCol1:=nCol2:=0,npom:=0

if lBezNC==NIL
	lBezNC:=.f.
endif

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()


nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
if cidvd=="10".or.cidvd=="70"
  ?? "ULAZ U MAGACIN - OD DOBAVLJACA"
endif
P_COND
? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok," ,Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner
?
?  "DOBAVLJAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP
?
select KONCIJ; seek trim(cIdKonto); lNC:=.t.
IF naz<>"N1"; lNc:=.f.; ENDIF
select KONTO; HSEEK cIdKonto
?  "MAGACINSKI KONTO zaduzuje :",cIdKonto,"-",naz
if !empty(pripr->Idzaduz2); ?? " Rad.nalog:",pripr->Idzaduz2; endif

if lBezNC

 m:="--- ---------- ----------"+IF(lNC,""," ---------- ----------")
 if gmpcpomoc=="D"
   m+= " ----------"
 endif
 ? m
 ? "*R * ROBA     * KOLICINA "+IF(lNC,"","*   PPP    *    VPC  *")
 if gmpcpomoc=="D"
   ?? "    MPC   *"
 endif
 ? "*BR* TARIFA   *          "+IF(lNC,"","*          *         *")
 if gmpcpomoc=="D"
   ?? "          *"
 endif

 ? "*  *          *          "+IF(lNC,"","*          *         *")
 if gmpcpomoc=="D"
   ?? "          *"
 endif

else

 m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"+IF(lNC,""," ---------- ---------- ----------")
 if gmpcpomoc=="D"
   m+= " ----------"
 endif
 ? m
 ? "*R * ROBA     *  FCJ     * KOLICINA * RABAT    * FCJ-RAB  * TROSKOVI *    NC    *"+IF(lNC,"",iif(gVarVP=="1"," MARZA.   "," RUC+PRUC ")+"*   PPP    *    VPC  *")
 if gmpcpomoc=="D"
   ?? "    MPC   *"
 endif
 ? "*BR* TARIFA   *          *          * DOBAVLJ. *          *          *          *"+IF(lNC,"","          *          *         *")
 if gmpcpomoc=="D"
   ?? "          *"
 endif

 ? "*  *          *  FV      *          *          * FV-RABAT *          *          *"+IF(lNC,"","          *          *         *")
 if gmpcpomoc=="D"
   ?? "          *"
 endif
 
endif

 ? m
 nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=0
 nTotB:=0
 nTotP:=nTotQ:=0
 nTotM:=0  // maloprodajna
select pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2


do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    ViseDokUPripremi(cIdd)
    RptSeekRT()
    KTroskovi()

    
    DokNovaStrana(125, @nStr, 2)

    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nTot+=  (nU:=round(FCj*Kolicina,gZaokr))
    if gKalo=="1"
        nTot1+= (nU1:=round(FCj2*(GKolicina+GKolicin2),gZaokr))
    else
        nTot1+= (nU1:=round(NC*(GKolicina+GKolicin2),gZaokr))
    endif
    nTot2+= (nU2:=round(-Rabat/100*FCJ*Kolicina,gZaokr))

    nTot3+= (nU3:=round(nPrevoz*SKol,gZaokr))
    nTot4+= (nU4:=round(nBankTr*SKol,gZaokr))
    nTot5+= (nU5:=round(nSpedTr*SKol,gZaokr))
    nTot6+= (nU6:=round(nCarDaz*SKol,gZaokr))
    nTot7+= (nU7:=round(nZavTr* SKol,gZaokr))

    // stanex
    nTot8+=(nU8:=nU+nU2+nU3+nU4+nU5+nU6+nU7)

    if !(roba->tip $ "VKX")
     nUP:=0
    else
     if roba->tip="X"
       nTotP+= (nUP:=round(mpcsapp/(1+tarifa->opp/100)*tarifa->opp/100*(Kolicina-Gkolicina-GKolicin2),gZaokr))
     else
       nTotP+= (nUP:=round(vpc/(1+tarifa->opp/100)*tarifa->opp/100*(Kolicina-Gkolicina-GKolicin2),gZaokr))
     endif
    endif


    nTotA+= (nUA:=round( VPC   * (Kolicina-Gkolicina-GKolicin2),gZaokr) )

    // stanex   marza
    nTot9+=(nU9:=round(nUA-nUp-nU8,gZaokr) )

    if gVarVP=="1"
      nTotB+= round(nU9*tarifa->vpp/100,gZaokr)  // porez na razliku u cijeni
    else
      private cistaMar:=round( nU9/(1+tarifa->vpp/100) ,gZaokr)
      nTotB+= round( cistaMar*tarifa->vpp/100 ,gZaokr) // porez na razliku u cijeni
    endif

    if gMpcPomoc=="D"
      nTotM+= (nUM:=round ( roba->mpc*kolicina, gZaokr))
    endif

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(ROBA->naz),"(",ROBA->jmj,")"
    if roba->(fieldpos("KATBR"))<>0
       ?? " KATBR:", roba->katbr
    endif
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    @ prow()+1,4 SAY IdRoba
    nCol1:=pcol()+1
    if !lBezNC
    	@ prow(),pcol()+1 SAY FCJ                   PICTURE PicCDEM
    endif
    @ prow(),pcol()+1 SAY Kolicina              picture pickol
    if !lBezNC
    	@ prow(),pcol()+1 SAY -Rabat                PICTURE PicProc
    	@ prow(),pcol()+1 SAY fcj*(1-Rabat/100)     pict piccdem
    	@ prow(),pcol()+1 SAY (nprevoz+nbanktr+nspedtr+ncardaz+nZavTr)/FCJ2*100       PICTURE PicProc

    	@ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
    endif

    IF !lNC
      if !lBezNC
      	@ prow(),pcol()+1 SAY nMarza/NC*100         PICTURE PicProc
      endif
      if roba->tip $ "VKX"
        @ prow(),pcol()+1 SAY tarifa->opp             PICTURE Picproc
      else
        @ prow(),pcol()+1 SAY 0                        PICTURE Picproc
      endif
      @ prow(),pcol()+1 SAY VPC                   PICTURE PicCDEM
    ENDIF

    if gMpcPomoc=="D"
      @ prow(),pcol()+1  SAY roba->mpc       picture         PICCDEM
    endif

    @ prow()+1,4 SAY IdTarifa
    @ prow(),nCol1    SAY  space(len(PicProc))
    if !lBezNC
    	@ prow(),pcol()+1 SAY  space(len(PicProc))
    	@ prow(),pcol()+1 SAY -Rabat/100*FCJ       PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY  space(len(PicProc))
    	@ prow(),pcol()+1 SAY (nprevoz+nbanktr+nspedtr+ncardaz+nZavTr)  PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY  space(len(PicProc))
    endif

    IF !lNC
      if !lBezNC
      	@ prow(),pcol()+1 SAY nMarza               PICTURE PicCDEM
      endif
      @ prow(),pcol()+1 SAY nUP/kolicina         PICTURE PicCDEM
    ENDIF

    if lBezNC
    	@ prow()+1,nCol1   SAY space(len(PicProc))
	IF !lNC
       		@ prow(),pcol()+1  SAY nUP         picture         PICDEM
	       	@ prow(),pcol()+1  SAY nUA         picture         PICDEM
	ENDIF
    else
    	@ prow()+1,nCol1   SAY nU          picture         PICDEM
    	@ prow(),pcol()+1 SAY space(len(PicProc))
    	@ prow(),pcol()+1  SAY nU2         picture         PICDEM
    	@ prow(),pcol()+1  SAY nU+nU2     picture         PICDEM
    	@ prow(),pcol()+1  SAY nu3+nu4+nu5+nu6+nu7    picture         PICDEM
    	@ prow(),pcol()+1  SAY nU8         picture         PICDEM

      	IF !lNC
        	@ prow(),pcol()+1  SAY nU9         picture         PICDEM
        	@ prow(),pcol()+1  SAY nUP         picture         PICDEM
        	@ prow(),pcol()+1  SAY nUA         picture         PICDEM
    	ENDIF
    endif

    if gMpcPomoc=="D"
      @ prow(),pcol()+1  SAY nUM         picture         PICDEM
    endif

  skip
enddo


DokNovaStrana(125, @nStr, 5)
? m
@ prow()+1,0        SAY "Ukupno:"

//stanex   nabavna cijena
nTot8:=nTot+nTot2+nTot3+nTot4+nTot5+nTot6+nTot7
nTot9:=nTotA-nTot8-nTotP   // utvrdi razliku izmedju nc i prodajne cijene

  if lBezNC
	  @ prow(),nCol1     SAY space(len(PicProc))
	  IF !lNC
	  	@ prow(),pcol()+1  SAY nTotP         picture         PICDEM
	  	@ prow(),pcol()+1  SAY nTotA         picture         PICDEM
	  ENDIF
  else
	  @ prow(),nCol1     SAY nTot          picture         PICDEM
	  @ prow(),pcol()+1  SAY space(len(PicProc))
	  @ prow(),pcol()+1  SAY nTot2         picture         PICDEM
	  @ prow(),pcol()+1  SAY ntot+nTot2         picture         PICDEM
	  @ prow(),pcol()+1  SAY ntot3+ntot4+ntot5+ntot6+ntot7  picture         PICDEM
	  @ prow(),pcol()+1  SAY nTot8         picture         PICDEM
	
	  IF !lNC
	    @ prow(),pcol()+1  SAY nTot9         picture         PICDEM
	    @ prow(),pcol()+1  SAY nTotP         picture         PICDEM
	    @ prow(),pcol()+1  SAY nTotA         picture         PICDEM
	  ENDIF
  endif

  if gMpcPomoc=="D"
     @ prow(),pcol()+1  SAY nTotM         picture         PICDEM
  endif

if !lBezNC .and. (g10Porez=="D" .or. gVarVP=="2")
 ? m
 if gVarVP=="1"
  ? "Ukalkulisani porez na ruc (PRUC):"
  @ prow(),pcol()+1 SAY nTotB pict picdem
  @ prow(),pcol()+8 SAY "RUC - PRUC ="
  @ prow(),pcol()+1 SAY alltrim(transform(nTot9,picdem))
  @ prow(),pcol()+1 SAY "-"
  @ prow(),pcol()+1 SAY alltrim(transform(nTotB,picdem))
  @ prow(),pcol()+1 SAY "="
  @ prow(),pcol()+1 SAY nTot9-nTotB pict picdem
 else
  ? "RUC ="
  @ prow(),pcol()+1 SAY alltrim(transform(nTot9-nTotB,picdem)); ?? ","
  @ prow(),pcol()+8 SAY "PRUC ="
  @ prow(),pcol()+1 SAY alltrim(transform(nTotB,picdem)); ?? ","
  @ prow(),pcol()+8 SAY "RUC + PRUC ="
  @ prow(),pcol()+1 SAY alltrim(transform(nTot9,picdem))
 endif
endif

if !lBezNC .and. round(ntot3+ntot4+ntot5+ntot6+ntot7,2) <>0
DokNovaStrana(125, @nStr, 10)
?
?  m
?  "Troskovi (analiticki):"
if ntot3<>0
 ?  c10T1,":"
 @ prow(),30 SAY  ntot3 pict picdem
endif
if ntot4<>0
 ?  c10T2,":"
 @ prow(),30 SAY  ntot4 pict picdem
endif
if ntot5<>0
 ?  c10T3,":"
 @ prow(),30 SAY  ntot5 pict picdem
endif
if ntot6<>0
 ?  c10T4,":"
 @ prow(),30 SAY  ntot6 pict picdem
endif
if ntot7<>0
 ?  c10T5,":"
 @ prow(),30 SAY  ntot7 pict picdem
endif
? m
? "Ukupno troskova:"
@ prow(),30 SAY  nTot3+nTot4+nTot5+nTot6+nTot7 pict picdem
? m
endif
return
*}



/*! \fn StKalk10_4()
 *  \brief Stampa kalkulacije 10 - varijanta 3, za papir formata A3
 */

function StKalk10_4()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2
P_COND2
?? SPACE(180)+"Str."+str(++nStr,3)     // 220-40
? PADC("PRIJEMNI LIST - KALKULACIJA BR."+cIdFirma+"-"+cIdVD+"-"+cBrDok+"     Datum:"+DTOC(DatDok),242)
? PADC(REPLICATE("-",64),242)
select PARTN; HSEEK cIdPartner
?
? SPACE(104)+"DOBAVLJAC: "+cIdPartner+"-"+naz
? SPACE(104)+"Racun broj: "+cBrFaktP+" od "+DTOC(dDatFaktP)
?
select KONTO; HSEEK cIdKonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz


 m:="--- ---------- ----------------------------------- ---"+IF(gRokTr=="D"," --------","")+" ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -----------"

 ? m

 ? "*R.* Sifra    *                                   *Jed*"+IF(gRokTr=="D","  Rok   *","")+"         F A K T U R A          *      R A B A T      *  CARINSKI TROSKOVI  *  OSTALI. ZAV. TROSK.*      M A R Z A      *POREZ NA PROM.PROIZV.*  IZNOS   * VELEPROD.*"
 ? "*br* artikla  *     N A Z I V    A R T I K L A    *mj.*"+IF(gRokTr=="D","trajanja*","")+"--------------------------------*---------------------*---------------------*---------------------*---------------------*---------------------*  VELE-   *  CIJENA  *"
 ? "*  *          *                                   *   *"+IF(gRokTr=="D","        *","")+" Kolicina *  Cijena  *   Iznos  *    %     *   Iznos  *    %     *   Iznos  *    %     *   Iznos  *    %     *   Iznos  *    %     *   Iznos  * PRODAJE  *          *"

 ? m
 nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=0
 nTotB:=0
 nTotP:=nTotQ:=0
select pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    ViseDokUPripremi(cIdd)
    RptSeekRT()
    KTroskovi()
    DokNovaStrana(230, @nStr, 2)


    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nTot+=  (nU:=round(FCj*Kolicina,gZaokr))
    if gKalo=="1"
        nTot1+= (nU1:=round(FCj2*(GKolicina+GKolicin2),gZaokr))
    else
        nTot1+= (nU1:=round(NC*(GKolicina+GKolicin2),gZaokr))
    endif
    nTot2+= (nU2:=round(-Rabat/100*FCJ*Kolicina,gZaokr))

    nTot3+= (nU3:=round(nPrevoz*SKol,gZaokr))
    nTot4+= (nU4:=round(nBankTr*SKol,gZaokr))
    nTot5+= (nU5:=round(nSpedTr*SKol,gZaokr))
    nTot6+= (nU6:=round(nCarDaz*SKol,gZaokr))
    nTot7+= (nU7:=round(nZavTr* SKol,gZaokr))

    nTot8+= (nU8:=round(NC *    (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    nTot9+= (nU9:=round(nMarza* (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    if !(roba->tip $ "VKX")
     nUP:=0
    else
     if roba->tip="X"
      nTotP+= (nUP:=round(mpcsapp/(1+tarifa->opp/100)*tarifa->opp/100*(Kolicina-Gkolicina-GKolicin2),gZaokr))
     else
      nTotP+= (nUP:=round(vpc/(1+tarifa->opp/100)*tarifa->opp/100*(Kolicina-Gkolicina-GKolicin2),gZaokr))
     endif
    endif
    nTotA+= (nUA:=round(VPC*(Kolicina-Gkolicina-GKolicin2),gZaokr) )
    if gVarVP=="1"
      nTotB+= round( nU9*tarifa->vpp/100 ,gZaokr) // porez na razliku u cijeni
    else
      private cistaMar:=round(nU9/(1+tarifa->vpp/100) , gZaokr)
      nTotB+= round(cistaMar*tarifa->vpp/100 , gZaokr)  // porez na razliku u cijeni
    endif

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    ?? " "+IdRoba+" "+PADR(ROBA->naz,35)+" "+ROBA->jmj
    if roba->(fieldpos("KATBR"))<>0
       ?? " KATBR:", roba->katbr
    endif

    if gRokTr=="D"; ?? " "+DTOC(RokTr); endif
    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    ?? " "+TRANSFORM(Kolicina,pickol)+" "+TRANSFORM(FCJ,PicCDEM)
    ?? " "+TRANSFORM(nU,PICDEM)+" "+TRANSFORM(rabat,PicProc)
    ?? " "+TRANSFORM(nU2,PICDEM)+" "+TRANSFORM(100*nU6/nU,PicProc)
    ?? " "+TRANSFORM(nU6,PICDEM)+" "+TRANSFORM(100*(nU3+nU4+nU5+nU7)/nU,PicProc)
    ?? " "+TRANSFORM((nU3+nU4+nU5+nU7),PICDEM)+" "+TRANSFORM(100*nMarza/NC,PicProc)
    ?? " "+TRANSFORM(nU9,PICDEM)
    /*
    if gVarVP=="1"
     ?? " "+TRANSFORM(tarifa->vpp,PicProc)+" "+TRANSFORM(nU9*tarifa->vpp/100,PICDEM)
    else
     ?? " "+TRANSFORM(100*tarifa->vpp/(100+tarifa->vpp),PicProc)+" "+TRANSFORM(cistaMar*tarifa->vpp/100,PICDEM)
    endif
    */
    ?? " "+TRANSFORM(if(!(roba->tip $ "VKX"),0,tarifa->opp),PicProc)+" "+TRANSFORM(nUP,PICDEM)
    ?? " "+TRANSFORM(nUA,PICDEM)+" "+TRANSFORM(VPC,PicCDEM)
  skip
enddo

DokNovaStrana(230, @nStr, 3)
? m
? "UKUPNO:"+SPACE(70+if(gRokTr=="D",9,0))+TRANSFORM(nTot,PICDEM)
?? SPACE(12)+TRANSFORM(nTot2,PICDEM)+SPACE(12)+TRANSFORM(nTot6,PICDEM)
?? SPACE(12)+TRANSFORM((nTot3+nTot4+nTot5+nTot7),PICDEM)+SPACE(12)+TRANSFORM(nTot9,PICDEM)
?? SPACE(12)+TRANSFORM(nTotP,PICDEM)
?? " "+TRANSFORM(nTotA,PICDEM)
? m
?
return
*}

