#include "ld.ch"

// -------------------------------------
// obracun i prikaz poreza
// -------------------------------------
function obr_porez( nPor, nPor2, nPorOps, nPorOps2, nUPorOl, cTipPor )
local cAlgoritam := ""

if cTipPor == nil
	cTipPor := ""
endif

select por
go top

nPom:=0
nPor:=0
nPor2:=0
nPorOps:=0
nPorOps2:=0
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
	
	cAlgoritam := get_algoritam()
	
	// ako to nije taj tip poreza preskoci
	if !EMPTY( cTipPor )
		if por_tip <> cTipPor
			skip
			loop
		endif
	endif

	if prow() > ( 55 + gPStranica )
		FF
	endif

	? id, "-", naz
	
	if cAlgoritam == "S"
		@ prow(), pcol() + 1 SAY "st.por"
	else
		@ prow(), pcol() + 1 SAY iznos pict "99.99%"
	endif
	
	nC1 := pcol() + 1
	
	if !EMPTY(poopst)
     		
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
		// ukupna Osnovica za Obracun Poreza za po opstinama
     		
		nPOLjudi:=0  
     		// ukup.ljudi za po opstinama
     		
		nPorOps:=0
     		nPorOps2:=0
     		
		if cAlgoritam == "S"
			cSeek := por->id
		else
			cSeek := SPACE(2)
		endif
		
		select opsld
     		seek cSeek + por->poopst
     		
		? strtran(cLinija,"-","=")
     		
		do while !eof() .and. porid == cSeek ;
			.and. id == por->poopst
		
			cOpst := opsld->idops
			
			select ops
			hseek cOpst
			
			select opsld
		        
			if !ImaUOp("POR", POR->id)
		        	
				skip 1
			   	loop
				
		        endif
		        
			if cAlgoritam == "S"
				
			  ? idops, ops->naz
				
			  nPom := 0
			  
			  do while !EOF() .and. porid == cSeek ;
				.and. id == por->poopst ;
				.and. idops == cOpst
				
				if t_iz_1 <> 0
				  ? " -obracun za stopu "
				  @ prow(), pcol()+1 SAY t_st_1 pict "99.99%"
				  @ prow(), pcol()+1 SAY "="
		        	  @ prow(), pcol()+1 SAY t_iz_1 pict gpici
		        	endif
				
				if t_iz_2 <> 0
				  ? " -obracun za stopu "
				  @ prow(), pcol()+1 SAY t_st_2 pict "99.99%"
				  @ prow(), pcol()+1 SAY "="
		        	  @ prow(), pcol()+1 SAY t_iz_2 pict gpici
		        	endif
				
				if t_iz_3 <> 0
				  ? " -obracun za stopu "
				  @ prow(), pcol()+1 SAY t_st_3 pict "99.99%"
				  @ prow(), pcol()+1 SAY "="
		        	  @ prow(), pcol()+1 SAY t_iz_3 pict gpici
		        	endif
				
				if t_iz_4 <> 0
				  ? " -obracun za stopu "
				  @ prow(), pcol()+1 SAY t_st_4 pict "99.99%"
				  @ prow(), pcol()+1 SAY "="
		        	  @ prow(), pcol()+1 SAY t_iz_4 pict gpici
		        	endif
			
				if t_iz_5 <> 0
				  ? " -obracun za stopu "
				  @ prow(), pcol()+1 SAY t_st_5 pict "99.99%"
				  @ prow(), pcol()+1 SAY "="
		        	  @ prow(), pcol()+1 SAY t_iz_5 pict gpici
		        	endif
			
				nPom += t_iz_1
				nPom += t_iz_2 
				nPom += t_iz_3
				nPom += t_iz_4
				nPom += t_iz_5
				
				skip
					
			  enddo

			  @ prow(), pcol()+1 SAY "UK="
			  @ prow(), pcol()+1 SAY nPom PICT gPici
			  
			  Rekapld("POR"+por->id+idops,cGodina,cMjesec,nPom,iznos,idops,NLjudi())
			  
			else
			
			  ? idops, ops->naz
		       	  
			  // ovo je osnovica za porez
			  nTmpPor := iznos

			  if por->por_tip == "B"
			  	// ako je na bruto onda je ovo osnovica
			  	nTmpPor := iznos3
			  endif

			  @ prow(), nC1 SAY nTmpPor picture gpici
			  
			  nPom := round2(max(por->dlimit,por->iznos/100*nTmpPor),gZaok2)
			  
			  @ prow(), pcol()+1 SAY nPom pict gpici
		        
			  if cUmPD=="D"
		        	@ prow(),pcol()+1 SAY nPom2:=round2(max(por->dlimit,por->iznos/100*piznos),gZaok2) pict gpici
		        	@ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
		        	
				Rekapld("POR"+por->id+idops,cgodina,cmjesec,nPom-nPom2,0,idops,NLjudi())
		        	nPorOps2 += nPom2
		          else
		        	
				Rekapld("POR"+por->id+idops,cgodina,cmjesec,nPom,nTmpPor,idops,NLjudi())
			  endif
		        
			endif
			
			nOOP += nTmpPor
		        nPOLjudi += ljudi
		        nPorOps += nPom
		       
		        if cAlgoritam <> "S"
				skip
		        endif
			
			if prow() > (62 + gPStranica)
				FF
			endif
		
		enddo
		select por
		
		? cLinija
		
		nPor += nPorOps
		nPor2 += nPorOps2
		
	endif
   	
	if !EMPTY(poopst)
	
     		? Lokal("Ukupno po ops.:")
     		
		@ prow(), nC1 SAY nOOP pict gpici
     		@ prow(),pcol()+1 SAY nPorOps   pict gpici
     		
		if cUmPD=="D"
       			@ prow(),pcol()+1 SAY nPorOps2   pict gpici
       			@ prow(),pcol()+1 SAY nPorOps-nPorOps2   pict gpici
       			Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps-nPorOps2,0,,NLjudi())
     		else
       			Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps,nOOP,,"("+ALLTRIM(STR(nPOLjudi))+")")
     		endif
		
     		? cLinija
   	else
     		
		nTmpOsnova := nUNeto
		if por->por_tip == "B"
			nTmpOsnova := nPorOsnova
		endif
		
		@ prow(),nC1 SAY nTmpOsnova pict gpici
		@ prow(),pcol()+1 SAY nPom:=round2(max(dlimit,iznos/100*nTmpOsnova),gZaok2) pict gpici
     		if cUmPD=="D"
       			@ prow(),pcol()+1 SAY nPom2:=round2(max(dlimit,iznos/100*nUNeto2),gZaok2) pict gpici
       			@ prow(),pcol()+1 SAY nPom-nPom2 pict gpici
       			Rekapld("POR"+por->id,cgodina,cmjesec,nPom-nPom2,0)
       			nPor2+=nPom2
     		else
       			Rekapld("POR"+por->id,cgodina,cmjesec,nPom,nTmpOsnova,,"("+ALLTRIM(STR(nLjudi))+")")
     		endif
     		
		nPor += nPom
   	endif
	
	skip
enddo

/*
if round2(nUPorOl,2)<>0 .and. gDaPorOl=="D" .and. !Obr2_9()
	? Lokal("PORESKE OLAKSICE")
   	select por
	go top
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
         		select ops
			hseek opsld->idops
			select opsld
         		IF !ImaUOp("POR",POR->id)
           			SKIP 1
				LOOP
         		ENDIF
         		? idops, ops->naz
         		@ prow(), nc1 SAY parobr->prosld picture gpici
         		@ prow(), pcol()+1 SAY round2(iznos2,gZaok2)    picture gpici
         		Rekapld("POROL"+por->id+opsld->idops,cgodina,cmjesec,round2(iznos2,gZaok2),0,opsld->idops,NLjudi())
         		skip
         		if prow()>62+gPStranica
				FF
			endif
      		enddo
      		select por
      		? cLinija
      		? Lokal("UKUPNO POR.OL")
   	endif
   	
	@ prow(),nC1 SAY parobr->prosld  pict gpici
   	@ prow(),pcol()+1 SAY round2(nUPorOl,gZaok2)    pict gpici
   	Rekapld("POROL"+por->id,cgodina,cmjesec,round2(nUPorOl,gZaok2),0,,"("+ALLTRIM(STR(nLjudi))+")")
   	if !empty(poopst)
   		? cLinija
   	endif
endif
*/

? cLinija
? Lokal("Ukupno Porez")
@ prow(),nC1 SAY space(len(gpici))
@ prow(),pcol()+1 SAY nPor - nUPorOl pict gpici

if cUmPD=="D"
	@ prow(),PCOL()+1 SAY nPor2              pict gpici
  	@ prow(),pcol()+1 SAY nPor-nUPorOl-nPor2 pict gpici
endif

? cLinija

return

