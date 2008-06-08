* kompajlirati sa CLP522R
*


cls

*

SETCANCEL(.F.)

SET ESCAPE OFF
public cSifra:=SPACE(8)
public cUlaz:=SPACE(8)
if file("PASS.MEM")
 restore FROM  pass   ADDITIVE
endif
if valtype(cSifra)<>"C"
 public cUlaz:=SPACE(8)
endif
do while .t.
Beep(1)
CSIFRA:=SPACE(8)
@ 2 ,30 SAY "SIGMA-COM ZENICA"
@ 15,28 SAY "Sifra za ulazak:"
cSifra:=upper(GETSECRET( cSifra ))
if cSifra=="SIGMAXAA"
   RETURN .T.
endif
if empty(culaz)
    cUlaz:=cSifra
    save all like cUlaz  to pass
endif
if cSifra=="XXXXXXXX"
  cls
  Beep(2)
  @ 1,15 SAY "PROMJENA SIFRE"
  cOld:=cNew:=cNew2:=space(8)
  @ 10,20 SAY "STARA sifra" GET cOld  pict "@!"
  read
  if cOld==cUlaz
     @ 18,20 SAY "NOVA sifra              " GET cNew  pict "@!"
     @ 19,20 SAY "Ponovite unos nove sifre" GET cNew2  pict "@!"
     read
  else
     cls
     Tone(10,2)
  endif
  if cNEW==cNEW2
      cUlaz:=cNew
      save all like cUlaz  to pass
      cls
  endif
else
  if cSifra==cUlaz
    RETURN .T.
  endif
endif
enddo
BOOTCOLD()
RETURN .F.

PROC GPROC()
RETURN

PROC UcitajParams()
RETURN

function SkloniSezonu()

