#include "\cl\sigma\fmk\virm\virm.ch"


function UnosUpl()
*{
MsgBeep("Nije realizovano - promjene 2001 ...")
return

O_STAMP2
O_VRPRIM2
O_PARTN
O_KUMUL2
O_PRIPR2


  ImeKol:={ { "R.br.", {|| rbr} },;
            { "U korist racuna", {|| kome_txt} } }

    //        { "Nacin placanja", {|| PADR(IF(nacpl=="1","domaca v.("+ALLTRIM(ValDomaca())+")"," devizno ("+ALLTRIM(ValPomocna())+")"),14)} } }
  //Kol:={1,2,3}
  Kol:={1,2}
  PrikUpl(1)
  @ 12,0 SAY ""
  ObjDBedit("PripUpl",6,77,{|| Editov2()},"","PRIPREMA UPLATNICE",;
            .f.,{"<c-N>   Nova uplatnica", "<c-T>   Brisanje",;
                 "<Enter> Ispravka", "<c-F9>  Brisi sve",;
                 "<a-A>   Azuriranje", "<c-P>   Stampanje",;
                 "<a-R>   Rekapitulacija", "<c-O>   Ostalo"},2,,,)
  PrikUpl(0)
CLOSERET



FUNCTION Editov2()
 LOCAL nRec:=RECNO(),i:=0,lVrati:=DE_CONT
 DO CASE

  case Ch==K_ALT_A
     IF RECCOUNT2()>0
       Azuriraj2()
       lVrati:=DE_REFRESH
     ELSE
       Msg("Nema nista za azuriranje!")
     ENDIF

  case Ch==K_CTRL_P
     StUplatnicu()
     GO nRec
     lVrati:=DE_REFRESH

  case Ch==K_ALT_R
     Rekapit2()
     GO nRec
     lVrati:=DE_REFRESH

  case Ch==K_CTRL_O
     O_PARAMS
     private cSection:="1",cHistory:=" "; aHistory:={}
     Rpar("da",@gDatum)
     Rpar("fi",@gFirma)
     Rpar("mj",@gMjesto)
     UsTipke()
     set cursor on
      aNiz:={ {"Firma - nalogodavac", "gFirma", "P_Firme(@gFirma)", , },;
              {"Inicijalni datum uplate", "gDatum", , , },;
              {"Mjesto uplate", "gMjesto", , , } }
      VarEdit(aNiz,12,5,18,74,"OSTALI PARAMETRI","B1")
     BosTipke()
     if lastkey()<>K_ESC
       Wpar("da",gDatum)
       Wpar("fi",gFirma)
       Wpar("mj",gMjesto)
       select params; use
     endif
     use
     SELECT PRIPR2

  case Ch==K_CTRL_T
     if Pitanje(,"Zelite li izbrisati ovu stavku ?","D")=="D"
      delete
       nRec:=RECNO()
       GO TOP
       DO WHILE !EOF()
         Scatter()
         _rbr:=++i
         Gather()
         SKIP 1
       ENDDO
       GO nRec
      lVrati:=DE_REFRESH
     endif

   case Ch==K_ENTER
    if reccount2()==0
      Msg("Ako zelite zapoceti unos nove uplatnice: <Ctrl-N>")
      return DE_CONT
    endif
    if !(EditPR2(1)==0)
      lVrati:=DE_REFRESH
    endif

  case Ch==K_CTRL_N  // nove stavke
        EditPR2(0)
        lVrati:=DE_REFRESH

  case Ch==K_CTRL_F9
      if Pitanje(,"Zelite li izbrisati cijelu pripremu ?","N")=="D"
         zapp()
         lVrati:=DE_REFRESH
      endif

 ENDCASE
 PrikUpl(2)
RETURN lVrati

PROCEDURE PrikUpl(nIndik)
 LOCAL cbsstara:=ShemaBoja("B1")
 IF nIndik==1
   Prozor1(1,0,12,79,"TEKUCA UPLATNICA",cbnaslova,,cbokvira,cbteksta,2)
 ENDIF
 FOR i:=1 TO 9; @ 1+i,36 SAY "³" COLOR SUBSTR(cbteksta,1,5); NEXT
 @  2, 2 SAY "NALOGODAVAC:" COLOR SUBSTR(cbteksta,1,5)
// @  2,38 SAY "ziro r.broj:" COLOR SUBSTR(cbteksta,1,5)
// @  3,38 SAY "poziv na br.zad." COLOR SUBSTR(cbteksta,1,5)
 @  5, 2 SAY "SVRHA DOZNAKE:" COLOR SUBSTR(cbteksta,1,5)
 @  6,38 SAY "IZNOS:" COLOR SUBSTR(cbteksta,1,5)
 @  8, 2 SAY "PRIMALAC:   " COLOR SUBSTR(cbteksta,1,5)
 @  8,38 SAY "ziro r.broj:" COLOR SUBSTR(cbteksta,1,5)
 @  9,38 SAY "poziv na br.od." COLOR SUBSTR(cbteksta,1,5)
// @ 11, 2 SAY "OJS:" COLOR SUBSTR(cbteksta,1,5)
// @ 11,23 SAY ",dat.DPO:" COLOR SUBSTR(cbteksta,1,5)
// @ 11,40 SAY ",mj.i d.upl. :" COLOR SUBSTR(cbteksta,1,5)
// @ 11,70 SAY "," COLOR SUBSTR(cbteksta,1,5)
 IF EMPTY(u_korist)
   cPom:=LomiGa(ALLTRIM(kome_txt),1,0,33)
   cPFirma1:=""; cPFirma2:=PADC(ALLTRIM(LEFT(cPom,33)),33)
   cPFirma3:=PADC(ALLTRIM(SUBSTR(cPom,34)),33)
 ELSE
   cPFirma1:=""; cPFirma2:=PADC(ALLTRIM(kome_txt),33)
   cPFirma3:=PADC(ALLTRIM(kome_sj),33)
 ENDIF
 IF EMPTY(na_teret)    // ovo se ne bi trebalo desavati
   cNFirma1:=cNFirma2:=cNFirma3:=""
 ELSE
   cNFirma1:=""; cNFirma2:=PADC(ALLTRIM(ko_txt),33)
   cNFirma3:=PADC(ALLTRIM(ko_sj),33)
 ENDIF
 nPom:=19
 DO WHILE SUBSTR(svrha_doz,nPom,1)!=" "; nPom--; ENDDO
 cSvrha1:=PADC(ALLTRIM(LEFT(svrha_doz,nPom)),18)
 cPom:=ALLTRIM(SUBSTR(svrha_doz,nPom))
 cPom:=LomiGa(cPom,1,0,33)
 cSvrha2:=PADC(ALLTRIM(LEFT(cPom,33)),33)
 cSvrha3:=PADC(ALLTRIM(SUBSTR(cPom,34)),33)
 @ 2,14 SAY PADR(cNFirma1,21) COLOR SUBSTR(cbteksta,15)
// @ 2,50 SAY PADC(ko_zr,22) COLOR SUBSTR(cbteksta,15)
 @ 3, 2 SAY PADR(cNFirma2,33) COLOR SUBSTR(cbteksta,15)
// @ 3,54 SAY PADC(pnabrzad,20) COLOR SUBSTR(cbteksta,15)
 @ 4, 2 SAY PADR(cNFirma3,33) COLOR SUBSTR(cbteksta,15)
 @ 5,16 SAY PADR(cSvrha1,19) COLOR cbnaslova
 @ 6, 2 SAY PADR(cSvrha2,33) COLOR cbnaslova
 //@ 5,60 SAY "Sifra" COLOR cbteksta
 //@ 5,67 SAY sifra   COLOR cbnaslova
 //@ 6,44 SAY PADC(IF(nacpl=="1",ALLTRIM(ValDomaca())+"=",ALLTRIM(ValPomocna())+"=")+ALLTRIM(IF(gNumT=="D",FormNum1(iznos),STRTRAN(STR(iznos),".",","))),20) COLOR cbnaslova
 @ 7, 2 SAY PADR(cSvrha3,33) COLOR cbnaslova
 @ 8,14 SAY PADR(cPFirma1,21) COLOR SUBSTR(cbteksta,15)
 @ 8,50 SAY PADC(kome_zr,22) COLOR SUBSTR(cbteksta,15)
 @ 9, 2 SAY PADR(cPFirma2,33) COLOR SUBSTR(cbteksta,15)
 //@ 9,54 SAY PADC(pnabrod,20) COLOR SUBSTR(cbteksta,15)
 @ 10,2 SAY PADR(cPFirma3,33) COLOR SUBSTR(cbteksta,15)
// @ 11, 6 SAY PADR(orgjed,17) COLOR cbnaslova
// @ 11,32 SAY dat_dpo COLOR cbnaslova
// @ 11,54 SAY PADC(ALLTRIM(mjesto),16) COLOR cbnaslova
// @ 11,71 SAY DTOC(dat_upl) COLOR cbnaslova
 IF nIndik==0; Prozor0(); ENDIF
 ShemaBoja(cbsstara)
RETURN


FUNCTION EditPR2(nInd)
 LOCAL nVrati:=0,aNiz,nRec:=RECNO()
 DO WHILE .t.
  DO CASE
    CASE nInd==0   // unosenje novih stavki
      GO BOTTOM
      SKIP 1
    CASE nInd==1   // ispravka stavke
  ENDCASE
  Scatter()
  // ovdje prvo definisimo sta se sve treba unositi u stavki
  aNiz:={ { "Tip uplate", "_svrha_pl", "P_VrPrim2(@_svrha_pl)", "@!" , },;
          { "U korist (sifra partnera)", "_u_korist", "P_Firme(@_u_korist)", "@!", "UplDob2()"},;
          { "Svrha doznake", "_svrha_doz", , "@S40", "IniProm2()"},;
          { "Uplata u (1-"+ALLTRIM(ValDomaca())+",2-"+ALLTRIM(ValPomocna())+")", "1", "ValPl2()", , },;
          { "Iznos", "_iznos", , , };
         }

          //{ "Poz.na br. odobr","_PnaBrOd",,,} }
  IF nInd==0
    SKIP -1
     _rbr:=rbr+1
    SKIP 1
    IF EMPTY(gDatum)
      IF gIDU=="D"
        _dat_upl:=date()  // gdatum
        _dat_dpo:=date()  //gDatum
      ELSE
        _dat_upl:=gdatum
        _dat_dpo:=gDatum
      ENDIF
    ELSE
      _dat_upl:=gdatum
      _dat_dpo:=gDatum
    ENDIF
  ENDIF
  IF VarEdit(aNiz,5,5,24,74,IF(nInd==0,"NOVA UPLATNICA-","ISPRAVKA UPLATNICE ")+"BR. "+ALLTRIM(STR(_rbr)),"B1")
    IF nInd==0
      APPEND BLANK
    ENDIF
    SELECT PARTN
    GO TOP
    HSEEK gFirma
    _ko_txt:=naz
    _ko_sj:=mjesto
    //_ko_zr:=IF(_nacpl=="1",ziror,dziror)
    _ko_zr:=ziror
    SELECT PRIPR2
    _na_teret:=gFirma
    _orgjed:=gOrgJed
    _mjesto:=gMjesto
    Gather()
    IF nInd==1; nVrati:=1; EXIT; ENDIF
  ELSE
    EXIT
  ENDIF
 ENDDO
 GO nRec
RETURN nVrati

FUNCTION UplDob2()
 LOCAL lVrati:=.f.
 SELECT VRPRIM2
 GO TOP
 HSEEK _svrha_pl
 IF dobav=="D"; lVrati:=.t.; ENDIF
 SELECT PRIPR2
RETURN lVrati

FUNCTION IniProm2()        // autom.popunjavanje nekih podataka
 SELECT VRPRIM2
 IF dobav=="D"
   //IF EMPTY(_nacpl).and.EMPTY(_iznos).and.EMPTY(_svrha_doz)
   IF EMPTY(_iznos).and.EMPTY(_svrha_doz)
     _svrha_doz:=PADR(pom_txt,LEN(_svrha_doz))
     //_nacpl:=nacin_pl
   ENDIF
   SELECT PARTN
   GO TOP
   HSEEK _u_korist
   _kome_txt:=naz
   _kome_sj:=mjesto
 ELSE
   _u_korist:=SPACE(LEN(_u_korist))
   //IF EMPTY(_nacpl).and.EMPTY(_iznos).and.EMPTY(_svrha_doz)
   IF EMPTY(_iznos).and.EMPTY(_svrha_doz)
     _svrha_doz:=PADR(pom_txt,LEN(_svrha_doz))
     //_nacpl:=nacin_pl
     _kome_txt:=naz
     _kome_sj:=SPACE(LEN(_kome_sj))
   ENDIF
 ENDIF
 //_sifra:=VRPRIM2->sifra  // rubrika sifra na uplatnici
 SELECT PRIPR2
RETURN .t.

FUNCTION ValPl2()
 LOCAL lVrati:=.f.
 //IF _nacpl$"12"
   lVrati:=.t.
   IF EMPTY(_u_korist)
     _kome_zr:=VRPRIM2->racun
   ELSE
     _kome_zr:=IF(_nacpl=="1",PARTN->ziror,PARTN->dziror)
   ENDIF
 //ENDIF
RETURN lVrati



function Azuriraj2()
*{
if Pitanje("p1","Zelite li izvrsiti azuriranje podataka (D/N) ?","N")=="N"
	return
endif
select F_KUMUL2
append from PRIPR2
select (F_VIPRIP2)
zap
return
*}




**********************************
* stampanje virmana
**********************************

PROCEDURE StUplatnicu()
 LOCAL fPrviput
 LOCAL gKRazmLin,cKPoc,cPom,nPom,cPom1:="",nOblast:=SELECT(),cMakro:=""
 LOCAL nKol:=0, nRed:=0
 PRIVATE cKrat1:="",cKrat2:="",cmjesidat:=""
 PRIVATE cPFirma1:="",cPFirma2:="",cPFirma3:=""
 PRIVATE cNFirma1:="",cNFirma2:="",cNFirma3:=""
 PRIVATE cSvrha1:="", cSvrha2:="", cSvrha3:=""

 nKoliko:=999 // koliko uplatnica od startne pozicije

 Box(,1,70)
  @ m_x+1,m_y+2 SAY "Broj uplatnica od sljedece pozicije:" GET nKoliko pict "999"
  read
 BoxC()
 START PRINT RET
 fPrviPut:=.t.


 nDoSada:=0
 do while !eof() // perforirani papir

 ++nDoSada
 if nKoliko<nDoSada
   exit
 endif

 if !fprviput
  INI
 else
  fPrviPut:=.f.
 endif
 cPom1:=IF(gnLmarg>0,SPACE(gnLMarg),"")
 gKRazmLin:=KonvKod(gKLpomak)
 //IF nacpl=="1"      // za virmane u domacoj valuti
   cKPoc:=KonvKod(gUKpocet0)+KonvKod(gUKpocet1)
 //ELSE               // devizni virmani
 //  cKPoc:=KonvKod(gUKpocet0)+KonvKod(gUKpocet2)
 //ENDIF
 IF EMPTY(u_korist)
   cPom:=LomiGa(ALLTRIM(kome_txt),1,0,33)
   cPFirma1:=""; cPFirma2:=PADC(ALLTRIM(LEFT(cPom,33)),33)
   cPFirma3:=PADC(ALLTRIM(SUBSTR(cPom,34)),33)
 ELSE
   cPFirma1:=""; cPFirma2:=PADC(ALLTRIM(kome_txt),33)
   cPFirma3:=PADC(ALLTRIM(kome_sj),33)
 ENDIF
 IF EMPTY(na_teret)    // ovo se ne bi trebalo desavati
   cNFirma1:=cNFirma2:=cNFirma3:=""
 ELSE
   cNFirma1:=""; cNFirma2:=PADC(ALLTRIM(ko_txt),33)
   cNFirma3:=PADC(ALLTRIM(ko_sj),33)
 ENDIF
 nPom:=19
 DO WHILE SUBSTR(svrha_doz,nPom,1)!=" "; nPom--; ENDDO
 cSvrha1:=PADC(ALLTRIM(LEFT(svrha_doz,nPom)),18)
 cPom:=ALLTRIM(SUBSTR(svrha_doz,nPom))
 cPom:=LomiGa(cPom,1,0,33)
 cSvrha2:=PADC(ALLTRIM(LEFT(cPom,33)),33)
 cSvrha3:=PADC(ALLTRIM(SUBSTR(cPom,34)),33)
 //CSIFRA:=sifra  //NEKA NOVA SARAJEVSKA FORA   7-karaktera

 /////////////
 //IF nacpl=="1".and.gUPrecrt1=="N".or.nacpl=="2".and.gUPrecrt2=="N"
 IF gUPrecrt1=="N".or.nacpl=="2".and.gUPrecrt2=="N"
   cKrat1:="     "
 //ELSEIF nacpl=="1".and.gUPrecrt1=="D".or.nacpl=="2".and.gUPrecrt2=="D"
 ELSEIF gUPrecrt1=="D".or.nacpl=="2".and.gUPrecrt2=="D"
   cKrat1:="xxx  "
 ELSE
   //cKrat1:=PADC(ALLTRIM(IF(nacpl=="1",ValDomaca(),ValPomocna())),6)
   cKrat1:=PADC(ALLTRIM(ValDomaca()),6)
 ENDIF

 //IF nacpl=="1"
   IF gUPrecrt1!="D"
     cKrat2:="="
   ELSE
     cKrat2:=ALLTRIM(ValDomaca())+"="
   ENDIF
 //ELSE
 //  IF gUPrecrt2!="D"
 //    cKrat2:="="
 //  ELSE
 //    cKrat2:=ALLTRIM(ValPomocna())+"="
 //  ENDIF
 //ENDIF

 IF gNumT=="D"
   cKrat2:=cKrat2+IF( iznos==0.and.gINulu=="N" , SPACE(6) , ALLTRIM(FormNum1(iznos)) )
 ELSE
   cKrat2:=cKrat2+IF( iznos==0.and.gINulu=="N" , SPACE(6) , ALLTRIM(STRTRAN(STR(iznos),".",",")) )
 ENDIF

 cKrat2:=PADC(cKrat2,20)
 cMjesIDat:=ALLTRIM(mjesto)+","+FormDat1(dat_upl)
 /////////////


 PRIVATE lPrvi:=.f.,lSTAMP:=.f.,nTRed:=0
 nKol:=0; nRed:=0

 SELECT F_STAMP2
 GO TOP
 DO WHILESC !EOF()
   SELECT (nOblast)
   cMakro:=ALLTRIM(STAMP2->id)
   IF !lPrvi.and.STAMP2->stampati=="D"  // ako nije prvi red odstampan
     Setpxlat()
     ?? cKPoc+cPom1
     KonvTable()
     lPrvi:=.t.; nRed:=STAMP2->v_pomak+gnUTmarg; lSTAMP:=.t.
   ELSEIF lPrvi.and.STAMP2->stampati=="D"
     nRed:=STAMP2->v_pomak+gnUTmarg
     lSTAMP:=.t.
   ENDIF
   IF lSTAMP
     Setpxlat()
     PodesiGlavu(STAMP2->h_pomak,nKol)
     nPom43:=KodPomaka(nRed)-nTRed
     Pomakni(gKRazmLin,nPom43*(gnRazmak/100+1))
     KonvTable()
     nTRed+=(KodPomaka(nRed)-nTRed)
     IF !(TYPE(cMakro)$"U#UE")
       nKol:=STAMP2->h_pomak+STAMP2->duzina
       IF STAMP2->ravnanje=="C".and.STAMP2->duzina>0
         ?? PADC(ALLTRIM(&cMakro),STAMP2->duzina)
       ELSEIF STAMP2->ravnanje=="D".and.STAMP2->duzina>0
         ?? PADL(ALLTRIM(&cMakro),STAMP2->duzina)
       ELSEIF STAMP2->ravnanje=="L".and.STAMP2->duzina>0
         ?? TRIM(&cMakro)
         nKol:=STAMP2->h_pomak+LEN(TRIM(&cMakro))
       ELSEIF STAMP2->duzina>0
         nKol:=STAMP2->h_pomak+LEN(TRIM(&cMakro))
         ?? TRIM(&cMakro)
       ELSE
         ?? TRIM(&cMakro)
         nKol:=STAMP2->h_pomak+LEN(TRIM(&cMakro))
       ENDIF
     ENDIF
   ENDIF
   SELECT F_STAMP2
   SKIP 1
   lSTAMP:=.f.
 ENDDO

 IF gUTrakas=="D"
  Setpxlat()
//  ?? gKRazmLin+CHR((KodPomaka(gnURazTrak)-nTRed)*(gnRazmak/100+1))
  Pomakni( gKRazmLin , (KodPomaka(gnURazTrak)-nTRed)*(gnRazmak/100+1) )

  KonvTable()
 ELSE
  ?
 ENDIF
   SELECT(nOblast)
   if gUTraKas=="N"
     exit
   else
     skip
   endif
 ENDDO  // eof()

 ?? KonvKod(gUKKraj0)
 END PRINT
 SELECT (nOblast)
RETURN

PROCEDURE Rekapit2()
 LOCAL aNiz:={},aRek:={},nPom:=0
 SELECT PRIPR2
 GO TOP
 //COUNT TO nPom FOR nacpl=="1"
 //IF nPom>1; AADD(aRek,"1"); ENDIF
 //GO TOP
 //COUNT TO nPom FOR nacpl=="2"
 //IF nPom>1; AADD(aRek,"2"); ENDIF
 //IF LEN(aRek)<1
 //  Msg("Nema svrhe praviti rekapitulaciju!")
 //  RETURN
 //ENDIF
 START PRINT RET
 aNiz:={ {"PRIMALAC"   , {|| kome_txt}  , .f., "C", 55, 0, 1, 1 },;
         {"IZNOS      ", {|| iznos}     , .t., "N", 15, 2, 1, 2 };
       }
 FOR i:=1 TO LEN(aRek)
  aNiz[2,1]:=IF(aRek[i]=="1","IZNOS ("+ALLTRIM(ValDomaca())+")","IZNOS ("+ALLTRIM(ValPomocna())+")")
  GO TOP
  StampaTabele(aNiz,,gnLMarg,gTabela,{|| .t.},gA43=="4",;
               "REKAPITULACIJA "+IF(aRek[i]=="1","UPLATA U "+ValDomaca(),"DEVIZNIH UPLATA"),;
               {|| Blok212(aRek[i])})
 NEXT
 END PRINT
RETURN

FUNCTION Blok212(cNacPl)   // "for" blok
RETURN IF(cNacPl==nacpl,.t.,.f.)

