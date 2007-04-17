#include "sc.ch"


// ----------------------------------
// kreiranje tabela "rules"
// ----------------------------------
function cre_fmkrules()
local aDBF
local cTbl := "FMKRULES.DBF"

// uzmi def.polja
aDbf := g_rule_tbl()

if !FILE( SIFPATH + cTbl )
	DBCREATE2( SIFPATH + cTbl, aDbf )
endif

CREATE_INDEX( "1", "STR(RULE_ID,10)", ; 
	SIFPATH + cTbl, .t. )

CREATE_INDEX( "2", "MODUL_NAME+RULE_OBJ+STR(RULE_NO,10)", ; 
	SIFPATH + cTbl, .t. )

CREATE_INDEX( "3", "MODUL_NAME+RULE_OBJ+STR(RULE_LEVEL,2)+STR(RULE_NO,10)", ; 
	SIFPATH + cTbl, .t. )

CREATE_INDEX( "4", "MODUL_NAME+RULE_OBJ+RULE_C1+RULE_C2", ; 
	SIFPATH + cTbl, .t. )

return


// -----------------------------------
// vraca polja tabele RULES
// -----------------------------------
static function g_rule_tbl()
local aDBF := {}

// RULE_ID, id pravila , 1,2,3,4....
AADD(aDbf,{"RULE_ID",       "N",   10,  0})  
// MODUL_NAME = "RNAL" / modul na koji se odnosi pravilo
AADD(aDbf,{"MODUL_NAME" ,   "C",   10,  0})  
// RULE_OBJ = "ARTICLES" / objekat modula na koji se odnosi pravilo
AADD(aDbf,{"RULE_OBJ",      "C",   30,  0})  
// RULE_NO = 1, 2, 3 / brojac po kljucu MODUL_NAME + RULE_OBJ
AADD(aDbf,{"RULE_NO",       "N",    5,  0})  
// RULE_NAME = "formiranje naziva" / naziv pravila
AADD(aDbf,{"RULE_NAME",     "C",  100,  0})  
// RULE_ERMSG = "greska: xxx yyyy" / greska u slucaju nezadovoljenja pravila
AADD(aDbf,{"RULE_ERMSG",    "C",  200,  0})  
// RULE_LEVEL = 0,1,2... / nivo vaznosti pravila
AADD(aDbf,{"RULE_LEVEL",    "N",    2,  0})  
// RULE_Cx - proizvoljna polja tipa "C", 1, 2, 3
AADD(aDbf,{"RULE_C1",       "C",    1,  0})  
AADD(aDbf,{"RULE_C2",       "C",    5,  0})  
AADD(aDbf,{"RULE_C3",       "C",   10,  0})  
AADD(aDbf,{"RULE_C4",       "C",   10,  0})  
AADD(aDbf,{"RULE_C5",       "C",   50,  0})  
AADD(aDbf,{"RULE_C6",       "C",   50,  0})  
AADD(aDbf,{"RULE_C7",       "C",  100,  0})  
// RULE_Nx - proizvoljna polja tipa "N", 1, 2, 3
AADD(aDbf,{"RULE_N1",       "N",  15,  5})  
AADD(aDbf,{"RULE_N2",       "N",  15,  5})  
AADD(aDbf,{"RULE_N3",       "N",  15,  5})  
// RULE_Dx - proizvoljna polja tipa "D", 1, 2
AADD(aDbf,{"RULE_D1",       "D",  8,  0})  
AADD(aDbf,{"RULE_D2",       "D",  8,  0})  

return aDBF


