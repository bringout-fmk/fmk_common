
#include "\cl\sigma\fmk\fin\fin.ch"

function TDBFinNew()
*{
local oObj

oObj:=TDBFin():new()
oObj:self:=oObj
oObj:cName:="FIN"
Logg("TDBFinNew:"+oObj:cName)
return oObj
*}

/*! \file fmk/fin/db/2g/db.prg
 *  \brief FIN Database
 *
 * TDBFin Database objekat 
 */


/*! \class TDBFin
 *  \brief FIN Database objekat
 */



#ifdef CPP
#translate class { (<x>) } => 

class TDBFin: public TDB
{

     public:
     	  *TObject self;
          *void dummy();
	  *void skloniSez(string cSezona, bool finverse, bool fda, bool fnulirati, bool fRS);
	  *void install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7);
	  *void setgaDBFs();
	  *void obaza(int i);
	  *void ostalef();
	  *void konvZn();
	  *void kreiraj();
}

#endif

#include "class(y).ch"

*{
CREATE CLASS TDBPos INHERIT TDB 
	EXPORTED:
	var self
	method skloniSezonu	
	method install	
	method setgaDBFs	
	method ostalef	
	method obaza	
	method kreiraj	
	method konvZn

END CLASS
*}


/*! \fn *void TDBPos::dummy()
 */
*void TDBPos::dummy()
*{
method dummy
return
*}


/*! \fn *void TDBPos::skloniSez(string cSezona, bool finverse, bool fda, bool fnulirati, bool fRS)
 *  \brief formiraj sezonsku bazu podataka
 */
 
*void TDBPos::skloniSez(string cSezona, bool finverse, bool fda, bool fnulirati, bool fRS)
*{
method skloniSezonu(cSezona, finverse, fda, fnulirati, fRS)
local cScr

????????????

return
*}

/*! \fn *void TDBPos::setgaDBFs()
 *  \brief Setuje matricu gaDBFs 
 */
*void TDBPos::setgaDBFs()
*{
method setgaDBFs()
PUBLIC gaDBFs:={ ;
......
{  F_DOKS      , "DOKS", P_KUMPATH },;
..........

}
return
*}


/*! \fn *void TDBPos::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
 *  \brief osnovni meni za instalacijske procedure
 *  \todo  prosljedjuje se goModul, ovo ce biti eliminsano eliminisanjem ISC_START-a procedure (tj zamjenom odgovarajucim klasama)
 */

*void TDBPos::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
*{
method install()
ISC_START(goModul,.f.)
return
*}

/*! *void TDBPos::kreiraj()
 *  \brief kreirane baze podataka POS
 */
 
*void TDBPos::kreiraj()
*{
method kreiraj()

??????????????????????????????
....

return
*}

/*! \fn *void TDBFin::obaza(int i)
 *  \brief otvara odgovarajucu tabelu
 *  
 *  S obzirom da se koristi prvenstveno za instalacijske funkcije
 *  otvara tabele u exclusive rezimu
 */

*void TDBFin::obaza(int i)
*{
method obaza (i)
local lIdIDalje
local cDbfName

?????????????????????????????

lIdiDalje:=.f.

if ( i==F_DOKS .or. i==F_POS .or. i==F_RNGPLA .or. i==F__POS .or. i==F__PRIPR .or. i==F_PRIPRZ ) 
	lIdiDalje:=.t.
endif

if (i==F_PRIPRG .or. i==F_K2C .or. i==F_MJTRUR .or. i==F_ROBAIZ .or. i==F_ROBA) 
	lIdiDalje:=.t.
endif

if i==F_SIROV .or. i==F_SAST .or. i==F_OSOB .or. i==F_STRAD 
	lIdiDalje:=.t.
endif

if i==F_TARIFA .or. i==F_VALUTE .or. i==F_VRSTEP .or. i==F_KASE .or. i==F_ODJ 
	lIdiDalje:=.t.
endif

if i==F_DIO .or. i==F_UREDJ .or. i==F_RNGOST .or. i==F_MARS .or. i==F_PARAMS .or. i==F_GPARAMS .or. i==F_KORISN .or. i==F_MPARAMS .or. i==F_GPARAMS
	lIdiDalje:=.t.
endif

if lIdiDalje
	cDbfName:=DBFName(i)
	select(i)
	usex(cDbfName)
else
	use
	return
endif

return
*}

/*! \fn *void TDBFin::ostalef()
 *  \brief Ostalef funkcije (bivsi install modul)
*/

*void TDBPos::ostalef()
*{

method ostalef()

??????????????????


closeret
return
*}

/*! \fn *void TDBPos::konvZn()
 *  \brief Koverzija znakova
 */
 
*void TDBPos::konvZn()
*{
method konvZn()

???

return
*}


