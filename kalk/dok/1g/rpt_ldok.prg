#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/dok/1g/rpt_ldok.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: rpt_ldok.prg,v $
 * Revision 1.5  2003/07/21 08:35:07  mirsad
 * varijanta koristenja polja UKSTAVKI u DOKS u koje se upisuje broj stavki dokumenta
 *
 * Revision 1.4  2003/07/21 08:10:12  mirsad
 * varijanta koristenja polja UKSTAVKI u DOKS u koje se upisuje broj stavki dokumenta
 *
 * Revision 1.3  2003/06/25 17:48:40  mirsad
 * 1) vraæanje u f-ju 15-ke
 *
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */


/*! \file fmk/kalk/dok/1g/rpt_ldok.prg
 *  \brief Stampa liste dokumenata
 */


/*! \fn StDoks()
 *  \brief Centralna funkcija koja poziva funkciju stampe liste dokumenata
 */

function StDoks()
*{
local nCol1:=0,cImeKup
local cidfirma
local nul,nizl,nRbr
local m
private qqTipDok

private ddatod,ddatdo
O_DOKS
if reccount2()==0
 GenDoks()
endif
close all
SStDoks()
return
*}


/*! \fn SStDoks()
 *  \brief Stampa liste dokumenata
 */

function SStDoks()
*{
local lImaUkSt:=.f.
O_DOKS
O_PARTN
O_KALK

cIdfirma:=gFirma
dDatOd:=ctod("")
dDatDo:=date()
qqVD=""
Box(,9,75)
private cStampaj:="N"
qqBrDok:=""
O_PARAMS
private cSection:="N",cHistory:=" "; aHistory:={}
Params1()
RPar("c1",@cIdFirma)
RPar("c2",@qqVD)
RPar("c3",@qqBrDok)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)

qqVD:=padr(qqVD,2)
qqBrDok:=PADR(qqBrDok,60)

cImeKup:=space(20)
cIdPartner:=space(6)
do while .t.
 if gNW=="X"
   cIdFirma:=padr(cidfirma,2)
   @ m_x+1,m_y+2 SAY "Firma - prazno svi" GET cIdFirma valid {|| .t. }
   read
 endif
 if !empty(cidfirma)
    @ m_x+2,m_y+2 SAY "Tip dokumenta (prazno svi tipovi)" GET qqVD pict "@!"
    qqVD:="  "
 else
    cIdfirma:=""
 endif
 @ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
 @ m_x+3,col()+1 SAY "do"  get dDatDo
 @ m_x+5,m_y+2 SAY "Partner"  get cIdPartner pict "@!" valid empty(cidpartner) .or. P_Firma(@cIdPartner)
 @ m_x+7,m_y+2 SAY "Brojevi dokumenata (prazno-svi)" GET qqBrDok PICT "@!S40"
 @ m_x+9,m_y+2 SAY "Izvrsiti stampanje sadrzaja ovih dokumenata ?"  get cStampaj pict "@!" valid cStampaj$"DN"
 read
 ESC_BCR
 aUsl1:=Parsiraj(qqBrDok,"BRDOK")
 if aUsl1<>NIL; exit; endif
enddo

qqVD:=trim(qqVD)
qqBrDok:=TRIM(qqBrDok)
Params2()
WPar("c1",cIdFirma)
WPar("c2",qqVD)
WPar("c3",qqBrDok)
WPar("d1",dDatOd)
WPar("d2",dDatDo)
select params; use

BoxC()

select doks

if fieldpos("ukstavki")<>0
	lImaUkSt:=.t.
endif

private cFilt:=".t."

if !empty(dDatOd) .or. !empty(dDatDo)
 cFilt+=".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
endif
if !empty(qqVD)
  cFilt+=".and. idvd=="+cm2str(qqVD)
endif
if !empty(cIdPartner)
  cFilt+=".and. idpartner=="+cm2str(cIdPartner)
endif
if !empty(qqBrDok)
  cFilt+=(".and."+aUsl1)
endif
set filter to &cFilt

qqVD:=trim(qqVD)

seek cIdFirma+qqVD

if cStampaj=="D"
   Stkalk(.t.,"IZDOKS")
   closeret
endif

EOF CRET


gaZagFix:={6,3}
START PRINT CRET

Preduzece()
if gduzkonto>7
 P_COND2
else
 P_COND
endif
?? "KALK: Stampa dokumenata na dan:",date(),space(10),"za period",dDatOd,"-",dDatDo
if !empty(qqVD); ?? space(2),"za tipove dokumenta:",trim(qqVD); endif
if !empty(qqBrDok); ?? space(2),"za brojeve dokumenta:",trim(qqBrDok); endif
m:="----- -------- -------------- "+replicate("-",gDuzKonto)+" "+replicate("-",gDuzKonto)+" ------- ------ ----- ------------ ------------ ------------ ------------"
if fieldpos("sifra")<>0
   m+=" ------"
endif
if lImaUkSt
   m+=" ------"
endif

? m
? "  Rbr  DatDok      DOKUMENT    "+padc("M-konto",gduzkonto)+;
  " "+padc("P-konto",gduzkonto)+" Partner ZAD   ZAD2      NV          VPV          RABATV         MPV"
if fieldpos("sifra")<>0
   ?? "      Op.  "
endif
if lImaUkSt
   ?? " Stavki"
endif

? m

nC:=0
nCol1:=30
nNV:=nVPV:=nRabat:=nMPV:=0
nUkStavki:=0
do while !eof() .and. IdFirma=cIdFirma
  ? Str(++nC,4)+".",datdok,idfirma+"-"+idVd+"-"+brdok,mkonto,pkonto,idpartner,idzaduz,idzaduz2
  nCol1:=pcol()+1
  @ prow(),pcol()+1 SAY str(nv,12,2)
  @ prow(),pcol()+1 SAY str(vpv,12,2)
  @ prow(),pcol()+1 SAY str(rabat,12,2)
  @ prow(),pcol()+1 SAY str(mpv,12,2)
  
  if fieldpos("sifra")<>0
    @ prow(),pcol()+1 SAY padr(iif(empty(sifra),space(2),left(CryptSC(sifra),2)),6)
  endif
  nNV+=NV
  nVPV+=VPV
  nRabat+=Rabat
  nMPV+=MPV
  if lImaUkSt
	if field->ukStavki==0
		nStavki:=0
		select kalk
		set order to tag "1"
		seek doks->(idFirma+idVd+brDok)
		do while !eof() .and. idFirma+idVd+brDok==doks->(idFirma+idVd+brDok)
			nStavki:=nStavki+1
			skip 1
		enddo
		select doks
		Scatter()
		_ukStavki:=nStavki
		Gather()
	endif
  	nUkStavki+=field->ukStavki
	@ prow(),pcol()+1 SAY str(field->ukStavki,6)
  endif
  skip
enddo

? m
? "UKUPNO "
  @ prow(),nCol1 SAY str(nnv,12,2)
  @ prow(),pcol()+1 SAY str(nvpv,12,2)
  @ prow(),pcol()+1 SAY str(nrabat,12,2)
  @ prow(),pcol()+1 SAY str(nmpv,12,2)

if fieldpos("sifra")<>0
   ?? "       "
endif
if lImaUkSt
	@ prow(),pcol()+1 SAY str(nUkStavki,6)
endif

FF
END PRINT

closeret
return
*}


/*! \fn GenDoks()
 *  \brief Generisanje tabele DOKS na osnovu tabele KALK
 */

function GenDoks()
*{
O_KALK

select kalk
go top
#ifdef PROBA
altd()
#endif

do while !eof()
  select doks
  append blank

  select kalk
  cIDFirma:=idfirma
  private cBrDok:=BrDok,cIdVD:=IdVD,dDatDok:=datdok

  cIdpartner:=idpartner; cmkonto:=mkonto; cpkonto:=pkonto ; cIdZaduz:=idzaduz; cIdzaduz2:=idzaduz2
  select doks
  replace idfirma with cidfirma, brdok with cbrdok,;
          datdok with ddatdok, idvd with cidvd,;
          idpartner with cIdPartner, mkonto with cMKONTO,pkonto with cPKONTO,;
          idzaduz with cidzaduz, idzaduz2 with cidzaduz2,;
          brfaktp with kalk->BrFaktP

  select kalk

  nNV:=nVPV:=nMPV:=nRABAT:=0
  do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
    if mu_i="1"
      nNV+=nc*(kolicina-gkolicina-gkolicin2)
      nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
    elseif mu_i="3"
      nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
    elseif mu_i="5"
      nNV-=nc*(kolicina)
      nVPV-=vpc*(kolicina)
      nRabat+=vpc*rabatv/100*kolicina
    endif

    if pu_i=="1"
     if empty(mu_i)
       nNV+=nc*kolicina
     endif
     nMPV+=mpcsapp*kolicina
    elseif pu_i=="5"
     if empty(mu_i)
      nNV-=nc*kolicina
     endif
     nMPV-=mpcsapp*kolicina
    elseif pu_i=="I"
      nMPV-=mpcsapp*gkolicin2
      nNV-=nc*gkolicin2
    elseif pu_i=="3"
      nMPV+=mpcsapp*kolicina
    endif

    skip
  enddo

  select doks
  replace nv with nnv, vpv with nvpv, rabat with nrabat, mpv with nmpv

  select kalk

enddo

return
*}
