#include "\cl\sigma\fmk\virm\virm.ch"
 
function TDbVIRMNew()
*{
local oObj
oObj:=TDbVirm():new()
oObj:self:=oObj
oObj:cName:="VIRM"
oObj:lAdmin:=.f.
return oObj
*}

/*! \file fmk/virm/db/2g/db.prg
 *  \brief VIRM Database
 *
 * TDbVirm Database objekat 
 */


/*! \class TDbVirm
 *  \brief Database objekat
 */


#ifdef CPP
class TDbVirm: public TDB 
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
CREATE CLASS TDbVirm INHERIT TDB

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


/*! \fn *void TDbVirm::dummy()
 */
*void TDbVirm::dummy()
*{
method dummy
return
*}

/*! \fn *void TDbVirm::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
 *  \brief formiraj sezonsku bazu podataka
 *  \param cSezona - 
 *  \param fInverse - .t. iz sezone u radno, .f. iz radnog u sezonu
 *  \param fda - ne znam
 *  \param fnulirati - nulirati tabele
 *  \param fRS - ne znam
 */

*void TDbVirm::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
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

if fInverse
	? "Prenos iz  sezonskih direktorija u radne podatke"
else
 	? "Prenos radnih podataka u sezonske direktorije"
endif

?

// Privatne datoteke
fNul:=.f.
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PRIPR.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PRIPR2.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"IZLAZ.DBF",cSezona,finverse,fda,fnul)

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

if fNulirati
	fNul:=.t.
else
	fNul:=.f.
endif  

// Kumulativne datoteke
Skloni(KUMPATH,"KUMUL.DBF",cSezona,finverse,fda,fnul)

// Sifranici
fnul:=.f.
Skloni(SIFPATH,"VRPRIM.dbf",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"STAMP.dbf",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"PARTN.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VALUTE.DBF",cSezona,finverse,fda,fnul)



?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr
return
*}

/*! \fn *void TDbVirm::setgaDbfs()
 *  \brief Setuje matricu gaDbfs 
 */
*void TDbVirm::setgaDbfs()
*{
method setgaDBFs()

public gaDbfs := {;
{ F_PARAMS ,"PARAMS"  , P_PRIVPATH    },;
{ F_VIPRIPR,"PRIPR"   , P_PRIVPATH    },;
{ F_VIPRIP2,"PRIPR2"  , P_PRIVPATH    },;
{ F_IZLAZ  ,"IZLAZ"   , P_PRIVPATH    },;
{ F_VRPRIM ,"VRPRIM"  , P_KUMPATH     },;
{ F_VRPRIM2,"VRPRIM2" , P_KUMPATH     },;
{ F_LDVIRM ,"LDVIRM"  , P_KUMPATH     },;
{ F_KALVIR ,"KALVIR"  , P_KUMPATH     },;
{ F_KUMUL  ,"KUMUL"   , P_KUMPATH     },;
{ F_KUMUL2 ,"KUMUL2"  , P_KUMPATH     },;
{ F_STAMP  ,"STAMP"   , P_SIFPATH     },;
{ F_STAMP2 ,"STAMP2"  , P_SIFPATH     },;
{ F_PARTN  ,"PARTN"   , P_SIFPATH     },;
{ F_BANKE  ,"BANKE"   , P_SIFPATH     },;
{ F_OPS    ,"OPS"     , P_SIFPATH     },;
{ F_SIFK   ,"SIFK"    , P_SIFPATH     },;
{ F_SIFV   ,"SIFV"    , P_SIFPATH     },;
{ F_JPRIH  ,"JPRIH"   , P_SIFPATH     },;
{ F_VALUTE ,"VALUTE"  , P_SIFPATH     };
}

return
*}


/*! \fn *void TDbVirm::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
 *  \brief osnovni meni za instalacijske procedure
 */

*void TDbVirm::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
*{

method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	ISC_START(goModul,.f.)
return
*}

/*! \fn *void TDbVirm::kreiraj(int nArea)
 *  \brief kreirane baze podataka VIRM-a
 */
 
*void TDbVirm::kreiraj(int nArea)
*{
method kreiraj(nArea)

if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

CreFMKSvi()

aDbf:={}
AADD(aDBf,{ 'RBR'        , 'N' ,   3 ,   0 })
AADD(aDBf,{ 'MJESTO'     , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DAT_UPL'    , 'D' ,   8 ,   0 })
AADD(aDBf,{ 'SVRHA_PL'   , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NA_TERET'   , 'C' ,   6 ,   0 }) // ko  placa - sifra
AADD(aDBf,{ 'U_KORIST'   , 'C' ,   6 ,   0 }) // kome se placa - sifra
AADD(aDBf,{ 'KO_TXT'     , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KO_ZR'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_TXT'   , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KOME_ZR'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KO_SJ'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_SJ'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'SVRHA_DOZ'  , 'C' ,  92 ,   0 })
AADD(aDBf,{ 'PNABR'      , 'C' ,  10 ,   0 })
AADD(aDBf,{ 'Hitno'      , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'Vupl'       , 'C' ,   1 ,   0 })
AADD(aDBF,{ 'IdOps'      , 'C' ,   3 ,   0 })
AADD(aDBF,{ 'POd'        , 'D' ,   8 ,   0 })
AADD(aDBF,{ 'PDo'        , 'D' ,   8 ,   0 })
AADD(aDBF,{ 'BPO'        , 'C' ,  13 ,   0 })
AADD(aDBF,{ 'BudzOrg'    , 'C' ,   7 ,   0 })
AADD(aDBF,{ 'IdJPrih'    , 'C' ,   6 ,   0 })
AADD(aDBf,{ 'IZNOS'      , 'N' ,  20 ,   2 })
AADD(aDBf,{ 'IZNOSSTR'   , 'C' ,  20 ,   0 })
AADD(aDBf,{ '_ST_'   ,     'C' ,   1 ,   0 })

if (nArea==-1 .or. nArea==(F_VIPRIPR))
	IF !FILE(PRIVPATH+'PRIPR.DBF')
		DBCREATE2(PRIVPATH+'PRIPR.DBF',aDbf)
	ENDIF
	CREATE_INDEX("1","STR(rbr,3)",PRIVPATH+"PRIPR")
	CREATE_INDEX("2","DTOS(dat_upl)+STR(rbr,3)",PRIVPATH+"PRIPR")
endif


if (nArea==-1 .or. nArea==(F_KUMUL))
	IF !FILE(KUMPATH+'KUMUL.DBF')
		DBCREATE2(KUMPATH+'KUMUL.DBF',aDbf)
	ENDIF
	CREATE_INDEX("1","STR(rbr,3)",KUMPATH+"KUMUL")
	CREATE_INDEX("2","DTOS(dat_upl)+STR(rbr,3)",KUMPATH+"KUMUL")
	CREATE_INDEX("3","na_teret+u_korist",KUMPATH+"KUMUL")
	CREATE_INDEX("4","u_korist+na_teret",KUMPATH+"KUMUL")
endif


if (nArea==-1 .or. nArea==(F_VIPRIP2))
	IF !FILE(PRIVPATH+'PRIPR2.DBF')
		DBCREATE2(PRIVPATH+'PRIPR2.DBF',aDbf)
	ENDIF
	CREATE_INDEX("1","STR(rbr,3)",PRIVPATH+"PRIPR2")
	CREATE_INDEX("2","DTOS(dat_upl)+STR(rbr,3)",PRIVPATH+"PRIPR2")
endif

if (nArea==-1 .or. nArea==(F_KUMUL2))
	IF !FILE(KUMPATH+'KUMUL2.DBF')
		DBCREATE2(KUMPATH+'KUMUL2.DBF',aDbf)
	ENDIF
	CREATE_INDEX("1","STR(rbr,3)",KUMPATH+"KUMUL2")
	CREATE_INDEX("2","DTOS(dat_upl)+STR(rbr,3)",KUMPATH+"KUMUL2")
	CREATE_INDEX("3","na_teret+u_korist",KUMPATH+"KUMUL2")
	CREATE_INDEX("4","u_korist+na_teret",KUMPATH+"KUMUL2")
endif


aDbf:={}
AADD(aDBf,{ 'RBR'        , 'N' ,   3 ,   0 })
AADD(aDBf,{ 'MJESTO'     , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DAT_UPL'    , 'C' ,  15 ,   0 })
AADD(aDBf,{ 'SVRHA_PL'   , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NA_TERET'   , 'C' ,   6 ,   0 }) // ko  placa - sifra
AADD(aDBf,{ 'U_KORIST'   , 'C' ,   6 ,   0 }) // kome se placa - sifra
AADD(aDBf,{ 'KO_TXT'     , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KO_ZR'      , 'C' ,  31 ,   0 })
AADD(aDBf,{ 'KOME_TXT'   , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KOME_ZR'    , 'C' ,  31 ,   0 })
AADD(aDBf,{ 'KO_SJ'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_SJ'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'SVRHA_DOZ'  , 'C' ,  92 ,   0 })
AADD(aDBf,{ 'PNABR'      , 'C' ,  19 ,   0 })
AADD(aDBf,{ 'Hitno'      , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'Vupl'       , 'C' ,   1 ,   0 })
AADD(aDBF,{ 'IdOps'      , 'C' ,   5 ,   0 })
AADD(aDBF,{ 'POd'        , 'C' ,  15 ,   0 })
AADD(aDBF,{ 'PDo'        , 'C' ,  15 ,   0 })
AADD(aDBF,{ 'BPO'        , 'C' ,  25 ,   0 })
AADD(aDBF,{ 'BudzOrg'    , 'C' ,  13 ,   0 })
AADD(aDBF,{ 'IdJPrih'    , 'C' ,  11 ,   0 })
AADD(aDBf,{ 'IZNOS'      , 'N' ,  20 ,   2 })
AADD(aDBf,{ 'IZNOSSTR'   , 'C' ,  20 ,   0 })
AADD(aDBf,{ '_ST_'   ,     'C' ,   1 ,   0 })

if (nArea==-1 .or. nArea==(F_IZLAZ))
	IF !FILE(PRIVPATH+'IZLAZ.DBF')
		DBCREATE2(PRIVPATH+'IZLAZ.DBF',aDbf)
	ENDIF
	CREATE_INDEX("1","STR(rbr,3)",PRIVPATH+"IZLAZ")
endif


aDbf:={}
AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NAZ'        , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'POM_TXT'    , 'C' ,  65 ,   0 })
AADD(aDBf,{ 'IDKONTO'    , 'C' ,   7 ,   0 })
AADD(aDBf,{ 'IDPartner'  , 'C' ,   6 ,   0 })
AADD(aDBf,{ 'NACIN_PL'   , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'RACUN'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DOBAV'      , 'C' ,   1 ,   0 })

if (nArea==-1 .or. nArea==(F_VRPRIM))
	IF !FILE(KUMPATH+'VRPRIM.DBF')
		DBCREATE2(KUMPATH+'VRPRIM.DBF',aDbf)
	ENDIF
	CREATE_INDEX("ID","id",KUMPATH+"VRPRIM")
	CREATE_INDEX("NAZ","naz",KUMPATH+"VRPRIM")
	CREATE_INDEX("IDKONTO","idkonto+idpartner",KUMPATH+"VRPRIM")
endif

if (nArea==-1 .or. nArea==(F_VRPRIM2))
	IF !FILE(KUMPATH+'VRPRIM2.DBF')
		DBCREATE2(KUMPATH+'VRPRIM2.DBF',aDbf)
	ENDIF
	CREATE_INDEX("ID","id",KUMPATH+"VRPRIM2")
	CREATE_INDEX("NAZ","naz",KUMPATH+"VRPRIM2")
	CREATE_INDEX("IDKONTO","idkonto+idpartner",KUMPATH+"VRPRIM2")
endif

if (nArea==-1 .or. nArea==(F_LDVIRM))
	IF !FILE(KUMPATH+'LDVIRM.DBF')
		aDbf:={}
		AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
		AADD(aDBf,{ 'NAZ'        , 'C' ,  50 ,   0 })
		AADD(aDBf,{ 'FORMULA'    , 'C' ,  70 ,   0 })
		DBCREATE2(KUMPATH+'LDVIRM.DBF',aDbf)
	ENDIF
	CREATE_INDEX("ID","id",KUMPATH+"LDVIRM")
endif


if (nArea==-1 .or. nArea==(F_KALVIR))
	IF !FILE(KUMPATH+'KALVIR.DBF')
		aDbf:={}
		AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
		AADD(aDBf,{ 'NAZ'        , 'C' ,  20 ,   0 })
		AADD(aDBf,{ 'FORMULA'    , 'C' ,  70 ,   0 })
		AADD(aDBf,{ 'PNABR'      , 'C' ,  10 ,   0 })
		DBCREATE2(KUMPATH+'KALVIR.DBF',aDbf)
	ENDIF
	CREATE_INDEX("ID","id",KUMPATH+"KALVIR")
endif

aDbf:={}
AADD(aDBf,{ 'ID'         , 'C' ,  20 ,   0 })
AADD(aDBf,{ 'NAZ'        , 'C' ,  40 ,   0 })
AADD(aDBf,{ 'V_POMAK'    , 'N' ,   6 ,   2 })
AADD(aDBf,{ 'H_POMAK'    , 'N' ,   6 ,   2 })
AADD(aDBf,{ 'RAVNANJE'   , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'DUZINA'     , 'N' ,   2 ,   0 })
AADD(aDBf,{ 'STAMPATI'   , 'C' ,   1 ,   0 })

if (nArea==-1 .or. nArea==(F_STAMP))
	IF !FILE(SIFPATH+'STAMP.DBF')
		DBCREATE2(SIFPATH+'STAMP.DBF',aDbf)
	ENDIF
	CREATE_INDEX("ID","stampati+STR(v_pomak,2)+STR(h_pomak,2)",SIFPATH+"STAMP")
endif

if (nArea==-1 .or. nArea==(F_STAMP2))
	IF !FILE(SIFPATH+'STAMP2.DBF')
		DBCREATE2(SIFPATH+'STAMP2.DBF',aDbf)
	ENDIF
	CREATE_INDEX("ID","stampati+STR(v_pomak,2)+STR(h_pomak,2)",SIFPATH+"STAMP2")
endif

if (nArea==-1 .or. nArea==(F_PARTN))
	if !file(SIFPATH+"PARTN.dbf")
		*********  PARTN.DBF   ***********
		aDbf:={}
		AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
		AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
		AADD(aDBf,{ 'NAZ2'                , 'C' ,  25 ,  0 })
		AADD(aDBf,{ 'PTT'                 , 'C' ,   5 ,  0 })
		AADD(aDBf,{ 'MJESTO'              , 'C' ,  16 ,  0 })
		AADD(aDBf,{ 'ADRESA'              , 'C' ,  24 ,  0 })
		AADD(aDBf,{ 'ZIROR'               , 'C' ,  22 ,  0 })
		AADD(aDBf,{ 'DZIROR'              , 'C' ,  22 ,  0 })
		AADD(aDBf,{ 'TELEFON'             , 'C' ,  12 ,  0 })
		AADD(aDBf,{ 'FAX'                 , 'C' ,  12 ,  0 })
		AADD(aDBf,{ 'MOBTEL'              , 'C' ,  20 ,  0 })
		DBCREATE2(SIFPATH+'PARTN.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id",SIFPATH+"PARTN") // firme
	CREATE_INDEX("NAZ","naz",SIFPATH+"PARTN")
endif
 
if (nArea==-1 .or. nArea==(F_VALUTE))
	if !file(SIFPATH+"VALUTE.DBF")
		*********  VALUTE.DBF   ***********
		aDbf:={}
		AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
		AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
		AADD(aDBf,{ 'NAZ2'                , 'C' ,   4 ,  0 })
		AADD(aDBf,{ 'DATUM'               , 'D' ,   8 ,  0 })
		AADD(aDBf,{ 'KURS1'               , 'N' ,  10 ,  3 })
		AADD(aDBf,{ 'KURS2'               , 'N' ,  10 ,  3 })
		AADD(aDBf,{ 'KURS3'               , 'N' ,  10 ,  3 })
		AADD(aDBf,{ 'TIP'                 , 'C' ,   1 ,  0 })
		DBCREATE2(SIFPATH+'VALUTE.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id", SIFPATH+"VALUTE")
	CREATE_INDEX("NAZ","tip+id+dtos(datum)", SIFPATH+"VALUTE")
endif


if (nArea==-1 .or. nArea==(F_BANKE))
	if !file(SIFPATH+"BANKE.DBF")
		*********  BANKE.DBF   ***********
		aDbf:={}
		AADD(aDBf,{ 'ID'                  , 'C' ,   3 ,  0 })
		AADD(aDBf,{ 'NAZ'                 , 'C' ,  45 ,  0 })
		AADD(aDBf,{ 'Mjesto'              , 'C' ,  20 ,  0 })
		DBCREATE2(SIFPATH+'BANKE.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id", SIFPATH+"BANKE")
	CREATE_INDEX("NAZ","naz", SIFPATH+"BANKE")
endif


if (nArea==-1 .or. nArea==(F_JPRIH))
	if !file(SIFPATH+"JPRIH.DBF")
		*********  JPRIH.DBF   ***********
		aDbf:={}
		AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
		AADD(aDBf,{ 'IdN0'                , 'C' ,   1 ,  0 })
		AADD(aDBf,{ 'IdKan'               , 'C' ,   2 ,  0 })
		AADD(aDBf,{ 'IdOps'               , 'C' ,   3 ,  0 })
		AADD(aDBf,{ 'Naz'                 , 'C' ,  40 ,  0 })
		AADD(aDBf,{ 'Racun'               , 'C' ,  16 ,  0 })
		AADD(aDBf,{ 'BudzOrg'             , 'C' ,  7 ,  0 })
		DBCREATE2(SIFPATH+'JPRIH.DBF',aDbf)
	endif
	CREATE_INDEX("Id","id+IdOps+IdKan+IdN0+Racun", SIFPATH+"JPRIH")
	CREATE_INDEX("Naz","Naz+IdOps", SIFPATH+"JPRIH")
endif

if (nArea==-1 .or. nArea==(F_OPS))
	if !file(SIFPATH+"OPS.DBF")
		************ tipovi primanja *************
		aDBf:={}
		AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
		AADD(aDBf,{ 'IDJ'                 , 'C' ,   3 ,  0 })
		AADD(aDBf,{ 'IdN0'                , 'C' ,   1 ,  0 })
		AADD(aDBf,{ 'IdKan'               , 'C' ,   2 ,  0 })
		AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
		DBCREATE2(SIFPATH+'OPS.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id",SIFPATH+"OPS")
	CREATE_INDEX("IDJ","idj",SIFPATH+"OPS")
	CREATE_INDEX("IDKAN","idKAN",SIFPATH+"OPS")
	CREATE_INDEX("IDN0","IDN0",SIFPATH+"OPS")
	CREATE_INDEX("NAZ","naz",SIFPATH+"OPS")
endif


if (nArea==-1 .or. nArea==(F_SIFK))
	if !file(SIFPATH+"SIFK.DBF")
		aDbf:={}
		AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
		AADD(aDBf,{ 'SORT'                , 'C' ,   2 ,  0 })
		AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
		AADD(aDBf,{ 'Oznaka'              , 'C' ,   4 ,  0 })
		AADD(aDBf,{ 'Veza'                , 'C' ,   1 ,  0 })
		AADD(aDBf,{ 'Unique'              , 'C' ,   1 ,  0 })
		AADD(aDBf,{ 'Izvor'               , 'C' ,  15 ,  0 })
		AADD(aDBf,{ 'Uslov'               , 'C' , 100 ,  0 })
		AADD(aDBf,{ 'Duzina'              , 'N' ,   2 ,  0 })
		AADD(aDBf,{ 'Decimal'             , 'N' ,   1 ,  0 })
		AADD(aDBf,{ 'Tip'                 , 'C' ,   1 ,  0 })
		AADD(aDBf,{ 'KVALID'              , 'C' , 100 ,  0 })
		AADD(aDBf,{ 'KWHEN'               , 'C' , 100 ,  0 })
		AADD(aDBf,{ 'UBROWSU'             , 'C' ,   1 ,  0 })
		AADD(aDBf,{ 'EDKOLONA'            , 'N' ,   2 ,  0 })
		AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
		AADD(aDBf,{ 'K2'                  , 'C' ,   2 ,  0 })
		AADD(aDBf,{ 'K3'                  , 'C' ,   3 ,  0 })
		AADD(aDBf,{ 'K4'                  , 'C' ,   4 ,  0 })
		// Primjer:
		// ID   = ROBA
		// NAZ  = Barkod
		// Oznaka = BARK
		// VEZA  = N ( 1 - moze biti samo jedna karakteristika, N - n karakteristika)
		// UNIQUE = D - radi se o jedinstvenom broju
		// Izvor =  ( sifrarnik  koji sadrzi moguce vrijednosti)
		// Uslov =  ( za koje grupe artikala ova karakteristika je interesantna
		// DUZINA = 13
		// Tip = C ( N numericka, C - karakter, D datum )
		// Valid = "ImeFje()"
		// validacija  mogu biti vrijednosti A,B,C,D
		//             aktiviraj funkciju ImeFje()
		dbcreate2(SIFPATH+'SIFK.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id+SORT+naz",SIFPATH+"SIFK")
	CREATE_INDEX("ID2","id+oznaka",SIFPATH+"SIFK")
	CREATE_INDEX("NAZ","naz",SIFPATH+"SIFK")
endif



if (nArea==-1 .or. nArea==(F_SIFV))
	if !file(SIFPATH+"SIFV.DBF")  // sifrarnici - vrijednosti karakteristika
		aDbf:={}
		AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
		AADD(aDBf,{ 'Oznaka'              , 'C' ,   4 ,  0 })
		AADD(aDBf,{ 'IdSif'               , 'C' ,  15 ,  0 })
		AADD(aDBf,{ 'NAZ'                 , 'C' ,  50 ,  0 })
		// Primjer:
		// ID  = ROBA
		// OZNAKA = BARK
		// IDSIF  = 2MON0005
		// NAZ = 02030303030303
		dbcreate2(SIFPATH+'SIFV.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id+oznaka+IdSif+Naz",SIFPATH+"SIFV")
	CREATE_INDEX("IDIDSIF","id+IdSif",SIFPATH+"SIFV")
	//  ROBA + BARK + 2MON0001
	CREATE_INDEX("NAZ","id+oznaka+naz",SIFPATH+"SIFV")
endif

return
*}



/*! \fn *void TDbVirm::obaza(int i)
 *  \brief otvara odgovarajucu tabelu
 *  
 *      
 */

*void TDbVirm::obaza(int i)
*{

method obaza(i)

local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_PARAMS .or. i==F_VIPRIPR .or. i==F_VIPRIP2 .or. i==F_IZLAZ  
	lIdiDalje:=.t.
endif

if i==F_KUMUL .or. i==F_KUMUL2 .or. i==F_LDVIRM .or. i==F_KALVIR .or. i==F_VRPRIM  .or. i==F_VRPRIM2 
	lIdiDalje:=.t.
endif

if i==F_JPRIH .or. i==F_STAMP .or. i==F_STAMP2 .or. i==F_PARTN .or. i==F_VALUTE .or. i==F_BANKE .or. i==F_OPS
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

/*! \fn *void TDbVirm::ostalef()
 *  \brief Ostalef funkcije (bivsi install modul)
 *  \note  sifra: SIGMAXXX
*/

*void TDbVirm::ostalef()
*{
method ostalef()

return
*}

/*! \fn *void TDbVirm::konvZn()
 *  \brief koverzija 7->8 baze podataka VIRM-a
 */
 
*void TDbVirm::konvZn()
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

aPriv:= { }
aKum:= { F_KUMUL, F_KUMUL2, F_VRPRIM, F_K_VRPRIM, F_VRPRIM2 }
aSif:={ F_JPRIH, F_STAMP, F_STAMP2, F_PARTN, F_VALUTE, F_BANKE, F_OPS }

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

