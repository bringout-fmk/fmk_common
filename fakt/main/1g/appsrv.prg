#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/main/1g/appsrv.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.5 $
 * $Log: appsrv.prg,v $
 * Revision 1.5  2002/10/15 13:24:52  sasa
 * ciscenje koda
 *
 * Revision 1.4  2002/09/09 08:22:40  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/18 13:07:22  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 
/*! \file fmk/fakt/main/1g/appsrv.prg
 *  \brief
 */

/*! \ingroup ini
  * \var *string FmkIni_PrivPath_FAKT_StampajSveIzPripreme
  * \brief Odredjuje da li ce se stampati svi dokumenti iz pripreme odjednom
  * \param N - default vrijednost
  * \param D - da, stampaj sve iz pripreme
  */
*string FmkIni_PrivPath_FAKT_StampajSveIzPripreme;



/*! \fn RunAppSrv()
 *  \brief Pokrece aplikacijski server
 */
 
function RunAppSrv()
*{
local nH, nH1, nH2

// aplikacijski server ...................................

set date to german
set century off
set epoch to 1960

private lPoNarudzb:=.f.

if IzFMKIni("FAKT","StampajSveIzPripreme","N",PRIVPATH)=="D"
          lSSIP99:=.t.
else
          lSSIP99:=.f.
endif

public gPrinter:="1"
public gPPORT:="1"

IniPrinter()
UcitajParams()

public gldistrib:=.f.
public fID_J:=.f.
public lBenjo:=.f.
public gDest:=.f.

if !File(".\BROJAC")
	nH:=FCreate(".\BROJAC")
   	FWrite(nH,STR(0,8))
   	FClose(nH)
endif


cFALog:=".\log\"+DToS(date())
nHLog:=FCreate(cFaLog)
? "kreiram ",cFaLog

public _V1:=NIL
public _V2:=NIL
public _V3:=NIL
public _V4:=NIL
public _CV1:=""
public _CV2:=""
public _CV3:=""
public _FV1:=.f.
public _FV2:=.f.


cMsg:=Time()+": zaopcinjem rad "
FWrite(nHLog, cMsg + chr(13)+chr(10))

do while .t.
	aFiles:=DIRECTORY("*.FAK")
    	ASORT(aFiles,,,{|x,y| x[1]>y[1] })      // naziv?
    	for i:=1 to LEN(aFiles)
      		cFilename:=aFiles[i,1]
      		? i,cFileName
      		nH:=-100
      		do while nH<0  // R/W mode
       			nH:=FOpen(cFileName,2)
      			if (nH<0)
         			? cFileName,": ne mogu otvoriti u rw/modu"
       			endif
      		enddo
      		
		cMsg:=Time()+": "+ALLTRIM(STR(i,5))+" ; 2-ga do while petlja "+cFileName
      		? cMsg
      		FWrite(nHLog, cMsg + chr(13)+chr(10))
      		cLineF:="__XXXXX__"
      		do while left(cLinef,9) <> "__START__"
       			FSeek(nH,0) // uvijek od pocetka
       			cLineF:=FReadLn(nH,1,80)
       			if LEFT(cLinef,9) <> "__START__"
         			cMsg:=Time()+": komandni fajl "+cFileName+" se jos pravi :" + left(cLineF,9)
         			? cMsg
         			FWrite(nHLog, cMsg + chr(13)+chr(10))
         			// zatvori , pa ponovo otvori ... ovo je mozda rjesenje za sambu
         			FClose(nH)
         			nH:=FOpen(cFileName,2)
       			endif
      		enddo

      		cMsg:=Time()+ ": idem na izvrsenje " + cFileName + " nH="+str(nH)
      		? cMsg
      		
		FWrite(nHLog, cMsg + chr(13)+chr(10))

      		FClose(nH)
      		nRezExec:=ExecKomande(cFileName, nHLog)
      		FClose(nH)
      		? "---------------kraj exec komande -----------------"
      		if nRezExec=2
        		// prebaci outf.txt u matricu rezultata
        		? "copy file outf.txt outf "+".\xrez\"+cFileName
        		__CopyFile(PRIVPATH+"outf.txt",".\xrez\"+cFileName)
      		endif
      		if nRezExec=3
        		? "copy file apprez to "+".\xrez\"+cFileName
        		// prebaci apprez.txt u matricu rezultata
        		__CopyFile(PRIVPATH+"apprez.txt",".\xrez\"+cFileName)
      		endif
      		copy file (".\"+cFileName) to (".\xlog\"+cFileName)
      		FErase(cFileName)
      		if nRezExec=4
         		goModul:quit()
     		endif
    		next
enddo
*}



/*! \fn ExecKomande(cFileName,nHXApsLog)
 *  \brief Exe komande
 *  \param cFileName    - ime fajla
 *  \param nHXApsLog
 */
 
function ExecKomande(cFileName,nHXApsLog)
*{
local nHOut
private cLnApsrv:=""

nHXAps:=FOpen(cFileName,2)

FSeek(nHXAps,0)

do while .t.
	cLnApsrv:=Freadln(nHXAps,1,200)
 	if len(cLnApsrv)==0
   		cMsg:= time() + ": exec komande: len  cLnApsrv = 0"
   		? cMsg
   		fwrite(nHXApsLog, cMsg + chr(13)+chr(10))
   		exit
 	endif
 	cLnApsrv :=strtran(cLnApsrv ,chr(13)+chr(10),"")
 	cMsg:= time() + ": exec:"+cLnApsrv
 	? cMsg
 	fwrite(nHXApsLog, cMsg + chr(13)+chr(10))
 	if (cLnApsrv="__START__")
    		loop
 	endif
 	if (cLnApsrv=="__AREYOUALIVE__")
    		nHXApsOut:=fcreate(PRIVPATH+'apprez.txt',0)
    		? "nHXApsout=",nHXApsOut
    		if (nHXApsout<1)
     			? "Ne mogu kreirati :" + PRIVPATH+'apprez.txt'
    		else
     			fwrite(nHXApsOut,"Yes")
     			fclose(nHXApsout)
    		endif
    		return 3
	endif

	if (cLnApsrv=="__SHOW__")
		? "idem na SHOW komandu"
    		fClose(nHXAps)
    		return 2
    		// prikazi outf.txt
	endif

	if (cLnApsrv=="__QUIT__")
		? "idem na quit komandu"
    		fClose(nHXAps)
    		return 4
	endif

	cLnApsrv:="{|| "+trim(cLnApsrv)+"}"
	? cLnApsrv
	EVAL(&cLnApsrv)

	? "iza eval ....", cLnApSrv
enddo

// kraj ... nema prikaza
fClose(nHXAps)

return 1
*}


