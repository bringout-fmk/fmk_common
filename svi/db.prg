#include "sc.ch"

/*! \todo koristi li se ova tabela TOKVAL, ako ne ukloniti je
 */
 
function OFmkSvi()
*{
O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_VALUTE
O_RJ
O_BANKE
O_OPS
select(F_SIFK)
if !used()
  O_SIFK
  O_SIFV
endif
if (!("U" $ TYPE("gSecurity")) .and. gSecurity=="D")
	O_USERS
	O_RULES
	O_GROUPS
	O_EVENTS
	O_EVENTLOG
endif
if (IsRamaGlas().or.gModul=="FAKT".and.glRadNal)
	O_RNAL
endif
return
*}

/*! \fn OSifVindija()
 *  \brief Priprema specificne tabele koje koristi Vindija
 */
 
function OSifVindija()
*{
O_RELAC
O_VOZILA
O_KALPOS
return
*}

function OSifDoksTxt()
*{
O_DOKSTXT
*}

function OSifFtxt()
*{
O_FTXT
return
*}

function OSifUgov()
*{
O_UGOV
O_RUGOV
if (rugov->(FIELDPOS("DESTIN"))<>0)
	O_DEST
endif
O_PARTN
O_ROBA
O_SIFK
O_SIFV
*}

function CreFmkSvi()
*{


if !file(KUMPATH+"RJ.DBF")
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  35 ,  0 })
   DBCREATE2(KUMPATH+'RJ.DBF',aDbf)
endif


CREATE_INDEX("ID","id",KUMPATH+"RJ")
CREATE_INDEX("NAZ","NAZ",KUMPATH+"RJ")


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
if !file(SIFPATH+"PARTN.dbf")
        dbcreate2(SIFPATH+'PARTN.DBF',aDbf)
endif
if !file(PRIVPATH+"_PARTN.dbf")
        dbcreate2(PRIVPATH+'_PARTN.DBF',aDbf)
endif

CREATE_INDEX("ID","id",SIFPATH+"PARTN") // firme
CREATE_INDEX("NAZ","naz",SIFPATH+"PARTN")
CREATE_INDEX("ID","id",PRIVPATH+"_PARTN")


if !file(SIFPATH+"KONTO.dbf")
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   7 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  57 ,  0 })
   dbcreate2(SIFPATH+'KONTO.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"KONTO") // konta
CREATE_INDEX("NAZ","naz",SIFPATH+"KONTO")


if !file(SIFPATH+"VALUTE.DBF")
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
        AADD(aDBf,{ 'NAZ2'                , 'C' ,   4 ,  0 })
        AADD(aDBf,{ 'DATUM'               , 'D' ,   8 ,  0 })
        AADD(aDBf,{ 'KURS1'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'KURS2'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'KURS3'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'TIP'                 , 'C' ,   1 ,  0 })
        dbcreate2(SIFPATH+'VALUTE.DBF',aDbf)

        use   (SIFPATH+'VALUTE.DBF')
        append blank
        replace id with "000", naz with "KONVERTIBILNA MARKA", ;
                NAZ2 WITH "KM", DATUM WITH CTOD("01.01.04"), TIP WITH "D",;
                KURS1 WITH 1, KURS2 WITH 1, KURS3 WITH 1
        append blank
        replace id with "978", naz with "EURO", ;
                NAZ2 WITH "EUR", DATUM WITH CTOD("01.01.04"), TIP WITH "P",;
                KURS1 WITH 0.512, KURS2 WITH 0.512, KURS3 WITH 0.512
        CLOSE ALL

endif

CREATE_INDEX("ID","id", SIFPATH+"VALUTE")
CREATE_INDEX("NAZ","tip+id+dtos(datum)", SIFPATH+"VALUTE")
CREATE_INDEX("ID2","id+dtos(datum)", SIFPATH+"VALUTE")

if !file(SIFPATH+'TOKVAL.dbf')
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,  8  ,  2 })
        AADD(aDBf,{ 'NAZ'                 , 'N' ,  8 ,   2 })
        AADD(aDBf,{ 'NAZ2'                , 'N' ,  8 ,   2 })
        dbcreate2(SIFPATH+'TOKVAL.DBF',aDbf)
endif

CREATE_INDEX("ID","id",SIFPATH+"tokval")

if !file(SIFPATH+"SIFK.dbf")
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


if !file(SIFPATH+"SIFV.dbf")  // sifrarnici - vrijednosti karakteristika
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

//BLOK: Tna, tdok
if !file(SIFPATH+"TNAL.dbf")
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  29 ,  0 })
        dbcreate2(SIFPATH+'TNAL.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"TNAL")  // vrste naloga
CREATE_INDEX("NAZ","naz",SIFPATH+"TNAL")

if !file(SIFPATH+"TDOK.dbf")
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  13 ,  0 })
        dbcreate2(SIFPATH+'TDOK.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"TDOK")  // Tip dokumenta
CREATE_INDEX("NAZ","naz",SIFPATH+"TDOK")

if !file(SIFPATH+"OPS.DBF")
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'IDJ'                 , 'C' ,   3 ,  0 })
   AADD(aDBf,{ 'IdN0'                , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'IdKan'               , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
   DBCREATE2(SIFPATH+'OPS.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"OPS")

if PoljeExist("IDJ")
	CREATE_INDEX("IDJ","idj",SIFPATH+"OPS")
endif
if PoljeExist("IDKAN")
	CREATE_INDEX("IDKAN","idKAN",SIFPATH+"OPS")
endif
if PoljeExist("IDN0")
	CREATE_INDEX("IDN0","IDN0",SIFPATH+"OPS")
endif
CREATE_INDEX("NAZ","naz",SIFPATH+"OPS")

if !file(SIFPATH+"BANKE.DBF")
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   3 ,  0 })
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  45 ,  0 })
        AADD(aDBf,{ 'Mjesto'              , 'C' ,  20 ,  0 })
        AADD(aDBf,{ 'Adresa'              , 'C' ,  30 ,  0 })
        DBCREATE2(SIFPATH+'BANKE.DBF',aDbf)
endif

CREATE_INDEX("ID","id", SIFPATH+"BANKE")
CREATE_INDEX("NAZ","naz", SIFPATH+"BANKE")


if !file(SIFPATH+"RNAL.DBF")
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  60 ,  0 })
   DBCREATE2(SIFPATH+'RNAL.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"RNAL")  // vrste naloga
CREATE_INDEX("NAZ","naz",SIFPATH+"RNAL")

if !FILE(SIFPATH+"DOKSTXT.DBF")
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
   AADD(aDBf,{ 'MODUL'               , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'POZICIJA'            , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'TXT'                 , 'C' , 340 ,  0 })
   AADD(aDBf,{ 'TXT2'                , 'C' , 340 ,  0 })
   DBCREATE2(SIFPATH+'DOKSTXT.DBF',aDbf)
endif
CREATE_INDEX("ID","modul+id+pozicija",SIFPATH+"DOKSTXT")  // Tip dokumenta

nArea:=nil

if (!("U"$TYPE("gSecurity")) .and. gSecurity=="D")
	CreEvents(nArea)
	CreSecurity(nArea)
endif

if IsRabati()
	CreRabDB()
endif

// kreiraj lokal tabelu
cre_lokal(F_LOKAL)

return
*}



function PoljeExist(cNazPolja)
*{
O_OPS
if OPS->(FieldPos(cNazPolja))<>0
	use
	return .t.
else
	use
	return .f.
endif

return
*}

