#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/sif/1g/sifre.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.15 $
 * $Log: sifre.prg,v $
 * Revision 1.15  2004/05/27 09:27:02  sasavranic
 * Koristenje zajednickog sifranika valuta
 *
 * Revision 1.14  2004/03/23 15:47:59  sasavranic
 * no message
 *
 * Revision 1.13  2003/07/24 15:58:38  sasa
 * stampa podataka o bankama na narudzbenici
 *
 * Revision 1.12  2003/05/27 15:34:13  mirsad
 * ukinuo f-ju za pregled normativa , prebacio je u modul roba/rpt_sast.prg
 *
 * Revision 1.11  2003/03/12 10:37:09  mirsad
 * parametrizirao poziv labeliranja
 *
 * Revision 1.10  2003/02/27 01:27:30  mirsad
 * male dorade za zips
 *
 * Revision 1.9  2002/09/13 08:44:54  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.8  2002/09/13 08:43:12  mirsad
 * Dokumentovanje INI parametara
 *
 * Revision 1.7  2002/07/08 08:27:47  ernad
 *
 *
 * debug - uzimanje teksta na kraju fakture
 *
 * Revision 1.6  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.5  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.4  2002/07/03 12:35:37  sasa
 * todo: iskoristiti iz f-je sifreold() sve one sifrarnike koji trenutno nisu implementirani u /fmk/svi i /fmk/roba.
 * Izbacena f-ja sifre()
 *
 * Revision 1.3  2002/06/24 08:15:02  sasa
 * no message
 *
 * Revision 1.2  2002/06/19 08:47:27  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 

/*! \file fmk/fakt/sif/1g/sifre.prg
 *  \brief Sifrarnici
 */


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_VrstePlacanja
  * \brief Da li se koristi sifrarnik vrsta placanja i evidentiranje vrste placanja na fakturama?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_VrstePlacanja;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_Partn_Naziv2
  * \brief Da li se koristi i dodatno polje NAZIV2 za naziv firme u sifrarniku partnera
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_Partn_Naziv2;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FIN_VidiUgovor
  * \brief Omoguciti opciju za pregled ugovora za partnera u sifrarniku partnera koja se dobije tipkom F5 ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FIN_VidiUgovor;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Svi_SifAuto
  * \brief Koriste li se automatski dodjeljivane sifre robe?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_Svi_SifAuto;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_Svi_SifAuto
  * \brief Onemoguciti korisnicko mijenjanje sifara robe?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_Svi_SifAuto;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_ID
  * \brief Prikazivati kolonu sifre robe u sifrarniku robe ako se sifra automatski dodjeljuje?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_SifPath_SifRoba_ID;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_VPC2
  * \brief Prikazati kolonu VPC2 u sifrarniku robe?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_SifPath_SifRoba_VPC2;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_MPCXY
  * \brief Da li se prikazuju MPC2, MPC3, ..., MPC10 (naravno ako uopste postoje ova polja u bazi) u sifrarniku robe?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_SifPath_SifRoba_MPCXY;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_SortTag
  * \brief Ime tag-a (indeksa) koji se koristi za sortiranje sifrarnika robe
  * \param ID  - po sifri robe, default vrijednost
  * \param NAZ - po nazivu robe
  */
*string FmkIni_SifPath_SifRoba_SortTag;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_PitanjeOpis
  * \brief Da li ce se pojavljivati pitanje za unos opisa robe pri editovanju podataka u sifrarniku robe?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_SifRoba_PitanjeOpis;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_BoxStanje_ZaglavljeStanjex
  * \brief Opis podatka koji se ispisuje kao dodatni parametar u okviru stanja robe (opcija "S" u sifrarniku robe) u x-tom dodatnom redu
  * \param  - prazno, tj. nije definisano, default vrijednost
  */
*string FmkIni_KumPath_BoxStanje_ZaglavljeStanjex;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_BoxStanje_FormulaStanjex
  * \brief Formula za odredjivanje podatka koji se ispisuje kao dodatni parametar u okviru stanja robe (opcija "S" u sifrarniku robe) u x-tom dodatnom redu
  * \param  - prazno, tj. nije definisano, default vrijednost
  */
*string FmkIni_KumPath_BoxStanje_FormulaStanjex;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SIFROBA_PrikID
  * \brief Koja sifra robe se prikazuje u dokumentima?
  * \param ID   - IDROBA, default vrijednost
  * \param ID_J - IDROBA_J, ako se koristi automatsko dodjeljivanje sifara robe)
  */
*string FmkIni_SifPath_SIFROBA_PrikID;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Koristi li se sifrarnik opcina i polje za sifru opcine u sifrarniku partnera
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_CROBA_GledajFakt
  * \brief Da li se FAKT-dokumenti koriste za utvrdjivanje stanja robe u centralnoj bazi robe CROBA?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_CROBA_GledajFakt;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_ID_J
  * \brief Koriste li se sifre robe ID_J?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_SifRoba_ID_J;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Svi_Sifk
  * \brief Da li se koriste sifrarnici SIFK i SIFV?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_Svi_Sifk;




/*! \fn P_KalPos(cId,dx,dy)
 *  \brief Otvara sifranik kalendar posjeta ako se u uslovu zada ID koji ne postoji
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_KalPos(cId,dx,dy)
*{
PRIVATE ImeKol,Kol:={}
ImeKol:={ ;
          { "DATUM"         , {|| datum}   , "datum"    },;
          { "Relacija"      , {|| idrelac} , "idrelac"  , {|| .t.}, {|| P_Relac(@widrelac)  } },;
          { "Distributer"   , {|| iddist } , "iddist"   , {|| .t.}, {|| P_Firma(@widdist)   } },;
          { "Vozilo"        , {|| idvozila}, "idvozila" , {|| .t.}, {|| P_Vozila(@widvozila)} },;
          { "Realizovano"   , {|| realiz  }, "realiz"   };
        }
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
Private gTBDir:="N"

return PostojiSifra(F_KALPOS,1,10,75,"Kalendar posjeta",@cId,dx,dy)
*}



/*! \fn P_Relac(cId,dx,dy)
 *  \brief Otvara sifranik relacija
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Relac(cId,dx,dy)
*{
PRIVATE ImeKol,Kol:={}
ImeKol:={ ;
          { "ID"                 , {|| id },       "id"  , {|| .t.}, {|| .t.}     },;
          { "Naziv i sort(r.br.)", {|| naz},       "naz"       },;
          { "Sifra kupca"        , {|| idpartner}, "idpartner" , {|| .t.}, {|| P_Firma(@widpartner)} },;
          { "Prodajno mjesto"    , {|| idpm}     , "idpm"      , {|| .t.}, {|| P_IDPM(@widpm,widpartner)} };
        }
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
Private gTBDir:="N"

return PostojiSifra(F_RELAC,1,10,75,"Lista: Relacije",@cId,dx,dy)
*}



/*! \fn P_Vozila(cId,dx,dy)
 *  \brief Otvara sifrarnik Volzila
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Vozila(cId,dx,dy)
*{
PRIVATE ImeKol,Kol:={}
ImeKol:={ ;
          { "ID"     , {|| id },     "id"  , {|| .t.}, {|| vpsifra(wId)}     },;
          { "Naziv"  , {|| naz},     "naz"      },;
          { "Tablice", {|| tablice}, "tablice"  };
        }
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
Private gTBDir:="N"

return PostojiSifra(F_VOZILA,1,10,75,"Lista: Vozila",@cId,dx,dy)
*}




/*! \fn P_Konto(cId,dx,dy)
 *  \brief Otvara sifrarnik konta
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_Konto(cId,dx,dy)
*{
PRIVATE ImeKol,Kol
ImeKol:={ ;
          { "ID  ",  {|| id },     "id"  , {|| .t.}, {|| vpsifra(wId)}     },;
          { "Naziv", {|| naz},     "naz"      };
        }
Kol:={1,2}
Private gTBDir:="N"

return PostojiSifra(F_KONTO,1,10,60,"Lista: Konta",@cId,dx,dy)
*}




/*! \fn P_FaSast(cId,dx,dy)
 *  \brief Otvara sifrarnik sastavnica
 *  \param cId
 *  \param dx
 *  \param dy
 *  \todo integrisati u fmk/roba/sast.prg
 */

function P_FaSast(cid,dx,dy)
*{

PRIVATE ImeKol,Kol
ImeKol:={ }
Kol:={}
AADD (ImeKol,{ padc("ID",10),  {|| id },     "id"   , {|| .t.}, {|| vpsifra(wId)} })
AADD (ImeKol,{ padc("Naziv",40), {|| naz},     "naz"      })
AADD (ImeKol,{ padc("JMJ",3), {|| jmj},       "jmj"    })
AADD (ImeKol,{ padc("VPC",10 ), {|| transform(VPC,"999999.999")}, "vpc"   })
if roba->(fieldpos("vpc2"))<>0
  AADD (ImeKol,{ padc("VPC2",10 ), {|| transform(VPC2,"999999.999")}, "vpc2" })
endif
AADD (ImeKol,{ padc("MPC",10 ), {|| transform(MPC,"999999.999")}, "mpc"   })
for i:=2 to 10
  cPom:="MPC"+ALLTRIM(STR(i))
  cPom2:='{|| transform('+cPom+',"999999.999")}'
  if roba->( fieldpos( cPom ) )  <>  0
    AADD (ImeKol,{ padc(cPom,10 ),;
                  &(cPom2) ,;
                  cPom })
  endif
next
AADD (ImeKol,{ padc("NC",10 ), {|| transform(NC,"999999.999")}, "NC"   })
AADD (ImeKol,{ "Tarifa",{|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa), EditOpis() }   })
AADD (ImeKol,{ "Tip",{|| " "+Tip+" "}, "Tip", {|| .t.}, {|| wTip $ "P" } } )
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

 

#ifdef CAX

select roba
index on id+tip to (SIFPATH+"robapro") for tip="P"  additive // samo lista robe
set index to (SIFPATH+"robapro")
go top
return PostojiSifra(F_ROBA,"_ROBAPRO",17,77,"Pregled gotovih proizvoda: <ENTER> Unos norme, <Ctrl-F4> Kopiraj normu",@cid,dx,dy,{|Ch| SastBlok(Ch)})

#else
select roba
index on id+tip tag "IDUN" to robapro for tip="P"  // samo lista robe
set order to tag "idun"
go top
Private gTBDir:="N"
return PostojiSifra(F_ROBA,"IDUN_ROBAPRO",17,77,"Pregled gotovih proizvoda: <ENTER> Unos norme, <Ctrl-F4> Kopiraj normu",@cid,dx,dy,{|Ch| SastBlok(Ch)})
#endif
*}



/*! \fn SastBlok(Ch)
 *  \brief Funkcija koja se poziva unutar P_Sast(), Brisanje sastavnica 
 *  \param Ch
 */
 
function SastBlok(Ch)
*{
local nUl,nIzl,nRezerv,nRevers,fOtv:=.f.,nIOrd,nFRec, aStanje

if Ch==K_CTRL_F9 // zabrani brisanje
  cDN:="0"
  Box(,5,40)
   @ m_x+1,m_Y+2 SAY "Sta ustvari zelite:"
   @ m_x+3,m_Y+2 SAY "0. Nista !"
   @ m_x+4,m_Y+2 SAY "1. Izbrisati samo sastavnice ?"
   @ m_x+5,m_Y+2 SAY "2. Izbrisati i artikle i sastavnice "
   @ m_x+5,col()+2 GET cDN valid cdn $ "012"
   read
  BoxC()

  if lastkey()=K_ESC
    return 7
  endif

  if cdn$"12" .and. pitanje(,"Sigurno zelite izbrisati definisane sastavnice ?","N")=="D"
      select sast
      zap
  endif
  if cdn$"2" .and. pitanje(,"Sigurno zelite izbrisati proizvode ?","N")=="D"
    select roba  // filter je na roba->tip="P"
    do while !eof()
      skip; nTrec:=recno(); skip -1
      delete
      go nTrec
    enddo
  endif

  return 7


elseif Ch==K_ENTER // pregled sastavnice
 nTRobaRec:=recno()
 private cIdTek:=id
 select sast
 set order to tag "id"
 set scope to cidTEk
 private ImeKol:={;
          { "Id2"       , {|| id2 }  , "id2", {|| .t.}, {|| wid:=cIdTek, p_roba(@wid2)} },;
          { "kolicina"  , {|| kolicina}  , "kolicina"      };
        }
 private Kol:={1,2}
 PostojiSifra(F_SAST,1,10,70,cIDTEK+"-"+roba->naz, , , ,{|Ch| EdSastBlok(Ch)},,,,.f.)

 set scope to
 // samo lista robe

 select roba
#ifdef CAX
 set index to (SIFPATH+"robapro")
#else
 set order to tag "idun"
#endif
 go nTrobaRec

#ifdef PROBA
 MsgBeep("Dodjoh li ovdjjjj DE_REF="+str(DE_REFRESH))
#endif
 return 2

elseif Ch=K_CTRL_F4
  nTRobaRec:=recno()
  if pitanje(,"Formirati novi normativ po uzoru na postojeci","N")=="D"
     cNoviProizvod:=space(10)
     cIdTek:=id
     Box(,2,60)
       @m_x+1,m_y+2 SAY "Proizvod:" GET cNoviProizvod pict "@!" valid cNoviProizvod<>cIdTek .and. p_Roba(@cNoviProizvod) .and. roba->tip=="P"
       read
     BoxC()
     if lastkey()<>K_ESC
       select sast; set order to tag id
       seek cidtek
       do while !eof() .and. id==cIdTek
          nTRec:=recno()
          scatter()
          _id:=cNoviProizvod
          append blank; Gather()
          go nTrec; skip
       enddo
       select roba
        #ifdef CAX
         set index to (SIFPATH+"robapro")
        #else
         set order to tag idun
        #endif
     endif
  endif
  go nTrobaRec
  return DE_REFRESH


elseif Ch=K_F10  // ostale opcije
       private opc[2]
       opc[1]:="1. zamjena sirovine u svim sastavnicama                 "
       opc[2]:="2. promjena ucesca pojedine sirovine u svim sastavnicama"
       h[1]:=h[2]:=""
       private am_x:=m_x,am_y:=m_y
       private Izbor:=1
       do while .t.
          Izbor:=menu("o_sast",opc,Izbor,.f.)
          do case
            case Izbor==0
                EXIT
            case izbor == 1
                cOldS:=space(10)
                cNewS:=space(10)
                nKolic:=0
                Box(,6,70)
                  @ m_x+1,m_y+2 SAY "'Stara' sirovina :" GET cOldS pict "@!" valid P_Roba(@cOldS)
                  @ m_x+2,m_y+2 SAY "'Nova'  sirovina :" GET cNewS pict "@!" valid cNews<>cOldS .and. P_Roba(@cNewS)
                  @ m_x+4,m_y+2 SAY "Kolicina u normama (0 - zamjeni bez obzira na kolicinu)" GET nKolic pict "999999.99999"
                  read
                BoxC()
                if lastkey()<>K_ESC
                  select sast; set order to
                  go top
                  do while !eof()
                    if id2==cOldS
                       if nKolic=0 .or. round(nKolic-kolicina,5)=0
                            replace id2 with cNewS
                       endif
                    endif
                    skip
                  enddo
                  set order to tag ID
                endif
            case izbor == 2
                cOldS:=space(10)
                cNewS:=space(10)
                nKolic:=0
                nKolic2:=0
                Box(,6,65)
                  @ m_x+1,m_y+2 SAY "Sirovina :" GET cOldS pict "@!" valid P_Roba(@cOldS)
                  @ m_x+4,m_y+2 SAY "postojeca kolicina u normama " GET nKolic pict "999999.99999"
                  @ m_x+5,m_y+2 SAY "nova kolicina u normama      " GET nKolic2 pict "999999.99999"   valid nKolic<>nKolic2
                  read
                BoxC()
                if lastkey()<>K_ESC
                  select sast; set order to
                  go top
                  do while !eof()
                    if id2==cOldS
                       if round(nKolic-kolicina,5)=0
                            replace kolicina with nKolic2
                       endif
                    endif
                    skip
                  enddo
                  set order to tag ID
                endif

          endcase
       enddo
       m_x:=am_x; m_y:=am_y
  return DE_CONT

endif
return DE_CONT
*}



/*! \fn EdSastBlok(Ch)
 *  \brief Nedozvoljava brisanje sifranika
 *  \param Ch
 */
 
function EdSastBlok(Ch)
*{
if ch=K_CTRL_F9
   MsgBeep("Nedozvoljena opcija")
   return 7  // kao de_refresh, ali se zavrsava izvr{enje f-ja iz ELIB-a
endif
#ifdef PROBA
   MsgBeep("DE_CONT="+str(DE_CONT))
#endif

return DE_CONT
*}





/*! \fn FaPartnBlock(Ch)
 *  \brief
 *  \param 
 */
 
function FaPartnBlock(Ch)
*{
LOCAL cSif:=PARTN->id, cSif2:=""

if Ch==K_F5
  IzfUgovor()
  return DE_REFRESH
endif

return DE_CONT
*}


/*! \fn IzFUgovor()
 *  \brief Pregled ugovora za partnera
 *  \brief Specificno za ZIPS
 */
 
function IzfUgovor()
*{
if IzFMkIni('FIN','VidiUgovor','N')=="D"

Pushwa()

select (F_UGOV)
if !used()
  O_UGOV
  O_RUGOV
  O_DEST
  O_ROBA
  O_TARIFA
endif

PRIVATE DFTkolicina:=1, DFTidroba:=PADR("ZIPS",10)
PRIVATE DFTvrsta  :="1", DFTidtipdok :="20", DFTdindem   := gOznVal
PRIVATE DFTidtxt  :="10", DFTzaokr    :=2, DFTiddodtxt :="  "

DFTParUg(.t.)

select ugov
private cFilter:="Idpartner=="+cm2str(partn->id)
set filter to &cFilter
go top
if eof()
  MsgBeep("Ne postoje definisani ugovori za korisnika")
  if pitanje(,"Zelite li definisati novi ugovor ?","N")=="D"
     set filter to
     P_UGov2(partn->id)

     select partn
     P_Ugov2()
  else
     PopWa()
     return .t.
  endif

else
    select partn
    P_Ugov2()
endif


select ugov; go top
if !eof() // postoji ugovor za partnera
select rugov
seek ugov->id
if !found() // izbrisane
  if Pitanje(,"Sve stavke ugovora su izbrisane, izbrisati ugovor u potputnosti ? ","D")=="D"
     select ugov
     delete
  endif
endif
endif

PopWa()

endif // iz fmk.ini

return .t.
*}



/*! \fn RobaBlok(Ch)
 *  \brief 
 *  \param Ch 
 */
 
function FaRobaBlock(Ch)
*{
LOCAL cSif:=ROBA->id, cSif2:=""
LOCAL nArr:=SELECT()

if UPPER(Chr(Ch))=="K"
 PushWa()
 BrowseKart(roba->id)
 PopWa()
 return 6  // DE_CONT2

elseif upper(Chr(Ch))=="S"
  TB:Stabilize()  // problem sa "S" - exlusive, htc
  PushWa()
  FaktStanje(roba->id)
  PopWa()
  return 6  // DE_CONT2

elseif upper(Chr(Ch))=="C"
  if IzFmkIni('CROBA','GledajFakt','N',KUMPATH)=='D'
      cIdRoba:=ID
      seek cSif
      TB:Stabilize()  // problem sa "S" - exlusive, htc
      cSQL:="select  stanjem,stanjev,ulazm,ulazv,realm,realv from croba "+;
           "  where idrobafmk="+sqlvalue(cIdroba)
      aRez:=sqlselect("c:\sigma\sql","sc",cSQL, {"N","N","N","N","N","N"} )
      if aRez[1,1]='ERR' .or. aRez[1,2]=0
       _Stanjem:=0
       _Stanjev:=0
       _Ulazm  :=0
       _Ulazv  :=0
       _realm  :=0
       _realv  :=0
      else
       _Stanjem:=aRez[2,1]
       _Stanjev:=aRez[2,2]
       _Ulazm  :=aRez[2,3]
       _Ulazv  :=aRez[2,4]
       _realm  :=aRez[2,5]
       _realv  :=aRez[2,6]
      endif

      Box(,15,75)
      @ m_x+ 1,m_y+2 SAY "Artikal : "+cSif+"-"+TRIM(ROBA->NAZ) COLOR INVERT
      @ m_x+ 3,m_y+2 SAY "Pocetno stanje MP: "+STR(_StanjeM)
      @ m_x+ 4,m_y+2 SAY "Ulaz           MP: "+STR(_UlazM)
      @ m_x+ 5,m_y+2 SAY "Realizacija    MP: "+STR(_RealM)
      @ m_x+ 6,m_y+2 SAY "-------------------------------------"
      @ m_x+ 7,m_y+2 SAY "STANJE         MP: "+STR(_StanjeM+_UlazM-_RealM)
      @ m_x+ 8,m_y+2 SAY "-------------------------------------"
      @ m_x+ 9,m_y+2 SAY "Pocetno stanje VP: "+STR(_StanjeV)
      @ m_x+10,m_y+2 SAY "Ulaz           VP: "+STR(_UlazV)
      @ m_x+11,m_y+2 SAY "Realizacija    VP: "+STR(_RealV)
      @ m_x+12,m_y+2 SAY "-------------------------------------"
      @ m_x+13,m_y+2 SAY "STANJE         VP: "+STR(_StanjeV+_UlazV-_RealV)
      @ m_x+14,m_y+2 SAY "-------------------------------------"
      @ m_x+15,m_y+2 SAY "STANJE      MP+VP: "+STR(_StanjeM+_UlazM-_RealM+_StanjeV+_UlazV-_RealV)
      INKEY(0)
      BoxC()
      return 6  // DE_CONT2
  endif


  
  RETURN DE_CONT


elseif Ch==K_ALT_M
  if pitanje(,"Formirati MPC na osnovu VPC ? (D/N)","N")=="D"
      private GetList:={}, nZaokNa:=1, cMPC:=" ", cVPC:=" "
      Scatter()
      select tarifa; hseek _idtarifa; select roba

      Box(,4,70)
        @ m_x+2, m_y+2 SAY "Set cijena VPC ( /2)  :" GET cVPC VALID cVPC$" 2"
        @ m_x+3, m_y+2 SAY "Set cijena MPC ( /2/3):" GET cMPC VALID cMPC$" 23"
        READ
        IF EMPTY(cVPC); cVPC:=""; ENDIF
        IF EMPTY(cMPC); cMPC:=""; ENDIF
      BoxC()

      Box(,6,70)
        @ m_X+1, m_y+2 SAY trim(roba->id)+"-"+trim(roba->naz)
        @ m_X+2, m_y+2 SAY "TARIFA"
        @ m_X+2, col()+2 SAY _idtarifa
        @ m_X+3, m_y+2 SAY "VPC"+cVPC
        @ m_X+3, col()+1 SAY _VPC&cVPC pict picdem
        @ m_X+4, m_y+2 SAY "Postojeca MPC"+cMPC
        @ m_X+4, col()+1 SAY roba->MPC&cMPC pict picdem
        @ m_X+5, m_y+2 SAY "Zaokruziti cijenu na (broj decimala):" GET nZaokNa VALID {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict "9"
        @ m_X+6, m_y+2 SAY "MPC"+cMPC GET _MPC&cMPC WHEN {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict picdem
        read
      BoxC()
      if lastkey()<>K_ESC
         Gather()
         IF Pitanje(,"Zelite li isto uraditi za sve artikle kod kojih je MPC"+cMPC+"=0 ? (D/N)","N")=="D"
           nRecAM:=RECNO()
           Postotak(1,RECCOUNT2(),"Formiranje cijena")
           nStigaoDo:=0
           GO TOP
           DO WHILE !EOF()
             IF ROBA->MPC&cMPC == 0
               Scatter()
                select tarifa; hseek _idtarifa; select roba
                _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa)
               Gather()
             ENDIF
             Postotak(2,++nStigaoDo)
             SKIP 1
           ENDDO
           Postotak(0)
           GO (nRecAM)
         ENDIF
         return DE_REFRESH
      endif
  elseif pitanje(,"Formirati VPC na osnovu MPC ? (D/N)","N")=="D"
      private GetList:={}, nZaokNa:=1, cMPC:=" ", cVPC:=" "
      Scatter()
      select tarifa; hseek _idtarifa; select roba

      Box(,4,70)
        @ m_x+2, m_y+2 SAY "Set cijena VPC ( /2)  :" GET cVPC VALID cVPC$" 2"
        @ m_x+3, m_y+2 SAY "Set cijena MPC ( /2/3):" GET cMPC VALID cMPC$" 23"
        READ
        IF EMPTY(cVPC); cVPC:=""; ENDIF
        IF EMPTY(cMPC); cMPC:=""; ENDIF
      BoxC()

      Box(,6,70)
        @ m_X+1, m_y+2 SAY trim(roba->id)+"-"+trim(roba->naz)
        @ m_X+2, m_y+2 SAY "TARIFA"
        @ m_X+2, col()+2 SAY _idtarifa
        @ m_X+3, m_y+2 SAY "MPC"+cMPC
        @ m_X+3, col()+1 SAY _MPC&cMPC pict picdem
        @ m_X+4, m_y+2 SAY "Postojeca VPC"+cVPC
        @ m_X+4, col()+1 SAY roba->VPC&cVPC pict picdem
        @ m_X+5, m_y+2 SAY "Zaokruziti cijenu na (broj decimala):" GET nZaokNa VALID {|| _VPC&cVPC:=round(_MPC&cMPC / ((1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100)),nZaokNa),.t.} pict "9"
        @ m_X+6, m_y+2 SAY "VPC"+cVPC GET _VPC&cVPC WHEN {|| _VPC&cVPC:=round(_MPC&cMPC / ((1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100)),nZaokNa),.t.} pict picdem
        read
      BoxC()
      if lastkey()<>K_ESC
         Gather()
         IF Pitanje(,"Zelite li isto uraditi za sve artikle kod kojih je VPC"+cVPC+"=0 ? (D/N)","N")=="D"
           nRecAM:=RECNO()
           Postotak(1,RECCOUNT2(),"Formiranje cijena")
           nStigaoDo:=0
           GO TOP
           DO WHILE !EOF()
             IF ROBA->VPC&cVPC == 0
               Scatter()
                select tarifa; hseek _idtarifa; select roba
                _VPC&cVPC:=round(_MPC&cMPC / ((1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100)),nZaokNa)
               Gather()
             ENDIF
             Postotak(2,++nStigaoDo)
             SKIP 1
           ENDDO
           Postotak(0)
           GO (nRecAM)
         ENDIF
         return DE_REFRESH
      endif
  endif
  return DE_CONT

elseif Ch==K_CTRL_T .and. gSKSif=="D"
 // provjerimo da li je sifra dupla
 PushWA()
 SET ORDER TO TAG "ID"
 SEEK cSif
 SKIP 1
 cSif2:=ROBA->id
 PopWA()
 IF !(cSif==cSif2)
   // ako nije dupla provjerimo da li postoji u kumulativu
   if ImaUKumul(cSif,"3")
     Beep(1)
     Msg("Stavka artikla/robe se ne moze brisati jer se vec nalazi u dokumentima!")
     return 7
   endif
 ENDIF

elseif Ch==K_F2 .and. gSKSif=="D"
 if ImaUKumul(cSif,"3")
   return 99
 endif

else // nista od magicnih tipki
 return DE_CONT
endif

RETURN DE_CONT

/*! \fn FaktStanje(cIdRoba)
 *  \brief Stanje robe fakt-a
 *  \param cIdRoba
 */
 
function FaktStanje(cIdRoba)
*{
local nUl,nIzl,nRezerv,nRevers,fOtv:=.f.,nIOrd,nFRec, aStanje
select roba
select (F_FAKT)
if !used()
   O_FAKT; fOtv:=.t.
else
  nIOrd:=indexord()
  nFRec:=recno()
endif
// "3","Idroba+dtos(datDok)","FAKT")  // za karticu, specifikaciju
set order to 3
SEEK cIdRoba

aStanje:={}
//{idfirma, nUl,nIzl,nRevers,nRezerv }
nUl:=nIzl:=nRezerv:=nRevers:=0
do while !eof()  .and. cIdRoba==IdRoba
   nPos:=ASCAN (aStanje, {|x| x[1]==FAKT->IdFirma})
   if nPos==0
     AADD (aStanje, {IdFirma, 0, 0, 0, 0})
     nPos := LEN (aStanje)
   endif
   if idtipdok="0"  // ulaz
      aStanje[nPos][2] += kolicina
   elseif idtipdok="1"   // izlaz faktura
       if !(left(serbr,1)=="*" .and. idtipdok=="10")  // za fakture na osnovu optpremince ne ra~unaj izlaz
         aStanje[nPos][3] += kolicina
       endif
   elseif idtipdok$"20#27"
      if serbr="*"
         aStanje[nPos][5] += kolicina
      endif
   elseif idtipdok=="21"
      aStanje[nPos][4] += kolicina
   endif
   skip
enddo

if fotv
 selec fakt; use
else
//  set order to (nIOrd)
  dbsetorder(nIOrd)
  go nFRec
endif
select roba
BoxStanje(aStanje, cIdRoba)      // nUl,nIzl,nRevers,nRezerv)
return
*}


/*! \fn BoxStanje(aStanje,cIdRoba)
 *  \brief
 *  \param aStanje
 *  \param cIdRoba
 */
 
function BoxStanje(aStanje,cIdroba)
*{
local picdem:="9999999.999", nR, nC, nTSta := 0, nTRev := 0, nTRez := 0,;
      nTOst := 0, npd, cDiv := " ³ ", nLen

 npd := LEN (picdem)
 nLen := LEN (aStanje)

 // ucitajmo dodatne parametre stanja iz FMK.INI u aDodPar
 
 aDodPar := {}
 FOR i:=1 TO 6
   cI := ALLTRIM(STR(i))
   cPomZ := IzFMKINI( "BoxStanje" , "ZaglavljeStanje"+cI , "" , KUMPATH )
   cPomF := IzFMKINI( "BoxStanje" , "FormulaStanje"+cI   , "" , KUMPATH )
   IF !EMPTY( cPomF )
     AADD( aDodPar , { cPomZ , cPomF } )
   ENDIF
 NEXT
 nLenDP := IF( LEN(aDodPar)>0 , LEN(aDodPar)+1 , 0 )

 select roba
 //PushWa()
 set order to tag "ID"; seek cIdRoba
 Box(,6+nLen+INT((nLenDP)/2),75)
  Beep(1)
  @ m_x+1,m_y+2 SAY "ARTIKAL: "
  @ m_x+1,col() SAY PADR(AllTrim (cidroba)+" - "+roba->naz,51) COLOR "GR+/B"
  @ m_x+3,m_y+2 SAY cDiv + "RJ" + cDiv + PADC ("Stanje", npd) + cDiv+ ;
                    PADC ("Na reversu", npd) + cDiv + ;
                    PADC ("Rezervisano", npd) + cDiv + PADC ("Ostalo", npd) ;
                    + cDiv
  nR := m_x+4
  FOR nC := 1 TO nLen
//{idfirma, nUl,nIzl,nRevers,nRezerv }
    @ nR,m_y+2 SAY cDiv
    @ nR,col() SAY aStanje [nC][1]
    @ nR,col() SAY cDiv
    nPom := aStanje [nC][2]-aStanje [nC][3]
    @ nR,col() SAY nPom pict picdem
    @ nR,col() SAY cDiv
    nTSta += nPom
    @ nR,col() SAY aStanje [nC][4] pict picdem
    @ nR,col() SAY cDiv
    nTRev += aStanje [nC][4]
    nPom -= aStanje [nC][4]
    @ nR,col() SAY aStanje [nC][5] pict picdem
    @ nR,col() SAY cDiv
    nTRez += aStanje [nC][5]
    nPom -= aStanje [nC][5]
    @ nR,col() SAY nPom pict picdem
    @ nR,col() SAY cDiv
    nTOst += nPom
    nR ++
  NEXT
    @ nR,m_y+2 SAY cDiv + "--" + cDiv + REPL ("-", npd) + cDiv+ ;
                   REPL ("-", npd) + cDiv + ;
                   REPL ("-", npd) + cDiv + REPL ("-", npd) + cDiv
    nR ++
    @ nR,m_y+2 SAY " ³ UK.³ "
    @ nR,col() SAY nTSta pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY nTRev pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY nTRez pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY nTOst pict picdem
    @ nR,col() SAY cDiv

    // ispis dodatnih parametara stanja
 
    IF nLenDP>0
      ++nR
      @ nR, m_y+2 SAY REPL("-",74)
      FOR i:=1 TO nLenDP-1

        cPom777 := aDodPar[i,2]

        IF "TARIFA->" $ UPPER(cPom777)
          SELECT (F_TARIFA)
          IF !USED(); O_TARIFA; ENDIF
          SET ORDER TO TAG "ID"
          HSEEK ROBA->idtarifa
          SELECT ROBA
        ENDIF

        IF i%2!=0
          ++nR
          @ nR, m_y+2 SAY PADL( aDodPar[i,1] , 15 ) COLOR "W+/B"
          @ nR, col()+2 SAY &cPom777 COLOR "R/W"
        ELSE
          @ nR, m_y+37 SAY PADL( aDodPar[i,1] , 15 ) COLOR "W+/B"
          @ nR, col()+2 SAY &cPom777 COLOR "R/W"
        ENDIF

      NEXT
    ENDIF

  inkey(0)
 BoxC()
 
return
*}


/*! \fn P_VrsteP(cId,dx,dy)
 *  \brief Otvara sifranik vrsta placanja 
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_VrsteP(cId,dx,dy)
*{
PRIVATE ImeKol,Kol:={}
ImeKol:={ { "ID ",  {|| id },       "id"  , {|| .t.}, {|| vpsifra(wId)}      },;
          { PADC("Naziv",20), {|| naz},      "naz"       };
        }
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_VRSTEP,1,10,55,"Sifrarnik vrsta placanja",@cid,dx,dy)
*}


/*! \fn P_Ops(cId,dx,dy)
 *  \brief Otvara sifranik opstina 
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_Ops(cId,dx,dy)
*{
private imekol,kol

ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("IDJ",3), {||  idj}, "idj" }                       ,;
          { padr("Kan",3), {||  idKan}, "idKan" }                       ,;
          { padr("N0",3), {||  idN0}, "IdN0" }                       ,;
          { padr("Naziv",20), {||  naz}, "naz" }                       ;
       }

Kol:={}
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_OPS,1,10,65,"Lista opcina",@cId,dx,dy)
*}


/*! \fn P_FTxt(cId, dx, dy)
 *  \brief Otvara sifranik fakt-txt 
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_FTxt(cId, dx, dy)
*{
local vrati
local nArr:=SELECT()

private ImeKol,Kol

SELECT (F_FTXT)
if !USED()
	O_FTXT
endif

ImeKol:={}
AADD(ImeKol, { PADR("ID",2),   {|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    } )
AADD(ImeKol,{ "Naziv",  {|| naz},  "naz" , { || UsTipke(), .t. }, { || wnaz:=strtran(wnaz,"##", chr(13)+chr(10)), BosTipke(), .t.}, NIL, "@S50" } )

Kol:={1,2}
Prozor1(3,0,11,79,"PREGLED TEKSTA")
@ 12,0 SAY ""
Private gTBDir:="N"
vrati:=PostojiSifra(F_FTXT, 1, 7, 77, "Faktura - tekst na kraju fakture", @cId , , , {|| PrikFTXT()})
Prozor0()
select (nArr)
RETURN vrati
*}


/*! \fn PrikFTxt()
 *  \brief Prikazuje uzorak teksta
 */
 
function PrikFTxt()
*{
LOCAL  i:=0, aTXT:={}
 @ 3,60 SAY "SIFRA:"+id
 aTXT := TXTuNIZ( naz , 78 )
 FOR i:=1 TO 7
   IF i > LEN(aTXT)
     @ 3+i,1 SAY SPACE(78)
   ELSE
     @ 3+i,1 SAY PADR(aTXT[i],78)
   ENDIF
 NEXT
return -1
*}

/*! \fn fn ObSif()
 *  \brief
 */
 
static function ObSif()
*{
IF glDistrib
   O_RELAC
   O_VOZILA
   O_KALPOS
 ENDIF
 O_SIFK
 O_SIFV
 O_KONTO
 O_PARTN
 O_ROBA
 O_FTXT
 O_TARIFA
 O_VALUTE
 O_RJ
 O_SAST
 O_UGOV
 O_RUGOV
 IF RUGOV->(FIELDPOS("DESTIN"))<>0
   O_DEST
 ENDIF
 IF gNW=="T"
   O_FADO
   O_FADE
 ENDIF
 IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
   O_VRSTEP
 ENDIF
 IF IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
   O_OPS
 ENDIF
RETURN
*}


/*! \fn TxtUNiz(cTxt,nKol)
 *  \brief Pretvara TXT u niz
 *  \param cTxt   - tekst
 *  \param nKol   - broj kolona
 */
 
function TxtUNiz(cTxt,nKol)
*{
LOCAL aVrati:={}, nPoz:=0, lNastavi:=.t., cPom:="", aPom:={}, i:=0
  cTxt:=TRIM(cTxt)
  DO WHILE lNastavi
    nPoz := AT( CHR(13)+CHR(10) , cTxt )
    IF nPoz>0
      cPom:=LEFT(cTxt,nPoz-1)
      IF nPoz-1>nKol
        cPom:=TRIM( LomiGa(cPom,1,5,nKol) )
        FOR  i:=1  TO  INT( (LEN(cPom)-1)/nKol ) + 1
          AADD( aVrati , SUBSTR( cPom , (i-1)*nKol+1 , nKol ) )
        NEXT
      ELSE
        AADD( aVrati , cPom )
      ENDIF
      cTxt := SUBSTR( cTxt , nPoz+2 )
    ELSEIF !EMPTY(cTxt)
      cPom:=TRIM(cTxt)
      IF LEN(cPom)>nKol
        cPom:=TRIM( LomiGa(cPom,1,5,nKol) )
        FOR  i:=1  TO  INT( (LEN(cPom)-1)/nKol ) + 1
          AADD( aVrati , SUBSTR( cPom , (i-1)*nKol+1 , nKol ) )
        NEXT
      ELSE
        AADD( aVrati , cPom )
      ENDIF
      lNastavi := .f.
    ELSE
      lNastavi := .f.
    ENDIF
  ENDDO
RETURN aVrati
*}



/*! \fn ImaUKumul(cKljuc,cTag)
 *  \brief
 *  \param cKljuc
 *  \param cTag
 */
 
function ImaUKumul(cKljuc,cTag)
*{
  LOCAL lVrati:=.f., lUsed:=.t., nArr:=SELECT()
  SELECT (F_FAKT)
  IF !USED()
    lUsed:=.f.
    O_FAKT
  ELSE
    PushWA()
  ENDIF
  IF !EMPTY(INDEXKEY(VAL(cTag)+1))
    SET ORDER TO TAG (cTag)
    seek cKljuc
    lVrati:=found()
  ENDIF

  IF !lUsed
    USE
  ELSE
    PopWA()
  ENDIF
  select (nArr)
RETURN lVrati
*}




/*! \fn P_DefDok(cId,dx,dy)
 *  \brief Otvara sifranik definicije dokumenata 
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_DefDok(cId,dx,dy)
*{
Private ImeKol:={}
Private Kol:={}
AADD (ImeKol,{ "Sifra/ID" , {|| id}       ,"id"       , {|| .t.},  {|| vpsifra(wid) }  } )
AADD (ImeKol,{ "Opis"   , {|| naz},      "Naz"                                       } )

Kol:={}
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
Private gTBDir:="N"
return PostojiSifra(F_FADO,1,10,60,"Lista dokumenata u FAKT <F5> - definisi izgled dokumenta",@cId,dx,dy,{|Ch| DefDokBlok(Ch)})
*}


/*! \fn DefDokBlok(Ch)
 *  \brief Obradjuje dogadjaje za pritisnuti taster Ch
 *  \param Ch  - pritisnuti taster (npr. CTRL+T)
 */
 
function DefDokBlok(Ch)
*{
if Ch==K_CTRL_T
 if Pitanje(,"Izbrisati dokument i definiciju izgleda dokumenta ?","N")=="D"
   if Pitanje(,"Jeste li sigurni?","N")=="D"
    cId:=id
    select fade
    seek cid
    do while !eof() .and. cid==id
       skip; nTrec:=recno(); skip -1
       delete
       go nTrec
    enddo
    select fado
    delete
    return 7  // prekini zavrsi i refresh
   endif
 endif

elseif Ch==K_F2
 if Pitanje(,"Promjena broja dokumenta ?","N")=="D"
     cIdOld:=id
     cId:=Id
     Box(,2,50)
      @ m_x+1, m_y+2 SAY "Novi broj dokumenta" GET cID  valid !empty(cid) .and. cid<>cidold
      read
     BoxC()
     if lastkey()==K_ESC; return DE_CONT; endif
     select fade
     seek cidOld
     do while !eof() .and. cidold==id
       skip; nTrec:=recno(); skip -1
       replace id with cid
       go nTrec
     enddo
     select fado
     replace id with cid

 endif
 return DE_CONT

elseif Ch==K_F5
 V_DefDok(fado->id)
 return 6 // DE_CONT2
else
  return DE_CONT
endif
return DE_CONT
*}


/*! \fn V_DefDok()
 *  \brief
 *  \param cId  - Id ugovora
 */
 
function V_DefDok()
*{
parameters cId
private GetList:={}
private ImeKol:={}
private Kol:={}

Box(,15,75)
select fade
ImeKol:={}
AADD(ImeKol,{ "ID      ",     {|| ID      }  })
AADD(ImeKol,{ "SEKCIJA ",     {|| SEKCIJA }  })
AADD(ImeKol,{ "KX      ",     {|| KX      }  })
AADD(ImeKol,{ "KY      ",     {|| KY      }  })
AADD(ImeKol,{ "TIPSLOVA",     {|| TIPSLOVA}  })
AADD(ImeKol,{ "FORMULA ",     {|| FORMULA }  })
AADD(ImeKol,{ "OPIS    ",     {|| OPIS    }  })
AADD(ImeKol,{ "TIPKOL  ",     {|| TIPKOL  }  })
AADD(ImeKol,{ "SIRKOL  ",     {|| SIRKOL  }  })
AADD(ImeKol,{ "SIRDEC  ",     {|| SIRDEC  }  })
AADD(ImeKol,{ "SUMIRATI",     {|| SUMIRATI}  })
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on
@ m_x+1,m_y+1 SAY ""; ?? "Dokument:",fado->id,fado->naz
BrowseKey(m_x+3,m_y+1,m_x+14,m_y+75,ImeKol,{|Ch| EdDefDok(Ch)},"id+brisano=='"+cid+" '",cid,2,,,{|| .f.})

select fado
BoxC()
return .t.
*}


/*! \fn EdDefDok(Ch)
 *  \brief
 *  \param Ch - Pritisnuti taster
 */
 
function EdDefDok(Ch)
*{
local  fK1:=.f.
local GetList:={}

local nRet:=DE_CONT
do case
  case Ch==K_F5

    cUslovSrch:=""
    Box(,1,60)
       cUslovSrch:=space(120)
       @ m_x+1,m_y+2 SAY "Zelim pronaci:" GET cUslovSrch pict "@!S40"
       read
    BoxC()

    if empty(cNazSrch)
      SetSifFilt(cUslovSrch)  // postavi filter u sifrarniku
    else
      set filter to
    endif
    return DE_REFRESH

  case Ch==K_F2  .or. Ch==K_CTRL_N

     sID       := FADO->id
     sSEKCIJA  := SEKCIJA
     sFORMULA  := FORMULA
     sOPIS     := OPIS
     IF Ch==K_CTRL_N
       sKX       := BLANK(KX)
       sKY       := BLANK(KY)
       sTIPSLOVA := BLANK(TIPSLOVA)
       sTIPKOL   := "C "
       sSIRKOL   := BLANK(SIRKOL)
       sSIRDEC   := BLANK(SIRDEC)
       sSUMIRATI := "N"
     ELSE
       sKX       := KX
       sKY       := KY
       sTIPSLOVA := TIPSLOVA
       sTIPKOL   := TIPKOL
       sSIRKOL   := SIRKOL
       sSIRDEC   := SIRDEC
       sSUMIRATI := SUMIRATI
     ENDIF

     Box(,12,75,.f.)
//       @ m_x+1,m_y+2 SAY "ID dokumenta     " GET sID       PICT "@!"
       @ m_x+ 2,m_y+2 SAY "Sekcija(A/B/C/D) " GET sSEKCIJA  PICT "@!" VALID sSekcija$"ABCD"
       @ m_x+ 3,m_y+2 SAY "Koordinata reda  " GET sKX       WHEN sSekcija$"BD" PICT "999"
       @ m_x+ 4,m_y+2 SAY "Koordinata kolone" GET sKY       WHEN sSekcija$"BCD" PICT "999"
       @ m_x+ 5,m_y+2 SAY "Izgled slova(BUI)" GET sTIPSLOVA WHEN sSekcija$"BD" PICT "@!"
       @ m_x+ 6,m_y+2 SAY "Formula          " GET sFORMULA
       @ m_x+ 7,m_y+2 SAY "Opis podatka     " GET sOPIS
       @ m_x+ 8,m_y+2 SAY "Tip (N /C /D /P )" GET sTIPKOL   WHEN sSekcija=="C" VALID sTipKol $ "N #C #N-#D #P " PICT "@!"
       @ m_x+ 9,m_y+2 SAY "Sirina kolone    " GET sSIRKOL   WHEN sSekcija=="C" PICT "999"
       @ m_x+10,m_y+2 SAY "Sirina decimala  " GET sSIRDEC   WHEN sSekcija=="C".and.sTipKol!="C " PICT "999"
       @ m_x+11,m_y+2 SAY "Sumirati (D/N)   " GET sSUMIRATI WHEN sSekcija=="C" PICT "@!" VALID sSumirati$"DN"
       read
     BoxC()
     if Ch==K_CTRL_N .and. lastkey()<>K_ESC
        append blank
        replace id with sid
     endif
     if lastkey()<>K_ESC
       replace SEKCIJA  WITH sSEKCIJA ,;
               KX       WITH sKX      ,;
               KY       WITH sKY      ,;
               TIPSLOVA WITH sTIPSLOVA,;
               FORMULA  WITH sFORMULA ,;
               OPIS     WITH sOPIS    ,;
               TIPKOL   WITH sTIPKOL  ,;
               SIRKOL   WITH sSIRKOL  ,;
               SIRDEC   WITH sSIRDEC  ,;
               SUMIRATI WITH sSUMIRATI
     endif
     nRet:=DE_REFRESH
  case Ch==K_CTRL_T
     if Pitanje(,"Izbrisati stavku ?","N")=="D"
        delete
     endif
     nRet:=DE_DEL

endcase
return nRet
*}



/*! \fn LabelU()
 *  \brief Labeliranje ugovora
 */
 
function LabelU()
*{
PushWA()
cIdRoba   := DFTidroba
cPartneri := SPACE(80)
cPTT      := SPACE(80)
cMjesta   := SPACE(80)
cNSort    := "4"

Box(,8,77)
DO WHILE .t.
 @ m_x+0, m_y+5 SAY "POSTAVLJENJE USLOVA ZA PRAVLJENJE LABELA"
 @ m_x+2, m_y+2 SAY "Artikal  :" GET cIdRoba  VALID P_Roba(@cIdRoba) PICT "@!"
 @ m_x+3, m_y+2 SAY "Partner  :" GET cPartneri PICT "@S50!"
 @ m_x+4, m_y+2 SAY "Mjesto   :" GET cMjesta   PICT "@S50!"
 @ m_x+5, m_y+2 SAY "PTT      :" GET cPTT      PICT "@S50!"
 @ m_x+6, m_y+2 SAY "Nacin sortiranja (1-kolicina+mjesto+naziv ,"
 @ m_x+7, m_y+2 SAY "                  2-mjesto+naziv+kolicina ,"
 @ m_x+8, m_y+2 SAY "                  3-PTT+mjesto+naziv+kolicina),"
 @ m_x+8, m_y+2 SAY "                  4-kolicina+PTT+mjesto+naziv):" GET cNSort VALID cNSort$"1234" PICT "9"
 READ
 IF LASTKEY()==K_ESC; BoxC(); RETURN; ENDIF
 aUPart := Parsiraj( cPartneri , "IDPARTNER" )
 aUPTT  := Parsiraj( cPTT      , "PTT"       )
 aUMjes := Parsiraj( cMjesta   , "MJESTO" )
 if aUPart<>NIL .and. aUMjes<>NIL .and. aUPTT<>NIL
   EXIT
 else
 endif
ENDDO
BoxC()


aDbf := {}
AADD (aDbf, {"IDROBA", "C",  10, 0})
AADD (aDbf, {"IdPartner", "C",  7, 0})
AADD (aDbf, {"Destin"  , "C", 1, 0})
AADD (aDbf, {"Kolicina", "N",  12, 2})
AADD (aDbf, {"Naz" , "C", 25, 0})
AADD (aDbf, {"Naz2", "C", 25, 0})
AADD (aDBf,{ 'PTT'                 , 'C' ,   5 ,  0 })
AADD (aDBf,{ 'MJESTO'              , 'C' ,  16 ,  0 })
AADD (aDBf,{ 'ADRESA'              , 'C' ,  24 ,  0 })
AADD (aDBf,{ 'TELEFON'             , 'C' ,  12 ,  0 })
AADD (aDBf,{ 'FAX'                 , 'C' ,  12 ,  0 })

Dbcreate2(PRIVPATH+"LABELU.DBF",aDbf)


select (F_LABELU); usex (PRIVPATH+"labelu")

index ON BRISANO TAG "BRISAN"    //TO (PRIVPATH+"ZAKSM")
index on str(kolicina,12,2)+mjesto+naz     tag "1"
index on mjesto+naz+str(kolicina,12,2)     tag "2"
index on ptt+mjesto+naz+str(kolicina,12,2) tag "3"
index on str(kolicina,12,2)+ptt+mjesto+naz tag "4"

select rugov; set filter to
set filter to idroba==cIdRoba
go top

MsgO("Kreiram LABELU")

do while !eof()

  select ugov; seek rugov->id
  if aktivan!="D" .or. !(&aUPart)
    select rugov; skip 1; loop
  endif
  select partn; seek ugov->idpartner
  if !(&aUMjes) .or. !(&aUPTT)
    select rugov; skip 1; loop
  endif

  select labelu
  append blank
  replace idpartner with ugov->idpartner,;
          kolicina  with rugov->kolicina, ;
          idroba    with rugov->idroba

  if !empty(rugov->destin)
     select dest; seek ugov->idpartner+rugov->destin

     select labelu
     replace naz with dest->naz, naz2 with dest->naz2, ;
     ptt with dest->ptt, mjesto with dest->mjesto, telefon with dest->telefon, fax with dest->fax,;
     adresa with dest->adresa

  else  // nije naznaŸena destinacija
     select labelu
     replace naz with partn->naz, naz2 with partn->naz2 ,;
     ptt with partn->ptt, mjesto with partn->mjesto, telefon with partn->telefon, fax with partn->fax,;
     adresa with partn->adresa
  endif

  select rugov
  skip

enddo

MsgC()

select labelu
SET ORDER TO TAG (cNSort)
GO TOP

aKol:={}
if lSpecifZips
 AADD( aKol, { "Sifra izdanja", {|| IDROBA       }, .f., "C", 13, 0, 1, 1} )
else
 AADD( aKol, { "Roba"         , {|| IDROBA       }, .f., "C", 10, 0, 1, 1} )
endif

AADD( aKol, { "Partner"      , {|| IdPartner    }, .f., "C",  7, 0, 1, 2} )
AADD( aKol, { "Dest."        , {|| Destin       }, .f., "C",  5, 0, 1, 3} )
AADD( aKol, { "Kolicina"     , {|| Kolicina     }, .t., "N", 12, 2, 1, 4} )
AADD( aKol, { "Naziv"        , {|| Naz          }, .f., "C", 25, 0, 1, 5} )
AADD( aKol, { "Naziv2"       , {|| Naz2         }, .f., "C", 25, 0, 1, 6} )
AADD( aKol, { "PTT"          , {|| PTT          }, .f., "C",  5, 0, 1, 7} )
AADD( aKol, { "Mjesto"       , {|| MJESTO       }, .f., "C", 16, 0, 1, 8} )
AADD( aKol, { "Adresa"       , {|| ADRESA       }, .f., "C", 24, 0, 1, 9} )

if !lSpecifZips
 AADD( aKol, { "Telefon"      , {|| TELEFON      }, .f., "C", 12, 0, 1,10} )
 AADD( aKol, { "Fax"          , {|| FAX          }, .f., "C", 12, 0, 1,11} )
endif

StartPrint()

 StampaTabele(aKol,{|| BlokSLU()},,gTabela,,;
              ,"PREGLED BAZE PRIPREMLJENIH LABELA",,,,,)

EndPrint()

use

PopWA()

if Pitanje(,"Aktivirati modul za stampu ?"," ")=="D"
  private cKomLin:=gcLabKomLin+" "+PRIVPATH+"  labelu "+cNSort
  run &cKomLin
endif
return
*}


/*! \fn BlokSLU()
 */
function BlokSLU()
*{
RETURN
*}


/*! \fn ZipsTemp()
 *  \brief Generisanje ugovora na osnovu telefon fax
 */
 
function ZipsTemp()
*{
PRIVATE DFTkolicina:=1, DFTidroba:=PADR("ZIPS",10)
PRIVATE DFTvrsta  :="1", DFTidtipdok :="20", DFTdindem   := gOznVal
PRIVATE DFTidtxt  :="10", DFTzaokr    :=2, DFTiddodtxt :="  "


DFTParUg(.t.)


select partn
go top

do while !eof()

select partn
if numtoken(telefon) <> numtoken(fax)
  MsgBeep("Sifra :"+id+" telefon<>fax  ???")
  skip ; loop
endif

nTokens:=numtoken(telefon)
if nTokens=0
   skip; loop
endif

select ugov
set order to tag PARTNER

seek partn->id
if found() // neki ugovor za partnera postoji, ne diraj !!!
  select partn
  skip ;  loop
endif


SELECT UGOV; set order to tag "ID"

nRecUg:=RECNO()
GO BOTTOM; SKIP 1; Scatter("w")

waktivan:="D"
wdatod:=DATE()
wdatdo:=CTOD("31.12.2059")
wdindem   := DFTdindem
widtipdok := DFTidtipdok
wzaokr    := DFTzaokr
wvrsta    := DFTvrsta
widtxt    := DFTidtxt
widdodtxt := DFTiddodtxt

SKIP -1
wid:=IF( EMPTY(id) , PADL("1",LEN(id),"0") ,;
           PADR(NovaSifra(TRIM(id)),LEN(ID)) )

wIdPartner:=partn->id

? partn->id, partn->naz

append blank
Gather("w")

SELECT RUGOV;  SET FILTER TO
// dodaj stavke robe

for i:=1 to nTokens
  append blank
  replace id with wId, kolicina with val(token(partn->telefon,i)),;
                      idroba with alltrim(token(partn->fax,i))
next


select partn
skip
enddo

MsgBeep("Kraj...")
return
*}



/*! \fn StIdRoba()
 *  \brief Prikaz roba
 */
 
function StIdRoba()
*{
*static string
static cPrikIdRoba:=""
*;
if cPrikIdroba == ""
  cPrikIdRoba:=IzFmkIni('SIFROBA','PrikID','ID',SIFPATH)
endif

if cPrikIdRoba="ID_J"
  return IDROBA_J
else
  return IDROBA
endif
*}

/*! \fn OsvjeziIdJ()
 *  \brief Osvjezavanje fakta javnim siframa
 */
 
function OsvjeziIdJ()
*{
if Pitanje(,"Osvjeziti FAKT javnim siframa ....","N")=="D"
O_FAKT
O_ROBA ; set order to tag "ID"
O_SIFK
O_SIFV
select fakt
set order to
go top
MsgO("Osvjezavam promjene sifarskog sistema u prometu ...")
nCount:=0
do while !eof()
  select roba
  hseek fakt->idroba
  if fakt->idroba_J <> roba->id_j
    select fakt
    replace IdRoba_J with roba->ID_J
  endif
  select fakt
  @ m_x+3,m_y+3 SAY str(++ncount,3)
  skip
enddo
MsgC()


if pitanje(,"Postaviti javne sifre za id_j prazno ?","N")=="D"
  select roba ; set order to
  go top
  do while !eof()
    if empty(id_j)
       replace id_j with id
    endif
    skip
  enddo
endif
endif

return
*}


/*! \fn SifkFill(cSifk,cSifv,cSifrarnik,cIdSif)
 *  \brief Puni pomocne tabele sifk i sifv radi prenosa
 *  \param cSifk       - ime sifk tabele
 *  \param cSifv       - ime sifv tabele
 *  \param cSifrarnik  - sifrarnik (nrp. roba)
 */
 
function SifkFill(cSifk,cSifv,cSifrarnik,cIDSif)
*{
PushWa()

use (cSifK) new   alias _SIFK
use (cSifV) new   alias _SIFV

select _SIFK
if reccount2()==0  // nisu upisane karakteristike, ovo se radi samo jednom
select sifk; set order to tag "ID";  seek padr(cSifrarnik,8)
// uzmi iz sifk sve karakteristike ID="ROBA"

do while !eof() .and. ID=padr(cSifrarnik,8)
   Scatter()
   select _Sifk; append blank
   Gather()
   select sifK
   skip
enddo
endif // reccount()

// uzmi iz sifv sve one kod kojih je ID=ROBA, idsif=2MON0002

select sifv; set order to tag "IDIDSIF"
seek padr(cSifrarnik,8) + cidsif
do while !eof() .and. ID=padr(cSifrarnik,8) .and. idsif= padr(cidsif,len(cIdSif))
 Scatter()
 select _SifV; append blank
 Gather()
 select sifv
 skip
enddo

select _sifv ;use
select _sifk ;use

PopWa()
return
*}


/*! \fn SifkOsv(cSifk,cSifv,cSifrarnik,cIdSif,cRepFajl)
 *  \brief Osvjezava sifk i sifv iz pomocnih tabela obicno _sifk i _sifv
 *  \param cSifk 
 *  \param cSifv 
 *  \param csifrarnik
 *  \param cIdSif
 *  \param cRepFajl
 */
 
function SifkOsv(cSifk,cSifv,cSifrarnik,cIdSif,cRepFajl)
*{
LOCAL cDiff:=""
PushWa()

use (cSifK) new   alias _SIFK
use (cSifV) new   alias _SIFV

select sifk; set order to tag "ID2" // id + oznaka
select _sifk
do while !eof()
 scatter()
 select sifk; seek _SIFK->(ID+OZNAKA)
 if !found()
   append blank
   IF !(cRepFajl==NIL)
     UpisiURF("SIFK: dodajem "+_id+"-"+_oznaka,cRepFajl,.t.,.f.)
   ENDIF
 else
   IF !(cRepFajl==NIL)
     cDiff:=""
     IF DiffMFV(,@cDiff)
       UpisiURF("SIFK: osvjezavam:"+cDiff,cRepFajl,.t.,.f.)
     ENDIF
   ENDIF
 endif
 Gather()
 select _SIFK
 skip
enddo

select sifV; set order to tag "ID"  //"ID","id+oznaka+IdSif",SIFPATH+"SIFV"
select _SIFV
do while !eof()
 scatter()
 select SIFV; seek _SIFV->(ID+OZNAKA+IDSIF)
 if !found()
  IF !(cRepFajl==NIL)
    UpisiURF("SIFV: dodajem "+_ID+"-"+_OZNAKA+"-"+_IDSIF,cRepFajl,.t.,.f.)
  ENDIF
  append blank
 else
  IF !(cRepFajl==NIL)
    cDiff:=""
    IF DiffMFV(,@cDiff)
      UpisiURF("SIFV: osvjezavam"+cDiff,cRepFajl,.t.,.f.)
    ENDIF
  ENDIF
 endif
 Gather()
 select _SIFV
 skip
enddo

select _SIFK; use
select _SIFV; use

PopWa()
return
*}


/*! \fn SMark(cNazPolja)
 *  \brief Vraca samo markiranu robu
 *  \param cNazPolja - ime polja koje sadrzi internu sifru artikla koji se trazi */
 
function SMark(cNazPolja)
*{
// izbor prodajnog mjesta
FUNC P_IDPM(cId,cIdPartner)
 LOCAL lVrati:=.f., nArr:=SELECT(), aNaz:={}
  SELECT SIFV; SET ORDER TO TAG "ID"
  HSEEK "PARTN   "+"PRMJ"+PADR(cIdPartner,15)
  DO WHILE !EOF() .and.;
           id+oznaka+idsif=="PARTN   "+"PRMJ"+PADR(cIdPartner,15)
    IF !EMPTY(naz)
      AADD( aNaz , PADR( naz , LEN(cId) ) )
    ENDIF
    SKIP 1
  ENDDO
  IF LEN(aNaz)>0
    nPom := ASCAN( aNaz , {|x| x=TRIM(cId)} )
    IF nPom<1; nPom:=1; ENDIF
    Box(,LEN(aNaz)+4,18)
       @ m_x+1, m_y+2 SAY "POSTOJECA PRODAJNA"
       @ m_x+2, m_y+2 SAY "      MJESTA      "
       @ m_x+3, m_y+2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
     CLEAR TYPEAHEAD
     nPom:=Menu2(m_x+3,m_y+3,aNaz,nPom)
    BoxC()
    IF nPom>0
      lVrati:=.t.
      cId := aNaz[nPom]
    ENDIF
  ELSE
    lVrati:=.t.
    cId := SPACE(LEN(cId))
  ENDIF
  SELECT (nArr)
RETURN lVrati
*}


/*! \fn IzborRelacije(cIdRelac,cIdDist,cIdVozila,dDatum,cMarsuta)
 *  \brief Izbor relacije
 *  \param cIdRelac    - id relacije
 *  \param cIdDist     - id distribucije
 *  \param cIdVozila   - id vozila
 *  \param dDatum
 *  \param cMarsuta    - marsuta
 */
 
function IzborRelacije(cIdRelac,cIdDist,cIdVozila,dDatum,cMarsruta)
*{
LOCAL lVrati:=.t., aMogRel:={}, nArr:=SELECT(), aIzb:={}
 IF cIdRelac=="NN  "
   cIdDist   := SPACE(LEN(cIdDist  ))
   cIdVozila := SPACE(LEN(cIdVozila))
   cMarsruta := SPACE(LEN(cMarsruta))
   RETURN .t.
 ENDIF
 SELECT KALPOS; SET ORDER TO TAG "2"
 SELECT RELAC; SET ORDER TO TAG "1"
 GO TOP
 HSEEK _idpartner+_idpm
 DO WHILE !EOF() .and. idpartner+idpm==_idpartner+_idpm
   SELECT KALPOS
   SEEK RELAC->id+DTOS(dDatum)
   DO WHILE !EOF() .and. idrelac==RELAC->id .and. DTOS(datum)>=DTOS(dDatum)
     AADD( aMogRel , {DTOC(datum)+"³"+idrelac+"³"+iddist+"³"+idvozila,;
                      idrelac,iddist,idvozila,datum,RELAC->naz} )
     SKIP 1
   ENDDO
   SELECT RELAC
   SKIP 1
 ENDDO
 IF LEN(aMogRel)>0
   ASORT(aMogRel,,,{|x,y| DTOS(x[5])+x[2]<DTOS(y[5])+y[2]})
   AEVAL(aMogRel,{|x| AADD(aIzb,x[1])})
   nPom := ASCAN( aMogRel, {|x| x[2]+x[3]+x[4]+DTOS(x[5])==;
                                cidrelac+ciddist+cidvozila+DTOS(ddatum)} )
   Box(,LEN(aIzb)+4,28)
      @ m_x+1, m_y+2 SAY "SLIJEDECE RELACIJE  "
      @ m_x+2, m_y+2 SAY "PO KALENDARU POSJETA"
      @ m_x+3, m_y+2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
    nPom:=Menu2(m_x+3,m_y+3,aIzb,nPom)
   BoxC()
   IF nPom>0
     cIdRelac  := aMogRel[nPom,2]
     cIdDist   := aMogRel[nPom,3]
     cIdVozila := aMogRel[nPom,4]
     dDatum    := aMogRel[nPom,5]
     cMarsruta := aMogRel[nPom,6]
   ELSE
     lVrati:=.f.
   ENDIF
 ELSE
   MsgBeep("Za zadanog kupca i datum ne postoji planirana relacija u kalendaru posjeta!#"+;
           "Ukoliko se radi npr. o skladiçnoj prodaji, kucajte NN u relaciju!")
   lVrati:=.f.
 ENDIF
 SELECT (nArr)
RETURN lVrati
*}


/*! \fn UpisiURF(cTekst,cFajl,lNoviRed,lNoviFajl)
 *  \brief Upisi u report fajl
 *  \param cTekst    - tekst
 *  \param cFajl     - ime fajla
 *  \param lNoviRed  - da li prelaziti u novi red
 *  \param lNoviFajl - da li snimati u novi fajl
 */
 
function UpisiURF(cTekst,cFajl,lNoviRed,lNoviFajl)
*{
STRFILE(IF(lNoviRed,CHR(13)+CHR(10),"")+cTekst,cFajl,!lNoviFajl)
RETURN
*}



/*! \fn DiffMFV(cZn,cDiff)
 *  \brief differences: memo vs field variable
 *  \param cZn 
 *  \param cdiff
 */
 
function DiffMFV(cZN,cDiff)
*{
LOCAL lVrati:=.f.
  LOCAL i,aStruct

  if cZn==NIL; cZn:="_"; endif
  aStruct:=DBSTRUCT()

  FOR i:=1 TO LEN(aStruct)
    cImeP:=aStruct[i,1]
    IF !(cImeP=="BRISANO")
      cVar:=cZn+cImeP
      IF "U"$TYPE(cVar)
	MsgBeep("Greska:neuskladjene strukture baza!#"+;
		"Pozovite servis SIGMA-COM-a!#"+;
		"Funkcija: GATHER(), Alias: "+ALIAS()+", Polje: "+cImeP)
      ELSE
	IF field->&cImeP <> &cVar
	  lVrati:=.t.
          cDiff+=(CHR(13)+CHR(10))+"     "
          cDiff+=cImeP+": bilo="+TRANS(field->&cImeP,"")+", sada="+TRANS(&cVar,"")
	ENDIF
      ENDIF
    ENDIF
  NEXT
RETURN lVrati
*}


