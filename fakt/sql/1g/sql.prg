#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/sql/1g/sql.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: sql.prg,v $
 * Revision 1.2  2002/06/19 09:23:04  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 

/*! \file fmk/fakt/sql/1g/sql.prg
 *  \brief Obrade sql upita
 */

/*! \fn ASqlCroba(nH,cFile,cIdRoba,cVM,cUI,nKolicina)
 *  \brief Azuriranje u sql croba
 *  \param nH          - kreiraj fajl za sql komande 
 *  \param cFile       - naziv fajla
 *  \param cIdRoba    
 *  \param cVM         - veleprodaja/maloprodaja
 *  \param cUI         - 0-setuj stanje na nKolicina, 1-ulaz nKolincina, 2-izlaz nKolicina  
 *  \param nKolicina
 */
 
function ASqlCroba(nH,cFile,cIdRoba,cVM,cUI,nKolicina)
*{
local cSQL
local aRez

if nH=0 
  // zapocni
  aRez:=sqlexec(@nH,cFile,"sc","commit")
  return "OK"
elseif left(cFile,5)="#END#"
  //cidroba sadrzi u sebi ime fajla
  aRez:=sqlexec(@nH,cFile,"sc","commit")
  return "OK"  
else  
  // za svaki slucaj insertuj, pa ako vec ima nece se nista desiti
  cSQL:="insert into croba "+;
         "(idrobafmk,stanjem,stanjev,ulazm,ulazv,realm,realv,datumm,datumv) "+;
         "values("+sqlvalue(cIdRoba)+", 0,0,0,0,0,0,CURDATE(),CURDATE())"

  aRez:=sqlexec(@nH,cFile,"sc",cSQL)
endif

if cUI=="0" .and. cVM=="M"
   cSQL:="update  croba "+;
         "set stanjem=0, "+;
         "ulazm=0, "+;
         "realm=0, datumm=CURDATE() "+;
         "  where idrobafmk="+sqlvalue(cIdroba)
   aRez:=sqlexec(@nH,cFile,"sc",cSQL)
elseif cUI=="0" .and. cVM=="V"
   cSQL:="update  croba "+;
         "set stanjev=0, "+;
         "ulazv=0, "+;
         "realv=0, datumv=CURDATE()  "+;
         "  where idrobafmk="+sqlvalue(cIdroba)
   aRez:=sqlexec(@nH,cFile,"sc",cSQL)
endif


if cUI<>"0" // nije pocetno stanje
  cSQL:="update croba set stanjem=stanjem+ulazm-realm, ulazm=0, realm=0, datumm=CURDATE()"+;
        "  where idrobafmk="+sqlvalue(cIdroba)+" and "+;
        "  CURDATE()<>datumm"
  aRez:=sqlexec(@nH,cFile,"sc",cSQL)

  cSQL:="update croba set stanjev=(stanjev+ulazv-realv), "+;
        "  ulazv=0.0, realv=0.0, datumv=CURDATE() "+;
        "  where idrobafmk="+sqlvalue(cIdroba)+" and "+;
        "  CURDATE()<>datumv"
  aRez:=sqlexec(@nH,cFile,"sc",cSQL)
  
endif


if cVM=="M"
 if cUI='0'
    cSQL:="update  croba "+;
         "set stanjem="+sqlvalue(nKolicina)+", datumm=CURDATE()"   +;
         "  where idrobafmk="+sqlvalue(cIdroba)
    aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 elseif cUI=="1"
    cSQL:="update  croba "+;
          "set ulazm=ulazm+"+sqlvalue(nKolicina)+", datumm=CURDATE()" + ;
          "  where idrobafmk="+sqlvalue(cIdroba)
    aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 elseif cUI=="2"
    cSQL:="update  croba "+;
          "set realm=realm+"+sqlvalue(nKolicina)+", datumm=CURDATE()" + ;
          "  where idrobafmk="+sqlvalue(cIdroba)
    aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 endif
endif
if cVM=="V"
 if cUI='0'
    //REPLACE StanjeV WITH nKolicina
    cSQL:="update  croba "+;
          "set stanjev="+sqlvalue(nKolicina)+", datumv=CURDATE()" + ;
          "  where idrobafmk="+sqlvalue(cIdroba)
    aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 elseif cUI=="1"
    //REPLACE UlazV WITH UlazV+nKolicina
    cSQL:="update  croba "+;
          "set ulazv=ulazv+"+sqlvalue(nKolicina)+", datumv=CURDATE()" + ;
          "  where idrobafmk="+sqlvalue(cIdroba)
    aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 elseif cUI=="2"
    //REPLACE RealV WITH RealV+nKolicina
    cSQL:="update  croba "+;
          "set realv=realv+"+sqlvalue(nKolicina)+", datumv=CURDATE()" + ;
          "  where idrobafmk="+sqlvalue(cIdroba)
    aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 endif
endif

return
*}

/*! \fn O_Log()
 *  \brief
 */
 
function O_Log()
*{
local cPom, cLogF

altd()
cPom:=KUMPATH+"\SQL"
DirMak2(cPom)

cLogF:=cPom+"\"+replicate("0",8)



if !file (cLogF)
   //nema pocetnog stanja
   nH:=fcreate(cLogF)
   O_ROBA
   Log_Tabela(nH,"ROBA")

  cLogF:=padl(alltrim(str(1)),8,"0")
  UzmiIzIni(KUMPATH+'sql\fmk.ini','Log','Broj',cLogF,'WRITE')
  nH:=fcreate(gLogF)
  //fwrite(nH,"#"+dtos(date())+" "+time()+" "+alltrim(str(nUser))+chr(13)+chr(10))
  fwrite(nH,"#"+dtos(date())+" "+time()+chr(13)+chr(10))
  fclose(nH)

else

  altd()
  cLogf:=UzmiIzIni(KUMPATH+'sql\fmk.ini','Log','Broj',cLogF,'READ')

endif

public gLogF:=cPom+"\"+cLogF // npr. c:\TOPS\SIGAM\KUM1\SQL\0000001

nH:=fopen(gLogF,2)
fwrite(nH,"#"+dtos(date())+" "+time()+chr(13)+chr(10))
fclose(nH)
return
*}


/*! \fn SqlExec(nH,cFile,cDatabase,cSql)
 *  \brief Izvrsi SQL komandu
 *  \param nH
 *  \param cFile
 *  \param cDatabase
 *  \param cSql
 */
 
function SqlExec(nH,cFile,cDatabase,cSql)
*{
local fOdmah:=.f.

private cKomLin:=""
if cFile=="#BEG"
  // fajl je vec otvoren
elseif cFile="#END" 
  // fajl je vec otvoren
else 
    if nH=-999
       // kreiraj i odmah izvrsi
      fOdmah:=.t.
    endif
    nH:=Fcreate(cFile)
  
endif  

if nH<=0
  return "ERR"
endif


fwrite(nH,cSQL+";"+Chr(13)+Chr(10))

if fOdmah .or. cFile="#END" 
  // zavrsi posao ...........
  fclose(nH)
  cKomLin:=gSQLKom+cDatabase+" < "+cFile
  run &cKomLin
endif  

return "OK"
*}


/*! \fn SqlValue(xVar)
 *  \brief Vrijednost sql
 *  \param xVar
 */
 
function SqlValue(xVar)
*{
local cPom

if valtype(xVAR)="C"
   return "'"+xVar+"'"
elseif valtype(xVAR)="N"
   return str(xVar)
elseif valtype(xVar)="D"
   cPom:=dtos(xVar)
   //1234-56-78
   cPom:="'"+substr(cPom,1,4)+"-"+substr(cPom,5,2)+"-"+substr(cPom,7,2)+"'"
   return cPom
else
   return "NULL"
endif
*}



/*! \fn SqlResult(cFile,aSqlType)
 *  \brief
 *  \param cFile
 *  \param aSqlType
 */
 
function SqlResult(cFile,aSqlType)
*{
local cLin,ctok
local i
local aResult, aSQLRow


nH:=fopen(cFile)
if nH<0 
  aResult:={"ERR"}
else
  cLin:="startxyz"
  aResult:={{"OK",0}}
  do while !empty(cLin)
       cLin:=freadln(nh,1,250)
       nTok := NUMTOKEN( cLin , chr(9), 1 )
       if aSQLType!=NIL .and. len(aSQLType)!=nTok
          // nema vise slogova
          exit
       endif

       aSQLRow:={}
       FOR i:= 1 TO nTok
         cTok := TOKEN( cLin , chr(9) , i , 1 )
         if aSQLType<>NIL // prosljedjeni su tipovi rezultata
            if aSQLType[i]="N"
               cTok:=Val(cTOK)
            elseif aSQLType[i]="D"
               //1234-67-9A
               cTOK:=CTOD( substr(cTOK,9,2)+"."+substr(cTok,6,2)+"."+substr(cTok,1,4) )
            endif      
         endif   
         AADD(aSQLRow,cTOK)
       next
       AADD(aResult,aSQLRow)
       // record count
       aResult[1,2]:=aResult[1,2] + 1      
  enddo
endif
fclose(nh)
return aResult
*}



/*! \fn SqlSelect(cFile,cDatabase,cSql,aSqlType)
 *  \brief 
 *  \param cFile
 *  \param cDatabase
 *  \param cSql
 *  \param aSqlType
 */
 
function SqlSelect(cFile,cDatabase,cSql,aSqlType)
*{
local  nH

private cKomLin:=""
nH:= fcreate(cFile)
if nH<=0
  return {"ERR"}
endif
fwrite(nH,cSQL)
fclose(nH)
// neka rezultat ide u sqlout
cKomLin:=gSQLKom+cDatabase+" < "+cFile+" > c:\sigma\sqlout"
run &cKomLin

// daj mi matricu rezultata
return sqlresult("c:\sigma\sqlout", aSQLType )
*}




