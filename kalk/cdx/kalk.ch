
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/cdx/kalk.ch,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: kalk.ch,v $
 * Revision 1.5  2002/11/22 10:41:54  mirsad
 * sredjivanje makroa za oblasti - ukidanje starog sistema
 *
 * Revision 1.4  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.3  2002/07/06 12:29:01  ernad
 *
 *
 * kalk, planika GenRekap1, GenRekap2
 *
 * Revision 1.2  2002/06/16 14:20:24  ernad
 *
 *
 * header
 *
 *
 */
 
//FIN
#xcommand FO_PRIPR   => select (F_FIPRIPR);   usex (SezRad(gDirFin)+"PRIPR") ; set order to 1
#xcommand FO_SUBAN   => select (F_SUBAN);  use  (SezRad(gDirFik)+"SUBAN")   ; set order to 1
#xcommand FO_ANAL    => select (F_ANAL);  use  (SezRad(gDirFik)+"ANAL")     ; set order to 1
#xcommand FO_SINT    => select (F_SINT);  use  (SezRad(gDirFik)+"SINT")     ; set order to 1
#xcommand FO_BBKLAS  => select (F_BBKLAS);  usex (SezRad(gDirFin)+"BBKLAS") ; set order to 1
#xcommand FO_IOS     => select (F_IOS);  usex (SezRad(gDirFin)+"IOS")       ; set order to 1
#xcommand FO_NALOG   => select (F_NALOG);  use  (SezRad(gDirFik)+"NALOG")   ; set order to 1
#xcommand FO_PNALOG  => select (F_PNALOG); usex (SezRad(gDirFin)+"PNALOG")  ; set order to 1
#xcommand FO_PSUBAN  => select (F_PSUBAN); usex (SezRad(gDirFin)+"PSUBAN")  ; set order to 1
#xcommand FO_PANAL   => select (F_PANAL); usex (SezRad(gDirFin)+"PANAL")    ; set order to 1
#xcommand FO_PSINT   => select (F_PSINT); usex (SezRad(gDirFin)+"PSINT")    ; set order to 1
#xcommand FO_PKONTO  => select (F_PKONTO); use  (SIFPATH+"pkonto") ; set order to tag "ID"

//FAKT
#xcommand XO_PRIPR   => select (F_FAPRIPR);   usex (SezRad(gDirFakt)+"PRIPR") alias xpripr; set order to 1
#xcommand XO_FAKT    => select (F_FAKT);  use  (SezRad(gDirFakK)+"FAKT")  alias xfakt; set order to 1
#xcommand XO_DOKS    => select(F_FADOKS);  use  (SezRad(gDirFakK)+"DOKS") alias xdoks; set order to 1
#xcommand XO_PARAMS    => select (F_POM); use (SezRad(gDirFakt)+"params"); set order to 1
#xcommand XO_POR       => select (F_POR); usex (SezRad(gDirFakt)+"por")

#xcommand O_K1 => select (F_K1); use  (KUMPATH+"k1") ; set order to tag "ID"
#xcommand O_OBJEKTI => select (F_OBJEKTI); use  (KUMPATH+"objekti") ; set order to tag "ID"

#xcommand O_POBJEKTI => select (F_POBJEKTI); use  (PRIVPATH+"pobjekti") ; set order to tag "ID"

#xcommand O_REKAP1 => select (F_REKAP1); usex (PRIVPATH+"rekap1") ; set order to tag "1"

#xcommand O_REKAP2 => select (F_REKAP2); usex (PRIVPATH+"rekap2") ; set order to tag "2"

#xcommand O_REKA22 => select (F_REKA22); usex (PRIVPATH+"reka22") ; set order to tag "1"


#xcommand O_RPT_TMP => select (F_RPT_TMP); usex (PRIVPATH+"rpt_tmp")


