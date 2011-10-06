/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"


/*! \fn CreInt1DB()
 *  \brief Kreiranje tabela dinteg1 i integ1
 */
function CreDIntDB()
*{
ChkDTbl()

// kreiraj tabelu errors
cre_errors()

// provjeri da li postoji tabela DINTEG1
if !FILE(ToUnix(KUMPATH + "DINTEG1.DBF")) .or. !FILE(ToUnix(KUMPATH + "DINTEG2.DBF"))
	// kreiraj tabelu DINTEG1/2
	
	// definicija tabele DINTEG1/2
	aDbf := {}
	AADD(aDbf, {"ID", "N", 20, 0})
	AADD(aDbf, {"DATUM", "D", 8, 0})
	AADD(aDbf, {"VRIJEME", "C", 8, 0 })
	AADD(aDbf, {"CHKDAT", "D", 8, 0 })
	AADD(aDbf, {"CHKOK", "C", 1, 0 })
	AADD(aDbf, {"CSUM1", "N", 20, 5 })
	AADD(aDbf, {"CSUM2", "N", 20, 5 })
	AADD(aDbf, {"CSUM3", "N", 20, 0 })
	// + spec.OID polja
	if gSql=="D"
		AddOidFields(@aDbf)
	endif   
	// kreiraj tabelu DINTEG1/2
	if !file(ToUnix(KUMPATH + "DINTEG1.DBF"))
		DBcreate2(KUMPATH+"DINTEG1.DBF", aDbf)
	endif
	if !file(ToUnix(KUMPATH + "DINTEG2.DBF"))
		DBcreate2(KUMPATH+"DINTEG2.DBF", aDbf)
	endif
endif

// provjeri da li postoji tabela INTEG1
if !file(ToUnix(KUMPATH + "INTEG1.DBF"))
	// kreiraj tabelu INTEG1

	// definicija tabele
	aDbf := {}
	AADD(aDbf, {"ID", "N", 20, 0})
	AADD(aDbf, {"IDROBA", "C", 10, 0})
	AADD(aDbf, {"OIDROBA", "N", 12, 0})
	AADD(aDbf, {"IDTARIFA", "C", 6, 0})
	AADD(aDbf, {"STANJEK", "N", 20, 5})
	AADD(aDbf, {"STANJEF", "N", 20, 5})
	AADD(aDbf, {"KARTCNT", "N", 6, 0})
	AADD(aDbf, {"SIFROBACNT", "N", 15, 0})
	AADD(aDbf, {"ROBACIJENA", "N", 15, 5})
	AADD(aDbf, {"KALKKARTCNT", "N", 6, 0})
	AADD(aDbf, {"KALKKSTANJE", "N", 20, 5})
	AADD(aDbf, {"KALKFSTANJE", "N", 20, 5})
	AADD(aDbf, {"N1", "N", 12, 0})
	AADD(aDbf, {"N2", "N", 12, 0})
	AADD(aDbf, {"N3", "N", 12, 0})
	AADD(aDbf, {"C1", "C", 20, 0})
	AADD(aDbf, {"C2", "C", 20, 0})
	AADD(aDbf, {"C3", "C", 20, 0})
	AADD(aDbf, {"DAT1", "D", 8, 0})
	AADD(aDbf, {"DAT2", "D", 8, 0})
	AADD(aDbf, {"DAT3", "D", 8, 0})
	// + spec.OID polja
	if gSql=="D"
		AddOidFields(@aDbf)
	endif   
	// kreiraj tabelu INTEG1
	DBcreate2(KUMPATH+"INTEG1.DBF", aDbf)
endif

// provjeri da li postoji tabela INTEG2
if !file(ToUnix(KUMPATH + "INTEG2.DBF"))
	// kreiraj tabelu INTEG2

	// definicija tabele
	aDbf := {}
	AADD(aDbf, {"ID", "N", 20, 0})
	AADD(aDbf, {"IDROBA", "C", 10, 0})
	AADD(aDbf, {"OIDROBA", "N", 12, 0})
	AADD(aDbf, {"IDTARIFA", "C", 6, 0})
	AADD(aDbf, {"STANJEF", "N", 20, 5})
	AADD(aDbf, {"STANJEK", "N", 20, 5})
	AADD(aDbf, {"SIFROBACNT", "N", 15, 0})
	AADD(aDbf, {"ROBACIJENA", "N", 15, 5})
	AADD(aDbf, {"N1", "N", 12, 0})
	AADD(aDbf, {"N2", "N", 12, 0})
	AADD(aDbf, {"N3", "N", 12, 0})
	AADD(aDbf, {"C1", "C", 20, 0})
	AADD(aDbf, {"C2", "C", 20, 0})
	AADD(aDbf, {"C3", "C", 20, 0})
	AADD(aDbf, {"DAT1", "D", 8, 0})
	AADD(aDbf, {"DAT2", "D", 8, 0})
	AADD(aDbf, {"DAT3", "D", 8, 0})
	// + spec.OID polja
	if gSql=="D"
		AddOidFields(@aDbf)
	endif   
	// kreiraj tabelu INTEG2
	DBcreate2(KUMPATH+"INTEG2.DBF", aDbf)
endif

// kreiraj index za tabelu DINTEG1/2
CREATE_INDEX ("1", "DTOS(DATUM)+VRIJEME+STR(ID)", KUMPATH+"DINTEG1")
CREATE_INDEX ("2", "ID", KUMPATH+"DINTEG1")
CREATE_INDEX ("1", "DTOS(DATUM)+VRIJEME+STR(ID)", KUMPATH+"DINTEG2")
CREATE_INDEX ("2", "ID", KUMPATH+"DINTEG2")

// kreiraj index za tabelu INTEG1
CREATE_INDEX ("1", "STR(ID)+IDROBA", KUMPATH+"INTEG1")
CREATE_INDEX ("2", "ID", KUMPATH+"INTEG1")

// kreiraj index za tabelu INTEG2
CREATE_INDEX ("1", "STR(ID)+IDROBA", KUMPATH+"INTEG2")
CREATE_INDEX ("2", "ID", KUMPATH+"INTEG2")

// OID indexi
CREATE_INDEX("OID","_oid_",KUMPATH+"DOKS")
CREATE_INDEX("OID","_oid_",KUMPATH+"POS")
CREATE_INDEX("OID","_oid_",SIFPATH+"ROBA")

return
*}


// kreiranje tabele errors
function cre_errors()
// provjeri da li postoji tabela ERRORS.DBF
if !file(ToUnix(PRIVPATH+"ERRORS.DBF"))
	aDbf := {}
	AADD(aDbf, {"TYPE", "C", 10, 0})
	AADD(aDbf, {"IDROBA", "C", 10, 0})
	AADD(aDbf, {"DOKS", "C", 50, 0})
	AADD(aDbf, {"OPIS", "C", 100, 0})
	DBcreate2(PRIVPATH+"ERRORS.DBF", aDbf)
endif

// kreiraj index za tabelu ERRORS
CREATE_INDEX ("1", "IDROBA+TYPE", PRIVPATH+"ERRORS")

return



/*! \fn ChkDTbl()
 *  \brief 
 */
function ChkDTbl()
*{
if FILE(KUMPATH + "INTEG1.DBF")
	O_INTEG1
	// ako nema polja N1 pobrisi tabele i generisi nove tabele
	if integ1->(FieldPos("N1")) == 0
		// trala lalalalall
		use
		FErase(KUMPATH + "\INTEG1.DBF")
		FErase(KUMPATH + "\INTEG1.CDX")
		FErase(KUMPATH + "\INTEG2.DBF")
		FErase(KUMPATH + "\INTEG2.CDX")
		FErase(KUMPATH + "\DINTEG1.DBF")
		FErase(KUMPATH + "\DINTEG1.CDX")
		FErase(KUMPATH + "\DINTEG2.DBF")
		FErase(KUMPATH + "\DINTEG2.CDX")
	endif
endif
return
*}


/*! \fn DInt1NextID()
 *  \brief Vrati sljedeci zapis polja ID za tabelu DINTEG1
 */
function DInt1NextID()
*{
local nArr 
nArr := SELECT()

O_DINTEG1
select dinteg1

nId := NextDIntID()

select (nArr)

return nId
*}


/*! \fn DInt2NextID()
 *  \brief Vrati sljedeci zapis polja ID za tabelu DINTEG2
 */
function DInt2NextID()
*{
local nArr 
nArr := SELECT()

O_DINTEG2
select dinteg2

nId := NextDIntID()

select (nArr)
return nId
*}


/*! \fn NextDIntID()
 *  \brief Vraca sljedeci ID broj za polje ID
 */
function NextDIntID()
*{
nId := 0
set order to tag "2"
go bottom
nId := field->id
nId := nId + 1

return nID
*}




