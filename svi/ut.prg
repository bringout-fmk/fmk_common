#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/ut.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: ut.prg,v $
 * Revision 1.4  2004/01/13 19:08:00  sasavranic
 * appsrv konverzija
 *
 * Revision 1.3  2002/06/17 18:44:32  ernad
 *
 *
 * podsenje makefile sistema
 *
 * Revision 1.2  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */
 
function Slovima(nIzn,cDINDEM)
*{
local npom; cRez:=""
fI:=.f.

if nIzn<0
  nIzn:=-nIzn
  cRez:="negativno:"
endif

if (nPom:=int(nIzn/10**9))>=1
   if nPom==1
     cRez+="milijarda"
   else
     Stotice(nPom,@cRez,.f.,.t.,cDinDEM)
      if right(cRez,1) $ "eiou"
        cRez+="milijarde"
      else
        cRez+="milijardi"
     endif
   endif
   nIzn:=nIzn-nPom*10**9
   fi:=.t.
endif
if (nPom:=int(nIzn/10**6))>=1
   //if fi; cRez+="i"; endif
   if fi; cRez+=""; endif
   fi:=.t.
   if nPom==1
     cRez+="milion"
   else
     Stotice(nPom,@cRez,.f.,.f.,cDINDEM)
     cRez+="miliona"
   endif
   nIzn:=nIzn-nPom*10**6
   f6:=.t.
endif
if (nPom:=int(nIzn/10**3))>=1
   //if fi; cRez+="i"; endif
   if fi; cRez+=""; endif
   fi:=.t.
   if nPom==1
     cRez+="hiljadu"
   else
     Stotice(nPom,@cRez,.f.,.t.,cDINDEM)
     if right(cRez,1) $ "eiou"
       cRez+="hiljade"
     else
       cRez+="hiljada"
     endif
   endif
   nIzn:=nIzn-nPom*10**3
endif
//if fi .and. nIzn>=1; cRez+="i"; endif
if fi .and. nIzn>=1; cRez+=""; endif
Stotice(nIzn,@cRez,.t.,.t.,cDINDEM)
return
*}

function Stotice(nIzn,cRez,fdecimale,fmnozina,cDINDEM)
*{
local fDec,fSto:=.f.,i

   if (nPom:=int(nIzn/100))>=1
      aSl:={ "stotinu", "dvijestotine", "tristotine", "~etiristotine",;
             "petstotina","{eststotina","sedamstotina","osamstotina","devetstotina"}
      if gKodnaS=="8"
        for i:=1 to len(aSL)
          aSL[i]:=KSTo852(aSl[i])
        next
      endif
      cRez+=aSl[nPom]
      nIzn:=nIzn-nPom*100
      fSto:=.t.
   endif

   fDec:=.f.
   do while .t.
     if fdec
        cRez+=alltrim(str(nizn,2))
     else
      if int(nIzn)>10 .and. int(nIzn)<20
        aSl:={ "jedanaest", "dvanaest", "trinaest", "~etrnaest",;
               "petnaest","{esnaest","sedamnaest","osamnaest","devetnaest"}

        if gKodnaS=="8"
          for i:=1 to len(aSL)
            aSL[i]:=KSTo852(aSl[i])
          next
        endif
        cRez+=aSl[int(nIzn)-10]
        nIzn:=nIzn-int(nIzn)
      endif
      if (nPom:=int(nIzn/10))>=1
        aSl:={ "deset", "dvadeset", "trideset", "~etrdeset",;
               "pedeset","{ezdeset","sedamdeset","osamdeset","devedeset"}
        if gKodnaS=="8"
          for i:=1 to len(aSL)
            aSL[i]:=KSTo852(aSl[i])
          next
        endif
        cRez+=aSl[nPom]
        nIzn:=nIzn-nPom*10
      endif
      if (nPom:=int(nIzn))>=1
         aSl:={ "jedan", "dva", "tri", "~etiri",;
                "pet","{est","sedam","osam","devet"}
         if gKodnaS=="8"
          for i:=1 to len(aSL)
            aSL[i]:=KSTo852(aSl[i])
          next
         endif
        if fmnozina
             aSl[1]:="jedna"
             aSl[2]:="dvije"
        endif
        cRez+=aSl[nPom]
        nIzn:=nIzn-nPom
      endif
      if !fDecimale; exit; endif

     endif // fdec
     if fdec; cRez+="/100 "+cDINDEM; exit; endif
     fDec:=.t.
     fMnozina:=.f.
     nizn:=round(nIzn*100,0)
     if nizn>0
       if !empty(cRez)
           cRez+=" i "
       endif
     else
       if empty(cRez)
          cRez:="nula DEM"
       else
          cRez+=" "+cDINDEM
       endif
       exit
     endif
   enddo


return cRez
*}


function OtkljucajBug()
*{

if SigmaSif("BUG     ")
    lPodBugom:=.f.
    gaKeys:={}
endif

return
*}



