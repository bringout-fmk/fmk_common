#include "\cl\sigma\fmk\os\os.ch"


*****************************
*****************************
function PregRjRev()
local cIdKonto:=qidkonto:=space(7), cidsk:="", ndug:=ndug2:=npot:=npot2:=ndug3:=npot3:=0
local nCol1:=10
O_KONTO
O_RJ
O_PROMJ
O_OS

cIdrj:=space(4)
cPromj:="2"
cPocinju:="N"
cFiltK1:=SPACE(40)
cON:=" " // novo!

Box(,10,77)
 DO WHILE .t.
  @ m_x+1,m_y+2 SAY "Radna jedinica (prazno - svi):" get cidrj valid empty(cIdRj) .or. p_rj(@cIdrj)
  @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
  @ m_x+2,m_y+2 SAY "Konto (prazno - svi):" get qIdKonto pict "@!" valid empty(qidkonto) .or. P_Konto(@qIdKonto)
  @ m_x+4,m_y+2 SAY "Za sredstvo prikazati vrijednost:"
  @ m_x+5,m_y+2 SAY "1 - bez promjena"
  @ m_x+6,m_y+2 SAY "2 - osnovni iznos + promjene"
  @ m_x+7,m_y+2 SAY "3 - samo promjene           " GET cPromj valid cpromj $ "123"
  @ m_x+8,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  @ m_x+ 9,m_y+2 SAY "Prikaz svih os ( )      /   neotpisanih (N)     / otpisanih   (O) "
  @ m_x+10,m_y+2 SAY "/novonabavljenih   (B) / iz proteklih godina (G)" get cON valid con $ "ONBG " pict "@!"
  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

if empty(qidkonto); qidkonto:=""; endif
if empty(cIdrj); cidrj:=""; endif
if cpocinju=="D"
  cIdRj:=trim(cidrj)
endif

DefIzvjVal()

start print cret
private nStr:=0  // strana
select rj; hseek cidrj; select os

if !EMPTY(cFiltK1)
  select os
  set filter to &aUsl1
endif

P_10CPI
? gTS+":",gnFirma
if !empty(cidrj)
 ? "Radna jedinica:",cidrj,rj->naz
endif
? "OS: Pregled obracuna revalorizacije po kontima "
?? "",PrikazVal(),"    Datum:",gDatObr
P_COND2

private m:="----- ---------- ---- -------- ------------------------------ --- ------"+REPL(" "+REPL("-",LEN(gPicI)),5)


if empty(cidrj)
  select os; set order to 4 //"OSi4","idkonto+idrj+id"
  seek qidkonto
else
  select os; set order to  3 //"OSi3","idrj+idkonto+id"
  seek cidrj+qidkonto
endif

private nrbr:=0
nDug1:=nDug2:=nPot1:=nPot2:=0
Zagl4()
n1:=n2:=0
do while !eof() .and. (idrj=cidrj .or. empty(cidrj))
   cIdSK:=left(idkonto,3)
   nDug21:=nDug22:=nPot21:=nPot22:=0
   do while !eof() .and. (idrj=cidrj .or. empty(cidrj))  .and. left(idkonto,3)==cidsk
      cIdKonto:=idkonto
      nDug31:=nDug32:=nPot31:=nPot32:=0
      do while !eof() .and. (idrj=cidrj .or. empty(cidrj))  .and. idkonto==cidkonto
         if prow()>63; FF; Zagl4(); endif
         if !( (cON=="N" .and. empty(datotp)) .or.;
               (con=="O" .and. !empty(datotp)) .or.;
               (con=="B" .and. year(datum)=year(gdatobr)) .or.;
               (con=="G" .and. year(datum)<year(gdatobr)) .or.;
                empty(con) )
           skip 1
           loop
         endif

           fIma:=.t.
           if cpromj=="3"  // ako zelim samo promjene vidi ima li za sr.
                          // uopste promjena
               select promj; hseek os->id
               fIma:=.f.
               do while !eof() .and. id==os->id .and. datum<=gDatObr
                 fIma:=.t.
                skip
               enddo
               select os
           endif
           if fIma
              ? str(++nrbr,4)+".",id,idrj,datum,naz,jmj,str(kolicina,6,1)
              nCol1:=pcol()+1
           endif
           if cPromj <> "3"
             @ prow(),ncol1    SAY nabvr*nBBK pict gpici
             @ prow(),pcol()+1 SAY otpvr*nBBK+amp*nBBK pict gpici
             @ prow(),pcol()+1 SAY revd*nBBK pict gpici
             @ prow(),pcol()+1 SAY revp*nBBK pict gpici
             @ prow(),pcol()+1 SAY nabvr*nBBK+revd*nBBK-(otpvr+amp+revp)*nBBK pict gpici
             nDug31+=nabvr; nPot31+=otpvr+amp
             nDug32+=revd; nPot32+=revp
           endif
           if cPromj $ "23"  // prikaz promjena
              select promj; hseek os->id
              do while !eof() .and. id==os->id .and. datum<=gDatObr
                 ? space(5),space(len(id)),space(len(os->idrj)),datum,opis
                    n1:=0; n2:=amp
                 @ prow(),ncol1    SAY nabvr*nBBK pict gpici
                 @ prow(),pcol()+1 SAY otpvr*nBBK+amp*nBBK pict gpici
                 @ prow(),pcol()+1 SAY revd*nBBK pict gpici
                 @ prow(),pcol()+1 SAY revp*nBBK pict gpici
                 @ prow(),pcol()+1 SAY nabvr*nBBK+revd*nBBK-(otpvr+amp+revp)*nBBK pict gpici
                 nDug31+=nabvr; nPot31+=otpvr+amp
                 nDug32+=revd; nPot32+=revp
                skip
              enddo
              select os
           endif

         skip
      enddo
      if prow()>62; FF; Zagl4(); endif
      ? m
      ? " ukupno ",cidkonto
      @ prow(),ncol1    SAY ndug31*nBBK pict gpici
      @ prow(),pcol()+1 SAY npot31*nBBK pict gpici
      @ prow(),pcol()+1 SAY ndug32*nBBK pict gpici
      @ prow(),pcol()+1 SAY npot32*nBBK pict gpici
      @ prow(),pcol()+1 SAY ndug31*nBBK+nDug32*nBBK-npot31*nBBK-npot32*nBBK pict gpici
      ? m
      nDug21+=nDug31; nPot21+=nPot31
      nDug22+=nDug32; nPot22+=nPot32
      if !empty(qidkonto); exit; endif
    enddo
    if !empty(qidkonto); exit; endif
    if prow()>62; FF; Zagl4(); endif
    ? m
    ? " UKUPNO ",cidsk
    @ prow(),ncol1    SAY ndug21*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot21*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug22*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot22*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug21*nBBK+nDug22*nBBK-npot21*nBBK-npot22*nBBK pict gpici
    ? m
    nDug1+=nDug21; nPot1+=nPot21
    nDug2+=nDug22; nPot2+=nPot22
enddo
if empty(qidkonto)
if prow()>60; FF; Zagl4(); endif
?
? m
? " U K U P N O :"
@ prow(),ncol1    SAY ndug1*nBBK pict gpici
@ prow(),pcol()+1 SAY npot1*nBBK pict gpici
@ prow(),pcol()+1 SAY ndug2*nBBK pict gpici
@ prow(),pcol()+1 SAY npot2*nBBK pict gpici
@ prow(),pcol()+1 SAY ndug1*nBBK+nDug2*nBBK-npot1*nBBK-npot2*nBBK pict gpici
? m
endif
?
? "Napomena: Kolona 'Otp. vrijednost' prikazuje otpisanu vrijednost sredstva sa uracunatom amortizacijom za ovu godinu"
FF
end print

closeret

*************************
* zaglavlje izvjestaj rev
*************************
function Zagl4()
?
P_COND
@ prow(),125 SAY "Str."+str(++nStr,3)
if !EMPTY(cFiltK1); ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"; endif
if con="N"
  ? "PRIKAZ NEOTPISANIH SREDSTAVA:"
elseif con=="B"
  ? "PRIKAZ NOVONABAVLJENIH SREDSTAVA:"
elseif con=="G"
  ? "PRIKAZ SREDSTAVA IZ PROTEKLIH GODINA:"
elseif con=="O"
  ? "PRIKAZ OTPISANIH SREDSTAVA:"
elseif   con==" "
  ? "PRIKAZ SVIH SREDSTAVA:"
endif
? m
? " Rbr.  Inv.broj   RJ    Datum    Sredstvo                     jmj  kol  "+" "+PADC("NabVr",LEN(gPicI))+" "+PADC("OtpVr",LEN(gPicI))+" "+PADC("Rev.Dug.",LEN(gPicI))+" "+PADC("Rev.Pot.",LEN(gPicI))+" "+PADC("SadVr",LEN(gPicI))
? m

