#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/jerry/1g/jerry.prg,v $
 * $Author: mirsadsubasic $ 
 * $Revision: 1.7 $
 * $Log: jerry.prg,v $
 * Revision 1.7  2003/09/29 13:26:57  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.6  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.5  2002/10/07 14:15:59  mirsad
 * novi parametar: broj decimala za prikaz iznosa stavki KALK 4x varijanta Jerry
 *
 * Revision 1.4  2002/08/02 13:46:27  mirsad
 * no message
 *
 * Revision 1.3  2002/07/19 14:01:43  mirsad
 * ubacivanje zakasnjelih dorada
 *
 * Revision 1.2  2002/06/24 09:01:02  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/specif/jerry/1g/jerry.prg
 *  \brief Specifikacije specificne za Jerry
 */


/*! \ingroup Jerry
  * \var *string FmkIni_KumPath_KALK_Jerry_KALK4x_SvediDatum
  * \brief Koji se datum svodi na datum posljednje stavke
  * \param F - datum fakture, default vrijednost
  * \param K - datum kalkulacije
  */
*string FmkIni_KumPath_KALK_Jerry_KALK4x_SvediDatum;


/*! \fn StKalk19J()
 *  \brief Stampa kalkulacije 19 "Jerry"
 */

function StKalk19J()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,aPorezi
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()
aPorezi:={}
nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
B_ON
?? "PROMJENA CIJENA U PRODAVNICI"
?
B_OFF
P_COND
? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,", Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
?
select PARTN; HSEEK cIdPartner             // izbaciti?  19.5.00
select KONTO; HSEEK cidkonto               // dodano     19.5.00

?  "KONTO zaduzuje :",cIdKonto,"-",naz

select PRIPR

if cIdVD == "19"
 m:= "--- ---------- ------------------------- --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
 ? m
   ? "*R *   SIFRA  *                         *   *          *  STARA   * RAZLIKA  * PPP   %  * PPU   %  *  POREZ   * RAZLIKA  *  NOVA   *"
   ? "*BR*   ROBE   *       NAZIV ROBE        *JMJ* KOLICINA *MPC SA PP *   MPC    *          *          *          * MPC SA PP*MPC SA PP*"
   ? "*  *          *                         *   *          *    ä     *    ä     *          *          *          *    ä     *    ä    *"
 ? m
 nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=0
endif

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    // !!!!!!!!!!!!!!!
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    endif


    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR
    
    Tarifa(field->pkonto,field->idroba,@aPorezi)
    
    KTroskovi()
    VTPOREZI()
    
    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif

      aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)
      nPor1:=aIPor[1]
      nPor2:=aIPor[2]
      
      nTot3+=  (nU3:= MPC*Kolicina )
      nTot4+=  (nU4:=(nPor1+nPor2)*Kolicina)
      nTot5+=  (nU5:= MPcSaPP*Kolicina )
      @ prow()+1,0 SAY  Rbr
      @ prow(),pcol()+1 SAY IdRoba
      nCol1:=pcol()+1
      aRoba:=SjeciStr(roba->naz,25)
      @ prow(),pcol()+1 SAY aRoba[1]+" "+ROBA->jmj
      @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol
      @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
      nC0:=pcol()+1
      @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
      @ prow(),pcol()+1 SAY aPorezi[POR_PPP]     PICTURE PicProc
      @ prow(),pcol()+1 SAY PrPPUMP()                   PICTURE PicProc
      nC1:=pcol()+1
      @ prow(),pcol()+1 SAY (nPor1+nPor2)*Kolicina        PICTURE PicDEM
      @ prow(),pcol()+1 SAY MPCSAPP                       PICTURE PicCDEM
      @ prow(),pcol()+1 SAY MPCSAPP+FCJ                   PICTURE PicCDEM


      FOR i:=2 TO LEN(aRoba)
        @ prow()+1,nCol1   SAY aRoba[i]
      NEXT

    SKIP 1

enddo

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nC0        SAY  nTot3         PICTURE        PicDEM
@ prow(),nC1        SAY  nTot4         PICTURE        PicDEM
@ prow(),pcol()+1   SAY  nTot5         PICTURE        PicDEM

? m

?
Rektarife()

?
P_10CPI
? padl("Clanovi komisije: 1. ___________________",75)
? padl("2. ___________________",75)
? padl("3. ___________________",75)
?
RETURN
*}


/*! \fn JerryMP()
 *  \brief Svodjenje datuma u svim stavkama na datum posljednje stavke
 */
function JerryMP()
*{
local dLast
local cDok
local cSvediDatFakt
cSvediDatFakt:=IzFmkIni("KALK","Jerry_KALK4x_SvediDatum","F",KUMPATH)
select pripr
go bottom
if (field->idvd="4")
	dLast:=field->datdok
	cDok:=field->idfirma+field->idvd+field->brdok
	go top
	do while (!eof())
		if (field->idfirma+field->idvd+field->brdok==cDok)
			if (cSvediDatFakt=="F")
				replace field->datfaktp with dLast
			elseif (cSvediDatFakt=="K")
				replace field->datdok with dLast
			endif
		endif
		skip 1
	enddo
endif
return nil
*}



/*! \fn StKalk47J()
 *  \brief Stampa kalkulacije 47 / izlaz iz prodavnice
 *  \param
 */
 
function StKalk47J()
*{
local nCol0:=nCol1:=nCol2:=0,npom:=0
local cPicI, nIznosDec

lPrikazNC := ( IzFMKINI("KALK","Jerry_KALK47_PrikazatiNC","D",KUMPATH)=="D" )

Private nMarza,nMarza2,nPRUC
nMarza:=nMarza2:=nPRUC:=0

private aPorezi
aPorezi:={}

nIznosDec:=VAL(IzFMKINI("KALK","Jerry4xIznosDecimala","3",KUMPATH))
cPicI:=STUFF(REPL("9",LEN(PicDEM)),LEN(PicDEM)-nIznosDec,1,".")

lVoSaTa := ( IzFmkIni("KALK","VodiSamoTarife","N",PRIVPATH)=="D" )

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
Naslov4x()

select PRIPR

 m:="---- ---------- -------------------- --- ----------"+IF(lPrikazNC," ---------- --------- -----","")+" ---------- ----- ------ ----- ----- ---------- -----------"

 ? m
 ?  "*R. *          *                    *   *          "+IF(lPrikazNC,"*  NABAVNA *RAZLIKA U* PRUC","")+"*    MP    *RABAT* SIF. * PPP * PPU *          *          *"
 ?  "*BR.* SIF.ROBE *     NAZIV ROBE     *JMJ* KOLICINA "+IF(lPrikazNC,"*  CIJENA  * CIJENI  * (%) ","")+"*  CIJENA  * (%) * TAR. * (%) * (%) *  POREZ   *  UKUPNO  *"
 ? m

nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=0
nTot4a:=0
nTot6a:=nTot6b:=nTot6c:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

	// !!!!!!!!!!!!!!!
	IF idpartner+brfaktp+idkonto+idkonto2<>cidd
		set device to screen
		Beep(2)
		Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
		set device to printer
	ENDIF

	scatter()  // formiraj varijable _....
	select ROBA
	HSEEK PRIPR->IdRoba
	select TARIFA
	HSEEK PRIPR->IdTarifa
	select PRIPR

	Tarifa(pripr->pkonto,pripr->idRoba,@aPorezi)

	Marza2R()   // izracunaj nMarza2
	KTroskovi()

	VTPorezi()

	if prow()>62+gPStranica
		FF
		@ prow(),125 SAY "Str:"+str(++nStr,3)
	endif

	nTot3+=(nU3:=IF(roba->tip="U",0,field->nc)*field->kolicina)
	nTot4+=(nU4:=nMarza2*field->kolicina)
	nTot5+=(nU5:=field->mpc*field->kolicina)

	aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)
	nPor1:=aIPor[1]
	nPor2:=aIPor[2]
	nPor3:=aIPor[3]

	nTot6+=  (nU6:=(nPor1+nPor2+nPor3)*Kolicina)
	nTot6a+= (nPor1*Kolicina)
	nTot6b+= (nPor2*Kolicina)
	nTot6c+= (nPor3*Kolicina)
	nTot7+=  (nU7:= MPcSaPP*Kolicina )

	nTot8+=  (nU8:= (MPcSaPP-RabatV)*Kolicina )
	nTot9+=  (nU9:= RabatV*Kolicina )

	@ prow()+1,0 SAY  " "+Rbr
	@ prow(),pcol()+1 SAY IdRoba
	nCol1:=pcol()+1
	aRoba:=SjeciStr(roba->naz,20)
	?? "", aRoba[1], ROBA->jmj, TRANS( kolicina, PicKol )

	IF lPrikazNC
		?? "", TRANS( NC       , PicCDEM )+TRANS( nMarza2  , PicCDEM ),TRANS( TARIFA->mpp , "99.99" )
	ENDIF

	?? "", TRANS( MPCsaPP  , PicCDEM ), TRANS( 100*rabatv/IF(MPCsaPP>0,MPCsaPP,999999999999), "99.99"  ), idtarifa, TRANS( aPorezi[POR_PPP] , "99.99" ), TRANS( aPorezi[POR_PPU] , "99.99" ), TRANS( nU6  , PicCDEM ), TRANS( nU8  , cPicI )

	FOR i:=2 TO LEN(aRoba)
		@ prow()+1,nCol1   SAY aRoba[i]
	NEXT

	skip 1

enddo

if prow()>61+gPStranica
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

? m
IF lPrikazNC
	nPom:=76
ELSE
	nPom:=49
ENDIF
nPom:=nPom+2-nIznosDec
@ prow()+1,nPom SAY PADR( "Ukupan iznos racuna" ,35,".") +            KPAD(nTot8 ,25)
IF ROUND(nTot6a,3)<>0
  @ prow()+1,nPom SAY PADR( "Porez na promet proizvoda" ,35,".") +      KPAD(nTot6a ,25)
ENDIF
IF ROUND(nTot6b,3)<>0
  @ prow()+1,nPom SAY PADR( "Porez na promet usluga" ,35,".") +         KPAD(nTot6b ,25)
ENDIF
IF lPrikazNC
  @ prow()+1,nPom SAY PADR( "Razlika u cijeni (marza)" ,35,".") +        KPAD(nTot4 ,25)
//  IF ROUND(nTot8-nTot6-nTot3-nTot4,3)<>0
//    @ prow()+1,nPom SAY PADR( "Porez na marzu" ,35,".") +        KPAD( nTot8-nTot6a-nTot6b-nTot3-nTot4 ,25)
//  ENDIF
  @ prow()+1,nPom SAY PADR( "Nabavna vrijednost prodate robe" ,35,".") + KPAD(nTot3 ,25)
ENDIF
IF ROUND(nTot6c,3)<>0
  @ prow()+1,nPom SAY PADR( "Posebni porez na potrosnju" ,35,".") +      KPAD(nTot6c ,25)
ENDIF
@ prow()+1,nPom SAY PADR( "Ukupna vrijednost poreza" ,35,".") +       KPAD(nTot6a+nTot6b+nTot6c ,25)
? m

if prow()>55+gPStranica
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif
nRec:=recno()

RekTar41(cIdFirma, cIdVd, cBrDok, @nStr)
set order to 1
go nRec
RETURN
*}




/*! \fn StKalk81J()
 *  \brief Stampa kalkulacije 81 / direktno zaduzenje prodavnice
 */
 
function StKalk81J()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,nPRUC,aPorezi
nMarza:=nMarza2:=nPRUC:=0
aPorezi:={}
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

P_10CPI
?? "ULAZ U PRODAVNICU DIREKTNO OD DOBAVLJACA"
P_COND
?
?
?? "KALK BR: "
B_ON
?? cIdFirma+"-"+cIdVD+"-"+cBrDok
B_OFF
?? "   ", P_TipDok(cIdVD,-2), SPACE(2), "Datum:", DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
?

select PARTN; HSEEK cIdPartner

?  "DOBAVLJAC:"
B_ON
?? cIdPartner,"-",naz
B_OFF
?? SPACE(6),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP
?

select KONTO; HSEEK cIdKonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz

m:="---- ---------- -------------------- --- --------- --------- ----- ------ ----- ----- ------ ----- ----- --------- ---------- -----------"

? m
?  "*R. *          *                    *   *         *JED.FAKT.*RABAT*ZAVIS.* RUC * PRUC* SIF. * PPP * PPU *         *    MP    *          *"
?  "*BR.* SIF.ROBE *     NAZIV ROBE     *JMJ*KOLICINA * CIJENA  * (%) *TR.(%)* (%) * (%) * TAR. * (%) * (%) *  POREZ  *  CIJENA  *  UKUPNO  *"
? m
nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=nTotb:=0
nTot9a:=0
nTotA1:=nTotA2:=nTotA3:=0

select pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

	// !!!!!!!!!!!!!!!
	if idpartner+brfaktp+idkonto+idkonto2<>cidd
		set device to screen
		Beep(2)
		Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
		set device to printer
	endif

	KTroskovi()

	select ROBA
	HSEEK PRIPR->IdRoba
	select TARIFA
	HSEEK PRIPR->IdTarifa

	VTPOREZI()
	select PRIPR

	Tarifa(pripr->pkonto,pripr->idroba,@aPorezi)

	if prow()>62+gPStranica
		FF
		@ prow(),125 SAY "Str:"+str(++nStr,3)
	endif

	if gKalo=="1"
		SKol:=Kolicina-GKolicina-GKolicin2
	else
		SKol:=Kolicina
	endif

	nTot+=  (nU:=FCj*Kolicina)
	if gKalo=="1"
		nTot1+= (nU1:=FCj2*(GKolicina+GKolicin2))
	else
		nTot1+= (nU1:=NC*(GKolicina+GKolicin2))
	endif
	nTot2+= (nU2:=-Rabat/100*FCJ*Kolicina)
	nTot3+= (nU3:=nPrevoz*SKol)
	nTot4+= (nU4:=nBankTr*SKol)
	nTot5+= (nU5:=nSpedTr*SKol)
	nTot6+= (nU6:=nCarDaz*SKol)
	nTot7+= (nU7:=nZavTr* SKol)
	nTot8+= (nU8:=NC *    (Kolicina-Gkolicina-GKolicin2) )
	nTot9+= (nU9:=nMarza2* (Kolicina-Gkolicina-GKolicin2) )
	nUA:=MPC   * (Kolicina-Gkolicina-GKolicin2)
	nTotA+= nUA
	
	aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)
	nTotA1 += aIPor[1]*(Kolicina-Gkolicina-GKolicin2)
	nTotA2 += aIPor[2]*(Kolicina-Gkolicina-GKolicin2)
	nTotA3 += aIPor[3]*(Kolicina-Gkolicina-GKolicin2)
	
	nUB:=MPCSAPP* (Kolicina-Gkolicina-GKolicin2)
	nTotB+= nUB

	@ prow()+1,0 SAY  " "+Rbr
	@ prow(),pcol()+1 SAY IdRoba
	nCol1:=pcol()+1
	aRoba:=SjeciStr(roba->naz,20)
	?? "", aRoba[1], ROBA->jmj+TRANS( kolicina  , PicCDEM )+TRANS( FCJ  , PicCDEM ), TRANS( rabat, "99.99"  ), TRANS( (nPrevoz+nBankTr+nSpedtr+nCarDaz+nZavTr)/FCJ2*100, "999.99" ), TRANS( nMarza2/NC*100, "99.99"  ), TRANS( aPorezi[POR_PRUCMP] , "99.99" ), idtarifa, TRANS( aPorezi[POR_PPP] , "99.99" ), TRANS( aPorezi[POR_PPU] , "99.99" )+TRANS( nUB-nUA  , PicCDEM ), TRANS( MPCSaPP  , PicCDEM ), TRANS( nUB  , PicDEM )

	for i:=2 to LEN(aRoba)
		@ prow()+1,nCol1   SAY aRoba[i]
	next

	skip 1
enddo

if prow()>61+gPStranica
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

? m
ncp:=76

if ROUND(nTot3+nTot4+nTot5+nTot6+nTot7,3)<>0
	@ prow()+1,ncp SAY PADR( "Ukupan iznos racuna" ,35,".")+KPAD(nTot+nTot2 ,25)
	@ prow()+1,ncp SAY PADR( "Zavisni troskovi" ,35,".")+KPAD(nTot3+nTot4+nTot5+nTot6+nTot7 ,25)
	@ prow()+1,ncp SAY PADR( "Nabavna vrijednost" ,35,".")+KPAD(nTot8  ,25)
else
	@ prow()+1,ncp SAY PADR( "Ukupan iznos racuna (nabavna vrij.)" ,35,".")+KPAD(nTot8  ,25)
endif


@ prow()+1,ncp SAY PADR( "Prodajna vrijednost bez poreza" ,35,".")+KPAD(nTotA  ,25)

if ROUND(nTotA1,3)<>0
	@ prow()+1,ncp SAY PADR( "Porez na promet proizvoda" ,35,".")+KPAD(nTotA1 ,25)
endif

if ROUND(nTotA2,3)<>0
	@ prow()+1,ncp SAY PADR( "Porez na promet usluga" ,35,".")+KPAD(nTotA2 ,25)
endif

if ROUND(nTotA3,3)<>0
	@ prow()+1,ncp SAY PADR( "Posebni porez na potrosnju" ,35,".")+KPAD(nTotA3 ,25)
endif

@ prow()+1,ncp SAY PADR( "Ukupna vrijednost poreza" ,35,".") +       KPAD(nTotA1+nTotA2+nTotA3 ,25)
@ prow()+1,ncp SAY PADR( "Prodajna vrijednost sa porezom" ,35,".") + KPAD(nTotB  ,25)

? m

if prow()>55+gPStranica
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif
?
if  round(ntot3+ntot4+ntot5+ntot6+ntot7,2) <>0
	?  m
	?  "Troskovi (analiticki):"
	?  c10T1,":"
	@ prow(),30 SAY  ntot3 pict picdem
	?  c10T2,":"
	@ prow(),30 SAY  ntot4 pict picdem
	?  c10T3,":"
	@ prow(),30 SAY  ntot5 pict picdem
	?  c10T4,":"
	@ prow(),30 SAY  ntot6 pict picdem
	?  c10T5,":"
	@ prow(),30 SAY  ntot7 pict picdem
	? m
	? "Ukupno troskova:"
	@ prow(),30 SAY  ntot3+ntot4+ntot5+ntot6+ntot7 pict picdem
	? m
endif

nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
RekTarife()
? "RUC:";  @ prow(),pcol()+1 SAY nTot6 pict picdem
? m
return
*}


