#include "sc.ch"
#include "msg.ch"


/*! \fn CreDB_Message()
 *  \brief Kreiranje tabele za razmjenu poruka
 */
function CreDB_Message()
*{
aDBF:={}
AADD(aDbf,{"FROMHOST","C",7,0})  
AADD(aDbf,{"FROMUSER","C",10,0})  
AADD(aDbf,{"ROW","N",2,0})  
AADD(aDbf,{"TEXT","C",220,0})  
AADD(aDbf,{"CREATED","D",8,0})  
AADD(aDbf,{"SENT","D",8,0})  
AADD(aDbf,{"READ","D",8,0})  
AADD(aDbf,{"PRIORITY","C",1,0})  
AADD(aDbf,{"TO","C",10,0})  
AADD(aDbf,{"UAMESSAGE","C",1,0})  
AADD(aDbf,{"_OID_","N",12,0})  
AADD(aDbf,{"_SITE_","N",2,0})  
AADD(aDbf,{"_USER_","N",3,0})  
AADD(aDbf,{"_DATAZ_","D",8,0})  
AADD(aDbf,{"_TIMEAZ_","C",8,0})  
AADD(aDbf,{"_COMMIT_","C",1,0})  

if !file((KUMPATH+"message.dbf"))
	DBCREATE2(KUMPATH+"message.dbf",aDbf)
endif
CREATE_INDEX("1","FROMHOST",KUMPATH+"message.dbf",.t.)
CREATE_INDEX("2","FROMHOST+FROMUSER+STR(ROW)",KUMPATH+"message.dbf",.t.)
CREATE_INDEX("3","DTOS(READ)",KUMPATH+"message.dbf",.t.)
CREATE_INDEX("4","FROMHOST+FROMUSER+STR(ROW)+DTOS(CREATED)+DTOS(SENT)+TO",KUMPATH+"message.dbf",.t.)
CREATE_INDEX("5","FROMHOST+FROMUSER+PADR(TEXT,40)+DTOS(CREATED)+DTOS(SENT)+TO",KUMPATH+"message.dbf",.t.)

if gSamoProdaja=="D"
	return
endif

aDBF:={}
AADD(aDbf,{"FROMHOST","C",7,0})  
AADD(aDbf,{"FROMUSER","C",10,0})  
AADD(aDbf,{"ROW","N",2,0})  
AADD(aDbf,{"TEXT","C",220,0})  
AADD(aDbf,{"CREATED","D",8,0})  
AADD(aDbf,{"SENT","D",8,0})  
AADD(aDbf,{"READ","D",8,0})  
AADD(aDbf,{"PRIORITY","C",1,0})  
AADD(aDbf,{"TO","C",10,0})  

if !file((EXEPATH+"amessage.dbf"))
	DBCREATE2(EXEPATH+"amessage.dbf",aDbf)
endif
CREATE_INDEX("1","FROMHOST",EXEPATH+"amessage.dbf",.t.)
CREATE_INDEX("2","FROMHOST+FROMUSER+STR(ROW)",EXEPATH+"amessage.dbf",.t.)
CREATE_INDEX("3","DTOS(READ)",EXEPATH+"amessage.dbf",.t.)
CREATE_INDEX("4","FROMHOST+FROMUSER+STR(ROW)+DTOS(CREATED)+DTOS(SENT)+TO",EXEPATH+"amessage.dbf",.t.)


return
*}



function CreTempDBMsg()
*{
aDbf:={}

AADD(aDbf, {"idmsg", "C", 1, 0})
AADD(aDbf, {"fromhost", "C", 7, 0})
AADD(aDbf, {"fromuser", "C", 10, 0})
AADD(aDbf, {"row", "N", 2, 0})
AADD(aDbf, {"text", "C", 220, 0})
AADD(aDbf, {"created", "D", 8, 0})
AADD(aDbf, {"sent", "D", 8, 0})
AADD(aDbf, {"read", "D", 8, 0})
AADD(aDbf, {"priority", "C", 1, 0})
AADD(aDbf, {"to", "C", 10, 0})

if !FILE(EXEPATH + "tmpmsg.dbf")
	DBCreate2(EXEPATH + "tmpmsg", aDbf)
endif

if !FILE(EXEPATH + "tmpmsg.cdx")
	CREATE_INDEX("1","idmsg",EXEPATH+"tmpmsg.dbf",.t.)
endif
return
*}



