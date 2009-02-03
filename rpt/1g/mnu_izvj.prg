#include "ld.ch"

// ----------------------------------------------------
// osnovna funkcija za poziv izvjestaja - menij
// ----------------------------------------------------
function MnuIzvj()

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. kartice                               ")
AADD(opcexe,{|| MnuIzvK()})
AADD(opc,"2. rekapitulacije")
AADD(opcexe,{|| MnuIzvR()})
AADD(opc,"3. pregledi")
AADD(opcexe,{|| MnuIzvP()})
AADD(opc,"4. specifikacije")
AADD(opcexe,{|| MnuIzvS()})
if gVarObracun == "2"
	AADD(opc,"4i. specifikacije spec.tipovi rada")
	AADD(opcexe,{|| m_spec_o()})
endif
AADD(opc,"5. ostali izvjestaji")
AADD(opcexe,{|| MnuIzvO()})

if gAHonorar == "D"
	AADD(opc,"A. autorski honorari - izvjestaji")
	AADD(opcexe,{|| mnu_ahon()})
endif

if gVarObracun == "2"
	AADD(opc,"O. obracunski listovi")
	AADD(opcexe,{|| r_obr_list() })
	AADD(opc,"P. akontacije poreza")
	AADD(opcexe,{|| r_ak_list() })
endif

Menu_SC("izvj")

return

// ----------------------------------------
// izvjestaji kartice
// ----------------------------------------
function MnuIzvK()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. kartice plate                      ")
AADD(opcexe,{|| KartPl()})
AADD(opc,"2. kartica plate za period (za m4)")
AADD(opcexe,{|| UKartPl()})

Menu_SC("kart")
return



// -----------------------------------------
// menij - izvjestaji specifikacije 2
// -----------------------------------------
function m_spec_o()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. specifikacija za samostalne poduzetnike     ")
AADD(opcexe,{|| SpecPlS()})
AADD(opc,"2. specifikacija ostale samostalne djelatnosti")
AADD(opcexe,{|| SpecPlU()})

Menu_SC("spec2")

return


// -----------------------------------------
// menij - izvjestaji specifikacije
// -----------------------------------------
function MnuIzvS()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. specifikacija uz isplatu plata                 ")
if gVarObracun == "2"
	AADD(opcexe,{|| SpecPl2()})
else
	AADD(opcexe,{|| Specif()})
endif

AADD(opc,"2. specifikacija po opstinama i RJ")
AADD(opcexe,{|| Specif2()})
AADD(opc,"3. specifikacija po rasponima primanja")
AADD(opcexe,{|| SpecifRasp()})
AADD(opc,"4. specifikacija primanja po mjesecima")
AADD(opcexe,{|| SpecifPoMjes()})
AADD(opc,"5. specif.novcanica potrebnih za isplatu plata")
AADD(opcexe,{|| SpecNovcanica()})
AADD(opc,"6. specif.prosjecnog neta po strucnoj spremi")
AADD(opcexe,{|| Specif3()})
AADD(opc,"7. specifikacija primanja po RJ")
AADD(opcexe,{|| SpecPrimRj()})

Menu_SC("spec")
return

// -------------------------------------
// menij - pregledi
// -------------------------------------
function MnuIzvP()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. pregled plata                                  ")
AADD(opcexe,{|| PregPl()})
AADD(opc,"2. pregled odredjenog primanja")
AADD(opcexe,{|| PregPrim()})
AADD(opc,"3. platni spisak")
AADD(opcexe,{|| PlatSp()})
AADD(opc,"4. platni spisak tekuci racun")
AADD(opcexe,{|| PlatSpTR("1")})
AADD(opc,"5. platni spisak stedna knj  ")
AADD(opcexe,{|| PlatSpTR("2")})
AADD(opc,"6. pregled primanja za period")
AADD(opcexe,{|| PregPrimPer()})
AADD(opc,"7. pregled obracunatih doprinosa")
AADD(opcexe,{|| IzObDop()})
AADD(opc,"8. isplata jednog tipa primanja na tekuci racun")
AADD(opcexe,{|| IsplataTR("1")})


Menu_SC("preg")
return


// --------------------------------------------
// menij ostali izvjestaji
// --------------------------------------------
function MnuIzvO()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. lista radnika sa netom po opst.stanovanja  ")
AADD(opcexe,{|| SpRadOpSt()})

if (IsRamaGlas())
	AADD(opc,"2. pregled plata po radnim nalozima    ")
	AADD(opcexe,{|| PlatePoRNalozima()})
endif

AADD(opc,"T. lista radnika za isplatu toplog obroka")
AADD(opcexe,{|| to_list()})

Menu_SC("ost")
return


// --------------------------------------------
// menij izvjestaji autorski honorari
// --------------------------------------------
function mnu_ahon()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. autorski honorari - lista               ")
AADD(opcexe,{|| ah_list_rpt()})
AADD(opc,"2. autorski honorari - specifikacija")
AADD(opcexe,{|| ah_spec_rpt()})

Menu_SC("a_honorari")

return


function MnuIzvR()
*{

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. rekapitulacija                         ")
if gVarObracun == "2"
	AADD(opcexe,{|| Rekap2(.f.)})
else
	AADD(opcexe,{|| Rekap(.f.)})
endif
AADD(opc,"2. rekapitulacija za sve rj")
if gVarObracun == "2"
	AADD(opcexe,{|| Rekap2(.t.)})
else
	AADD(opcexe,{|| Rekap(.t.)})
endif
AADD(opc,"3. rekapitulacija po koeficijentima")
AADD(opcexe,{|| RekapBod()})
AADD(opc,"4. rekapitulacija neto primanja")
AADD(opcexe,{|| RekNeto()})
AADD(opc,"5. rekapitulacija tekucih racuna")
AADD(opcexe,{|| RekTekRac()})

Menu_SC("rekap")
return
*}



