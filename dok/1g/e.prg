
#include "\dev\fmk\ld\ld.ch"

public gModul:="LD", gGlBaza:="LD.DBF"
#ifdef  C52
#include "ini0c52.ch"
#else
#include "ini0.ch"
#endif

PUBLIC cVer:='02.72s'


#ifdef CAX
PUBLIC cNaslov:="LD:LAN AX, 06.96-05.02"
#else
#ifdef EXT
PUBLIC cNaslov:="LD:LAN CDX EXT, 06.96-05.02"
#else
PUBLIC cNaslov:="LD:LAN CDX, 06.96-05.02"
#endif
#endif

public lViseObr:=.f.

#ifdef CPOR
  cNaslov:="POR-"+cNaslov
#endif

#include "ini.ch"
private Izbor:=1

//BLOK: Glob var LD

OKumul(F_LD,KUMPATH,"LD",1,"D")
OKumul(F_RADN,KUMPATH,"RADN",1,"D")
OKumul(F_RADKR,KUMPATH,"RADKR",1,"D")

UcitajParams()

// SetHF("LD.hlp")

SETKEY(K_SH_F1,{|| Calc()})

if !empty(substr(Evar,32,1))   // nije registrovano

Beep(4)
Msg("Probna verzija !!!##Ogranicena obrada - maximalno 4 radnika !!")

O_RADN  // vi{e od 4 radnika
select radn
if reccount2()>4
 Beep(4)
 PUBLIC  Normal:="GR+/B,R/N+,,,N/W"
 Box(,6,60)
 @ m_x+1,m_y+2 SAY "Potrebno je registrovati kopiju od strane"
 @ m_x+2,m_y+2 SAY "ovlastenog distributera SIGMA-COM software-a"
 @ m_x+4,m_y+2 SAY "Podaci koje ste unosili NISU izgubljeni !"
 @ m_x+5,m_y+2 SAY "Nakon instalacije registrovane verzije mozete"
 @ m_x+6,m_y+2 SAY "nastaviti sa radom."
 inkey(0)
 Boxc()
 PUBLIC  Normal:="W/B,R/N+,,,N/W"
 quite()
endif
select radn
use
endif

PUBLIC gSQL:="N"

O_SIFK
set order to tag "ID2"
seek padr("PARTN",8)+"BANK"
if !found()
 if Pitanje(,"U sifk dodati PARTN/BANK  ?","D")=="D"
    append blank
    replace id with "PARTN" , oznaka with "BANK", naz with "Banke",;
            Veza with "N", Duzina with 16 , Tip with "C"
 endif
endif
use


Pars0()

// LDPoljaINI()         // prebaceno u UcitajParams()

//BLOK: Glavni meni LD

#ifndef CPOR
@ 4,5 SAY ""       // STANDARDNI LD meni
private opc[18]
Opc[1]:="1. unos                                               "
Opc[2]:="2. brisanje"
Opc[3]:="3. rekalkulacija"
Opc[4]:="4. izvjestaji"
Opc[5]:="5. sifrarnici"
#ifdef CPOR
Opc[6]:="6. porodilje-rjesenja"
#else
Opc[6]:="6. krediti"
#endif
IF lViseObr
 Opc[7]:="7. ---------------------------"
 Opc[8]:="8. preuzmi podatke iz obracuna"
 Opc[9]:="9. ---------------------------"
ELSE
 Opc[7]:="7. prenos obracuna u smece"
 Opc[8]:="8. povrat obracuna iz smeca"
 Opc[9]:="9. uklanjanje obracuna iz smeca"
ENDIF
Opc[10]:="B. parametri"
Opc[11]:="X. brisanje obracuna za jedan mjesec"
Opc[12]:="Y. radnici obradjeni vise puta za jedan mjesec"
Opc[13]:="D. prenos za mjesec,rj na diskete"
Opc[14]:="P. povrat sa disketa"
Opc[15]:="Q. brisanje nepotrebnih podataka iz protekle sezone"
Opc[16]:="C. promjena sifre radnika/preduzeca"
Opc[17]:="E. totalno brisanje radnika iz evidencije"
Opc[18]:="F. uzmi obracun iz CLIPBOARD-a (SIF0)"

do while .t.

 h[1]:=""
 h[2]:=""
 h[3]:=h[4]:=""

Izbor:=menu("ld",opc,Izbor,.f.)

   do case
     case Izbor==0
      cOdgovor:=Pitanje("",'Zelite izaci iz programa ?','N')
      if cOdgovor=="D"
       EXIT
      elseif cOdgovor=="L"
       Prijava()
       Izbor:=1
       @ 4,5 SAY ""
       LOOP
      else
       Izbor:=1
       @ 4,5 SAY ""
       LOOP
      endif
     case izbor == 1

        cSecur:=SecurR(KLevel,"UNOS")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
         private bHUp:=setkey(K_PGDN,{|| NIL})
         private bHDn:=setkey(K_PGUP,{|| NIL})
         Unos()
         setkey(K_PGDN,bhup)
         setkey(K_PGUP,bhdn)
        endif


     case izbor == 2
        cSecur:=SecurR(KLevel,"BRISIR")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
           Brisi()
        endif
     case izbor == 3
        cSecur:=SecurR(KLevel,"REKALK")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
         Rekalk()
        endif
     case izbor == 4
        cSecur:=SecurR(KLevel,"IZVJESTAJI")
        if ImaSlovo("X",cSecur)
           MsgBeep("Opcija nedostupna !")
        else
         Izvj()
        endif
     case izbor == 5
         Sifre()
     case izbor == 6
        Krediti()
     case izbor == 7
        if lViseObr
        else
          cSecur:=SecurR(KLevel,"SMECE")
          cSecur2:=SecurR(KLevel,"SGLEDAJ")
          if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
             MsgBeep("Opcija nedostupna !")
          else
            LdSM()
          endif
        endif
     case izbor == 8
        if lViseObr
          if SigmaSif("SIGMAXXX")
            UzmiObr()
          endif
        else
          cSecur:=SecurR(KLevel,"SMECE")
          cSecur2:=SecurR(KLevel,"SGLEDAJ")
          if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
            MsgBeep("Opcija nedostupna !")
          else
            SmLD()
          endif
        endif
     case izbor == 9
        if lViseObr
        else
          cSecur:=SecurR(KLevel,"SMECE")
          cSecur2:=SecurR(KLevel,"SGLEDAJ")
          if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
             MsgBeep("Opcija nedostupna !")
          else
             BrSm()
          endif
        endif
     case izbor == 10
        cSecur:=SecurR(KLevel,"PARAMETRI")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
           Pars()
        endif
     case izbor == 11
        cSecur:=SecurR(KLevel,"BRISIMJ")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur).or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
          BrisiMj()
        endif
     case izbor == 12
          VisePuta()
     case izbor == 13
        cSecur:=SecurR(KLevel,"DISKETE")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
          NaDiskete()
        endif
     case izbor == 14
        cSecur:=SecurR(KLevel,"DISKETE")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
          SaDisketa()
        endif
     case izbor == 15
        cSecur:=SecurR(KLevel,"PRENOSNG")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur).or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
          PrenosLd()
        endif
     case izbor == 16
        PromSif()
     case izbor == 17
        TotBrisRadn()
     case izbor == 18
        if SigmaSif("CLIP")
          ObrIzClip()
        endif
   endcase

enddo


quite()
return


#ELSE // ********* POR-LD ***************


@ 4,5 SAY ""
private opc[15]
Opc[ 1]:="1. porodilje-rjesenja                                 "
Opc[ 2]:="2. generacija obracuna"
Opc[ 3]:="3. unos, pregled podataka nakon generacije  "
Opc[ 4]:="4. izvjestaji"
Opc[ 5]:="5. sifrarnici"
Opc[ 6]:="6. unos neisplacenih naknada"
Opc[ 7]:="7. brisanje obracuna za jedan mjesec svi radnici !"
Opc[ 8]:="8. radnici obradjeni vise puta za jedan mjesec"
Opc[ 9]:="9. parametri"
Opc[10]:="A. prenos za mjesec,rj na diskete"
Opc[11]:="B. povrat sa disketa"
Opc[12]:="Q. --------------------------------"
//Opc[7]:="7. prenos obracuna u smece"
//Opc[8]:="8. povrat obracuna iz smeca"
//Opc[9]:="9. uklanjanje obracuna iz smeca"
Opc[13]:="C. promjena sifre radnika/preduzeca"
Opc[14]:="D. definisi parametre obracuna"
Opc[15]:="E. zakljucenje obracuna"

do while .t.

 h[1]:=""
 h[2]:=""
 h[3]:=h[4]:=""

Izbor:=menu("ld",opc,Izbor,.f.)

   do case
     case Izbor==0
      cOdgovor:=Pitanje("",'Zelite izaci iz programa ?','N')
      if cOdgovor=="D"
       EXIT
      elseif cOdgovor=="L"
       Prijava()
       Izbor:=1
       @ 4,5 SAY ""
       LOOP
      else
       Izbor:=1
       @ 4,5 SAY ""
       LOOP
      endif
     case izbor == 1
        Krediti()

     case izbor == 2
        cSecur:=SecurR(KLevel,"REKALK")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
         Rekalk()
        endif


     case izbor == 3
        cSecur:=SecurR(KLevel,"UNOS")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
         private bHUp:=setkey(K_PGDN,{|| NIL})
         private bHDn:=setkey(K_PGUP,{|| NIL})
         Unos()
         setkey(K_PGDN,bhup)
         setkey(K_PGUP,bhdn)
        endif


     case izbor == 4
        cSecur:=SecurR(KLevel,"IZVJESTAJI")
        if ImaSlovo("X",cSecur)
           MsgBeep("Opcija nedostupna !")
        else
         Izvj()
        endif
     case izbor == 5
         Sifre()
     case izbor == 6
        cSecur:=SecurR(KLevel,"BRISIR")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
           PriBris()
//           Brisi()
        endif
     case izbor == 7
        cSecur:=SecurR(KLevel,"BRISIMJ")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur).or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
          BrisiMj()
        endif
     case izbor == 8
          VisePuta()
     case izbor == 9
        cSecur:=SecurR(KLevel,"PARAMETRI")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
           Pars()
        endif
     case izbor == 10
        cSecur:=SecurR(KLevel,"DISKETE")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
          NaDiskete()
        endif
     case izbor == 11
        cSecur:=SecurR(KLevel,"DISKETE")
        cSecur2:=SecurR(KLevel,"SGLEDAJ")
        if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
           MsgBeep("Opcija nedostupna !")
        else
          SaDisketa()
        endif
     case izbor == 12
     case izbor == 13
        PromSif()
     case izbor == 14
        DefinisiObr()
     case izbor == 15
        ZakljuciObr()
   endcase

enddo


quite()
return

#endif // PORLD

**************************
PROCEDURE NaDiskete()
*
**************************

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := gObracun

O_LD
copy structure extended to struct
use
create (PRIVPATH+"_LD") from struct
close all
*
O_RADN
copy structure extended to struct
use
create (PRIVPATH+"_RADN") from struct
close all
*
O_KRED
copy structure extended to struct
ferase(PRIVPATH+"_KRED.CDX")
use
create (PRIVPATH+"_KRED") from struct
#ifdef C50
 index on id to (PRIVPATH+"_kredi1")
#else
 index on id tag ("ID") to (PRIVPATH+"_kred")
#endif
close all
*
O_RADKR
copy structure extended to struct
ferase(PRIVPATH+"_RADKR.CDX")
use
create (PRIVPATH+"_RADKR") from struct
close all

O_KBENEF
O_VPOSLA
O_RJ
O_RADKR
O_KRED
O_RADN
O_LD
cmxAutoOpen(.f.)
O__LD; SET ORDER TO; GO TOP
cmxAutoOpen(.t.)
O__RADN
O__RADKR
O__KRED

private cKBenef:=" ",cVPosla:=" ",cDisk:="A:\"

Box(,6,50)
@ m_x+1,m_y+2 SAY "Radna jedinica : "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+4,m_y+2 SAY "Disketa:"  GET  cDisk
read; ESC_BCR

select ld
set order to 1
hseek str(cGodina,4)+cidrj+str(cMjesec,2)

do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec

 Scatter()  // ld

 select radn; hseek _idradn
 Scatter("r")        // radn
 select _radn
 append blank
 Gather("r")

 SELECT RadKr   // str(godina)+str(mjesec)+idradn+idkred+naosnovu

 HSEEK Str (cGodina,4)+Str (cMjesec)+_IdRadn
 IF Found()
   While !Eof() .and. RADKR->Godina==cGodina .and. RADKR->Mjesec==cMjesec;
         .and. RADKR->IdRadn==_IdRadn
     cIdKred := RADKR->IdKred
     While ! Eof() .and. RADKR->Godina==cGodina .and. RADKR->Mjesec==cMjesec;
           .and. RADKR->(IdRadn+IdKred)==(_IdRadn+cIdKred)
       Scatter ("w")
       SELECT _RADKR
       Append Blank
       Gather ("w")
       SELECT RADKR
       SKIP
     EndDO
     *
     SELECT KRED
     HSEEK cIdKred
     Scatter ("x")
     SELECT _KRED
     HSEEK cIdKred
     IF ! Found()
       Append Blank
       Gather ("x")
     EndIF
     *
     SELECT RADKR
   EndDO
 EndIF

 select _ld
 append blank
 Gather()

 select ld
 skip
enddo

close all

@ m_x+6,m_y+2 SAY "stavi praznu disketu.."
inkey(0)
copy file (PRIVPATH+"_LD.DBF") to (cDisk+"_LD.DBF")
copy file (PRIVPATH+"_RADN.DBF") to (cDisk+"_RADN.DBF")
copy file (PRIVPATH+"_RADKR.DBF") to (cDisk+"_RADKR.DBF")
copy file (PRIVPATH+"_KRED.DBF") to (cDisk+"_KRED.DBF")
#ifdef C50
 copy file (PRIVPATH+"_KREDi1.NTX") to (cDisk+"_KREDi1.NTX")
#else
 copy file (PRIVPATH+"_KRED.CDX") to (cDisk+"_KRED.CDX")
#endif
BoxC()

Beep(1)
Msg("Podaci kopirani na "+cDisk)

closeret



*************************
*************************
PROCEDURE SaDisketa()

local cOdgov:="N"

private cDisk:="A:\"

Box(,1,50)
 @ m_x+1,m_y+2 SAY "Disketa:"  GET  cDisk
 read; ESC_BCR
Boxc()

copy file (cDisk+"_LD.DBF") to (PRIVPATH+"_LD.DBF")
copy file (cDisk+"_RADN.DBF") to (PRIVPATH+"_RADN.DBF")
copy file (cDisk+"_RADKR.DBF") to (PRIVPATH+"_RADKR.DBF")
copy file (cDisk+"_KRED.DBF") to (PRIVPATH+"_KRED.DBF")
#ifdef C50
 copy file (cDisk+"_KREDi1.NTX") to (PRIVPATH+"_KREDi1.NTX")
#else
 copy file (cDisk+"_KRED.CDX") to (PRIVPATH+"_KRED.CDX")
#endif

O__KRED; GO TOP
O__RADKR; GO TOP
O__RADN; GO TOP
cmxAutoOpen(.f.)
O__LD; SET ORDER TO; GO TOP
cmxAutoOpen(.t.)

cidrj   := idrj
cmjesec := mjesec
cgodina := godina

O_KRED
O_RADKR
O_RADN
O_LD

hseek str(cGodina,4)+cidrj+str(cMjesec,2)
if found()
 Beep(2)
 Msg("Podaci za "+str(cMjesec,2)+"/"+str(cGodina,4)+" rj "+cidrj+" vec postoje")
 closeret
endif

SELECT _LD
GO TOP
Box(,6,40)
nRbr:=0
do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec

 Scatter()  // _ld
 @ m_x+1,m_y+2 SAY "LD ..."
 @ row(),col()+1 SAY ++nrbr pict "9999"
 SELECT LD
 append blank
 Gather()

 SELECT _LD
 SKIP 1
enddo


nRbr := 0
SELECT _RADN
GO TOP
do while !eof()

 Scatter()  // _radn
 @ m_x+2,m_y+2 SAY "RADNICI ..."
 @ row(),col()+1 SAY ++nrbr pict "9999"

 select radn
 hseek _id
 if !found()
  append blank
  Gather()
 elseif cOdgov!="O"
   if cOdgov=="A".or.(cOdgov:=Pitanje2("",'RADNIK:'+_id+'. Zelite li da zamijenite podatke?','N'))$'DA'
     Gather()
   endif
 endif
 select _radn
 skip 1
enddo

nRbr := 0
SELECT _RADKR
GO TOP
While ! Eof()
  Scatter()
  @ m_x+3,m_y+2 SAY "KREDITI ..."
  @ row(),col()+1 SAY ++nrbr pict "9999"
  SELECT RADKR  // str(godina)+str(mjesec)+idradn+idkred+naosnovu
  HSEEK STR (_Godina)+Str (_Mjesec)+_IdRadn+_IdKred+_NaOsnovu
  IF ! Found ()
    Append Blank
  EndIF
  Gather ()
  SELECT _RADKR
  SKIP 1
EndDO

nRbr := 0
SELECT _KRED
GO TOP
While ! Eof()
  Scatter()
  @ m_x+4,m_y+2 SAY "KREDITORI ..."
  @ row(),col()+1 SAY ++nrbr pict "9999"
  SELECT KRED
  HSEEK _Id
  IF ! Found ()
    Append Blank
  EndIF
  Gather ()
  SELECT _KRED
  SKIP 1
EndDO

Beep(3)
@m_x+6,m_y+2 SAY "Prenos je zavrsen !!!"
inkey(0)
BoxC()
closeret

**************************
**************************
function VisePuta()

cMjesec  := gMjesec
cGodina  := gGodina
cObracun := gObracun

private cKBenef:=" ",cVPosla:=" "

Box(,2,50)
 @ m_x+1, m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
 @ m_x+2, m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
 read; ESC_BCR
BoxC()

// CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")
// ----------- removao ovu liniju 21.11.2000. MS ------------

O_LD
set order to tag "2"

seek str(cgodina,4)+str(cmjesec,2)
start print cret
? "Radnici obradjeni vise puta za isti mjesec -",cgodina,"/",cmjesec
?
? "RADNIK RJ     neto        sati"
? "------ -- ------------- ----------"
do while !eof() .and. str(cgodina,4)+str(cmjesec,2)==str(godina)+str(mjesec)
  cIdRadn:=idradn
  nProlaz:=0
  do while !eof() .and. str(godina)+str(mjesec)==str(godina)+str(mjesec) .and. idradn==cidradn
     ++nProlaz
     skip
  enddo
  if nProlaz>1
     seek str(cgodina,4)+str(cmjesec,2)+cidradn
     do while !eof() .and. str(godina)+str(mjesec)==str(cgodina,4)+str(cmjesec,2) .and. idradn==cidradn
        ? idradn,idrj,uneto,usati
        skip
     enddo
  endif

enddo
end print
closeret
***************************
* prenos obracuna u smece
***************************
function LdSm()

O_LD
O_LDSM

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := " "

Box(,3,70)
@ m_x+1,m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
@ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
@ m_x+3,m_y+2   SAY "Obracun: "  GET cObracun
read; ESC_BCR
BoxC()

select ldsm
seek cobracun+str(cGodina,4)+str(cMjesec,2)
if found()
  Beep(1)
  Msg("Ova varijanta obracuna vec postoji u smecu",4)
  closeret
endif
select ld; set order to tag "2"   // str(godina)+str(mjesec)+idradn

MsgC("Prenos obracuna u smece")
seek str(cgodina)+str(cmjesec)
do while !eof() .and. godina=cgodina .and. mjesec=cmjesec
   Scatter()
   _Obr:=cObracun
   select ldsm
   append blank
   gather()
   select ld
   skip
enddo
MsgC()

closeret


***************************
* prenos iz smeca u ld
***************************
function SmLd()
local i

O_LD
O_LDSM

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := " "
cDodati  := "N"

Box(,4,70)
 @ m_x+1,  m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
 @ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
 @ m_x+3,  m_y+2 SAY "Obracun: "  GET cObracun
 @ m_x+4,  m_y+2 SAY "Dodati (iznose) na postojeci obracun: "  GET cDodati pict "@!" valid cDodati $ "DN"
 read; ESC_BCR
BoxC()

select ldsm
seek cobracun+str(cGodina,4)+str(cMjesec,2)
if !found()
  Beep(1)
  Msg("Ova varijanta obracuna ne postoji u smecu",4)
  closeret
endif
select ld; set order to tag "2"   // str(godina)+str(mjesec)+idradn

if Pitanje(,"Sigurno zelite izvrsiti povrat obracuna iz smeca ?","N")=="N"
  closeret
endif

MsgO("Povrat obracuna iz smeca...")
select ldsm
seek cobracun+str(cgodina)+str(cmjesec)
do while !eof() .and. cobracun==obr .and. godina=cgodina .and. mjesec=cmjesec
   Scatter()
   select ld
   seek str(_godina)+str(_mjesec)+_idradn+_idrj
   if !found()
     append blank
     gather()
   else   // postoji zapis
     if cDodati=="N"  // ne dodaji na postojeci obracun
       gather()
     else

        private cpom:=""
        Scatter("w") // stanje u datoteci ld
        for i:=1 to cLDPolja
         cPom:=padl(alltrim(str(i)),2,"0")
         wi&cPom+=_i&cPom
        next
        wuneto+=_uneto
        wuodbici+=_uodbici
        wuiznos+=_uiznos
        Gather("w")

     endif
   endif
   select ldsm
   skip
enddo
MsgC()

closeret

***************************
* brisi iz smeca
***************************
function BrSm()
local nRec

O_LD
O_LDSM

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := " "

Box(,3,70)
 @ m_x+1,  m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
 @ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
 @ m_x+3,  m_y+2 SAY "Obracun: "  GET cObracun
 read; ESC_BCR
BoxC()

select ldsm
seek cobracun+str(cGodina,4)+str(cMjesec,2)
do while !eof() .and. cobracun==obr .and. godina=cgodina .and. mjesec=cmjesec
  skip; nRec:=recno(); skip -1
  delete
  go nRec
enddo
closeret


#include "p:\clp52\include\gproc.ch"

*****************************
*****************************
function Pars0()

O_RJ

O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}

select rj

Box(,3+IF(lViseObr,1,0),50)
 set cursor on
#ifdef CPOR
 @ m_x+1,m_y+2 SAY "Radna jedinica "; ?? gRJ
#else
 @ m_x+1,m_y+2 SAY "Radna jedinica" GET gRJ  valid P_Rj(@gRj) pict "@!"
#endif
 @ m_x+2,m_y+2 SAY "Mjesec        " GET gMjesec pict "99"
 @ m_x+3,m_y+2 SAY "Godina        " GET gGodina pict "9999"
 IF lViseObr
   @ m_x+4, m_y+2 SAY "Obracun       " GET gObracun WHEN HelpObr(.f.,gObracun) VALID ValObr(.f.,gObracun)
 ENDIF
 read
 clvbox()
BoxC()


if lastkey()<>K_ESC
 select params
 Wpar("rj",@gRJ)
 Wpar("mj",@gMjesec)
 Wpar("go",@gGodina)
 Wpar("ob",@gObracun)
 select params; use
endif
closeret


*****************************
*****************************
function Pars()

O_RJ

O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}

UsTipke()

Box(,13,77)
 set cursor on
 cIspravka:="N"
 @ m_x+ 2,m_y+2 SAY "Postaviti naziv firme, RJ, mjesec, godinu ?" GET cIspravka valid SetFirma(cIspravka) pict "@!"
 @ m_x+ 4,m_y+2 SAY "Postaviti zaokruzenja, valutu, formate prikaza iznosa ?" GET cIspravka valid SetForma(cIspravka) pict "@!"
 @ m_x+ 6,m_y+2 SAY "Postaviti nacin obracuna ?" GET cIspravka valid SetObracun(cIspravka) pict "@!"
 @ m_x+ 8,m_y+2 SAY "Postaviti formule (uk.prim.,uk.sati,godisnji) i koeficijente ?" GET cIspravka valid SetFormule(cIspravka) pict "@!"
 @ m_x+10,m_y+2 SAY "Postaviti parametre izgleda dokumenata ?" GET cIspravka valid SetPrikaz(cIspravka) pict "@!"
 @ m_x+12,m_y+2 SAY "Postaviti parametre - razno ?" GET cIspravka valid SetRazno(cIspravka) pict "@!"
#ifdef CPOR
 @ m_x+13,m_y+2 SAY "Postaviti parametre - POR-LD " GET cIspravka valid SetPor(cIspravka) pict "@!"
#endif
 read
BoxC()

BosTipke()

select params; use
CLOSERET


*****************************
*****************************
FUNCTION SetFirma()
  private GetList:={}
  IF cIspravka=="D"
    Box(, 9,77)
      @ m_x+ 2,m_y+2 SAY "Radna jedinica" GET gRJ valid P_Rj(@gRj) pict "@!"
      @ m_x+ 4,m_y+2 SAY "Mjesec        " GET gMjesec pict "99"
      @ m_x+ 6,m_y+2 SAY "Godina        " GET gGodina pict "9999"
      IF lViseObr
        @ m_x+ 7,m_y+2 SAY "Obracun       " GET gObracun WHEN HelpObr(.f.,gObracun) VALID ValObr(.f.,gObracun)
      ENDIF
      @ m_x+ 8,m_y+2 SAY "Naziv firme:" GET gNFirma
      @ m_x+ 9,m_y+2 SAY "TIP SUBJ.:" GET gTS
      read
      clvbox()
    BoxC()
    IF lastkey()<>K_ESC
      Wpar("fn",gNFirma)
      Wpar("ts",gTS)
      Wpar("go",gGodina)
      Wpar("mj",gMjesec)
      Wpar("ob",gObracun)
      Wpar("rj",gRJ)
    ENDIF
    cIspravka:="N"
    RETURN .T.
  ELSEIF cIspravka=="N"
    RETURN .T.
  ELSE
    RETURN .F.
  ENDIF
RETURN (NIL)

*****************************
*****************************
FUNCTION SetForma()
  private GetList:={}
  IF cIspravka=="D"
    Box(,11,77)
      @ m_x+ 2,m_y+2 SAY "Zaokruzenje primanja" GET gZaok pict "99"
      @ m_x+ 4,m_y+2 SAY "Zaokruzenje poreza i doprinosa" GET gZaok2 pict "99"
      @ m_x+ 6,m_y+2 SAY "Valuta " GET gValuta pict "XXX"
      @ m_x+ 8,m_y+2 SAY "Prikaz iznosa" GET gPicI
      @ m_x+10,m_y+2 SAY "Prikaz sati" GET gPicS
      read
    BoxC()
    IF lastkey()<>K_ESC
      Wpar("pi",gPicI)
      Wpar("ps",gPicS)
      Wpar("va",gValuta)
      Wpar("z2",gZaok2)
      Wpar("zo",gZaok)
    ENDIF
    cIspravka:="N"
    RETURN .T.
  ELSEIF cIspravka=="N"
    RETURN .T.
  ELSE
    RETURN .F.
  ENDIF
RETURN (NIL)

*****************************
*****************************
FUNCTION SetFormule()
  private GetList:={}
  IF cIspravka=="D"
    Box(,17,77)
      gFURaz:=PADR(gFURaz,100)
      gFUPrim:=PADR(gFUPrim,100)
      gFUSati:=PADR(gFUSati,100)
      gFURSati:=PADR(gFURSati,100)
      @ m_x+ 2,m_y+2 SAY "Formula za ukupna primanja:" GET gFUPrim  pict "@!S30"
      @ m_x+ 4,m_y+2 SAY "Formula za ukupno sati    :" GET gFUSati  pict "@!S30"
      @ m_x+ 6,m_y+2 SAY "Formula za godisnji:" GET gFUGod pict "@!S30"
      @ m_x+ 8,m_y+2 SAY "Formula za uk.prim.-razno :" GET gFURaz pict "@!S30"
      @ m_x+10,m_y+2 SAY "Formula za uk.sati -razno :" GET gFURSati pict "@!S30"
      @ m_x+12,m_y+2 SAY "God. promjena koef.min.rada - ZENE:" GET gMRZ   pict "9999.99"
      @ m_x+14,m_y+2 SAY "God. promjena koef.min.rada - MUSK:" GET gMRM   pict "9999.99"
      @ m_x+16,m_y+2 SAY "% prosjecne plate kao donji limit neta za obracun poreza i doprinosa" GET gPDLimit pict "999.99"
      read
    BoxC()
    IF lastkey()<>K_ESC
      Wpar("gd",gFUGod)
      WPar("m1", @gMRM)
      WPar("m2", @gMRZ)
      WPar("dl", @gPDLimit)
      Wpar("uH",@gFURSati)
      Wpar("uS",@gFUSati)
      Wpar("up",gFUPrim)
      Wpar("ur",gFURaz)
    ENDIF
    cIspravka:="N"
    RETURN .T.
  ELSEIF cIspravka=="N"
    RETURN .T.
  ELSE
    RETURN .F.
  ENDIF
RETURN (NIL)

*****************************
*****************************
FUNCTION SetObracun()
  private GetList:={}
  cVarPorol:=padr(cVarPorol,2)
  IF cIspravka=="D"
    Box(,16,77)
      @ m_x+ 2,m_y+2 SAY "Tip obracuna " GET gTipObr
      @ m_x+ 4,m_y+2 SAY "Mogucnost unosa mjeseca pri obradi D/N:" GET gUnMjesec  pict "@!" valid glistic $ "DN"
      @ m_x+ 6,m_y+2 SAY "Koristiti set formula (sifrarnik Tipovi primanja):" GET gSetForm pict "9" valid V_setform()
      @ m_x+ 8,m_y+2 SAY "Minuli rad  %/B:" GET gMinR  valid gMinR $ "%B"   pict "@!"
      @ m_x+10,m_y+2 SAY "Pri obracunu napraviti poreske olaksice D/N:" GET gDaPorOl  valid gDaPorOl $ "DN"   pict "@!"
      @ m_x+11,m_y+2 SAY "Ako se prave por.ol.pri obracunu, koja varijanta se koristi:"
      @ m_x+12,m_y+2 SAY " '1' - POROL = RADN->porol*PAROBR->prosld/100 ÄÄ¿  "
      @ m_x+13,m_y+2 SAY " '2' - POROL = RADN->porol, '29' - LD->I29    ÄÄÁÄ>" GET cVarPorOl WHEN gDaPorOl=="D"   PICT "99"

      @ m_x+15,m_y+2 SAY "Grupe poslova u specif.uz platu (1-automatski/2-korisnik definise):" GET gVarSpec  valid gVarSpec $ "12" pict "9"
      @ m_x+16,m_y+2 SAY "Obrada sihtarice ?" GET gSihtarica valid gSihtarica $ "DN" pict "@!"
      read
    BoxC()
    IF lastkey()<>K_ESC
      WPar("fo", gSetForm)
      WPar("mr", @gMinR)   // min rad %, Bodovi
      WPar("p9", @gDaPorOl) // praviti poresku olaksicu D/N
      Wpar("to",gTipObr)
      Wpar("vo",cVarPorOl)
      WPar("um",gUNMjesec)
      Wpar("vs",gVarSpec)
      Wpar("Si",gSihtarica)
    ENDIF
    cIspravka:="N"
    RETURN .T.
  ELSEIF cIspravka=="N"
    RETURN .T.
  ELSE
    RETURN .F.
  ENDIF
RETURN (NIL)

*****************************
*****************************
FUNCTION SetPrikaz()
  private GetList:={}
  IF cIspravka=="D"
    Box(,17,77)
      @ m_x+ 2,m_y+2 SAY "Krediti-rekap.po 'na osnovu' (D/N/X)?" GET gReKrOs VALID gReKrOs $ "DNX" PICT "@!"
      @ m_x+ 4,m_y+2 SAY "Na kraju obrade odstampati listic D/N:" GET gListic  pict "@!" valid glistic $ "DN"
      @ m_x+ 6,m_y+2 SAY "Prikaz bruto iznosa na kartici radnika (D/N/X) " GET gPrBruto pict "@!" valid gPrBruto $ "DNX"
      @ m_x+ 8,m_y+2 SAY "Potpis na kartici radnika D/N:" GET gPotp  valid gPotp $ "DN"   pict "@!"
      @ m_x+10,m_y+2 SAY "Varijanta kartice plate za kredite (1/2) ?" GET gReKrKP VALID gReKrKP$"12"
      @ m_x+12,m_y+2 SAY "Opis osnovnih podataka za obracun (1-bodovi/2-koeficijenti) ?" GET gBodK VALID gBodK$"12"
      @ m_x+14,m_y+2 SAY "Pregled plata: varijanta izvjestaja (1/2)" GET gVarPP VALID gVarPP$"12"
      //@ m_x+14,m_y+2 SAY "Prikaz tabele 0/1/2" GET gTabela VALID gTabela$"012"
      read
    BoxC()
    IF lastkey()<>K_ESC
      Wpar("bk",gBodK)
      Wpar("kp",gReKrKP)
      Wpar("pp",gVarPP)
      Wpar("li",gListic)
      WPar("pb", gPrBruto)   // set formula
      WPar("po", gPotp)   // potp4is na listicu
      Wpar("rk",gReKrOs)
      //Wpar("tB",gTabela)
    ENDIF
    cIspravka:="N"
    RETURN .T.
  ELSEIF cIspravka=="N"
    RETURN .T.
  ELSE
    RETURN .F.
  ENDIF
RETURN (NIL)


*****************************
*****************************
FUNCTION SetRazno()
  private GetList:={}
  IF cIspravka=="D"
    Box(, 4,77)
      @ m_x+ 2,m_y+2 SAY "Fajl obrasca specifikacije" GET gFSpec VALID V_FSpec()
      read
    BoxC()
    IF lastkey()<>K_ESC
      WPar("os", @gFSpec)   // fajl-obrazac specifikacije
    ENDIF
    cIspravka:="N"
    RETURN .T.
  ELSEIF cIspravka=="N"
    RETURN .T.
  ELSE
    RETURN .F.
  ENDIF
RETURN (NIL)


#ifdef CPOR
*****************************
*****************************
FUNCTION SetPor()
  private GetList:={}
  IF cIspravka=="D"
    gBrRjes:=padr(gBrRjes,60)
    Box(, 7,77)
      cEr:=" "
      @ m_x+ 1,m_y+2 SAY "Formula za broj rjesenja " GET gBrRjes pict "@!S40"
      cEr:="0"
      @ m_x+ 4,m_y+2 SAY "Fajl rjesenja.txt 0/1/2/5/6" GET cER valid {|| cEr="0" .or. V_FRjes(cEr) }
      @ m_x+ 6,m_y+2 SAY "Minimalni iznos mjesecne naknade:" GET gMinRata  pict "99999.99"
      @ m_x+ 7,m_y+2 SAY "Ispis TXT/RTF tekuci   (T/R)    :" GET gTxtRtf  pict "@!" valid gTxtRTf $ "TR"
      read
    BoxC()
    gBrRjes:=trim(gBrRjes)
    IF lastkey()<>K_ESC
      WPar("#1", gBrRjes)   // fajl-obrazac specifikacije
      WPar("m3", @gMinRata)
      WPar("#2", @gTxtRtf)
    ENDIF
    cIspravka:="N"
    RETURN .T.
  ELSEIF cIspravka=="N"
    RETURN .T.
  ELSE
    RETURN .F.
  ENDIF
RETURN (NIL)

#endif

****************
****************
function v_setform()
local cscsr, nArr:=SELECT()
if file(SIFPATH+"TIPPR.DB"+gSetForm) .and. pitanje(,"Sifrarnik tipova primanja uzeti iz arhive br. "+gSetForm+" ?","N")=="D"
 save screen to cscr
 select (F_TIPPR)
 use

 cls
#ifdef C52
 ? filecopy  (SIFPATH+"TIPPR.DB"+gSetForm  ,SIFPATH+"TIPPR.DBF"  )
 ? filecopy  (SIFPATH+"TIPPR.CD"+gSetForm,SIFPATH+"TIPPR.CDX")
#else
 ? filecopy  (SIFPATH+"TIPPR.DB"+gSetForm  ,SIFPATH+"TIPPR.DBF"  )
 ? filecopy  (SIFPATH+"TIPPRI1.NT"+gSetForm,SIFPATH+"TIPPRi1.NTX")
#endif
 inkey(20)
 restore screen from cscr
 select (F_TIPPR)
 if !used(); O_TIPPR; endif
 P_Tippr()
 select params
elseif  pitanje(,"Tekuci sifrarnik tipova primanja staviti u arhivu br. "+gSetForm+" ?","N")=="D"
 save screen to cscr
 select (F_TIPPR)
 use
 cls
#ifdef C52
 ? filecopy  (SIFPATH+"TIPPR.DBF",SIFPATH+"TIPPR.DB"+gSetForm)
 ? filecopy  (SIFPATH+"TIPPR.CDX",SIFPATH+"TIPPR.CD"+gSetForm)
#else
 ? filecopy  (SIFPATH+"TIPPR.DBF", SIFPATH+"TIPPR.DB"+gSetForm)
 ? filecopy  (SIFPATH+"TIPPRi1.NTX",SIFPATH+"TIPPRI1.NT"+gSetForm)
#endif
 inkey(20)
 restore screen from cscr
endif
select (nArr)
return .t.

*****************************************************************
*****************************************************************
**function DinDem(p1,p2,cVar)
**local nNaz
**
**
**nArr:=SELECT()
**select tokval
**seek dtos(_DatDok)
**if !found() .or. eof()
**    skip -1
**endif
**
**if kurslis=="1"; nNaz:=naz; else;  nNaz:=naz2; endif
**if cVar=="_IZNOSDEM"
**    _IZNOSBHD:=_IZNOSDEM*nnaz
**elseif cVar="_IZNOSBHD"
**    _IZNOSDEM:=_IZNOSBHD/nnaz
**endif
**select(nArr)
**AEVAL(GetList,{|o| o:display()})


****************************************************
function SkloniSezonu(cSezona,finverse,fda,fnulirati, fRS)
*
* fnulirati
******************************************************
local cScr


if fda==NIL
  fDA:=.f.
endif
if finverse==NIL
  finverse:=.f.
endif
if fNulirati==NIL
  fnulirati:=.f.
endif
if fRS==NIL
  // mrezna radna stanica , sezona je otvorena
  fRS:=.f.
endif

if fRS // radna stanica
  altd()
  if file(PRIVPATH+cSezona+"\_RADKR.DBF")
      // nema se sta raditi ......., pripr.dbf u sezoni postoji !
      return
  endif
  aFilesK:={}
  aFilesS:={}
  aFilesP:={}
endif

save screen to cScr

cls
?
if finverse
 ? "Prenos iz  sezonskih direktorija u radne podatke"
else
 ? "Prenos radnih podataka u sezonske direktorije"
endif
?
// privatni
fnul:=.f.
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_RADN.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_RADKR.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_OPSLD.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_KRED.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_PRIPNO.DBF",cSezona,finverse,fda,fnul)

if fnulirati; fnul:=.t.; else; fnul:=.f.; endif  // kumulativ datoteke
Skloni(PRIVPATH,"LDSM.DBF",cSezona,finverse,fda,fnul)

if fRS
 // mrezna radna stanica!!! , baci samo privatne direktorije
 ?
 ?
 ?
 Beep(4)
 ? "pritisni nesto za nastavak.."

 restore screen from cScr
 return
endif

fnul:=.f.
Skloni(KUMPATH,"RADN.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RADKR.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RJ.DBF",cSezona,finverse,fda,fnul)

Skloni(KUMPATH,"LD.DBF",cSezona,finverse,fda,fnul)

fnul:=.f.
Skloni(SIFPATH,"PAROBR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KRED.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"POR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"DOPR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"STRSPR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KBENEF.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VPOSLA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TIPPR.DBF",cSezona,finverse,fda,fnul)
//if lViseObr
  Skloni(SIFPATH,"TIPPR2.DBF",cSezona,finverse,fda,fnul)
//endif
Skloni(SIFPATH,"SIFK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFV.DBF",cSezona,finverse,fda,fnul)


//sifrarnici
?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr
return

**********************************
function PrenosLD()
*
*
**********************************
Beep(4)
MsgBeep("Da bi se rasteretili od podataka koji nam nisu potrebni,#"+;
        "vrsimo brisanje nepotrebnih podataka u tekucoj godini.##"+;
        " ?")

if Pitanje(,"Brisanje dijela podataka iz protekle sezone ?","N")="N"
  closeret
endif
if !sigmaSif("LDSTARO")
  closeret
endif

nGodina:=year(date())-1
nMjOd:=1
nMjDo:=9
Box(,4,60)
do while .t.
 cispravno:="N"
   @ m_x+1,m_y+2 SAy"Izbrisati mjesece za godinu :"  GET nGodina pict "9999"
   @ m_x+2,m_y+2 SAY "Brisanje izvrsiti od mjeseca:" GET nMjOd pict "99"
   @ row(),col()+2 SAY "do mjeseca" GET nMjDO pict "99"
   @ m_x+4,m_y+2 SAY "Ispravno D/N ?" GET cispravno valid cispravno $ "DN" pict "@!"
   read
   if cispravno=="D"; exit; endif
enddo
Boxc()

O_LDX    ; set order to 0

start print cret

? "Datoteka LD..."
?
select ld; go top
do while !eof()
  if ngodina==godina .and. (mjesec>=nmjod .and. mjesec<=nmjdo) .or. ;
     empty(idradn)

     dbdelete2()
     ? "Brisem:",idrj,godina,mjesec,idradn
  endif

  skip
enddo
select ld;use

? "Datoteka LDSM..."
?
O_LDSMX
select ldsm; go top
do while !eof()
  if ngodina==godina .and. (mjesec>=nmjod .and. mjesec<=nmjdo) .or. ;
     empty(idradn)

     dbdelete2()
     ? "Brisem:",idrj,godina,mjesec,idradn
  endif

  skip
enddo
select ldsm;use

? "Datoteka RADKR..."
?
O_RADKRX
select radkr; go top
do while !eof()
 // ako je godina 1998, onda brisi 1997 i starije
 if ngodina>godina .or.  empty(idradn)
     dbdelete2()
     ? "Brisem: radkr",godina,mjesec,idradn
  endif

  skip
enddo
select radkr;use

end print

closeret

**********************************************
function UcitajParams()
*
**********************************************
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}

public gRJ:="00", gnHelpObr:=0
public gMjesec:=1, gObracun:=" "
public gGodina:=1997
public gZaok:=2
public gZaok2:=2
public gValuta:="KM "
public gPicI:="99999999.99"
public gPicS:="999999"
public gTipObr:="1", gVarSpec:="1", cVarPorOl:="1"
public gSihtarica:="N"
public gFUPrim:=padr("UNETO+I24+I25",50)
public gFURaz :=padr("",60)
public gFUSati:=padr("USATI",50)
public gFURSati:=padr("",50)
public gFUGod:=padr("I06",40)
public gNFirma:=space(20)  // naziv firme
public gListic:="N", gTS:="Preduzece"
public gUNMjesec:="N"
public gMRM:=0
public gMRZ:=0
public gPDLimit:=0
public gSetForm:="1"
public gPrBruto:="N"
public gMinR:="%"
public gPotp:="D", gBodK:="1"
public gDaPorol:="D" // pri obracunu uzeti u obzir poreske olaksice
public gFSpec:=PADR("SPEC.TXT",12), gReKrOs:="X", gReKrKP:="1", gVarPP:="1"

#ifdef CPOR
 public gMinRata:=150
 public gBrRjes:='"02-01/8-124-"+Bez0(RIGHT(radkr->naosnovu,6))'
 public gTxtRTf:="T"
 RPar("m3",@gMinRata)
 Rpar("#1",@gBrRjes)
 RPar("#2",@gTxtRtf)
#endif

RPar("bk",@gBodK)      // opisno: 1-"bodovi" ili 2-"koeficijenti"
Rpar("fn",@gNFirma)
Rpar("ts",@gTS)
RPar("fo",@gSetForm)   // set formula
Rpar("gd",@gFUGod)
Rpar("go",@gGodina)
Rpar("kp",@gReKrKP)
Rpar("pp",@gVarPP)
Rpar("li",@gListic)
RPar("m1",@gMRM)
RPar("m2",@gMRZ)
RPar("dl",@gPDLimit)
Rpar("mj",@gMjesec)
Rpar("ob",@gObracun)
RPar("mr",@gMinR)      // min rad %, Bodovi
RPar("os",@gFSpec)     // fajl-obrazac specifikacije
RPar("p9",@gDaPorOl)   // praviti poresku olaksicu D/N
RPar("pb",@gPrBruto)   // set formula
Rpar("pi",@gPicI)
RPar("po",@gPotp)      // potpis na listicu
Rpar("ps",@gPicS)
Rpar("rj",@gRj)
Rpar("rk",@gReKrOs)
Rpar("to",@gTipObr)
Rpar("vo",@cVarPorOl)
Rpar("uH",@gFURSati)
Rpar("uS",@gFUSati)
RPar("um",@gUNMjesec)
Rpar("up",@gFUPrim)
Rpar("ur",@gFURaz)
Rpar("va",@gValuta)
Rpar("vs",@gVarSpec)
Rpar("Si",@gSihtarica)
Rpar("z2",@gZaok2)
Rpar("zo",@gZaok)
//Rpar("tB",@gTabela)

select 99; use

LDPoljaINI()

return

*********************
function V_FSpec()
*
*********************
private cKom:="q "+PRIVPATH+gFSpec
if Pitanje(,"Zelite li izvrsiti ispravku fajla obrasca specifikacije ?","N")=="D"
 if !empty(gFSpec)
   Box(,25,80)
   run &ckom
   BoxC()
 endif
endif
return .t.

*********************
function V_FRjes(cVarijanta)
*
*********************

private cKom:="q "+PRIVPATH
if cVarijanta>"4"
 cKom+="dokaz"
else
 cKom+="rjes"
endif
if cvarijanta=="5"
 cKom+="1"
elseif cvarijanta=="6"
 cKom+="2"
else
 cKom+=cVarijanta
endif
cKom+=".txt"

altd()
if Pitanje(,"Zelite li izvrsiti ispravku fajla obrasca rjesenja ?","N")=="D"
 if !empty(gFSpec)
   Box(,25,80)
   run &ckom
   BoxC()
 endif
endif
return .t.


#include "p:\clp52\include\RDDINIT.CH"

#ifdef CAX
function truename(cc)  // sklonjena iz CTP
return cc
#else
#ifdef EXT
 function truename(cc)  // sklonjena iz CTP
 return cc
#endif
#endif


#ifdef C52
********************************
function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
*
* F:\SIGMA\FIN -> C:\SIGMA\FIN
* 5.2
*********************************
local cPath,cScreen

if cDefault==NIL
  cDefault:="0"
endif

select (nArea)
if gKesiraj $ "CD"
  cPath:=strtran(cStaza,LEFT(cStaza,3),gKesiraj+":\")

  DirMak2(cPath)  // napravi odrediçni direktorij

  if cDefault!="0"
    if !file( cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
     save screen to cScr
     cls
     ? "Molim sacekajte prenos podataka na vas racunar "
     ? "radi brzeg pregleda podataka"
     ?
     ? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     ?
     close all
     Copysve(cIme+"*.DB?",cStaza,cPath)
     Copysve(cIme+"*.CDX",cStaza,cPath)
     ?
     ? "pritisni nesto za nastavak ..."
     inkey(10)
     restore screen from cScr
   endif
  endif

else
  cPath:=cStaza
endif
cPath:=cPath+cIme
use  (cPath)
return NIL

#else

********************************

function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
*
* F:\SIGMA\FIN -> C:\SIGMA\FIN
* CAX !!!
*********************************
local cPath,cScreen

if cDefault==NIL
  cDefault:="0"
endif

select (nArea)

if used(); return; endif
// CAX - samo jednom otvori !!!!!!!!!!!!!!!!!

if gKesiraj $ "CD"
  cPath:=strtran(cStaza,LEFT(cStaza,3),gKesiraj+":\")

  DirMak2(cPath)  // napravi odrediçni direktorij

  if cDefault!="0"
    if !file( cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
     save screen to cScr
     cls
     ? "Molim sacekajte prenos podataka na vas racunar "
     ? "radi brzeg pregleda podataka"
     ?
     ? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     ?
     close all
     Copysve(cIme+"*.DB?",cStaza,cPath)
     Copysve(cIme+"*.CDX",cStaza,cPath)
     ?
     ? "pritisni nesto za nastavak ..."
     inkey(10)
     restore screen from cScr
   endif
  endif

else
  cPath:=cStaza
endif
cPath:=cPath+cIme
use  (cPath)
return NIL


#endif


PROCEDURE LDPoljaINI()
 O_LD
 if ld->(fieldpos("S40"))<>0
   public cLDPolja:=40
 elseif ld->(fieldpos("S30"))<>0
   public cLDPolja:=30
 else
   public cLDPolja:=14
 endif
 if ld->(fieldpos("OBR"))<>0
   public lViseObr:=.t.
 else
   public lViseObr:=.f.
 endif
 use
RETURN


// WHEN za GET cObracun i gObracun
FUNC HelpObr(lIzv,cObracun)
  IF lIzv==NIL; lIzv:=.f.; ENDIF
  IF gnHelpObr=0
    Box(,3+IF(lIzv,1,0),40)
    @ m_x+0, m_y+2 SAY PADC(" POMOC: ",36,"Í")
    IF lIzv
      @ m_x+2, m_y+2 SAY "Ukucajte broj obracuna (1/2/.../9)"
      @ m_x+3, m_y+2 SAY "ili prazno ako zelite sve obracune"
    ELSE
      @ m_x+2, m_y+2 SAY "Ukucajte broj obracuna (1/2/.../9)"
    ENDIF
    ++gnHelpObr
  ENDIF
RETURN .t.


// VALID za GET cObracun
FUNC ValObr(lIzv,cObracun)
  LOCAL lVrati:=.t.
  IF lIzv==NIL; lIzv:=.f.; ENDIF
  IF lIzv
    lVrati := ( cObracun $ " 123456789" )
  ELSE
    lVrati := ( cObracun $ "123456789" )
  ENDIF
  IF gnHelpObr>0 .and. lVrati
    BoxC()
    --gnHelpObr
  ENDIF
RETURN lVrati


PROC ClVBox()
 LOCAL i:=0
 FOR i:=1 TO gnHelpObr
   BoxC()
 NEXT
 gnHelpObr:=0
RETURN


*****************************************
* preuzimanje podataka iz drugog obracuna
*****************************************
function UzmiObr()
local i, lSveRJ

O_LD

cIdRj    := gRj
cMjesec  := gMjesec
cGodina  := gGodina
cObracun := " "
cDodati  := "N"

Box(,4,75)
 @ m_x+0,  m_y+2 SAY "PREUZETI PODATKE IZ OBRACUNA:"
 @ m_x+1,  m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
 @ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
 @ m_x+2,  m_y+2 SAY "RJ (prazno-sve):"  GET cIdRJ
 @ m_x+3,  m_y+2 SAY "Obracun: "  GET cObracun VALID cObracun<>gObracun .and. !EMPTY(cObracun)
 @ m_x+4,  m_y+2 SAY "Dodati (iznose) na postojeci obracun: "  GET cDodati pict "@!" valid cDodati $ "DN"
 read; ESC_BCR
BoxC()

lSveRJ:=.f.
if EMPTY(cIDRJ) .and. pitanje(,"Zelite li preuzeti podatke ZA SVE RJ za ovaj mjesec ?","D")=="D"
  lSveRJ:=.t.
endif

select ld
if lSveRJ
  SET ORDER TO TAG "2"
// "str(godina)+str(mjesec)+obr+idradn+idrj"
  seek str(cGodina,4)+str(cMjesec,2)+cObracun
else
// "str(godina)+idrj+str(mjesec)+obr+idradn"
  seek str(cGodina,4)+cIdRj+str(cMjesec,2)+cObracun
endif
if !found()
  Beep(1)
  Msg("Ovaj obracun ne postoji!",4)
  closeret
endif

IF lSveRJ
  do while !eof() .and. STR(godina,4)+str(Mjesec,2)+Obr==str(cGodina,4)+str(cMjesec,2)+cObracun
    nRec:=RECNO()
    Scatter()
    _godina := gGodina
    _mjesec := gMjesec
    _obr    := gObracun
    seek str(gGodina,4)+str(gMjesec,2)+gObracun+_idradn+_idrj
    IF FOUND()
      IF cDodati=="N"
        gather()
      ELSE
        private cpom:=""
        Scatter("w") // stanje u datoteci ld
        for i:=1 to cLDPolja
          cPom:=padl(alltrim(str(i)),2,"0")
          wi&cPom+=_i&cPom
        next
        wuneto+=_uneto
        wuodbici+=_uodbici
        wuiznos+=_uiznos
        Gather("w")
      ENDIF
    ELSE
      append blank
      gather()
    ENDIF
    GO (nRec); skip 1
  enddo
  MsgBeep("Preuzimanje podataka iz obracuna "+cObracun+" za "+STR(cMjesec,2)+"/"+STR(cGodina,4)+",#"+;
          " za sve RJ zavrseno. Novi obracun:"+gObracun+" za "+STR(gMjesec,2)+"/"+STR(gGodina,4))
ELSE
  do while !eof() .and. STR(godina,4)+IdRj+str(Mjesec,2)+Obr==str(cGodina,4)+cIdRj+str(cMjesec,2)+cObracun
    nRec:=RECNO()
    Scatter()
    _godina := gGodina
    _mjesec := gMjesec
    _idrj   := gRJ
    _obr    := gObracun
    seek str(gGodina,4)+gRj+str(gMjesec,2)+gObracun+_idradn
    IF FOUND()
      IF cDodati=="N"
        gather()
      ELSE
        private cpom:=""
        Scatter("w") // stanje u datoteci ld
        for i:=1 to cLDPolja
         cPom:=padl(alltrim(str(i)),2,"0")
         wi&cPom+=_i&cPom
        next
        wuneto+=_uneto
        wuodbici+=_uodbici
        wuiznos+=_uiznos
        Gather("w")
      ENDIF
    ELSE
       append blank
       gather()
    ENDIF
    GO (nRec); skip 1
  enddo
  MsgBeep("Preuzimanje podataka iz obracuna "+cObracun+" za "+STR(cMjesec,2)+"/"+STR(cGodina,4)+",#"+;
          " za RJ:"+cIdRJ+". Novi obracun:"+gObracun+" za "+STR(gMjesec,2)+"/"+STR(gGodina,4)+" za RJ:"+gRJ+".")
ENDIF

CLOSERET

FUNC Reindex_all()
RETURN (NIL)

function o_nar()

