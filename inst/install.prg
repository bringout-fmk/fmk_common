// INSTALL MODUL

/*! \fn Main()
 *  \brief Osnovna f-ja za instalaciju programa 
 */
function Main()
*{
local i,j,ii
local cNprog[16],cMProg[16],cTProg[16]

SetSCGvars()

//////////////////////////////////////
// globalne varijable i podesavanja
//////////////////////////////////////

// Definisanje boja
PUBLIC StaraBoja:=SETCOLOR()
PUBLIC cbteksta,cbokvira,cbnaslova,cbshema:="B1"
IF ISCOLOR()
 PUBLIC  Invert:="B/W,R/N+,,,R/B+"
 PUBLIC  Normal:="W/B,R/N+,,,N/W"
 PUBLIC  Blink:="R****/W,W/B,,,W/RB"
 PUBLIC  Nevid:="W/W,N/N"
ELSE
 PUBLIC  Invert:="N/W,W/N,,,W/N"
 PUBLIC  Normal:="W/N,N/W,,,N/W"
 PUBLIC  Blink:="N****/W,W/N,,,W/N"
 PUBLIC  Nevid:="W/W,N/N"
ENDIF
SET SCOREBOARD OFF
SET DATE GERMAN

gReadOnly:=.f.

cls
fMem:=.f.

// ovo se dole cita iz mem fajla
nFirmi:=2
cSF1:="01"; cSF2:="02"; cSF3:="03"; cSF4:="04"; cSF5:="05"
cSF6:="06"; cSF7:="07"; cSF8:="08"; cSF9:="09"; cSF10:="10"
cSF11:="11"; cSF12:="12"; cSF13:="13"; cSF14:="14"; cSF15:="15"
cSF16:="16"; cSF17:="17"; cSF18:="18"; cSF19:="19"; cSF20:="20"
cSF21:="21"; cSF22:="22"; cSF23:="23"; cSF24:="24"; cSF25:="25"
cSF26:="26"; cSF27:="27"; cSF28:="28"; cSF29:="29"; cSF30:="30"
cSF31:="31"; cSF32:="32"; cSF33:="33"; cSF34:="34"; cSF35:="35"
cSF36:="36"; cSF37:="37"; cSF38:="38"; cSF39:="39"; cSF40:="40"
cSF41:="41"; cSF42:="42"; cSF43:="43"; cSF44:="44"; cSF45:="45"
cSF46:="46"; cSF47:="47"; cSF48:="48"; cSF49:="49"; cSF50:="50"
cSF51:="51"; cSF52:="52"; cSF53:="53"; cSF54:="54"; cSF55:="55"
cSF56:="56"; cSF57:="57"; cSF58:="58"; cSF59:="59"; cSF60:="60"
cnf1:=cnf2:=cnf3:=cnf4:=cnf5:=cnf6:=cnf7:=cnf8:=cnf9:=cnf10:=space(20)
cnf11:=cnf12:=cnf13:=cnf14:=cnf15:=cnf16:=cnf17:=cnf18:=cnf19:=cnf20:=space(20)
cnf21:=cnf22:=cnf23:=cnf24:=cnf25:=cnf26:=cnf27:=cnf28:=cnf29:=cnf30:=space(20)
cnf31:=cnf32:=cnf33:=cnf34:=cnf35:=cnf36:=cnf37:=cnf38:=cnf39:=cnf40:=space(20)
cnf41:=cnf42:=cnf43:=cnf44:=cnf45:=cnf46:=cnf47:=cnf48:=cnf49:=cnf50:=space(20)
cnf51:=cnf52:=cnf53:=cnf54:=cnf55:=cnf56:=cnf57:=cnf58:=cnf59:=cnf60:=space(20)
cPosSif:="N"

if file("install.mem")
    cProg1:=cProg2:=cProg3:=cProg4:=cProg5:=cProg6:=cProg7:=cProg8:=cProg9:=cProg10:=cProg11:=cProg12:="D"
    cProg13:=cProg14:=cProg15:=cProg16:="N"
    restore from install.mem additive
    fMem:=.t.
endif

@ 1,1 SAY "Instalacija FMK - SIGMA-COM software 1.w.0.0.2, 05.95-27.02.05"


cFMkInst:="D"
@ 3,1 SAY "Instalacija FMK/EXT (D/N) " GET cFMKInst  vali cFMKInst $ "DN" pict "@!"
read

cFullPath:='N'
@ 4,1 SAY "Pri pozivu EXE fajlova navesti puno ime (full path) " GET cFullPath pict "@!" valid cFullpath$"DN"
read


******************************
******************************
nPrograma:=16

if !fmem
 cProg1:=cProg2:=cProg3:=cProg4:=cProg5:=cProg6:=cProg7:=cProg8:=cProg9:=cProg10:=cProg11:=cProg12:=cProg16:="N"
 cProg1:="D"
 cProg3:="D"
 cProg4:="D"
 cProg13:="D"
 cProg14:="N"
 cProg15:="N"
endif


// imena programa
cnProg[1]:="FIN"
cNProg[2]:="MAT"
cNPROG[3]:="KALK"
cNPROG[4]:="FAKT"
cNPROG[5]:="CJEN"
cNPROG[6]:="POR"
cNPROG[7]:="LD"
cNPROG[8]:="OS"
cNPROG[9]:="CKALK"
cNPROG[10]:="CFAKT"
cNPROG[11]:="VIRM"
cNPROG[12]:="KAM"
cNPROG[13]:="ADMIN"
cNPROG[14]:="MANAG"
cNPROG[15]:="SII"
cNPROG[16]:="BLAG"

// {to zna~i da ovo indicira da li program koristi podatke drugog programa
// - master programa. Tako je master programa koji prenosi iz KALK u FIN -
// (program KALFAK) program KALK
cMProg[1]:="FIN"   // master program
cMProg[2]:="MAT"
cMPROG[3]:="KALK"
cMPROG[4]:="FAKT"
cMPROG[5]:="FAKT"
cMPROG[6]:="KALK"
cMPROG[7]:="LD"
cMPROG[8]:="OS"
cMProg[9]:="CKALK"
cMProg[10]:="CFAKT"
cMProg[11]:="VIRM"
cMProg[12]:="KAM"
cMPROG[13]:="ADMIN"
cMPROG[14]:="ADMIN"
cMPROG[15]:="SII"
cMPROG[16]:="BLAG"

// cTProgi title koji se pojavljuje u BAT-u
cTProg[1]:="FIN  - Finansijsko"
cTProg[2]:="MAT  - Materijalno"
cTPROG[3]:="KALK - robno/materijalno"
cTPROG[4]:="FAKT - Fakturisanje"
cTPROG[5]:="CJEN - Cjenovnik robe"
cTPROG[6]:="POR  - Obracun poreza u MP"
cTPROG[7]:="LD   - Obracun plata"
cTPROG[8]:="OS   - Osnovna sredstva"
cTPROG[9]:="CKALK - kalk konsignacija"
cTPROG[10]:="CFAKT - kalk fakture    "
cTPROG[11]:="VIRM - virmani"
cTPROG[12]:="KAM - kamate"
cTPROG[13]:="ADMIN - administracija"
cTPROG[14]:="MANAG - manager"
cTPROG[15]:="SII  - Sitan inventar"
cTPROG[16]:="BLAG  - Blagajna"


if cFmkInst=="N"

// imena programa
cnProg[1]:="TNAM"
cNProg[2]:="INKAS"
cNPROG[3]:="RVET"
cNPROG[4]:="KADEV"
cNPROG[5]:="SANK"
cNPROG[6]:="GRAD"
cNPROG[7]:="TOPS"
cNPROG[8]:="HOPS"
cNPROG[9]:="ZZ"
cNPROG[10]:="KK"
cNPROG[11]:="YY"
cNPROG[12]:="VV"
cNPROG[13]:="ADMIN"
cNPROG[14]:="VV"
cNPROG[15]:="VV"
cNPROG[16]:="VV"

cMProg[1]:="TNAM"  // master program
cMProg[2]:="INKAS"
cMPROG[3]:="RVET"
cMPROG[4]:="KADEV"
cMPROG[5]:="SANK"
cMPROG[6]:="GRAD"
cMPROG[7]:="TOPS"
cMPROG[8]:="HOPS"
cMProg[9]:="ZZ"
cMProg[10]:="KK"
cMProg[11]:="YY"
cMProg[12]:="VV"
cMProg[13]:="ADMIN"
cMProg[14]:="VV"
cMProg[15]:="VV"
cMProg[16]:="VV"

// cTProgi title koji se pojavljuje u BAT-u
cTProg[1 ]:="TNAM  trgovine na malo"
cTProg[2 ]:="INKAS inkasanti"
cTPROG[3 ]:="RVET  reprodukcija vet"
cTPROG[4 ]:="KADEV kadrovska evidencija"
cTPROG[5 ]:="SANK  sank jela i pica"
cTPROG[6 ]:="GRAD  gradjevinske ponude"
cTPROG[7 ]:="TOPS  trgovacka kasa"
cTPROG[8 ]:="HOPS  ugostiteljska kasa"
cTPROG[9 ]:="ZZ"
cTPROG[10]:="KK"
cTPROG[11]:="YY"
cTPROG[12]:="VV"
cTPROG[13]:="ADMIN"
cTPROG[14]:="VV"
cTPROG[15]:="VV"
cTPROG[16]:="VV"

endif

for i:=1 to nPrograma
	cPom:=alltrim(str(i))
  	@ i+3,1 SAY padr("Instalise se: "+cTprog[i],55,".") GET cPROG&cpom valid cprog&cpom $ "DN" pict "@!"
  	read
next
read

cls

cDN:="D"
do while .t.
	@ 7,1 SAY "Za koliko se firmi program instalise"  GET nFirmi pict "99" valid nfirmi < 61 .and. nFirmi>0
	read
	for i:=1 to nFirmi
 		cPom:=alltrim(str(i))
 		IF EMPTY(cnf&cPom)
   			cnf&cPom := PADR( "Firma "+cPom , 20 )
 		ENDIF
 		@ 8,1 SAY "Sifra, naziv firme  "+str(i,2)+":" GET cSF&cPom
 		@ 8,col()+2 GET cnf&cPom
 		read
	next
	?
	@ 10,1 SAY "Sifre firmi su respektivno :"
	? " "
	for i:=1 to nFirmi
   		cPom:=alltrim(str(i))
   		?? cSF&cPom+" "
	next
	@ 14,1 SAY "Ispravno (D/N) ?" GET cDN valid cDN $ "DN" pict "@!"
	read
	if cDN=="D"
		exit
	endif
enddo

if !fmem
	cRS:="1"
endif
@ 15,1 SAY "Broj radne stanice na koju se vrsi instalacija: " GET cRS valid CRS $ "123456789A" pict "@!"
read

DO WHILE .T.
	cls
	if !fmem
 		cBDir1:=padr("C:\SIGMA",20)
	else
 		cBDir1:=padr(cBdir1,20)
	endif
	nmk:=0

	if !fmem
 		cBDir2:=padr("C:\SIGMA",20)
	else
 		cBDir2:=padr(cBDir2,20)
	endif
	cBDir9:=padr("",20)

	cExeDir:=space(20)
	@ 1,1 SAY "Bazni direktorij SERVERA:" get cBDir2
	@ 2,1 SAY "Bazni direktorij RS:     " get cBDir1
	@ 3,1 SAY "Sek.  direktorij SERVERA:" get cBDir9
	if cFullpath=="D"
		@ 4,1 SAY "Direktorij EXE fajlova  :" get cExeDir pict "@!" when {|| cExeDir:=cBDir2,.t.}
	endif
	@ 5,1 SAY "Svaka firma posebno sifrarnici:" get cPosSif pict "@!" valid cPosSif $"DN"
	read


	cBDir2:=alltrim(cBDir2)
	cDrive2:=left(cBdir2,At(":",cBdir2))
	cBDir1:=alltrim(cBDir1)
	cDrive1:=left(cBdir1,At(":",cBdir1))
	cDrive9:=left(cBdir9,At(":",cBdir9))

	cBDir9:=alltrim(cBDir9)

	cDN:="D"
	@ 6,1 SAY "Ispravno (D/N) ?" GET cDN valid cDN $ "DN" pict "@!"
read

save to install.mem

if cDN=="D"
	nmk:=mkdir(cBDir2)
 	if nmk==3
		? "Ne mogu kreirati direktorij ", cbdir2
		quit
	endif
 	nmk:=mkdir(cBDir1)
 	if nmk==3
		? "Ne mogu kreirati direktorij ", cbdir1
		quit
	endif
 	exit
endif

ENDDO

#define NL Chr(13)+Chr(10)

**********************************
**********************************
cls
cBoot:=padr("C:\",10)
@ 1,1 SAY "Gdje se nalazi autoexec.bat, config.sys" get cBoot
read
cboot:=alltrim(cBoot)
@ 3,1 SAY "1. U autoexec.bat-u se u PATH mora postaviti "+cBdir1
@ 4,1 SAY "2. U autoexec.bat se mora postaviti linija SET CLIPPER=F:90;"
@ 5,1 SAY "3. U config.sys mora biti postavljeno FILES=100"
@ 6,1 SAY "4. Ako u config.sys postoji linija DEVICE=...EMM386.EXE NOEMS ..."
@ 7,1 SAY "   parametar NOEMS mora biti zamjenjen sa RAM !"
cDn:="N"
@ 9,1 SAY "Zelite li da ovo uradimo umjesto vas (D/N) ?" GET cDN pict "@!" valid cdn $ "DN"
read

if cDN=="D"

copy file (cBoot+"autoexec.bat") to (cBoot+"autoexec.old")
copy file (cBoot+"config.sys") to (cBoot+"config.old")

nH:=fopen(cBoot+"autoexec.old")
nhO:=fcreate(cBoot+"autoexec.bat")
cLine:=""
do while .t.
  cLine:=freadln(nH,1,200)
  if upper(cLine)="SET PATH=%PATH%;"
    // nista
  elseif upper(cLine)="SET CLIPPER=F:90;"
  else
     fwrite(nHO,cLine)
  endif
  if cline==""
    exit
  endif
enddo
fwrite(nHo,NL+"SET PATH=%PATH%;"+cBDir1+NL)
fwrite(nHo,"SET CLIPPER=F:90;"+NL)
fclose(nH)
fclose(nHO)


nH:=fopen(cBoot+"config.old")
nHO:=fcreate(cBoot+"config.sys")
cLine:=""
fnoems:=.f.
do while .t.
  cLine:=freadln(nH,1,200)
  if upper(cLine)="FILES=250"
    // nista
  elseif ("EMM386.EXE" $ upper(cline))  .and.  ("NOEMS" $ upper(cLine)) .and. !("REM " $ upper(cline))
    cline:=upper(cLine)
    cLine:=strtran(cLine,"NOEMS","RAM")
    fwrite(nHO,cLine)
    fNOEMS:=.t.
  else
     fwrite(nHO,cLine)
  endif
  if cline==""
    exit
  endif
enddo
fwrite(nHO,NL+"FILES=250")
fclose(nH)
fclose(nHO)
cls

if fnoems
    ? "Resetujte racunar i ponovo pokrenite instalaciju  !"
    quit
endif

endif

? "Kreiram direktorije"
*****************************
for i=1 to nPrograma
   cPom:=alltrim(str(i))
   if  cProg&cPom=="D"  // program 1 se instalise
      nmk:=mkdir(cBDir1+"\"+cMProg[i])
      if nmk==3; ? "Ne mogu kreirati direktorij ",cBDir1+"\"+cMProg[i]; quit; endif
      nmk:=mkdir(cBDir2+"\"+cmProg[i])
      if nmk==3; ? "Ne mogu kreirati direktorij ",cBDir2+"\"+cmProg[i]; quit; endif

      for ii=1 to nFirmi
        cPom3:=cBDir1+"\"+cMProg[i]+"\"+alltrim(str(ii,2))+cRS
        mkdir(cPom3)
        if nmk==3; ? "Ne mogu kreirati direktorij ",cPom3; quit; endif
        cPom3:=cBDir2+"\"+cMProg[i]+"\KUM"+alltrim(str(ii,2))
        mkdir(cPom3)
        if cPosSif=="D"
         cPom3:=cBDir2+"\SIF"+alltrim(str(ii,2))
         mkdir(cPom3)
        endif
        if nmk==3; ? "Ne mogu kreirati direktorij ",cPom3; quit; endif
      next
   endif
next
if cPosSif=="N"
 cPom2:=cbdir2+"\sif"
 mkdir(cpom2)
 if nmk==3; ? "Ne mogu kreirati direktorij ",cPom2; quit; endif
endif

cFMkString:="FMK"
if cFMkInst=="N"
 cFMKString:="EXT"
endif



? "Kreiram fajl "+cBDir1+" LISTA.ARH"
***************** fmk.bat **************
nH:=fcreate(cBDir1+"\LISTA.ARH")
if nh==-1; ?; ? "Greska pri formiranju fajla LISTA.ARH"; quit; endif
aModuli:={}; aSifr:={}
for i=1 to nPrograma
  cPom:=alltrim(str(i))
  if cProg&cPom=="D".and.ASCAN(aModuli,cMProg[i])==0  // program se instalise
    AADD(aModuli,cMProg[i])
    fwrite(nH,cBDir1+"\"+cMProg[i]+"\*.db?"+NL)
    fwrite(nH,cBDir1+"\"+cMProg[i]+"\*.fp?"+NL)
    IF !(cBDir1==cBDir2)
      fwrite(nH,cBDir2+"\"+cMProg[i]+"\*.db?"+NL)
      fwrite(nH,cBDir2+"\"+cMProg[i]+"\*.fp?"+NL)
    ENDIF
    for ii=1 to nFirmi
      fwrite(nH,cBDir1+"\"+cMProg[i]+"\"+alltrim(str(ii,2))+cRS+"\*.db?"+NL)
      fwrite(nH,cBDir1+"\"+cMProg[i]+"\"+alltrim(str(ii,2))+cRS+"\*.fp?"+NL)
      fwrite(nH,cBDir2+"\"+cMProg[i]+"\KUM"+alltrim(str(ii,2))+"\*.db?"+NL)
      fwrite(nH,cBDir2+"\"+cMProg[i]+"\KUM"+alltrim(str(ii,2))+"\*.fp?"+NL)
      if cPosSif=="D".and.ASCAN(aSifr,"SIF"+alltrim(str(ii,2)))==0
        AADD(aSifr,"SIF"+alltrim(str(ii,2)))
        fwrite(nH,cBDir2+"\SIF"+alltrim(str(ii,2))+"\*.db?"+NL)
        fwrite(nH,cBDir2+"\SIF"+alltrim(str(ii,2))+"\*.fp?"+NL)
      endif
    next
  endif
next
if cPosSif=="N"
 fwrite(nH,cbdir2+"\sif\*.db?"+NL)
 fwrite(nH,cbdir2+"\sif\*.fp?"+NL)
endif
fclose(nH)



? "Kreiram "+cFMkString+cRs+".bat"
***************** fmk.bat **************
nH:=fcreate(cBDir1+"\"+cFMkString+cRs+".bat")
if nh==-1; ?;? "Greska pri formiranju fajla "+cFMkString+".bat"; quit; endif
fwrite(nh,"@echo off"+NL)
fwrite(nh,"call "+cFMkString+"mrez.bat"+NL)
fwrite(nh,"cls"+NL)
fwrite(nh,"be beep /D1 /F200"+NL)
fwrite(nh,"be beep /D3 /F250"+NL)
fwrite(nh,":ponovo"+NL)
fwrite(nh,"cls"+NL)
fwrite(nh,"@ echo --------- * "+cFMkString+" * sigma-com software ----- RS br. "+cRS+NL)
fwrite(nh,"@ echo ."+NL)

if nFirmi>15
 fwrite(nH,"@ echo Odabir firme 01-"+str(nfirmi)+NL)
else
 for i:=1 to nFirmi
  cPom:="@ echo "
  cPom+=str(i,2)
  cPom+=". "
  cPom2:=alltrim(str(i))
  cPom+=trim(cnf&cPom2); cPom+=" - "+cSF&cPom2
  fwrite(nH,cPom+NL)
 next
endif

fwrite(nH,"@ echo ------------------------------"+NL)
fwrite(nH,"@ echo "+str(97,2)+". arhiviraj sve"+NL)
fwrite(nH,"@ echo "+str(98,2)+". pocisti i instalisi"+NL)
fwrite(nH,"@ echo ------------------------------"+NL)
fwrite(nH,"@ echo "+str(99,2)+". Kraj"+NL)
fwrite(nH,"@ echo ."+NL)
fwrite(nH,"@ echo ."+NL)

cPom:=""
for i:=1 to nFirmi
 if nFirmi==10
  cPom+="A"
 else
  cPom+=str(i,1)
 endif
next

// ne valja fwrite(nH,iif(cFullpath='D',trim(cExeDir)+'\','')+'be2'+NL)
fwrite(nH,'be2'+NL)

fwrite(nH,"if errorlevel  99 goto KRAJ"+NL)
fwrite(nH,"if errorlevel  98 goto C"+cFMkString+cRs+NL)
fwrite(nH,"if errorlevel  97 goto ASVE"+NL)
for i:=nFirmi to 1 step -1
  cPom:="if errorlevel "+str(i)+" goto "
  cPom+="Firma"+alltrim(str(i))+cRs
  fwrite(nH,cPom+NL)
next
fwrite(nH,"goto ponovo"+NL+NL)

for i:=1 to nFirmi
  fwrite(nh,":firma"+alltrim(str(i))+cRs+NL)
  fwrite(nh,"call firma"+alltrim(str(i))+cRs+NL)
  fwrite(nh,"goto ponovo"+NL+NL)
next

cls
beep(1)
cMedij:="A"
@ 20,1 SAY "Arhiviranje ce se vrsiti na Floppy/ZIP/CD izmjenljivu jedinicu A/B/D/E/F/G/H" GET cMedij pict "@!"  valid cMedij $ "ABDEFGH"
read

fwrite(nH,":C"+cFMkString+cRs+NL)
fwrite(nH,"cls"+NL)
fwrite(nH,cDrive1+NL)
fwrite(nH,"cd "+cBDir1+NL)
fwrite(nH,"call c"+cFMkString+cRs+NL)
fwrite(nH,cDrive1+NL)
fwrite(nH,"cd "+cBDir1+NL)
fwrite(nH,"goto ponovo"+NL)

fwrite(nH,":ASVE"+NL)
fwrite(nH,"cls"+NL)
fwrite(nH,cDrive2+NL)
fwrite(nH,"cd "+cBDir2+NL)
fwrite(nH,"echo MENI: ARHIVIRANJE SVIH PODATAKA"+NL)
fwrite(nH,"echo -------------------------------"+NL)
if cMedij>"B"
fwrite(nH,"echo  1. Arhiviranje na CD/ZIP medije"+NL)
else
fwrite(nH,"echo  1. Arhiviranje na flopy diskete "+NL)
endif
fwrite(nH,"echo  2. Arhiviranje na tvrdi disk"+NL)
fwrite(nH,"echo  3. Brisanje diskete"+NL)
fwrite(nH,"echo  4. Formatiranje diskete"+NL)
fwrite(nH,"echo  5. Pregled sadrzaja diskete"+NL)
fwrite(nH,"echo  9. Prethodni meni"+NL)
fwrite(nH,"echo -------------------------------"+NL)
fwrite(nH,'be ask "Izaberite opciju (1/2/3/4/5/9): "  123459 DEFAULT=9'+NL)
fwrite(nH,"echo ."+NL)
fwrite(nH,"if errorlevel==6 goto ponovo"+NL)
fwrite(nH,"if errorlevel==5 goto FDDDIR"+NL)
fwrite(nH,"if errorlevel==4 goto FDDFOR"+NL)
fwrite(nH,"if errorlevel==3 goto FDDBRI"+NL)
fwrite(nH,"if errorlevel==2 goto ANAHDD"+NL)
fwrite(nH,"if errorlevel==1 goto ANAFDD"+NL)
fwrite(nH,"goto ASVE"+NL)

fwrite(nH,":FDDBRI"+NL)
fwrite(nH,"cls"+NL)
if cMedij>"B"
fwrite(nH,"echo Stavite ZIP/CD u ureðaj i pritisnite neku tipku"+NL)
else
fwrite(nH,"echo Stavite flopy disketu i pritisnite neku tipku"+NL)
endif
fwrite(nH,"pause"+NL)
if cMedij>"B"
fwrite(nH,"echo Za brisanje sadrzaja ZIP diskete/CDa kucajte Y!"+NL)
else
fwrite(nH,"echo Za brisanje sadrzaja flopy diskete kucajte Y!"+NL)
endif
fwrite(nH,"del "+cMedij+":."+NL)
fwrite(nH,cDrive1+NL)
fwrite(nH,"cd "+cBDir1+NL)
fwrite(nH,"cls"+NL)
fwrite(nH,"goto ASVE"+NL)

fwrite(nH,":FDDFOR"+NL)
fwrite(nH,"cls"+NL)
if cMedij>"B"
fwrite(nH,"echo Stavite ZIP/CD i pritisnite neku tipku za pocetak formatiranja"+NL)
else
fwrite(nH,"echo Stavite floppy disketu i pritisnite neku tipku za pocetak formatiranja"+NL)
endif
fwrite(nH,"format "+cMedij+":"+NL)
fwrite(nH,cDrive1+NL)
fwrite(nH,"cd "+cBDir1+NL)
fwrite(nH,"cls"+NL)
fwrite(nH,"goto ASVE"+NL)

fwrite(nH,":FDDDIR"+NL)
fwrite(nH,"cls"+NL)
if cMedij>"B"
fwrite(nH,"echo Stavite ZIP/CD u ureðaj i pritisnite neku tipku radi pregleda sadrzaja"+NL)
else
fwrite(nH,"echo Stavite floppy disketu i pritisnite neku tipku radi pregleda sadrzaja diskete"+NL)
endif
fwrite(nH,"pause"+NL)
fwrite(nH,"dir "+cMedij+": /p"+NL)
fwrite(nH,"echo Pregled zavrsen! Pritisnite neku tipku za nastavak."+NL)
fwrite(nH,"pause"+NL)
fwrite(nH,cDrive1+NL)
fwrite(nH,"cd "+cBDir1+NL)
fwrite(nH,"cls"+NL)
fwrite(nH,"goto ASVE"+NL)

fwrite(nH,":ANAFDD"+NL)

fwrite(nH,"cls"+NL)
fwrite(nH,"echo MENI: ARHIVIRANJE SVIH PODATAKA"+NL)
fwrite(nH,"echo -------------------------------------------------"+NL)
fwrite(nH,"echo  1. Arhivirati samo podatke tekuce sezone"+NL)
fwrite(nH,"echo  2. Arhivirati sve podatke (tekuca+prosle sezone)"+NL)
fwrite(nH,"echo  9. Prethodni meni"+NL)
fwrite(nH,"echo -------------------------------------------------"+NL)
fwrite(nH,'be ask "Izaberite opciju (1/2/9): "  129 DEFAULT=9'+NL)
fwrite(nH,"echo ."+NL)
fwrite(nH,"if errorlevel==3 goto ASVE"+NL)
fwrite(nH,"if errorlevel==2 goto ANAFDDS"+NL)
fwrite(nH,"if errorlevel==1 goto ANAFDDT"+NL)
fwrite(nH,"goto ANAFDD"+NL)



fwrite(nH,":ANAFDDS"+NL)
fwrite(nH,"cls"+NL)
if cMedij>"B"
  fwrite(nH,"echo Stavite ZIP/CD u ureðaj i pritisnite neku tipku za pocetak arhiviranja"+NL)
  else
  fwrite(nH,"echo Stavite floppy disketu i pritisnite neku tipku za pocetak arhiviranja"+NL)
endif
fwrite(nH,"pause"+NL)
if cMedij>"B"
  fwrite(nH,"del "+cMedij+":\"+cFMKString+"S.BAK"+NL)
  fwrite(nH,"copy "+cMedij+":\"+cFMKString+"S.ARJ "+cMedij+":\"+cFMKString+"S.BAK"+NL)
  fwrite(nH,"del "+cMedij+":\"+cFMKString+"S.ARJ"+NL)
endif
if cMedij>"B"
  fwrite(nH,"arj a -vva -r -jt "+cMedij+":\"+cFMkString+"S "+cBdir2+"\*.db? "+cBDir2+"\*.fp? "+cBDir2+"\*.ini "+cBDir2+"\*.bat "+cBDir2+"\*.rtm "+cBDir2+"\*.txt "+NL)
  else
  fwrite(nH,"arj a -vva -r -jt "+cMedij+":\"+cFMkString+"S "+cBdir2+"\*.db? "+cBDir2+"\*.fp? "+cBDir2+"\*.ini "+NL)
endif
if !empty(cBDir9)
  fwrite(nH,"arj a -vva -r -jt "+cMedij+":\"+cFMkString+"S "+cBdir9+"\*.db? "+cBDir9+"\*.fp? "+NL)
endif
  fwrite(nH,"goto ANAFDDK"+NL)



fwrite(nH,":ANAFDDT"+NL)
fwrite(nH,"cls"+NL)
if cMedij>"B"
fwrite(nH,"echo Stavite ZIP/CD u ureðaj i pritisnite neku tipku za pocetak arhiviranja"+NL)
else
fwrite(nH,"echo Stavite floppy disketu i pritisnite neku tipku za pocetak arhiviranja"+NL)
endif
fwrite(nH,"pause"+NL)
if cMedij>"B"
fwrite(nH,"del "+cMedij+":\"+cFMKString+".BAK"+NL)
fwrite(nH,"copy "+cMedij+":\"+cFMKString+".ARJ "+cMedij+":\"+cFMKString+".BAK"+NL)
fwrite(nH,"del "+cMedij+":\"+cFMKString+".ARJ"+NL)
endif
fwrite(nH,"arj a -vva -jt "+cMedij+":\"+cFMkString+" !"+cBdir2+"\LISTA.ARH"+NL)
if !empty(cBDir9)
fwrite(nH,"arj a -vva -jt "+cMedij+":\"+cFMkString+" !"+cBdir9+"\LISTA.ARH"+NL)
endif
fwrite(nH,"goto ANAFDDK"+NL)



fwrite(nH,":ANAFDDK"+NL)            // kraj
fwrite(nH,"echo Arhiviranje zavrseno! Pritisnite neku tipku za nastavak."+NL)
fwrite(nH,"pause"+NL)
fwrite(nH,cDrive1+NL)
fwrite(nH,"cd "+cBDir1+NL)
fwrite(nH,"cls"+NL)
fwrite(nH,"goto ASVE"+NL)

fwrite(nH,":ANAHDD"+NL)
fwrite(nH,"cls"+NL)
fwrite(nH,cDrive2+NL)
fwrite(nH,"cd "+cBDir2+NL)
fwrite(nH,"echo Pritisnite bilo koju tipku za pocetak arhiviranja na tvrdi disk"+NL)
fwrite(nH,"pause"+NL)
fwrite(nH,"del \"+cFMkString+".arj"+NL)
fwrite(nH,"arj a -r -jt \"+cFMkString+" *.db? *.fp? *.ini *.bat *.txt *.rtm *.txt "+NL)
if !empty(cBDir9)
fwrite(nH,cDrive9+NL)
fwrite(nH,"cd "+cBDir9+NL)
fwrite(nH,"del \"+cFMkString+".arj"+NL)
fwrite(nH,"arj a -r -jt \"+cFMkString+" *.db? *.fp? *.ini *.bat *.txt *.rtm *.txt "+NL)
endif

fwrite(nH,"echo Arhiviranje zavrseno! Pritisnite neku tipku za nastavak."+NL)
fwrite(nH,"pause"+NL)
fwrite(nH,cDrive1+NL)
fwrite(nH,"cd "+cBDir1+NL)
fwrite(nH,"cls"+NL)
fwrite(nH,"goto ASVE"+NL)
fwrite(nH,":KRAJ"+NL)
fwrite(nH,"cls"+NL)

fclose(nH)



? "Kreiram c"+cFMkString+cRs+".bat"
***************** cfmk.bat **************
nH:=fcreate(cBDir1+"\c"+cFMkString+cRs+".bat")
if nh==-1; ?;? "Greska pri formiranju fajla cfmk.bat"; quit; endif
fwrite(nh,"@echo off"+NL)
fwrite(nh,"cls"+NL)
fwrite(nh,":ponovo"+NL)
fwrite(nh,"echo ."+NL)
fwrite(nh,"echo ."+NL)
fwrite(nh,"echo ."+NL)
fwrite(nh,'be ask "Zelite li izbrisati indeksne fajlove D/N : "  nd DEFAULT=N'+NL)
fwrite(nh,"echo ."+NL)
fwrite(nh,"if errorlevel==2 goto ntx"+NL)

fwrite(nh,":p2"+NL)
fwrite(nh,'be ask "Zelite li izvrsiti modifikacije struktura D/N : "  nd DEFAULT=N'+NL)
fwrite(nh,"echo ."+NL)
fwrite(nh,"if errorlevel==2 goto amodstru"+NL)
fwrite(nh,"goto p3"+NL)

fwrite(nh,":p3"+NL)
fwrite(nh,'be ask "Zelite li izvrsiti install  D/N : "  nd DEFAULT=N'+NL)
fwrite(nh,"echo ."+NL)
fwrite(nh,"if errorlevel==2 goto inst"+NL)
fwrite(nh,"goto end"+NL)

fwrite(nh,":amodstru"+NL)
fwrite(nh,'be ask "Zelite li izvrsiti modifikaciju struktura i u sezonama D/N : "  nd DEFAULT=N'+NL)
fwrite(nh,"echo ."+NL)
fwrite(nh,"if errorlevel==2 goto smodstru"+NL)
fwrite(nh,"goto modstru"+NL)





fwrite(nh,":ntx"+NL)
fwrite(nh,cDrive1+NL)                // c:
fwrite(nh,"cd "+cBDir1+NL)           // cd c:\e
for i=1 to nPrograma
   cPom:=alltrim(str(i))
   if  cProg&cPom=="D" .and. (cMProg[i]==cNProg[i])  // program 1 se instalise
      fwrite(nh,"del "+cMProg[i]+"\*.ntx"+NL)
      fwrite(nh,"del "+cMProg[i]+"\*.cdx"+NL)
      fwrite(nh,"del "+cMProg[i]+"\*.idx"+NL)
      for ii=1 to nFirmi
        cPom2:=alltrim(str(ii))
        fwrite(nh,"del "+cMProg[i]+"\"+alltrim(str(ii,2))+cRS+"\*.ntx"+NL)
        fwrite(nh,"del "+cMProg[i]+"\"+alltrim(str(ii,2))+cRS+"\*.cdx"+NL)
        fwrite(nh,"del "+cMProg[i]+"\"+alltrim(str(ii,2))+cRS+"\*.idx"+NL)
      next
   endif

next

fwrite(nh,cDrive2+NL)                // f:
fwrite(nh,"cd "+cBDir2+NL)           // cd f:\e
for i=1 to nPrograma
   cPom:=alltrim(str(i))
   if  cProg&cPom=="D" .and. (cMProg[i]==cNProg[i]) // program 1 se instalise
      fwrite(nh,"del "+cNProg[i]+"\*.ntx"+NL)   // del fin\*.ntx
      fwrite(nh,"del "+cNProg[i]+"\*.cdx"+NL)   // del fin\*.ntx
      fwrite(nh,"del "+cNProg[i]+"\*.idx"+NL)   // del fin\*.ntx
      for ii=1 to nFirmi
        fwrite(nh,"del "+cNProg[i]+"\KUM"+alltrim(str(ii,2))+"\*.ntx"+NL)
        fwrite(nh,"del "+cNProg[i]+"\KUM"+alltrim(str(ii,2))+"\*.cdx"+NL)
        fwrite(nh,"del "+cNProg[i]+"\KUM"+alltrim(str(ii,2))+"\*.idx"+NL)
      next
   endif

next

if cPosSif=="D"
  for ii:=1 to nFirmi
   fwrite(nh,"del "+"SIF"+alltrim(str(ii,2))+"\*.ntx"+NL)
   fwrite(nh,"del "+"SIF"+alltrim(str(ii,2))+"\*.cdx"+NL)
   fwrite(nh,"del "+"SIF"+alltrim(str(ii,2))+"\*.idx"+NL)
  next
else
  fwrite(nh,"del "+"SIF\*.ntx"+NL)
  fwrite(nh,"del "+"SIF\*.cdx"+NL)
  fwrite(nh,"del "+"SIF\*.idx"+NL)
endif

fwrite(nh,"cls"+NL)
fwrite(nh,"goto p2"+NL)

fwrite(nh,":modstru"+NL)
fwrite(nh,cDrive1+NL)                // f:
fwrite(nh,"cd "+cBDir1+NL)           // cd f:\e
for i=1 to nPrograma
   cPom:=alltrim(str(i))
   if  cProg&cPom=="D" .and. (cMProg[i]==cNProg[i]) // program 1 se instalise
      for ii=1 to nFirmi
       fwrite(nh,"cd "+cBDir1+"\"+cNProg[i]+NL)
        // fwrite(nh,"i"+cNProg[i]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /M"+NL)
        fwrite(nh,cNProg[i]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /M /INSTALL"+NL)
      next
   endif

next
fwrite(nh,"goto p3"+NL)

fwrite(nh,":smodstru"+NL)
fwrite(nh,cDrive1+NL)                // f:
fwrite(nh,"cd "+cBDir1+NL)           // cd f:\e
for i=1 to nPrograma
   cPom:=alltrim(str(i))
   if  cProg&cPom=="D" .and. (cMProg[i]==cNProg[i]) // program 1 se instalise
      for ii=1 to nFirmi
       fwrite(nh,"cd "+cBDir1+"\"+cNProg[i]+NL)
        // fwrite(nh,"i"+cNProg[i]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /XM"+NL)
        fwrite(nh,cNProg[i]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /XM /INSTALL"+NL)
      next
   endif

next
fwrite(nh,"goto p3"+NL)

fwrite(nh,":inst"+NL)
fwrite(nh,cDrive1+NL)                // f:
fwrite(nh,"cd "+cBDir1+NL)           // cd f:\e
for i=1 to nPrograma
   cPom:=alltrim(str(i))
   if  cProg&cPom=="D" .and. (cMProg[i]==cNProg[i]) // program 1 se instalise
      for ii=1 to nFirmi
       fwrite(nh,"cd "+cBDir1+"\"+cNProg[i]+NL)
        // fwrite(nh,"i"+cNProg[i]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /I "+NL)
        fwrite(nh,cNProg[i]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /I /INSTALL"+NL)
      next
   endif

next

fwrite(nh,"goto end"+NL)



fwrite(nh,":end"+NL)
fwrite(nh,"echo ."+NL)
fwrite(nh,"echo kraj...."+NL)

fclose(nH)





? "Kreiram novgodtt.bat"
***************** cfmk.bat **************
nH:=fcreate(cBDir1+"\novgodtt.bat")
if nh==-1; ?;? "Greska pri formiranju fajla novgodtt.bat"; quit; endif
fwrite(nh,"@echo off"+NL)
fwrite(nh,"cls"+NL)

fwrite(nh,cDrive1+NL)                // f:
fwrite(nh,"cd "+cBDir1+NL)           // cd f:\e
for i=1 to nPrograma
  IF cNProg[i] $ "KALK#FAKT#FIN#LD#OS"
    cPom:=alltrim(str(i))
    if  cProg&cPom=="D" .and. (cMProg[i]==cNProg[i]) // program 1 se instalise
       for ii=1 to nFirmi
        fwrite(nh,"cd "+cBDir1+"\"+cNProg[i]+NL)
         // fwrite(nh,cNProg[i]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /XN"+NL)
         fwrite(nh,cNProg[i]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /XN /INSTALL"+NL)
       next
    endif
  ENDIF
next

fclose(nH)




*****************************************
for ii:=0 to nFirmi
   cPom2:=alltrim(str(ii))
   if ii==0
     cPom:=cBDir1+"\"+cFMkString+".bat"
   else
     cPom:=cBdir1+"\firma"+cPom2+cRs+".BAT"
   endif
   nH:=fcreate(cpom)

   ? "Kreiram ",cPom


   fwrite(nh,"@echo off"+NL)
   fwrite(nh,":pocetak"+NL)
   fwrite(nh,"cls"+NL)
   if ii=0
     fwrite(nh,"@echo "+padc(cFMkString+" ** s-com",55,"*")+" %1"+NL)
   else
     fwrite(nh,"@echo "+padc(" "+alltrim(cNF&cpom2)+" - "+alltrim(cSF&cpom2)+" ",55,"*")+" RS br."+cRS+" ****"+NL)
   endif
   fwrite(nh,"@echo ."+NL)
   cPrompt:=""   // promt za be ask
   nPCount:=0 // broj programa koji se instalissu
   nPCount2:=0 // broj programa koji se instalissu
   aProcs:={}    // lista goto procedura
   for i:=1 to nPrograma
      cPom:=alltrim(str(i))
      if  cProg&cPom=="D"  // program 1 se instalise
          ++nPcount
          cSL:="A"
          chadd(@cSL,npcount-1)
          AADD(aProcs,{cNProg[i],cMProg[i]})
          cPrompt+=cSL
          cLine:="@echo "+cSL+". "+PADR(cTProg[i],25)
          if cMProg[i]==cNProg[i]  // master program = program
              cSL2:="K"
              nPCount2+=2
              chadd(@cSL2,npcount2-2)
              cPrompt+=cSL2
              AADD(aProcs,{"I"+cNProg[i],cMProg[i]})
              cLine+="    "+cSL2+". "+padr("install "+cNProg[i],12)
              cSL2:="K"
              chadd(@cSL2,npcount2-1)
              cPrompt+=cSL2
              AADD(aProcs,{"CALL ARHIVA",cMProg[i]})
              cLine+="    "+cSL2+". "+padr("arhiva "+cNProg[i],12)
          endif
          fwrite(nH,cLine+NL)
      endif
   next  // nprograma
   AADD(aProcs,{"KRAJ",""})
   fwrite(nh,"@echo "+replicate("-",70)+NL)
   cPrompt+="9"
   fwrite(nh,"@echo 9. Kraj"+NL)
   fwrite(nh,'be ask "->" '+cPrompt+" DEF=9 bright yellow"+NL)
   for j:=(nPCount2+nPcount+1) to 1 step -1
    if aProcs[j,1]="CALL ARHIVA"
      fwrite(nh,"if errorlevel "+str(j,2)+" goto A"+aProcs[j,2]+NL)
    else
      fwrite(nh,"if errorlevel "+str(j,2)+" goto "+aProcs[j,1]+NL)
    endif
   next
   fwrite(nh,"goto kraj"+NL)
   for j:=1 to (nPCount2+nPcount)
     if aProcs[j,1]="CALL ARHIVA"
       fwrite(nh,":A"+aprocs[j,2]+NL)
     else
       fwrite(nh,":"+aprocs[j,1]+NL)
     endif
     fwrite(nh,cDrive1+NL)
     fwrite(nh,"cd "+cBdir1+"\"+aProcs[j,2]+NL)
     if ii==0
       fwrite(nh,aProcs[j,1]+" %1 %1"+NL)
     else
       **donja linija primjer:  FIN  11 11 , IFIN 11 11
       if left(aProcs[j,1],1)=="I"
          fwrite(nh,iif(cFullpath='D',trim(cExeDir)+'\','')+SUBSTR(aProcs[j,1],2)+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /INSTALL"+NL)
       else
          fwrite(nh,iif(cFullpath='D'.and. left(aProcs[j,1],4)<>"CALL",trim(cExeDir)+'\','')+aProcs[j,1]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+NL)
       endif
       if left(aProcs[j,1],1)<>"I" .and. left(aProcs[j,1],4)<>"CALL"
//        fwrite(nh,"if errorlevel=57 I"+aProcs[j,1]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /I /R"+NL)
//        fwrite(nh,"if errorlevel=55 I"+aProcs[j,1]+" "+alltrim(str(ii,2))+cRS+" "+alltrim(str(ii,2))+cRS+" /M"+NL)
       endif
     endif
     fwrite(nh,"cd "+cBdir1+NL)
     fwrite(nh,"goto pocetak"+NL)
   next
   fwrite(nh,":kraj"+NL)
   fwrite(nh,"cls"+NL)

   fclose(nh)
next  // firma







***********************************
***********************************
cls
? "Otpakujem EXE fajlove"

?
UnZipuj("UT.ZIP",cBdir1)
for i:=1 to nPrograma
  cpom:=alltrim(str(i))
  cStr:="cd "+cBdir1+"\"+cnprog[i]
  if cProg&cpom=="D"                    //       ÚÄÄÄÄÄÄ !! master program
     UnZipuj(cnprog[i]+".ZIP",cBdir1)
  endif

next
UnZipuj("SIF.ZIP",cBdir2+"\SIF")



? "Kreiram KORISN.DBF fajlove"
for i:=1 to nprograma
 cpom:=alltrim(str(i))
if cProg&cpom=="D"
 for j:=1 to nFirmi
  cPom2:=alltrim(str(j))
  IF !FILE(cbdir1+"\"+cmprog[i]+"\Korisn.dbf")
   aDbf:={}
   AADD(aDbf,{"ime","C",10,0})
   AADD(aDbf,{"sif","C",6,0})
   AADD(aDbf,{"dat","D",8,0})
   AADD(aDbf,{"time","C",8,0})
   AADD(aDbf,{"prov","N",4,0})  // brojac neispravnih pokusaja ulaza
   AADD(aDbf,{"nk","L",1,0})
   AADD(aDbf,{"level","C",1,0})
   AADD(aDbf,{"DirRad","C",40,0})
   AADD(aDbf,{"DirSif","C",40,0})
   AADD(aDbf,{"DirPriv","C",40,0})
   DBCREATE2(cbdir1+"\"+cmprog[i]+"\Korisn",aDbf)
   USE (cbdir1+"\"+cmprog[i]+"\Korisn")

   APPEND BLANK
   REPLACE ime WITH "SYSTEM"        ,  ;
          sif WITH CryptSC("SYSTEM") ,  ;
          dat WITH  Date()         ,  ;
          time WITH Time()         ,  ;
          prov WITH 0              ,  ;
          level WITH "0"           ,  ;
          nk WITH .F.              ,  ;
          level with "0"           ,  ;
          DirRad  with             cbdir1+"\"+cmprog[i]  ,;
          DirSif  with             cbdir1+"\"+cmprog[i]  ,;
          DirPriv with             cbdir1+"\"+cmprog[i]
    USE
  ENDIF
 use // zatvori korisn.dbf
 CREATE_INDEX("IME","IME",cbdir1+"\"+cmprog[i]+"\Korisn.dbf",.t.)
 USE (cbdir1+"\"+cmprog[i]+"\Korisn")
 set order to tag "IME"
 seek cpom2+cRs
  cDN:="0"
  if !found()
    append blank
  else
    cDN:="N"
    Beep(1)
    VarEdit({{cmprog[i]+": Postaviti tekuce direktorije za korisnika "+cpom2+"-"+crs+" ?","cDN",,"@!",}},10,1,14,78,"Postojeci korisnik:","B1")
  endif
  if  cDN $ "0D"
    REPLACE ime WITH cpom2+crs        ,  ;
          sif WITH CryptSC(padr(cpom2+crs,6)) ,  ;
          dat WITH  Date()         ,  ;
          time WITH Time()         ,  ;
          prov WITH 0              ,  ;
          level WITH "0"           ,  ;
          nk WITH .F.              ,  ;
          level with "0"           ,  ;
          DirRad  with             cbdir2+"\"+cmprog[i]+"\kum"+cpom2  ,;
          DirSif  with             cbdir2+"\SIF"  ,;
          DirPriv with             cbdir1+"\"+cmprog[i]+"\"+cpom2+crs
     if cPosSif=="D"
        replace DirSif with cbdir2+"\SIF"+cpom2
     endif
   endif
   use
 next
endif
next
return
*}


/***
*
*  Fileio.prg
*  Sample user-defined functions to process binary files
*  Copyright, Nantucket Corporation, 1990
*
*  NOTE: compile with /n/w/a/m
*/

#include "Fileio.ch"

/***
*  FGets( <nHandle>, [<nLines>], [<nLineLength>], [<cDelim>] ) --> cBuffer
*  Read one or more lines from a text file
*
*/
FUNCTION FGets(nHandle, nLines, nLineLength, cDelim)
	RETURN FReadLn(nHandle, nLines, nLineLength, cDelim)

/***
*  FileTop( <nHandle> ) --> nPos
*  Position the file pointer to the first byte in a binary file and return
*  the new file position (i.e., 0).
*
*/
FUNCTION FileTop(nHandle)
	RETURN FSEEK(nHandle, 0)

/***
*  FileBottom( <nHandle> ) --> nPos
*  Position the file pointer to the last byte in a binary file and return
*  the new file position
*
*/
FUNCTION FileBottom(nHandle)
	RETURN FSEEK(nHandle, 0, FS_END)

/***
*  FilePos( <nHandle> ) --> nPos
*  Report the current position of the file pointer in a binary file
*
*/
FUNCTION FilePos(nHandle)
	RETURN FSEEK(nHandle, 0, FS_RELATIVE)

/***
*  FileSize( <nHandle> ) --> nBytes
*  Return the size of a binary file
*
*/
FUNCTION FileSize( nHandle )
   LOCAL nCurrent, nLength

   // Get file position
   nCurrent := FilePos(nHandle)

   // Get file length
   nLength := FSEEK(nHandle, 0, FS_END)

   // Reset file position
   FSEEK(nHandle, nCurrent)

   RETURN nLength

/***
*  FReadLn( <nHandle>, [<nLines>], [<nLineLength>], [<cDelim>] ) --> cLines
*  Read one or more lines from a text file
*
*  NOTE: Line length includes delimiter, so max line read is 
*        (nLineLength - LEN( cDelim ))
*
*  NOTE: Return value includes delimiters, if delimiter was read
*
*  NOTE: nLines defaults to 1, nLineLength to 80 and cDelim to CRLF
*
*  NOTE: FERROR() must be checked to see if FReadLn() was successful
*
*  NOTE: FReadLn() returns "" when EOF is reached
*
*/
FUNCTION FReadLn( nHandle, nLines, nLineLength, cDelim )
   LOCAL nCurPos, nFileSize, nChrsToRead, nChrsRead
   LOCAL cBuffer, cLines
   LOCAL nCount
   LOCAL nEOLPos

   IF nLines == NIL
      nLines := 1
   ENDIF

   IF nLineLength == NIL
      nLineLength := 80
   ENDIF

   IF cDelim == NIL
      cDelim := CHR(13) + CHR(10)
   ENDIF

   nCurPos   := FilePos( nHandle )
   nFileSize := FileSize( nHandle )

   // Make sure no attempt is made to read past EOF
   nChrsToRead := MIN( nLineLength, nFileSize - nCurPos )

   cLines  := ''
   nCount  := 1
   DO WHILE (nCount <= nLines) .AND. ( nChrsToRead != 0 ) 
      cBuffer   := SPACE( nChrsToRead )
      nChrsRead := FREAD( nHandle, @cBuffer, nChrsToRead )

      // Check for error condition
      IF ! (nChrsRead == nChrsToRead)
         // Error!
         // In order to stay conceptually compatible with the other
         // low-level file functions, force the user to check FERROR()
         // (which was set by the FREAD() above) to discover this fact
         //
         nChrsToRead := 0
      ENDIF

      nEOLPos := AT( cDelim, cBuffer )

      // Update buffer and current file position
      IF nEOLPos == 0
         cLines  += LEFT( cBuffer, nChrsRead )
         nCurPos += nChrsRead
      ELSE
         cLines  += LEFT( cBuffer, ( nEOLPos + LEN( cDelim ) ) - 1 )
         nCurPos += ( nEOLPos + LEN( cDelim ) ) - 1
         FSEEK( nHandle, nCurPos, FS_SET )
      ENDIF

      // Make sure we don't try to read past EOF
      IF (nFileSize - nCurPos) < nLineLength
         nChrsToRead := (nFileSize - nCurPos)
      ENDIF

      nCount++
   ENDDO

   RETURN cLines

/***
*  FEof( <nHandle> ) --> lBoundary
*  Determine if the current file pointer position is the last
*  byte in the file
*
*/
FUNCTION FEof( nHandle )
   RETURN (IF(FileSize(nHandle) == FilePos(nHandle), .T., .F. ))



#ifdef C50

#command INDEX ON <key> TO <(file)> [<u: UNIQUE>]                    ;
      => dbcreateindex(                                              ;
                        <(file)>, "d()+"+<(key)>,{|| d()+&(<(key)>)},  ;
                        if( <.u.>, .t., NIL )                        ;
                       )
function CREATE_INDEX(cImeInd,kljuc,cImeDbf,fsilent)

if !file(cImeInd+".NTX")
    use (cImedbf)
    index on (kljuc) to (cImeInd)
    use
endif
#endif
return


***************************
function ChADD(cC,n)
*
*
***************************
cC:=Chr(ASC(cC)+n)

*************************
*************************
function UnZipuj(cZip,cDir)


*do while .t.
*? "Stavite disketu sa "+czip+", i pritisnite tipku za nastavak ...(N-preskoci)."
*if upper(chr(inkey(0)))=="N"; exit; endif
*if !file(cZip)
*   cDN:="D"
*   ? "Fajl "+cZip+" se ne nalazi na ovoj disketi"
*   @ row()+1, 1 SAY "Zelite li pokusati ponovo (D/N) ?" get cDN pict "@!" valid cDN $ "DN"
*   if cdn=="D"
*       loop
*   endif
*endif
*cStr:="unzip "+czip+" "+cDir
*! &cStr
*exit
*enddo
**

******************
function Gproc()
****************
return

***********************
function Ucitajparams()
***********************


#ifdef C52
#include "h:\clipper\include\RDDINIT.CH"
#endif


function SkloniSezonu()


function SetScGVars()
*{

#ifdef CLIP
	? "start SetScGVars"
#endif
public ZGwPoruka:=""
public GW_STATUS:="-"

public GW_HANDLE:=0

public gModul:=""
public gVerzija:=""
public gAppSrv:=.f.
public gSQL:="N"
public ZGwPoruka:=""
public GW_STATUS:="-"
public GW_HANDLE:=0
public gReadOnly:=.f.
public gProcPrenos:="N"
public gInstall:=.f.
public gfKolor:="D"
public gPrinter:="1"
public gMeniSif:=.f.
public gValIz:="280 "
public gValU:="000 "
public gKurs:="1"
public gPTKONV:="0 "
public gPicSif:="V"
public gcDirekt:="V"
public gSKSif:="D"
public gSezona:="    "

public gShemaVF:="B5"

//counter - za testiranje
public gCnt1:=0


PUBLIC m_x
PUBLIC m_y
PUBLIC h[20]
PUBLIC lInstal:=.t.

//  .t. - korisnik je SYSTEM
PUBLIC System   
PUBLIC aRel:={}

PUBLIC cDirRad
PUBLIC cDirSif
PUBLIC cDirPriv
PUBLIC gNaslov

public gSezonDir:=""
public gRadnoPodr:="RADP"

public ImeKorisn:="" 
public SifraKorisn:=""
public KLevel:="9"

public gArhDir

public gPFont
gPFont:="Arial"

public gKodnaS:="8"
public gWord97:="N"
public g50f:=" "

//if !goModul:lStarted 
	public cDirPriv:=""
	public cDirRad:=""
	public cDirSif:=""
//endif

PUBLIC StaraBoja
StaraBoja:=SETCOLOR()

public System:=.f.
public gGlBaza:=""
public gSQL
public gSqlLogBase

PUBLIC  Invert:="N/W,R/N+,,,R/B+"
PUBLIC  Normal:="GR+/N,R/N+,,,N/W"
PUBLIC  Blink:="R****/W,W/B,,,W/RB"
PUBLIC  Nevid:="W/W,N/N"

PUBLIC gHostOS
gHostOS:="Win9X"

public cBteksta
public cBokvira
public cBnaslova
public cBshema:="B1"


#ifdef CLIP
	? "end SetScGVars"
#endif

return
*}

function PreUseEvent(cImeDbf,fShared)
*{
return cImeDbf
*}

