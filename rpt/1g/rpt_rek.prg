#include "\dev\fmk\ld\ld.ch"



function Rekap(fSvi)
*{
private nC1:=20
private i
private cTPNaz
private cUmPD:="N"
private nKrug:=1
private nUPorOl:=0
private cFilt1:=""
private cNaslovRekap:="LD: Rekapitulacija primanja"
private aUsl1, aUsl2
private aNetoMj

lPorNaRekap:=IzFmkIni("LD","PoreziNaRekapitulaciji","N",KUMPATH)=="D"

cIdRadn:=SPACE(_LR_)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cMjesecDo:=cMjesec
nStrana:=0
aUkTr:={}

if fSvi==nil
	fSvi:=.f.
endif

ORekap()

cIdRadn:=SPACE(6)
cStrSpr:=SPACE(3)
cOpsSt:=SPACE(4)
cOpsRad:=SPACE(4)
cK4:="S"

altd()

if fSvi
	qqRJ:=SPACE(60)
	BoxRekSvi()
	if (LastKey()==K_ESC)
		return
	endif
else
	qqRJ:=SPACE(2)
	BoxRekJ()
	if (LastKey()==K_ESC)
		return
	endif
endif

select ld
	
if lViseObr
	cObracun:=TRIM(cObracun)
else
	cObracun:=""
endif

if fSvi
	set order to tag (TagVO("2"))
else
	set order to tag (TagVO("1"))
endif

if fSvi
	
	cFilt1:=".t." + IF(EMPTY(cStrSpr),"",".and.IDSTRSPR=="+cm2str(cStrSpr))+IF(EMPTY(qqRJ),"",".and."+aUsl1)
	
	if cMjesec!=cMjesecDo
  		cFilt1:=cFilt1 + ".and.mjesec>="+cm2str(cMjesec)+".and.mjesec<="+cm2str(cMjesecDo)+".and.godina="+cm2str(cGodina)
	endif
// benjo, 08.04.2004, ispravka buga na rekapitulaciji za sve rj
	//if cMjesec==cMjesecDo
  		//seek str(cGodina,4)+STR(cMjesec,2)+cObracun
		//EOF CRET
	//else
  		//GO TOP
	//endif
GO TOP

else

	cFilt1 := ".t." + IF(EMPTY(cStrSpr),"",".and.IDSTRSPR=="+cm2str(cStrSpr))
	if cMjesec!=cMjesecDo
  		cFilt1 := cFilt1 + ".and.mjesec>="+cm2str(cMjesec)+".and.mjesec<="+cm2str(cMjesecDo)+".and.godina="+cm2str(cGodina)
	endif

endif //fSvi	


if lViseObr
	cFilt1 += ".and. OBR="+cm2str(cObracun)
endif
	
cFilt1:=STRTRAN(cFilt1,".t..and.","")

if cFilt1==".t."
	SET FILTER TO
else
	SET FILTER TO &cFilt1
endif

if !fSvi
	seek STR(cGodina,4)+cIdRj+STR(cMjesec,2)+cObracun
	EOF CRET
else
  	seek str(cGodina,4)+STR(cMjesec,2)+cObracun
	EOF CRET
endif




PoDoIzSez(cGodina,cMjesecDo)


if !lPorNaRekap
   cLinija:="------------------------  ----------------               -------------------"
else
   cLinija:="------------------------  ---------------  ---------------  -------------"
endif


CreOpsLD()
CreRekLD()

O_REKLD
O_OPSLD

select ld

START PRINT CRET

P_10CPI

if IzFMKIni("LD","RekapitulacijaGustoPoVisini","N",KUMPATH)=="D"
	lGusto:=.t.
  	gRPL_Gusto()
  	nDSGusto:=VAL(IzFMKIni("RekapGustoPoVisini","DodatnihRedovaNaStranici","11",KUMPATH))
  	gPStranica+=nDSGusto
else
  	lGusto:=.f.
  	nDSGusto:=0
endif


ParObr(cmjesec,IF(lViseObr,cObracun,),IF(!fSvi,cIdRj,))
// samo pozicionira bazu PAROBR na odgovarajuci zapis

private aRekap[cLDPolja,2]

for i:=1 to cLDPolja
	aRekap[i,1]:=0
  	aRekap[i,2]:=0
next

nT1:=nT2:=nT3:=nT4:=0
nUNeto:=0
nUNetoOsnova:=0
nUBNOsnova:=0
nUIznos:=nUSati:=nUOdbici:=nUOdbiciP:=nUOdbiciM:=0
nLjudi:=0

private aNeta:={}
altd()
select ld

if cMjesec!=cMjesecDo
	if fSvi
   		go top
		private bUslov:={|| godina==cGodina .and. mjesec>=cMjesec .and. mjesec<=cMjesecDo .and. IF(lViseObr,obr=cObracun,.t.) }
 	else
   		private bUslov:={|| godina==cGodina .and. idrj==cIdRj .and. mjesec>=cMjesec .and. mjesec<=cMjesecDo .and. IF(lViseObr,obr=cObracun,.t.) }
 	endif
else
 	if fSvi
   		private bUslov:={|| cgodina==godina .and. cmjesec=mjesec .and. IF(lViseObr,obr=cObracun,.t.) }
 	else
   		private bUslov:={|| cgodina==godina .and. cidrj==idrj .and. cmjesec=mjesec .and. IF(lViseObr,obr=cObracun,.t.) }
 	endif
endif

VrtiSeULD(fSvi)

if nLjudi==0
	nLjudi:=9999999
endif

B_ON

?? cNaslovRekap

B_OFF

if !empty(cstrspr)
	?? " za radnike strucne spreme ",cStrSpr
endif

if !empty(cOpsSt)
	? "Opstina stanovanja:",cOpsSt
endif

if !empty(cOpsRad)
	? "Opstina rada:",cOpsRad
endif

if fSvi
	ZaglSvi()
else
	ZaglJ()
endif

if lPorNaRekap
	? SPACE(60) + "Porez:" + STR(por->iznos) + "%"
endif

? cLinija

IspisTP(fSvi)

if IzFmkIni("LD","Rekap_ZaIsplatuRasclanitiPoTekRacunima","N",KUMPATH)=="D" .and. LEN(aUkTR)>1
	PoTekRacunima()
endif

? cLinija

if !lPorNaRekap
   ?  "UKUPNO ZA ISPLATU"
   @ prow(),60 SAY nUIznos pict gpici
   ?? "",gValuta
else
   ?  "UKUPNO ZA ISPLATU"
   @ prow(),42 SAY nUIznos pict gpici
   ?? "",gValuta
endif

? cLinija

if !lGusto
	?
endif


?

ProizvTP()

if cMjesec==cMjesecDo     
	// za vise mjeseci nema prikaza poreza i doprinosa
	if !lGusto
  		?
	endif
	PrikKBO()
	PrikKBOBenef()
	select por
	go top
	nPom:=nPor:=nPor2:=nPorOps:=nPorOps2:=0
	nC1:=20

	cLinija:="----------------------- -------- ----------- -----------"

	if cUmPD=="D"
  		m+=" ----------- -----------"
	endif

	if cUmPD=="D"
  		P_12CPI
  		? "----------------------- -------- ----------- ----------- ----------- -----------"
  		? "                                 Obracunska     Porez    Preplaceni     Porez   "
  		? "     Naziv poreza          %      osnovica   po obracunu    porez     za uplatu "
  		? "          (1)             (2)        (3)     (4)=(2)*(3)     (5)     (6)=(4)-(5)"
  		? "----------------------- -------- ----------- ----------- ----------- -----------"
	endif

	do while !eof()
  		if prow()>55+gPStranica
    			FF
  		endif
   		
		? id,"-",naz
   		@ prow(),pcol()+1 SAY iznos pict "99.99%"
   		nC1:=pcol()+1
   		if !empty(poopst)
			altd()
     			if poopst=="1"
       				?? " (po opst.stan)"
     			elseif poopst=="2"
       				?? " (po opst.stan)"
     			elseif poopst=="3"
       				?? " (po kant.stan)"
     			elseif poopst=="4"
       				?? " (po kant.rada)"
     			elseif poopst=="5"
       				?? " (po ent. stan)"
     			elseif poopst=="6"
       				?? " (po ent. rada)"
       				?? " (po opst.rada)"
     			endif
     			nOOP:=0      
			// ukupna Osnovica za ObraŸun Poreza za po opçtinama
     			nPOLjudi:=0  
     			// ukup.ljudi za po opçtinama
     			nPorOps:=0
     			nPorOps2:=0
     			select opsld
     			seek por->poopst
     			? strtran(cLinija,"-","=")
     			do while !eof() .and. id==por->poopst   //idopsst
		         select ops
			 hseek opsld->idops
			 select opsld
		         IF !ImaUOp("POR",POR->id)
		           SKIP 1
			   LOOP
		         ENDIF
		         ? idops,ops->naz
		         @ prow(),nc1 SAY iznos picture gpici
		         @ prow(),pcol()+1 SAY nPom:=round2(max(por->dlimit,por->iznos/100*iznos),gZaok2) pict gpici
		         if cUmPD=="D"
		           // ______  PORLD ______________
		           @ prow(),pcol()+1 SAY nPom2:=round2(max(por->dlimit,por->iznos/100*piznos),gZaok2) pict gpici
		           @ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
		           Rekapld("POR"+por->id+idops,cgodina,cmjesec,nPom-nPom2,0,idops,NLjudi())
		           nPorOps2+=nPom2
		         else
		           Rekapld("POR"+por->id+idops,cgodina,cmjesec,nPom,iznos,idops,NLjudi())
		         endif
		         nOOP += iznos
		         nPOLjudi += ljudi
		         nPorOps+=nPom
		         skip
		         if prow()>62+gPStranica
			 	FF
			 endif
		     enddo
		     select por
		     ? cLinija
		     nPor+=nPorOps
		     nPor2+=nPorOps2
	   endif // poopst
   if !empty(poopst)
     ? cLinija
     ? "Ukupno:"
//     @ prow(),nc1 SAY nUNeto pict gpici
     @ prow(),nc1 SAY nOOP pict gpici
     @ prow(),pcol()+1 SAY nPorOps   pict gpici
     if cUmPD=="D"
       @ prow(),pcol()+1 SAY nPorOps2   pict gpici
       @ prow(),pcol()+1 SAY nPorOps-nPorOps2   pict gpici
       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps-nPorOps2,0,,NLjudi())
     else
//       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps,nUNeto,,NLjudi())
       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps,nOOP,,"("+ALLTRIM(STR(nPOLjudi))+")")
     endif
     ? cLinija
   else
     @ prow(),nc1 SAY nUNeto pict gpici
     @ prow(),pcol()+1 SAY nPom:=round2(max(dlimit,iznos/100*nUNeto),gZaok2) pict gpici
     if cUmPD=="D"
       @ prow(),pcol()+1 SAY nPom2:=round2(max(dlimit,iznos/100*nUNeto2),gZaok2) pict gpici
       @ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
       Rekapld("POR"+por->id,cgodina,cmjesec,nPom-nPom2,0)
       nPor2+=nPom2
     else
       Rekapld("POR"+por->id,cgodina,cmjesec,nPom,nUNeto,,"("+ALLTRIM(STR(nLjudi))+")")
     endif
     nPor+=nPom
   endif


  skip
enddo
if round2(nUPorOl,2)<>0 .and. gDaPorOl=="D" .and. !Obr2_9()
   ? "PORESKE OLAKSICE"
   select por; go top
   nPOlOps:=0
   if !empty(poopst)
      if poopst=="1"
       ?? " (po opst.stan)"
      else
       ?? " (po opst.rada)"
      endif
      nPOlOps:=0
      select opsld
      seek por->poopst
      do while !eof() .and. id==por->poopst
         If prow()>55+gPStranica
           FF
         endif
         select ops; hseek opsld->idops; select opsld
         IF !ImaUOp("POR",POR->id)
           SKIP 1; LOOP
         ENDIF
         ? idops, ops->naz
         @ prow(), nc1 SAY parobr->prosld picture gpici
         @ prow(), pcol()+1 SAY round2(iznos2,gZaok2)    picture gpici
         Rekapld("POROL"+por->id+opsld->idops,cgodina,cmjesec,round2(iznos2,gZaok2),0,opsld->idops,NLjudi())
         skip
         if prow()>62+gPStranica; FF; endif
      enddo
      select por
      ? cLinija
      ? "UKUPNO POR.OL"
   endif // poopst
   @ prow(),nC1 SAY parobr->prosld  pict gpici
   @ prow(),pcol()+1 SAY round2(nUPorOl,gZaok2)    pict gpici
   Rekapld("POROL"+por->id,cgodina,cmjesec,round2(nUPorOl,gZaok2),0,,"("+ALLTRIM(STR(nLjudi))+")")
   if !empty(poopst)
   	? cLinija
   endif

endif
? cLinija
? "Ukupno Porez"
@ prow(),nC1 SAY space(len(gpici))
@ prow(),pcol()+1 SAY nPor-nUPorOl pict gpici
if cUmPD=="D"
  @ prow(),PCOL()+1 SAY nPor2              pict gpici
  @ prow(),pcol()+1 SAY nPor-nUPorOl-nPor2 pict gpici
endif
? cLinija
IF !lGusto
 ?
 ?
ENDIF
?
if prow()>55+gpStranica; FF; endif


m:="----------------------- -------- ----------- -----------"
if cUmPD=="D"
  m+=" ----------- -----------"
endif
select dopr; go top
nPom:=nDopr:=0
nPom2:=nDopr2:=0
nC1:=20

if cUmPD=="D"
  ? "----------------------- -------- ----------- ----------- ----------- -----------"
  ? "                                 Obracunska   Doprinos   Preplaceni   Doprinos  "
  ? "    Naziv doprinosa        %      osnovica   po obracunu  doprinos    za uplatu "
  ? "          (1)             (2)        (3)     (4)=(2)*(3)     (5)     (6)=(4)-(5)"
  ? "----------------------- -------- ----------- ----------- ----------- -----------"
endif

do while !eof()

  if prow()>55+gpStranica
     FF
  endif

  // ako je BENEF i ako je osnova 0 preskoci ovaj doprinos
  if ("BENEF" $ naz) .and. nUBNOsnova == 0
      skip
      loop 
  endif

  if right(id,1)=="X"
   ? cLinija
  endif
  ? id,"-",naz

  @ prow(),pcol()+1 SAY iznos pict "99.99%"
  nC1:=pcol()+1

  if empty(idkbenef) // doprinos udara na neto

    altd()
    if !empty(poopst)
      if poopst=="1"
        ?? " (po opst.stan)"
      elseif poopst=="2"
        ?? " (po opst.rada)"
      elseif poopst=="3"
        ?? " (po kant.stan)"
      elseif poopst=="4"
        ?? " (po kant.rada)"
      elseif poopst=="5"
        ?? " (po ent. stan)"
      elseif poopst=="6"
        ?? " (po ent. rada)"
      endif
      ? strtran(m,"-","=")
      nOOD:=0          // ukup.osnovica za obraŸun doprinosa za po opçtinama
      nPOLjudi:=0      // ukup.ljudi za po opçtinama
      nDoprOps:=0
      nDoprOps2:=0
      select opsld
      seek dopr->poopst
      altd()
      do while !eof() .and. id==dopr->poopst
        altd()
        select ops; hseek opsld->idops; select opsld
        IF !ImaUOp("DOPR",DOPR->id)
          SKIP 1; LOOP
        ENDIF
        ? idops,ops->naz
        nBOOps:=round2(iznos*parobr->k3/100,gZaok2)
        @ prow(),nc1 SAY nBOOps picture gpici
        nPom:=round2(max(dopr->dlimit,dopr->iznos/100*nBOOps),gZaok2)
        if cUmPD=="D"
          nBOOps2:=round2(piznos*nPK3/100,gZaok2)
          nPom2:=round2(max(dopr->dlimit,dopr->iznos/100*nBOOps2),gZaok2)
        endif
        if round(dopr->iznos,4)=0 .and. dopr->dlimit>0
          nPom:=dopr->dlimit*opsld->ljudi
          if cUmPD=="D"
            nPom2:=dopr->dlimit*opsld->pljudi
          endif
        endif
        @ prow(),pcol()+1 SAY  nPom picture gpici
        if cUmPD=="D"
          @ prow(),pcol()+1 SAY  nPom2 picture gpici
          @ prow(),pcol()+1 SAY  nPom-nPom2 picture gpici
          Rekapld("DOPR"+dopr->id+idops,cgodina,cmjesec,nPom-nPom2,0,idops,NLjudi())
          nDoprOps2+=nPom2
          nDoprOps+=nPom
        else
          Rekapld("DOPR"+dopr->id+opsld->idops,cgodina,cmjesec,npom,nBOOps,idops,NLjudi())
          nDoprOps+=nPom
        endif
        nOOD += nBOOps
        nPOLjudi += ljudi
        skip
        if prow()>62+gPStranica; FF; endif
      enddo // opsld
      select dopr
      ? cLinija
      ? "UKUPNO ",DOPR->ID
//      @ prow(),nC1 SAY nBO pict gpici
      @ prow(),nC1 SAY nOOD pict gpici
      @ prow(),pcol()+1 SAY nDoprOps pict gpici
      if cUmPD=="D"
        @ prow(),pcol()+1 SAY nDoprOps2 pict gpici
        @ prow(),pcol()+1 SAY nDoprOps-nDoprOps2 pict gpici
        Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nDoprOps-nDoprOps2,0,,NLjudi())
        nPom2:=nDoprOps2
      else
        if nDoprOps>0
//          Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nDoprOps,nBO,,NLjudi())
          Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nDoprOps,nOOD,,"("+ALLTRIM(STR(nPOLjudi))+")")
        endif
      endif
      ? cLinija
      nPom:=nDoprOps
    else
      // doprinosi nisu po opstinama
      altd()
      if "BENEF" $ dopr->naz
           nBo:=round2(parobr->k3/100*nUBNOsnova,gZaok2)
      else
           nBo:=round2(parobr->k3/100*nUNetoOsnova,gZaok2)
      endif
      @ prow(),nC1 SAY nBO pict gpici
      nPom:=round2(max(dlimit,iznos/100*nBO),gZaok2)
      if cUmPD=="D"
        nPom2:=round2(max(dlimit,iznos/100*nBO2),gZaok2)
      endif
      if round(iznos,4)=0 .and. dlimit>0
          nPom:=dlimit*nljudi      // nije po opstinama
          if cUmPD=="D"
            nPom2:=dlimit*nljudi      // nije po opstinama ?!?nLjudi
          endif
      endif
      @ prow(),pcol()+1 SAY nPom pict gpici
      if cUmPD=="D"
        @ prow(),pcol()+1 SAY nPom2 pict gpici
        @ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
        Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nPom-nPom2,0)
      else
        Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nPom,nBO,,"("+ALLTRIM(STR(nLjudi))+")")
      endif
    endif // poopst
  else
  //**************** po stopama beneficiranog radnog staza ?? nije testirano
    nPom0:=ASCAN(aNeta,{|x| x[1]==idkbenef})
    if nPom0<>0
      nPom2:=parobr->k3/100*aNeta[nPom0,2]
    else
      nPom2:=0
    endif
    if round2(nPom2,gZaok2)<>0
      @ prow(),pcol()+1 SAY nPom2 pict gpici
      nC1:=pcol()+1
      @ prow(),pcol()+1 SAY nPom:=round2(max(dlimit,iznos/100*nPom2),gZaok2) pict gpici
    endif
  endif  // ****************  nije testirano

  if right(id,1)=="X"
    ? cLinija
    IF !lGusto
      ?
    ENDIF
    nDopr+=nPom
    if cUmPD=="D"
      nDopr2+=nPom2
    endif
  endif

  skip
  if prow()>56+gPStranica; FF; endif
enddo
? cLinija 
? "Ukupno Doprinosi"
@ prow(),nc1 SAY space(len(gpici))
@ prow(),pcol()+1 SAY nDopr  pict gpici
if cUmPD=="D"
  @ prow(),pcol()+1 SAY nDopr2  pict gpici
  @ prow(),pcol()+1 SAY nDopr-nDopr2  pict gpici
endif
? cLinija
IF cUmPD=="D"
  P_10CPI
ENDIF
?
?


cLinija:="---------------------------------"
altd()
if prow()>49+gPStranica
	FF
endif
? cLinija
? "     NETO PRIMANJA:"
@ prow(),pcol()+1 SAY nUNeto pict gpici
?? "(za isplatu:"
@ prow(),pcol()+1 SAY nUNeto+nUOdbiciM pict gpici
?? ",Obustave:"
@ prow(),pcol()+1 SAY -nUOdbiciM pict gpici
?? ")"
? " PRIMANJA VAN NETA:"
@ prow(),pcol()+1 SAY nUOdbiciP pict gpici  // dodatna primanja van neta
? "            POREZI:"
IF cUmPD=="D"
	@ prow(),pcol()+1 SAY nPor-nUPorOl-nPor2    pict gpici
ELSE
  	@ prow(),pcol()+1 SAY nPor-nUPorOl    pict gpici
ENDIF
? "         DOPRINOSI:"
IF cUmPD=="D"
  	@ prow(),pcol()+1 SAY nDopr-nDopr2    pict gpici
ELSE
  	@ prow(),pcol()+1 SAY nDopr    pict gpici
ENDIF
? cLinija
IF cUmPD=="D"
  	? " POTREBNA SREDSTVA:"
  	@ prow(),pcol()+1 SAY nUNeto+nUOdbiciP+(nPor-nUPorOl)+nDopr-nPor2-nDopr2    pict gpici
ELSE
  	? " POTREBNA SREDSTVA:"
  	@ prow(),pcol()+1 SAY nUNeto+nUOdbiciP+(nPor-nUPorOl)+nDopr    pict gpici
ENDIF
? cLinija
?
? "Izvrsena obrada na ",str(nLjudi,5),"radnika"
?
if nUSati==0
	nUSati:=999999
endif
? "Prosjecni neto/satu je",alltrim(transform(nUNeto,gpici)),"/",alltrim(str(nUSati)),"=",alltrim(transform(nUNeto/nUsati,gpici)),"*",alltrim(transform(parobr->k1,"999")),"=",alltrim(transform(nUneto/nUsati*parobr->k1,gpici))




ELSE // cMjesec==cMjesecDo // za viçe mjeseci nema prikaza poreza i doprinosa
  // ali se mo§e dobiti bruto osnova i prosjeŸni neto po satu
  // --------------------------------------------------------
  ASORT(aNetoMj,,,{|x,y| x[1]<y[1]})
  ?
  ?     "MJESEC³  UK.NETO  ³UK.SATI³KOEF.BRUTO³FOND SATI³BRUTO OSNOV³PROSJ.NETO "
  ?     " (A)  ³    (B)    ³  (C)  ³   (D)    ³   (E)   ³(B)*(D)/100³(E)*(B)/(C)"
  ? ms:="ÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄ"
  nT1:=nT2:=nT3:=nT4:=nT5:=0
  FOR i:=1 TO LEN(aNetoMj)
    ? STR(aNetoMj[i,1],4,0) +". ³"+;
      TRANS(aNetoMj[i,2],gPicI) +"³"+;
      STR(aNetoMj[i,3],7) +"³"+;
      TRANS(aNetoMj[i,4],"999.99999%") +"³"+;
      STR(aNetoMj[i,5],9) +"³"+;
      TRANS(ROUND2(aNetoMj[i,2]*aNetoMj[i,4]/100,gZaok2),gPicI) +"³"+;
      TRANS(aNetoMj[i,5]*aNetoMj[i,2]/aNetoMj[i,3],gPicI)
      nT1 += aNetoMj[i,2]
      nT2 += aNetoMj[i,3]
      nT3 += aNetoMj[i,5]
      nT4 += ROUND2(aNetoMj[i,2]*aNetoMj[i,4]/100,gZaok2)
      nT5 += aNetoMj[i,5]*aNetoMj[i,2]/aNetoMj[i,3]
  NEXT
  altd()
  nT5 := nT5/LEN(aNetoMj)
  // nT5 := nT3*nT1/nT2
  ? ms
  ?     "UKUPNO³"+;
      TRANS(nT1,gPicI) +"³"+;
      STR(nT2,7) +"³"+;
      "          "+"³"+;
      STR(nT3,9) +"³"+;
      TRANS(nT4,gPicI) +"³"+;
      TRANS(nT5,gPicI)

ENDIF

?
P_10CPI
if prow()<62+gPStranica
 nPom:=62+gPStranica-prow()
 for i:=1 to nPom
   ?
 next
endif
?  PADC("     Obradio:                                 Direktor:    ",80)
?
?  PADC("_____________________                    __________________",80)
?
FF
IF lGusto
  gRPL_Normal()
  gPStranica-=nDSGusto
ENDIF
END PRINT
#ifdef CAX
select opsld; use
select rekld; use
select ld
#endif
CLOSERET


function RekapLd(cId,nGodina,nMjesec,nIzn1,nIzn2,cIdPartner,cOpis,cOpis2,lObavDodaj)
*{

if lObavDodaj==nil
	lObavDodaj:=.f.
endif

if cIdPartner=NIL
	cIdPartner=""
endif

if cOpis=nil
	cOpis=""
endif

if cOpis2=nil
  	cOpis2=""
endif

pushwa()

select rekld
if lObavDodaj
	append blank
else
  	seek str(nGodina,4)+str(nMjesec,2)+cId+" "
  	if !found()
       		append blank
  	endif
endif

replace godina with str(nGodina,4),mjesec with str(nMjesec,2),;
        id    with  cId,;
        iznos1 with nIzn1, iznos2 with nIzn2,;
        idpartner with cIdPartner,;
        opis with cOpis ,;
        opis2 with cOpis2

popwa()

return
*}


// Otvara potrebne tabele za kreiranje izvjestaja rekapitulacije
function ORekap()
*{
O_POR
O_DOPR
O_PAROBR
O_RJ
O_RADN
O_STRSPR
O_KBENEF
O_VPOSLA
O_OPS
O_RADKR
O_KRED
O_LD
if lViseObr
	O_TIPPRN
else
	O_TIPPR
endif

return
*}



function BoxRekSvi()
*{
local nArr

nArr:=SELECT()

Box(,10+IF(IsRamaGlas(),1,0),75)
	do while .t.
		@ m_x+3,m_y+2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
		@ m_x+4,m_y+2 SAY "Za mjesece od:"  GET  cmjesec  pict "99" VALID {|| cMjesecDo:=cMjesec,.t.}
		@ m_x+4,col()+2 SAY "do:"  GET  cMjesecDo  pict "99" VALID cMjesecDo>=cMjesec
		if lViseObr
			@ m_x+4,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
		endif
		@ m_x+5,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
		@ m_x+7,m_y+2 SAY "Strucna Sprema: "  GET  cStrSpr pict "@!" valid empty(cStrSpr) .or. P_StrSpr(@cStrSpr)
		@ m_x+8,m_y+2 SAY "Opstina stanovanja: "  GET  cOpsSt pict "@!" valid empty(cOpsSt) .or. P_Ops(@cOpsSt)
		@ m_x+9,m_y+2 SAY "Opstina rada:       "  GET  cOpsRad  pict "@!" valid empty(cOpsRad) .or. P_Ops(@cOpsRad)
		if (IsRamaGlas())
			@ m_x+10,m_y+2 SAY "Izdvojiti radnike (P-proizvodne,N-neproizvodne,S-sve)" GET cK4 valid cK4$"PNS" pict "@!"
		endif

		read
		
		ClvBox()
		ESC_BCR
		aUsl1:=Parsiraj(qqRJ,"IDRJ")
		aUsl2:=Parsiraj(qqRJ,"ID")
		if aUsl1<>nil .and. aUsl2<>nil
			exit
		endif
	enddo
BoxC()

select (nArr)

return
*}


function BoxRekJ()
*{
local nArr

nArr:=SELECT()

Box(,8+IF(IsRamaGlas(),1,0),75)
	@ m_x+2,m_y+2 SAY "Radna jedinica: "  GET cIdRJ
	@ m_x+3,m_y+2 SAY "Za mjesece od:"  GET  cmjesec  pict "99" VALID {|| cMjesecDo:=cMjesec,.t.}
	@ m_x+3,col()+2 SAY "do:"  GET  cMjesecDo  pict "99" VALID cMjesecDo>=cMjesec
	if lViseObr
   		@ m_x+3,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
 	endif
 	@ m_x+4,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
 	@ m_x+6,m_y+2 SAY "Strucna Sprema: "  GET  cStrSpr pict "@!" valid empty(cStrSpr) .or. P_StrSpr(@cStrSpr)
 	@ m_x+7,m_y+2 SAY "Opstina stanovanja: "  GET  cOpsSt pict "@!" valid empty(cOpsSt) .or. P_Ops(@cOpsSt)
 	@ m_x+8,m_y+2 SAY "Opstina rada:       "  GET  cOpsRad  pict "@!" valid empty(cOpsRad) .or. P_Ops(@cOpsRad)
	if (IsRamaGlas())
		@ m_x+9,m_y+2 SAY "Izdvojiti radnike (P-proizvodne,N-neproizvodne,S-sve)" GET cK4 valid cK4$"PNS" pict "@!"
	endif
 	read
	ClvBox()
	ESC_BCR
BoxC()

select (nArr)

return
*}


// Kreira pomocnu tabelu REKLD.DBF
function CreRekLD()
*{

aDbf:={{"GODINA"     ,  "C" ,  4, 0} ,;
       {"MJESEC"     ,  "C" ,  2, 0} ,;
       {"ID"         ,  "C" , 30, 0} ,;
       {"opis"       ,  "C" , 20, 0} ,;
       {"opis2"      ,  "C" , 35, 0} ,;
       {"iznos1"     ,  "N" , 25, 4} ,;
       {"iznos2"     ,  "N" , 25, 4} ,;
       {"idpartner"  ,  "C" ,  6, 0}}

DBCREATE2(KUMPATH+"REKLD",aDbf)

select (F_REKLD)
usex (KUMPATH+"rekld")

index ON  BRISANO+"10" TAG "BRISAN"
index on  godina+mjesec+id  tag "1"

set order to tag "1"
use

return
*}


// Kreira pomocnu tabelu OPSLD.DBF
function CreOpsLD()
*{

aDbf:={{"ID"    ,"C", 1,0},;
       {"IDOPS" ,"C", 4,0},;
       {"IZNOS" ,"N",25,4},;
       {"IZNOS2","N",25,4},;
       {"LJUDI" ,"N", 10,0}}

//id- 1 opsstan
//id- 2 opsrad

DBCreate2(PRIVPATH + "opsld",aDbf)


select(F_OPSLD)
usex (PRIVPATH+"opsld")

INDEX ON ID+IDOPS tag "1"
index ON  BRISANO TAG "BRISAN"
use

return
*}


// Popunjava tabelu OPSLD
function PopuniOpsLD()
*{

select ops
seek radn->idopsst
select opsld
seek "1"+radn->idopsst

if Found()
	replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
else
	append blank
	replace id with "1", idops with radn->idopsst, iznos with _ouneto,iznos2 with iznos2+nPorOl, ljudi with 1
endif
		
seek "3"+ops->idkan

if found()
	replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 		else
   			append blank
   			replace id with "3", idops with ops->idkan, iznos with _ouneto,iznos2 with iznos2+nPorOl, ljudi with 1
 		endif
 		seek "5"+ops->idn0
 		if found()
   			replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 		else
   			append blank
   			replace id with "5", idops with ops->idn0, iznos with _ouneto,iznos2 with iznos2+nPorOl, ljudi with 1
 		endif
 		select ops
		seek radn->idopsrad
 		select opsld
 		seek "2"+radn->idopsrad
 		if found()
   			replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl , ljudi with ljudi+1
 		else
   			append blank
   			replace id with "2", idops with radn->idopsrad, iznos with _ouneto,iznos2 with iznos2+nPorOl, ljudi with 1
 		endif
 		seek "4"+ops->idkan
 		if found()
   			replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 		else
   			append blank
   			replace id with "4", idops with ops->idkan, iznos with _ouneto,iznos2 with iznos2+nPorOl, ljudi with 1
 		endif
 		seek "6"+ops->idn0
 		if found()
   			replace iznos with iznos+_ouneto, iznos2 with iznos2+nPorOl, ljudi with ljudi+1
 		else
   			append blank
   			replace id with "6", idops with ops->idn0, iznos with _ouneto,iznos2 with iznos2+nPorOl, ljudi with 1
 		endif
 		select ld
 		//*************************




return
*}


function VrtiSeULD(fSvi)
*{

nPorOl:=0
nUPorOl:=0
aNetoMj:={}

altd()
do while !eof() .and. eval(bUSlov)
	// vrti se u bazi LD.DBF
 	if lViseObr .and. EMPTY(cObracun)
   		ScatterS(godina,mjesec,idrj,idradn)
 	else
   		Scatter()
 	endif

 	select radn
	hseek _idradn
 	select vposla
	hseek _idvposla

 	if (!empty(copsst) .and. copsst<>radn->idopsst) .or. (!empty(copsrad) .and. copsrad<>radn->idopsrad)
   		select ld
   		skip 1
		loop
 	endif

	if (IsRamaGlas() .and. cK4<>"S")
		if (cK4="P".and.!radn->k4="P" .or. cK4="N".and.radn->k4="P")
			select ld
			skip 1
			loop
		endif
	endif

 	_ouneto:=MAX(_uneto,PAROBR->prosld*gPDLimit/100)
 
 	select por
	go top
 	nPor:=nPorOl:=0
 	do while !eof()  // datoteka por
   		PozicOps(POR->poopst)
   		if !ImaUOp("POR",POR->id)
     			SKIP 1
			LOOP
   		endif
   		nPor+=round2(max(dlimit,iznos/100*_oUNeto),gZaok2)
   		skip
 	enddo
 	if radn->porol<>0 .and. gDaPorOl=="D" .and. !Obr2_9() // poreska olaksica
   		if alltrim(cVarPorOl)=="2"
     			nPorOl:=RADN->porol
   		elseif alltrim(cVarPorol)=="1"
     			nPorOl:=round(parobr->prosld*radn->porol/100,gZaok)
   		else
     			nPorOl:= &("_I"+cVarPorol)
   		endif
   		if nPorOl>nPor 
			// poreska olaksica ne moze biti veca od poreza
     			nPorOl:=nPor
   		endif
   			nUPorOl+=nPorOl
 	endif

	PopuniOpsLD()

	nPom:=ASCAN(aNeta,{|x| x[1]==vposla->idkbenef})
 	if nPom==0
    		AADD(aNeta,{vposla->idkbenef,_oUNeto})
 	else
    		aNeta[nPom,2]+=_oUNeto
 	endif

 	for i:=1 to cLDPolja
  		cPom:=padl(alltrim(str(i)),2,"0")
  		select tippr
		seek cPom
		select ld
  		aRekap[i,1]+=_s&cPom  // sati
  		nIznos:=_i&cPom
  
  		aRekap[i,2]+=nIznos  // iznos
  		if tippr->uneto=="N" .and. nIznos<>0
  			if nIznos>0
  				nUOdbiciP+=nIznos
  			else
  				nUOdbiciM+=nIznos
  			endif
  		endif
 	next
	++nLjudi
	nUSati+=_USati   // ukupno sati
	nUNeto+=_UNeto  // ukupno neto iznos
	
	nUNetoOsnova+=_oUNeto  // ukupno neto osnova za obracun por.i dopr.
	
	if UBenefOsnovu()
		nUBNOsnova+=_oUNeto
	endif

	cTR := IF( RADN->isplata$"TR#SK", RADN->idbanka,;
                                 SPACE(LEN(RADN->idbanka)) )

	IF LEN(aUkTR)>0 .and. ( nPomTR := ASCAN( aUkTr , {|x| x[1]==cTR} ) ) > 0
   		aUkTR[nPomTR,2] += _uiznos
 	ELSE
   		AADD( aUkTR , { cTR , _uiznos } )
 	ENDIF

 	nUIznos+=_UIznos  // ukupno iznos
	nUOdbici+=_UOdbici  // ukupno odbici

	IF cMjesec<>cMjesecDo
		altd()
		nPom:=ASCAN(aNetoMj,{|x| x[1]==mjesec})
		IF nPom>0
			aNetoMj[nPom,2] += _uneto
			aNetoMj[nPom,3] += _usati
		ELSE
			nTObl:=SELECT()
			nTRec := PAROBR->(RECNO())
			ParObr(mjesec,IF(lViseObr,cObracun,),IF(!fSvi,cIdRj,))      // samo pozicionira bazu PAROBR na odgovaraju†i zapis
			AADD(aNetoMj,{mjesec,_uneto,_usati,PAROBR->k3,PAROBR->k1})
			SELECT PAROBR
			GO (nTRec)
			SELECT (nTObl)
		ENDIF
	ENDIF

	IF RADN->isplata=="TR"  // isplata na tekuci racun
		Rekapld( "IS_"+RADN->idbanka , cgodina , cmjesecDo ,_UIznos , 0 , RADN->idbanka , RADN->brtekr , RADNIK , .t. )
	ENDIF
	select ld
	skip
enddo
	// vrti se u bazi LD.DBF *******

return
*}


function ZaglSvi()
*{

	select por
 	go top
	O_RJ
	select rj
 	? "Obuhvacene radne jedinice: "
 	IF !EMPTY(qqRJ)
  		SET FILTER TO &aUsl2
  		GO TOP
  		DO WHILE !EOF()
   			?? id+" - "+naz
   			? SPACE(27)
   			SKIP 1
  		ENDDO
 	ELSE
  		?? "SVE"
  		?
 	ENDIF
 
 	B_ON
 
 	IF cMjesec==cMjesecDo
   ? "Firma:",gNFirma,"  Mjesec:",str(cmjesec,2)+IspisObr()
   ?? "    Godina:", str(cGodina,4)
   B_OFF
   ? IF(gBodK=="1","Vrijednost boda:","Vr.koeficijenta:"), transform(parobr->vrbod,"99999.99999")
 ELSE
   ? "Firma:",gNFirma,"  Za mjesece od:",str(cmjesec,2),"do",str(cmjesecDo,2)+IspisObr()
   ?? "    Godina:", str(cGodina,4)
   B_OFF
   // ? IF(gBodK=="1","Vrijednost boda:","Vr.koeficijenta:"), transform(parobr->vrbod,"99999.99999")
 ENDIF
 ?


return
*}


function ZaglJ()
*{
O_RJ
select rj
hseek cIdRj
select por
go top
select ld
?
B_ON
if cMjesec==cMjesecDo
	? "RJ:",cidrj,rj->naz,"  Mjesec:",str(cmjesec,2)+IspisObr()
   	?? "    Godina:", str(cGodina,4)
   	B_OFF
     	? if(gBodK=="1","Vrijednost boda:","Vr.koeficijenta:"), transform(parobr->vrbod,"99999.99999")
else
   	? "RJ:",cidrj,rj->naz,"  Za mjesece od:",str(cmjesec,2),"do",str(cmjesecDo,2)+IspisObr()
   	?? "    Godina:", str(cGodina,4)
   	B_OFF
endif

?

return
*}


function IspisTP(fSvi)
*{

cUNeto:="D"

for i:=1 to cLDPolja
	if prow()>55+gPStranica
    		FF
  	endif
	//********************* 90 - ke
  	cPom:=padl(alltrim(str(i)),2,"0")
  	_s&cPom:=aRekap[i,1]   // nafiluj ove varijable radi prora~una dodatnih stavki
  	_i&cPom:=aRekap[i,2]
  	//**********************

  	cPom:=padl(alltrim(str(i)),2,"0")
  	select tippr
	seek cPom
  	if tippr->uneto=="N" .and. cUneto=="D"
    		cUneto:="N"
    		? cLinija
    		if !lPorNaRekap
       			? "UKUPNO NETO:"
			@ prow(),nC1+8  SAY  nUSati  pict gpics
			?? " sati"
       			@ prow(),60 SAY nUNeto pict gpici
			?? "",gValuta
    		else
       			? "UKUPNO NETO:"
			@ prow(),nC1+5  SAY  nUSati  pict gpics
			?? " sati"
       			@ prow(),42 SAY nUNeto pict gpici; ?? "",gValuta
       			@ prow(),60 SAY nUNeto*(por->iznos/100) pict gpici
			?? "",gValuta
    		endif
    		// ****** radi 90 - ke
    		_UNeto:=nUNeto
    		_USati:=nUSati
    		//***********
    		? cLinija
  	endif

	if tippr->(found()) .and. tippr->aktivan=="D" .and. (aRekap[i,2]<>0 .or. aRekap[i,1]<>0)
        	cTPNaz:=tippr->naz
  		? tippr->id+"-"+cTPNaz
  		nC1:=pcol()
  		if !lPorNaRekap
   			if tippr->fiksan $ "DN"
     				@ prow(),pcol()+8 SAY aRekap[i,1]  pict gpics; ?? " s"
     				@ prow(),60 say aRekap[i,2]      pict gpici
   			elseif tippr->fiksan=="P"
     				@ prow(),pcol()+8 SAY aRekap[i,1]/nLjudi pict "999.99%"
     				@ prow(),60 say aRekap[i,2]        pict gpici
   			elseif tippr->fiksan=="C"
     				@ prow(),60 say aRekap[i,2]        pict gpici
   			elseif tippr->fiksan=="B"
    				@ prow(),pcol()+8 SAY aRekap[i,1] pict "999999"; ?? " b"
     				@ prow(),60 say aRekap[i,2]      pict gpici
   			endif
  		else
   			if tippr->fiksan $ "DN"
     				@ prow(),pcol()+5 SAY aRekap[i,1]  pict gpics; ?? " s"
     				@ prow(),42 say aRekap[i,2]      pict gpici
     				if tippr->uneto=="D"
        				@ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     				endif
   			elseif tippr->fiksan=="P"
     				@ prow(),pcol()+4 SAY aRekap[i,1]/nLjudi pict "999.99%"
     				@ prow(),42 say aRekap[i,2]        pict gpici
     				if tippr->uneto=="D"
        				@ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     				endif
   			elseif tippr->fiksan=="C"
     				@ prow(),42 say aRekap[i,2]        pict gpici
     					if tippr->uneto=="D"
        					@ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     					endif
   			elseif tippr->fiksan=="B"
     				@ prow(),pcol()+4 SAY aRekap[i,1] pict "999999"; ?? " b"
     				@ prow(),42 say aRekap[i,2]      pict gpici
     				if tippr->uneto=="D"
        				@ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     				endif
   			endif
  		endif
   		IF cMjesec==cMjesecDo
     			Rekapld("PRIM"+tippr->id,cgodina,cmjesec,aRekap[i,2],aRekap[i,1])
   		ELSE
     			Rekapld("PRIM"+tippr->id,cgodina,cMjesecDo,aRekap[i,2],aRekap[i,1])
   		ENDIF

		IspisKred(fSvi)
	endif

next

return
*}


function IspisKred(fSvi)
*{
if "SUMKREDITA" $ tippr->formula
	if gReKrOs=="X"
        	? cLinija
        	? "  ","Od toga pojedinacni krediti:"
        	SELECT RADKR
		SET ORDER TO TAG "3"
        	SET FILTER TO STR(cGodina,4)+STR(cMjesec,2)<=STR(godina,4)+STR(mjesec,2) .and. STR(cGodina,4)+STR(cMjesecDo,2)>=STR(godina,4)+STR(mjesec,2)
        	GO TOP
        	DO WHILE !EOF()
          		cIdKred:=IDKRED
          		SELECT KRED; HSEEK cIdKred; SELECT RADKR
          		nUkKred := 0
          		DO WHILE !EOF() .and. IDKRED==cIdKred
            			cNaOsnovu:=NAOSNOVU; cIdRadnKR:=IDRADN
            			SELECT RADN; HSEEK cIdRadnKR; SELECT RADKR
            			cOpis2   := RADNIK
            			nUkKrRad := 0
            			DO WHILE !EOF() .and. IDKRED==cIdKred .and. cNaOsnovu==NAOSNOVU .and. cIdRadnKR==IDRADN
              				mj:=mjesec
              				if fSvi
               					select ld
						set order to tag (TagVO("2"))
						hseek  str(cGodina,4)+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
               					//"LDi2","str(godina)+str(mjesec)+idradn"
              				else
                				select ld
						hseek  str(cGodina,4)+cidrj+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
              				endif // fsvi
              				select radkr
              				if ld->(found())
                				nUkKred  += iznos
                				nUkKrRad += iznos
              				endif
              				SKIP 1
            			ENDDO
            			if nUkKrRad<>0
              				Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cmjesecDo,nUkKrRad,0,cidkred,cnaosnovu,cOpis2,.t.)
            			endif
          		ENDDO
          		IF nUkKred<>0    // ispisati kreditora
            			if prow()>55+gPStranica
              				FF
            			endif
            			? "  ",cidkred,left(kred->naz,22)
            			@ prow(),58 SAY nUkKred  pict "("+gpici+")"
          		ENDIF
        	ENDDO
      	else
        	? cLinija
        	? "  ","Od toga pojedinacni krediti:"
        	cOpis2:=""
        	select radkr
		set order to 3 
		go top
       		//"RADKRi3","idkred+naosnovu+idradn+str(godina)+str(mjesec)","RADKR")
        	do while !eof()
        		select kred
			hseek radkr->idkred 
			select radkr
         		private cidkred:=idkred, cNaOsnovu:=naosnovu
         		select radn; hseek radkr->idradn; select radkr
         		cOpis2:= RADNIK
         		seek cidkred+cnaosnovu
         		private nUkKred:=0
         		do while !eof() .and. idkred==cidkred .and. ( cnaosnovu==naosnovu .or. gReKrOs=="N" )
          			if fSvi
           				select ld
					set order to tag (TagVO("2"))
					hseek  str(cGodina,4)+str(cmjesec,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
           				//"LDi2","str(godina)+str(mjesec)+idradn"
          			else
            				select ld
					hseek  str(cGodina,4)+cidrj+str(cmjesec,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
          			endif // fsvi
          			select radkr
          			if ld->(found()) .and. godina==cgodina .and. mjesec=cmjesec
            				nUkKred+=iznos
          			endif
          			IF cMjesecDo>cMjesec
            				FOR mj:=cMjesec+1 TO cMjesecDo
              					if fSvi
               						select ld
							set order to tag (TagVO("2"))
							hseek  str(cGodina,4)+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
               						//"LDi2","str(godina)+str(mjesec)+idradn"
              					else
                					select ld
							hseek  str(cGodina,4)+cidrj+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
              					endif // fsvi
              					select radkr
              					if ld->(found()) .and. godina==cgodina .and. mjesec=mj
                					nUkKred+=iznos
              					endif
            				NEXT
          			ENDIF
          			skip
         		enddo
         		if nukkred<>0
          			if prow()>55+gPStranica
            				FF
          			endif
          			? "  ",cidkred,left(kred->naz,22),IF(gReKrOs=="N","",cnaosnovu)
          			@ prow(),58 SAY nUkKred  pict "("+gpici+")"
          			if cMjesec==cMjesecDo
            				Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cmjesec,nukkred,0,cidkred,cnaosnovu, cOpis2)
          			ELSE
            				Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cMjesecDo,nukkred,0,cidkred,cnaosnovu, cOpis2)
          			ENDIF
         		endif
        	enddo
        	select ld
	endif
endif


return
*}


function PoTekRacunima()
*{
 ? cLinija
  ? "ZA ISPLATU:"
  ? "-----------"
  nMArr:=SELECT()
  SELECT KRED
  ASORT(aUkTr,,,{|x,y| x[1]<y[1]})
  FOR i:=1 TO LEN(aUkTR)
    IF EMPTY(aUkTR[i,1])
      ? PADR("B L A G A J N A",LEN(aUkTR[i,1]+KRED->naz)+1)
    ELSE
      HSEEK aUkTR[i,1]
      ? aUkTR[i,1], KRED->naz
    ENDIF
    @ prow(),60 SAY aUkTR[i,2] pict gpici; ?? "",gValuta
  NEXT
  SELECT (nMArr)


return
*}



function ProizvTP()
*{


// proizvoljni redovi pocinju sa "9"

select tippr
seek "9"

do while !eof() .and. left(id,1)="9"
	if prow()>55+gPStranica
    		FF
  	endif
  	? tippr->id+"-"+tippr->naz
	cPom:=tippr->formula
	if !lPorNaRekap
     		@ prow(),60 say round2(&cPom,gZaok2) pict gpici
  	else
     		@ prow(),42 say round2(&cPom,gZaok2) pict gpici
  	endif
  	if cMjesec==cMjesecDo
    		Rekapld("PRIM"+tippr->id,cgodina,cmjesec,round2(&cpom,gZaok2),0)
  	else
    		Rekapld("PRIM"+tippr->id,cgodina,cMjesecDo,round2(&cpom,gZaok2),0)
  	endif
  	
	skip
  	
	if eof() .or. !left(id,1)="9"
    		? cLinija
  	endif
enddo



return
*}

function PrikKBO()
*{
nBO:=0
? "Koef. Bruto osnove (KBO):",transform(parobr->k3,"999.99999%")
?? space(1),"BRUTO OSNOVA = NETO OSNOVA*KBO ="
@ prow(),pcol()+1 SAY nBo:=round2(parobr->k3/100*nUNetoOsnova,gZaok2) pict gpici
?
return
*}


function PrikKBOBenef()
*{
if nUBNOsnova == 0
	return
endif

nBO:=0
? "Koef. Bruto osnove benef.(KBO):",transform(parobr->k3,"999.99999%")
? space(3),"BRUTO OSNOVA = NETO OSNOVA.BENEF * KBO ="
@ prow(),pcol()+1 SAY nBo:=round2(parobr->k3/100*nUBNOsnova,gZaok2) pict gpici
?
return
*}


function UBenefOsnovu()
*{
if radn->k4 == "BF"
	if !EMPTY(gBFForm) .and. ROUND(&gBFForm,4) == 0
		return .t.
	endif
endif

return .f.
*}


