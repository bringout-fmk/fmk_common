#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/razdb/1g/kont_dok.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.13 $
 * $Log: kont_dok.prg,v $
 * Revision 1.13  2004/03/02 18:37:28  sasavranic
 * no message
 *
 * Revision 1.12  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.11  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.10  2003/06/25 17:48:21  mirsad
 * debug: opis stavki u FIN-nalogu ako je u shemi definisano zaokr. pomocu ";9"  prociscen od ovih spec.simbola
 *
 * Revision 1.9  2003/05/28 05:42:46  mirsad
 * debug kalk->fin - porezi u ugost.var."T"
 *
 * Revision 1.8  2003/05/27 00:37:56  mirsad
 * debug kalk->fin - porezi u ugost.var."T"
 *
 * Revision 1.7  2003/01/08 03:15:25  mirsad
 * omogucen parametar trfp->dokument=="R" za izbor prenosa radnog naloga u broj veze
 *
 * Revision 1.6  2003/01/06 15:28:15  mirsad
 * ispravka BUG-a pri KALK->FIN
 *
 * Revision 1.5  2002/11/21 13:29:03  mirsad
 * ispravka bug-a: zaokruženje krajnjih iznosa u FIN-nalogu sada mora biti minimalno na 2 decimale
 *
 * Revision 1.4  2002/07/22 14:17:04  mirsad
 * ispravio bug: sada kontira PRUCMP (pruc - ugostiteljstvo)
 *
 * Revision 1.3  2002/07/19 14:00:29  mirsad
 * lPrikPRUC je sada globalna
 *
 * Revision 1.2  2002/06/24 09:19:02  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/razdb/1g/kont_dok.prg
 *  \brief Operacije kontiranja dokumenata na osnovu shema kontiranja
 */


/*! \fn KontNal(fAuto)
 *  \param fAuto - .t. automatski se odrjedjuje broj naloga koji se formira, .f. getuje se broj formiranog naloga - default vrijednost
 *  \brief Kontiranje dokumenta tj. formiranje FIN i/ili MAT naloga
 */

function KontNal(fAuto)
*{
local cidfirma,cidvd,cbrdok, lAFin,lAMat, lafin2,lamat2
local nRecNo
local lPrvoDzok:=(IzFMKINI("KontiranjeKALK","PrioritetImajuDzokeri","N",SIFPATH)=="D")

PRIVATE lVrsteP := ( IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D" )

if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK;O_SIFV
endif
O_ROBA
O_FINMAT
O_TRFP
O_KONCIJ
IF FIELDPOS("IDRJ")<>0
  lPoRj:=.t.
ELSE
  lPoRj:=.f.
ENDIF
O_VALUTE

if fAuto==NIL
	fAuto:=.f.
endif

lAFin:=(fauto .and. gAFin=="D")

if lafin
	Beep(1)
	lafin:=Pitanje(,"Formirati FIN nalog?","D")=="D"
endif

lafin2:=(!fauto .and. gafin<>"0")
lAMat:=(fauto .and. gAMat=="D")

if lamat
	Beep(1)
	lamat:=Pitanje(,"Formirati MAT nalog?","D")=="D"
	O_TRMP
endif

lamat2:=(!fauto .and. gamat<>"0")
cBrNalF:=cBrNalM:=""

if lAFin .or. lAFin2
	use (SezRad(gDirFIN)+"pripr") new alias fpripr
	set order to 1
	use (SezRad(gDirFIK)+"nalog") new alias fnalog
	set order to 1
endif

if lAMat .or. lAMat2
	use (SezRad(gDirMAT)+"pripr") new alias mpripr
	set order to tag "1"
	use (SezRad(gDirMAK)+"nalog") new alias mnalog
	set order to tag "1"
endif

select FINMAT
go top

if finmat->idvd $ "14#94#96#95"
	select koncij
	seek trim(finmat->idkonto2)
else
	select koncij
	hseek trim(finmat->idkonto)
endif

select trfp
seek finmat->IdVD+koncij->shema
cIdVN:=IdVN   // uzmi vrstu naloga koja ce se uzeti u odnosu na prvu kalkulaciju
             //  koja se kontira

if KONCIJ->(FIELDPOS("FN14"))<>0 .and. !EMPTY(KONCIJ->FN14) .and. FINMAT->IDVD=="14"
	cIdVN:=KONCIJ->FN14
endif

if lAFin .or. lAFin2
	select fnalog
	seek finmat->idfirma+cidvn+"X"
	skip -1
	if idvn<>cidvn
		// cBrnalF:="0"
		cBrnalF:="0000"
	else
		cBrNalF:=brnal
	endif
	cBrNalF:=NovaSifra(cBrNalF)
	select fnalog
	use
endif

if lAMat .or. lAMat2
	select mnalog
	seek finmat->idfirma+cidvn+"X"
	skip -1
	if idvn<>cidvn
		cBrnalM:="0000"
	else
		cBrNalM:=brnal
	endif
	cBrNalM:=NovaSifra(cBrNalM)
	select mnalog
	use
endif

select finmat
go top

Box("brn?",5,55)
dDatNal:=datdok
set cursor on

if fAuto
	if !lAFin
		cBrNalF:=""
	else
		@ m_x+1,m_y+2  SAY "Broj naloga u FIN  "+finmat->idfirma+" - "+cidvn+" - "+cBrNalF
	endif
	
	if !lAMat
		cBrBalM:=""
	else
		if idvd<>"24" // kalkulacija usluge
			@ m_x+2,m_y+2 SAY "Broj naloga u MAT  "+finmat->idfirma+" - "+cidvn+" - "+cBrNalM
		endif
	endif
	
	@ m_x+4,m_y+2 SAY "Datum naloga: "; ?? dDatNal
	
	if lAFin .or. lAMat
		inkey(0)
	endif
else
	if laFin2
		@ m_x+1,m_y+2 SAY "Broj naloga u FIN  "+finmat->idfirma+" - "+cidvn+" -" GET cBrNalF
	endif
	
	if idvd<>"24" .and. laMat2
		@ m_x+2,m_y+2 SAY "Broj naloga u MAT  "+finmat->idfirma+" - "+cidvn+" -" GET cBrNalM
	endif

	@ m_x+5,m_y+2 SAY "(ako je broj naloga prazan - ne vrsi se kontiranje)"
	read
	ESC_BCR
endif

BoxC()

nRbr:=0
nRbr2:=0

MsgO("Prenos KALK -> FIN")

select finmat
private cKonto1:=NIL
altd()
do while !eof()    // datoteka finmat

 cIDVD:=IdVD
 cBrDok:=BrDok
 if valtype(cKonto1)<>"C"
  private cKonto1:=""
  private cKonto2:=""
  private cKonto3:=""
  private cPartner1:=cPartner2:=cPartner3:=cPartner4:=cPartner5:=""
  private cBrFakt1:=cBrFakt2:=cBrFakt3:=cBrFakt4:=cBrFakt5:=SPACE(10)
  private dDatFakt1:=dDatFakt2:=dDatFakt3:=dDatFakt4:=dDatFakt5:=CTOD("")
  private cRj1:=""
  private cRj2:=""
 endif
 private dDatVal:=ctod("")  // inicijalizuj datum valute
 private cIdVrsteP:="  "    // i vrstu placanja

 do while cIdVD==IdVD .and. cBrDok==BrDok .and. !eof()

     if finmat->idvd $ "14#94#96#95"
          select koncij; hseek finmat->idkonto2
     else
          select koncij; hseek finmat->idkonto
     endif
     select roba; hseek finmat->idroba

         select trfp
         seek cIdVD+koncij->shema
         do while !empty(cBrNalF) .and. idvd==cIDVD  .and. shema=koncij->shema .and. !eof()

          cStavka:=Id
          select finmat
          nIz:=&cStavka
          select trfp
          if !empty(trfp->idtarifa) .and. trfp->idtarifa<>finmat->idtarifa
            // ako u {ifrarniku parametara postoji tarifa prenosi po tarifama
            niz:=0
          endif
          if empty(trfp->idtarifa) .and. roba->tip $ "U"
            // roba tipa u,t
            nIz:=0
          endif

          // iskoristeno u slucaju RN, gdje se za kontiranje stavke
          // 901-999 koriste sa tarifom XXXXXX
          if finmat->idtarifa=="XXXXXX" .and. trfp->idtarifa<>finmat->idtarifa
            nIz:=0
          endif

          if nIz<>0  // ako je iznos elementa <> 0, dodaj stavku u fpripr

            IF lPoRj
              IF TRFP->porj="D"
                cIdRj := KONCIJ->idrj
              ELSEIF TRFP->porj="S"
                cIdRj := KONCIJ->sidrj
              ELSE
                cIdRj := ""
              ENDIF
            ENDIF

            select fpripr

            if trfp->znak=="-"
              nIz:=-nIz
            endif
            if gBaznaV=="P"
               nIz:=round7(nIz,RIGHT(TRFP->naz,2))  //DEM - pomocna valuta
               nIz2:=round7(nIz*Kurs(FINMAT->DatKurs,"P","D"),RIGHT(TRFP->naz,2))
            else
               nIz2:=round7(nIz,RIGHT(TRFP->naz,2))  //DEM - pomocna valuta
               nIz:=round7(nIz2*Kurs(FINMAT->DatKurs,"D","P"),RIGHT(TRFP->naz,2))
            endif


            if "IDKONTO"==padr(trfp->IdKonto,7)
               cIdKonto:=FINMAT->idkonto
            elseif "IDKONT2"==padr(trfp->IdKonto,7)
               cIdKonto:=FINMAT->idkonto2
            else
               cIdKonto:=trfp->Idkonto
            endif

            IF lPrvoDzok
              cPomFK777:=TRIM(gFunKon1)
              cIdkonto:=STRTRAN(cidkonto,"F1",&cPomFK777)
              cPomFK777:=TRIM(gFunKon2)
              cIdkonto:=STRTRAN(cidkonto,"F2",&cPomFK777)

              cIdkonto:=STRTRAN(cidkonto,"A1",right(trim(finmat->idkonto),1))
              cIdkonto:=STRTRAN(cidkonto,"A2",right(trim(finmat->idkonto),2))
              cIdkonto:=STRTRAN(cidkonto,"B1",right(trim(finmat->idkonto2),1))
              cIdkonto:=STRTRAN(cidkonto,"B2",right(trim(finmat->idkonto2),2))
            ENDIF

            if (cIdkonto='KK')  .or.  (cIdkonto='KP')  .or. (cIdkonto='KO')
              if right(trim(cIdkonto),3)=="(2)"  // gonjaj idkonto2
                 select koncij; nRecno:=recno(); seek FinMat->idkonto2
                 cIdkonto:=strtran(cIdkonto,"(2)","")
                 cIdkonto:=koncij->(&cIdkonto)
                 select koncij; go nRecNo  // vrati se na glavni konto
                 select fpripr // finansije, priprema
              elseif right(trim(cIdkonto),3)=="(1)"  // gonjaj idkonto
                 select koncij; nRecNo:=recno(); seek FinMat->idkonto
                 cIdkonto:=strtran(cIdkonto,"(1)","")
                 cIdkonto:=koncij->(&cIdkonto)
                 select koncij; go nRecNo  // vrati se na glavni konto
                 select fpripr // finansije, priprema
              else
                 cIdkonto:=koncij->(&cIdkonto)
              endif

            elseif !lPrvoDzok
              cPomFK777:=TRIM(gFunKon1)
              cIdkonto:=STRTRAN(cidkonto,"F1",&cPomFK777)
              cPomFK777:=TRIM(gFunKon2)
              cIdkonto:=STRTRAN(cidkonto,"F2",&cPomFK777)

              cIdkonto:=STRTRAN(cidkonto,"A1",right(trim(finmat->idkonto),1))
              cIdkonto:=STRTRAN(cidkonto,"A2",right(trim(finmat->idkonto),2))
              cIdkonto:=STRTRAN(cidkonto,"B1",right(trim(finmat->idkonto2),1))
              cIdkonto:=STRTRAN(cidkonto,"B2",right(trim(finmat->idkonto2),2))
            endif

            cIdkonto:=STRTRAN(cidkonto,"?1",trim(ckonto1))
            cIdkonto:=STRTRAN(cidkonto,"?2",trim(ckonto2))
            cIdkonto:=STRTRAN(cidkonto,"?3",trim(ckonto3))

            cIdkonto:=padr(cidkonto,7)

            cBrDok:=space(8)
            dDatDok:=FINMAT->datdok


            if trfp->Dokument=="R"  // radni nalog
                   cBrDok:=FINMAT->idZaduz2
            elseif trfp->Dokument=="1"
                   cBrDok:=FINMAT->brdok
            elseif trfp->Dokument=="2"
                   cBrDok:=FINMAT->brfaktp
                   dDatDok:=FINMAT->datfaktp
            elseif trfp->Dokument=="3"
                   dDatDok:=dDatNal
            endif

            cIdPartner:=space(6)
            if trfp->Partner=="1"  //  stavi Partnera
                    cidpartner:=FINMAT->IdPartner
            elseif trfp->Partner=="2"   // stavi  Lice koje se zaduzuje
                    cIdpartner:=FINMAT->IdZaduz
            elseif trfp->Partner=="3"   // stavi  Lice koje se zaduz2
                    cIdpartner:=FINMAT->IdZaduz2
            elseif trfp->Partner=="A"
                    cIdpartner:=cPartner1
                    IF !EMPTY(dDatFakt1); dDatDok:=dDatFakt1; ENDIF
                    IF !EMPTY( cBrFakt1); cBrDok := cBrFakt1; ENDIF
            elseif trfp->Partner=="B"
                    cIdpartner:=cPartner2
                    IF !EMPTY(dDatFakt2); dDatDok:=dDatFakt2; ENDIF
                    IF !EMPTY( cBrFakt2); cBrDok := cBrFakt2; ENDIF
            elseif trfp->Partner=="C"
                    cIdpartner:=cPartner3
                    IF !EMPTY(dDatFakt3); dDatDok:=dDatFakt3; ENDIF
                    IF !EMPTY( cBrFakt3); cBrDok := cBrFakt3; ENDIF
            elseif trfp->Partner=="D"
                    cIdpartner:=cPartner4
                    IF !EMPTY(dDatFakt4); dDatDok:=dDatFakt4; ENDIF
                    IF !EMPTY( cBrFakt4); cBrDok := cBrFakt4; ENDIF
            elseif trfp->Partner=="E"
                    cIdpartner:=cPartner5
                    IF !EMPTY(dDatFakt5); dDatDok:=dDatFakt5; ENDIF
                    IF !EMPTY( cBrFakt5); cBrDok := cBrFakt5; ENDIF
            elseif trfp->Partner=="O"   // stavi  banku
                    cIdpartner:=KONCIJ->banka
            endif

            fExist:=.f.
            seek FINMAT->IdFirma+cidvn+cBrNalF
            if found()
             fExist:=.f.
             do while !EOF() .and. FINMAT->idfirma+cidvn+cBrNalF==IdFirma+idvn+BrNal
               if IdKonto==cIdKonto .and. IdPartner==cIdPartner .and.;
                  trfp->d_p==d_p  .and. idtipdok==FINMAT->idvd .and.;
                  padr(brdok,10)==padr(cBrDok,10) .and. datdok==dDatDok .and.;
                  IF(lPoRj,TRIM(idrj)==TRIM(cIdRj),.t.)
                  // provjeriti da li se vec nalazi stavka koju dodajemo
                 fExist:=.t.
                 exit
               endif
               skip
             enddo
             if !fExist
               SEEK FINMAT->idfirma+cIdVN+cBrNalF+"ZZZZ"
               SKIP -1
               IF idfirma+idvn+brnal==FINMAT->idfirma+cIdVN+cBrNalF
                 nRbr:=val(Rbr)+1
               ELSE
                 nRbr:=1
               ENDIF
               APPEND BLANK
             endif
            else
               SEEK FINMAT->idfirma+cIdVN+cBrNalF+"ZZZZ"
               SKIP -1
               IF idfirma+idvn+brnal==FINMAT->idfirma+cIdVN+cBrNalF
                 nRbr:=val(Rbr)+1
               ELSE
                 nRbr:=1
               ENDIF
               APPEND BLANK
            endif

            replace iznosDEM with iznosDEM+nIz,;
                    iznosBHD with iznosBHD+nIz2,;
                    idKonto  with cIdKonto,;
                    IdPartner  with cIdPartner,;
                    D_P      with trfp->d_P,;
                    idFirma  with FINMAT->idfirma,;
                    IdVN     with cidvn,;
                    BrNal    with cBrNalF,;
                    IdTipDok with FINMAT->IdVD,;
                    BrDok    with cBrDok,;
                    DatDok   with dDatDok,;
                    opis     with trfp->naz

            if LEFT(RIGHT(trfp->naz,2),1)$".;"  // nacin zaokruzenja
                replace opis with LEFT(trfp->naz,LEN(trfp->naz)-2)
            endif


            if "#V#" $  trfp->naz  // stavi datum valutiranja
                replace datval with ddatVal, opis with strtran(trfp->naz,"#V#","")
                IF lVrsteP
                  replace k4 with cIdVrsteP
                ENDIF
            endif

            // kontiraj radnu jedinicu
            if "#RJ1#" $  trfp->naz  // stavi datum valutiranja
               replace IdRJ with cRj1, opis with strtran(trfp->naz,"#RJ1#","")
            endif
            if "#RJ2#" $  trfp->naz  // stavi datum valutiranja
               replace IdRJ with cRj2, opis with strtran(trfp->naz,"#RJ2#","")
            endif
            IF lPoRj
               replace IdRJ with cIdRj
            ENDIF

            if !fExist
              replace Rbr  with str(nRbr,4)
            endif

           endif // nIz <>0

           select trfp
           skip
         enddo // trfp->id==cIDVD


         if gAMat<>"0"     // za materijalni nalog

           select  trmp; HSEEK cIdVD
           do while !empty(cBrNalM) .and. trmp->id==cIdVD .and. !eof()

             cIznos:=naz

             // mpripr
             select  mpripr

              cIdPartner:=""
              if trmp->Partner=="1"  //  stavi Partnera
                      cIdpartner:=FINMAT->IdPartner
              endif

              cIdzaduz:=""
              if trmp->Zaduz=="1"
                     cIdKonto:=FINMAT->idkonto
                     cIdZaduz:=FINMAT->idzaduz
              elseif trmp->Zaduz=="2"
                     cIdKonto:=FINMAT->idkonto2
                     cIdZaduz:=FINMAT->idzaduz2
              endif

              cBrDok:=""
              dDatDok:=FINMAT->Datdok
              if trmp->dokument=="1"
                     cBrDok:=FINMAT->Brdok
              elseif trmp->dokument=="2"
                     cBrDok:=FINMAT->BrFaktP
                     dDatDok:=FINMAT->DatFaktP
              endif
             nKol:=FINMAT->Kolicina
             nIz:=FINMAT->&cIznos

             if trim(cIznos)=="GKV"
                  nKol:=finmat->Gkol
             elseif  trim(cIznos)=="GKV2"
                  nKol:=finmat->GKol2
             elseif  trim(cIznos)=="MARZA2"
                  nKol:=finmat->(Gkol+GKol2)
             elseif  trim(cIznos)=="RABATV"
                  nKol:=0
             endif

             if trmp->znak=="-"
               nIz:= -nIz
               nKol:= -nKol
             endif

             nIz:=round(nIz,2)

             if nIz==0;  select trmp; skip; loop; endif
             go bottom
             nRbr2:=val(rbr)+1
             append blank

             replace IdFirma   with FINMAT->IdFirma,;
                     BrNal     with cBrNalM,;
                     IdVN      with cIdVN,;
                     IdPartner with cIdPartner,;
                     IdRoba    with FINMAT->idroba,;
                     Kolicina  with nKol,;
                     IdKonto   with cIdKonto,;
                     IdZaduz   with cIdZaduz,;
                     IdTipDok  with FINMAT->IdVD,;
                     BrDok     with cBrDok,;
                     DatDok    with dDatDok,;
                     Rbr       with str(nRbr2,4),;
                     IdPartner with cIdPartner,;
                     Iznos    with nIz,;
                     Iznos2   with round(nIz*Kurs(FINMAT->DatKurs),2),;
                     DatKurs  with FINMAT->DatKurs,;
                     Cijena   with iif(nKol<>0,Iznos/nKol,0),;
                     U_I      with trmp->u_i,;
                     D_P      with trmp->u_i


             select trmp
             skip
           enddo // trmp->id = cIDVD

         endif    // za materijalni nalog


  select FINMAT
  skip
 enddo

enddo

SKIP -1      // zbog FINMAT->idfirma u donjem seek-u

if lAFin .or. lAFin2

select fpripr; go top
seek FINMAT->idfirma+cIdVN+cBrNalF
if found()
	do while !eof() .and. IDFIRMA+IDVN+BRNAL==FINMAT->idfirma+cIdVN+cBrNalF
		cPom:=right(opis,1)
		// na desnu stranu opisa stavim npr "ZADUZ MAGACIN          0"
		// onda ce izvrsiti zaokruzenje na 0 decimalnih mjesta
		if cPom $ "0125"
			nLen:=len(trim(opis))
			replace opis with left(trim(opis),nLen-1)
			if cPom="5"  // zaokruzenje na 0.5 DEM
				replace iznosbhd with round2(iznosbhd,2)
				replace iznosdem with round2(iznosdem,2)
			else
				replace iznosbhd with round(iznosbhd,MIN(val(cPom),2))
				replace iznosdem with round(iznosdem,MIN(val(cPom),2))
			endif
		endif // cpom
		skip
	enddo //fpripr
endif

endif // lafin , lafin2

MsgC()

closeret
return
*}





/*! \fn Konto(nBroj,cDef,cTekst)
 *  \param nBroj - koju varijablu punimo (1-ckonto1,2-ckonto2,3-ckonto3)
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi
 *  \brief Edit proizvoljnog teksta u varijablu ckonto1,ckonto2 ili ckonto3 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

function Konto(nBroj,cDef,cTekst)
*{
private GetList:={}

if (nBroj==1 .and. len(ckonto1)<>0) .or. ;
   (nBroj==2 .and. len(ckonto2)<>0) .or. ;
   (nBroj==3 .and. len(ckonto3)<>0)
  return 0
endif

  Box(,2,60)
    set cursor on
    @ m_x+1,m_y+2 SAY cTekst
    if nBroj==1
      ckonto1:=cdef
     @ row(),col()+1 GET cKonto1
    elseif nBroj==2
      ckonto2:=cdef
     @ row(),col()+1 GET cKonto2
    else
      ckonto3:=cdef
     @ row(),col()+1 GET cKonto3
    endif
    read
  BoxC()

return 0
*}





/*! \fn RJ(nBroj,cDef,cTekst)
 *  \param nBroj - koju varijablu punimo (1-cRj1,2-cRj2)
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi
 *  \brief Edit proizvoljnog teksta u varijablu cRj1 ili cRj2 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

function RJ(nBroj,cDef,cTekst)
*{
private GetList:={}

if (nBroj==1 .and. len(cRJ1)<>0) .or. (nBroj==2 .and. len(cRj2)<>0)
  return 0
endif

  Box(,2,60)
    set cursor on
    @ m_x+1,m_y+2 SAY cTekst
    if nBroj==1
      cRJ1:=cdef
     @ row(),col()+1 GET cRj1
    elseif nBroj==2
      cRJ2:=cdef
     @ row(),col()+1 GET cRj2
    endif
    read
  BoxC()

return 0
*}





/*! \fn DatVal()
 *  \brief Odredjivanje datuma valute - varijabla dDatVal
 */

function DatVal()
*{
local nUvecaj:=15
private GetList:={}

// uzmi datval iz doks2
if file(KUMPATH+"DOKS2.DBF")
   PushWa()
   O_DOKS2
   seek finmat->(idfirma+idvd+brdok)
   dDatVal:=DatVal
   IF lVrsteP
     cIdVrsteP:=k2
   ENDIF
   PopWa()
endif

if empty(dDatVal)  // nisam nasao u datumu valuta pokupi rucno !

  Box(,3+IF(lVrsteP.and.EMPTY(cIdVrsteP),1,0),60)
    set cursor on
    @ m_x+1,m_y+2 SAY "Datum dokumenta: " ; ??  finmat->datfaktp
    @ m_x+2,m_y+2 SAY "Uvecaj dana    :" GET nUvecaj pict "99"
    @ m_x+3,m_y+2 SAY "Valuta         :" GET dDatVal when {|| dDatVal:=finmat->datfaktp+nUvecaj,.t.}
    IF lVrsteP .and. EMPTY(cIdVrsteP)
      @ m_x+4,m_y+2 SAY "Sifra vrste placanja:" GET cIdVrsteP PICT "@!"
    ENDIF
    read
  BoxC()
  if file(KUMPATH+"DOKS2.DBF")
     PushWa()
     O_DOKS2
     seek finmat->(idfirma+idvd+brdok)
     if !found()  // ovo se moze desiti ako je neko mjenjao dokumenta u KALK
                  // ako je
        append blank
        replace idfirma with finmat->idfirma,;
                idvd with finmat->idvd,;
                brdok with finmat->brdok
     endif
     replace datval with dDatVal
     IF lVrsteP
       replace k2 with cIdVrsteP
     ENDIF
     PopWa()
  endif

endif

return 0
*}





/*! \fn Partner(nBroj,cDef,cTekst,lFaktura,dp)
 *  \param nBroj - 1 znaci da se sifrom partnera puni varijabla cPartner1
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi u varijablu cPartner1
 *  \param lFaktura - .t. i ako je npr.nBroj==1 filuju se i varijable cBrFakt1 i dDatFakt1 koje cuvaju broj i datum fakture, .f. - ne edituju se ove varijable sto je i default vrijednost
 *  \param dp - duzina sifre partnera, ako se ne navede default vrijednost=6
 *  \brief Edit sifre partnera u varijablu cPartner1...ili...cPartner5 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

function Partner(nBroj,cDef,cTekst,lFaktura,dp)
*{
IF lFaktura==NIL; lFaktura:=.f.; ENDIF
IF dp==NIL; dp:=6; ENDIF
IF cDef==NIL; cDef:=""; ENDIF
IF cTekst==NIL; cTekst:="Sifra partnera "+ALLTRIM(STR(nBroj)); ENDIF
private GetList:={}

if (nBroj==1 .and. len(cPartner1)<>0) .or. ;
   (nBroj==2 .and. len(cPartner2)<>0) .or. ;
   (nBroj==3 .and. len(cPartner3)<>0) .or. ;
   (nBroj==4 .and. len(cPartner4)<>0) .or. ;
   (nBroj==5 .and. len(cPartner5)<>0)
  return 0
endif

  Box(,2+IF(lFaktura,2,0),60)
    set cursor on
    @ m_x+1,m_y+2 SAY cTekst
    if nBroj==1
      cPartner1:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner1
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt1
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt1
      ENDIF
    elseif nBroj==2
      cPartner2:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner2
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt2
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt2
      ENDIF
    elseif nBroj==3
      cPartner3:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner3
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt3
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt3
      ENDIF
    elseif nBroj==4
      cPartner4:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner4
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt4
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt4
      ENDIF
    else
      cPartner5:=padr(cdef,dp)
      @ row(),col()+1 GET cPartner5
      IF lFaktura
        @ m_x+2,m_y+2 SAY "Broj fakture " GET cBrFakt5
        @ m_x+3,m_y+2 SAY "Datum fakture" GET dDatFakt5
      ENDIF
    endif
    read
  BoxC()

return 0
*}





/*! \fn SetZaDoks()
 *  \brief Setuje nnv,nvpv,nmpv za doks.dbf
 */

function SetZaDoks()
*{
if mu_i="1"
  nNV+=nc*(kolicina-gkolicina-gkolicin2); nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
elseif mu_i="3"
  nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
elseif mu_i=="5"
 nNV-=nc*(kolicina); nVPV-=vpc*(kolicina); nRabat+=vpc*rabatv/100*kolicina
endif

if pu_i=="1"
 if empty(mu_i)
   nNV+=nc*kolicina
 endif
 nMPV+=mpcsapp*kolicina
elseif pu_i=="5"
 if empty(mu_i); nNV-=nc*kolicina; endif
 nMPV-=mpcsapp*kolicina
elseif pu_i=="I"
  nMPV-=mpcsapp*gkolicin2; nNV-=nc*gkolicin2
elseif pu_i=="3"
  nMPV+=mpcsapp*kolicina
endif

return
*}





/*! \fn IspitajRezim()
 *  \brief Ako se radi o privremenom rezimu obrade KALK dokumenata setuju se vrijednosti parametara gCijene i gMetodaNC na vrijednosti u dvoclanom nizu aRezim
 */

function IspitajRezim()
*{
  IF !EMPTY(aRezim)
//    Msg("aRezim[1]='"+aRezim[1]+"', aRezim[2]='"+aRezim[2]+"'")
    gCijene   = aRezim[1]
    gMetodaNC = aRezim[2]
  ENDIF
return
*}




/*! \fn RekapK()
 *  \param fstara - .f. znaci poziv iz tabele pripreme, .t. radi se o azuriranoj kalkulaciji pa se prvo getuje broj dokumenta (cIdFirma,cIdVD,cBrdok)
 *  \brief Pravi rekapitulaciju kalkulacija a ako je ulazni parametar fstara==.t. poziva se i kontiranje dokumenta
 */

function RekapK()
*{
parameters fstara

local fprvi
local n1:=n2:=n3:=n4:=n5:=n6:=n7:=n8:=n9:=na:=nb:=0
local nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=nTotb:=0
local nCol1:=nCol2:=nCol3:=0

private aPorezi
aPorezi:={}

if pcount()==0; fstara:=.f.; endif

lVoSaTa := (gVodiSamoTarife=="D")

fprvi:=.t.  // prvi prolaz
do while  .t.

O_FINMAT
O_KONTO
O_PARTN
O_TDOK
O_ROBA
O_TARIFA
if fstara

#ifdef CAX
 select (F_PRIPR); use
#endif
 O_SKALK   // alias pripr
else
 O_PRIPR
endif

select FINMAT; zap
select PRIPR; set order to 1  // idfirma+brdok+rbr

if fprvi
 cIdFirma:=IdFirma;cIdVD:=IdVD;cBrdok:=brdok
 if empty(cidfirma)
   cIdFirma:=gFirma
 endif

 fprvi:=.f.
endif

if fstara

 Box("",1,50)
  set cursor on
  @ m_x+1,m_y+2 SAY "Dokument broj:"
  if gNW $ "DX"
   @ m_x+1,col()+2  SAY cIdFirma
  else
   @ m_x+1,col()+2 GET cIdFirma
  endif
  @ m_x+1,col()+1 SAY "-" GET cIdVD
  @ m_x+1,col()+1 SAY "-" GET cBrDok
  read; ESC_BCR
 BoxC()
 HSEEK cIdFirma+cIdVD+cBrDok
else
  go top
  cIdFirma:=IdFirma;cIdVD:=IdVD;cBrdok:=brdok
endif

EOF CRET

if fstara
  // - info o izabranom dokumentu -
  Box("#DOKUMENT "+cIdFirma+"-"+cIdVd+"-"+cBrDok,7,77)
   cDalje:="D"
   SELECT PARTN; HSEEK PRIPR->IDPARTNER
   SELECT KONTO; HSEEK PRIPR->MKONTO; cPom:=naz
   SELECT KONTO; HSEEK PRIPR->PKONTO
   SELECT PRIPR
   @ m_x+2, m_y+2 SAY "DATUM------------>"             COLOR "W+/B"
   @ m_x+2, col()+1 SAY DTOC(DATDOK)                   COLOR "N/W"
   @ m_x+3, m_y+2 SAY "PARTNER---------->"             COLOR "W+/B"
   @ m_x+3, col()+1 SAY IDPARTNER+"-"+PARTN->naz       COLOR "N/W"
   @ m_x+4, m_y+2 SAY "KONTO MAGACINA--->"             COLOR "W+/B"
   @ m_x+4, col()+1 SAY MKONTO+"-"+PADR(cPom,49)       COLOR "N/W"
   @ m_x+5, m_y+2 SAY "KONTO PRODAVNICE->"             COLOR "W+/B"
   @ m_x+5, col()+1 SAY PKONTO+"-"+PADR(KONTO->naz,49) COLOR "N/W"
   @ m_x+7, m_y+2 SAY "Zelite li kontirati dokument? (D/N)" GET cDalje VALID cDalje$"DN" PICT "@!"
   READ
  BoxC()
  IF LASTKEY()==K_ESC .or. cDalje<>"D"
    LOOP
  ENDIF
endif

if cidvd=="24"
 START PRINT CRET
endif

nStr:=0

 nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=nTotb:=0
 do whilesc !eof() .and. cIdFirma==idfirma .and. cidvd==idvd
   cBrDok:=BrDok
   cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
   dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2
   if cidvd=="24" .and. (prow()==0 .or. prow()>55)
     if prow()-gPStranica>55; FF ;endif
     P_COND
     ?? "KALK: REKAPITULACIJA NA DAN:",date()
     @ prow(),125 SAY "Str:"+str(++nStr,3)
   endif

   if cidvd=="24"
    ?
    ? "KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
    select PARTN; HSEEK cIdPartner
   endif

   if cIDVD == "24"
    ?  "KUPAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP
   endif

   select KONTO; HSEEK cIdKonto

   HSEEK cIdKonto2
   select PRIPR

   m:=""
   if cidvd == "24"
     m:="---- -------------- -------------- -------------- -------------- -------------- ---------- ---------- ---------- ---------- ----------"
     P_COND2
     ? m
     ? "*R. * "+left(c24T1,12)+" * "+left(c24T2,12)+" * "+left(c24T3,12)+" * "+left(c24T4,12)+" * "+left(c24T5,12)+" *   FV     * POREZ    *  POREZ   *   FV     * PRIHOD  *"
     ? "*Br.* "+left(c24T6,12)+" * "+left(c24T7,12)+" * "+space(12)+" * "+space(12)+" * "+space(12)+" * BEZ POR  *   %      *          * SA POR   *         *"
     ? m
   endif

   IF lVoSaTa
     cIdd:=idpartner+idkonto+idkonto2
   ELSE
     cIdd:=idpartner+brfaktp+idkonto+idkonto2
   ENDIF
   do whilesc !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

     if gmagacin<>"1" .and.;
        ( !lVoSaTa .and. idpartner+brfaktp+idkonto+idkonto2<>cidd .or.;
          lVoSaTa .and. idpartner+idkonto+idkonto2<>cidd )
      set device to screen
      if ! ( (idvd $ "16#80" )  .and. !empty(idkonto2)  )
       if !idvd $ "24"
        Beep(2)
        Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
       endif
      endif
      if cidvd=="24"
       set device to printer
      endif
     endif

     // iznosi troskova koji se izracunavaju u KTroskovi()
     Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2

        nFV:=FCj*Kolicina
        if gKalo=="1"
          SKol:=Kolicina-GKolicina-GKolicin2
        else
          SKol:=Kolicina
        endif

        if cidvd=="24" .and. prow()>62
		FF
		@ prow(),125 SAY "Str:"+str(++nStr,3)
	endif

        select ROBA; HSEEK PRIPR->IdRoba
        select TARIFA; HSEEK PRIPR->idtarifa
        select PRIPR

	// if !glPoreziLegacy
		Tarifa(pkonto,idroba,@aPorezi)
	// endif

        KTroskovi()

        if cidvd=="24"
         @ prow()+1,0 SAY  Rbr PICTURE "999"
        endif

        if cidvd=="24"
         nCol1:=pcol()+6
         @ prow(),pcol()+6 SAY n1:=prevoz    pict picdem
         @ prow(),pcol()+5 SAY n2:=banktr    pict picdem
         @ prow(),pcol()+5 SAY n3:=spedtr    pict picdem
         @ prow(),pcol()+5 SAY n4:=cardaz    pict picdem
         @ prow(),pcol()+5 SAY n5:=zavtr     pict picdem
         @ prow(),pcol()+1 SAY n6:=fcj       pict picdem
         @ prow(),pcol()+1 SAY tarifa->vpp   pict picproc
         @ prow(),pcol()+1 SAY n7:=nc-fcj    pict picdem
         @ prow(),pcol()+1 SAY n8:=nc        pict picdem
         @ prow(),pcol()+1 SAY n9:=marza     pict picdem
         @ prow()+1,nCol1  SAY nA:=mpc       pict picdem
         @ prow(),pcol()+5 SAY nB:=mpcsapp pict picdem
         nTot1+=n1; nTot2+=n2; nTot3+=n3; nTot4+=n4
         nTot5+=n5; nTot6+=n6; nTot7+=n7; nTot8+=n8
         nTot9+=n9; nTotA+=na; nTotB+=nB
        endif

        VtPorezi()
	
	aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

        select FINMAT
        append blank
	
        replace IdFirma   with PRIPR->IdFirma,;
                IdKonto   with PRIPR->IdKonto,;
                IdKonto2  with PRIPR->IdKonto2,;
                IdTarifa  with PRIPR->IdTarifa,;
                IdPartner with PRIPR->IdPartner,;
                IdZaduz   with PRIPR->IdZaduz,;
                IdZaduz2  with PRIPR->IdZaduz2,;
                BrFaktP   with PRIPR->BrFaktP,;
                DatFaktP  with PRIPR->DatFaktP,;
                IdVD      with PRIPR->IdVD,;
                BrDok     with PRIPR->BrDok,;
                DatDok    with PRIPR->DatDok,;
                DatKurs   with PRIPR->DatKurs,;
                GKV       with round(PRIPR->(GKolicina*FCJ2),gZaokr),;   // vrijednost transp.kala
                GKV2      with round(PRIPR->(GKolicin2*FCJ2),gZaokr),;   // vrijednost ostalog kala
                Prevoz    with round(PRIPR->(nPrevoz*SKol),gZaokr) ,;
                CarDaz    with round(PRIPR->(nCarDaz*SKol),gZaokr) ,;
                BankTr    with round(PRIPR->(nBankTr*SKol),gZaokr) ,;
                SpedTr    with round(PRIPR->(nSpedTr*SKol),gZaokr) ,;
                ZavTr     with round(PRIPR->(nZavTr*SKol),gZaokr)  ,;
                NV        with round(PRIPR->(NC*(Kolicina-GKolicina-GKolicin2)),gZaokr)  ,;
                Marza     with round(PRIPR->(nMarza*(Kolicina-GKolicina-GKolicin2)),gZaokr)  ,;           // marza se ostvaruje nad stvarnom kolicinom
                VPV       with round(PRIPR->(VPC*(Kolicina-GKolicina-GKolicin2)),gZaokr),;         // vpv se formira nad stvarnom kolicinom
                RABATV    with round(PRIPR->(RabatV/100*VPC*Kolicina),gZaokr),;
                POREZV    with round(PRIPR->(TARIFA->VPP/100*(iif(nMarza<0,0,nMarza)*Kolicina)),gZaokr),;
                VPVSAP    with round(PRIPR->(VPCSaP*Kolicina),gZaokr),;
                Marza2    with round(PRIPR->(nMarza2*(Kolicina-GKolicina-GKolicin2)),gZaokr),;
                MPV       with round(iif(pripr->idvd $ "14#94",Pripr->(VPC*(1-RabatV/100)*MPC/100*Kolicina),PRIPR->(MPC*(Kolicina-GKolicina-GKolicin2))),gZaokr) ,;
                Porez     with round(PRIPR->(aIPor[1]*(Kolicina-GKolicina-GKolicin2)),gZaokr)  ,;
                Porez2    with round(PRIPR->(aIPor[2]*(Kolicina-GKolicina-GKolicin2)),gZaokr)  ,;
                MPVSaPP   with round(PRIPR->(MPCSaPP*(Kolicina-GKolicina-GKolicin2)),gZaokr),;
                idroba    with PRIPR->idroba,;
                Kolicina  with PRIPR->(Kolicina-GKolicina-GKolicin2)


          if glUgost
            REPLACE prucmp WITH round(PRIPR->(aIPor[2]*(Kolicina-GKolicina-GKolicin2)),gZaokr)
            REPLACE porpot WITH round(PRIPR->(aIPor[3]*(Kolicina-GKolicina-GKolicin2)),gZaokr)
          endif

          if !(pripr->IdVD $ "IM#IP")
                // bug opresa 19.01.2001
                // kod dokumenta IM FCj sadrzi ustvari knjiznu vrijednost
             replace   FV        with round(nFV,gZaokr)  ,;
                       Rabat     with round(PRIPR->(nFV*Rabat/100),gZaokr)
          endif

          if  pripr->mu_i $ "13" .and. roba->tip $ "VK" // ulaz u magacin, vt
                replace Porez     with round(PRIPR->(TARIFA->OPP/100*(nc+nMarza)*(Kolicina-GKolicina-GKolicin2)),gZaokr)
          endif
          if  pripr->mu_i $ "13" .and. roba->tip="X" // ulaz u magacin, vt
                replace Porez     with round(PRIPR->(mpcsapp/(1+tarifa->opp/100)*TARIFA->OPP/100*(Kolicina-GKolicina-GKolicin2)),gZaokr)
          endif

          if  idvd $ "11#12#13#14#96#94" // porez vt koji se realizuje iz magacina
                                   // samo ako je roba tip K
               replace porvt with  round(pripr->(vpc/(1+_opp)*_opp*kolicina),gZaokr)
          endif

          // verzija 03.24
          if  idvd == "IP"
               replace  GKV2  with round(PRIPR->((Gkolicina-Kolicina)*MPcSAPP),gZaokr),;
                        GKol2 with Pripr->(Gkolicina-Kolicina)
          endif

          if  idvd $ "14#94"
               if roba->tip<>"X"  // kod nafte ne diraj MPVSAPP
                 replace  MPVSaPP   with  Pripr->( VPC*(1-RabatV/100)*(Kolicina-GKolicina-GKolicin2) )
               endif
               if  gVarVP=="2"  // unazad VPC - preracunata stopa
                  replace POREZV with round(TARIFA->VPP/100/(1+tarifa->vpp/100)*iif(nMarza<0,0,nMarza)*Kolicina,gZaokr)
               endif
          endif
          if  !empty(pripr->mu_i)
               select tarifa; hseek roba->idtarifa; select finmat
               replace UPOREZV with  round(pripr->(nMarza*kolicina*TARIFA->VPP/100/(1+TARIFA->VPP/100)),gZaokr)
               select tarifa; hseek roba->idtarifa; select finmat
          endif

          if gKalo=="2" .and.  pripr->idvd $ "10#81"  // kalo ima vrijednost po NC
               replace GKV   with round(PRIPR->(GKolicina*NC),gZaokr),;   // vrijednost transp.kala
                       GKV2  with round(PRIPR->(GKolicin2*NC),gZaokr),;   // vrijednost ostalog kala
                       GKol  with round(PRIPR->GKolicina,gZaokr),;
                       GKol2 with round(PRIPR->GKolicin2,gZaokr) ,;
                       POREZV with round(nMarza*pripr->(GKolicina+Gkolicin2),gZaokr) // negativna marza za kalo
          endif


          if pripr->idvd=="24"
            replace mpv     with pripr->mpc,;
                    mpvsapp with pripr->mpcsapp
          endif
          if PRIPR->IDVD $ "18#19"
                replace Kolicina with 0
          endif
          select ROBA  // azuriraj NC,VPC,MPC

          HSEEK PRIPR->idroba
          if found()
             if PRIPR->IdVD $ "10"  // azuriranje NC za ulaz u magacin
               replace NC with PRIPR->NC
             endif
          endif

         select PRIPR
         skip
   enddo // brdok

   if cidvd=="24"
    ? m
   else
     // problemi kompatibilnosti - kija
     if fStara
       exit
     endif
   endif

 enddo // idfirma,idvd
 if cidvd=="24" .and. prow()>60; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif

 if cidvd=="24"
  ?
  ? m
  @ prow()+1,0      SAY  "Ukup."+cIdVD+":"
 endif

 if cidvd=="24"
  @ prow(),nCol1    SAY  nTot1         picture   picdem
  @ prow(),pcol()+5 SAY  nTot2         picture   picdem
  @ prow(),pcol()+5 SAY  nTot3         picture   picdem
  @ prow(),pcol()+5 SAY  nTot4         picture   picdem
  @ prow(),pcol()+5 SAY  nTot5         picture   picdem
  @ prow(),pcol()+1 SAY  nTot6         picture   picdem
  @ prow(),pcol()+1 SAY  space(len(picproc))
  @ prow(),pcol()+1  SAY  nTot7        picture   picdem
  @ prow(),pcol()+1  SAY  nTot8        picture   picdem
  @ prow(),pcol()+1  SAY  nTot9        picture   picdem
  @ prow()+1,nCol1   SAY  nTota         picture   picdem
  @ prow(),pcol()+5  SAY  nTotb         picture   picdem
 endif

 if cidvd=="24"
  ? m
 endif

if cidvd=="24"
 ?
endif

if cidvd=="24"
 END PRINT
endif

if !fstara
	exit
else
	cIdFirma:=idfirma
	cidvd:=idvd
	cBrdok:=brdok
	close all
	Kontnal(.f.)
endif

enddo // do while .t.

if fstara
	select pripr
	use
endif

closeret
return
*}

