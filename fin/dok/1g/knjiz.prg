#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/dok/1g/knjiz.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.19 $
 * $Log: knjiz.prg,v $
 * Revision 1.19  2004/05/27 09:27:10  sasavranic
 * Koristenje zajednickog sifranika valuta
 *
 * Revision 1.18  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 * Revision 1.17  2003/04/12 06:45:40  mirsad
 * ispravka: gBrojac sada je PUBLIC varijabla
 *
 * Revision 1.16  2003/03/29 02:28:31  mirsad
 * ispravka sistema pamcenja tekuce RJ pri unosu naloga: umjesto FMK.INI za ovo od sada koristimo PARAMS.DBF parametarski sistem
 *
 * Revision 1.15  2003/03/16 10:07:50  ernad
 * RJ u tabeli prireme
 *
 * Revision 1.14  2003/01/10 00:25:43  ernad
 *
 *
 * - popravka make systema
 * make zip ... \\*.chs -> \\\*.chs
 * ispravka std.ch ReadModal -> ReadModalSc
 * uvoenje keyb/get.prg funkcija
 *
 * Revision 1.13  2003/01/08 03:11:45  mirsad
 * specificnosti za rama glas - pogonsko
 *
 * Revision 1.12  2002/11/21 12:13:52  sasa
 * korekcije koda
 *
 * Revision 1.11  2002/11/20 14:17:02  sasa
 * ispravka buga, ako se radi o radnim jedinicama, ne pamti polje radne jedinice
 *
 * Revision 1.10  2002/11/17 13:14:08  sasa
 * no message
 *
 * Revision 1.8  2002/11/16 23:23:57  sasa
 * korekcija koda
 *
 * Revision 1.7  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.6  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.5  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.4  2002/06/19 13:46:23  sasa
 * no message
 *
 * Revision 1.3  2002/06/17 18:44:32  ernad
 *
 *
 * podsenje makefile sistema
 *
 * Revision 1.2  2002/06/17 09:22:39  ernad
 * headeri, podesavanje Makefile
 *
 *
 */

#define DABLAGAS lBlagAsis.and._IDVN==cBlagIDVN




/*! \file fmk/fin/dok/1g/knjiz.prg
 *  \brief Knjizenje naloga
 */

/*! \fn Knjiz()
 *  \brief Knjizenje naloga
 */

*string
static cTekucaRj:=""
*;


/* ukinuto!!!
*string FmkIni_KumPath_TekucaRj;


/*! \var *string FmkIni_KumPath_TekucaRj
 *  \brief Tekuca radna jedinica
 *  \kada Koristi se u slucaju da u Db unosimo podatke za odredjenu radnu jedinicu; da ne bi svaki puta ukucavali tu Rj ovaj parametar nam je nudi kao tekucu vrijednost.
 *
 */
*/

function Knjiz()
*{
local izbor
private opc[4]

cSecur:=SecurR(KLevel,"Priprema")
if ImaSlovo("X",cSecur)
   MsgBeep("Opcija nedostupna !")
   closeret
endif
cSecur:=SecurR(KLevel,"SGLEDAJ")
if ImaSlovo("D",cSecur)
   MsgBeep("Opcija nedostupna !")
   closeret
endif

cTekucaRj:=GetTekucaRJ()

lBlagAsis := ( IzFMKINI("BLAGAJNA","Asistent","N",PRIVPATH) == "D" )
cBlagIDVN := IzFMKINI("BLAGAJNA","SifraNaloga","66",PRIVPATH)
lAutoPomUDom := ( IzFMKINI("AutomatskoPretvaranjeIznosa","PomocnaUDomacu","N",PRIVPATH)=="D" )

private fK1:=fk2:=fk3:=fk4:=cDatVal:="N",gnLOst:=0,gPotpis:="N"

O_PARAMS
Private cSection:="1",cHistory:=" ",aHistory:={}
Params1()
RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)
RPar("dv",@cDatVal)
RPar("li",@gnLOSt)
RPar("po",@gPotpis)
select params
use

private KursLis:="1"

if gNW=="N"
 Opc[1]:="1. knjizenje naloga    "
 Opc[2]:="2. stampa naloga"
 Opc[3]:="3. azuriranje podataka"
 Opc[4]:="4. kurs "+KursLis

 Izbor:=1
 do while .t.

 h[1]:=h[2]:=h[3]:=h[4]:=""
 Izbor:=menu("knjiz",opc,Izbor,.f.)

   do case
     case Izbor==0
         EXIT
     case izbor == 1
         KnjNal()
     case izbor == 2
         StNal()
     case izbor == 3
         Azur()
     case izbor == 4
       if KursLis=="1"  // prva vrijednost
         KursLis:="2"
       else
         KursLis:="1"
       endif
       opc[4]:="4. kurs "+KursLis
   endcase

 enddo

else   // gNW=="D"
  KnjNal()
endif
closeret
return
*}

/*! \fn KnjNal()
 *  \brief Otvara pripremu za knjizenje naloga
 */
 
function KnjNal()
*{
O_Edit()
ImeKol:={ ;
          {"F.",            {|| IdFirma }, "IdFirma" } ,;
          {"VN",            {|| IdVN    }, "IdVN" } ,;
          {"Br.",           {|| BrNal   }, "BrNal" },;
          {"R.br",          {|| RBr     }, "rbr" , {|| wrbr()}, {|| vrbr()} } ,;
          {"Konto",         {|| IdKonto }, "IdKonto", {|| .t.}, {|| P_Konto(@_IdKonto),.t. } } ,;
          {"Partner",       {|| IdPartner }, "IdPartner" } ,;
          {"Br.veze ",      {|| BrDok   }, "BrDok" } ,;
          {"Datum",         {|| DatDok  }, "DatDok" } ,;
          {"D/P",           {|| D_P     }, "D_P" } ,;
          {ValDomaca(),     {|| transform(IznosBHD,FormPicL(gPicBHD,15)) }, "iznos "+ALLTRIM(ValDomaca()) } ,;
          {ValPomocna(),    {|| transform(IznosDEM,FormPicL(gPicDEM,10)) }, "iznos "+ALLTRIM(ValPomocna()) } ,;
          {"Opis",          {|| Opis      }, "OPIS" }, ;
          {"K1",            {|| k1      }, "k1" },;
          {"K2",            {|| k2      }, "k2" },;
          {"K3",            {|| K3Iz256(k3)      }, "k3" },;
          {"K4",            {|| k4      }, "k4" } ;
        }


Kol:={}
for i:=1 to 16
	AADD(Kol,i)
next

if gRj=="D"
	AADD(ImeKol, { "RJ", {|| IdRj}, "IdRj" }  )
	AADD(Kol, 17)
ENDIF


Box(,20,77)
@ m_x+18,m_y+2 SAY "<c-N>  Nove Stavke    ≥ <ENT> Ispravi stavku   ≥ <c-T> Brisi Stavku         "
@ m_x+19,m_y+2 SAY "<c-A>  Ispravka Naloga≥ <c-P> Stampa Naloga    ≥ <a-A> Azuriranje           "
@ m_x+20,m_y+2 SAY "<c-F9> Brisi pripremu ≥ <F5>  KZB, <a-F5> PrDat≥ <a-B> Blagajna,<F10> Ostalo"

ObjDbedit("PNal",20,77,{|| EdPRIPR()},"","Priprema...", , , , ,3)
BoxC()
closeret
return
*}


/*! \fn WRbr()
 *  \brief Sredjivaje rednog broja u pripremi 
 */
 
function WRbr()
scatter()
if val(_rbr)<2
  @ m_x+1,m_y+2 SAY "Dokument:" GET _idvn
  @ m_x+1,col()+2  GET _brnal
  read
endif

set order to 0
go top
do while !eof()
 replace idvn with _idvn, brnal with _brnal
 skip
enddo
set order to 1
go top
return .t.
*}


/*! \fn VRbr()
 *  \brief 
 */
 
function vrbr()
*{
return .t.
*}



/*! \fn O_Edit()
 *  \brief Otvara unos nove stavke u pripremi
 */
 
function O_Edit()
*{
IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
	O_VRSTEP
ENDIF

IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
	O_ULIMIT
ENDIF

O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG

O_PAREK
O_KONTO
O_PARTN
O_TNAL
O_TDOK

O_PRIPR


O_NALOG

if (IsRamaGlas())
	O_RNAL
endif

if gRj=="D"
	O_RJ
endif

if gTroskovi=="D"
	O_FOND
	O_FUNK
endif

select PRIPR
set order to 1
go top

// ulaz _IdFirma, _IdKonto, ...., nRBr (val(_RBr))
return
*}



/*! \fn EditPripr()
 *  \brief Ispravka stavke u pripremi
 *  \param fNovi .t. - Nova stavka, .f. - Ispravka postojece
 */
 
function EditPripr()
*{
parameters fNovi

if fNovi .and. nRbr==1
	_IdFirma:=gFirma
endif

if fNovi
	_OtvSt:=" "
endif

if ((gRj=="D") .and. fNovi)
	_idRj:=cTekucaRj
endif
	
set cursor on

if gNW=="D"
	@  m_x+1,m_y+2 SAY "Firma: "
    	?? gFirma,"-",gNFirma
    	@  m_x+3,m_y+2 SAY "NALOG: "
    	@  m_x+3,m_y+14 SAY "Vrsta:" GET _idvn VALID P_VN(@_IdVN,3,26) PICT "@!"
else
	@  m_x+1,m_y+2 SAY "Firma:" GET _idfirma VALID {|| P_Firma(@_IdFirma,1,20),_idfirma:=left(_idfirma,2),.t.}
    	@  m_x+3,m_y+2 SAY "NALOG: "
    	@  m_x+3,m_y+14 SAY "Vrsta:" GET _idvn VALID P_VN(@_IdVN,3,26)
endif
read

ESC_RETURN 0

if fNovi .and. (_idfirma<>idfirma .or. _idvn<>idvn)
	if gBrojac=="1"
     		select NALOG
		set order to 1
     		seek _idfirma+_idvn+"X"
		skip -1
     		if idfirma+idvn==_idfirma+_idvn
       			_brnal:=NovaSifra(brnal)
     		else
       			_brnal:="0001"
     		endif
    	else
     		select NALOG
     		set order to 2
     		seek _idfirma+"X"
     		skip -1
     		brnal:=padl(alltrim(str(val(brnal)+1)),4,"0")
    	endif

     	select  pripr
endif

set key K_ALT_K to DinDem()
set key K_ALT_O to KonsultOS()

@  m_x+3,m_y+55  SAY "Broj:"   get _BrNal   valid Dupli(_IdFirma,_IdVN,_BrNal) .and. !empty(_BrNal)
@  m_x+5,m_y+2  SAY "Redni broj stavke naloga:" get nRbr picture "9999"
@  m_x+7,m_y+2   SAY "DOKUMENT: "

if gNW<>"D"
	@  m_x+7,m_y+14  SAY "Tip:" get _IdTipDok valid P_TipDok(@_IdTipDok,7,26)
endif

if (IsRamaGlas())
	@  m_x+8,m_y+2   SAY "Vezni broj (racun/r.nalog):"  get _BrDok valid BrDokOK()
else
	@  m_x+8,m_y+2   SAY "Vezni broj:"  get _BrDok
endif
@  m_x+8,m_y+COL()+2  SAY "Datum:"   get  _DatDok

if cDatVal=="D"
	@  m_x+8,col()+2 SAY "Valuta" GET _DatVal
endif

@  m_x+11,m_y+2  SAY "Opis :"   get  _Opis  WHEN {|| USTipke(),.t.} VALID {|| BosTipke(),.t.} PICT "@S40"

if fk1=="D"
	@  m_x+11,col()+2 SAY "K1" GET _k1 pict "@!" 
endif

if fk2=="D"
	@  m_x+11,col()+2 SAY "K2" GET _k2 pict "@!"
endif

if fk3=="D"
	if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
       		_k3:=K3Iz256(_k3)
       		@  m_x+11,col()+2 SAY "K3" GET _k3 VALID EMPTY(_k3).or.P_ULIMIT(@_k3) pict "999"
     	else
       		@  m_x+11,col()+2 SAY "K3" GET _k3 pict "@!"
     	endif
endif

if fk4=="D"
	if IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
       		@  m_x+11,col()+2 SAY "K4" GET _k4 VALID EMPTY(_k4).or.P_VRSTEP(@_k4) pict "@!"
     	else
       		@  m_x+11,col()+2 SAY "K4" GET _k4 pict "@!"
     	endif
endif

if gRj=="D"
	@  m_x+11,col()+2 SAY "RJ" GET _idrj valid empty(_idrj) .or. P_Rj(@_idrj) PICT "@!"
	
endif

if gTroskovi=="D"
	@ m_x+12,m_y+22 SAY "      Funk." GET _Funk valid empty(_Funk) .or. P_Funk(@_Funk) pict "@!"
       	@  m_x+12,m_y+44 SAY "      Fond." GET _Fond valid empty(_Fond) .or. P_Fond(@_Fond) pict "@!"
endif

if DABLAGAS
	@ m_x+13,m_y+2  SAY "Konto  :" get _IdKonto    pict "@!" valid   Partija(@_IdKonto) .and. P_Konto(@_IdKonto,13,20,.t.) .and. BrDokOK()
else
    	@  m_x+13,m_y+2  SAY "Konto  :" get _IdKonto    pict "@!" valid   Partija(@_IdKonto) .and. P_Konto(@_IdKonto,13,20) .and. BrDokOK()
endif

@  m_x+14,m_y+2  SAY "Partner:" get _IdPartner  pict "@!" valid {|| if(empty(_idpartner),Reci(14,20,SPACE(25)),), empty(_IdPartner) .or. P_Firma(@_IdPartner,14,20)}
@  m_x+16,m_y+2  SAY "Duguje/Potrazuje (1/2):" get _D_P valid V_DP()
@ m_x+16,m_y+46  GET _IznosBHD  PICTURE "999999999999.99"
@ m_x+17,m_y+46  GET _IznosDEM  WHEN {|| DinDEM(,,"_IZNOSBHD"),.t.} VALID {|oGet| V_IznosDEM(,,"_IZNOSDEM",oGet)} PICTURE '9999999999.99'
@ m_x,m_y+50 SAY " <a-O> Otvorene stavke "

read

// ako su radne jedinice setuj var cTekucaRJ na novu vrijednost
if (gRJ=="D" .and. cTekucaRJ<>_idrj)
	cTekucaRJ:=_idrj
	SetTekucaRJ(cTekucaRJ)
endif

_IznosBHD:=round(_iznosbhd,2)
_IznosDEM:=round(_iznosdem,2)

ESC_RETURN 0
set key K_ALT_K to
set key K_ALT_O to

_k3:=K3U256(_k3)
_Rbr:=STR(nRbr,4)

return 1
*}


/*! \fn V_IznosDEM(p1, p2, cVar, oGet)
 *  \brief Sredjivanje iznosa
 *  \param p1
 *  \param p2
 *  \param cVar
 *  \param oGet
 */
 
function V_IznosDEM(p1,p2,cVar,oGet)
*{
if lAutoPomUDom .and. oGet:changed
	
	altd()
	
	_iznosdem:=oGet:unTransform()
   	DinDem(p1,p2,cVar)
endif

return .t.
*}



/*! \fn Partija(cIdKonto)
 *  \brief
 *  \param cIdKonto - oznaka konta
 */
 
function Partija(cIdKonto)
*{
if right(trim(cIdkonto),1)=="*"
	select parek
   	hseek strtran(cIdkonto,"*","")+" "
   	cIdkonto:=idkonto
   	select pripr
endif
return .t.
*}



/*! \fn V_DP()
 *  \brief Ispis duguje/potrazuje u domacoj i pomocnoj valuti 
 */
 
function V_DP()
*{
SetPos(m_x+16,m_y+30)
if _D_P=="1"
	?? "   DUGUJE"
else
  	?? "POTRAZUJE"
endif
?? " "+ValDomaca()

SetPos(m_x+17,m_y+30)
if _D_P=="1"
	?? "   DUGUJE"
else
  	?? "POTRAZUJE"
endif
?? " "+ValPomocna()

return _D_P $ "12"
*}



/*! \fn DinDem(p1,p2,cVar)
 *  \brief
 *  \param p1
 *  \param p2
 *  \param cVar
 */
function DinDem(p1,p2,cVar)
*{
local nNaz

nNaz:=Kurs(_datdok)
if cVar=="_IZNOSDEM"
    _IZNOSBHD:=_IZNOSDEM*nnaz
elseif cVar="_IZNOSBHD"
  if round(nNaz,4)==0
    _IZNOSDEM:=0
  else
    _IZNOSDEM:=_IZNOSBHD/nnaz
  endif
endif
// select(nArr)
AEVAL(GetList,{|o| o:display()})
*}


// poziva je ObjDbedit u KnjNal
// c-T  -  Brisanje stavke,  F5 - kontrola zbira za jedan nalog
// F6 -  Suma naloga, ENTER-edit stavke, c-A - ispravka naloga

/*! \fn EdPRIPR()
 *  \brief Ostale operacije u ispravki stavke
 */

function EdPRIPR()
*{
local nTr2

if Logirati(goModul:oDataBase:cName,"DOK","KNJIZ")
	lLogKnjiz:=.t.
else
	lLogKnjiz:=.f.
endif

if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
	return DE_CONT
endif

select pripr
do case

case Ch==K_ALT_F5
     if pitanje(,"Za konto u nalogu postaviti datum val. DATDOK->DATVAL","N")=="D"
        cIdKonto:=space(7)
        dDatDok:=date()
        nDana:=15
        Box(,5,60)
          @ m_x+1,m_Y+2 SAY "Promjena za konto  " GET cIdKonto
          @ m_x+3,m_Y+2 SAY "Novi datum dok " GET dDatDok
          @ m_x+5,m_Y+2 SAY "uvecati stari datdok za (dana) " GET nDana pict "99"
          read
        BoxC()
        if lastkey()<>K_ESC
          select pripr
          go top
          do while !eof()
             if idkonto==cidkonto .and. empty(datval)
                replace  datval with datdok+ndana,;
                         datdok with dDatDok
             endif
             skip
          enddo
          go top
          return DE_REFRESH
        endif
     endif
     return DE_CONT

  case Ch==K_CTRL_T
     if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
      delete
      BrisiPBaze()
      if lLogKnjiz
      		EventLog(nUser,goModul:oDataBase:cName,"DOK","KNJIZ",nil,nil,nil,nil,"","","Stavka pobrisana",Date(),Date(),"","Brisanje stavke...")		
      endif
      return DE_REFRESH
     endif
     return DE_CONT

   case Ch==K_F5 // kontrola zbira za jedan nalog

      KontrZbNal()
      return DE_REFRESH

   case Ch==K_ENTER
    Box("ist",20,75,.f.)
    Scatter()
    nRbr:=VAL(_Rbr)
    if EditPRIPR(.f.)==0
     BoxC()
     return DE_CONT
    else
     Gather()
     BrisiPBaze()
     BoxC()
     return DE_REFRESH
    endif

   case Ch==K_CTRL_A
        PushWA()
        select PRIPR
        go top
        Box("anal",20,75,.f.,"Ispravka naloga")
        nDug:=0; nPot:=0
        do while !eof()
           skip; nTR2:=RECNO(); skip-1
           Scatter()
           nRbr:=VAL(_Rbr)
           @ m_x+1,m_y+1 CLEAR to m_x+19,m_y+74
           if EditPRIPR(.f.)==0
             exit
           else
             BrisiPBaze()
           endif
           if _D_P='1'; nDug+=_IznosBHD; else; nPot+=_IznosBHD; endif
           @ m_x+19,m_y+1 SAY "ZBIR NALOGA:"
           @ m_x+19,m_y+14 SAY nDug PICTURE '9 999 999 999.99'
           @ m_x+19,m_y+35 SAY nPot PICTURE '9 999 999 999.99'
           @ m_x+19,m_y+56 SAY nDug-nPot PICTURE '9 999 999 999.99'
           inkey(10)
           select PRIPR
           Gather()
           go nTR2
         enddo
         PopWA()
         BoxC()
         return DE_REFRESH

     case Ch==K_CTRL_N  // nove stavke
	select pripr
	nDug:=0
	nPot:=0
	nPrvi:=0
        go top
        do while .not. eof() // kompletan nalog sumiram
        	if D_P='1'
			nDug+=IznosBHD
		else
			nPot+=IznosBHD
		endif
           	skip
        enddo
        go bottom
	
	Box("knjn",20,77,.f.,"Knjizenje naloga - nove stavke")
        do while .t.
           Scatter()
	   
	   if (IsRamaGlas())
	   	_idKonto:=SPACE(LEN(_idKonto))
		_idPartner:=SPACE(LEN(_idPartner))
		_brDok:=SPACE(LEN(_brDok))
	   endif
	   
           nRbr:=VAL(_Rbr)+1
           @ m_x+1,m_y+1 CLEAR to m_x+19,m_y+76
           if EditPRIPR(.t.)==0
             exit
           else
             BrisiPBaze()
           endif
           if _D_P='1'
	   	nDug+=_IznosBHD
	   else
	   	nPot+=_IznosBHD
	   endif
           @ m_x+19,m_y+1 SAY "ZBIR NALOGA:"
           @ m_x+19,m_y+14 SAY nDug PICTURE '9 999 999 999.99'
           @ m_x+19,m_y+35 SAY nPot PICTURE '9 999 999 999.99'
           @ m_x+19,m_y+56 SAY nDug-nPot PICTURE '9 999 999 999.99'
           inkey(10)
           select PRIPR
           APPEND BLANK
           Gather()
           if lLogKnjiz
      	          EventLog(nUser,goModul:oDataBase:cName,"DOK","KNJIZ",nDug,nPot,nil,nil,"","","Unos stavke ....",Date(),Date(),"","Knjizenje novog naloga")
	   endif
	   
	enddo
        BoxC()
        return DE_REFRESH
   case Ch=K_CTRL_F9
        if Pitanje(,"Zelite li izbrisati pripremu !!????","N")=="D"
             if lLogKnjiz
	     	EventLog(nUser,goModul:oDataBase:cName,"DOK","KNJIZ",nil,nil,nil,nil,"","",pripr->idfirma+"-"+pripr->idvn+"-"+pripr->brnal,Date(),Date(),"","Brisanje pripreme ....")
	     endif
	     zap
             BrisiPBaze()
	endif
        return DE_REFRESH

   case Ch==K_CTRL_P
#ifndef CAX
     close all
#endif
     StNal()
     O_Edit()
     return DE_REFRESH


   case Ch==K_ALT_F10

     if !SigmaSif("SIGMAXXX")
       return DE_CONT
     endif

     // stampaj
     #ifndef CAX
     close all
     #endif
     StNal(.t.)

     // pa azuriraj
     #ifndef CAX
     close all
     #endif
     Azur(.t.)
     O_Edit()
     return DE_REFRESH


   case Ch==K_ALT_A
#ifndef CAX
     close all
#endif
     Azur()
     O_Edit()
     return DE_REFRESH

   case Ch==K_ALT_B
#ifndef CAX
     close all
#endif
     Blagajna()
     O_Edit()
     return DE_REFRESH

   case Ch==K_ALT_I
     OiNIsplate()
     return DE_CONT

   case Ch==K_F10        // ostale opcije
     OstaleOpcije()
     return DE_REFRESH

endcase

return DE_CONT
*}



/*! \fn StNal(lAuto)
 *  \brief Priprema za stampu naloga 
 *  \param lAuto
 */
 
function StNal(lAuto)
*{
private dDatNal:=date()
StAnalNal(@lAuto)
//StSintNal()
SintStav(lAuto)
return
*}


/*! \fn StAnalNal(lAuto)
 *  \brief Stampanje analitickog naloga
 *  \param lAuto
 */
 
function StAnalNal(lAuto)
*{
private aNalozi:={}

if lAuto==NIL
	lAuto:=.f.
ENDIF

if IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
  O_VRSTEP
endif

O_PRIPR
O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_PSUBAN

select PSUBAN
ZAP

SELECT PRIPR
set order to 1
go top
EOF CRET

fizgenerisi:=.f.
if lAuto .or. reccount2()>9999  // keli  ze-do
   if Pitanje(,"Staviti na stanje bez pojed stampe ?","N")=="D"
     fizgenerisi:=.t.
   else
     lAuto:=.f.
   endif
endif

if lAuto
  Box(,3,75)
   @ m_x+0, m_y+2 SAY "PROCES FORMIRANJA SINTETIKE I ANALITIKE"
endif

DO WHILE !EOF()
   cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal
   if !fizgenerisi
     Box("",2,50)
       set cursor on
       @ m_x+1,m_y+2 SAY "Nalog broj:"
       if gNW=="D"
           cIdFirma:=gFirma
           @ m_x+1,col()+1 SAY cIdFirma
       else
           @ m_x+1,col()+1 GET cIdFirma
       endif
       @ m_x+1,col()+1 SAY "-" GET cIdVn
       @ m_x+1,col()+1 SAY "-" GET cBrNal
       if gDatNal=="D"
        @ m_x+2,m_y+2 SAY "Datum naloga:" GET dDatNal
       endif
       read; ESC_BCR
     BoxC()
   endif

   HSEEK cIdFirma+cIdVN+cBrNal
   if eof(); closeret; endif

   if !fizgenerisi
     START PRINT CRET

   // SELECT PRIPR    // priprema je selektovana
   endif

   StSubNal("1",lAuto)

   if !fizgenerisi
     END PRINT
   endif

   IF ASCAN(aNalozi,cIdFirma+cIdVN+cBrNal)==0
     AADD(aNalozi,cIdFirma+cIdVN+cBrNal)  // lista naloga koji su oti{li
     IF lAuto
       @ m_x+2, m_y+2 SAY "Formirana sintetika i analitika za nalog:"+cIdFirma+"-"+cIdVN+"-"+cBrNal
     ENDIF
   ENDIF

ENDDO   

if lAuto
  BoxC()
endif

if fizgenerisi .and. !lAuto
   Beep(2)
   Msg("Sve stavke su stavljene na stanje")
endif

closeret
return
*}


/*! \fn Zagl11()
 *  \brief Zaglavlje analitickog naloga
 */
 
function Zagl11()
*{
local nArr, lDnevnik:=.f.
if "DNEVNIKN"==PADR(UPPER(PROCNAME(1)),8) .or.;
   "DNEVNIKN"==PADR(UPPER(PROCNAME(2)),8)
   lDnevnik:=.t.
endif
if gNW=="N".and.gVar1=="0"
 P_COND2
else
 P_COND
endif
B_ON
?? UPPER(gTS)+":",gNFirma
?
nArr:=select()
if gNW=="N"
   select partn; hseek cidfirma; select (nArr)
   ? cidfirma,"-",partn->naz
endif
?
IF lDnevnik
  ? "FIN.P:      D N E V N I K    K NJ I Z E NJ A    Z A    "+;
    UPPER(NazMjeseca(MONTH(dDatNal)))+" "+STR(YEAR(dDatNal))+". GODINE"
ELSE
  ? "FIN.P: NALOG ZA KNJIZENJE BROJ :"
  @ prow(),PCOL()+2 SAY cIdFirma+" - "+cIdVn+" - "+cBrNal
ENDIF
B_OFF
if gDatNal=="D" .and. !lDnevnik
 @ prow(),pcol()+4 SAY "DATUM: "
 ?? dDatNal
endif

IF !lDnevnik
  select TNAL; hseek cidvn
  @ prow(),pcol()+4 SAY naz
ENDIF

@ prow(),pcol()+15 SAY "Str:"+str(++nStr,3)

lJerry := ( IzFMKIni("FIN","JednovalutniNalogJerry","N",KUMPATH) == "D" )

P_NRED
?? M
if gNW=="D"
 P_NRED
 ?? IF(lDnevnik,"R.BR. *   BROJ   *DAN*","")+"*R. * KONTO * PART *"+IF(gVar1=="1".and.lJerry,"       NAZIV PARTNERA         *                    ","    NAZIV PARTNERA ILI      ")+"*   D  O  K  U  M  E  N  T    *         IZNOS U  "+ValDomaca()+"         *"+IF(gVar1=="1","","    IZNOS U "+ValPomocna()+"    *")
 P_NRED
 ?? IF(lDnevnik,"U DNE-*  NALOGA  *   *","")+"              NER   "+IF(gVar1=="1".and.lJerry,"            ILI                      O P I S       ","                            ")+" ----------------------------- ------------------------------- "+IF(gVar1=="1","","---------------------")
 P_NRED; ?? IF(lDnevnik,"VNIKU *          *   *","")+"*BR *       *      *"+IF(gVar1=="1".and.lJerry,"        NAZIV KONTA           *                    ","    NAZIV KONTA             ")+"* BROJ VEZE * DATUM  * VALUTA *  DUGUJE "+ValDomaca()+"  * POTRAZUJE "+ValDomaca()+"*"+IF(gVar1=="1",""," DUG. "+ValPomocna()+"* POT."+ValPomocna()+"*")
ELSE
 P_NRED
 ?? IF(lDnevnik,"R.BR. *   BROJ   *DAN*","")+"*R. * KONTO * PART *"+IF(gVar1=="1".and.lJerry,"       NAZIV PARTNERA         *                    ","    NAZIV PARTNERA ILI      ")+"*           D  O  K  U  M  E  N  T             *         IZNOS U  "+ValDomaca()+"         *"+IF(gVar1=="1","","    IZNOS U "+ValPomocna()+"    *")
 P_NRED
 ?? IF(lDnevnik,"U DNE-*  NALOGA  *   *","")+"              NER   "+IF(gVar1=="1".and.lJerry,"            ILI                      O P I S       ","                            ")+" ---------------------------------------------- ------------------------------- "+IF(gVar1=="1","","---------------------")
 P_NRED
 ?? IF(lDnevnik,"VNIKU *          *   *","")+"*BR *       *      *"+IF(gVar1=="1".and.lJerry,"        NAZIV KONTA           *                    ","    NAZIV KONTA             ")+"*  TIP I NAZIV   * BROJ VEZE * DATUM  * VALUTA *  DUGUJE "+ValDomaca()+"  * POTRAZUJE "+ValDomaca()+"*"+IF(gVar1=="1",""," DUG. "+ValPomocna()+"* POT."+ValPomocna()+"*")
ENDIF
P_NRED
?? M
select(nArr)
return
*}

/*! \fn SintStav(lAuto)
 *  \brief Formiranje sintetickih stavki
 *  \param lAuto
 */
 
function SintStav(lAuto)
*{
if lAuto==NIL; lAuto:=.f.; ENDIF

O_PSUBAN
O_PARTN
O_PANAL
O_PSINT
O_PNALOG
O_KONTO
O_TNAL

select PANAL; zap
select PSINT; zap
select PNALOG; zap

select PSUBAN; set order to 2; go top
if empty(BrNal); closeret; endif

A:=0
DO WHILE !eof()   // svi nalozi

   nStr:=0
   nD1:=nD2:=nP1:=nP2:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal

   DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog

         cIdkonto:=idkonto

         nDugBHD:=nDugDEM:=0
         nPotBHD:=nPotDEM:=0
         IF D_P="1"
               nDugBHD:=IznosBHD; nDugDEM:=IznosDEM
         ELSE
               nPotBHD:=IznosBHD; nPotDEM:=IznosDEM
         ENDIF

         SELECT PANAL     // analitika
         seek cidfirma+cidvn+cbrnal+cidkonto
         fNasao:=.f.
         DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                    .and. IdKonto==cIdKonto
           if gDatNal=="N"
              if month(psuban->datdok)==month(datnal)
                fNasao:=.t.
                exit
              endif
           else  // sintetika se generise na osnovu datuma naloga
              if month(dDatNal)==month(datnal)
                fNasao:=.t.
                exit
              endif
           endif
           skip
         enddo
         if !fNasao
            append blank
         endif

         REPLACE IdFirma WITH cIdFirma,IdKonto WITH cIdKonto,IdVN WITH cIdVN,;
                 BrNal with cBrNal,;
                 DatNal WITH iif(gDatNal=="D",dDatNal,max(psuban->datdok,datnal)),;
                 DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
                 DugDEM WITH DugDEM+nDugDEM, PotDEM WITH PotDEM+nPotDEM


         SELECT PSINT
         seek cidfirma+cidvn+cbrnal+left(cidkonto,3)
         fNasao:=.f.
         DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                   .and. left(cidkonto,3)==idkonto
           if gDatNal=="N"
            if  month(psuban->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
           else // sintetika se generise na osnovu dDatNal
              if month(dDatNal)==month(datnal)
                fNasao:=.t.
                exit
              endif
           endif

           skip
         enddo
         if !fNasao
             append blank
         endif

         REPLACE IdFirma WITH cIdFirma,IdKonto WITH left(cIdKonto,3),IdVN WITH cIdVN,;
              BrNal WITH cBrNal,;
              DatNal WITH iif(gDatNal=="D", dDatNal,  max(psuban->datdok,datnal) ),;
              DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
              DugDEM WITH DugDEM+nDugDEM,PotDEM WITH PotDEM+nPotDEM

         nD1+=nDugBHD; nD2+=nDugDEM; nP1+=nPotBHD; nP2+=nPotDEM

        SELECT PSUBAN
        skip
   ENDDO  // nalog

   SELECT PNALOG    // datoteka naloga
   APPEND BLANK
   REPLACE IdFirma WITH cIdFirma,IdVN WITH cIdVN,BrNal WITH cBrNal,;
           DatNal WITH iif(gDatNal=="D",dDatNal,date()),;
           DugBHD WITH nD1,PotBHD WITH nP1,;
           DugDEM WITH nD2,PotDEM WITH nP2

   private cDN:="N"
   if !lAuto
     Box(,2,55)
       @ m_x+1,m_y+2 SAY "Stampanje analitike/sintetike za nalog "+cidfirma+"-"+cidvn+"-"+cbrnal+" ?"  GET cDN pict "@!" valid cDN $ "DN"
       if gDatNal=="D"
        @ m_x+2,m_y+2 SAY "Datum naloga:" GET dDatNal
       endif
       read
     BoxC()
   endif
   if cDN=="D"
     select panal
     seek cidfirma+cidvn+cbrnal
     StOSNal(.f.)    // stampa se priprema
   endif
   SELECT PSUBAN

ENDDO  // svi nalozi

select PANAL
go top
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo

select PSINT
go top
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo

closeret
return
*}


/*! \fn Blagajna()
 *  \brief Blagajna
 */
 
function Blagajna()
*{
local nRbr,nCOpis:=0,cOpis:=""
private pici:=FormPicL("9,"+gPicDEM,12)

lSumiraj := ( IzFMKINI("BLAGAJNA","DBISumirajPoBrojuVeze","N",PRIVPATH)=="D" )
O_KONTO
O_ANAL
O_PRIPR

GO TOP
_IDVN:=idvn; cIdfirma:=idfirma; cBrdok:=brnal
IF DABLAGAS
  cKontoBlag := PADR(IzFMKINI("BLAGAJNA","Konto","202000",PRIVPATH),7)
  // CREATE_INDEX("2","idFirma+IdVN+BrNal+IdKonto",PRIVPATH+"PRIPR")
  SET ORDER TO TAG "2"
  SEEK cidfirma+_idvn+cBrDok+cKontoBlag
  IF !FOUND() .or. Pitanje(,"Postoji knjizenje na kontu blagajne! Regenerisati knjizenje? (D/N)","N")=="D"
    IF FOUND()
      DO WHILE !EOF() .and. cidfirma+_idvn+cBrDok+cKontoBlag == idFirma+IdVN+BrNal+IdKonto
        SKIP 1; nRec:=RECNO(); SKIP -1
        DBDELETE2()
        GO (nRec)
      ENDDO
    ENDIF
    // CREATE_INDEX("1","idFirma+IdVN+BrNal+Rbr",PRIVPATH+"PRIPR")
    SET ORDER TO TAG "1"
    GO TOP
    lEOF:=.f.
    DO WHILE !EOF() .and. !lEOF .and. cidfirma+_idvn+cBrDok == idFirma+IdVN+BrNal
      SKIP 1; lEOF:=EOF(); nRec:=RECNO(); SKIP -1
      Scatter("w")
        APPEND BLANK
        // promijeni konto i predznak, te nuliraj partnera, rj, funk i fond
        wIdKonto   := cKontoBlag
        wIdPartner := SPACE(LEN(wIdPartner))
        wD_P       := IF(wD_P="1","2","1")
        IF gRJ=="D"
          wIdRj := SPACE(LEN(widrj))
        ENDIF
        if gTroskovi=="D"
          wFunk := SPACE(LEN(wFunk))
          wFond := SPACE(LEN(wFond))
        endif
      Gather("w")
      GO (nRec)
    ENDDO
  ENDIF
  SET ORDER TO TAG "1"
  go top
ENDIF

cDinDem:="1"
Box(,3,60)
 @ m_x+1,m_y+2 SAY ValDomaca()+"/"+ValPomocna()+" blagajnicki izvjestaj (1/2):" GET cDinDem
 read
 if cDinDem=="1"
   cIdKonto:=padr("2020",7)
   pici:=FormPicL("9,"+gPicBHD,12)
 else
   cIdKonto:=padr("2050",7)
 endif
 IF DABLAGAS
   cIdKonto := cKontoBlag
 ENDIF

 dDatdok:=datdok

 @ m_x+2,m_Y+2 SAY "Datum:" GET dDatDok
 @ m_x+3,m_Y+2 SAY "Konto blagajne:" GET cIdKonto valid P_Konto(@cIdKonto)
 read
BoxC()

SELECT PRIPR

start print cret

F12CPI
?? space(12)
if cdindem=="1"
  ?? "("+ValDomaca()+")"
else
  ?? "DEVIZNI ("+ValPomocna()+")"
endif
?? " BLAGAJNICKI IZVJESTAJ OD ", dDatDok
?? space(8),"Broj:",cBrDok
?
?
nRbr:=0
nDug:=nPot:=0
nCol1:=20
? "    ------- ------------------------- --------------------- -------------- ---------------"
? "    * Redni*       Temeljnica        *        OPIS         *    ULAZ      *    IZLAZ     *"
? "    * broj *                         *                     *              *              *"
? "    *      *            *            *                     *              *              *"
? m:="    ------- ------------ ------------ --------------------- -------------- ---------------"
do while !eof()
  IF PROW() > 49+gPStranica
    PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)
  ENDIF
  IF lSumiraj
    nPomD:=nPomP:=0
    cBrDok2:=brdok
    cOpis:=""
    nStavki:=0
    DO WHILE !EOF() .and. brdok==cBrDok2
      if idkonto<>cidkonto
        skip 1
        loop
      else
        if nPomD<>0 .and. d_p=="2" .or. nPomP<>0 .and. d_p=="1"
          // ovo se moze desiti ako su iste temeljnice za naplatu i isplatu
          exit
        endif
      endif
      if cdindem=="1"  // dinari !!!!
        if d_p=="1"
          nPomD+=iznosbhd
        else
          nPomP+=iznosbhd
        endif
      else
        if d_p=="1"
          nPomD+=iznosdem
        else
          nPomP+=iznosdem
        endif
      endif
      IF !EMPTY(opis)
        cOpis += opis
        ++nStavki
      ENDIF
      skip 1
    ENDDO
    IF PROW() > 49+gPStranica-nStavki
      PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)
    ENDIF
    ? "    *",str(++nRbr,3)+". *"
    if nPomD<>0
      ?? " "+cbrdok2+" *"+space(12)+"*"
    else
      ?? space(12)+"* "+padr(cbrdok2,11)+"*"
    endif
    nCOpis:=pcol()+1
    ?? " "+PADR(cOpis,20)
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomD,pici),14)
    @ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomP,pici),14)
    nDug += nPomD
    nPot += nPomP
    OstatakOpisa(cOpis,nCOpis)
  ELSE
    if idkonto<>cidkonto
      skip
      loop
    endif
    ? "    *",str(++nRbr,3)+". *"
    if d_p=="1"
      ?? " "+brdok+" *"+space(12)+"*"
    else
      ?? space(12)+"* "+padr(brdok,11)+"*"
    endif
    nCOpis:=pcol()+1
    ?? " "+PADR(cOpis:=ALLTRIM(opis),20)
    nCol1:=pcol()+1
    if cdindem=="1"  // dinari !!!!

      if d_p=="1"
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici),14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        nDug+=iznosbhd
      else
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici),14)
        nPot+=iznosbhd
      endif

    else

      if d_p=="1"
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici),14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        nDug+=iznosdem
      else
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici),14)
        nPot+=iznosdem
      endif

    endif
    OstatakOpisa(cOpis,nCOpis)
    skip 1
  ENDIF
enddo
select anal
//CREATE_INDEX("ANALi1","IdFirma+IdKonto+dtos(DatNal)","ANAL")
hseek cidfirma+cidkonto
nDugSt:=nPotSt:=0
do while !eof() .and. idfirma==cidfirma .and. idkonto==cidkonto .and. datnal<dDatDok
   if cdindem=="1"
     nDugSt+=dugbhd
     nPotSt+=potbhd
   else
     nDugSt+=dugdem
     nPotSt+=potdem
   endif
   skip
enddo
? m
@ prow()+1,10 SAY "Promet blagajne:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndug,pici),14)
@ prow(),pcol()+1 SAY PADL(TRANSFORM(npot,pici),14)
? m
@ prow()+1,10 SAY "Saldo od "+dtoc(ddatdok-1)+":"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndugst-npotst,pici),14)
? m
@ prow()+1,10 SAY "Ukupan primitak:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndugst-npotst+ndug,pici),14)

@ prow()+1,10 SAY "Izdatak:"
@ prow(),ncol1 SAY PADL(TRANSFORM(npot,pici),14)

? m
@ prow()+1,10 SAY "Saldo na dan:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndugst-npotst+ndug-npot,pici),14)
? m
@ prow()+1,10 SAY "Slovima:"
@ prow(),pcol()+1 SAY Slovima(round(ndugst-npotst+ndug-npot,2),iif(cdindem=="1",ValDomaca(),ValPomocna()))
? m
?
?
@ prow()+1,25 SAY "  ___________________            ______________________"
@ prow()+1,25 SAY "     Blagajna                           Kontrola       "
FF
end print
closeret


PROC PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)
    // zavrsetak prethodne stranice:
    // -----------------------------
    ? m
      @ prow()+1,10 SAY "Promet blagajne, prenos:"
      @ prow(),ncol1 SAY PADL(TRANSFORM(ndug,pici),14)
      @ prow(),pcol()+1 SAY PADL(TRANSFORM(npot,pici),14)
    ? m
    FF
    // sljedeca stranica:
    // ------------------
    F12CPI
    ?? space(12)
    if cdindem=="1"
      ?? "("+ValDomaca()+")"
    else
      ?? "DEVIZNI ("+ValPomocna()+")"
    endif
    ?? " BLAGAJNICKI IZVJESTAJ OD ", dDatDok
    ?? space(8),"Broj:",cBrDok
    ?
    ?
    ? "    ------- ------------------------- --------------------- -------------- ---------------"
    ? "    * Redni*       Temeljnica        *        OPIS         *    ULAZ      *    IZLAZ     *"
    ? "    * broj *                         *                     *              *              *"
    ? "    *      *            *            *                     *              *              *"
    ? m
      @ prow()+1,10 SAY "Promet blagajne, donos:"
      @ prow(),ncol1 SAY PADL(TRANSFORM(ndug,pici),14)
      @ prow(),pcol()+1 SAY PADL(TRANSFORM(npot,pici),14)
    ? m
return
*}


/*! \fn Slovima(nIzn,cDinDem)
 *  \brief Ispisuje neki iznos nIzn slovima
 *  \param nIzn    - iznos
 *  \param cDinDem - domaca/strana valuta
 */
 
function Slovima(nIzn,cDinDem)
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
   if fi; cRez+="i"; endif
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
   if fi; cRez+="i"; endif
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
if fi .and. nIzn>=1; cRez+="i"; endif
Stotice(nIzn,@cRez,.t.,.t.,cDINDEM)
return
*}



/*! \todo Ova funkcija vec postoji i u fakt-u treba je prebaciti u /sclib 
 */

/*! \fn Stotice(nIzn,cRez,fDecimale,fMnozina,cDinDem)
 *  \brief 
 *  \param nIzn
 *  \param cRez
 *  \param fDecimale
 *  \param fMnozina
 *  \param cDinDem
 */
 
function Stotice(nIzn,cRez,fDecimale,fMnozina,cDinDem)
*{
local fDec,fSto:=.f.

if (nPom:=int(nIzn/100))>=1
   aSl:={ "stotinu", "dvijestotine", "tristotine", "~etiristotine",;
          "petstotina","{eststotina","sedamstotina","osamstotina","devetstotina"}
   cRez+=aSl[nPom]
   nIzn:=nIzn-nPom*100
   fSto:=.t.
endif

fDec:=.f.
do while .t.
if int(nIzn)>10 .and. int(nIzn)<20
   aSl:={ "jedanest", "dvanest", "trinest", "~etrnest",;
          "petnest","{esnest","sedamnest","osamnest","devetnest"}
   cRez+=aSl[int(nIzn)-10]
   nIzn:=nIzn-int(nIzn)
endif
if (nPom:=int(nIzn/10))>=1
   aSl:={ "deset", "dvadeset", "trideset", "~etrdeset",;
          "pedeset","{ezdeset","sedamdeset","osamdeset","devedeset"}
   cRez+=aSl[nPom]
   nIzn:=nIzn-nPom*10
endif
if (nPom:=int(nIzn))>=1
    aSl:={ "jedan", "dva", "tri", "~etiri",;
           "pet","{est","sedam","osam","devet"}
   if fmnozina
        aSl[1]:="jedna"
        aSl[2]:="dvije"
   endif
   cRez+=aSl[nPom]
   nIzn:=nIzn-nPom
endif

if !fDecimale; exit; endif

if fdec; cRez+="/100"; exit; endif
fDec:=.t.
fMnozina:=.f.
nizn:=round(nIzn*100,0)
if nizn>0
 if !empty(cRez)
  cRez+=" "+cDINDEM+" i "
 endif
else
 if empty(cRez)
  cRez:="nula "+ValPomocna()
 else
  cRez+=" "+cDINDEM
 endif
 exit
endif
enddo


return cRez
*}



/*! \fn IdPartner(cIdPartner)
 *  \brief Odstampa sifru na 6 mjesta, a ako ne moze onda punu sifru
 *  \param cIdPartner  - id partnera
 */
 
function IdPartner(cIdPartner)
*{
return iif(len(TRIM(cIDPARTNER))>6,cIdPartner,left(cidpartner,6))
*}


/*! \fn DifIdP(cIdPartner)
 *  \brief Formatira cIdPartner na 6 mjesta ako mu je duzina 8
 *  \param cIdPartner - id partnera
 */
 
function DifIdP(cIdPartner)
*{
return if(len(TRIM(cIDPARTNER))>6,2,0)
*}


/*! \fn Preduzece()
 *  \brief Vraca naziv firme
 */
 
function Preduzece()
*{
local nArr:=select()
F10CPI
B_ON
? gTS+": "
if gNW=="D"
 ?? gFirma,"-",gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ?? cIdFirma,partn->naz,partn->naz2
endif
B_OFF
?
select (nArr)
return
*}


/*! \fn BrisiPBaze()
 *  \brief Brisi pomocne baze
 */
 
function BrisiPBaze()
*{
  PushWA()
  SELECT F_PSUBAN; ZAP
  SELECT F_PANAL; ZAP
  SELECT F_PSINT; ZAP
  SELECT F_PNALOG; ZAP
  PopWA()
RETURN (NIL)
*}


/*! \fn PreuzSezSPK(cSif)
 *  \brief Preuzimanje sifre iz sezone
 *  \param cSif
 */
 
function PreuzSezSPK(cSif)
*{
*static string
static cSezNS:="1998"
*;
 LOCAL nObl:=SELECT()
 Box(,3,70)
  cSezNS:=PADR(cSezNS,4)
  @ m_x+1,m_y+2 SAY "Sezona:" GET cSezNS PICT "9999"
  READ
  cSezNS:=ALLTRIM(cSezNS)
 BoxC()
 IF cSif=="P"
   USE (TRIM(cDirSif)+"\"+cSezNS+"\PARTN") ALIAS PARTN2 NEW
   SELECT PARTN2
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK PSUBAN->idpartner
   IF FOUND()
     SELECT PARTN
     APPEND BLANK
     REPLACE id WITH PARTN2->id,;
            naz WITH PARTN2->naz,;
         mjesto WITH PARTN2->mjesto
   ELSE
     SELECT PARTN
     APPEND BLANK
     REPLACE id WITH PSUBAN->idpartner
   ENDIF
   SELECT PARTN2; USE
 ELSE
   USE (TRIM(cDirSif)+"\"+cSezNS+"\KONTO") ALIAS KONTO2 NEW
   SELECT KONTO2
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK PSUBAN->idkonto
   IF FOUND()
     SELECT KONTO
     APPEND BLANK
     REPLACE id WITH KONTO2->id, naz WITH KONTO2->naz
   ELSE
     SELECT KONTO
     APPEND BLANK
     REPLACE id WITH PSUBAN->idkonto
   ENDIF
   SELECT KONTO2; USE
 ENDIF
 SELECT (nObl)
RETURN



/*! \fn SintFilt(lSint,cFilter)
 *  \brief Iz filterisane SUBAN.DBF tabele generise POM.DBF
 *  \brief Ova funkcija ne podrzava varijantu gDatNal:="D"
 *  \param lSint   - .t.-POM.DBF je analitika, .f.-POM.DBF
 *  \param cFilter
 */
 
function SintFilt(lSint,cFilter)
*{
IF lSint==NIL; lSint:=.f.; ENDIF
  // napravimo pomocnu bazu
  aDbf := {}
  AADD(aDBf,{ 'IDFIRMA'   , 'C' ,   2 ,  0 })
  AADD(aDBf,{ 'IDKONTO'   , 'C' , IF(lSint,3,7) ,  0 })
  AADD(aDBf,{ 'IDVN'      , 'C' ,   2 ,  0 })
  AADD(aDBf,{ 'BRNAL'     , 'C' ,   4 ,  0 })
  AADD(aDBf,{ 'RBR'       , 'C' ,   3 ,  0 })
  AADD(aDBf,{ 'DATNAL'    , 'D' ,   8 ,  0 })
  AADD(aDBf,{ 'DUGBHD'    , 'N' ,  17 ,  2 })
  AADD(aDBf,{ 'POTBHD'    , 'N' ,  17 ,  2 })
  AADD(aDBf,{ 'DUGDEM'    , 'N' ,  15 ,  2 })
  AADD(aDBf,{ 'POTDEM'    , 'N' ,  15 ,  2 })

  DBCREATE2 (PRIVPATH+"POM", aDbf)
  IF !lSint
    USEX (PRIVPATH+"POM") NEW ALIAS ANAL
  ELSE
    USEX (PRIVPATH+"POM") NEW ALIAS SINT
  ENDIF
  INDEX ON idFirma+IdVN+BrNal+IdKonto TAG "0"
  IF lSint
    INDEX ON IdFirma+IdKonto+dtos(DatNal) TAG "1"
    INDEX ON idFirma+IdVN+BrNal+Rbr       TAG "2"
  ELSE
    INDEX ON IdFirma+IdKonto+dtos(DatNal) TAG "1"
    INDEX ON idFirma+IdVN+BrNal+Rbr       TAG "2"
    INDEX ON idFirma+dtos(DatNal)         TAG "3"
    INDEX ON Idkonto                      TAG "4"
    INDEX ON DatNal                       TAG "5"
  ENDIF
  SET ORDER TO TAG "0"
  GO TOP

  O_SUBAN
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt:=cFilter
  cSort1:="idFirma+IdVN+BrNal+IdKonto"
  INDEX ON &cSort1 TO "SUBTMP" FOR &cFilt EVAL(TekRec2()) EVERY 1
  GO TOP
  nArr:=SELECT()
  BoxC()

  DO WHILE !eof()   // svi nalozi

    nD1:=nD2:=nP1:=nP2:=0
    cIdFirma:=IdFirma; cIDVn=IdVN; cBrNal:=BrNal

    DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog

        cIdkonto:=idkonto

        nDugBHD:=nDugDEM:=0
        nPotBHD:=nPotDEM:=0
        IF D_P="1"
          nDugBHD:=IznosBHD; nDugDEM:=IznosDEM
        ELSE
          nPotBHD:=IznosBHD; nPotDEM:=IznosDEM
        ENDIF

        IF !lSint
          SELECT ANAL     // analitika
          seek cidfirma+cidvn+cbrnal+cidkonto
          fNasao:=.f.
          DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                     .and. IdKonto==cIdKonto
            if month((nArr)->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
            skip 1
          enddo
          if !fNasao
             append blank
          endif

          REPLACE IdFirma WITH cIdFirma,IdKonto WITH cIdKonto,IdVN WITH cIdVN,;
                  BrNal with cBrNal,;
                  DatNal WITH max((nArr)->datdok,datnal),;
                  DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
                  DugDEM WITH DugDEM+nDugDEM, PotDEM WITH PotDEM+nPotDEM

        ELSE             // sintetika
  
          SELECT SINT
          seek cidfirma+cidvn+cbrnal+left(cidkonto,3)
          fNasao:=.f.
          DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                    .and. left(cidkonto,3)==idkonto
            if  month((nArr)->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
            skip 1
          enddo
          if !fNasao
              append blank
          endif

          REPLACE IdFirma WITH cIdFirma,IdKonto WITH left(cIdKonto,3),IdVN WITH cIdVN,;
               BrNal WITH cBrNal,;
               DatNal WITH max((nArr)->datdok,datnal),;
               DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
               DugDEM WITH DugDEM+nDugDEM,PotDEM WITH PotDEM+nPotDEM
        ENDIF
        SELECT (nArr)
        skip 1
    ENDDO  // nalog

    SELECT (nArr)

  ENDDO  // svi nalozi
  SELECT (nArr); USE

  IF !lSint
    SELECT ANAL
  ELSE
    SELECT SINT
  ENDIF
  go top
  do while !eof()
    nRbr:=0
    cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
    do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
      replace rbr with str(++nRbr,3)
      skip 1
    enddo
  enddo
  SET ORDER TO TAG "1"
  GO TOP

RETURN
*}


/*! \fn TekRec2()
 *  \brief Tekuci zapis
 */
 
function TekRec2()
*{
 nSlog++
 @ m_x+1, m_y+2 SAY PADC(ALLTRIM(STR(nSlog))+"/"+ALLTRIM(STR(nUkupno)),20)
 @ m_x+2, m_y+2 SAY "Obuhvaceno: "+STR(cmxKeysIncluded())
RETURN (NIL)
*}

/*! \fn Reci(x,y,cT)
 *  \brief Ispisuje zeljenu poruku cT na odredjenu lokaciju x,y
 *  \param x
 *  \param y
 *  \param cT
 */
 
function Reci(x,y,cT)
*{
LOCAL px:=ROW(),py:=COL()
 @ m_x+x,m_y+y SAY cT
 SETPOS(px,py)
RETURN
*}


/*! \fn OstaleOpcije()
 *  \brief Ostale opcije koje se pozivaju sa <F10>
 */
 
function OstaleOpcije()
*{
private opc[3]
  opc[1]:="1. novi datum->datum, stari datum->dat.valute "
  opc[2]:="2. podijeli nalog na vise dijelova"
  if IzFMKINI("FIN","IzvodBanke","N")=="D"
    opc[3]:="3. preuzmi izvod iz banke"
  else
    opc[3]:="3. -------------------------------"
  endif
  h[1]:=h[2]:=h[3]:=""
  private Izbor:=1
  private am_x:=m_x,am_y:=m_y
  close all
  do while .t.
     Izbor:=menu("prip",opc,Izbor,.f.)
     do case
       case Izbor==0
           EXIT
       case izbor == 1
           SetDatUPripr()
       case izbor == 2
           PodijeliN()
       case izbor == 3
           if IzFMKINI("FIN","IzvodBanke","N")=="D"
             IzvodBanke()
           endif
     endcase
  enddo
  m_x:=am_x; m_y:=am_y
  O_Edit()
RETURN
*}


/*! \fn PodijeliN()
 *  \brief
 */
 
function PodijeliN()
*{
if !SigmaSif("PVNAPVN")
 return
endif

cPomKTO:="9999999"

O_PRIPR

nRbr1:=nRbr2:=nRbr3:=nRbr4:=0
cBRnal1:=cBrnal2:=cBrnal3:=cBrnal4:=cBrnal5:=pripr->brnal
dDatDok:=pripr->datdok

Box(,10,60)
 @ m_x+1,m_y+2 SAY "Redni broj / 1 " get nRbr1
 @ m_x+1,col()+2 SAY "novi broj naloga" GET cBRNAL1
 @ m_x+2,m_y+2 SAY "Redni broj / 2 " get nRbr2
 @ m_x+2,col()+2 SAY "novi broj naloga" GET cBRNAL2
 @ m_x+3,m_y+2 SAY "Redni broj / 3 " get nRbr3
 @ m_x+3,col()+2 SAY "novi broj naloga" GET cBRNAL3
 @ m_x+4,m_y+2 SAY "Redni broj / 4 " get nRbr4
 @ m_x+4,col()+2 SAY "novi broj naloga" GET cBRNAL4

 @ m_x+6,m_y+6 SAY "Zadnji dio, broj naloga  " get cBrnal5
 @ m_x+8,m_y+6 SAY "Pomocni konto  " get cPomKTO
 @ m_x+9,m_y+6 SAY "Datum dokumenta" get dDatDok

 read
Boxc()
if lastkey()==K_ESC
     close all
     RETURN DE_CONT
endif


nDug:=nPot:=0

cIdfirma:=idfirma
cIdVN:=IDVN
cBrnal:=BRNAL

go top
MsgO("Prvi krug...")
do while !eof()
 if d_p=="1"
    nDug+=iznosbhd
 else
    nPot+=iznosbhd
 endif

 if nRbr1<>0 .and. nRbr1==val(pripr->Rbr)
    nRbr:=nRbr1
 elseif nRbr2<>0 .and. nRbr2==val(pripr->Rbr)
    nRbr:=nRbr2
 elseif nRbr3<>0 .and.nRbr3==val(pripr->Rbr)
    nRbr:=nRbr3
 elseif nRbr4<>0 .and.nRbr4==val(pripr->Rbr)
    nRbr:=nRbr4
 else
    nRbr:=0  // nista
 endif

 if nRbr<>0
    append blank
    replace idvn with cidvn,idfirma with cidfirma, brnal with cbrnal,;
            idkonto with cPomKTO, datdok with dDatDok

    if ndug>nPot // dugovni saldo
       replace d_p with "2"
       replace iznosbhd with (nDug-nPot)
    else
       replace d_p with "1"
       replace iznosbhd with (nPot-nDug)
    endif
    replace rbr with str(nRbr,4)

    // protustavka
    Scatter()
    append blank
    _iznosbhd:=-_iznosbhd
    _opis:=">prenos iz p.n.<"  // prenos iz predhodnog naloga
    Gather()

    if _d_p=="2"  // inicijalizuj ndug,npot
      nPot:=iznosbhd; nDug:=0
    else
      nDug:=iznosbhd; nPot:=0
    endif

 endif


 skip
enddo
MsgC()

MsgO("Drugi krug...")
set order to
go top
do while !eof()
   if nRbr1<>0 .and. val(pripr->Rbr)<=nRbr1
      altd()
      if opis=">prenos iz p.n.<"   .and. idkonto=cPomKTO
       if nRbr2=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal2
       endif
      else
       replace brnal with cBrnal1
      endif
   elseif nRbr2<>0 .and. val(pripr->Rbr)<=nRbr2
      if opis=">prenos iz p.n.<"     .and. idkonto=cPomKTO
       if nRbr3=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal3
       endif
      else
       replace brnal with cBrnal2
      endif
   elseif nRbr3<>0 .and. val(pripr->Rbr)<=nRbr3
      if opis=">prenos iz p.n.<"      .and. idkonto=cPomKTO
       if nRbr4=0
         replace brnal with cBrnal5
       else
        replace brnal with cBrnal4
       endif
      else
       replace brnal with cBrnal3
      endif
   elseif nRbr4<>0 .and. val(pripr->Rbr)<=nRbr4
      if opis=">prenos iz p.n.<"    .and. idkonto=cPomKTO
       replace brnal with cBrnal5
      else
       replace brnal with cBrnal4
      endif
   else
      replace brnal with cBrnal5
   endif
   skip
enddo
MsgC()

close all
return DE_REFRESH
*}


/*! \fn SetDatUPripr()
 *  \brief Postavi datum u pripremi
 */
 
function SetDatUPripr()
*{
  PRIVATE cTDok:="00"
  PRIVATE dDatum:=CTOD("01.01."+STR(YEAR(DATE()),4))
  IF !VarEdit({ {"Postaviti datum dokumenta","dDatum",,,},;
                {"Promjenu izvrsiti u nalozima vrste","cTDok",,,} }, 10,0,15,79,;
              'SETOVANJE NOVOG DATUMA DOKUMENTA I PREBACIVANJE STAROG U DATUM VALUTE',;
              "B1")
    CLOSERET
  ENDIF
  O_PRIPR
  GO TOP
  DO WHILE !EOF()
    IF IDVN<>cTDok; SKIP 1; LOOP; ENDIF
    Scatter()
    IF EMPTY(_datval)
      _datval:=_datdok
    ENDIF
    _datdok:=dDatum
    Gather()
    SKIP 1
  ENDDO
CLOSERET
return
*}


/*! \fn StSubNal(cInd,lAuto)
 *  \brief Stapmanje subanalitickog naloga
 *  \param cInd  - "1"-stampa pripreme, "2"-stampa azuriranog, "3"-stampa dnevnika
 *  \param lAuto
 */
 
function StSubNal(cInd,lAuto)
*{
LOCAL nArr:=SELECT(), aRez:={}, aOpis:={}

   IF lAuto=NIL; lAuto:=.f.; ENDIF

   lJerry := ( IzFMKIni("FIN","JednovalutniNalogJerry","N",KUMPATH) == "D" )

   PicBHD:="@Z "+FormPicL(gPicBHD,15)
   PicDEM:="@Z "+FormPicL(gPicDEM,10)
   IF gNW=="N"
     M:=IF(cInd=="3","------ ---------- --- ","")+"---- ------- ------ ----------------------------"+IF(gVar1=="1".and.lJerry,"-- "+REPL("-",20),"")+" -- ------------- ----------- -------- -------- --------------- ---------------"+IF(gVar1=="1","-"," ---------- ----------")
   ELSE
     M:=IF(cInd=="3","------ ---------- --- ","")+"---- ------- ------ ----------------------------"+IF(gVar1=="1".and.lJerry,"-- "+REPL("-",20),"")+" ----------- -------- -------- --------------- ---------------"+IF(gVar1=="1","-"," ---------- ----------")
   ENDIF

   IF cInd $ "1#2"
     nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
     nStr:=0
//     nUkDug:=nUkPot:=0
   ENDIF

   b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
   // cVN:=VN; cFirma:=Firma1+Firma2
   cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal

   IF cInd $ "1#2" .and. !lAuto
     Zagl11()
   ENDIF
   DO WHILE !eof() .and. eval(b2)
      if !lAuto
       if prow()>61+IF(cInd=="3",-7,0)+gPStranica
         if cInd=="3"
           PrenosDNal()
         else
           FF
         endif
         Zagl11()
       endif
       P_NRED
       IF cInd=="3"
         @ prow(),0 SAY STR(++nRBrDN,6)
         @ prow(),pcol()+1 SAY cIdFirma+"-"+cIdVN+"-"+cBrNal
         @ prow(),pcol()+1 SAY " "+LEFT(DTOC(dDatNal),2)
         @ prow(),pcol()+1 SAY RBr
       ELSE
         @ prow(),0 SAY RBr
       ENDIF
       @ prow(),pcol()+1 SAY IdKonto

       if !empty(IdPartner)
         if gVSubOp=="D"
           select KONTO; hseek (nArr)->idkonto
           select PARTN; hseek (nArr)->idpartner
           cStr:=TRIM(KONTO->naz)+" ("+TRIM(trim(naz)+" "+trim(naz2))+")"
         else
           select PARTN; hseek (nArr)->idpartner
           cStr:=trim(naz)+" "+trim(naz2)
         endif
       else
         select KONTO;  hseek (nArr)->idkonto
         cStr:=naz
       endif
       select (nArr)

       IF gVar1=="1" .and. lJerry
         aRez:={PADR(cStr,30)}
         cStr:=opis
         aOpis:=SjeciStr(cStr,20)
       ELSE
         aRez:=SjeciStr(cStr,28)
         cStr:=opis
         aOpis:=SjeciStr(cStr,20)
       ENDIF

       @ prow(),pcol()+1 SAY Idpartner(idpartner)

       nColStr:=PCOL()+1

       @  prow(),pcol()+1 SAY padr(aRez[1],28+IF(gVar1=="1".and.lJerry,2,0)-DifIdP(idpartner)) // dole cu nastaviti

       nColDok:=PCOL()+1

       IF gVar1=="1" .and. lJerry
         @ prow(),pcol()+1 SAY aOpis[1]
       ENDIF

       if gNW=="N"
         @ prow(),pcol()+1 SAY IdTipDok
         select TDOK;  hseek (nArr)->idtipdok
         @ prow(),pcol()+1 SAY naz
         select (nArr)
         @ prow(),pcol()+1 SAY padr(BrDok,11)
       else
         @ prow(),pcol()+1 SAY padr(BrDok,11)
       endif
       @ prow(),pcol()+1 SAY DatDok
       if cDatVal=="D"
         @ prow(),pcol()+1 SAY DatVal
       else
         @ prow(),pcol()+1 SAY space(8)
       endif
       nColIzn:=pcol()+1
      endif

      IF D_P=="1"
         if !lAuto
           @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
           @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
         endif
         nUkDugBHD+=IznosBHD
         IF cInd=="3"
           nTSDugBHD+=IznosBHD
         ENDIF
      ELSE
         if !lAuto
           @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
           @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
         endif
         nUkPotBHD+=IznosBHD
         IF cInd=="3"
           nTSPotBHD+=IznosBHD
         ENDIF
      ENDIF

      IF gVar1!="1"
        if D_P=="1"
           if !lAuto
             @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
             @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
           endif
           nUkDugDEM+=IznosDEM
           IF cInd=="3"
             nTSDugDEM+=IznosDEM
           ENDIF
        else
           if !lAuto
             @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
             @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
           endif
           nUkPotDEM+=IznosDEM
           IF cInd=="3"
             nTSPotDEM+=IznosDEM
           ENDIF
        endif
      ENDIF

      if !lAuto
        Pok:=0
        for i:=2 to max(len(aRez),len(aOpis)+IF(gVar1=="1".and.lJerry,0,1))
          if i<=len(aRez)
            @ prow()+1,nColStr say aRez[i]
          else
            pok:=1
          endif
          IF gVar1=="1" .and. lJerry
            @ prow()+pok,nColDok say IF( i<=len(aOpis) , aOpis[i] , SPACE(20) )
          ELSE
            @ prow()+pok,nColDok say IF( i-1<=len(aOpis) , aOpis[i-1] , SPACE(20) )
          ENDIF
          if i==2 .and. ( !Empty(k1+k2+k3+k4) .or. grj=="D" .or. gtroskovi=="D" )
            ?? " "+k1+"-"+k2+"-"+K3Iz256(k3)+"-"+k4
            if IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
              ?? "("+Ocitaj(F_VRSTEP,k4,"naz")+")"
            endif
            if gRj=="D"; ?? " RJ:",idrj; endif
            if gTroskovi=="D"
              ?? "    Funk:",Funk
              ?? "    Fond:",Fond
            endif
          endif
        next
      endif

      IF cInd=="1" .and. ASCAN(aNalozi,cIdFirma+cIdVN+cBrNal)==0  // samo ako se ne nalazi u psuban
        select PSUBAN; Scatter(); select (nArr); Scatter()
        SELECT PSUBAN; APPEND BLANK
        Gather()  // stavi sve vrijednosti iz PRIPR u PSUBAN
      ENDIF
      select (nArr)
      SKIP 1
   ENDDO

   IF cInd $ "1#2" .and. !lAuto
     IF prow()>58+gPStranica; FF; Zagl11();  endif
     P_NRED
     ?? M
     P_NRED
     ?? "Z B I R   N A L O G A:"
     @ prow(),nColIzn  SAY nUkDugBHD PICTURE picBHD
     @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
     IF gVar1!="1"
       @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
       @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM
     ENDIF
     P_NRED
     ?? M
     nUkDugBHD:=nUKPotBHD:=nUkDugDEM:=nUKPotDEM:=0

     if gPotpis=="D"
       IF prow()>58+gPStranica; FF; Zagl11();  endif
       P_NRED
       P_NRED; F12CPI
       P_NRED
       @ prow(),55 SAY "Obrada AOP "; ?? replicate("_",20)
       P_NRED
       @ prow(),55 SAY "Kontirao   "; ?? replicate("_",20)
     endif
     FF
   ELSEIF cInd=="3"
      if prow()>54+gPStranica
        PrenosDNal()
      endif
   ENDIF
RETURN
*}


/*! \fn PrenosDNal()
 *  \brief Ispis prenos na sljedecu stranicu
 */
 
function PrenosDNal()
*{
? m
  ? PADR("UKUPNO NA STRANI "+ALLTRIM(STR(nStr)),30)+":"
   @ prow(),nColIzn  SAY nTSDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nTSPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nTSDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nTSPotDEM PICTURE picDEM
   ENDIF
  ? m
  ? PADR("DONOS SA PRETHODNE STRANE",30)+":"
   @ prow(),nColIzn  SAY nUkDugBHD-nTSDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nUkPotBHD-nTSPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nUkDugDEM-nTSDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nUkPotDEM-nTSPotDEM PICTURE picDEM
   ENDIF
  ? m
  ? PADR("PRENOS NA NAREDNU STRANU",30)+":"
   @ prow(),nColIzn  SAY nUkDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM
   ENDIF
  ? m
  FF
  nTSDugBHD:=nTSPotBHD:=nTSDugDEM:=nTSPotDEM:=0   // tekuca strana
RETURN
*}


/*! \fn IzvodBanke()
 *  \brief Formira nalog u pripremi na osnovu txt-izvoda iz banke
 */
 
function IzvodBanke()
*{
 LOCAL nIF:=1, cBrNal:=""
 PRIVATE cLFSpec := "A:\ZEN*.", cIdVn:="99"

 O_NALOG
 O_PRIPR
 if reccount2()<>0
   Msg("Priprema mora biti prazna !")
   closeret
 endif

 Box(,20,75); old_m_x := m_x; old_m_y := m_y

  O_PARAMS
   PRIVATE cSection:="7",cHistory:=" ",aHistory:={}
    RPar("f1",@cLFSpec)
     RPar("f2",@cIdVn)
      SELECT PARAMS; USE

  cLFSpec:=PADR(cLFSpec,50)
  @ m_x+2, m_y+2 SAY "Lokacija i specifikacija fajla-izvoda banke" GET cLFSpec PICT "@!S30"
  @ m_x+3, m_y+2 SAY "Vrsta naloga koji se formira (prazno-ne formiraj nalog):" GET cIdVn
  READ; ESC_BCR
  cLFSpec:=TRIM(cLFSpec)

  O_PARAMS
   PRIVATE cSection:="7",cHistory:=" "; aHistory:={}
    WPar("f1",cLFSpec)
     WPar("f2",cIdVn)
      SELECT PARAMS; USE

  aFajlovi := DIRECTORY(cLFSpec)
  IF LEN(aFajlovi)<1
    MsgBeep("Na izabranoj lokaciji ne postoji nijedan specificirani fajl!")
    BoxC(); CLOSERET
  ENDIF

  FOR i:=1 TO LEN(aFajlovi); aFajlovi[i]:=PADR(aFajlovi[i,1],20); NEXT
  nIF := Menu("IBan",aFajlovi,nIF,.f.)
  IF nIF<1
    BoxC(); CLOSERET
  ELSE
    // zatvaranje prozora menija
    // -------------------------
    Menu("IBan",aFajlovi,0,.f.)
  ENDIF
  cIme := LEFT(cLFSpec,2)+"\"+TRIM(aFajlovi[nIF])
  m_x := old_m_x; m_y := old_m_y
  @ m_x+4, m_y+2 SAY "Izabran fajl:"
  @ m_x+4, col()+2 SAY cIme COLOR INVERT

  nH   := fopen(cIme)
  nRBr := 0

    if gBrojac=="1"
     select NALOG; set order to 1
     seek gfirma+cidvn+"X"; skip -1
     if idfirma+idvn==gfirma+cidvn
       cbrnal:=NovaSifra(brnal)
     else
       cbrnal:="0001"
     endif
    else
     select NALOG; set order to 2
     seek gfirma+"X"; skip -1; cbrnal:=padl(alltrim(str(val(brnal)+1)),4,"0")
    endif


  StartPrint(.t.)

  P_COND2
  ? "⁄ƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø"
  ? "≥R.BR≥ DATUM  ≥ZIRO-RACUN      ≥POSILJAOC: NAZIV, ADRESA I MJESTO                                                         ≥POZIV NA BROJ                     ≥"
  ? "√ƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¡¬ƒƒƒƒƒƒƒƒ¬ƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¥"
  ? "≥SIFRA I OPIS SVRHE DOZNAKE                                     ≥     IZNOS    ≥D/P≥MAT.BROJ     ≥VR.UPL.≥VR.PRIH.≥ DAT.OD ≥ DAT.DO ≥OPè≥ P.NA BR. ≥BUDZ.ORG.≥"
  ? "¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒŸ"

  DO WHILE .T.

    cString := Freadln(nH,1,268)
    cString := STRTRAN( cString , CHR(0) , " " )

    IF LEN(TRIM(cString)) < 2
      EXIT
    ENDIF

    w_DatDok := CTOD( SUBSTR( cString , 1 , 2 ) + "." +;
                      SUBSTR( cString , 3 , 2 ) + "." +;
                      SUBSTR( cString , 5 , 2 ) )

    w_ZiroR  := SUBSTR( cString ,   7 , 16 )
    w_SaljeN := SUBSTR( cString ,  23 , 30 )
    w_SaljeA := SUBSTR( cString ,  53 , 30 )
    w_SaljeM := SUBSTR( cString ,  83 , 30 )
    w_PNABR  := SUBSTR( cString , 113 , 26 )
    w_SifDoz := SUBSTR( cString , 139 ,  3 )
    w_SvrDoz := SUBSTR( cString , 142 , 60 )

    w_Iznos  := VAL( SUBSTR( cString , 202 , 10 )+"."+;
                     SUBSTR( cString , 212 ,  2 ) )

    w_DugPot := SUBSTR( cString , 214 ,  1 )
    w_MatBr  := SUBSTR( cString , 215 , 13 )
    w_VrUpl  := SUBSTR( cString , 228 ,  1 )
    w_VrPrih := SUBSTR( cString , 229 ,  6 )

    w_DatOd  := CTOD( SUBSTR( cString , 235 , 2 ) + "." +;
                      SUBSTR( cString , 237 , 2 ) + "." +;
                      SUBSTR( cString , 239 , 2 ) )

    w_DatDo  := CTOD( SUBSTR( cString , 241 , 2 ) + "." +;
                      SUBSTR( cString , 243 , 2 ) + "." +;
                      SUBSTR( cString , 245 , 2 ) )

    w_Opcina := SUBSTR( cString , 247 ,  3 )
    w_PNABR2 := SUBSTR( cString , 250 , 10 )
    w_BudOrg := SUBSTR( cString , 260 ,  7 )

    ++nRBr

    // TEST:
    // ? nRBr, w_datdok, w_ziror, w_opcina, w_pnabr2, w_budorg

    IF prow()>60
      FF
      ? "⁄ƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø"
      ? "≥R.BR≥ DATUM  ≥ZIRO-RACUN      ≥POSILJAOC: NAZIV, ADRESA I MJESTO                                                         ≥POZIV NA BROJ                     ≥"
      ? "√ƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¡¬ƒƒƒƒƒƒƒƒ¬ƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¥"
      ? "≥SIFRA I OPIS SVRHE DOZNAKE                                     ≥     IZNOS    ≥D/P≥MAT.BROJ     ≥VR.UPL.≥VR.PRIH.≥ DAT.OD ≥ DAT.DO ≥OPè≥ P.NA BR. ≥BUDZ.ORG.≥"
      ? "¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒŸ"
    ENDIF


    ? " "+STR(nRBR,4), w_DatDok, w_ZiroR, PADR(TRIM(w_SaljeN)+", "+TRIM(w_SaljeA)+", "+TRIM(w_SaljeM),90), w_PNABR
    ? " "+w_SifDoz, w_SvrDoz, w_Iznos, IF(w_DugPot=="1","dug","pot"), w_MatBr
    ?? " "+PADR(w_VrUpl,7), PADR(w_VrPrih,8), w_DatOd, w_DatDo, w_Opcina, w_PNABR2, w_BudOrg
    ? REPL("-",160)

    IF !EMPTY(cIdVn)
      SELECT PRIPR
      APPEND BLANK
      REPLACE idfirma   with  gFirma      ,;
              idvn      with  cIdVn       ,;
              brnal     with  cBrNal      ,;
              datdok    with  w_datdok    ,;
              d_p       with  w_DugPot    ,;
              iznosbhd  with  w_iznos     ,;
              rbr       with  str(nRBr,4) ,;
              idkonto   with  w_VrPrih    ,;
              opis      with  w_SvrDoz
    ENDIF

  ENDDO

  FClose(nH)

  FF
  EndPrint()

  IF !EMPTY(cIdVn)
    MsgBeep("Preuzimanje izvoda zavrseno. Vratite se u pripremu tipkom <Esc>!")
  ELSE
    MsgBeep("Pregled izvoda zavrsen. Vratite se u pripremu tipkom <Esc>!")
  ENDIF

 BoxC()
CLOSERET
return
*}



/*! \fn K3Iz256(cK3)
 *  \brief 
 *  \param cK3
 */
 
function K3Iz256(cK3)
*{
 LOCAL i,c,o,d:=0,aC:={" ","0","1","2","3","4","5","6","7","8","9"}
  IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
    IF !EMPTY(cK3)
      FOR i:=LEN(cK3) TO 1 STEP -1
        d += ASC(SUBSTR(cK3,i,1)) * 256^(LEN(cK3)-i)
      NEXT
      cK3:=""
      DO WHILE .t.
        c := INT(d/11)
        o := d%11
        cK3 := aC[o+1] + cK3
        IF c=0; EXIT; ENDIF
        d := c
      ENDDO
    ENDIF
    cK3:=PADL(cK3,3)
  ENDIF
RETURN cK3
*}


/*! \fn K3U256(cK3)
 *  \brief
 *  \cK3
 */
 
function K3U256(cK3)
*{
LOCAL i,c,o,d:=0,aC:={" ","0","1","2","3","4","5","6","7","8","9"}
  IF !EMPTY(cK3) .and. IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
    FOR i:=1 TO LEN(cK3)
      p := ASCAN( aC , SUBSTR(cK3,i,1) ) - 1
      d += p * 11^(LEN(cK3)-i)
    NEXT
    cK3:=""
    DO WHILE .t.
      c := INT(d/256)
      o := d%256
      cK3 := CHR(o) + cK3
      IF c=0; EXIT; ENDIF
      d := c
    ENDDO
    cK3:=PADL(cK3,2,CHR(0))
  ENDIF
RETURN cK3



/*! \fn KontrZbNal()
 *  \brief Kontrola zbira naloga
 */
 
function KontrZbNal()
*{

PushWa()
Box("kzb",12,70,.f.,"Kontrola zbira naloga")
      set cursor on
      cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal

      if gNW=="D"
       @ m_x+1,m_y+1 SAY "       Firma: "+cIDFirma
      else
       @ m_x+1,m_y+1 SAY "       Firma:" GET cIDFirma VALID {|| P_Firma(@cIdFirma,1,20),cidfirma:=left(cidfirma,2),.t.}
      endif
      @ m_x+2,m_y+1 SAY "Vrsta naloga:" GET cIdVn valid P_VN(@cIdVN,2,20)
      @ m_x+3,m_y+1 SAY " Broj naloga:" GET cBrNal
      READ; if lastkey()==K_ESC; BoxC(); PopWA(); return DE_CONT; endif
      set cursor off
      cIdFirma:=left(cIdFirma,2)
      set order to 1
      seek cIdFirma+cIdVn+cBrNal
      if !(IdFirma+IdVn+BrNal==cIdFirma+cIdVn+cBrNal)
        Msg("Ovaj nalog nije unesen ...",10)
        BoxC()
        PopWa()
        return DE_CONT
      endif

      dug:=dug2:=Pot:=Pot2:=0
      do while  !eof() .and. (IdFirma+IdVn+BrNal==cIdFirma+cIdVn+cBrNal)
        if D_P=="1"; dug+=IznosBHD; dug2+=iznosdem; else; pot+=IznosBHD;pot2+=iznosdem; endif
        skip
      enddo
      SKIP -1
      Scatter()

      cPic:=FormPicL("9 "+gPicBHD,20)
      @ m_x+5,m_y+2 SAY "Zbir naloga:"
      @ m_x+6,m_y+2 SAY "     Duguje:"
      @ m_x+6,COL()+2 SAY Dug PICTURE cPic
      @ m_x+6,COL()+2 SAY Dug2 PICTURE cPic
      @ m_x+7,m_y+2 SAY "  Potrazuje:"
      @ m_x+7,COL()+2 SAY Pot  PICTURE cPic
      @ m_x+7,COL()+2 SAY Pot2  PICTURE cPic
      @ m_x+8,m_y+2 SAY "      Saldo:"
      @ m_x+8,COL()+2 SAY Dug-Pot  PICTURE cPic
      @ m_x+8,COL()+2 SAY Dug2-Pot2  PICTURE cPic
      InkeySc(0)
      IF round(Dug-Pot,2) <> 0  .and. gRavnot=="D"
        cDN:="N"
        set cursor on
        @ m_x+10,m_y+2 SAY "Zelite li uravnoteziti nalog (D/N) ?" GET cDN valid (cDN $ "DN") pict "@!"
        read
        if cDN=="D"
          _Opis:=PADR("?",LEN(_opis))
          _BrDok:=""
          _D_P:="2"; _IdKonto:=SPACE(7)
          @ m_x+11,m_y+2 SAY "Opis" GET _opis  WHEN {|| USTipke(),.t.} VALID {|| BosTipke(),.t.} PICT "@S40"
          @ m_x+12,m_y+2 SAY "Staviti na konto ?" GET _IdKonto valid P_Konto(@_IdKonto)
          @ m_x+12,col()+1 SAY "Datum dokumenta:" GET _DatDok
          read
          if lastkey()<>K_ESC
            _Rbr:=str(val(_Rbr)+1,4)
            _IdPartner:=""
            _IznosBHD:=Dug-Pot
            DinDem(NIL,NIL,"_IZNOSBHD")
            append blank
            Gather()
          endif
        endif // cDN=="D"
      endif  // dug-pot<>0
BoxC()
PopWA()

return
*}


/*! \fn BrDokOK()
 *  \brief
 */
 
function BrDokOK()
*{
local nArr
local lOK
local nLenBrDok
if (!IsRamaGlas())
	return .t.
endif
nArr:=SELECT()
lOK:=.t.
nLenBrDok:=LEN(_brDok)
select konto
seek _idkonto
if field->oznaka="TD"
	select rnal
	hseek PADR(_brDok,10)
	if !found() .or. empty(_brDok)
		MsgBeep("Unijeli ste nepostojeci broj radnog naloga. Otvaram sifrarnik radnih##naloga da biste mogli izabrati neki od postojecih!")
		P_Rnal(@_brDok,9,2)
		_brDok:=PADR(_brDok,nLenBrDok)
		ShowGets()
	endif
endif
SELECT (nArr)
return lOK
*}



/*! \fn SetTekucaRJ(cRJ)
 *  \brief Setuje tekucu radnu jedinicu 
 *  \param cRJ
 */
 
function SetTekucaRJ(cRJ)
*{
local nArr
local lUsed
nArr:=SELECT()
lUsed:=.t.
select (F_PARAMS)
if !used()
	lUsed:=.f.
	O_PARAMS
endif
Private cSection:="1",cHistory:=" ",aHistory:={}
Params1()
WPar("tj",cRJ)
if !lUsed
	select params
	use
endif
select (nArr)
return
*}


/*! \fn GetTekucaRJ()
 *  \brief Daje tekucu radnu jedinicu
 */

function GetTekucaRJ()
*{
local nArr
local lUsed
local cRJ
nArr:=SELECT()
lUsed:=.t.
cRJ:=SPACE(4)
select (F_PARAMS)
if !used()
	lUsed:=.f.
	O_PARAMS
endif
Private cSection:="1",cHistory:=" ",aHistory:={}
Params1()
RPar("tj",@cRJ)
if !lUsed
	select params
	use
endif
select (nArr)
return (PADR(cRJ,4))
*}

