#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/gvars.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.8 $
 * $Log: gvars.prg,v $
 * Revision 1.8  2004/01/13 19:07:59  sasavranic
 * appsrv konverzija
 *
 * Revision 1.7  2003/10/06 15:00:04  sasavranic
 * no message
 *
 * Revision 1.6  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.5  2003/05/10 15:12:12  mirsad
 * uvedeno i parametrizirano automatsko preuzimanje sifre robe u barkod kada nije definisan
 *
 * Revision 1.4  2003/02/28 07:25:45  mirsad
 * ispravke
 *
 * Revision 1.3  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */



/*! \ingroup ini
  * \var *string FmkIni_ExePath_ROBA_BezIstihNaziva
  * \brief Da li ce se zabraniti unos istog naziva robe pod razlicitom sifrom?
  * \param N - ne, default vrijednost
  * \param D - onemogucava unos istog naziva pod drugom sifrom robe
  */
*string FmkIni_ExePath_ROBA_BezIstihNaziva;



function SetFmkRGVars()
*{
public gUVarPP
public glProvNazRobe
public gRobaBlock
public gPicCDem
public PicDem

public gPicCDEM
public gPicProc
public gPicDEM
public gPickol

public glAutoFillBK
public gDuzSifIni

public glPoreziLegacy
public glUgost
public gUgostVarijanta

// R - Obracun porez na RUC
// D - starija varijanta ???
// N - obicno robno knjigovodstvo


glPoreziLegacy:=(IzFmkIni("POREZI","Legacy","D", EXEPATH) == "D")


glUgost:=(IzFmkIni("UGOSTITELJSTVO","Obracun","N", KUMPATH) == "D")

//RMarza_DLimit - osnovica realizovana marza ili donji limit
//MpcSaPor - Maloprodajna cijena sa porezom
gUgostVarijanta:=UPPER(IzFmkIni("UGOSTITELJSTVO","Varijanta","Rmarza_DLimit", KUMPATH))

gUVarPP:=IzFMKINI("POREZI","PPUgostKaoPPU","N", KUMPATH)

glProvNazRobe:=(IzFmkIni("ROBA","BezIstihNaziva","N")=="D")

glAutoFillBK:=(IzFmkIni("ROBA","AutoFillBarKod","N",SIFPATH)=="D")

gRobaBlock:=nil

gPicCDEM:="999999.999"
gPicProc:="999999.99%"
gPicDEM:= "9999999.99"
gPickol:= "999999.999"

gDuzSifINI:=IzFmkIni('Sifroba','DuzSifra','10',SIFPATH)
return
*}
