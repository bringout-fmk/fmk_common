#include "\cl\sigma\fmk\os\os.ch"


**************************
* C52 Verzija
function RekK1()
**************************
O_K1
O_RJ
O_OS

cIdrj:=space(4)
cON:="N"
cKolP:="N"
cPocinju:="N"
cDNOS:="D"
Box(,4,77)
 @ m_x+1,m_y+2 SAY "Radna jedinica (prazno svi):" get cidrj valid empty(cIdRj) .or. p_rj(@cIdrj)
 @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
 @ m_x+2,m_y+2 SAY "Prikaz svih neotpisanih/otpisanih/samo novonabavljenih (N/O/B) sredstava:" get cON pict "@!" valid con $ "ONB"
 @ m_x+4,m_y+2 SAY "Prikaz sredstava D/N:" get cDNOs pict "@!" valid cDNOs $ "DN"
 read; ESC_BCR
BoxC()

if cpocinju=="D" .or. empty(cidrj)
  cIdRj:=trim(cidrj)
endif




m:="----- ---------- ------------------------- -------------"


select os; set order to  2 //idrj+id+dtos(datum)

cFilt1:="idrj=cidrj"
cSort1:="k1+idrj"

Box(,1,30)
index on &cSort1 to "TMPSP2" for &cFilt1 eval(TekRec()) every 10
BoxC()

start print cret

nCol1:=48
ZglK1()

go top
do while !eof()

 select os
 nKol:=0
 cK1:=os->k1
 do while !eof() .and. cK1=os->k1

   select os
   nKolRJ:=0
   nRbr:=0
   cTRj:=idrj
   do while !eof() .and. cK1==os->k1 .and. cTRj==os->idrj
      select os
      if (cON="B" .and. year(gdatobr)<>year(datum))  // nije novonabavljeno
        skip; loop
        // prikazi samo novonabavlj.
      endif

      if (!empty(datotp) .and. year(datotp)=year(gdatobr)) .and. cON $ "NB"
          // otpisano sredstvo , a zelim prikaz neotpisanih
          skip; loop
      endif

      if (empty(datotp) .or. year(datotp)<year(gdatobr)) .and. cON=="O"
          // neotpisano, a zelim prikaz otpisanih
          skip ; loop
      endif
      nKolRJ+=kolicina
      if cDNOS=="D"
       ? str(++nrbr,4)+".",id,naz
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY kolicina   pict gpickol
      endif

      skip
      select os

    enddo
    if prow()>62; FF; ZglK1(); endif
    ? m
    ? "UKUPNO ZA RJ", cTRJ,"-", ck1
    @ prow(),nCol1 SAY nKolRJ   pict gpickol
    ? m
    nKol+=nKolRJ
 enddo
 if prow()>62; FF; ZglK1(); endif
 ? strtran(m,"-","=")
 select k1; hseek ck1; select os
 ? "UKUPNO ZA GRUPU", cK1, k1->naz
 @ prow(),nCol1 SAY nKol pict gpickol
 ? strtran(m,"-","=")

enddo

end print

closeret


**********************
function TekRec()
**********************
@ m_x+1,m_y+2 SAY recno()
return NIL


*********************
*********************
function ZglK1()
P_12CPI
?? UPPER(gTS)+":",gNFirma
?
? "OS: Rekapitulacija po grupama - k1 "
if cON=="N"
   ?? "sredstava u upotrebi"
else
   ?? "sredstava otpisanih u toku godine"
endif
?? "     Datum:",gDatObr
select rj; seek cidrj; select os
? "Radna jedinica:",cidrj,rj->naz
if cpocinju=="D"
  ?? "(SVEUKUPNO)"
endif
? m
? "Rbr                                           Kolicina"
? m
return

