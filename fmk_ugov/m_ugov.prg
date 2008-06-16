#include "sc.ch"


// --------------------------------------
// meni sifrarnik ugovora
// --------------------------------------
function SifUgovori()
private Opc:={}
private opcexe:={}

AADD(Opc, "1. ugovori                      ")
AADD(opcexe, {|| P_Ugov() })
AADD(Opc, "2. parametri ugovora")
AADD(opcexe, {|| DFTParUg(.f.) })
private Izbor:=1

Menu_SC("mugo")
CLOSERET
return





