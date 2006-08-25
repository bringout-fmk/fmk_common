#include "sc.ch"


// menij grupacija 
function roba_grupe()
private opc:={}
private opcexe:={}
private izbor:=1

AADD(opc, "1. grupe                         ")
AADD(opcexe, {|| p_grupe() })
AADD(opc, "2. dodatne karakteristike grupa  ")
AADD(opcexe, {|| p_gr_dinfo() })
AADD(opc, "3. grupe - parovi  ")
AADD(opcexe, {|| p_gr_parovi() })


Menu_SC("grp")

return


// otvaranje sifrarnika grupa
function p_grupe(cId, dx, dy)
local nTArea := SELECT()
private ImeKol
private Kol

ImeKol := {}
Kol := {}

O_GRUPE

AADD(ImeKol, {padc("ID", 5), {|| id }, "id", {|| inc_cid(@wid, "GRUPE"), .f.}, {|| vpsifra(wId)} })
AADD(ImeKol, {padc("Naziv", 20), {|| LEFT(naz, 20)}, "naz", {|| .t.}, {|| .t.} })
AADD(ImeKol, {padc("Aktivna", 10), {|| gr_aktiv}, "gr_aktiv", {|| .t.}, {|| .t.} })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_GRUPE, "ID", 10, 65, "Lista grupa artikala", @cId, dx, dy, {|Ch| grupe_handler(Ch)})


// key handler grupe...
static function grupe_handler(Ch)

do case
	case Ch == K_CTRL_T .or. Ch == K_CTRL_F9
		MsgBeep("Opcija zabranjena!")
		return DE_CONT
endcase

return DE_CONT



// otvaranje sifrarnika grupa - dodatnih informacija
function p_gr_dinfo(cId, dx, dy)
local nTArea := SELECT()
private ImeKol
private Kol

ImeKol := {}
Kol := {}

O_GR_DINFO

AADD(ImeKol, {padc("ID", 5), {|| id }, "id", {|| inc_cid(@wId,"GR_D_INFO"),.f.}, {|| vpsifra(wId)} })
AADD(ImeKol, {padc("Naziv", 30), {|| LEFT(naz, 30)}, "naz", {|| .t.}, {|| .t.} })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_GR_DINFO, "ID", 10, 65, "Grupe dodatne informacije", @cId, dx, dy, {|Ch| grdinfo_handler(Ch)})


// key handler
static function grdinfo_handler(Ch)
return DE_CONT


// otvaranje sifrarnika grupa - parova
function p_gr_parovi(cId, dx, dy)
local nTArea := SELECT()
private ImeKol
private Kol

ImeKol := {}
Kol := {}

O_GR_PAR

AADD(ImeKol, {padc("ID", 10), {|| id }, "id", {|| inc_nid(@wId, "GR_PAR"), .f.}, {|| .t.} })

AADD(ImeKol, {padc("GRUPA", 10), {|| id_gr}, "id_gr", {|| .t.}, {|| x:=p_grupe(@wid_gr), ispisi_naz(x, m_y+35, ocitaj(F_GRUPE, id_gr, "naz_grupa()")) } })

AADD(ImeKol, {padc("DOD.INFO", 12), {|| id_gr_dinfo}, "id_gr_dinfo", {|| .t.}, {|| xx:=p_gr_dinfo(@wid_gr_dinfo), ispisi_naz(xx, m_y+35, ocitaj(F_GR_DINFO, id_gr_dinfo, "naz_gr_dinfo()"))  } })

AADD(ImeKol, {padc("K1", 10), {|| k1 }, "k1", {|| .t.}, {|| .t.} })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_GR_PAR, "1", 10, 65, "Grupe parovi", @cId, dx, dy, {|Ch| grpar_handler(Ch)})


// uvecaj ID (C)
static function inc_cid(wId, cTable)
local lRet:=.t.
if ((Ch==K_CTRL_N) .or. (Ch==K_F4))
	if (LastKey()==K_ESC)
		return lRet:=.f.
	endif
	nRecNo:=RecNo()
	gr_new_cid(@wId, cTable)
	AEVAL(GetList,{|o| o:display()})
endif
return lRet


// uvecaj ID (N)
static function inc_nid(wId, cTable)
local lRet:=.t.
if ((Ch==K_CTRL_N) .or. (Ch==K_F4))
	if (LastKey()==K_ESC)
		return lRet:=.f.
	endif
	nRecNo:=RecNo()
	gr_new_nid(@wId, cTable)
	AEVAL(GetList,{|o| o:display()})
endif
return lRet


// key handler
static function grpar_handler(Ch)
return DE_CONT


function naz_grupa()
return TRIM(field->naz)


function naz_gr_dinfo()
return TRIM(field->naz)


function ispisi_naz(x, y, c)
@ x,y SAY c
return .t.

