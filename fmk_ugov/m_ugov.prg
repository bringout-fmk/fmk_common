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


// --------------------------------------
// meni sifrarnik ugovora
// --------------------------------------
function SifUgovori()
private Opc:={}
private opcexe:={}

AADD(Opc, "1. ugovori                                    ")
AADD(opcexe, {|| P_Ugov() })
AADD(Opc, "2. parametri ugovora")
AADD(opcexe, {|| DFTParUg(.f.) })
AADD(Opc, "3. grupna zamjena cijene artikla u ugovoru")
AADD(opcexe, {|| ug_ch_price() })
private Izbor:=1

Menu_SC("mugo")
CLOSERET
return





