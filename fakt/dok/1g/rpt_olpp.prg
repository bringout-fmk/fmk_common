#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/rpt_olpp.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: rpt_olpp.prg,v $
 * Revision 1.5  2003/04/25 10:44:36  ernad
 * ispravka za Planiku: parametar Cijena13MPC=D vise ne setuje MPC u sifrarniku pri promjeni cijene u unosu 13-ke
 *
 * Revision 1.4  2002/09/13 12:02:33  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.3  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.2  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.1  2002/06/26 18:00:19  ernad
 *
 *
 * ciscenja
 *
 *
 */


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Cijena13MPC
  * \brief Da li je MPC cijena koja se pamti u dokumentu tipa 13 (otpremnica u MP) ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_Cijena13MPC;


/*! \fn StOLPP()
 *  \brief Stampa obracunaskog lista poreza na promet
 *  \todo Prebaciti u /RPT
 */


function StOLPP()
*{
LOCAL nMirso:=0, nsMir1:=0, nsMir2:=0, ii:=0, InPicDem:=picdem, GetList:={}
LOCAL InPicKol:=pickol

 private cRegion:=GetRegion()

 O_PARTN
 O_ROBA
 O_TARIFA
 O_PRIPR

 gOstr    := "D"
 gnRedova := gPStranica+64
 picdem   := "99999999.99"
 pickol   := SUBSTR(pickol,2)

 SELECT PRIPR

IF glCij13Mpc
  cpmp:="9"
ELSEIF EMPTY(g13dcij) .and. gVar13!="2"
 Box(,1,50)
  cpmp:="9"
  @ m_x+1,m_y+2 SAY "Prikaz MPC ( 1/2/3/4/5/6/9 iz fakt-a) " GET cPMP valid cpmp $ "1234569"
  read
 BoxC()
ELSE
 cPMP:=g13dcij
ENDIF

cTxt1:=""
cTxt2:=""
cTxt3a:=""
cTxt3b:=""
cTxt3c:=""

if val(podbr)=0  .and. val(rbr)==1
   aMemo:=ParsMemo(txt)
   if len(aMemo)>0
     cTxt1:=padr(aMemo[1],40)
   endif
   if len(aMemo)>=5
    cTxt2:=aMemo[2]
    cTxt3a:=aMemo[3]
    cTxt3b:=aMemo[4]
    cTxt3c:=aMemo[5]
   endif
else
  Beep(2)
  Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  return
endif


 cIdFirma := IDFIRMA
 cIdVd    := IDTIPDOK
 cBrDok   := BRDOK

 m:="ÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ"

 nC1:=10; nc2:=25; nc3:=40; nC4:=0; nC5:=0

 START PRINT RET

 nU1:=nU2:=nU3:=nU4:=0

 ZOlPP()

 PRIVATE nColR:=10

 DO WHILE !EOF() .and. cIdfirma+cIdVd+cBrDok==IDFIRMA+IDTIPDOK+BRDOK

   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba

   aPorezi:={}
   SELECT PRIPR
   cTarifa:=TarifaR(cRegion,ROBA->id,@aPorezi)


   IF gVar13!="2"
     if cPMP=="2"
      nMPCSAPP:=roba->mpc2
     elseif cPMP=="3"
      nMPCSAPP:=roba->mpc3
     elseif cPMP=="4"
      nMPCSAPP:=roba->mpc4
     elseif cPMP=="5"
      nMPCSAPP:=roba->mpc5
     elseif cPMP=="6"
      nMPCSAPP:=roba->mpc6
     elseif cpmp=="1"
      nMPCSAPP:=roba->mpc
     else
      nMPCSAPP:=pripr->cijena
     endif
   ELSE
     nMPCSaPP:=cijena
   ENDIF

   if kolicina==0   // nivelacija:TNAM
     nMPC1 := MpcBezPor( iznos , aPorezi )
     nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )
     // nMPC2:=Iznos/(1+tarifa->ppp/100)
     // nMPC1:=nMPC2/(1+tarifa->opp/100)
   else
     nMPC1 := MpcBezPor( nMPCSaPP , aPorezi )
     nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )
     // nMPC2:=nMPCSaPP/(1+tarifa->ppp/100)
     // nMPC1:=nMPC2/(1+tarifa->opp/100)
   endif

   if prow()>gnRedova-2 .and. gOstr=="D"; FF; ZOlPP(); endif
                                // bilo:  EJECTNA0
   ? rbr
   nColR:=pcol()+1

   aRoba:=SjeciStr(roba->naz,20)
   @ prow(),pcol()+1 SAY aRoba[1]
   @ prow(),pcol()+1 SAY roba->jmj

   nPom:=at("/",ctarifa)
   IF nPom>0
    cT1:=padr( left(ctarifa,npom-1),2)
    cT2:=padr( substr(ctarifa,npom+1) ,2)
   ELSE
    cT1:=LEFT(ctarifa,1)+" "
    cT2:="  "
   ENDIF

   @ prow(),pcol()+1 say kolicina pict pickol

   @ prow(),pcol()+1 say nMPC1 pict "99999999.99"
   nC1:=pcol()+1

   @ prow(),pcol()+1 say nMPC1*kolicina pict picdem
   @ prow(),pcol()+1 say cT1

   @ prow(),pcol()+1 say aPorezi[POR_PPP] pict "99.9"; ?? "%"
   nC4:=pcol()+1

   @ prow(),pcol()+1 say (nMirso:=(nMPC2-nMPC1)*kolicina) pict "999999.99"
   nsMir1+=nMirso

   @ prow(),pcol()+1 say nMPC2 pict "9999999.99"
   nC2:=pcol()+1

   @ prow(),pcol()+1 say nMPC2*kolicina pict picdem
   @ prow(),pcol()+1 say cT2

   @ prow(),pcol()+1 say aPorezi[POR_PP] pict "99.9"; ?? "%"
   IF kolicina==0   // nivelacija:TNAM
     nPor:=MpcBezPor( iznos , aPorezi )
     // nPor:=iznos/(1+tarifa->opp/100)/(1+tarifa->ppp/100)
   ELSE
     nPor:=Izn_P_PP(nMPC1, aPorezi)+Izn_P_PPP(nMPC1, aPorezi)
     // nPor:=nMPC1*tarifa->opp/100+nMPC2*tarifa->ppp/100
   ENDIF
   nC5:=pcol()+1

   @ prow(),pcol()+1 say IF(kolicina==0,nPor,nPor*kolicina)-nMirso pict "999999.99"
   nsMir2+=(IF(kolicina==0,nPor,nPor*kolicina)-nMirso)

   @ prow(),pcol()+1 say nMPCSAPP          pict picdem
   nC3:=pcol()+1

   if kolicina==0     // nivelacija:TNAM
     @ prow(),pcol()+1 say Iznos pict picdem
     @ prow(),pcol()+1 say  nPor pict picdem
     nU1+=nmpc1;nU2+=nMpc2
     nU3+=iznos; nU4+=nPor
   else
     @ prow(),pcol()+1 say nMPCSAPP*kolicina pict picdem
     @ prow(),pcol()+1 say  nPor*kolicina pict picdem
     nU1+=nmpc1*kolicina; nU2+=nMPC2*kolicina
     nU3+=nMPCsaPP*kolicina;  nU4+=nPor*kolicina
   endif

   for ii=2 to len(aRoba)
    @ prow()+1,nColR SAY aRoba[ii]
   next

   skip 1

 ENDDO

 if prow()>gnRedova-4 .and. gOstr=="D"; FF; ZOlPP(); endif
                              // bilo:  EJECTNA0

 ? m
 ? "Ukupno :"
 @ prow(),nc1   say    nu1  pict picdem
 @ prow(),nc4   say nsMir1  pict "999999.99"
 @ prow(),nc2   say    nu2  pict picdem
 @ prow(),nc5   say nsMir2  pict "999999.99"
 @ prow(),nc3   say    nu3  pict picdem
 @ prow(),pcol()+1 say    nu4  pict picdem
 ? STRTRAN(m," ","Ä")
 ?

 FF

 END PRINT

 picdem:=InPicDem
 pickol:=InPicKol

return
*}


/*! \fn ZOLPP()
 *  \brief Obracunski list poreza na promet
 */
 
function ZOLPP()
*{
LOCAL cNaslov:=StrKZN("OBRA^UNSKI LIST POREZA NA PROMET","7",gKodnaS),cPom1,cPom2,c
ZagFirma()
@ prow()+1,35 SAY cNaslov
?
select partn; hseek pripr->idpartner; select pripr
@ prow()+1,20 SAY "Po dokumentu: "+idtipdok+"   "
?? StrKZN("Sjedi{te:","7",gKodnaS)
@ prow()+1,33 SAY "Broj: "; ?? brdok,"od:",SrediDat(datdok)

P_COND2

?  StrKZN("ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿","7",gKodnaS)
?  StrKZN("³  ³                    ³   ³          ³   Prod.cijena bez por.³ Porez na promet  ³ Prodajna cijena sa   ³   Poseban porez  ³  Prod.cij.sa porezom  ³ Porez na ³","7",gKodnaS)
       c:="³R.³       Naziv        ³jed³ koli~ina ³   na promet proizvoda ³    proizvoda     ³ porezom na pr.proizv.³                  ³na prom.proiz.i pos.por³  promet  ³"
? StrKZN(c,"7",gKodnaS)
?  StrKZN("³br³                    ³mj.³          ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÅÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÅÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ´          ³","7",gKodnaS)
?  StrKZN("³  ³                    ³   ³          ³ Pojedin.  ³   Ukupna  ³TB³Stopa³ Iznos   ³ Pojedin. ³  Ukupna   ³TB³Stopa³ Iznos   ³  Pojedin. ³  Ukupna   ³  UKUPNO  ³","7",gKodnaS)
?  StrKZN("ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ","7",gKodnaS)
return
*}

