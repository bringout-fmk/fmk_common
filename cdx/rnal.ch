#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_RN_VERZIJA "02.92"
#define D_RN_PERIOD "06.06-01.12.09"

#ifndef FMK_DEFINED
	#include "fmk.ch"
#endif

// komande za otvaranje tabela


// -------------------------------------
// PRIVPATH
// -------------------------------------

#xcommand O__DOCS => select (F__DOCS); usex (PRIVPATH + "_DOCS"); set order to tag "1"
#xcommand O__DOC_IT => select (F__DOC_IT); usex (PRIVPATH + "_DOC_IT"); set order to tag "1"
#xcommand O__DOC_IT2 => select (F__DOC_IT2); usex (PRIVPATH + "_DOC_IT2"); set order to tag "1"
#xcommand O__DOC_OPS => select (F__DOC_OPS); usex (PRIVPATH + "_DOC_OPS"); set order to tag "1"
#xcommand O__FND_PAR => select (F__FND_PAR); usex (PRIVPATH + "_FND_PAR"); set order to tag "1"
#xcommand O_T_DOCIT => select (F_T_DOCIT); usex (PRIVPATH + "T_DOCIT"); set order to tag "1"
#xcommand O_T_DOCIT2 => select (F_T_DOCIT2); usex (PRIVPATH + "T_DOCIT2"); set order to tag "1"
#xcommand O_T_DOCOP => select (F_T_DOCOP); usex (PRIVPATH + "T_DOCOP"); set order to tag "1"
#xcommand O_T_PARS => select (F_T_PARS); usex (PRIVPATH + "T_PARS"); set order to tag "id_par"
#xcommand O__TMP1 => select (F__TMP1); usex (PRIVPATH + "_TMP1"); set order to tag "1"
#xcommand O__TMP2 => select (F__TMP2); usex (PRIVPATH + "_TMP2"); set order to tag "1"


// -----------------------------------
// KUMPATH
// -----------------------------------

#xcommand O_DOCS => select (F_DOCS); use (KUMPATH + "DOCS"); set order to tag "1"
#xcommand O_DOC_IT => select (F_DOC_IT); use (KUMPATH + "DOC_IT"); set order to tag "1"
#xcommand O_DOC_IT2 => select (F_DOC_IT2); use (KUMPATH + "DOC_IT2"); set order to tag "1"
#xcommand O_DOC_OPS => select (F_DOC_OPS); use (KUMPATH + "DOC_OPS"); set order to tag "1"
#xcommand O_DOC_LOG => select (F_DOC_LOG); use (KUMPATH + "DOC_LOG"); set order to tag "1"
#xcommand O_DOC_LIT => select (F_DOC_LIT); use (KUMPATH + "DOC_LIT"); set order to tag "1"


// -------------------------------------
// SIFPATH
// -------------------------------------

#xcommand O_E_GROUPS => select(F_E_GROUPS); use (SIFPATH + "E_GROUPS"); set order to tag "1"
#xcommand O_CUSTOMS => select(F_CUSTOMS); use (SIFPATH + "CUSTOMS"); set order to tag "1"
#xcommand O_OBJECTS => select(F_OBJECTS); use (SIFPATH + "OBJECTS"); set order to tag "1"
#xcommand O_CONTACTS => select(F_CONTACTS); use (SIFPATH + "CONTACTS"); set order to tag "1"
#xcommand O_E_GR_ATT => select(F_E_GR_ATT); use (SIFPATH + "E_GR_ATT"); set order to tag "1"
#xcommand O_E_GR_VAL => select(F_E_GR_VAL); use (SIFPATH+"E_GR_VAL"); set order to tag "1"
#xcommand O_AOPS => select(F_AOPS); use (SIFPATH + "AOPS"); set order to tag "1"
#xcommand O_AOPS_ATT => select(F_AOPS_ATT); use (SIFPATH + "AOPS_ATT"); set order to tag "1"
#xcommand O_ARTICLES => select(F_ARTICLES); use (SIFPATH + "ARTICLES"); set order to tag "1"
#xcommand O_ELEMENTS => select(F_ELEMENTS); use (SIFPATH + "ELEMENTS"); set order to tag "1"
#xcommand O_E_AOPS => select(F_E_AOPS); use (SIFPATH + "E_AOPS"); set order to tag "1"
#xcommand O_E_ATT => select(F_E_ATT); use (SIFPATH + "E_ATT"); set order to tag "1"
#xcommand O_RAL => select(F_RAL); use (SIFPATH + "RAL"); set order to tag "1"



