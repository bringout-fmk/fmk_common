#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/db/2g/db.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.21 $
 * $Log: db.prg,v $
 * Revision 1.21  2004/01/19 13:13:55  sasavranic
 * Pri generaciji IM magacina, pita za cijene VPC ili NC
 *
 * Revision 1.20  2004/01/13 19:07:58  sasavranic
 * appsrv konverzija
 *
 * Revision 1.19  2003/11/04 02:13:26  ernadhusremovic
 * Planika Kranj - Robno poslovanje
 *
 * Revision 1.18  2003/07/14 08:54:07  mirsad
 * Skloni() :_finmat.dbf->finmat.dbf
 *
 * Revision 1.17  2003/05/28 05:42:45  mirsad
 * debug kalk->fin - porezi u ugost.var."T"
 *
 * Revision 1.16  2003/04/02 07:12:56  mirsad
 * u varijanti za Trgomarket uveo dva nova indeksa u KALK "PARM" i "PARP" radi brzeg pregleda za dobavljaca
 *
 * Revision 1.15  2003/03/12 09:18:16  mirsad
 * novi tag na DOKS-u "1S" za brojac KALK dokumenata po kontima (koristenje sufiksa iz KONCIJ-a)
 *
 * Revision 1.14  2003/03/11 15:24:41  mirsad
 * no message
 *
 * Revision 1.13  2002/11/22 10:41:06  mirsad
 * security - omogucavanje reindeksa secur.baza
 *
 * Revision 1.12  2002/07/06 17:28:58  ernad
 *
 *
 * izvjestaj Trgomarket: pregled stanja po objektima
 *
 * Revision 1.11  2002/07/06 12:29:01  ernad
 *
 *
 * kalk, planika GenRekap1, GenRekap2
 *
 * Revision 1.10  2002/07/01 13:34:48  sasa
 * Ispravka greske nArea==(FINMAT) -> nArea==(F_FINMAT)
 *
 * Revision 1.9  2002/06/29 17:32:01  ernad
 *
 *
 * planika - pregled prometa prodavnice
 *
 * Revision 1.8  2002/06/26 08:33:41  sasa
 * sredjen method Kreiraj(nArea)
 *
 * Revision 1.7  2002/06/25 12:19:36  ernad
 *
 *
 * debug - bezveze greska
 *
 * Revision 1.6  2002/06/25 12:09:15  ernad
 *
 *
 * i parametrar u metodu kreiraj
 *
 * Revision 1.5  2002/06/20 16:54:05  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.4  2002/06/17 11:12:26  ernad
 *
 *
 * ciscenje...
 *
 * Revision 1.3  2002/06/16 14:12:46  ernad
 * ispravka gaDbfs
 *
 *
 */
 
function TDbKalkNew()
*{
local oObj
oObj:=TDbKalk():new()
oObj:self:=oObj
oObj:cName:="KALK"
oObj:lAdmin:=.f.
return oObj
*}

/*! \file fmk/kalk/db/2g/db.prg
 *  \brief KALK Database
 *
 * TDbKalk Database objekat 
 */


/*! \class TDbKalk
 *  \brief Database objekat
 */


#ifdef CPP
class TDbKalk: public TDB 
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
CREATE CLASS TDbKalk INHERIT TDB

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


/*! \fn *void TDbKalk::dummy()
 */
*void TDbKalk::dummy()
*{
method dummy
return
*}

/*! \fn *void TDbKalk::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
 *  \brief formiraj sezonsku bazu podataka
 *  \param cSezona - 
 *  \param fInverse - .t. iz sezone u radno, .f. iz radnog u sezonu
 *  \param fda - ne znam
 *  \param fnulirati - nulirati tabele
 *  \param fRS - ne znam
 */

*void TDbKalk::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
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
  if file(PRIVPATH+cSezona+"\PRIPR.DBF")
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
if finverse
 ? "Prenos iz  sezonskih direktorija u radne podatke"
else
 ? "Prenos radnih podataka u sezonske direktorije"
endif
?

fnul:=.f.
Skloni(PRIVPATH,"PRIPR.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_KALK.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FINMAT.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PRIPR2.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PRIPR9.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FMK.INI",cSezona,finverse,fda,fnul)

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

if fnulirati; fnul:=.t.; else; fnul:=.f.; endif  // kumulativ datoteke
Skloni(KUMPATH,"KALK.DBF",cSezona,finverse,fda,fnul)
if FILE(KUMPATH+"KALKS.DBF")
  Skloni(KUMPATH,"KALKS.DBF",cSezona,finverse,fda,fnul)
endif
Skloni(KUMPATH,"DOKS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOKS2.DBF",cSezona,finverse,fda,fnul)


fnul:=.f.
// proizvoljni izvjestaji
Skloni(KUMPATH,"KONIZ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"KOLIZ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"IZVJE.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"ZAGLI.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"OBJEKTI.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"K1.DBF",cSezona,finverse,fda,fnul)


fnul:=.f.
Skloni(SIFPATH,"TARIFA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.FPT",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"PARTN.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TNAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TDOK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KONTO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TRFP.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VALUTE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KONCIJ.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SAST.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFV.DBF",cSezona,finverse,fda,fnul)
if IsPlanika()
	Skloni(KUMPATH,"PRODNC.DBF",cSezona,finverse,fda,fnul)
	Skloni(SIFPATH,"RVRSTA.DBF",cSezona,finverse,fda,fnul)
endif

Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)



?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr
return
*}

/*! \fn *void TDbKalk::setgaDbfs()
 *  \brief Setuje matricu gaDbfs 
 */
*void TDbKalk::setgaDbfs()
*{
method setgaDBFs()

PUBLIC gaDbfs := {;
{ F_PRIPR  ,"PRIPR"   , P_PRIVPATH    },;
{ F_PRIPR2 ,"PRIPR2"  , P_PRIVPATH    },;
{ F_PRIPR9 ,"PRIPR9"  , P_PRIVPATH    },;
{ F__KALK  ,"_KALK"   , P_PRIVPATH    },;
{ F_FINMAT ,"FINMAT"  , P_PRIVPATH    },;
{ F_KALK   ,"KALK"    , P_KUMPATH     },;
{ F_KALKS  ,"KALKS"   , P_KUMPATH     },;
{ F_DOKS   ,"DOKS"    , P_KUMPATH     },;
{ F_DOKS2  ,"DOKS2"   , P_KUMPATH     },;
{ F_PORMP  ,"PORMP"   , P_PRIVPATH    },;
{ F__ROBA  ,"_ROBA"   , P_PRIVPATH    },;
{ F__PARTN ,"_PARTN"  , P_PRIVPATH    },;
{ F_ROBA   ,"ROBA"    , P_SIFPATH     },;
{ F_TARIFA ,"TARIFA"  , P_SIFPATH     },;
{ F_KONTO  ,"KONTO"   , P_SIFPATH     },;
{ F_TRFP   ,"TRFP"    , P_SIFPATH     },;
{ F_PARTN  ,"PARTN"   , P_SIFPATH     },;
{ F_TNAL   ,"TNAL"    , P_SIFPATH     },;
{ F_TDOK   ,"TDOK"    , P_SIFPATH     },;
{ F_KONCIJ ,"KONCIJ"  , P_SIFPATH     },;
{ F_VALUTE ,"VALUTE"  , P_SIFPATH     },;
{ F_SAST   ,"SAST"    , P_SIFPATH     },;
{ F_KONIZ  ,"KONIZ"   , P_KUMPATH     },;
{ F_IZVJE  ,"IZVJE"   , P_KUMPATH     },;
{ F_ZAGLI  ,"ZAGLI"   , P_KUMPATH     },;
{ F_KOLIZ  ,"KOLIZ"   , P_KUMPATH     },;
{ F_LOGK   ,"LOGK"    , P_KUMPATH     },;
{ F_LOGKD  ,"LOGKD"   , P_KUMPATH     },;
{ F_BARKOD ,"BARKOD"  , P_PRIVPATH    },;
{ F_PPPROD ,"PPPROD"  , P_PRIVPATH    },;
{ F_OBJEKTI,"OBJEKTI" , P_KUMPATH     },;
{ F_PRODNC, "PRODNC"  , P_KUMPATH     },;
{ F_RVRSTA, "RVRSTA"  , P_SIFPATH     },;
{ F_K1     ,"K1"      , P_KUMPATH     };
}

return

*}


/*! \fn *void TDbKalk::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
 *  \brief osnovni meni za instalacijske procedure
 */

*void TDbKalk::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
*{

method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	ISC_START(goModul,.f.)
return
*}

/*! \fn *void TDbKalk::kreiraj(int nArea)
 *  \brief kreirane baze podataka POS
 */
 
*void TDbKalk::kreiraj(int nArea)
*{
method kreiraj(nArea)

#ifdef CAX
  SET EXCLUSIVE ON
#endif

if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

CreFMKSvi()
CreRoba()
CreFMKPI()

#IFDEF SR
	if (nArea==-1 .or. nArea==(F_LOGK))
		//LOGK.DBF	
   	
		aDbf:={}
   		AADD(aDbf,{"NO",     "N",15,0})
   		AADD(aDbf,{"ID",     "C",6,0})
   		AADD(aDbf,{"DatProm","D",8,0})
   		AADD(aDbf,{"Datum",  "D",8,0})
   		AADD(aDbf,{"K1",     "C",10,0})
  	 	AADD(aDbf,{"K2",     "C",10,0})
   		AADD(aDbf,{"K3",     "C",2,0})
   		AADD(aDbf,{"N1",     "N",10,2})

		if !FILE(KUMPATH+"LOGK.DBF")
   			DBcreate2(KUMPATH+'LOGK.DBF',aDbf)
		endif
	
		CREATE_INDEX("ID","id", KUMPATH+"LOGK")
		CREATE_INDEX("NO","NO", KUMPATH+"LOGK")
		CREATE_INDEX("Datum","Datum", KUMPATH+"LOGK")
	endif
#endif



aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDKONTO2'            , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDZADUZ'             , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ2'            , 'C' ,   6 ,  0 })
// ova su polja prakticno tu samo radi kompat
// istina, ona su ponegdje iskoristena za neke sasvim druge stvari
// pa zato treba biti pazljiv sa njihovim diranjem
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'DATFAKTP'            , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'DATKURS'             , 'D' ,   8 ,  0 })
// ovaj datkurs je sada skroz eliminisan iz upotrebe
// vidjeti za njegovo uklanjanje  (paziti na modul FIN) jer se ovo i tamo
// koristi
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICINA'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICIN2'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'FCJ'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'FCJ2'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'FCJ3'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TRABAT'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'RABAT'               , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TPREVOZ'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PREVOZ'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TPREVOZ2'            , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PREVOZ2'             , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TBANKTR'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'BANKTR'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TSPEDTR'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'SPEDTR'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TCARDAZ'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'CARDAZ'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TZAVTR'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'ZAVTR'               , 'N' ,  18 ,  8 })
// ovi troskovi pravo uvecavaju bazu, mislim da bi njihovo sklanjanje u
// drugu bazu zaista pomoglo brzini
// medjutim i ova su polja viseznacna
AADD(aDBf,{ 'NC'                  , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TMARZA'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA'               , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'RABATV'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPCSAP'              , 'N' ,  18 ,  8 })
// ova vpcsap je u principu skroz bezvezna stvar
AADD(aDBf,{ 'TMARZA2'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA2'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'MPCSAPP'             , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'RokTr'               , 'D' ,   8 ,  0 })
// rok trajanja NIKO ne koristi !!
AADD(aDBf,{ 'MU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'ERROR'               , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

if (nArea==-1 .or. nArea==(F_PRIPR))
	//PRIPR.DBF
	
	if !FILE(PRIVPATH+"PRIPR.dbf")
  		DBcreate2(PRIVPATH+'PRIPR.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"PRIPR")
	CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa",PRIVPATH+"PRIPR")
	CREATE_INDEX("3","idFirma+idvd+brdok+idroba+rbr",PRIVPATH+"PRIPR")
endif

if (nArea==-1 .or. nArea==(F_PRIPR2))
	//PRIPR2
	
	if !FILE(PRIVPATH+"PRIPR2.DBF")
  		dbcreate2(PRIVPATH+'PRIPR2.DBF',aDbf)
	endif

	CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"PRIPR2")
	CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa",PRIVPATH+"PRIPR2")
endif

if (nArea==-1 .or. nArea==(F_PRIPR9))
	//PRIPR9.DBF
	
	if !FILE(PRIVPATH+"PRIPR9.DBF")
  		DBcreate2(PRIVPATH+'PRIPR9.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"PRIPR9")
	CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa",PRIVPATH+"PRIPR9")
	CREATE_INDEX("3","dtos(datdok)+mu_i+pu_i",PRIVPATH+"PRIPR9")
endif

if (nArea==-1 .or. nArea==(F__KALK))
	//_KALK.DBF

	if !FILE(PRIVPATH+"_KALK.DBF")
  		DBcreate2(PRIVPATH+'_KALK.DBF',aDbf)
	endif

	CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"_KALK")
endif


if (nArea==-1 .or. nArea==(F_KALK))
	//KALK.DBF

	if !FILE(KUMPATH+"KALK.dbf")
  		DBcreate2(KUMPATH+'KALK.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr",KUMPATH+"KALK")
	CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa",KUMPATH+"KALK")
	// 3 - vodjenje magacina
	CREATE_INDEX("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")
	// 4 - vodjenje prodavnice
	CREATE_INDEX("4","idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD",KUMPATH+"KALK")
	
	CREATE_INDEX("5","idFirma+dtos(datdok)+podbr+idvd+brdok",KUMPATH+"KALK")

	CREATE_INDEX("6","idFirma+IdTarifa+idroba",KUMPATH+"KALK")
	
	CREATE_INDEX("7","idroba",KUMPATH+"KALK")
	CREATE_INDEX("8","mkonto",KUMPATH+"KALK")
	CREATE_INDEX("9","pkonto",KUMPATH+"KALK")
        if IsTrgom()
		CREATE_INDEX("PARM","idpartner+idroba+mu_i",KUMPATH+"KALK")
		CREATE_INDEX("PARP","idpartner+idroba+pu_i",KUMPATH+"KALK")
	endif
	CREATE_INDEX("PMAG","idfirma+mkonto+idpartner+idvd+dtos(datdok)",KUMPATH+"KALK")
	if lPoNarudzbi
  		CREATE_INDEX("3N","idFirma+mkonto+idnar+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")
  		CREATE_INDEX("4N","idFirma+Pkonto+idnar+idroba+dtos(datdok)+podbr+PU_I+IdVD",KUMPATH+"KALK")
  		CREATE_INDEX("6N","idFirma+IdTarifa+idnar+idroba",KUMPATH+"KALK")
	endif
	if  gVodiSamoTarife=="D"
 		CREATE_INDEX("PTARIFA","idFirma+pkonto+IdTarifa+idroba",KUMPATH+"KALK")
	endif
endif



if (nArea==-1 .or. nArea==(F_DOKS))
	//DOKS.DBF
	
	aDbf:={}
	AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
	AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })
	AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
	AADD(aDBf,{ 'IdZADUZ'             , 'C' ,   6 ,  0 })
	AADD(aDBf,{ 'IdZADUZ2'            , 'C' ,   6 ,  0 })
	AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
	AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
	AADD(aDBf,{ 'NV'                  , 'N' ,  12 ,  2 })
	AADD(aDBf,{ 'VPV'                 , 'N' ,  12 ,  2 })
	AADD(aDBf,{ 'RABAT'               , 'N' ,  12 ,  2 })
	AADD(aDBf,{ 'MPV'                 , 'N' ,  12 ,  2 })
	AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })
	
	if !FILE(KUMPATH+'DOKS.DBF')
        	DBcreate2(KUMPATH+'DOKS.DBF',aDbf)
	endif

	CREATE_INDEX("1","IdFirma+idvd+brdok",KUMPATH+"DOKS")
	CREATE_INDEX("2","IdFirma+MKONTO+idzaduz2+idvd+brdok",KUMPATH+"DOKS")
	CREATE_INDEX("3","IdFirma+dtos(datdok)+podbr+idvd+brdok",KUMPATH+"DOKS")
	// za RN
	if glBrojacPoKontima
		CREATE_INDEX("1S","IdFirma+idvd+SUBSTR(brdok,6)+LEFT(brdok,5)",KUMPATH+"DOKS")
	endif
endif


if (nArea==-1 .or. nArea==(F_DOKS2))
	//DOKS2.DBF
	
	aDbf:={}
	AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'IDvd'                , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
	AADD(aDBf,{ 'DATVAL'              , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'Opis'                , 'C' ,  20 ,  0 })
	AADD(aDBf,{ 'K1'                , 'C' ,  1 ,  0 })
	AADD(aDBf,{ 'K2'                , 'C' ,  2 ,  0 })
	AADD(aDBf,{ 'K3'                , 'C' ,  3 ,  0 })
	if !FILE(KUMPATH+'DOKS2.DBF')
       		DBcreate2(KUMPATH+'DOKS2.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idvd+brdok",KUMPATH+"DOKS2")
endif



aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDKONTO2'            , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ'             , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ2'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'DATFAKTP'            , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DATKURS'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'FV'                  , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'GKV'                 , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'GKV2'                , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'RABAT'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PREVOZ'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'CARDAZ'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'BANKTR'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'SPEDTR'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'ZAVTR'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'NV'                  , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'RABATV'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'POREZV'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'MARZA'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'VPV'                 , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'VPVSAP'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'MARZA2'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'MPV'                 , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'POREZ'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'POREZ2'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'MPVSAPP'             , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  19 ,  7 })
AADD(aDBf,{ 'GKol'                , 'N' ,  19 ,  7 })
AADD(aDBf,{ 'GKol2'               , 'N' ,  19 ,  7 })
AADD(aDBf,{ 'PORVT'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'UPOREZV'             , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PRUCMP'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PORPOT'              , 'N' ,  20 ,  8 })

if (nArea==-1 .or. nArea==(F_FINMAT))
	//FINMAT.DBF
	
	if !FILE(PRIVPATH+"FINMAT.dbf")
    		DBcreate2(PRIVPATH+'FINMAT.DBF',aDbf)
	endif

	CREATE_INDEX("1","idFirma+IdVD+BRDok",PRIVPATH+"FINMAT")
endif


if (nArea==-1 .or. nArea==(F_OBJEKTI))
	
	cImeTbl:=KUMPATH+"OBJEKTI.DBF"
	aDbf:={}
	AADD(aDbf, {"id","C",2,0})
	AADD(aDbf, {"naz","C",10,0}) 
	AADD(aDbf, {"IdObj","C", 7,0})

	if !FILE(cImeTbl)
		DBCREATE2(cImeTbl, aDbf)
	endif

	CREATE_INDEX("ID", "ID", cImeTbl)
	CREATE_INDEX("NAZ", "NAZ", cImeTbl)

endif


if (nArea==-1 .or. nArea==(F_K1))
	aDbf:={}
	AADD(aDbf, {"id","C",4,0})
	AADD(aDbf, {"naz","C",20,0})
	cImeTbl:=KUMPATH+"K1.DBF"
	if !FILE(cImeTbl)
		DBCREATE2(KUMPATH+"K1",aDbf)
	endif
	CREATE_INDEX("ID", "ID", cImeTbl)
	CREATE_INDEX("NAZ", "NAZ", cImeTbl)
endif


if IsPlanika() 

//ProdNc.Dbf

aDbf:={}
AADD(aDBf,{ 'PKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDROBA'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDTARIFA'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDVD'               , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'              , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'NC'                 , 'N' ,  20 ,  8 })

// kolicina kod posljednje nabavke
AADD(aDBf,{ 'KOLICINA'           , 'N' ,  12 ,  2 })


if (nArea==-1 .or. nArea==(F_PRODNC))
	if !FILE(KUMPATH+"PRODNC.dbf")
    		DBcreate2(KUMPATH+'PRODNC.DBF',aDbf)
	endif

	CREATE_INDEX("PRODROBA","PKONTO+IDROBA",KUMPATH+"PRODNC")
endif

//RVrsta.Dbf
aDbf:={}
AADD(aDBf,{ 'ID'              , 'C' ,  1 ,  0 })
AADD(aDBf,{ 'NAZ'             , 'C' , 30 ,  0 })
if (nArea==-1 .or. nArea==(F_RVRSTA))
	if !FILE(SIFPATH+"RVRSTA.dbf")
    		DBcreate2(SIFPATH+'RVRSTA.DBF',aDbf)
	endif

	CREATE_INDEX("ID","ID",SIFPATH+"RVRSTA")
	CREATE_INDEX("NAZ", "NAZ", SIFPATH+"RVRSTA")
endif


//IsPlanika()
endif

return
*}

/*! \fn *void TDbKalk::obaza(int i)
 *  \brief otvara odgovarajucu tabelu
 *  
 *      
 */

*void TDbKalk::obaza(int i)
*{

method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.



if i==F_PRIPR .or. i==F_FINMAT .or. i==F_PRIPR2 .or. i==F_PRIPR9
	lIdiDalje:=.t.
endif

if i==F__KALK .or. i==F__ROBA .or. i==F__PARTN 
	lIdiDalje:=.t.
endif

if i==F_KALK .or. i=F_DOKS .or. i==F_ROBA .or. i==F_TARIFA .or. i==F_PARTN  .or. i==F_TNAL   .or. i==F_TDOK  .or. i==F_KONTO  
	lIdiDalje:=.t.
endif

if i==F_TRFP .or. i==F_VALUTE .or. i==F_KONCIJ .or. i==F_SAST  .or. i==F_BARKOD
	lIdiDalje:=.t.
endif

if i==F_PARAMS .or. i==F_GPARAMS .or. i==F_GPARAMSP .or. i==F_KORISN .or. i==F_MPARAMS .or. i==F_KPARAMS .or. i==F_SECUR .or. i==F_ADRES
	lIdiDalje:=.t.
endif

if i==F_KONIZ .or. i==F_KOLIZ .or. i==F_IZVJE .or. i==F_ZAGLI
	lIdiDalje:=.t.
endif

if i==F_OBJEKTI .or. i==F_K1
	lIdiDalje:=.t.
endif

if IsPlanika()
	if i==F_PRODNC .or. i==F_RVRSTA
		lIdiDalje:=.t.
	endif
endif


if (gSecurity=="D" .and. (i==F_EVENTS .or. i==F_EVENTLOG .or. i==F_USERS .or. i==F_GROUPS .or. i==F_RULES))
	lIdiDalje:=.t.
endif

if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	if gAppSrv 
		? "OPEN: " + cDbfName + ".DBF"
		if !File(cDbfName + ".DBF")
			? "Fajl " + cDbfName + ".dbf ne postoji!!!"
			use
			return
		endif
	endif
	
	select(i)
	usex(cDbfName)
else
	use
	return
endif


return
*}

/*! \fn *void TDbKalk::ostalef()
 *  \brief Ostalef funkcije (bivsi install modul)
 *  \note  sifra: SIGMAXXX
*/

*void TDbKalk::ostalef()
*{
method ostalef()

if pitanje(,"Formirati Bosanski sort","N")=="D"
   CREATE_INDEX("NAZ_B","BTOEU(Naz)",SIFPATH+"ROBA")
endif

if pitanje(,"Formirati KALKS ?","N")=="D"

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICINA'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICIN2'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'NC'                  , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'TMARZA'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA'               , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC'                 , 'N' ,  12 ,  4 })
AADD(aDBf,{ 'RABATV'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TMARZA2'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA2'              , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'MPC'                 , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'MPCSAPP'             , 'N' ,  12 ,  4 })
AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'RokTr'               , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'MU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'ERROR'               , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

if Pitanje(,"KALKS vec postoji, nulirati je ?","N")=="D"
    ferase(KUMPATH+'KALKS.CDX')
    ferase(KUMPATH+'KALKS.DBF')
endif

if !file(KUMPATH+'KALKS.DBF')
 ferase(KUMPATH+'KALKS.CDX')
 dbcreate2(KUMPATH+'KALKS.DBF',aDbf)
endif

CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr",KUMPATH+"KALKS")
CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa",KUMPATH+"KALKS")
// 3 - vodjenje magacina
CREATE_INDEX("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALKS")
// 4 - vodjenje prodavnice
CREATE_INDEX("4","idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD",KUMPATH+"KALKS")
CREATE_INDEX("5","idFirma+dtos(datdok)+podbr+idvd+brdok",KUMPATH+"KALKS")
CREATE_INDEX("6","idFirma+IdTarifa+idroba",KUMPATH+"KALKS")
CREATE_INDEX("7","idroba",KUMPATH+"KALKS")
CREATE_INDEX("8","mkonto",KUMPATH+"KALKS")
CREATE_INDEX("9","pkonto",KUMPATH+"KALKS")
CREATE_INDEX("D","datdok",KUMPATH+"KALKS")

endif

return
*}

/*! \fn *void TDbKalk::konvZn()
 *  \brief koverzija 7->8 baze podataka KALK
 */
 
*void TDbKalk::konvZn()
*{
method konvZn() 
LOCAL cIz:="7", cU:="8", aPriv:={}, aKum:={}, aSif:={}
LOCAL GetList:={}, cSif:="D", cKum:="D", cPriv:="D"

if !gAppSrv
	if !SigmaSif("KZ      ")
		return
	endif
	Box(,8,50)
  	@ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  	@ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  	@ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  	@ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  	@ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  	READ
  	IF LASTKEY()==K_ESC
		BoxC()
		RETURN
	ENDIF
  	IF Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    		BoxC()
		RETURN
  	ENDIF
 	BoxC()
else
	?
	cKonvertTo:=IzFmkIni("FMK","KonvertTo","78",EXEPATH)
	
	if cKonvertTo=="78"
		cIz:="7"
		cU:="8"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU 
	elseif cKonvertTo=="87"
		cIz:="8"
		cU:="7"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU 
	else // pitaj
		?
		@ 10, 2 SAY "Trenutni standard (7/8)        " GET cIz VALID cIz$"78" PICT "9"
		?
		@ 11, 2 SAY "Konvertovati u standard (7/8/A)" GET cU VALID cU$"78A" PICT "@!"
		read
	endif
	cSif:="D"
	cKum:="D"
	cPriv:="D"
endif

aPriv := { F_PRIPR, F_FINMAT, F_PRIPR2, F_PRIPR9, F__KALK, F__ROBA,;
            F__PARTN, F_PORMP }
aKum  := { F_KALK, F_DOKS, F_KONIZ, F_IZVJE, F_ZAGLI, F_KOLIZ }
aSif  := { F_ROBA, F_TARIFA, F_PARTN, F_TNAL, F_TDOK, F_KONTO, F_TRFP,;
            F_VALUTE, F_KONCIJ, F_SAST }

IF cSif  == "N"
	aSif  := {}
ENDIF
IF cKum  == "N"
	aKum  := {}
ENDIF
IF cPriv == "N"
	aPriv := {}
ENDIF

KZNbaza(aPriv,aKum,aSif,cIz,cU)

return
*}


/*
function O_Log()

local cPom, cLogF

cPom:=KUMPATH+"\SQL"
DirMak2(cPom)
cLogF:=cPom+"\"+replicate("0",8)

OKreSQLPar(cPom)

public gSQLSite:=field->_SITE_
public gSQLUser:=1
use

//postavi site
Gw("SET SITE "+Str(gSQLSite))
Gw("SET TODATABASE OFF")
Gw("SET MODUL "+gModul)
return

*/

