#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/rpt_rekp.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.2 $
 * $Log: rpt_rekp.prg,v $
 * Revision 1.2  2003/11/11 14:06:35  sasavranic
 * Uvodjenje f-je IspisNaDan()
 *
 * Revision 1.1  2002/06/30 08:57:26  ernad
 *
 *
 * Rekapitulacija - planika -> rpt_rekp.prg
 *
 *
 */
 
 
/*! \fn Planika2()
 *  \brief Rekapitulacija za period 
 *  \ingroup Planika
 * \code
 *  Kolone:
 *  R.br; Artikal (id, naz, jmj, tarifa); poc.stanje (kol/iznos); 
 *  prijem (kol/iznos); prodaja (kol/iznos); reklamac (kol/iznos);
 *  stanje (kol/iznos)"
 */
 
function Planika2()
*{
cIdFirma:=gFirma
cIdKonto:=padr("1320",gDuzKonto)
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
private cPNab:="N"
private cNula:="D",cTU:="N"
Box(,12,60)
do while .t.
 if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cIdFirma:=left(cIdFirma,2),.t.}
 endif
 @ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid P_Konto(@cIdKonto)
 @ m_x+3,m_y+2 SAY "Artikli " GET qqRoba pict "@!S50"
 @ m_x+4,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 @ m_x+5,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 @ m_x+6,m_y+2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  valid cpnab $ "DN" pict "@!"
 @ m_x+7,m_y+2 SAY "Prikaz stavki kojima je MPV 0 D/N" GET cNula  valid cNula $ "DN" pict "@!"
 @ m_x+9,m_y+2 SAY "Datum od " GET dDatOd
 @ m_x+9,col()+2 SAY "do" GET dDatDo
 @ m_x+10,m_y+2 SAY "Prikaz robe tipa T/U  (D/N)" GET cTU valid cTU $ "DN" pict "@!"
 read; ESC_BCR
 private aUsl1:=Parsiraj(qqRoba,"IdRoba")
 private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 private aUsl3:=Parsiraj(qqIDVD,"idvd")
 if aUsl1<>nil; exit; endif
 if aUsl2<>nil; exit; endif
 if aUsl3<>nil; exit; endif
enddo
BoxC()

O_KONCIJ
O_KALKREP
if aUsl1==".t."
  set filter to
else
  set filter to &aUsl1
endif

select kalk
set order to 4
//CREATE_INDEX("4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALK")
HSEEK cIdFirma+cIdKonto
EOF CRET

nLen:=1
m:="----- ---------- -------------------- --- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

start print cret
P_COND
select konto; hseek cIdKonto
select kalk

private nTStrana:=0

private bZagl:={|| ZPlanika()}

nTUlaz:=nTIzlaz:=0
nTMPVU:=nTMPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
nCol1:=nCol0:=50
nRbr:=0

Eval(bZagl)

do while !eof() .and. cIdFirma+cIdKonto==idfirma+pkonto .and.  IspitajPrekid()

select roba
hseek cIdRoba
select kalk
nUlaz:=nIzlaz:=0
nMPVU:=nMPVI:=nNVU:=nNVI:=0
nRabat:=0

if len(aUsl2)<>0
    if !Tacno(aUsl2)
       skip
       loop
    endif
endif

if cTU=="N" .and. roba->tip $ "TU"; skip; loop; endif
do while !eof() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+pkonto+idroba .and.  IspitajPrekid()

   if datdok<dDatOd  // predhodno stanje
          if pu_i=="1"
             nPUlaz+=kolicina ; nPMPVU+=mpcsapp*kolicina; nPNVU+=nc*(kolicina)
          elseif pu_i=="5"

            if idvd $ "12#13"
             nPUlaz-=kolicina  ; nPMPVU-=mpcsapp*kolicina; nPNVU-=nc*kolicina
            else
              nPIzlaz+=kolicina ; nPMPVI+=mpcsapp*kolicina; nPNVI+=nc*kolicina
            endif

          elseif pu_i=="3"    // nivelacija
            nPMPVU+=mpcsapp*kolicina
          elseif pu_i=="I"
            nPIzlaz+=gkolicin2
            nPMPVI+=mpcsapp*gkolicin2
            nPNVI+=nc*gkolicin2
          endif

     skip ; loop
  endif

  if  datdok>ddatdo
     skip
     loop
  endif

  if cTU=="N" .and. roba->tip $ "TU"; skip; loop; endif

  if len(aUsl3)<>0
    if !Tacno(aUsl3)
       skip
       loop
    endif
  endif

  if pu_i=="1"
     nUlaz+=kolicina ; nMPVU+=mpcsapp*kolicina; nNVU+=nc*(kolicina)
  elseif pu_i=="5"

    if idvd $ "12#13"
     nUlaz-=kolicina  ; nMPVU-=mpcsapp*kolicina; nNVU-=nc*kolicina
    else
      nIzlaz+=kolicina ; nMPVI+=mpcsapp*kolicina; nNVI+=nc*kolicina
      if kolicina<0  // evidentiraj reklamacije
           nRekKol+=abs(kolicina)
           nRekMPV+=abs(mpcsapp*kolicina)
      endif
    endif

  elseif pu_i=="3"    // nivelacija
    nMPVU+=mpcsapp*kolicina
  elseif pu_i=="I"
    nIzlaz+=gkolicin2
    nMPVI+=mpcsapp*gkolicin2
    nNVI+=nc*gkolicin2
  endif

  skip

enddo  // idroba

if prow()>61+gPStranica; FF; eval(bZagl); endif
select roba
hseek cIdRoba
select kalk

aNaz:=Sjecistr(roba->naz,20)
? str(++nrbr,4)+".",cIdRoba
nCr:=pcol()+1
@ prow(),pcol()+1 SAY aNaz[1]
@ prow(),pcol()+1 SAY roba->jmj
nCol0:=pcol()+1

// predhodno stanje
@ prow(), pcol()+1  SAY nPUlaz-nPIzlaz pict gpickol
// prijem
@ prow(),pcol()+1 SAY nUlaz pict gpickol
// prodaja
@ prow(),pcol()+1 SAY nIzlaz pict gpickol
@ prow(),pcol()+1 SAY nPUlaz+nUlaz-nIzlaz pict gpickol
nCol1:=pcol()+1
@ prow(),pcol()+1 SAY nMPVU pict gpicdem
@ prow(),pcol()+1 SAY nMPVI pict gpicdem

@ prow(),pcol()+1 SAY nMPVU-NMPVI pict gpicdem

select koncij; seek trim(cIdKonto)
select roba; hseek cIdRoba
_mpc:=UzmiMPCSif()
select kalk

if round(nUlaz-nIzlaz,4)<>0
 @ prow(),pcol()+1 SAY (nMPVU-nMPVI)/(nUlaz-nIzlaz) pict gpiccdem
 if round((nMPVU-nMPVI)/(nUlaz-nIzlaz),4)<>round(_mpc,4)
   ?? " ERR"
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
if cpnab=="D"
 @ prow(),ncol0    SAY space(len(gpickol))
 @ prow(),pcol()+1 SAY space(len(gpickol))
 if round(nulaz-nizlaz,4)<>0
  @ prow(),pcol()+1 SAY (nNVU-nNVI)/(nUlaz-nIzlaz) pict gpicdem
 endif
 @ prow(),nCol1 SAY nNVU pict gpicdem
 @ prow(),pcol()+1 SAY space(len(gpicdem))
 @ prow(),pcol()+1 SAY nNVI pict gpicdem
 @ prow(),pcol()+1 SAY nNVU-nNVI pict gpicdem
 @ prow(),pcol()+1 SAY _MPC pict gpiccdem
endif
nTULaz+=nUlaz; nTIzlaz+=nIzlaz
nTMPVU+=nMPVU; nTMPVI+=nMPVI
nTNVU+=nNVU; nTNVI+=nNVI
nTRabat+=nRabat
enddo  // idkonto

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


/*! \fn ZPlanika()
 *  \brief Zaglavlje rekapitulacije
 */
 
function ZPlanika()
*{
select konto
hseek cIdKonto
?? "Prodavnica:", cIdKonto, "-", konto->naz
IspisNaDan(10)
? "KALK: REKAPITULACIJA ZA PERIOD", dDatod,"-",dDatDo, space(30),"Str:",str(++nTStrana,3)
select kalk
 ? m
 ? " R.  * Artikal  *   Naziv            *jmj*Tarifa*            * POC. STANJ *   PRIJEM   *  PRODAJA   *  REKLAMAC  *   STANJE   *"
 ? "     *          *                    *   *      *    MPC     *  kolicina  *  kolicina  *  kolicina  *  kolicina  *  kolicina  *"
 ? "     *          *                    *   *      *   N.MPC    *    iznos   *    iznos   *    iznos   *    iznos   *    iznos   *"
 ? m
return
*}

