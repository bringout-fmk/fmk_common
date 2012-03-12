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


#include "sc.ch"


// ------------------------------------------
// prikazi rezultat
// ------------------------------------------
function f18_rezultat( a_ctrl, a_data, a_sif )
local i, d, s

START PRINT CRET
?
P_COND

? "Rezultati testa:", DTOC( DATE() )
? "================================"
?
? "1) Kontrolni podaci:"
? "-------------- --------------- ---------------"
? "objekat        broj zapisa     kontrolni broj"
? "-------------- --------------- ---------------"
// prvo mi ispisi kontrolne zapise
for i := 1 to LEN( a_ctrl )
	? PADR( a_ctrl[ i, 1 ], 14 )
	@ prow(), pcol() + 1 SAY STR( a_ctrl[ i, 2 ], 15, 2 )
	@ prow(), pcol() + 1 SAY STR( a_ctrl[ i, 3 ], 15, 2 )
next

// dupli rbr
if LEN( a_data ) > 0

	? 
	? "2) Dokumenti sa duplim rednim brojem"
	? "----------------------------------------"

	for d := 1 to LEN( a_data )
		? a_data[ d, 1 ]
	next

endif

// duple sifre
if LEN( a_sif ) > 0

	? 
	? "3) Duple sifre"
	? "-------------------------------------------------------------"

	for s := 1 to LEN( a_sif )
		? PADR( a_sif[ s, 1 ], 10 ) + ": " + ;
			PADR( a_sif[ s, 2 ], 10 ) + " - " + ;
			PADR( a_sif[ s, 3 ], 20 )
	next

endif

?
?

FF
END PRINT

return


// -----------------------------------------
// provjera sifrarnika
// -----------------------------------------
function f18_sif_data( data, checksum )

O_ROBA
O_PARTN
O_KONTO
O_TRFP
O_OPS
O_VALUTE
O_KONCIJ

select roba
set order to tag "1"
go top

f18_sif_check( @data, @checksum )

select partn
set order to tag "1"
go top

f18_sif_check( @data, @checksum )

select konto
set order to tag "1"
go top

f18_sif_check( @data, @checksum )

select ops
set order to tag "1"
go top

f18_sif_check( @data, @checksum )


return


// ------------------------------------------
// provjera sifrarnika 
// ------------------------------------------
static function f18_sif_check( data, checksum )
local _chk := "x-x"
local _scan
local _stavke := 0

do while !EOF()
	
	_sif_id := field->id

	if EMPTY( _sif_id )
		skip
		loop
	endif

	if _sif_id == _chk
		// dodaj u matricu
		_scan := ASCAN( data, { |var| var[2] == _sif_id } )
		if _scan == 0
			AADD( data, { ALIAS(), _sif_id, field->naz } ) 
		endif
	else
		++ _stavke
	endif

	_chk := _sif_id

	skip
enddo

if _stavke > 0
	AADD( checksum, { "sif. " + ALIAS(), _stavke, 0 } )
endif

return


 
 

