#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/sql/2g/sql.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.3 $
 * $Log: sql.prg,v $
 * Revision 1.3  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.2  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.1  2002/07/30 16:44:01  ernad
 *
 *
 * -
 *
 *
 */

*string
static cTblSif:="#KONTO#PARTN#VALUTE#SIFK#SIFV#TDOK#TNAL#VALUTE"
*;

*string
static cTblKum:="#NALOG#SUBAN#ANAL#SINT#RJ"
*;

*string
static cTblPriv:="#PARAM#YY"
*;

 

/*! \fn TSqlLogNew()
 *  \brief funkcija koja kreira SqlLog objekat
 */

function TSqlLogNew()
*{
local oObj

#ifdef CLIP
	oObj:=TSqlLogNew()
	oObj:open:=@open()
#else
	oObj:=TSqlLog():new()
#endif

oObj:self:=oObj
return oObj
*}

#ifdef CPP

/*! \class TSqlLog
 *  \brief FIN aplikacijski modul
 */

class TSqlLog
{
	public:
	integer nSite;
	integer nUser;
	*bool open();
	*void genZeroState();
	*void genPeriod();
	*bool import(integer nSite);
	*void autoImport();
	*bool startSynchro();
	*void menuAdmin();
	*void importInteractive();
}
#endif


#ifndef CPP
#include "class(y).ch"
CREATE CLASS TSqlLog INHERIT TAppMod
	EXPORTED: 
	var nSite
	var nUser
	method open
	method genZeroState
	method genPeriod
	method import
	method autoImport
	method startSynchro
	method menuAdmin
	method importInteractive
	
END CLASS
#endif


/*! \fn *bool TSqlLog::open()
 *  \brief Otvara - kreira Sql log
 */

*bool TSqlLog::open()
*{
method open()
local cPom
local cLogF


cPom:=ToUnix(KUMPATH+SLASH+"SQL")
DirMak2(cPom)

cLogF:=cPom+SLASH+replicate("0",8)

OKreSQLPar(cPom)

public gSqlSite:=field->_SITE_
public gSqlUser:=1

::nSite:=gSqlSite
::nUser:=gSqlUser

goModul:cSqlLogBase:=gSqlLogBase
use

altd()

Gw("SET SITE "+Str(::nSite))
Gw("SET TODATABASE OFF")
Gw("SET MODUL "+gModul)

::autoImport()

return .t.
*}

/*! \fn *bool TSqlLog::import(integer nSite)
 *  \brief importuje log "nSite".log u Db
 */

*bool TSqlLog::import(integer nSite)
*{
method import(nSite)

//Box(,2,60)
//@ m_x+1,m_y+2 SAY "Vrsim importovanje podataka"

Gw("SET TABLE_DIRSIF  "+cTblSif)
Gw("SET TABLE_DIRKUM  "+cTblKum)
Gw("SET TABLE_DIRPRIV "+cTblPriv)

Gw("SET DIRKUM "+KUMPATH)
Gw("SET DIRSIF "+SIFPATH)
Gw("SET DIRPRIV "+PRIVPATH)
GW_STATUS:="EXE_GET_SQLLOG"
cRezultat:=Gw("GET SQLLOG "+alltrim(str(nSite)))

if ("Fajl" $ cRezultat .and.  "ne postoji" $ cRezultat)
	if gAppSrv
       		? cRezultat
   	else
       		MsgBeep(cRezultat)
   	endif
else
 	nBroji2:=SECONDS()
 	do while .t.
   		cTmp:=GwStaMai(@nBroji2)
   		if (GW_STATUS != "NA_CEKI_K_SQL")
      			exit
   		endif
 	enddo
endif

GW_STATUS="-"
//Boxc()

goModul:oDatabase:scan()

return .t.
*}

/*! \fn *void TSqlLog::importInteractive()
 *  \brief Interaktivni import - trazi od korisnika unos Site-a koji se importuje
 */

*void TSqlLog::importInteractive()
*{
method importInteractive()
local nSite

nSite:=99

Box(,3,60)
@ m_x+1, m_y+2 SAY "Oznaka site-a koji se importuje:" GET nSite PICT "99"
READ
BoxC()

if LASTKEY()==K_ESC
	return
endif
::import(nSite)

return .t.
*}


/*! \fn *void TSqlLog::genZeroState()
 *  \brief Generise log pocetnog - trenutnog stanja Db-a
 */

*void TSqlLog::genZeroState()
*{
method genZeroState()
local nStartSec

if !SigmaSif("SQLPS")
	MsgBeep("Neispravna sifra ...")
  	return
endif

GW_STATUS="GEN_SQL_LOG"

if Pitanje(,"SQL pocetno stanje ?","N")=="N"
	return
endif

Box(,3,60)
@ m_x+1,m_y+2 SAY "Formiram sql log ..."
nStartSec:=SECONDS()
Gw("SET POCSTANJE ON")

// ove tabele se nalaze u direktoriju sifrarnika
Gw("SET TABLE_DIRSIF "+cTblSif)
Gw("SET TABLE_DIRKUM "+cTblKum)

Gw("ZAP KONTO")
Gw("ZAP PARTN")
Gw("ZAP SIFK")
Gw("ZAP SIFV")
Gw("ZAP TDOK")
Gw("ZAP TNAL")
Gw("ZAP VALUTE")
//Gw("ZAP RJ")
Gw("ZAP ANAL")
Gw("ZAP SINT")
Gw("ZAP SUBAN")
Gw("ZAP NALOG")

O_KONTO
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("KONTO")

O_SIFK
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("SIFK")

O_SIFV
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("SIFV")

O_TNAL
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("TNAL")

O_TDOK
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("TDOK")

//O_RJ
//@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
//Log_Tabela("RJ")

O_PARTN
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("PARTN")

O_VALUTE
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("VALUTE")


O_SUBAN
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("SUBAN")

O_ANAL
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("ANAL")

O_SINT
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("SINT")

O_NALOG
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("NALOG")

O_RJ
@ m_x+2,m_y+2 SAY "Logiram tabelu RJ  "+padr(ALIAS(),15)
Log_Tabela("RJ")

close all

GW_STATUS="-"
BoxC()


#ifdef PROBA
	MsgBeep("Trajanje operacije:"+ALLTRIM(STR(SECONDS()-nStartSec)))
#endif


return nil
*}


/*! \fn *void TSqlLog::genPeriod(dDatOd, dDatDo)
 *  \brief Generise log za datumski period
 */

*void TSqlLog::genPeriod(dDatOd, dDatDo)
*{
method genPeriod(dDatOd, dDatDo)

return nil
*}


/*! \fn *void TSqlLog::menuAdmin()
 *  \brief Meni za administraciju Sql logova
 */

*void TSqlLog::menuAdmin()
*{
method menuAdmin()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. aktiviraj synchronihaciju client<->server")
AADD(opcexe,{|| ::startSynchro() })

AADD(opc,"2. generacija log-a pocetnog stanja db-a")
AADD(opcexe,{|| ::genZeroState() })
AADD(opc,"3. generacija log-a za period")
AADD(opcexe,{|| ::genPeriod()})
AADD(opc,"4. sql ucitaj log")
AADD(opcexe,{|| ::importInteractive() })

Menu_SC("msql")
return .f.
*}


*string FmkIni_ExePath_Gateway_AutoImportSql;

/*! *string FmkIni_ExePath_Gateway_AutoImportSql;
 *
 *
 */
 
/*! \fn *void TSqlLog::autoImport()
 *  \brief Vrsi automatsko importovanje log-a na osnovu ini parametra Gateway/AutoImportSQL
 *  \sa FmkIni_ExePath_Gateway_AutoImportSql
 */

*void TSqlLog::autoImport()
*{
method autoImport()
local i
local cPomIni
local cLog

if goModul:oDatabase:lAdmin
	return 0
endif

cPomIni:=IzFmkIni("Gateway","AutoImportSql_"+ALLTRIM(str(::nSite)),"-",EXEPATH)

cLog:=""
for i:=1 to INT(LEN(cPomIni)/3)
	cLog:=SUBSTR(cPomIni,(i-1)*3+1 ,2)
    	::import(VAL(cLog))
next

return 1
*}


/*! \fn *bool TSqlLog::startSynchro()
 *  \brief Trazim od servera da izvrsi proces sinhronizacije za moj <Site>
 *  Clipper -> lokalnom Gateway-u -> TCP/IP -> remote Gateway-u; Kada remote gateway dobije ovaj poziv on pokrece sql_synchro.py <Site>
 */

*bool TSqlLog::startSynchro()
*{
method startSynchro()


Gw("RECI_SERVERU_JA_SAM_ON_LINE "+Str(::nSite))

return .t.
*}

