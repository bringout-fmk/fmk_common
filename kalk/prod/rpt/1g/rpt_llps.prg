#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_llps.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: rpt_llps.prg,v $
 * Revision 1.5  2003/07/02 07:36:44  ernad
 * Planika - llp, llps, dodatni uslov za artikal "NAZ $ &*"
 *
 * Revision 1.4  2003/06/06 14:38:10  sasa
 * dodat uslov Prikaz ERR, uvedena varijabla cERR
 *
 * Revision 1.3  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.2  2002/06/21 12:12:35  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_llps.prg
 *  \brief Izvjestaj "lager lista sinteticki"
 */


/*! \fn LLPS()
 *  \brief Izvjestaj "lager lista sinteticki"
 */

function LLPS()
*{
cIdFirma:=gFirma
qqKonto:=padr("132;",60)
if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK
   O_SIFV
endif
O_ROBA
O_KONTO
O_PARTN

dDatOd:=ctod("")
dDatDo:=date()
qqRoba:=space(60)
qqTarifa:=qqidvd:=space(60)
private cERR:="D"
private cPNab:="N"
private cNula:="D",cTU:="N"
private cPredhStanje:="N"
Box(,12,66)
cGrupacija:=space(4)
do while .t.
 if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+1,m_y+2 SAY "Firma  " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+2,m_y+2 SAY "Prodavnice" GET qqKonto  pict "@!S50"
 @ m_x+3,m_y+2 SAY "Artikli   " GET qqRoba pict "@!S50"
 @ m_x+4,m_y+2 SAY "Tarife    " GET qqTarifa pict "@!S50"
 @ m_x+5,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 @ m_x+6,m_y+2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  valid cpnab $ "DN" pict "@!"
 @ m_x+7,m_y+2 SAY "Prikaz stavki kojima je MPV 0 D/N" GET cNula  valid cNula $ "DN" pict "@!"
 @ m_x+8,m_y+2 SAY "Prikaz ERR D/N" GET cERR  valid cERR $ "DN" pict "@!"
 @ m_x+9,m_y+2 SAY "Datum od " GET dDatOd
 @ m_x+9,col()+2 SAY "do" GET dDatDo
 @ m_x+10,m_y+2 SAY "Prikaz robe tipa T/U  (D/N)" GET cTU valid cTU $ "DN" pict "@!"
 @ m_x+12,m_y+2 SAY "Odabir grupacije (prazno-svi) GET" GET cGrupacija pict "@!"
 read; ESC_BCR
 private aUsl1:=Parsiraj(qqRoba,"IdRoba")
 private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 private aUsl3:=Parsiraj(qqIDVD,"idvd")
 private aUsl4:=Parsiraj(qqkonto,"pkonto")
 if aUsl1<>NIL
 	exit
 endif
 if aUsl2<>NIL
 	exit
 endif
 if aUsl3<>NIL
 	exit
 endif
enddo
BoxC()

O_KONCIJ
O_KALKREP

PRIVATE cFilt1:=""
cFilt1 := "!EMPTY(pu_i).and."+aUsl1+".and."+aUsl4
cFilt1 := STRTRAN(cFilt1,".t..and.","")
IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

select kalk
set order to 6
//CREATE_INDEX("6","idFirma+IdTarifa+idroba",KUMPATH+"KALK")
hseek cidfirma
EOF CRET

nLen:=1
m:="----- ---------- -------------------- --- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

start print cret

select kalk

private nTStrana:=0

private bZagl:={|| ZaglLLP(.t.)}

nTUlaz:=nTIzlaz:=0
nTMPVU:=nTMPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
nCol1:=nCol0:=50
nRbr:=0


private fSMark:=.f.
if right(trim(qqRoba),1)="*"
  fSMark:=.t.
endif


Eval(bZagl)
do while !eof() .and. cidfirma==idfirma .and.  IspitajPrekid()

cIdRoba:=Idroba
select roba
hseek cidroba
select kalk
nUlaz:=nIzlaz:=0
nMPVU:=nMPVI:=nNVU:=nNVI:=0
nRabat:=0


if fSMark .and. SkLoNMark("ROBA",cIdroba)
   skip
   loop
endif


if len(aUsl2)<>0
    if !Tacno(aUsl2)
       skip
       loop
    endif
endif

if cTU=="N" .and. roba->tip $ "TU"
	skip
	loop
endif
if !empty(cGrupacija)
  if cGrupacija<>roba->k1
    skip
    loop
  endif
endif
do while !eof() .and. cidfirma+cidroba==idFirma+idroba .and.  IspitajPrekid()

  if !empty(cGrupacija)
    if cGrupacija<>roba->k1
      skip
      loop
    endif
  endif

if fSMark .and. SkLoNMark("ROBA",cIdroba)
   skip
   loop
endif


  if datdok<ddatod .or. datdok>ddatdo
     skip
     loop
  endif
  if cTU=="N" .and. roba->tip $ "TU"
  	skip
	loop
  endif

  if len(aUsl3)<>0
    if !Tacno(aUsl3)
       skip
       loop
    endif
  endif
  if pu_i=="1"
    SumirajKolicinu(field->kolicina,0, @nUlaz, 0)
    nCol1:=pcol()+1
    nMPVU+=mpcsapp*kolicina
    nNVU+=nc*(kolicina)
  elseif pu_i=="5"
    if idvd $ "12#13"
     SumirajKolicinu(-field->kolicina,0, @nUlaz, 0)
     nMPVU-=mpcsapp*kolicina
     nNVU-=nc*kolicina
    else
     
     SumirajKolicinu(0, field->kolicina, 0, @nIzlaz)
     nMPVI+=mpcsapp*kolicina
     nNVI+=nc*kolicina
    endif

  elseif pu_i=="3"    
    // nivelacija
    nMPVU+=mpcsapp*kolicina
  elseif pu_i=="I"
    SumirajKolicinu(0, field->gkolicin2, 0, @nIzlaz)
    nMPVI+=mpcsapp*gkolicin2
    nNVI+=nc*gkolicin2

  endif

  skip
enddo

NovaStrana(bZagl)
select roba
hseek cidroba
select kalk
aNaz:=Sjecistr(roba->naz,20)

? str(++nrbr,4)+".",cidroba
nCr:=pcol()+1
@ prow(),pcol()+1 SAY aNaz[1]
@ prow(),pcol()+1 SAY roba->jmj
nCol0:=pcol()+1
@ prow(),pcol()+1 SAY nUlaz pict gpickol
@ prow(),pcol()+1 SAY nIzlaz pict gpickol
@ prow(),pcol()+1 SAY nUlaz-nIzlaz pict gpickol

nCol1:=pcol()+1
@ prow(),pcol()+1 SAY nMPVU pict gpicdem
@ prow(),pcol()+1 SAY nMPVI pict gpicdem

@ prow(),pcol()+1 SAY nMPVU-NMPVI pict gpicdem

select roba
hseek cidroba
_mpc:=UzmiMPCSif()
select kalk

if round(nUlaz-nIzlaz,4)<>0
	@ prow(),pcol()+1 SAY (nMPVU-nMPVI)/(nUlaz-nIzlaz) pict gpiccdem
 	if round((nMPVU-nMPVI)/(nUlaz-nIzlaz),4)<>round(_mpc,4)
   		if (cERR=="D")
			?? " ERR"
		endif
 	endif
else
	@ prow(),pcol()+1 SAY 0 pict gpicdem
 	if round((nMPVU-nMPVI),4)<>0
   		?? " ERR"
 	endif
endif


@ prow()+1,0 SAY ""
if len(aNaz)==2
 @ prow(),nCR  SAY aNaz[2]
endif
if cPnab=="D"
 @ prow(),ncol0    SAY space(len(gpickol))
 @ prow(),pcol()+1 SAY space(len(gpickol))
 if round(nulaz-nizlaz,4)<>0
  @ prow(),pcol()+1 SAY (nNVU-nNVI)/(nUlaz-nIzlaz) pict gpicdem
 endif
 @ prow(),nCol1 SAY nNVU pict gpicdem
// @ prow(),pcol()+1 SAY space(len(gpicdem))
 @ prow(),pcol()+1 SAY nNVI pict gpicdem
 @ prow(),pcol()+1 SAY nNVU-nNVI pict gpicdem
 @ prow(),pcol()+1 SAY _MPC pict gpiccdem
endif
nTULaz+=nUlaz
nTIzlaz+=nIzlaz
nTMPVU+=nMPVU
nTMPVI+=nMPVI
nTNVU+=nNVU
nTNVI+=nNVI
nTRabat+=nRabat
enddo

NovaStrana(bZagl, 3)
? m
? "UKUPNO:"
@ prow(),nCol0 SAY ntUlaz pict gpickol
@ prow(),pcol()+1 SAY ntIzlaz pict gpickol
@ prow(),pcol()+1 SAY ntUlaz-ntIzlaz pict gpickol
nCol1:=pcol()+1
@ prow(),pcol()+1 SAY ntMPVU pict gpicdem
@ prow(),pcol()+1 SAY ntMPVI pict gpicdem
@ prow(),pcol()+1 SAY ntMPVU-NtMPVI pict gpicdem

if cpnab=="D"
@ prow()+1,nCol1 SAY ntNVU pict gpicdem
@ prow(),pcol()+1 SAY ntNVI pict gpicdem
@ prow(),pcol()+1 SAY ntNVU-ntNVI pict gpicdem
endif
? m
FF
end print

#ifdef CAX
if gKalks
 	select kalk
	use
endif
#endif
closeret
return
*}

