#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/db/2g/db.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.15 $
 * $Log: db.prg,v $
 * Revision 1.15  2004/02/12 15:37:16  sasavranic
 * Kopiranje podataka za novu grupu po uzoru na postojecu.
 *
 * Revision 1.14  2004/01/13 19:07:53  sasavranic
 * appsrv konverzija
 *
 * Revision 1.13  2004/01/05 14:19:30  sasavranic
 * Pohranjivanje i nar.txt u sezonu
 *
 * Revision 1.12  2003/10/13 12:36:23  sasavranic
 * no message
 *
 * Revision 1.11  2003/07/24 16:05:48  sasa
 * stampa podataka o bankama na narudzbenici
 *
 * Revision 1.10  2003/07/07 14:09:36  sasa
 * Prebacene pomocne tabele POMGN i PPOMGN.DBF u KUMPATH
 *
 * Revision 1.9  2002/10/15 13:24:33  sasa
 * rjesena dilema prenosa sezona
 *
 * Revision 1.8  2002/07/04 11:13:51  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.7  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.6  2002/06/26 14:52:32  ernad
 *
 *
 * dokumentovanje tabela
 *
 * Revision 1.5  2002/06/26 08:00:53  sasa
 * sredjen method Kreiraj(nArea)
 *
 * Revision 1.4  2002/06/25 13:41:35  sasa
 * no message
 *
 * Revision 1.3  2002/06/20 13:55:27  ernad
 * izbaciti create RJ (postoji u fmk/svi)
 *
 * Revision 1.2  2002/06/18 08:30:42  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 

/*! \defgroup db_fakt  Baza podataka fakt
 * @{
 * @}
 *
 */


*tbl tbl_fakt; 

/*! \var tbl_fakt
 *  \brief Glavna datoteka prometa (kumulativa), modul FAKT
 *
 *  \ingroup db_fakt
 *
 *  \code
 *
 *  Create Table "FAKT" ( 
 *	IDFIRMA Char( 2 ), 
 *	IDTIPDOK Char( 2 ), 
 *	BRDOK Char( 8 ), 
 *	DATDOK Date, 
 *	IDPARTNER Char( 6 ), 
 *	DINDEM Char( 3 ), 
 *	ZAOKR Numeric( 1 ,0 ), 
 *	RBR Char( 3 ), 
 *	PODBR Char( 2 ), 
 *	IDROBA Char( 10 ), 
 *	SERBR Char( 15 ), 
 *	KOLICINA Numeric( 14 ,5 ), 
 *	CIJENA Numeric( 14 ,5 ), 
 *	RABAT Numeric( 8 ,5 ), 
 *	POREZ Numeric( 9 ,5 ), 
 *	TXT Memo, 
 *	K1 Char( 4 ), 
 *	K2 Char( 4 ), 
 *	M1 Char( 1 ), 
 *	BRISANO Char( 1 ), 
 *	IDVRSTEP Char( 2 )
 * );
 *
 * Create Index "BRISAN" on FAKT( BRISANO );
 * Create Index "OID" on FAKT( OID );
 * Create Index "1" on FAKT( IDFIRMA, IDTIPDOK, BRDOK, RBR, PODBR );
 * Create Index "2" on FAKT( IDFIRMA, DATDOK, IDTIPDOK, BRDOK, RBR );
 * Create Index "3" on FAKT( IDROBA, DATDOK );
 * Create Index "HOST" on FAKT( HOST );
 * Create Index "USER" on FAKT( USER );
 *
 * \endcode
 */
 
*tbl tbl_fa_doks;

/*! \var tbl_fa_doks
 *  \brief Tabela dokumenata u fakt-u 
 *
 * \ingroup db_fakt
 *
 * \code
 *
 * Create Table "DOKS" ( 
 *	IDFIRMA Char( 2 ), 
 *	IDTIPDOK Char( 2 ), 
 *	BRDOK Char( 8 ), 
 *	PARTNER Char( 30 ), 
 *	DATDOK Date, 
 *	DINDEM Char( 3 ), 
 *	IZNOS Numeric( 12 ,3 ), 
 *	RABAT Numeric( 12 ,3 ), 
 *	REZERV Char( 1 ), 
 *	M1 Char( 1 ), 
 *	IDPARTNER Char( 6 ), 
 *	SIFRA Char( 6 ), 
 *	BRISANO Char( 1 ), 
 *	IDVRSTEP Char( 2 ), 
 *	DATPL Date
 * );
 *  
 *
 * Create Index "BRISAN" on DOKS( BRISANO );
 * Create Index "OID" on DOKS( OID );
 * Create Index "1" on DOKS( IDFIRMA, IDTIPDOK, BRDOK );
 * Create Index "2" on DOKS( IDFIRMA, IDTIPDOK, PARTNER );
 * Create Index "3" on DOKS( PARTNER );
 * Create Index "4" on DOKS( IDTIPDOK );
 * Create Index "5" on DOKS( DATDOK );
 * Create Index "6" on DOKS( IDFIRMA, IDPARTNER, IDTIPDOK );
 *
 * \endcode
 *
 */
 

*tbl tbl_dest;

/*! \var tbl_dest 
 *  \brief Tabela destinacije
 *
 * \ingroup db_fakt
 *
 * \code
 *
 * Create Table "DEST" ( 
 *	ID Char( 6 )
 *	NAZ Char( 25 ), 
 *	NAZ2 Char( 25 ), 
 *	OZNAKA Char( 1 ), 
 *	PTT Char( 5 ), 
 *	MJESTO Char( 16 ), 
 *	ADRESA Char( 24 ), 
 *	TELEFON Char( 12 ),  
 *	FAX Char( 12 ), 
 *	MOBTEL Char( 20 )
 * );
 *
 *
 * Create Index "BRISAN" on DEST( BRISANO );
 * Create Index "1" on DEST( ID, OZNAKA );
 *
 * \endcode
 *
 */

*tbl tbl_fa_doks2;

/*! \var tbl_fa_doks2
 *  \brief Tabele doks2 - dodatni atributi dokumenata, db fakt
 *
 * \ingroup db_fakt
 * 
 * \code
 *
 * Create Table "DOKS2" ( 
 *	IDFIRMA Char( 2 ), 
 *	IDTIPDOK Char( 2 ), 
 *	BRDOK Char( 8 ), 
 *	K1 Char( 15 ), 
 *	K2 Char( 15 ), 
 *	K3 Char( 15 ), 
 *	K4 Char( 20 ), 
 *	K5 Char( 20 ),  
 *	N1 Numeric( 15 ,2 ), 
 *	N2 Numeric( 15 ,2 ), 
 *	BRISANO Char( 1 )
 * );
 *
 * Create Index "BRISAN" on DOKS2( BRISANO );
 * Create Index "1" on DOKS2( IDFIRMA, IDTIPDOK, BRDOK );
 *
 * \endcode
 *
 */
 



*tbl tbl_Ugov;

/*! \var tbl_ugov
 *  \brief Tabela ugovora, baza podataka fakt
 *  \ingroup db_fakt
 *
 * \code
 *
 * Create Table "UGOV" ( 
 *	ID Char( 10 ), 
 *	DATOD Date, 
 *	IDPARTNER Char( 6 ), 
 *	DATDO Date, 
 *	VRSTA Char( 1 ), 
 *	IDTIPDOK Char( 2 ), 
 *	NAZ Char( 20 ), 
 *	AKTIVAN Char( 1 ), 
 *	DINDEM Char( 3 ), 
 *	IDTXT Char( 2 ),  
 *	ZAOKR Numeric( 1 ,0 ), 
 *	BRISANO Char( 1 ) 
 * );
 * Create Index "BRISAN" on UGOV( BRISANO );
 * Create Index "ID" on UGOV( ID, IDPARTNER );
 * Create Index "NAZ" on UGOV( IDPARTNER, ID );
 * Create Index "NAZ2" on UGOV( NAZ );
 * Create Index "PARTNER" on UGOV( IDPARTNER );
 * Create Index "AKTIVAN" on UGOV( AKTIVAN );
 *
 * \endcode
 *
 */

*tbl tbl_upl;

/*! \var Fmk_tbl_upl
 *  \brief Tabela uplata kupaca
 *  \ingroup db_fakt
 *
 * \code
 *
 * Create Table "UPL" ( 
 *	DATUPL Date
 *	IDPARTNER Char( 6 ),
 *	OPIS Char( 30 ), 
 *	IZNOS Numeric( 12 ,2 ), 
 *	BRISANO Char( 1 ) 
 * );
 *
 * 
 * Create Index "BRISAN" on UPL( BRISANO );
 * Create Index "1" on UPL( IDPARTNER, DATUPL );
 * Create Index "2" on UPL( IDPARTNER );
 *
 * \endcode
 *
 */

*string FmkIni_ExePath_SifRoba_ID_J;

/*! \ingroup ini
  * \var *string FmkIni_ExePath_SifRoba_ID_J
  * \brief Omogucava koristenje dodatnih skrivenih sifara robe
  * \param N - default vrijednost
  * \param D - koriste se dodatne skrivene sifre robe
  */
*string FmkIni_ExePath_SifRoba_ID_J;




/*! \fn TDBFaktNew()
 *  \brief
 */
function TDBFaktNew()
*{
local oObj
oObj:=TDBFakt():new()
oObj:self:=oObj
oObj:cName:="FAKT"
oObj:lAdmin:=.f.
return oObj
*}


/*! \file fmk/fakt/db/2g/db.prg
 *  \brief FAKT Database
 *
 * TDBFakt Database objekat 
 */


/*! \class TDBFakt
 *  \brief Database objekat
 */


#ifdef CPP
class TDBFakt: public TDB 
{
     public:
     	TObject self;
	string cName;
	*void dummy();
	*void skloniSezonu(string cSezona, bool finverse, bool fda, bool fnulirati, bool fRS);
	*void install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7);
	*void setgaDBFs();
	*void obaza(int i);
	*void kreiraj(int nArea);
	*void ostalef();
}
#endif

#ifndef CPP
#include "class(y).ch"
CREATE CLASS TDBFakt INHERIT TDB

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


/*! \fn *void TDBFakt::dummy()
 */
*void TDBFakt::dummy()
*{
method dummy
return
*}

/*! \fn *void TDBFakt::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
 *  \brief formiraj sezonsku bazu podataka
 *  \param cSezona - 
 *  \param fInverse - .t. iz sezone u radno, .f. iz radnog u sezonu
 *  \param fda - ne znam
 *  \param fnulirati - nulirati tabele
 *  \param fRS - ne znam
 */

*void TDBFakt::skloniSezonu(string cSezona, bool fInverse,bool fDa,bool fNulirati,bool fRS)
*{

method skloniSezonu(cSezona,fInverse,fDa,fNulirati,fRS)

save screen to cScr

if fDa==nil
	fDA:=.f.
endif

if fInverse==nil
	fInverse:=.f.
endif

if fNulirati==nil
	fNulirati:=.f.
endif

if fRS==nil
	// mrezna radna stanica , sezona je otvorena
  	fRS:=.f.
endif

if fRS // radna stanica
	if File(PRIVPATH+cSezona+"\PRIPR.DBF")
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
	? "Prenos iz sezonskih direktorija u radne podatke"
else
 	? "Prenos radnih podataka u sezonske direktorije"
endif

?

fNul:=.f.

MsgBeep("Sklanjam privatne direktorije!!!")

Skloni(PRIVPATH,"PRIPR.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PRIPR.FPT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_FAKT.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_FAKT.FPT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_ROBA.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_ROBA.FPT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"BARKOD.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"ZAGL.TXT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"NAR.TXT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FMK.INI",cSezona,finverse,fda,fnul)

if IsStampa()
	Skloni(KUMPATH,"POMGN",cSezona,finverse,fda,fnul)
	Skloni(KUMPATH,"PPOMGN",cSezona,finverse,fda,fnul)
endif

if fRS
	// mrezna radna stanica!!! , baci samo privatne direktorije
 	?
 	?
 	?
 	Beep(4)
 	? "pritisni nesto za nastavak..."
	restore screen from cScr
 	return
endif


// kumulativ datoteke

MsgBeep("Sklanjam kumulativne direktorije!!!")

Skloni(KUMPATH,"FAKT.FPT",cSezona,fInverse,fDa,fNul)

if fNulirati
	fNul:=.t.
else
	fNul:=.f.
endif  

Skloni(KUMPATH,"FAKT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOKS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOKS2.DBF",cSezona,finverse,fda,fnul)

if fNulirati
	fNul:=.f.
else
	fNul:=.t.
endif  

Skloni(KUMPATH,"RJ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"UGOV.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RUGOV.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DEST.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"KALPOS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)


// Sif PATH
MsgBeep("Sklanjam direktorij sifrarnika!!!")

Skloni(SIFPATH,"TARIFA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.FPT",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"PARTN.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FTXT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VALUTE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SAST.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KONTO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFV.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FADO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FADE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"BANKE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VRSTEP.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VOZILA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"RELAC.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

?
?
?
Beep(4)
? "pritisni nesto za nastavak..."

restore screen from cScr
return
*}

/*! \fn *void TDBFakt::setgaDBFs()
 *  \brief Setuje matricu gaDBFs 
 */
*void TDBFakt::setgaDBFs()
*{
method setgaDBFs()

PUBLIC gaDBFs := {;
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
{ F_RJ     ,"RJ"      , P_KUMPATH     },;
{ F_UPL    ,"UPL"     , P_KUMPATH     },;
{ F_FTXT   ,"FTXT"    , P_SIFPATH     },;
{ F_FAKT   ,"FAKT"    , P_KUMPATH     },;
{ F__FAKT  ,"_FAKT"   , P_PRIVPATH    },;
{ F_FAPRIPR,"PRIPR"   , P_PRIVPATH    },;
{ F_UGOV   ,"UGOV"    , P_KUMPATH     },;
{ F_RUGOV  ,"RUGOV"   , P_KUMPATH    },;
{ F_DEST   ,"DEST"    , P_KUMPATH     },;
{ F_DOKS   ,"DOKS"    , P_KUMPATH     },;
{ F_DOKS2  ,"DOKS2"   , P_KUMPATH     },;
{ F_VRSTEP ,"VRSTEP"  , P_SIFPATH     },;
{ F_RELAC  ,"RELAC"   , P_SIFPATH     },;
{ F_VOZILA ,"VOZILA"  , P_SIFPATH     },;
{ F_KALPOS ,"KALPOS"  , P_KUMPATH     },;
{ F_BANKE  ,"BANKE"   , P_SIFPATH     },;
{ F_OPS    ,"OPS"     , P_SIFPATH     };
}

return
*}


/*! \fn *void TDBFakt::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
 *  \brief osnovni meni za instalacijske procedure
 */

*void TDBFakt::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
*{

method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	ISC_START(goModul,.f.)
return
*}

/*! \fn *void TDBFakt::Kreiraj(int nArea)
 *  \brief Kreiranje baze podataka Fakt-a
 */
 
*void TDBFakt::Kreiraj(int nArea)
*{
method Kreiraj(nArea)

#ifdef CAX
	SET EXCLUSIVE ON
#endif

CreFMKSvi()
CreRoba()
CreFMKPI()

if (nArea==nil)
	nArea:=-1
endif

Beep(1)

if (nArea<>-1)
	CreSystemDb(nArea)
endif

if (nArea==-1 .or. nArea==(F_UPL))
	
	//UPL.DBF
	aDBf:={}
   	AADD(aDBf,{'DATUPL'     ,'D', 8,0})
   	AADD(aDBf,{'IDPARTNER'  ,'C', 6,0})
   	AADD(aDBf,{'OPIS'       ,'C',30,0})
   	AADD(aDBf,{'IZNOS'      ,'N',12,2})
   	if !FILE(KUMPATH+"UPL.DBF")
		DBcreate2(KUMPATH+"UPL.DBF",aDbf)
	endif

	CREATE_INDEX("1","IDPARTNER+DTOS(DATUPL)",KUMPATH+"UPL")
	CREATE_INDEX("2","IDPARTNER",KUMPATH+"UPL")
endif


if (nArea==-1 .or. nArea==(F_FTXT))
        
	//FTXT.DBF
	aDbf:={}
        AADD(aDBf,{'ID'  ,'C',  2 ,0})
        AADD(aDBf,{'NAZ' ,'C',340 ,0})
	if !FILE(SIFPATH+"FTXT.DBF")
        	DBcreate2(SIFPATH+'FTXT.DBF',aDbf)
	endif
	
	CREATE_INDEX("ID","ID",SIFPATH+"FTXT")
endif


aDbf:={}
AADD(aDBf,{ 'IDFIRMA'   , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IdTIPDok'  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'     , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'    , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'IDPARTNER' , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'DINDEM'    , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'zaokr'     , 'N' ,   1 ,  0 })
AADD(aDBf,{ 'Rbr'       , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'PodBr'     , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'    , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'SerBr'     , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'KOLICINA'  , 'N' ,  14 ,  5 })
AADD(aDBf,{ 'Cijena'    , 'N' ,  14 ,  5 })
AADD(aDBf,{ 'Rabat'     , 'N' ,   8 ,  5 })
AADD(aDBf,{ 'Porez'     , 'N' ,   9 ,  5 })
AADD(aDBf,{ 'K1'        , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K2'        , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'M1'        , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TXT'       , 'M' ,  10 ,  0 })
AADD(aDBf,{ 'IDVRSTEP'  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDPM'      , 'C' ,  15 ,  0 })

if (nArea==-1 .or. nArea==(F_FAKT))
	//FAKT.DBF
	
	if !FILE(KUMPATH+'FAKT.DBF')
        	DBcreate2(KUMPATH+'FAKT.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok+rbr+podbr",KUMPATH+"FAKT")
	CREATE_INDEX("2","IdFirma+dtos(datDok)+idtipdok+brdok+rbr",KUMPATH+"FAKT")
	CREATE_INDEX("3","idroba+dtos(datDok)",KUMPATH+"FAKT")
	if lPoNarudzbi
 		// sifru gradi IDNAR + idroba !!!!!!!!!!
  		CREATE_INDEX("3N","idnar+idroba+dtos(datDok)",KUMPATH+"FAKT")
	endif
	if izfmkini("SifRoba","ID_J")=="D"
 		// sifru gradi IDROBA_J + idroba !!!!!!!!!!
 		CREATE_INDEX("3J","idroba_j+idroba+dtos(datDok)",KUMPATH+"FAKT")
	endif
	// ako se koristi varijanta DITRIBUCIJA ukljuci i ove indexe
	if glDistrib
		CREATE_INDEX("4","idfirma+idtipdok+dtos(datdok)+idrelac+marsruta+brdok+rbr",KUMPATH+"FAKT")
  		CREATE_INDEX("5","idfirma+idtipdok+dtos(datdok)+idrelac+iddist+idvozila+idroba",KUMPATH+"FAKT")
  		CREATE_INDEX("6","idfirma+idpartner+idroba+idtipdok+dtos(datdok)",KUMPATH+"FAKT")
	endif
endif


if (nArea==-1 .or. nArea==(F_PRIPR))
	//PRIPR.DBF
	
	if !FILE(PRIVPATH+'PRIPR.DBF')
        	DBcreate2(PRIVPATH+'PRIPR.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok+rbr+podbr",PRIVPATH+"PRIPR")
	CREATE_INDEX("2","IdFirma+dtos(datdok)",PRIVPATH+"PRIPR")
	CREATE_INDEX("3","IdFirma+idroba+rbr",PRIVPATH+"PRIPR")

endif

if (nArea==-1 .or. nArea==(F__FAKT))
	//_FAKT.DBF
	
	if !FILE(PRIVPATH+'_FAKT.DBF')
        	DBcreate2(PRIVPATH+'_FAKT.DBF',aDbf)
	endif

	CREATE_INDEX("1","IdFirma+idtipdok+brdok+rbr+podbr",PRIVPATH+"_FAKT")
endif

#ifndef C50
	dbt2fpt(KUMPATH+'FAKT')
	dbt2fpt(PRIVPATH+'PRIPR')
	dbt2fpt(PRIVPATH+'_FAKT')
#endif


if (nArea==-1 .or. nArea==(F_UGOV))
	//UGOV.DBF
	
	aDBf:={}
	AADD(aDBF, { "ID"        , "C" , 10,  0 })
	AADD(aDBF, { "DatOd"     , "D" ,  8,  0 })
	AADD(aDBF, { "IDPartner" , "C" ,  6,  0 })
	AADD(aDBF, { "DatDo"     , "D" ,  8,  0 })
	AADD(aDBF, { "Naz"       , "C" , 20,  0 })
	AADD(aDBF, { "Vrsta"     , "C" ,  1,  0 })
	AADD(aDBF, { "IdTipdok"  , "C" ,  2,  0 })
	AADD(aDBF, { "Aktivan"   , "C" ,  1,  0 })
	AADD(aDBf, { 'DINDEM'    , 'C' ,  3,  0 })
	AADD(aDBf, { 'IdTXT'     , 'C' ,  2,  0 })
	AADD(aDBf, { 'zaokr'     , 'N' ,  1,  0 })
	AADD(aDBf, { 'IdDodTXT'  , 'C' ,  2,  0 })

	if !FILE(KUMPATH+"UGOV.DBF")
   		DBcreate2(KUMPATH+"UGOV.DBF",aDBF)
	endif
	
	CREATE_INDEX("ID"      ,"Id+idpartner" ,KUMPATH+"UGOV")
	CREATE_INDEX("NAZ"     ,"idpartner+Id" ,KUMPATH+"UGOV")
	CREATE_INDEX("NAZ2"    ,"naz"          ,KUMPATH+"UGOV")
	CREATE_INDEX("PARTNER" ,"IDPARTNER"    ,KUMPATH+"UGOV")
	CREATE_INDEX("AKTIVAN" ,"AKTIVAN"      ,KUMPATH+"UGOV")
	if glDistrib
  		CREATE_INDEX("1","AKTIVAN+VRSTA+IDPARTNER",KUMPATH+"UGOV")
	endif
endif


if (nArea==-1 .or. nArea==(F_RUGOV))
	//RUGOV.DBF
	
	aDbf:={}
	AADD(aDBF, { "ID"       , "C" ,  10,  0 })
	AADD(aDBF, { "IDROBA"   , "C" ,  10,  0 })
	AADD(aDBF, { "Kolicina" , "N" ,  15,  4 })
	AADD(aDBf, { 'Rabat'    , 'N' ,   6,  3 })
	AADD(aDBf, { 'Porez'    , 'N' ,   5,  2 })
	AADD(aDBf, { 'DESTIN'   , 'C' ,   1,  0 })

	if !FILE(KUMPATH+"RUGOV.DBF")
   		DBcreate2(KUMPATH+"RUGOV.DBF",aDBF)
	endif
	
	CREATE_INDEX("ID","id+IdRoba",KUMPATH+"RUGOV")
	CREATE_INDEX("IDROBA","IdRoba",KUMPATH+"RUGOV")
endif


if (nArea==-1 .or. nArea==(F_DEST))
	//DEST.DBF
        
	aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
        AADD(aDBf,{ 'NAZ2'                , 'C' ,  25 ,  0 })
        AADD(aDBf,{ 'OZNAKA'              , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'PTT'                 , 'C' ,   5 ,  0 })
        AADD(aDBf,{ 'MJESTO'              , 'C' ,  16 ,  0 })
        AADD(aDBf,{ 'ADRESA'              , 'C' ,  24 ,  0 })
        AADD(aDBf,{ 'TELEFON'             , 'C' ,  12 ,  0 })
        AADD(aDBf,{ 'FAX'                 , 'C' ,  12 ,  0 })
        AADD(aDBf,{ 'MOBTEL'              , 'C' ,  20 ,  0 })
        
	if !FILE(KUMPATH+"DEST.dbf")
		DBcreate2(KUMPATH+"DEST.DBF",aDbf)
	endif
	
	// destinacije (veza: ID=PARTN->id)
	CREATE_INDEX("1","ID+OZNAKA",KUMPATH+"DEST") 
endif

if (nArea==-1 .or. nArea==(F_DOKS))
	//DOKS.DBF
	
	aDbf:={}
	AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'IdTIPDok'            , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
	AADD(aDBf,{ 'PARTNER'             , 'C' ,  30 ,  0 })
	AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'DINDEM'              , 'C' ,   3 ,  0 })
	AADD(aDBf,{ 'Iznos'               , 'N' ,  12 ,  3 })
	AADD(aDBf,{ 'Rabat'               , 'N' ,  12 ,  3 })
	AADD(aDBf,{ 'Rezerv'              , 'C' ,   1 ,  0 })
	AADD(aDBf,{ 'M1'                  , 'C' ,   1 ,  0 })
	AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
	AADD(aDBf,{ 'IDVRSTEP'            , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'DATPL'               , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'IDPM'                , 'C' ,  15 ,  0 })

	if !FILE(KUMPATH+"DOKS.DBF")
        	DBcreate2(KUMPATH+'DOKS.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok",KUMPATH+"DOKS")
	CREATE_INDEX("2","IdFirma+idtipdok+partner",KUMPATH+"DOKS")
	CREATE_INDEX("3","partner",KUMPATH+"DOKS")
	CREATE_INDEX("4","idtipdok",KUMPATH+"DOKS")
	CREATE_INDEX("5","datdok",KUMPATH+"DOKS")
	CREATE_INDEX("6","IdFirma+idpartner+idtipdok",KUMPATH+"DOKS")
endif


if (nArea==-1 .or. nArea==(F_DOKS2))
	//BLOK: DOKS2
	
	aDbf:={}
	AADD(aDBf,{ "IDFIRMA"      , "C" ,   2 ,  0 })
	AADD(aDBf,{ "IDTIPDOK"     , "C" ,   2 ,  0 })
	AADD(aDBf,{ "BRDOK"        , "C" ,   8 ,  0 })
	AADD(aDBf,{ "K1"           , "C" ,  15 ,  0 })
	AADD(aDBf,{ "K2"           , "C" ,  15 ,  0 })
	AADD(aDBf,{ "K3"           , "C" ,  15 ,  0 })
	AADD(aDBf,{ "K4"           , "C" ,  20 ,  0 })
	AADD(aDBf,{ "K5"           , "C" ,  20 ,  0 })
	AADD(aDBf,{ "N1"           , "N" ,  15 ,  2 })
	AADD(aDBf,{ "N2"           , "N" ,  15 ,  2 })
	
	if !FILE(KUMPATH+"DOKS2.DBF")
        	DBcreate2(KUMPATH+"DOKS2.DBF",aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok",KUMPATH+"DOKS2")
endif


if (nArea==-1 .or. nArea==(F_VRSTEP))
	//VRSTEP.DBF
	
	aDbf:={}
	AADD(aDbf,{"ID" ,"C", 2,0})
	AADD(aDbf,{"NAZ","C",20,0})
	
	if !FILE(SIFPATH+"VRSTEP.DBF")
		DBcreate2(SIFPATH+"VRSTEP.DBF",aDbf)
	endif
	
	CREATE_INDEX("ID","Id",SIFPATH+"VRSTEP.DBF")
endif

if glDistrib
	if (nArea==-1 .or. nArea==(F_RELAC)) 
		//RELAC.DBF
		
		aDBf:={}
     		AADD(aDBf,{ "ID"                  , "C" ,   4 ,  0 })
     		AADD(aDBf,{ "NAZ"                 , "C" ,  10 ,  0 })
     		AADD(aDBf,{ "IDPARTNER"           , "C" ,   6 ,  0 })
     		AADD(aDBf,{ "IDPM"                , "C" ,  15 ,  0 })
     
  		if !FILE(SIFPATH+"RELAC.DBF")
     			DBcreate2(SIFPATH+"RELAC.DBF",aDbf)
  		endif
  		
		CREATE_INDEX("ID","id+naz"         ,SIFPATH+"RELAC")
  		CREATE_INDEX("1" ,"idpartner+idpm" ,SIFPATH+"RELAC")
	endif
        
	if (nArea==-1 .or. nArea==(F_VOZILA)) 
  		//VOZILA.DBF	
     		
		aDBf:={}
     		AADD(aDBf,{ "ID"                  , "C" ,   4 ,  0 })
     		AADD(aDBf,{ "NAZ"                 , "C" ,  25 ,  0 })
     		AADD(aDBf,{ "TABLICE"             , "C" ,  15 ,  0 })
		
		if !FILE(SIFPATH+"VOZILA.DBF")
     			DBcreate2(SIFPATH+"VOZILA.DBF",aDbf)
  		endif
  		
		CREATE_INDEX("ID","id",SIFPATH+"VOZILA")
	endif
	
	if (nArea==-1 .or. nArea==(F_KALPOS))  
  	 	//KALPOS.DBF
		
		aDBf:={}
     		AADD(aDBf,{ "DATUM"              , "D" ,   8 ,  0 })
     		AADD(aDBf,{ "IDRELAC"            , "C" ,   4 ,  0 })
     		AADD(aDBf,{ "IDDIST"             , "C" ,   6 ,  0 })
     		AADD(aDBf,{ "IDVOZILA"           , "C" ,   4 ,  0 })
     		AADD(aDBf,{ "REALIZ"             , "C" ,   1 ,  0 })
    		
		if !file(KUMPATH+"KALPOS.DBF")
     			DBcreate2(KUMPATH+"KALPOS.DBF",aDbf)
  		endif
  		
		CREATE_INDEX("1","DTOS(datum)",KUMPATH+"KALPOS")
  		CREATE_INDEX("2","IDRELAC+DTOS(datum)",KUMPATH+"KALPOS")
	endif
endif

return
*}



/*! \fn *void TDBFakt::obaza(int i)
 *  \brief otvara odgovarajucu tabelu
 *  
 *      
 */

*void TDBFakt::obaza(int i)
*{

method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_KORISN .or. i==F_PARAMS .or.  i==F_GPARAMS .or. i==F_GPARAMSP .or. i==F_MPARAMS .or. i==F_PRIPR 
	lIdiDalje:=.t.
endif
if i==F_FAKT  .or. i==F_DOKS .or. i==F_DOKS2 .or. i==F_RJ .or. i==F_UPL
	lIdiDalje:=.t.
endif

if i==F_ROBA .or. i==F__ROBA .or. i==F_TARIFA .or. i==F_PARTN .or. i==F_FTXT .or. i==F_VALUTE .or.  i==F_SAST  .or. i==F_KONTO  .or. i==F_VRSTEP .or. i==F_BANKE .or. i==F_OPS   
	lIdiDalje:=.t.
endif

if i==F_UGOV .or. i==F_RUGOV .or. i==F_DEST  .or. i==F_SECUR .or. i==F_ADRES
	lIdiDalje:=.t.
endif

if glDistrib
  	if i==F_RELAC .or. i==F_VOZILA .or. i==F_KALPOS
  		lIdiDalje:=.t.
	endif
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

/*! \fn *void TDBFakt::ostalef()
 *  \brief Ostalef funkcije (bivsi install modul)
 *  \note  sifra: SIGMAXXX
*/

*void TDBFakt::ostalef()
*{
method ostalef()


return
*}

/*! \fn *void TDBFakt::konvZn()
 *  \brief koverzija 7->8 baze podataka KALK
 */
 
*void TDBFakt::konvZn()
*{
method konvZn()

LOCAL cIz:="7", cU:="8", aPriv:={}, aKum:={}, aSif:={}
LOCAL GetList:={}, cSif:="D", cKum:="D", cPriv:="D"

if !gAppSrv
	IF !SigmaSif("KZ      ")
   		RETURN
	ENDIF

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

aPriv := { F_PRIPR, F__ROBA }
aKum  := { F_FAKT, F_DOKS, F_RJ, F_UGOV, F_RUGOV, F_UPL, F_DEST, F_DOKS2 }
aSif  := { F_ROBA, F_TARIFA, F_PARTN, F_FTXT, F_VALUTE, F_SAST, F_KONTO,;
           F_VRSTEP, F_OPS }

IF cSif  == "N"; aSif  := {}; ENDIF
IF cKum  == "N"; aKum  := {}; ENDIF
IF cPriv == "N"; aPriv := {}; ENDIF

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

