#include "\cl\sigma\fmk\virm\virm.ch"

function PrenosLD()
*{
// ovom procedurom cu uzeti iz pripreme zeljena konta i baciti ih u
// virmane

O_BANKE
O_JPRIH
O_SIFK
O_SIFV
O_KRED
O_REKLD
O_PARTN
O_VRPRIM
O_LDVIRM
O_PRIPR

cKome_Txt:=""
lOpresa:=.t. //( IzFMKINI("VIRM","Opresa","N",PRIVPATH) == "D" )
cPozBr:=""

qqKonto:=padr("6;",60)
dDatVir:=date()

private _godina:=val(IzFmkIni("LDVIRM","Godina",str(year(date()),4), KUMPATH))
private _mjesec:=val(IzFmkIni("LDVIRM","Mjesec",str(mont(date()),2), KUMPATH))
private cBezNula:="D"

cPNaBr:=IzFmkIni("LDVIRM","PozivNaBr"," ", KUMPATH)
cPnabr:=padr(cPnabr,10)
// dodati na opis "plate za mjesec ...."
cOpisPlus1:=IzFmkIni("LDVIRM","OpisPlus1","D", KUMPATH)
cOpisPlus2:=IzFmkIni("LDVIRM","OpisPlus2","D", KUMPATH)
cKo_ZR:=IzFmkIni("LDVIRM","KoRacun"," ", KUMPATH)
dPod:=ctod("")
dPdo:=ctod("")


Box(,10,70)
 @ m_x+1,m_y+2 SAY "PRENOS REKAPITULACIJE IZ LD -> VIRM"

 cIdBanka:=padr(cko_zr,3)
 @ m_x+2,m_y+2 SAY "Posiljaoc (sifra banke):       " GET cIdBanka valid  OdBanku(gFirma,@cIdBanka)
 read
 cKo_zr:=cIdBanka
 select partn; seek gFirma; select pripr
 cKo_txt := trim(partn->naz) + ", " + trim(partn->mjesto)+", "+trim(partn->adresa) + ", " + trim(partn->telefon)

 @ m_x+3,m_y+2 SAY "Poziv na broj " GET cPNABR
 @ m_x+4,m_y+2 SAY "Godina" GET _godina pict "9999"
 @ m_x+5,m_y+2 SAY "Mjesec" GET _mjesec  pict "99"
 @ m_x+7,m_y+2 SAY "Datum" GET dDatVir
 @ m_x+8,m_y+2 SAY "Porezni period od" GET dPOd
 @ m_x+8,col()+2 SAY "do" GET dPDo
 @ m_x+9,m_y+2 SAY "Formirati samo stavke sa iznosima vecim od 0 (D/N)?" GET cBezNula VALID cBezNula$"DN" PICT "@!"
 read; ESC_BCR
BoxC()

// upisi u fmk.ini
UzmiIzIni(KUMPATH+"fmk.ini","LDVIRM","PozivNaBr",cPNaBr, "WRITE")
UzmiIzIni(KUMPATH+"fmk.ini","LDVIRM","KoRacun",cKo_ZR, "WRITE")
UzmiIzIni(KUMPATH+"fmk.ini","LDVIRM","Godina",str(_godina,4), "WRITE")
UzmiIzIni(KUMPATH+"fmk.ini","LDVIRM","Mjesec",str(_mjesec,2), "WRITE")

if cOpisPlus1=="D"
  cDOpis:=", za "+STR(_MJESEC,2)+"." +str(_godina,4)
else
  cDOpis:=""
endif

cDOBrRad:=""  // opis, broj radnika

SELECT LDVIRM; GO TOP

nRbr:=0
DO WHILE !EOF()

     private cFormula:=formula
     cSvrha_pl:=id

     select VRPRIM; hseek ldvirm->id
     select partn;hseek  gFirma

     select PRIPR

     nFormula := &cFormula  // npr. RLD("DOPR1XZE01")

     select PRIPR

     IF cBezNula=="N" .or. nFormula>0

       APPEND BLANK
       replace rbr with ++nrbr, ;
               mjesto with gmjesto,;
               svrha_pl with csvrha_pl,;
               iznos with nFormula,;
               PnaBR with cPNABR,;
               VUpl with '0'

       // posaljioc
       replace na_teret with gFirma,;
               Ko_Txt with cKo_TXT,;
               Ko_ZR with cKo_ZR ,;
               mjesto with gMjesto ,;
               kome_txt with VRPRIM->naz

       //  29.01.2001 promjene ............
       //  nacpl with VRPRIM->nacin_pl, ;


       cPomOpis := trim(VRPRIM->pom_txt)+IF(!EMPTY(cDOpis)," "+cDOpis,"")+;
                   IF(!EMPTY(cDOBrRad) .and. cOpisPlus2=="D" ,", "+cDOBrRad,"")

       private _kome_zr:=""; _kome_txt:=""; _budzorg:=""
       if vrprim->idpartner="JP  " // javni prihodi
          // setuj varijable _kome_zr, _kome_txt , _budzorg
          SetJPVar()
          cKome_zr:=_kome_zr; cKome_txt:=_kome_txt; cBudzOrg:=_BudzOrg
          cBPO:=gOrgJed  // iskoristena za broj poreskog obveznika
       else
          if vrprim->dobav=="D"
             cKome_ZR:=padr(cKome_ZR,3)
             select partn; seek vrprim->idpartner; select pripr
             MsgBeep("Odrediti racun za partnera :"+vrprim->idpartner)
             OdBanku(vrprim->idpartner,@cKome_ZR)
          else
             ckome_zr:=vrprim->racun
          endif
          cBudzOrg:="" ; cBPO:=""
          dPod:=ctod(""); dPDO:=ctod("")
          cPorDBR:=""
          cBPO:=""
       endif
       replace kome_zr with cKome_zr,;
               dat_upl with dDatVir,;
               svrha_doz with cPomOpis,;
               POD with dPOD, PDO with dPDO,;
               budzorg with cBudzOrg,;
               BPO with cBPO

             //2001 -ukunuto
             //  sifra with VRPRIM->sifra
             //  dat_dpo with dDatVir,;

       //if nacpl=="2" // devize
       //       replace ko_zr with partn->dziror
       //endif

     ENDIF

     SELECT LDVIRM
     SKIP 1

ENDDO //LDVIRM


// odraditi kredite
select REKLD
seek str(_godina,4)+str(_mjesec,2)+"KRED"
do while !eof() .and. id="KRED"

     cIdKred:=substr(id,5)  // sifra kreditora

     select kred;   hseek padr(cidkred,len(kred->id))
     // partija kreditora
     cOpresa1 := KRED->zirod
     cOpresa2 := ""
     select partn;  hseek padr(cidkred,len(partn->id))
     if !found()  // dodaj kreditora u listu partnera
         append blank
         replace id with kred->id ,;
                 naz with kred->naz ,;
                 ziror with kred->ziro

                 //dziror with kred->zirod
     endif
     select vrprim; hseek PADR("KR",LEN(id))  // SPECIJALNA SIFRA ZA KREDITE
     if !found()
       APPEND BLANK
       replace id with "KR",;
               naz with "KREDIT",;
               pom_txt with "Kredit",;
               NACIN_PL WITH "1",;
               DOBAV WITH "D"
     endif

     // VRPRIM->dobav=="D"
     cSvrha_pl:=id
     select partn
     seek CIDKRED
     cU_korist:=id
     cKome_txt:=naz
     cKome_sj:=mjesto
     cNacPl:="1"

     //cKome_zr:=ziror
     cKome_ZR:=space(16)
     OdBanku(cU_korist,@cKome_ZR, .f.)

     select pripr; go top   // uzmi podatke iz prve stavke
     cKo_Txt:=ko_txt
     cKo_ZR :=ko_zr

     select partn;hseek  gFirma

     nRekLDI1:=0
     //if lOpresa
       // sumiraj istog kreditora (za razliŸite part.kredita radnika)
       nKrOpresa:=0
       SELECT REKLD
       cSKOpresa := idpartner // SK=sifra kreditora
       // krediti .............
       DO WHILE !EOF() .and. id="KRED" .and. IDPARTNER=cSKOpresa
         ++nKrOpresa
         cOpresa2:=rekld->opis2
         nRekLDI1 += rekld->iznos1
         SKIP 1
       ENDDO
       SKIP -1
     //else
     //  nRekLDI1 := rekld->iznos1
     //endif

     select PRIPR
     IF cBezNula=="N" .or. nRekLDI1>0
       APPEND BLANK
       replace rbr with ++nrbr, ;
               mjesto with gmjesto,;
               svrha_pl with "KR",;
               iznos with nRekLDI1,;
               na_teret  with gFirma,;
               kome_txt with ckome_txt ,;
               ko_txt   with cKo_txt,;
               ko_zr    with cKo_zr,;
               kome_sj  with ckome_sj,;
               kome_zr with ckome_zr,;
               dat_upl with dDatVir,;
               svrha_doz with trim(VRPRIM->pom_txt)+" "+cDOpis,;
               U_KORIST WITH cidkred  // SIFRA KREDITORA

               //dorade 2001
               //orgjed with gorgjed,;
               //sifra with VRPRIM->sifra,;
               //Ko_Txt with partn->naz,;
               //Ko_ZR with partn->ziror ,;
               //Ko_SJ  with partn->Mjesto,;
               //dat_dpo with dDatVir,;
               //nacpl with VRPRIM->nacin_pl, ;

        // popuniti podatke o partiji kredita
        if lOpresa
         if nKrOpresa>1 // vise radnika za jednog kreditora, zajednicka part.
           if !empty(cOpresa1)
              replace svrha_doz with trim(svrha_doz) +", Partija "+ TRIM(cOpresa1)
           endif
         else
           // jedan radnik
           replace svrha_doz with trim(svrha_doz) +", "+trim(cOpresa2)+", Partija:"+TRIM(REKLD->opis)
         endif
       endif        
     ENDIF
  SELECT REKLD
  skip
enddo

// odraditi isplate na tekuci racun
select REKLD
seek str(_godina,4)+str(_mjesec,2)+"IS_"
do while !eof() .and. id="IS_"

     cIdKred:=substr(id,4)  // sifra banke

     select kred;   hseek padr(cidkred,len(kred->id))
     // partija kreditora / banke
     cOpresa1 := KRED->zirod
     cOpresa2 := ""
     select partn;  hseek padr(cidkred,len(partn->id))
     if !found()  // dodaj kreditora u listu partnera
         append blank
         replace id with kred->id ,;
                 naz with kred->naz ,;
                 ziror with kred->ziro

                 //dziror with kred->zirod
     endif
     select vrprim; hseek PADR("IS",LEN(id))  // SPEC.SIFRA ZA ISPLATU NA TR
     if !found()
       APPEND BLANK
       replace id with "IS",;
               naz with "ISPLATA NA TEKUCI RACUN",;
               pom_txt with "Plata",;
               NACIN_PL WITH "1",;
               DOBAV WITH "D"
     endif

     // VRPRIM->dobav=="D"
     cSvrha_pl:=id
     select partn
     seek CIDKRED
     cU_korist:=id
     cKome_txt:=naz
     cKome_sj:=mjesto
     cNacPl:="1"

     //cKome_zr:=ziror
     cKome_ZR:=space(16)
     OdBanku(cU_korist,@cKome_ZR, .f.)

     select pripr; go top   // uzmi podatke iz prve stavke
     cKo_Txt:=ko_txt
     cKo_ZR :=ko_zr

     select partn; hseek  gFirma

     nRekLDI1:=0
     nKrOpresa:=0
     SELECT REKLD
     cSKOpresa := idpartner // SK=sifra kreditora/banke
     DO WHILE !EOF() .and. id="IS_" .and. IDPARTNER=cSKOpresa
       ++nKrOpresa
       cOpresa2:=rekld->opis2
       nRekLDI1 += rekld->iznos1
       SKIP 1
     ENDDO
     SKIP -1
     select PRIPR
     IF cBezNula=="N" .or. nRekLDI1>0
       APPEND BLANK
       replace rbr with ++nrbr, ;
               mjesto with gmjesto,;
               svrha_pl with "IS",;
               iznos with nRekLDI1,;
               na_teret  with gFirma,;
               kome_txt with ckome_txt ,;
               ko_txt   with cKo_txt,;
               ko_zr    with cKo_zr,;
               kome_sj  with ckome_sj,;
               kome_zr with ckome_zr,;
               dat_upl with dDatVir,;
               svrha_doz with trim(VRPRIM->pom_txt)+" "+cDOpis,;
               U_KORIST WITH cidkred  // SIFRA BANKE

        // popuniti podatke o partiji kredita
        if lOpresa
         if nKrOpresa>1 // vise radnika za jednog kreditora, zajednicka part.
           if !empty(cOpresa1)
              replace svrha_doz with trim(svrha_doz)
           endif
         else
           // jedan radnik
           replace svrha_doz with trim(svrha_doz) +", "+trim(cOpresa2)+", Tekuci rn:"+TRIM(REKLD->opis)
         endif
       endif        
     ENDIF
  SELECT REKLD
  skip
enddo

FillJPrih()  // popuni polja javnih prihoda

closeret

**************************************************************
function RLD(cid,nIz12,qqPartn)
*
**************************************************************
local npom1:=0, npom2:=0
if niz12=NIL
  niz12:=1
endif
// prolazim kroz rekld i trazim npr DOPR1XSA01
rekapld(cid,_godina,_mjesec,@npom1,@npom2,,@cDOBrRad,qqPartn)
if niz12==1
 return npom1
else
 return npom2
endif
return 0

****************************************************************
function Rekapld(cId,ngodina,nmjesec,nizn1,nizn2,cidpartner,copis,qqPartn)
*
****************************************************************
PushWA()
if cidpartner=NIL
  cidpartner:=""
endif
if copis=NIL
  copis:=""
endif

select rekld
if qqPartn==NIL
 hseek str(ngodina,4)+str(nmjesec,2)+cid
 nizn1:=iznos1
 nizn2:=iznos2
 cidpartner:=idpartner
 copis:=opis
 //IF lOpresa .and. ( LEFT(cId,3)=="POR" .or. LEFT(cId,4)=="DOPR" )
 //  cPozBr := ALLTRIM( STR(iznos2,20,2) )
 //ELSE
 //  cPozBr := ""
 //ENDIF
else
 nizn1 := nizn2 := nRadnika := 0
 aUslP := Parsiraj(qqPartn,"IDPARTNER")
 seek str(ngodina,4)+str(nmjesec,2)+cid
 do while !eof() .and.;
          godina+mjesec+id = str(ngodina,4)+str(nmjesec,2)+cid
   if &aUslP
     nizn1 += iznos1
     nizn2 += iznos2
     IF LEFT(opis,1)=="("
       cOpis    := opis
       cOpis    := STRTRAN(cOpis,"(","")
       cOpis    := ALLTRIM(STRTRAN(cOpis,")",""))
       nRadnika += VAL(cOpis)
     ENDIF
   ENDIF
   skip 1
 enddo
 cIdPartner:=""
 IF nRadnika>0
   cOpis:="("+ALLTRIM(STR(nRadnika))+")"
 ELSE
   cOpis:=""
 ENDIF
 // u poziv na broj za poreze i dopr stavljena netor,bruto osnovica
 //IF lOpresa .and. ( LEFT(cId,3)=="POR" .or. LEFT(cId,4)=="DOPR" )
 //  cPozBr := ALLTRIM( STR(nizn2,20,2) )
 //ELSE
 //  cPozBr := ""
 //ENDIF
endif

PopWA()
return
