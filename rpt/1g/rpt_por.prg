#include "\dev\fmk\ld\ld.ch"

// -------------------------------------
// obracun i prikaz poreza
// -------------------------------------
function obr_porez( nPor, nPor2, nPorOps, nPorOps2, nUPorOl )

	select por
	go top
	nPom:=nPor:=nPor2:=nPorOps:=nPorOps2:=0
	nC1:=20

	cLinija:="----------------------- -------- ----------- -----------"

	if cUmPD=="D"
  		m+=" ----------- -----------"
	endif

	if cUmPD=="D"
  		P_12CPI
  		? "----------------------- -------- ----------- ----------- ----------- -----------"
  		? Lokal("                                 Obracunska     Porez    Preplaceni     Porez   ")
  		? Lokal("     Naziv poreza          %      osnovica   po obracunu    porez     za uplatu ")
  		? "          (1)             (2)        (3)     (4)=(2)*(3)     (5)     (6)=(4)-(5)"
  		? "----------------------- -------- ----------- ----------- ----------- -----------"
	endif

	do while !eof()
  		if prow()>55+gPStranica
    			FF
  		endif
   		
		? id,"-",naz
   		@ prow(),pcol()+1 SAY iznos pict "99.99%"
   		nC1:=pcol()+1
   		if !empty(poopst)
			altd()
     			if poopst=="1"
       				?? Lokal(" (po opst.stan)")
     			elseif poopst=="2"
       				?? Lokal(" (po opst.stan)")
     			elseif poopst=="3"
       				?? Lokal(" (po kant.stan)")
     			elseif poopst=="4"
       				?? Lokal(" (po kant.rada)")
     			elseif poopst=="5"
       				?? Lokal(" (po ent. stan)")
     			elseif poopst=="6"
       				?? Lokal(" (po ent. rada)")
       				?? Lokal(" (po opst.rada)")
     			endif
     			nOOP:=0      
			// ukupna Osnovica za ObraŸun Poreza za po opçtinama
     			nPOLjudi:=0  
     			// ukup.ljudi za po opçtinama
     			nPorOps:=0
     			nPorOps2:=0
     			select opsld
     			seek por->poopst
     			? strtran(cLinija,"-","=")
     			do while !eof() .and. id==por->poopst   //idopsst
		         select ops
			 hseek opsld->idops
			 select opsld
		         IF !ImaUOp("POR",POR->id)
		           SKIP 1
			   LOOP
		         ENDIF
		         ? idops,ops->naz
		         @ prow(),nc1 SAY iznos picture gpici
		         @ prow(),pcol()+1 SAY nPom:=round2(max(por->dlimit,por->iznos/100*iznos),gZaok2) pict gpici
		         if cUmPD=="D"
		           // ______  PORLD ______________
		           @ prow(),pcol()+1 SAY nPom2:=round2(max(por->dlimit,por->iznos/100*piznos),gZaok2) pict gpici
		           @ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
		           Rekapld("POR"+por->id+idops,cgodina,cmjesec,nPom-nPom2,0,idops,NLjudi())
		           nPorOps2+=nPom2
		         else
		           Rekapld("POR"+por->id+idops,cgodina,cmjesec,nPom,iznos,idops,NLjudi())
		         endif
		         nOOP += iznos
		         nPOLjudi += ljudi
		         nPorOps+=nPom
		         skip
		         if prow()>62+gPStranica
			 	FF
			 endif
		     enddo
		     select por
		     ? cLinija
		     nPor+=nPorOps
		     nPor2+=nPorOps2
	   endif // poopst
   if !empty(poopst)
     ? cLinija
     ? Lokal("Ukupno:")
//     @ prow(),nc1 SAY nUNeto pict gpici
     @ prow(),nc1 SAY nOOP pict gpici
     @ prow(),pcol()+1 SAY nPorOps   pict gpici
     if cUmPD=="D"
       @ prow(),pcol()+1 SAY nPorOps2   pict gpici
       @ prow(),pcol()+1 SAY nPorOps-nPorOps2   pict gpici
       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps-nPorOps2,0,,NLjudi())
     else
//       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps,nUNeto,,NLjudi())
       Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps,nOOP,,"("+ALLTRIM(STR(nPOLjudi))+")")
     endif
     ? cLinija
   else
     @ prow(),nc1 SAY nUNeto pict gpici
     @ prow(),pcol()+1 SAY nPom:=round2(max(dlimit,iznos/100*nUNeto),gZaok2) pict gpici
     if cUmPD=="D"
       @ prow(),pcol()+1 SAY nPom2:=round2(max(dlimit,iznos/100*nUNeto2),gZaok2) pict gpici
       @ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
       Rekapld("POR"+por->id,cgodina,cmjesec,nPom-nPom2,0)
       nPor2+=nPom2
     else
       Rekapld("POR"+por->id,cgodina,cmjesec,nPom,nUNeto,,"("+ALLTRIM(STR(nLjudi))+")")
     endif
     nPor+=nPom
   endif


  skip
enddo
if round2(nUPorOl,2)<>0 .and. gDaPorOl=="D" .and. !Obr2_9()
   ? Lokal("PORESKE OLAKSICE")
   select por; go top
   nPOlOps:=0
   if !empty(poopst)
      if poopst=="1"
       ?? Lokal(" (po opst.stan)")
      else
       ?? Lokal(" (po opst.rada)")
      endif
      nPOlOps:=0
      select opsld
      seek por->poopst
      do while !eof() .and. id==por->poopst
         If prow()>55+gPStranica
           FF
         endif
         select ops; hseek opsld->idops; select opsld
         IF !ImaUOp("POR",POR->id)
           SKIP 1; LOOP
         ENDIF
         ? idops, ops->naz
         @ prow(), nc1 SAY parobr->prosld picture gpici
         @ prow(), pcol()+1 SAY round2(iznos2,gZaok2)    picture gpici
         Rekapld("POROL"+por->id+opsld->idops,cgodina,cmjesec,round2(iznos2,gZaok2),0,opsld->idops,NLjudi())
         skip
         if prow()>62+gPStranica; FF; endif
      enddo
      select por
      ? cLinija
      ? Lokal("UKUPNO POR.OL")
   endif // poopst
   @ prow(),nC1 SAY parobr->prosld  pict gpici
   @ prow(),pcol()+1 SAY round2(nUPorOl,gZaok2)    pict gpici
   Rekapld("POROL"+por->id,cgodina,cmjesec,round2(nUPorOl,gZaok2),0,,"("+ALLTRIM(STR(nLjudi))+")")
   if !empty(poopst)
   	? cLinija
   endif

endif
? cLinija
? Lokal("Ukupno Porez")
@ prow(),nC1 SAY space(len(gpici))
@ prow(),pcol()+1 SAY nPor-nUPorOl pict gpici
if cUmPD=="D"
  @ prow(),PCOL()+1 SAY nPor2              pict gpici
  @ prow(),pcol()+1 SAY nPor-nUPorOl-nPor2 pict gpici
endif
? cLinija

return

