#include "\cl\sigma\fmk\os\os.ch"
 


function TDbOsNew()
*{
local oObj
oObj:=TDbOs():new()
oObj:self:=oObj
oObj:cName:="OS"
oObj:lAdmin:=.f.
return oObj
*}

/*! \file fmk/os/db/2g/db.prg
 *  \brief OS Database
 *
 * TDbOs Database objekat 
 */


/*! \class TDbOs 
 *  \brief Database objekat
 */


#ifdef CPP
class TDbOs: public TDB 
{
     public:
     	TObject self;
	string cName;
	*void dummy();
	*void skloniSezonu(string cSezona, bool finverse, bool fda, bool fnulirati, bool fRS);
	*void install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7);
	*void setgaDBFs();
	*void obaza(int i);
	*void ostalef();
	*void kreiraj(int nArea);
}
#endif

#ifndef CPP
#include "class(y).ch"
CREATE CLASS TDbOs INHERIT TDB

	EXPORTED:
	var    self
	var    cName
	method skloniSezonu
	method install	
	method setgaDBFs	
	method ostalef	
	method obaza	
	method kreiraj	
	method konvZn

END CLASS
#endif


/*! \fn *void TDbOs::dummy()
 */
*void TDbOs::dummy()
*{
method dummy
return
*}


/*! \fn *void TDbOs::setgaDbfs()
 *  \brief Setuje matricu gaDbfs 
 */
*void TDbOs::setgaDbfs()
*{
method setgaDBFs()

public gaDbfs := {;
{ F_INVENT, "INVENT", P_PRIVPATH },;
{ F_OS    , "OS"    , P_KUMPATH  },;
{ F_PROMJ , "PROMJ" , P_KUMPATH  },;
{ F_RJ    , "RJ"    , P_KUMPATH  },;
{ F_K1    , "K1"    , P_KUMPATH  },;
{ F_AMORT , "AMORT" , P_SIFPATH  },;
{ F_REVAL , "REVAL" , P_SIFPATH  },;
{ F_KONTO , "KONTO" , P_SIFPATH  },;
{ F_PARTN , "PARTN" , P_SIFPATH  },;
{ F_VALUTE, "VALUTE", P_SIFPATH  };
}

return
*}


/*! \fn *void TDbOs::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
 *  \brief osnovni meni za instalacijske procedure
 */

*void TDbOs::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
*{

method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	ISC_START(goModul,.f.)
return
*}

/*! \fn *void TDbOs::kreiraj(int nArea)
 *  \brief kreiranje baze podataka OS-a
 */
 
*void TDbOs::kreiraj(int nArea)
*{
method kreiraj(nArea)

if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

CreFMKSvi()


if (nArea==-1 .or. nArea==(F_OS))
	if !file(KUMPATH+"OS.DBF")
	   *********  OS.DBF   ***********
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
	   AADD(aDBf,{ 'IDRJ'                , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'Datum'               , 'D' ,   8 ,  0 })
	   AADD(aDBf,{ 'DatOtp'              , 'D' ,   8 ,  0 })
	   AADD(aDBf,{ 'OpisOtp'             , 'C' ,  30 ,  0 })
	   AADD(aDBf,{ 'IdKonto'             , 'C' ,   7 ,  0 })
	   AADD(aDBf,{ 'kolicina'            , 'N' ,   6 ,  1 })
	   AADD(aDBf,{ 'jmj'                 , 'C' ,   3 ,  0 })
	   AADD(aDBf,{ 'IdAm'                , 'C' ,   8 ,  0 })
	   AADD(aDBf,{ 'IdRev'               , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'NabVr'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'OtpVr'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'AmD'                 , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'AmP'                 , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'RevD'                , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'RevP'                , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'K1'                  , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
	   AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
	   AADD(aDBf,{ 'Opis'                , 'C' ,  25 ,  0 })
	   AADD(aDBf,{ 'BrSoba'              , 'C' ,   6 ,  0 })
	   AADD(aDBf,{ 'IdPartner'           , 'C' ,   6 ,  0 })

	   DBCREATE2(KUMPATH+'OS.DBF',aDbf)

	endif
	CREATE_INDEX("1","id+idam+dtos(datum)",KUMPATH+"OS")
	CREATE_INDEX("2","idrj+id+dtos(datum)",KUMPATH+"OS")
	CREATE_INDEX("3","idrj+idkonto+id",KUMPATH+"OS")
	CREATE_INDEX("4","idkonto+idrj+id",KUMPATH+"OS")
	CREATE_INDEX("5","idam+idrj+id",KUMPATH+"OS")
endif

/*
if !file(KUMPATH+"RJ.DBF")
   ************ rj *************
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  35 ,  0 })
   DBCREATE2(KUMPATH+'RJ.DBF',aDbf)
endif

CREATE_INDEX("ID","id",KUMPATH+"RJ")
CREATE_INDEX("NAZ","NAZ",KUMPATH+"RJ")
*/

if (nArea==-1 .or. nArea==(F_K1))
	if !file(KUMPATH+"K1.DBF")
	   ************ grupacije *************
	   aDBf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
	   DBCREATE2(KUMPATH+'K1.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id",KUMPATH+"K1")
	CREATE_INDEX("NAZ","NAZ",KUMPATH+"K1")
endif


if (nArea==-1 .or. nArea==(F_INVENT))
	if !file(PRIVPATH+'INVENT.dbf')
	        *********   INVENT.DBF   ***********
	        aDbf:={}
	        AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
	        AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
	        AADD(aDBf,{ 'KOLICINA'            , 'N' ,   6 ,  1 })
	        AADD(aDBf,{ 'IZNOS'               , 'N' ,  14 ,  2 })
	        DBCREATE2(PRIVPATH+'INVENT.DBF',aDbf)
	endif
	CREATE_INDEX("ID","Id",PRIVPATH+"INVENT") // Inventura
endif

if (nArea==-1 .or. nArea==(F_PROMJ))
	if !file(KUMPATH+"PROMJ.DBF")
	   *********  promj.DBF   ***********
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
	   AADD(aDBf,{ 'Opis'                , 'C' ,  30 ,  0 })
	   AADD(aDBf,{ 'Datum'               , 'D' ,   8 ,  0 })
	   AADD(aDBf,{ 'Tip'                 , 'C' ,   2 ,  0 })
	   AADD(aDBf,{ 'NabVr'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'OtpVr'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'AmD'                , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'AmP'                , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'RevD'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'RevP'               , 'N' ,  18 ,  2 })
	   DBCREATE2(KUMPATH+'Promj.DBF',aDbf)
	endif
	CREATE_INDEX("1","id+tip+dtos(datum)",KUMPATH+"PROMJ")
endif

if (nArea==-1 .or. nArea==(F_AMORT))
	if !file(SIFPATH+"AMORT.DBF")
	   *********  AMORT.DBF   ***********
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
	   AADD(aDBf,{ 'Iznos'               , 'N' ,   7 ,  3 })
	   DBCREATE2(SIFPATH+'AMORT.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id",SIFPATH+"AMORT")
endif

if (nArea==-1 .or. nArea==(F_REVAL))
	if !file(SIFPATH+"REVAL.DBF")
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  10 ,  0 })
	   AADD(aDBf,{ 'I1'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I2'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I3'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I4'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I5'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I6'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I7'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I8'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I9'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I10'                 , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I11'                 , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I12'                 , 'N' ,   7 ,  3 })
	   DBCREATE2(SIFPATH+'REVAL.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id",SIFPATH+"REVAL")
endif

return
*}



/*! \fn *void TDbOs::obaza(int i)
 *  \brief otvara odgovarajucu tabelu
 *  
 *      
 */

*void TDbOs::obaza(int i)
*{

method obaza(i)

local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_PARAMS 
	lIdiDalje:=.t.
endif

if i==F_OS .or. i==F_PROMJ .or. i==F_INVENT .or. i==F_REVAL .or. i==F_AMORT
	lIdiDalje:=.t.
endif

if i==F_KONTO .or. i==F_PARTN .or. i==F_RJ .or. i==F_K1 .or. i==F_VALUTE
	lIdiDalje:=.t.
endif

if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	select(i)
	usex(cDbfName)
else
	use
	return
endif


return
*}

/*! \fn *void TDbOs::ostalef()
 *  \brief Ostalef funkcije (bivsi install modul)
 *  \note  sifra: SIGMAXXX
*/

*void TDbOs::ostalef()
*{
method ostalef()

return
*}

/*! \fn *void TDbOs::konvZn()
 *  \brief koverzija 7->8 baze podataka OS-a
 */
 
*void TDbOs::konvZn()
*{
method konvZn() 
local cIz:="7"
local cU:="8"
local aPriv:={}
local aKum:={}
local aSif:={}
local GetList:={}
local cSif:="D"
local cKum:="D"
local cPriv:="D"

if !SigmaSif("KZ      ")
	return
endif

Box(,8,50)
	@ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  	@ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  	@ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  	@ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  	@ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  	read
  	if LastKey()==K_ESC
		BoxC()
		return
	endif
  	if Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    		BoxC()
		return
  	endif
BoxC()

aPriv:= { F_INVENT }
aKum:= { F_OS, F_PROMJ, F_RJ, F_K1 }
aSif:={ F_PARTN, F_KONTO, F_AMORT, F_REVAL }

if cSif=="N"
	aSif:={}
endif

if cKum=="N"
	aKum:={}
endif

if cPriv=="N"
	aPriv:={}
endif

KZNbaza(aPriv,aKum,aSif,cIz,cU)

return
*}



/*! \fn *void TDbOs::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
 *  \brief formiraj sezonsku bazu podataka
 *  \param cSezona - 
 *  \param fInverse - .t. iz sezone u radno, .f. iz radnog u sezonu
 *  \param fda - ne znam
 *  \param fnulirati - nulirati tabele
 *  \param fRS - ne znam
 */

*void TDbOs::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
*{

method skloniSezonu(cSezona,finverse,fda,fnulirati, fRS)
save screen to cScr

if (fda==nil)
	fDA:=.f.
endif
if (finverse==nil)
	finverse:=.f.
endif
if (fNulirati==nil)
	fnulirati:=.f.
endif
if (fRS==nil)
  // mrezna radna stanica , sezona je otvorena
  fRS:=.f.
endif

if fRS // radna stanica
  if file(PRIVPATH+cSezona+"\INVENT.DBF")
      // nema se sta raditi ......., pripr.dbf u sezoni postoji !
      return
  endif
  aFilesK:={}
  aFilesS:={}
  aFilesP:={}
endif

if KLevel<>"0"
	MsgBeep("Nemate pravo na koristenje ove opcije")
endif

cls

if fRS
   // mrezna radna stanica
   ? "Formiranje DBF-ova u privatnom direktoriju, RS ...."
endif

?

if fInverse
	? "Prenos iz  sezonskih direktorija u radne podatke"
else
 	? "Prenos radnih podataka u sezonske direktorije"
endif

?

fnul:=.f.
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"INVENT.DBF",cSezona,finverse,fda,fnul)
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


Skloni(KUMPATH,"OS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RJ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"K1.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"PROMJ.DBF",cSezona,finverse,fda,fnul)

Skloni(SIFPATH,"KONTO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"AMORT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"REVAL.DBF",cSezona,finverse,fda,fnul)



//sifrarnici
?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr

return
*}



*****************************************
function PrenesiUtekucu()
*
* prenesi iz sezonskog podrucja u tekucu
* trenutno se nalazim u sezonskom podrucju!
****************************************
*{
local cScr , nprolaz
local cBioUSezoni

if !sigmasif("OSPREN")
  msgbeep("Ne cackaj !")
  return
endif

MsgBeep("Trenutno se nalazim u sezonskom podrucju, sezona:"+right(goModul:oDataBase:cSezonDir,4)+;
        "##U ovom podrucju su unesene zavrsne promjene.#"+;
        "Sada zelite ovo stanje prenijeti u tekucu godinu (radno podrucje)#"+;
        "radi formiranja pocetnog stanja u tekucoj godini.##"+;
        "Ako sam u pravu, NASTAVITE. U suprotnom - PREKINITE PROCEDURU !")

if pitanje(,"Izvrsiti prenos podataka sezone: "+right(goModul:oDataBase:cSezonDir,4)+" u radno podrucje ?","N")=="N"
  return
endif

MsgO("Prelazim u radno podrucje....")
  cBioUsezoni:=right(goModul:oDataBase:cSezonDir,4)
  Uradpodr(.t.)
MsgC()

ZaSvakiSlucaj()  // !!!

save screen to cScr

fDA:=.f.
fnulirati:=.f.
finverse:=.t.

private aFilesP:={}
private aFilesS:={}
private aFilesK:={}
close all

if !PocSkSez()
 ::quit()
endif

cls

?

? "Prenos iz  sezonskih direktorija u radne podatke"
?

fnul:=.f.
Skloni(PRIVPATH,"PARAMS.DBF",cBioUsezoni,finverse,fda,fnul)

Skloni(KUMPATH,"OS.DBF",cBioUsezoni,finverse,fda,fnul)
Skloni(KUMPATH,"RJ.DBF",cBioUsezoni,finverse,fda,fnul)
Skloni(KUMPATH,"K1.DBF",cBioUsezoni,finverse,fda,fnul)
Skloni(KUMPATH,"PROMJ.DBF",cBioUsezoni,finverse,fda,fnul)

// necu konto on je sigurno ok ...Skloni(SIFPATH,"KONTO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"AMORT.DBF",cBioUsezoni,finverse,fda,fnul)
Skloni(SIFPATH,"REVAL.DBF",cBioUsezoni,finverse,fda,fnul)

//sifrarnici
?
?
?
Beep(4)
? "pritisni nesto za nastavak.."
inkey(0)
restore screen from cScr

KrajskSez()

msgbeep("Sada se nalazimo u radnom potrucju.##"+;
        "Provjerite da li su podaci korektno preneseni !##"+;
        "Nakon toga mozete izvrsiti opciju formiranja #"+;
        "pocetnog stanja sredstava u ovoj godini")


return
*}


********************************************************************
function PrenosOs()
*
*
* nalazim se u tekucoj godini, zelim "slijepiti" promjene i izbrisati
* otpisana sredstva u protekloj godini
********************************************************************
*{
Beep(4)
if Pitanje(,"Brisanje otpisanih sredstva i promjena u toku protekle godine ! Nastaviti ?","N")="N"
  closeret
endif

if !sigmaSif("OSGEN")
  closeret
endif

start print cret

O_OSX
O_PROMJX

? "Prolazim kroz bazu OS...."
select os; go top
do while !eof()
  nRbr:=0
  skip; nTRec:=recno(); skip -1
  Scatter("w")  // za os
  ? wid,naz
  wNabVr:=wNabvr+wrevd
  wOtpVr:=wOtpvr+wrevp+wAmp
  if !empty(wDatOtp)
     ?? "  brisem, otpisano"
     dbdelete2()
     go nTrec
     loop
  endif
  select promj; hseek os->id
  do while !eof() .and. id==os->id
   wNabVr+=nabvr+revd
   wOtpVr+=otpvr+revp+amp
   skip
  enddo
  select os
  wAmp:=wAmd:=0
  wRevD:=wRevP:=0
  Gather("w")

  go nTrec

enddo // eof

select promj
zap
close all

end print
return
*}


********************************************************************
function RegenPS()
*
* regeneracija nabavne i otpisane vrijednosti za stara sredstva
********************************************************************
*{
Beep(4)
if Pitanje(,"Ponovo generisati nab.i otpisanu vrijednost sredstava iz prosle godine ?","N")="N"
  closeret
endif

if !sigmaSif("OSREGEN")
  closeret
endif

O_OSX

// naÐimo sve postoje†e sezone
// ---------------------------
aSezone := ASezona(KUMPATH)
cTekSez := goModul:oDatabase:cSezona
FOR i:=LEN(aSezone) TO 1 STEP -1
  IF aSezone[i,1]>cTekSez .or. aSezone[i,1]<"1995" .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\OS.DBF") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\OS.CDX") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\PROMJ.DBF") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\PROMJ.CDX")
    ADEL(aSezone,i)
    ASIZE(aSezone,LEN(aSezone)-1)
  ENDIF
NEXT
ASORT(aSezone,,,{|x,y| x[1]>y[1]})

IF LEN(aSezone)<1
  MsgBeep("Nema proçlih sezona!")
  CLOSERET
ENDIF

// interesuje me samo posljednja od svih postoje†ih proçlih sezona
cOldSez:=aSezone[1,1]

USE (KUMPATH+cOldSez+"\OS")    NEW ALIAS ("OS"+cOldSez)
  SET ORDER TO TAG "1"
USE (KUMPATH+cOldSez+"\PROMJ") NEW ALIAS ("PROMJ"+cOldSez)
  SET ORDER TO TAG "1"

START PRINT CRET

cMP:="9999999.99"

? "Prikaz razlika nastalih ponovnom generacijom nabavne i otp.vrijednosti"
?
? "R.broj³ Inv.broj ³       Naziv sredstva         ³Stara NabV³Stara OtpV³Nova NabV ³Nova OtpV ³Razlika NV³Razlika OV"
? " (1)  ³    (2)   ³            (3)               ³   (4)    ³   (5)    ³    (6)   ³    (7)   ³  (6)-(4) ³  (7)-(5) "
m:="------ ---------- ------------------------------ ---------- ---------- ---------- ---------- ---------- ----------"
? m
SELECT OS; GO TOP

nRbr:=0
nT1:=nT2:=nT3:=nT4:=nT5:=nT6:=0
DO WHILE !EOF()
  SKIP; nTRec:=RECNO(); SKIP -1
  cInvBr:=id    // OS->id
  SELECT ("OS"+cOldSez)
   HSEEK cInvBr
   lIma:=lImaP:=.f.
   IF FOUND()
     lIma:=.t.
     SELECT ("PROMJ"+cOldSez)
      HSEEK cInvBr
      IF FOUND()
        lImaP:=.t.
      ENDIF
   ENDIF
  SELECT OS
  IF lIma
    // promijeni NABVR i OTPVR
    ++nRBr
    Scatter("w")
     ? STR(nRBr,5)+".", wid, naz, TRANS(wNabVr,cMP), TRANS(wOtpVr,cMP)
     nDifNV:=-wNabVr; nDifOV:=-wOtpVr
      nT1+=wNabVr; nT2+=wOtpVr
     wNabVr:=("OS"+cOldSez)->(Nabvr+revd); wOtpVr:=("OS"+cOldSez)->(Otpvr+revp+Amp)
     IF lImaP
       SELECT ("PROMJ"+cOldSez)
       DO WHILE !EOF() .AND. id==cInvBr
         wNabVr+=nabvr+revd
         wOtpVr+=otpvr+revp+amp
         SKIP 1
       ENDDO
       SELECT OS
     ENDIF
      nT3+=wNabVr; nT4+=wOtpVr
     nDifNV+=wNabVr; nDifOV+=wOtpVr
      nT5+=nDifNV; nT6+=nDifOV
     ?? "", TRANS(wNabVr,cMP), TRANS(wOtpVr,cMP), TRANS(nDifNV,cMP),;
        TRANS(nDifOV,cMP)
     wAmp:=wAmd:=0
     wRevD:=wRevP:=0
    Gather("w")
  ENDIF
  SELECT OS
  GO nTrec
ENDDO // EOF
? m
? PADL("UKUPNO",LEN(id+naz)+8), TRANS(nT1,cMP), TRANS(nT2,cMP),;
  TRANS(nT3,cMP), TRANS(nT4,cMP), TRANS(nT5,cMP), TRANS(nT6,cMP)

close all

END PRINT
RETURN
*}


// -----------------------------------------------------------
// vraca niz poddirektorija koji nemaju ekstenziju u nazivu
// a nalaze se u direktoriju cPath (npr. "c:\sigma\fin\kum1\")
// -----------------------------------------------------------
static function ASezona(cPath)
*{
 LOCAL aSezone
  aSezone := DIRECTORY(cPath+"*.","DV")
  FOR i:=LEN(aSezone) TO 1 STEP -1
    IF aSezone[i,1]=="." .or. aSezone[i,1]==".."
      ADEL(aSezone,i)
      ASIZE(aSezone,LEN(aSezone)-1)
    ENDIF
  NEXT
RETURN aSezone
*}




************************
function Unifid()
* unificiraj invent. brojeve
*****************************
*{
local nTrec, nTSRec
local nIsti
O_OS
set order to tag "1"
do while !eof()
  cId:=id
  nIsti:=0
  do while !eof() .and. id==cid
    ++nIsti
    skip
  enddo
  if nisti>1  // ima duplih slogova
    seek cid // prvi u redu
    nProlaz:=0
    do while !eof() .and. id==cid
      skip
      ++nProlaz
      nTrec:=recno()   // sljedeci
      skip -1
      nTSRec:=recno()
      cNovi:=""
      if len(trim(cid))<=8
        cNovi:=trim(id)+idrj
      else
        cNovi:=trim(id)+chr(48+nProlaz)
      endif
      seek cnovi
      if found()
        msgbeep("vec postoji "+cid)
      else
        go nTSRec
        replace id with cnovi
      endif
      go nTrec
    enddo
  endif

enddo
return
*}


********************************************************************
function NovaSredstva()
*
* daje listu sredstava kojih nema u prethodnoj sezoni
********************************************************************
*{
local lSamoStara:=.f.

if Pitanje(,"Prikazati samo sredstva iz proteklih godina? (D/N)","D")=="D"
	lSamoStara:=.t.
endif

O_OSX

// nadjimo sve postojece sezone
// ----------------------------
aSezone := ASezona(KUMPATH)
cTekSez := goModul:oDatabase:cSezona
FOR i:=LEN(aSezone) TO 1 STEP -1
  IF aSezone[i,1]>cTekSez .or. aSezone[i,1]<"1995" .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\OS.DBF") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\OS.CDX") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\PROMJ.DBF") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\PROMJ.CDX")
    ADEL(aSezone,i)
    ASIZE(aSezone,LEN(aSezone)-1)
  ENDIF
NEXT
ASORT(aSezone,,,{|x,y| x[1]>y[1]})

IF LEN(aSezone)<1
  MsgBeep("Nema proslih sezona!")
  CLOSERET
ENDIF

// interesuje me samo posljednja od svih postojecih proslih sezona
cOldSez:=aSezone[1,1]

USE (KUMPATH+cOldSez+"\OS")    NEW ALIAS ("OS"+cOldSez)
  SET ORDER TO TAG "1"
USE (KUMPATH+cOldSez+"\PROMJ") NEW ALIAS ("PROMJ"+cOldSez)
  SET ORDER TO TAG "1"

START PRINT CRET

cMP:="9999999.99"

? "Prikaz sredstava iz tekuce sezone kojih nema u prethodnoj sezoni"
?
SELECT OS; GO TOP

nRbr:=0
nT1:=nT2:=nT3:=nT4:=nT5:=nT6:=0
? "Inv.broj     Datum     Nab.vr.    Otp.vr."
DO WHILE !EOF()
  if (lSamoStara .and. YEAR(field->datum)>=VAL(cTekSez))
  	skip 1
	loop
  endif
  cInvBr:=id    // OS->id
  SELECT ("OS"+cOldSez)
   HSEEK cInvBr
   IF !FOUND()
     ? OS->id, os->datum, TRANSFORM(os->nabVr,cMP), TRANSFORM(os->otpVr,cMP)
     nT1+=os->nabVr
     nT2+=os->otpVr
   ENDIF
  SELECT OS
  skip 1
ENDDO // EOF
?
? PADR("UKUPNO",LEN(field->id)+9), TRANSFORM(nT1,cMP), TRANSFORM(nT2,cMP)
close all

END PRINT
RETURN
*}


********************************************************************
function IzbrisanaSredstva()
*
* daje listu sredstava kojih nema u novoj sezoni
********************************************************************
*{

O_OSX

// nadjimo sve postojece sezone
// ----------------------------
aSezone := ASezona(KUMPATH)
cTekSez := goModul:oDatabase:cSezona
FOR i:=LEN(aSezone) TO 1 STEP -1
  IF aSezone[i,1]>cTekSez .or. aSezone[i,1]<"1995" .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\OS.DBF") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\OS.CDX") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\PROMJ.DBF") .or.;
     !FILE(KUMPATH+aSezone[i,1]+"\PROMJ.CDX")
    ADEL(aSezone,i)
    ASIZE(aSezone,LEN(aSezone)-1)
  ENDIF
NEXT
ASORT(aSezone,,,{|x,y| x[1]>y[1]})

IF LEN(aSezone)<1
  MsgBeep("Nema proslih sezona!")
  CLOSERET
ENDIF

// interesuje me samo posljednja od svih postojecih proslih sezona
cOldSez:=aSezone[1,1]

USE (KUMPATH+cOldSez+"\OS")    NEW ALIAS ("OS"+cOldSez)
  SET ORDER TO TAG "1"
USE (KUMPATH+cOldSez+"\PROMJ") NEW ALIAS ("PROMJ"+cOldSez)
  SET ORDER TO TAG "1"

START PRINT CRET

cMP:="9999999.99"

? "Prikaz sredstava iz prethodne sezone kojih nema u tekucoj sezoni"
?
SELECT ("OS"+cOldSez)
GO TOP

nRbr:=0
nT1:=nT2:=nT3:=nT4:=nT5:=nT6:=0
? "Inv.broj     Datum     Nab.vr.    Otp.vr.     Amort."
DO WHILE !EOF()
  cInvBr:=id    // OS->id
  SELECT OS
   HSEEK cInvBr
   IF !FOUND()
     SELECT ("OS"+cOldSez)
     ? field->id, field->datum, TRANSFORM(field->nabVr,cMP), TRANSFORM(field->otpVr,cMP), TRANSFORM(field->amP,cMP)
     nT1+=field->nabVr
     nT2+=field->otpVr
     nT3+=field->amP
   ENDIF
  SELECT ("OS"+cOldSez)
  skip 1
ENDDO // EOF
?
? PADR("UKUPNO",LEN(field->id)+9), TRANSFORM(nT1,cMP), TRANSFORM(nT2,cMP), TRANSFORM(nT3,cMP)
close all

END PRINT
RETURN
*}


