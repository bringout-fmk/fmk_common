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


// ---------------------------------------------------------
// fiskalni izvjestaji i komande
// ---------------------------------------------------------
function fisc_rpt()
local nDevice := 0
private izbor := 1
private opc := {}
private opcexe := {}

// ako se koristi lista uredjaja izaberi uredjaj
if gFc_dlist == "D"

	// listaj mi uredjaje koje imam
	nDevice := list_device()

	if nDevice > 0
		// setuj parametre za dati uredjaj
		fdev_params( nDevice )
	endif

endif


do case 

  case ALLTRIM( gFc_type ) == "FLINK"

    AADD(opc,"------ izvjestaji ---------------------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"1. dnevni izvjestaj  (Z-rep / X-rep)          ")
    AADD(opcexe,{|| fl_daily( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    	nDevice ) })
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"5. unos pologa u uredjaj       ")
    AADD(opcexe,{|| fl_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"6. ponisti otvoren racun      ")
    AADD(opcexe,{|| fl_reset( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })

  // za FPRINT uredjaje (NSC)
  case ALLTRIM(gFc_type) == "FPRINT"

    AADD(opc,"------ izvjestaji ---------------------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"1. dnevni izvjestaj  (Z-rep / X-rep)          ")
    AADD(opcexe,{|| fp_daily_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    	nDevice ) })
    AADD(opc,"2. periodicni izvjestaj")
    AADD(opcexe,{|| fp_per_rpt( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    AADD(opc,"3. pregled artikala ")
    AADD(opcexe,{|| fp_sold_plu( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
   
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"5. unos pologa u uredjaj       ")
    AADD(opcexe,{|| fp_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"6. stampanje duplikata       ")
    AADD(opcexe,{|| fp_double( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"7. zatvori racun (cmd 56)       ")
    AADD(opcexe,{|| fp_close( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"8. zatvori nasilno racun (cmd 301) ")
    AADD(opcexe,{|| fp_void( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    AADD(opc,"9. proizvoljna komanda ")
    AADD(opcexe,{|| fp_man_cmd( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    
    if gFC_device == "P"
    	AADD(opc,"10. brisanje artikala iz uredjaja (cmd 107)")
    	AADD(opcexe,{|| ;
		fp_del_plu( ALLTRIM(gFc_path), ALLTRIM(gFc_name), .f., ;
			nDevice ) })
    endif

    AADD(opc,"11. reset PLU ")
    AADD(opcexe,{|| auto_plu( .t., nil, nDevice ) })
    AADD(opc,"12. non-fiscal racun - test")
    AADD(opcexe,{|| fp_nf_txt( ALLTRIM(gFc_path), ALLTRIM(gFc_name), ;
    			"TEST") })
    AADD(opc,"13. test fisc. email")
    AADD(opcexe,{|| _fisc_eml_test() })


  // za HCP uredjaje
  case ALLTRIM(gFc_type) == "HCP" 
    
    AADD(opc,"------ izvjestaji -----------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"1. dnevni fiskalni izvjestaj (Z rep.)    ")
    AADD(opcexe,{|| hcp_z_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"2. presjek stanja (X rep.)    ")
    AADD(opcexe,{|| hcp_x_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    
    AADD(opc,"3. periodicni izvjestaj (Z rep.)    ")
    AADD(opcexe,{|| hcp_s_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })

    
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    
    AADD(opc,"5. kopija racuna    ")
    AADD(opcexe,{|| hcp_rn_copy( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"6. polog u uredjaj    ")
    AADD(opcexe,{|| hcp_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"7. posalji cmd.ok    ")
    AADD(opcexe,{|| hcp_s_cmd( ALLTRIM(gFC_path) ) })
    
    AADD(opc,"8. izbaci stanje racuna    ")
    AADD(opcexe,{|| hcp_fisc_no( ALLTRIM(gFC_path), ;
    				ALLTRIM(gFC_name), ;
    				gFC_error, .f. ) , ;
			hcp_fisc_no( ALLTRIM(gFc_path), ;
				ALLTRIM(gFC_name), ;
				gFc_error, .t. ) })

    AADD(opc,"11. reset PLU ")
    AADD(opcexe,{|| auto_plu( .t., nil, nDevice ) })


    // za TREMOL uredjaje
  case ALLTRIM(gFc_type) == "TREMOL" 
    
    AADD(opc,"------ izvjestaji -----------------------")
    AADD(opcexe,{|| .f. })
    
    AADD(opc,"1. dnevni fiskalni izvjestaj (Z rep.)    ")
    AADD(opcexe,{|| trm_z_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    
    AADD(opc,"2. izvjestaj po artiklima (Z rep.)    ")
    AADD(opcexe,{|| trm_z_item( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
   
    AADD(opc,"3. presjek stanja (X rep.)    ")
    AADD(opcexe,{|| trm_x_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
 
    AADD(opc,"4. izvjestaj po artiklima (X rep.)    ")
    AADD(opcexe,{|| trm_x_item( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    
    AADD(opc,"5. periodicni izvjestaj (Z rep.)    ")
    AADD(opcexe,{|| trm_p_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
   
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })

    AADD(opc,"K. kopija racuna    ")
    AADD(opcexe,{|| trm_rn_copy( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"R. reset artikala    ")
    AADD(opcexe,{|| fc_trm_rplu( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"P. polog u uredjaj    ")
    AADD(opcexe,{|| trm_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    
    AADD(opc,"11. reset PLU ")
    AADD(opcexe,{|| auto_plu( .t., nil, nDevice ) })

  case ALLTRIM(gFc_type) == "TRING" 
    
    AADD(opc,"------ izvjestaji ---------------------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"1. dnevni izvjestaj                               ")
    AADD(opcexe,{|| trg_daily_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"2. periodicni izvjestaj")
    AADD(opcexe,{|| trg_per_rpt( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    AADD(opc,"3. presjek stanja")
    AADD(opcexe,{|| trg_x_rpt( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })

    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"5. unos pologa u uredjaj       ")
    AADD(opcexe,{|| trg_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"6. stampanje duplikata       ")
    AADD(opcexe,{|| trg_double( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"7. zatvori (ponisti) racun ")
    AADD(opcexe,{|| trg_close_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    AADD(opc,"8. inicijalizacija ")
    AADD(opcexe,{|| trg_init( ALLTRIM(gFc_path), ALLTRIM(gFc_name), ;
    	"1", "" ) })
    AADD(opc,"10. reset zahtjeva na PU serveru ")
    AADD(opcexe,{|| trg_reset( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    
    AADD(opc,"11. reset PLU ")
    AADD(opcexe,{|| auto_plu( .t., nil, nDevice ) })


  // ostali uredjaji
  otherwise
   
   AADD(opc," ---- nema dostupnih opcija ------ ")
   AADD(opcexe,{|| .f. })

endcase

Menu_SC("izvf")

return



// kopija fiskalnog racuna
function fisc_rn_kopija()

do case 

  case ALLTRIM(gFc_type) == "FPRINT"
      fp_double( ALLTRIM(gFC_path), ALLTRIM(gFC_name) )
  case ALLTRIM(gFc_type) == "HCP"
      hcp_rn_copy( ALLTRIM(gFC_path), ALLTRIM(gFC_name), gFc_error )

endcase

return


