#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/dok/1g/knjiz.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.22 $
 * $Log: knjiz.prg,v $
 * Revision 1.22  2003/12/22 14:59:10  sasavranic
 * Uslov za sortiranje rednih brojeva u pripremi...varijanta Jerry
 *
 * Revision 1.21  2003/10/04 12:34:30  sasavranic
 * uveden security sistem
 *
 * Revision 1.20  2003/09/29 13:26:55  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.19  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.18  2003/08/30 15:42:38  mirsad
 * dvije nove opcije (F10 u pripremi): J.prenos KALK 10->11  i  K. prenos KALK 16->14
 *
 * Revision 1.17  2003/08/27 08:09:41  mirsad
 * nova opcija u pripremi: F11/4.obracun poreza pri uvozu
 *
 * Revision 1.16  2003/08/09 08:12:14  mirsad
 * dorada za vindiju: pri rasporedu troskova uveo uslov po tarifama
 *
 * Revision 1.15  2003/08/01 16:17:37  mirsad
 * no message
 *
 * Revision 1.14  2003/07/06 22:20:23  mirsad
 * prenos fakt12->kalk96 obuhvata i varijantu unosa radnog naloga u fakt12
 *
 * Revision 1.13  2003/06/25 17:48:40  mirsad
 * 1) vraæanje u f-ju 15-ke
 *
 * Revision 1.12  2003/04/12 06:56:09  mirsad
 * omogucen prenos KALK10,11,81->FAKT poput KALK->TOPS za udaljene lokacije
 *
 * Revision 1.11  2003/03/12 09:18:58  mirsad
 * brojac KALK dokumenata po kontima (koristenje sufiksa iz KONCIJ-a)
 *
 * Revision 1.10  2003/01/28 07:40:17  mirsad
 * dorada radni nalozi za pogon.knjigov.
 *
 * Revision 1.9  2002/12/19 09:32:41  mirsad
 * nova opcija u meniju ost.opcije/2 (F11) "3. pretvori maloprod.popust u smanjenje MPC"
 *
 * Revision 1.8  2002/12/18 15:45:34  mirsad
 * nova opcija u ostalim opcijama (F11): promjena umjesto popusta smanji mpcsapp
 *
 * Revision 1.7  2002/07/18 10:24:35  mirsad
 * uvedeno koristenje IsJerry() za specificnosti za Jerry Trade
 *
 * Revision 1.6  2002/07/12 14:02:47  mirsad
 * zavrsena dorada za labeliranje robe za Aden
 *
 * Revision 1.5  2002/07/10 09:45:18  ernad
 *
 *
 *
 * skeleton rlabele (Roba labele - naljepnice)
 *
 * Revision 1.4  2002/07/10 08:44:19  ernad
 *
 *
 * barkod funkcije kalk, fakt -> fmk/roba/barkod.prg
 *
 * Revision 1.3  2002/06/19 13:57:53  mirsad
 * no message
 *
 * Revision 1.2  2002/06/18 14:02:39  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */


/*! \file fmk/kalk/dok/1g/knjiz.prg
 *  \brief Unos i ispravka dokumenata
 */

*static string
static cENTER:=chr(K_ENTER)+chr(K_ENTER)+chr(K_ENTER)
*;

/*! \fn Knjiz()
 *  \brief Nudi meni za rad na dokumentu u staroj varijanti ili direktno poziva tabelu pripreme u novoj (default) varijanti
 */

function Knjiz()
*{
local izbor:=1

PRIVATE PicCDEM:=gPicCDEM
PRIVATE PicProc:=gPicProc
PRIVATE PicDEM:= gPICDEM
PRIVATE Pickol:= gPICKOL
PRIVATE lAsistRadi:=.f.

if gNW=="N"

private opc[6]

Opc[1]:="1. unos               "
Opc[2]:="2. stampa"
Opc[3]:="3. rekapitulacija"
Opc[4]:="4. kontiranje"
Opc[5]:="5. azuriranje"
Opc[6]:="6. kurs:"+KursLis

do while .t.
 Izbor:=menu("knjiz",opc,Izbor,.f.)

   do case
     case Izbor==0
       EXIT
     case izbor == 1
         KUnos()
     case izbor == 2
         StKalk()
     case izbor == 3
         RekapK()
     case izbor == 4
         KontNal()
     case izbor == 5
         Azur()
     case izbor == 6
       if KursLis=="1"  // prva vrijednost
         KursLis:="2"
       else
         KursLis:="1"
       endif
       Opc[6]:="6. kurs:"+KursLis
   endcase

enddo

else  // gnw=="D"
   KUnos()
endif

closeret
return
*}



/*! \fn KUnos()
 *  \brief Tabela pripreme dokumenta
 */

function KUnos()
*{
O_PARAMS
private cSection:="K",cHistory:=" "; aHistory:={}
select 99; use

OEdit()

private gVarijanta:="2"

private PicV:="99999999.9"
ImeKol:={ ;
          { "F."        , {|| IdFirma                  }, "IdFirma"     } ,;
          { "VD"        , {|| IdVD                     }, "IdVD"        } ,;
          { "BrDok"     , {|| BrDok                    }, "BrDok"       } ,;
          { "R.Br"      , {|| Rbr                      }, "Rbr"         } ,;
          { "Dat.Kalk"  , {|| DatDok                   }, "DatDok"      } ,;
          { "Dat.Fakt"  , {|| DatFaktP                 }, "DatFaktP"    } ,;
          { "K.zad. "   , {|| IdKonto                  }, "IdKonto"     } ,;
          { "K.razd."   , {|| IdKonto2                 }, "IdKonto2"    } ,;
          { "IdRoba"    , {|| IdRoba                   }, "IdRoba"      } ,;
          { "Kolicina"  , {|| transform(Kolicina,picv) }, "kolicina"    } ,;
          { "IdTarifa"  , {|| idtarifa                 }, "idtarifa"    } ,;
          { "F.Cj."     , {|| transform(FCJ,picv)      }, "fcj"         } ,;
          { "F.Cj2."    , {|| transform(FCJ2,picv)     }, "fcj2"        } ,;
          { "Nab.Cj."   , {|| transform(NC,picv)       }, "nc"          } ,;
          { "VPC"       , {|| transform(VPC,picv)      }, "vpc"         } ,;
          { "VPCj.sa P.", {|| transform(VPCsaP,picv)   }, "vpcsap"      } ,;
          { "MPC"       , {|| transform(MPC,picv)      }, "mpc"         } ,;
          { "MPC sa PP" , {|| transform(MPCSaPP,picv)  }, "mpcsapp"     }, ;
          { "RN"        , {|| idzaduz2                 }, "idzaduz2"    }, ;
          { "Br.Fakt"   , {|| brfaktp                  }, "brfaktp"     }, ;
          { "Partner"   , {|| idpartner                }, "idpartner"   }, ;
          { "E"         , {|| error                    }, "error"       } ;
        }

IF lPoNarudzbi
  AADD( ImeKol , { "Br.nar." , {|| brojnar   }, "brojnar"   } )
  AADD( ImeKol , { "Narucioc" , {|| idnar   }, "idnar"   } )
ENDIF

Kol:={}; for i:=1 to len(ImeKol); AADD(Kol,i); next
Box(,20,77)
@ m_x+17,m_y+2 SAY "<c-N>  Nove Stavke      ³<ENT> Ispravi stavku    ³<c-T>  Brisi Stavku   "
@ m_x+18,m_y+2 SAY "<c-A>  Ispravka Naloga  ³<c-P> Stampa Kalkulacije³<a-A> Azuriranje      "
@ m_x+19,m_y+2 SAY "<a-K>  Rekap+Kontiranje ³<c-F9> Brisi pripremu   ³<a-P> Stampa pripreme "
@ m_x+20,m_y+2 SAY "<c-F8> Raspored troskova³<a-F10> asistent        ³<F10>,<F11> Ost.opcije"
IF gCijene=="1" .and. gMetodaNC==" "
  Soboslikar({{m_x+17,m_y+1,m_x+20,m_y+77}},23,14)
ENDIF

PRIVATE lAutoAsist:=.f.

ObjDbedit("PNal",20,77,{|| EdPRIPR()},"<F5>-kartica magacin, <F6>-kartica prodavnica","Priprema...", , , , ,4)
BoxC()

CLOSERET
return
*}




/*! \fn OEdit()
 *  \brief Otvara sve potrebne baze za pripremu dokumenata
 */

function OEdit()
*{
O_DOKS
O_PRIPR
O_KALK
O_KONTO
O_PARTN
O_TDOK
O_VALUTE
if IzFMKIni("Svi","Sifk")=="D"
	O_SIFK
	O_SIFV
endif
if (IsRamaGlas())
	O_RNAL
endif
O_ROBA
O_TARIFA // tarife
O_KONCIJ

select PRIPR
set order to 1
go top
return
*}



/*! \fn EdPRIPR()
 *  \brief Obrada dostupnih opcija u tabeli pripreme
 */

function EdPRIPR()
*{
local nTr2,cSekv,nkekk
local isekv
if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. eof()
  return DE_CONT
endif

PRIVATE PicCDEM:=gPicCDEM
PRIVATE PicProc:=gPicProc
PRIVATE PicDEM:= gPicDEM
PRIVATE Pickol:= gPicKol

select pripr
do case

  case Ch==K_ALT_H
     Savjetnik()
  case Ch==K_ALT_K
     close all
       RekapK()
       if Pitanje(,"Zelite li izvrsiti kontiranje ?","D")=="D"
         Kontnal()
       endif
     Oedit()
     return DE_REFRESH
  case Ch==K_ALT_P
     close all
     IzbDokOLPP()
     // StPripr()
     Oedit()
     return DE_REFRESH
  case Ch==K_ALT_L
	close all
     KaLabelBKod()
     // StPripr()
     
     OEdit()
     return DE_REFRESH
  
  case Ch==K_ALT_Q
	if Pitanje(,"Stampa naljepnica(labela) za robu ?","D")=="D"
  		CLOSE ALL
		RLabele()
		OEdit()		
		return DE_REFRESH
	endif
	return DE_CONT
	
  case Ch==K_ALT_A
	if IsJerry()
		JerryMP()
	endif
	close all
	Azur()
	Oedit()
	if PRIPR->(RECCOUNT())==0 .and. IzFMKINI("Indikatori","ImaU_KALK","N",PRIVPATH)=="D"
		O__KALK
		SELECT PRIPR
		APPEND FROM _KALK
		UzmiIzINI(PRIVPATH+"FMK.INI","Indikatori","ImaU_KALK","N","WRITE")
		close all
		Oedit()
		MsgBeep("Stavke koje su bile privremeno sklonjene sada su vracene! Obradite ih!")
	endif
	return DE_REFRESH

  case Ch==K_CTRL_P
  	if IsJerry()
		JerryMP()
	endif
	close all
	StKalk()
	Oedit()
	return DE_REFRESH

  case Ch==K_CTRL_T
     if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
      delete
      if Logirati(goModul:oDataBase:cName,"DOK","BRISIDOK")
      	EventLog(nUser,goModul:oDataBase:cName,"DOK","BRISIDOK",nil,nil,nil,nil,"","",pripr->idfirma+"-"+pripr->idvd+"-"+pripr->brdok,pripr->datdok,Date(),"","Brisanje stavke iz pripreme")
      endif
      return DE_REFRESH
     endif
     return DE_CONT

   case IsDigit(Chr(Ch))
      Msg("Ako zelite zapoceti unos novog dokumenta: <Ctrl-N>")
      return DE_CONT
   case Ch==K_ENTER
     return EditStavka()

   case Ch==K_CTRL_A
       return EditAll() 

   case Ch==K_CTRL_N  // nove stavke
        return NovaStavka()


     case Ch==K_CTRL_F8
      RaspTrosk()
      return DE_REFRESH

     case Ch==K_CTRL_F9
      if Pitanje(,"Zelite Izbrisati cijelu pripremu ??","N")=="D"
	 if Logirati(goModul:oDataBase:cName,"DOK","BRISIDOK")
      		EventLog(nUser,goModul:oDataBase:cName,"DOK","BRISIDOK",nil,nil,nil,nil,"","",pripr->idfirma+"-"+pripr->idvd+"-"+pripr->brdok,pripr->datdok,Date(),"","Brisanje kompletne pripreme")
      	 endif
 	 zapp()
         return DE_REFRESH
      endif
      return DE_CONT

     case Ch==K_ALT_F10 .or. lAutoAsist
      
         return KnjizAsistent()

     case Ch==K_F10
       return MeniF10()

     case Ch==K_F11
       return MeniF11()

     case Ch==K_F5
         Kmag()
         return DE_CONT

     case Ch==K_F6
         KPro()
         return DE_CONT

endcase
return DE_CONT
*}




/*! \fn EditStavka()
 *  \brief Ispravka stavke dokumenta u pripremi
 */

function EditStavka()
*{
    if reccount2()==0
      Msg("Ako zelite zapoceti unos novog dokumenta: <Ctrl-N>")
      return DE_CONT
    endif
    Scatter()
    if left(_idkonto2,3)="XXX"
      Beep(2)
      Msg("Ne mozete ispravljati protustavke")
      return DE_CONT
    endif
    nRbr:=RbrUNum(_Rbr);_ERROR:=""

    Box("ist",20,77,.f.)
    if EditPRIPR(.f.)==0
     BoxC()
     return DE_CONT
    else
     BoxC()
     if _ERROR<>"1"; _ERROR:="0"; endif       // stavka onda postavi ERROR
     if _idvd=="16"
      _oldval:=_vpc*_kolicina  // vrijednost prosle stavke
     else
      _oldval:=_mpcsapp*_kolicina  // vrijednost prosle stavke
     endif
     _oldvaln:=_nc*_kolicina
     Gather()
     if _idvd $ "16#80" .and. !empty(_idkonto2)
              cIdkont:=_idkonto
              cIdkont2:=_idkonto2
              Box("",21,77,.f.,"Protustavka")
              seek _idfirma+_idvd+_brdok+_rbr
              _Tbanktr:="X"
              do while !eof() .and. _idfirma+_idvd+_brdok+_rbr==idfirma+idvd+brdok+rbr
                if left(idkonto2,3)=="XXX"
                 Scatter()
                 _TBankTr:=""
                 exit
                endif
                skip
              enddo
               _idkonto:=cidkont2
               _idkonto2:="XXX"
               if _idvd=="16"
                Get1_16b()
               else
                Get1_80b()
               endif
               if _TBanktr=="X"
                 append ncnl
               endif
               if _ERROR<>"1"; _ERROR:="0"; endif       // stavka onda postavi ERROR
               Gather()
              BoxC()
      endif
     return DE_REFRESH
    endif
return DE_CONT
*}



/*! \fn NovaStavka()
 *  \brief Unos nove stavke dokumenta u pripremi
 */

function NovaStavka()
*{
        Box("knjn",21,77,.f.,"Unos novih stavki")
        _TMarza:="A"
        // ipak idi na zadnju stavku !
        go bottom

        if left(idkonto2,3)="XXX"
               skip -1
        endif
        // TODO: popni se u odnosu na negativne brojeve
        // TODO: VIDJETI ?? negativne su protustavke ????!!! zar to ima
        do while !bof()
           if val(rbr)<0; skip -1; else; exit; endif
        enddo

        cIdkont:=""
        cidkont2:=""
        do while .t.

           Scatter(); _ERROR:=""
           if _idvd $ "16#80" .and. _idkonto2="XXX"
              _idkonto:=cidkont
              _idkonto2:=cidkont2
           endif
           _Kolicina:=_GKolicina:=_GKolicin2:=0
           _FCj:=_FCJ2:=_Rabat:=0
           if !(_IdVD $ "10#81")
            _Prevoz:=_Prevoz2:=_Banktr:=_SpedTr:=_CarDaz:=_ZavTr:=0
           endif
           _NC:=_VPC:=_VPCSaP:=_MPC:=_MPCSaPP:=0
           nRbr:=RbrUNum(_Rbr)+1

           if EditPRIPR(.t.)==0
             exit
           endif
           append blank
           if _ERROR<>"1"; _ERROR:="0"; endif       // stavka onda postavi ERROR
           if _idvd=="16"
            _oldval:=_vpc*_kolicina  // vrijednost prosle stavke
           else
            _oldval:=_mpcsapp*_kolicina  // vrijednost prosle stavke
           endif
           _oldvaln:=_nc*_kolicina
           Gather()
           if _idvd $ "16#80" .and. !empty(_idkonto2)
              cIdkont:=_idkonto
              cIdkont2:=_idkonto2
              _idkonto:=cidkont2
              _idkonto2:="XXX"
              _kolicina:=-kolicina
              Box("",21,77,.f.,"Protustavka")
              if _idvd=="16"
               Get1_16b()
              else
               Get1_80b()
              endif
              append blank
              if _ERROR<>"1"; _ERROR:="0"; endif       // stavka onda postavi ERROR
              Gather()
              BoxC()
              _idkonto:=cidkont
              _idkonto2:=cidkont2
           endif
        enddo

        BoxC()
return DE_REFRESH
*}




/*! \fn EditAll()
 *  \brief Cirkularna ispravka stavki dokumenta u pripremi
 */

function EditAll()
*{
  // ovu opciju moze pozvati i asistent alt+F10 !
        PushWA()
        select PRIPR
        //go top
        Box("anal",20,77,.f.,"Ispravka naloga")
        nDug:=0; nPot:=0
        do while !eof()
          skip; nTR2:=RECNO(); skip-1
          Scatter(); _ERROR:=""
          if left(_idkonto2,3)="XXX"
             // 80-ka
             skip
             skip; nTR2:=RECNO(); skip-1
             Scatter(); _ERROR:=""
             if left(_idkonto2,3)="XXX"
                exit
             endif
          endif
          nRbr:=RbrUNum(_Rbr)
          IF lAsistRadi
            // pocisti bafer
            CLEAR TYPEAHEAD
            // spucaj mu dovoljno entera za jednu stavku
            cSekv:=""
            for nkekk:=1 to 17
             cSekv+=cEnter
            next
            keyboard cSekv
          ENDIF
          if EditPRIPR(.f.)==0
            exit
          endif
          select PRIPR
          if _ERROR<>"1"; _ERROR:="0"; endif       // stavka onda postavi ERROR
          _oldval:=_mpcsapp*_kolicina  // vrijednost prosle stavke
          _oldvaln:=_nc*_kolicina
          Gather()
          if _idvd $ "16#80" .and. !empty(_idkonto2)
            cIdkont:=_idkonto
            cIdkont2:=_idkonto2
            Box("",21,77,.f.,"Protustavka")
              seek _idfirma+_idvd+_brdok+_rbr
              _Tbanktr:="X"
              do while !eof() .and. _idfirma+_idvd+_brdok+_rbr==idfirma+idvd+brdok+rbr
                if left(idkonto2,3)=="XXX"
                  Scatter()
                  _TBankTr:=""
                  exit
                endif
                skip
              enddo
              _idkonto:=cidkont2
              _idkonto2:="XXX"
              if _idvd=="16"
                Get1_16b()
              else
                Get1_80b()
              endif
              if _TBanktr=="X"
                append ncnl
              endif
              if _ERROR<>"1"; _ERROR:="0"; endif       // stavka onda postavi ERROR
              Gather()
            BoxC()
          endif
          go nTR2
        enddo
        Beep(1)
        clear typeahead
        PopWA()
        BoxC()
        lAsistRadi:=.f.
return DE_REFRESH
*}




/*! \fn KnjizAsistent()
 *  \brief Asistent za obradu stavki dokumenta u pripremi
 */

function KnjizAsistent()
*{
      lAutoAsist:=.f.
      private nEntera:=30
      IF IzFMKIni("KALK","PametniAsistent","D",KUMPATH)=="D"
        lAsistRadi:=.t.
        csekv:=chr(K_CTRL_A)
        keyboard csekv
      ELSE
        // nova varijanta rada asistenta mora se ukljuciti parametrom
        // PametniAsistent=D
        // -----------------
        lAsistRadi:=.f.
        // -----------------
        for isekv:=1 to int(reccount2()/15)+1
          csekv:=chr(K_CTRL_A)
          for nkekk:=1 to min(reccount2(),15)*30
            cSekv+=cEnter
          next
          keyboard csekv
        next
      ENDIF
return DE_REFRESH
*}





/*! \fn MeniF10()
 *  \brief Meni ostalih opcija koji se poziva tipkom F10 u tabeli pripreme
 */

function MeniF10()
*{
private opc[9]

if gVodiSamoTarife=="D"
 opc[1]:="1. generisi storno sume 41 u postojeci dokument                 "
else
 opc[1]:="1. prenos dokumenta fakt->kalk                                  "
endif
opc[2]:="2. povrat dokumenta u pripremu"
opc[3]:="3. priprema -> smece"
opc[4]:="4. smece    -> priprema"
opc[5]:="5. najstariji dokument iz smeca u pripremu"
opc[6]:="6. generacija dokumenta inventure magacin "
opc[7]:="7. generacija dokumenta inventure prodavnica"
opc[8]:="8. generacija nivelacije prodavn. na osnovu niv. za drugu prod"
opc[9]:="9. parametri obrade - nc / obrada sumnjivih dokumenata"
h[1]:=h[2]:=""

select pripr
go top
cIdVDTek:=IdVD  // tekuca vrsta dokumenta

if cidvdtek=="19"
 AADD(opc,"A. obrazac promjene cijena")
else
 AADD(opc,"--------------------------")
endif

AADD( opc , "B. pretvori 11 -> 41  ili  11 -> 42"        )
AADD( opc , "C. promijeni predznak za kolicine"          )
AADD( opc , "D. preuzmi tarife iz sifrarnika"            )
AADD( opc , "E. storno dokumenta"                        )
AADD( opc , "F. prenesi VPC(sifr)+POREZ -> MPCSAPP(dok)" )
AADD( opc , "G. prenesi MPCSAPP(dok)    -> MPC(sifr)"    )
AADD( opc , "H. prenesi VPC(sif)        -> VPC(dok)"     )
AADD( opc , "I. povrat (12,11) -> u drugo skl.(96,97)"   )
AADD( opc , "J. zaduzenje prodavnice iz magacina (10->11)"   )
AADD( opc , "K. veleprodaja na osnovu dopreme u magacin (16->14)"   )

close all
private am_x:=m_x,am_y:=m_y
private Izbor:=1
do while .t.
          Izbor:=menu("prip",opc,Izbor,.f.)
          do case
            case Izbor==0
                EXIT
            case izbor == 1
               if gVodiSamoTarife=="D"
                  Gen41S()
               else
                  FaktKalk()
               endif
            case izbor == 2
                Povrat()
            case izbor == 3
                Azur9()
            case izbor == 4
                Povrat9()
            case izbor == 5
                P9najst()

            case izbor == 6
               im()
            case izbor == 7
               ip()
            case izbor == 8
                GenNivP()
            case izbor == 9
                aRezim:={gCijene,gMetodaNC}
                O_PARAMS
                private cSection:="K",cHistory:=" "; aHistory:={}
                cIspravka:="D"
                SetMetoda()
                select params; use
                IF gCijene<>aRezim[1] .or. gMetodaNC<>aRezim[2]
                  IF gCijene=="1".and.gMetodaNC==" "
                    Soboslikar({{m_x+17,m_y+1,m_x+20,m_y+77}},23,14)
                  ELSEIF aRezim[1]=="1".and.aRezim[2]==" "
                    Soboslikar({{m_x+17,m_y+1,m_x+20,m_y+77}},14,23)
                  ENDIF
                ENDIF

            case izbor == 10 .and. cIdVDTek=="19"
                OEdit()
                select pripr
                go top
                cidfirma:=idfirma
                cidvd:=idvd
                cbrdok:=brdok
                Obraz19()
                select pripr
                go top
                RETURN DE_REFRESH

            case izbor == 11
                Iz11u412()

            case izbor == 12
                PlusMinusKol()

            case izbor == 13
                UzmiTarIzSif()

            case izbor == 14
                StornoDok()

            case izbor == 15
                DiskMPCSAPP()

            case izbor == 16
                IF SigmaSif("SIGMAXXX")
                  IF Pitanje(,"Koristiti dokument u pripremi (D) ili azurirani (N) ?","N")=="D"
                    MPCSAPPuSif()
                  ELSE
                    MPCSAPPiz80uSif()
                  ENDIF
                ENDIF

            case izbor == 17
                VPCSifUDok()

            case izbor == 18
                Iz12u97()     // 11,12 -> 96,97

            case izbor == 19
                Iz10u11()

            case izbor == 20
                Iz16u14()


            endcase
enddo
m_x:=am_x; m_y:=am_y
OEdit()
return DE_REFRESH
*}




/*! \fn MeniF11()
 *  \brief Meni ostalih opcija koji se poziva tipkom F11 u tabeli pripreme
 */

function MeniF11()
*{
private opc:={}
private opcexe:={}
AADD(opc, "1. preuzimanje kalkulacije iz druge firme        ")
AADD(opcexe, {|| IzKalk2f()})
AADD(opc, "2. ubacivanje troskova-uvozna kalkulacija")
AADD(opcexe, {|| KalkTrUvoz()})
AADD(opc, "3. pretvori maloprodajni popust u smanjenje MPC")
AADD(opcexe, {|| PopustKaoNivelacijaMP()})
AADD(opc, "4. obracun poreza pri uvozu")
AADD(opcexe, {|| ObracunPorezaUvoz()})

close all
private am_x:=m_x,am_y:=m_y
private Izbor:=1
Menu_SC("osop2")
m_x:=am_x; m_y:=am_y
OEdit()
return DE_REFRESH
*}




/*! \fn EditPripr(fNovi)
 *  \brief Centralna funkcija za unos/ispravku stavke dokumenta
 */

//ulaz _IdFirma, _IdRoba, ...., nRBr (val(_RBr))
function EditPripr(fNovi)
*{
private nMarza:=0,nMarza2:=0,nR
private PicDEM:="9999999.99999999",PicKol:=gPicKol
nStrana:=1

do while .t.

@ m_x+1,m_y+1 CLEAR TO m_x+20,m_y+77

setkey(K_PGDN,{|| NIL})
setkey(K_PGUP,{|| NIL})

if nStrana==1
  nR:=GET1(fnovi)
elseif nStrana==2
  nR:=GET2(fnovi)
endif

setkey(K_PGDN,NIL)
setkey(K_PGUP,NIL)

set escape on

if nR==K_ESC
  exit
elseif nR==K_PGUP
  --nStrana
elseif nR==K_PGDN .or. nR==K_ENTER
  ++nStrana
endif

if nStrana==0
     nStrana++
elseif nStrana>=3
     exit
endif

enddo

if lastkey()<>K_ESC
 _Rbr:=RedniBroj(nRbr)
 _Dokument:=P_TipDok(_IdVD,-2)
  return 1
else
  return 0
endif
return
*}




/*! \fn Get1()
 *  \param fnovi
 *  \brief Prva strana/prozor maske unosa/ispravke stavke dokumenta
 */

function Get1()
*{
parameters fnovi

private pIzgSt:=.f.   // izgenerisane stavke postoje
private Getlist:={}

if Get1Header() == 0
    return K_ESC
endif

if _idvd=="10"

  if nRbr==1
   if gVarEv=="2" .or. glEkonomat .or. Pitanje(,"Skracena varijanta (bez troskova) D/N ?","N")=="D"
     gVarijanta:="1"
   else
     gVarijanta:="2"
   endif
  endif
  return if( gVarijanta=="1", Get1_10s(), Get1_10() )

elseif _idvd=="11"
   return GET1_11()
elseif _idvd=="12"
   return GET1_12()
elseif _idvd=="13"
   return GET1_12()
elseif _idvd=="14"  //.or._idvd=="74"
   return GET1_14()

elseif _idvd=="15"
   return GET1_15()

elseif _idvd=="16"
   return GET1_16()
   
elseif _idvd=="18"
   return GET1_18()
elseif _idvd=="19"
   return GET1_19()
elseif _idvd $ "41#42#43#47#49"
   return GET1_41()
elseif _idvd == "81"
   return GET1_81()
elseif _idvd == "80"
   return GET1_80()
elseif _idvd=="24"
   return GET1_24()
elseif _idvd $ "95#96#97"
   return GET1_95()
elseif _idvd $  "94#16"    // storno fakture, storno otpreme, doprema
   return GET1_94()
elseif _idvd == "82"
   return GET1_82()
elseif _idvd == "IM"
   return GET1_IM()
elseif _idvd == "IP"
   return GET1_IP()
elseif _idvd == "RN"
   return GET1_RN()
elseif _idvd == "PR"
   return GET1_PR()
else
   return K_ESC
endif
return
*}




/*! \fn Get2()
 *  \param fnovi
 *  \brief Druga strana/prozor maske unosa/ispravke stavke dokumenta
 */

function Get2()
*{
parameters fnovi
if _idvd $ "10"
  return Get2_10()
elseif _idvd == "81"
  return Get2_81()
elseif _idvd == "RN"
  return Get2_RN()
elseif _idvd == "PR"
  return Get2_PR()
endif
return K_ESC
*}




/*! \fn Get1Header()
 *  \brief Maska za unos/ispravku podataka zajednickih za sve stavke dokumenta
 */

function Get1Header()
*{
if fnovi; _idfirma:=gFirma; endif
if fnovi .and. _TBankTr=="X"; _TBankTr:="%"; endif  // izgenerisani izlazi
if gNW $ "DX"
 @  m_x+1,m_y+2   SAY "Firma: ";?? gFirma,"-",gNFirma
else
 @  m_x+1,m_y+2   SAY "Firma:"    get _IdFirma valid P_Firma(@_IdFirma,1,25) .and. len(trim(_idFirma))<=2
endif
@  m_x+2,m_y+2   SAY "KALKULACIJA: "
@  m_x+2,col()   SAY "Vrsta:" get _IdVD valid P_TipDok(@_IdVD,2,25) pict "@!"

read; ESC_RETURN 0

if fnovi .and. gBrojac=="D" .and. (_idfirma<>idfirma .or. _idvd<>idvd)
	if glBrojacPoKontima .and. _idVD$"10#16#18#IM#14#95#96"
		Box("#Glavni konto",3,70)
			if _idVD$"10#16#18#IM"
				@ m_x+2, m_y+2 SAY "Magacinski konto zaduzuje" GET _idKonto VALID P_Konto(@_idKonto) PICT "@!"
				read
				cSufiks:=SufBrKalk(_idKonto)
			else
				@ m_x+2, m_y+2 SAY "Magacinski konto razduzuje" GET _idKonto2 VALID P_Konto(@_idKonto2) PICT "@!"
				read
				cSufiks:=SufBrKalk(_idKonto2)
			endif
		BoxC()
		_brDok:=SljBrKalk(_idVD,_idFirma,cSufiks)
	else
		_brDok:=SljBrKalk(_idVD,_idFirma)
	endif
	select pripr
endif

@  m_x+2,m_y+40  SAY "Broj:"  get _BrDok  ;
  valid {|| !P_Kalk(_IdFirma,_IdVD,_BrDok) }

@  m_x+2,COL()+2 SAY "Datum:"   get  _DatDok

@ m_x+4,m_y+2  SAY "Redni broj stavke:" GET nRBr PICT '9999' valid {|| CentrTxt("",24),.t.}
read
ESC_RETURN 0

return 1
*}




/*! \fn VpcSaPpp()
 *  \brief Vrsi se preracunavanje veleprodajnih cijena ako je _VPC=0
 */

function VpcSaPpp()
*{
if _VPC==0
  _RabatV:=0
  _VPC:=(_VPCSAPPP+_NC*tarifa->vpp/100)/(1+tarifa->vpp/100+_mpc/100)
  nMarza:=_VPC-_NC
  _VPCSAP:=_VPC+nMarza*TARIFA->VPP/100
  _PNAP:=_VPC*_mpc/100
  _VPCSAPP:=_VPC+_PNAP
endif
ShowGets()
return .t.
*}




/*! \fn RaspTrosk(fSilent)
 *  \brief Rasporedjivanje troskova koji su predvidjeni za raspored. Takodje se koristi za raspored ukupne nabavne vrijednosti na pojedinacne artikle kod npr. unosa pocetnog stanja prodavnice ili magacina
 */

function RaspTrosk(fSilent)
*{
local nStUc:=20

if fsilent==NIL
  fsilent:=.f.
endif
if fsilent .or.  Pitanje(,"Rasporediti troskove ??","N")=="D"
   private qqTar:=""
   private aUslTar:=""
   if idvd $ "16#80"
     Box(,1,55)
      if idvd=="16"
       @ m_x+1,m_y+2 SAY "Stopa marze (vpc - stopa*vpc)=nc:" GET nStUc pict "999.999"
      else
       @ m_x+1,m_y+2 SAY "Stopa marze (mpc-stopa*mpcsapp)=nc:" GET nStUc pict "999.999"
      endif
      read
     BoxC()
   endif
   go top

   select F_KONCIJ
   if !used(); O_KONCIJ; endif
   select koncij
   seek trim(pripr->mkonto)
   select pripr

   if IsVindija()
	PushWA()
	if !EMPTY(qqTar)
		aUslTar:=Parsiraj(qqTar,"idTarifa")
		if aUslTar<>nil .and. !aUslTar==".t."
			set filter to &aUslTar
		endif
	endif
   endif

   do while !eof()
      nUKIzF:=0
      nUkProV:=0
      cIdFirma:=idfirma;cIdVD:=idvd;cBrDok:=Brdok
      nRec:=recno()
      do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok
         if cidvd $ "10#16#81#80"    // zaduzenje magacina,prodavnice
           nUkIzF+=round(fcj*(1-Rabat/100)*kolicina,gZaokr)
         endif
         if cidvd $ "11#12#13"    // magacin-> prodavnica,povrat
           nUkIzF+=round(fcj*kolicina,gZaokr)
         endif
         if cidvd $ "RN"
           if val(Rbr)<900
            nUkProV+=round(vpc*kolicina,gZaokr)
           else
            nUkIzF+=round(nc*kolicina,gZaokr)  // sirovine
           endif
         endif
         skip
      enddo
      if cidvd $ "10#16#81#80#RN"  // zaduzenje magacina,prodavnice
       go nRec
       RTPrevoz:=.f.; RPrevoz:=0
       RTCarDaz:=.f.;RCarDaz:=0
       RTBankTr:=.f.;RBankTr:=0
       RTSpedTr:=.f.;RSpedTr:=0
       RTZavTr:=.f.;RZavTr:=0
       if TPrevoz=="R"; RTPrevoz:=.t.;RPrevoz:=Prevoz; endif
       if TCarDaz=="R"; RTCarDaz:=.t.;RCarDaz:=CarDaz; endif
       if TBankTr=="R"; RTBankTr:=.t.;RBankTr:=BankTr; endif
       if TSpedTr=="R"; RTSpedTr:=.t.;RSpedTr:=SpedTr; endif
       if TZavTr =="R"; RTZavTr :=.t.;RZavTr :=ZavTr ; endif

       UBankTr:=0   // do sada utroçeno na bank tr itd, radi "sitniça"
       UPrevoz:=0
       UZavTr:=0
       USpedTr:=0
       UCarDaz:=0
       do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok
         Scatter()

         if _idvd $ "RN" .and. val(_rbr)<900
            _fcj:=_fcj2:= _vpc/nUKProV*nUkIzF
            // nabavne cijene izmisli proporcionalno prodajnim
         endif

         if RTPrevoz    //troskovi 1
             if round(nUkIzF,4)==0
              _Prevoz:=0
             else
              _Prevoz:=round( _fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RPrevoz ,gZaokr)
              UPrevoz+=_Prevoz
              if abs(RPrevoz-UPrevoz)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _Prevoz+=(RPrevoz-UPrevoz)
                   endif
                   skip -1
              endif
             endif
             _TPrevoz:="U"
         endif
         if RTCarDaz   //troskovi 2
             if round(nUkIzF,4)==0
              _CarDaz:=0
             else
              _CarDaz:=round( _fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RCarDaz ,gZaokr)
              UCardaz+=_Cardaz
              if abs(RCardaz-UCardaz)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _Cardaz+=(RCardaz-UCardaz)
                   endif
                   skip -1
              endif
             endif
             _TCarDaz:="U"
         endif
         if RTBankTr  //troskovi 3
             if round(nUkIzF,4)==0
              _BankTr:=0
             else
              _BankTr:=round( _fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RBankTr ,gZaokr)
              UBankTr+=_BankTr
              if abs(RBankTr-UBankTr)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _BankTr+=(RBankTr-UBankTr)
                   endif
                   skip -1
              endif
             endif
             _TBankTr:="U"
         endif
         if RTSpedTr    //troskovi 4
             if round(nUkIzF,4)==0
              _SpedTr:=0
             else
              _SpedTr:=round(_fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RSpedTr,gZaokr)
              USpedTr+=_SpedTr
              if abs(RSpedTr-USpedTr)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _SpedTr+=(RSpedTr-USpedTr)
                   endif
                   skip -1
              endif
             endif
             _TSpedTr:="U"
         endif
         if RTZavTr    //troskovi
             if round(nUkIzF,4)==0
              _ZavTr:=0
             else
              _ZavTr:=round( _fcj*(1-_Rabat/100)*_kolicina/nUkIzF*RZavTr ,gZaokr)
              UZavTR+=_ZavTR
              if abs(RZavTR-UZavTR)< 0.1 // sitniç, baci ga na zadnju st.
                   skip
                   if .not. ( !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok )
                     _ZavTR+=(RZavTR-UZavTR)
                   endif
                   skip -1
              endif
             endif
             _TZavTr:="U"
         endif
         select roba; hseek _idroba
         select tarifa; hseek _idtarifa; select pripr
         if _idvd=="RN"
           if val(_rbr)<900
            NabCj()
           endif
         else
            NabCj()
         endif
         if _idvd=="16"
           _nc:=_vpc*(1-nStUc/100)
         endif
         if _idvd=="80"
           _nc:=_mpc-_mpcsapp*nStUc/100
           _vpc:=_nc
           _TMarza2:="A"
           _Marza2:=_mpc-_nc
         endif
         if koncij->naz=="N1"; _VPC:=_NC; endif
         if _idvd=="RN"
           if val(_rbr)<900
            Marza()
           endif
         else
            Marza()
         endif

         Gather()
         skip
       enddo
      endif //cidvd $ 10
      if cidvd $ "11#12#13"
       go nRec
       RTPrevoz:=.f.;RPrevoz:=0
       if TPrevoz=="R"; RTPrevoz:=.t.;RPrevoz:=Prevoz; endif
       nMarza2:=0
       do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cBrDok==BrDok
         Scatter()
         if RTPrevoz    //troskovi 1
             if round(nUkIzF,4)==0
              _Prevoz:=0
             else
              _Prevoz:=_fcj/nUkIzF*RPrevoz
             endif
             _TPrevoz:="A"
         endif
         _nc:=_fcj+_prevoz
         if koncij->naz=="N1"; _VPC:=_NC; endif
         _marza:=_VPC-_FCJ
         _TMarza:="A"
         select roba; hseek _idroba
         select tarifa; hseek _idtarifa; select pripr
         Marza2()
         _TMarza2:="A"
         _Marza2:=nMarza2
         Gather()
         skip
       enddo
      endif //cidvd $ "11#12#13"
   enddo  // eof()

   if IsVindija()
   	select pripr
	PopWA()
   endif

endif // pitanje
go top
return
*}




/*! \fn Savjetnik()
 *  \brief Zamisljeno da se koristi kao pomoc u rjesavanju problema pri unosu dokumenta. Nije razradjeno.
 */

function Savjetnik()
*{
 LOCAL nRec:=RECNO(),lGreska:=.f.

 // pripremne radnje za stampu u fajl
 //////////////////////////////////////////////////

 MsgO("Priprema izvjestaja...")
 set console off
 cKom:=PRIVPATH+"savjeti.txt"
 set printer off
 set device to printer
 cDDir:=SET(_SET_DEFAULT)
 set default to
 set printer to (ckom)
 set printer on
 SET(_SET_DEFAULT,cDDir)


 // stampanje izvjestaja
 //////////////////////////////////////

SELECT PRIPR
GO TOP

DO WHILE !EOF()
 lGreska:=.f.
 DO CASE

  CASE idvd=="11"     // magacin->prodavnica
    IF vpc==0
      OpisStavke(@lGreska)
      ? "PROBLEM: - veleprodajna cijena = 0"
      ? "OPIS:    - niste napravili ulaz u magacin, ili nemate veleprodajnu"
      ? "           cijenu (VPC) u sifrarniku za taj artikal"
    ENDIF

 ENDCASE

 IF EMPTY(datdok)
   OpisStavke(@lGreska)
   ? "DATUM KALKULACIJE NIJE UNESEN!!!"
 ENDIF

 IF EMPTY(error)
   OpisStavke(@lGreska)
   ? "STAVKA PRIPADA AUTOMATSKI FORMIRANOM DOKUMENTU !!!"
   ? "Pokrenite opciju <Alt-F10> - asistent ako zelite da program sam prodje"
   ? "kroz sve stavke ili udjite sa <Enter> u ispravku samo ove stavke."
   IF idvd=="11"
     ? "Kada pokrenete <Alt-F10> za ovu kalkulaciju (11), veleprodajna"
     ? "cijena ce biti preuzeta: 1) Ako program omogucava azuriranje"
     ? "sumnjivih dokumenata, VPC ce ostati nepromijenjena; 2) Ako program"
     ? "radi tako da ne omogucava azuriranje sumnjivih dokumenata, VPC ce"
     ? "biti preuzeta iz trenutne kartice artikla. Ako nemate evidentiranih"
     ? "ulaza artikla u magacin, bice preuzeta 0 sto naravno nije korektno."
   ENDIF
 ENDIF

 If lGreska; ?; ENDIF
 SKIP 1
ENDDO


 // zavrsetak stampe u fajl i pregled na ekranu
 //////////////////////////////////////////////////

 set printer to
 set printer off
 set console on
 SET DEVICE TO SCREEN
 set printer to
 MsgC()
 save screen to cS
 VidiFajl(cKom)
 restore screen from cS
 SELECT PRIPR
 GO (nRec)
return
*}



/*! \fn OpisStavke(lGreska)
 *  \brief Daje informacije o dokumentu i artiklu radi lociranja problema. Koristi je opcija "savjetnik"
 *  \sa Savjetnik()
 */

function OpisStavke(lGreska)
*{
 IF !lGreska
  ? "Dokument:    "+idfirma+"-"+idvd+"-"+brdok+", stavka "+rbr
  ? "Artikal: "+idroba+"-"+Ocitaj(F_ROBA,idroba,"naz")
  lGreska:=.t.
 ENDIF
return
*}




/*! \fn Soboslikar(aNiz,nIzKodaBoja,nUKodBoja)
 *  \brief Mijenja boje dijela ekrana
 */

function Soboslikar(aNiz,nIzKodaBoja,nUKodBoja)
*{
 LOCAL i, cEkran
  FOR i:=1 TO LEN(aNiz)
    cEkran:=SAVESCREEN(aNiz[i,1],aNiz[i,2],aNiz[i,3],aNiz[i,4])
    cEkran:=STRTRAN(cEkran,CHR(nIzKodaBoja),CHR(nUKodBoja))
    RESTSCREEN(aNiz[i,1],aNiz[i,2],aNiz[i,3],aNiz[i,4],cEkran)
  NEXT
return
*}



/*! \fn StrKZN(cInput,cIz,cU)
 *  \brief Vrsi konverziju znakova u stringu iz jednog u drugi izabrani standard
 */

function StrKZN(cInput,cIz,cU)
*{
 LOCAL a852:={"æ","Ñ","¬","","¦","ç","Ð","Ÿ","†","§"}
 LOCAL a437:={"[","\","^","]","@","{","|","~","}","`"}
 LOCAL aEng:={"S","D","C","C","Z","s","d","c","c","z"}
 LOCAL i:=0, aIz:={}, aU:={}
 aIz := IF( cIz=="7" , a437 , IF( cIz=="8" , a852 , aEng ) )
 aU  := IF(  cU=="7" , a437 , IF(  cU=="8" , a852 , aEng ) )
 FOR i:=1 TO 10
   cInput:=STRTRAN(cInput,aIz[i],aU[i])
 NEXT
return cInput
*}



/*! \fn ZagFirma()
 *  \brief Ispisuje zaglavlje firme/preduzeca
 */

function ZagFirma()
*{
P_12CPI
U_OFF
B_OFF
I_OFF
? "Subjekt:"
U_ON
?? PADC(TRIM(gTS)+" "+TRIM(gNFirma),39)
U_OFF
? "Prodajni objekat:"
U_ON
?? PADC(ALLTRIM(NazProdObj()),30)
U_OFF
? "(poslovnica-poslovna jedinica)"
? "Datum:"
U_ON
?? PADC(SrediDat(DATDOK),18)
U_OFF
?
?
return
*}



/*! \fn NazProdObj()
 *  \brief Daje naziv prodavnickog konta iz pripreme
 */

function NazProdObj()
*{
 LOCAL cVrati:=""
  SELECT KONTO
  SEEK PRIPR->pkonto
  cVrati:=naz
  SELECT PRIPR
return cVrati
*}



/*! \fn IzbDokOLPP()
 *  \brief Izbor dokumenta za stampu u formi OLPP-a
 */

function IzbDokOLPP()
*{
if IzFMKIni("Svi","Sifk")=="D"
	O_SIFK
	O_SIFV
endif
O_ROBA
O_TARIFA
O_PARTN
O_KONTO
O_PRIPR

select PRIPR; set order to 1; go top

do while .t.

 cIdFirma:=IdFirma; cBrDok:=BrDok; cIdVD:=IdVD

 if eof();  exit  ; endif

 if empty(cidvd+cbrdok+cidfirma) .or. ! (cIdVd $ "11#19#81#80")
   skip; loop
 endif

 Box("",2,50)
  set cursor on
  @ m_x+1,m_y+2 SAY "Dokument broj:"
  if gNW $ "DX"
   @ m_x+1,col()+2  SAY cIdFirma
  else
   @ m_x+1,col()+2 GET cIdFirma
  endif
  @ m_x+1,col()+1 SAY "-" GET cIdVD  VALID cIdVd $ "11#19#81#80"  PICT "@!"
  @ m_x+1,col()+1 SAY "-" GET cBrDok
  read; ESC_BCR

 BoxC()

 HSEEK cIdFirma+cIdVD+cBrDok
 EOF CRET

 StOLPP()

enddo

CLOSERET
return
*}



/*! \fn PlusMinusKol()
 *  \brief Mijenja predznak kolicini u svim stavkama u pripremi
 */

function PlusMinusKol()
*{
  OEdit()
  SELECT PRIPR
  GO TOP
  DO WHILE !EOF()
    Scatter()
      _kolicina := -_kolicina
      _ERROR := " "
    Gather()
    SKIP 1
  ENDDO
  // Msg("Automatski pokrecem asistenta (Alt+F10)!",1)
  // lAutoAsist:=.t.
  KEYBOARD CHR(K_ESC)
CLOSERET
return
*}




/*! \fn UzmiTarIzSif()
 *  \brief Filuje tarifu u svim stavkama u pripremi odgovarajucom sifrom tarife iz sifrarnika robe
 */

function UzmiTarIzSif()
*{
  OEdit()
  SELECT PRIPR
  GO TOP
  DO WHILE !EOF()
    Scatter()
      _idtarifa := Ocitaj(F_ROBA,_idroba,"idtarifa")
      _ERROR := " "
    Gather()
    SKIP 1
  ENDDO
  Msg("Automatski pokrecem asistenta (Alt+F10)!",1)
  lAutoAsist:=.t.
  KEYBOARD CHR(K_ESC)
CLOSERET
return
*}




/*! \fn DiskMPCSAPP()
 *  \brief Formira diskontnu maloprodajnu cijenu u svim stavkama u pripremi
 */

function DiskMPCSAPP()
*{
aPorezi:={}
OEdit()
SELECT PRIPR
GO TOP
DO WHILE !EOF()
	SELECT ROBA
	HSEEK PRIPR->idroba
	SELECT TARIFA
	HSEEK ROBA->idtarifa
	Tarifa(pripr->pKonto,pripr->idRoba,@aPorezi)
	SELECT PRIPR
	Scatter()
	
	_mpcSaPP:=MpcSaPor(roba->vpc,aPorezi)
	
	_ERROR := " "
	Gather()
	SKIP 1
ENDDO
Msg("Automatski pokrecem asistenta (Alt+F10)!",1)
lAutoAsist:=.t.
KEYBOARD CHR(K_ESC)
CLOSERET
return
*}



/*! \fn MPCSAPPuSif()
 *  \brief Maloprodajne cijene svih artikala u pripremi kopira u sifrarnik robe
 */

function MPCSAPPuSif()
*{
  OEdit()
  SELECT PRIPR
  GO TOP
  DO WHILE !EOF()
    cIdKonto:=PRIPR->pkonto
    SELECT KONCIJ; HSEEK cIdKonto
    SELECT PRIPR
    DO WHILE !EOF() .and. pkonto==cIdKonto
      SELECT ROBA; HSEEK PRIPR->idroba
      IF FOUND()
        StaviMPCSif(PRIPR->mpcsapp,.f.)
      ENDIF
      SELECT PRIPR
      SKIP 1
    ENDDO
  ENDDO
CLOSERET
return
*}



/*! \fn MPCSAPPiz80uSif()
 *  \brief Maloprodajne cijene svih artikala iz izabranog azuriranog dokumenta tipa 80 kopira u sifrarnik robe
 */

function MPCSAPPiz80uSif()
*{
  OEdit()

  cIdFirma := gFirma
  cIdVdU   := "80"
  cBrDokU  := SPACE(LEN(PRIPR->brdok))

  Box(,4,75)
    @ m_x+0, m_y+5 SAY "FORMIRANJE MPC U SIFRARNIKU OD MPCSAPP DOKUMENTA TIPA 80"
    @ m_x+2, m_y+2 SAY "Dokument: "+cIdFirma+"-"+cIdVdU+"-"
    @ row(),col() GET cBrDokU VALID ImaDok(cIdFirma+cIdVdU+cBrDokU)
    READ; ESC_BCR
  BoxC()

  // pocnimo
  SELECT KALK
  SEEK cIdFirma+cIdVDU+cBrDokU
  cIdKonto:=KALK->pkonto
  SELECT KONCIJ; HSEEK cIdKonto
  SELECT KALK
  DO WHILE !EOF() .and. cIdFirma+cIdVDU+cBrDokU == IDFIRMA+IDVD+BRDOK
    SELECT ROBA; HSEEK KALK->idroba
    IF FOUND()
      StaviMPCSif(KALK->mpcsapp,.f.)
    ENDIF
    SELECT KALK
    SKIP 1
  ENDDO

CLOSERET
return
*}




/*! \fn VPCSifUDok()
 *  \brief Filuje VPC u svim stavkama u pripremi odgovarajucom VPC iz sifrarnika robe
 */

function VPCSifUDok()
*{
  OEdit()
  SELECT PRIPR
  GO TOP
  DO WHILE !EOF()
    SELECT ROBA; HSEEK PRIPR->idroba
    SELECT KONCIJ; SEEK TRIM(PRIPR->mkonto)
    // SELECT TARIFA; HSEEK ROBA->idtarifa
    SELECT PRIPR
    Scatter()
      _vpc := KoncijVPC()
      _ERROR := " "
    Gather()
    SKIP 1
  ENDDO
  Msg("Automatski pokrecem asistenta (Alt+F10)!",1)
  lAutoAsist:=.t.
  KEYBOARD CHR(K_ESC)
CLOSERET
return
*}



/*! \fn StKalk()
 *  \param fstara
 *  \param cSeek
 *  \brief Centralna funkcija za stampu KALK dokumenta. Poziva odgovarajucu funkciju za stampu dokumenta u zavisnosti od tipa dokumenta i podesenja parametara varijante izgleda dokumenta
 */

function StKalk()
*{
parameters fstara,cSeek
local nCol1
local nCol2
local nPom

nCol1:=0
nCol2:=0
nPom:=0

PRIVATE PicCDEM:=gPICCDEM
PRIVATE PicProc:=gPICPROC
PRIVATE PicDEM:= gPICDEM
PRIVATE Pickol:= gPICKOL

private nStr:=0
O_KONCIJ
O_ROBA
O_TARIFA
O_PARTN
O_KONTO
O_TDOK

if (pcount()==0)
	fstara:=.f.
endif

if (cSeek==nil)
	cSeek:=""
endif

if fstara
#ifdef CAX
	select (F_PRIPR)
	use
#endif
	O_SKALK   // alias pripr
else
	O_PRIPR
endif

select PRIPR
set order to 1
go top

fTopsD:=.f.
fFaktD:=.f.

do while .t.

	cIdFirma:=IdFirma
	cBrDok:=BrDok
	cIdVD:=IdVD

	if eof()
		exit
	endif

	if empty(cidvd+cbrdok+cidfirma)
		skip
		loop
	endif

	if (cSeek=="")
		Box("",1,50)
			set cursor on
			@ m_x+1,m_y+2 SAY "Dokument broj:"
			if (gNW $ "DX")
				@ m_x+1,col()+2  SAY cIdFirma
			else
				@ m_x+1,col()+2 GET cIdFirma
			endif
			@ m_x+1,col()+1 SAY "-" GET cIdVD  pict "@!"
			@ m_x+1,col()+1 SAY "-" GET cBrDok
			read
			ESC_BCR
		BoxC()
	endif

	if (!empty(cSeek) .and. cSeek!='IZDOKS')
		HSEEK cSeek
		cidfirma:=substr(cSeek,1,2)
		cIdvd:=substr(cSeek,3,2)
		cBrDok:=padr(substr(cSeek,5,8) ,8)
	else
		HSEEK cIdFirma+cIdVD+cBrDok
	endif

	if (cidvd=="24")
		Msg("Kalkulacija 24 ima samo izvjestaj rekapitulacije !")
		closeret
	endif

	if (cSeek!='IZDOKS')
		EOF CRET
	else
		private nStr:=1
	endif

	START PRINT CRET
	
	do while .t.
	
		if (cidvd=="10".and.!((gVarEv=="2").or.(gmagacin=="1")).or.(cidvd $ "11#12#13")).and.(c10Var=="3")
			gPSOld:=gPStranica
			gPStranica:=VAL(IzFmkIni("KALK","A3_GPSTRANICA","-20",EXEPATH))
			P_PO_L
		endif
	
		if (cSeek=='IZDOKS')  // stampaj sve odjednom !!!
			if (prow()>42)
				++nStr
				FF
			endif
			select pripr
			cIdfirma:=doks->idfirma
			cIdvd:=doks->idvd
			cBrdok:=doks->brdok
			hseek cIdFirma+cIdVD+cBrDok
		endif

		Preduzece()

		if (cidvd=="10" .or. cidvd=="70")
			if (gVarEv=="2")
				StKalk10_sk()
			elseif (gmagacin=="1")
				StKalk10_1()
			else
				if (c10Var=="1")
					StKalk10_2()
				elseif (c10Var=="2")
					StKalk10_3()
				else
					StKalk10_4()
				endif
			endif

		elseif cidvd $ "15"
			StKalk15()

		elseif (cidvd $ "11#12#13")
			if (c10Var=="3")
				StKalk11_3()
			else
				if (gmagacin=="1")
					StKalk11_1()
				else
					StKalk11_2()
				endif
			endif
		elseif (cidvd $ "14#94#74")
			if (c10Var=="3")
				Stkalk14_3()
			else
				Stkalk14()
			endif
		elseif (cidvd $ "95#96#97#16")
			if (gVarEv=="2")
				Stkalk95_sk()
			elseif (gmagacin=="1")
				Stkalk95_1()
			else
				Stkalk95()
			endif
		elseif (cidvd $ "41#42#43#47#49")   // realizacija prodavnice
			if (IsJerry() .and. cIdVd$"41#42#47")
				StKalk47J()
			else
				StKalk41()
			endif
		elseif (cidvd == "18")
			StKalk18()
		elseif (cidvd == "19")
			if IsJerry()
				StKalk19J()
			else
				StKalk19()
			endif
		elseif (cidvd == "80")
			StKalk80()
		elseif (cidvd == "81")
			if IsJerry()
				StKalk81J()
			else
				if (c10Var=="1")
					StKalk81()
				else
					StKalk81_2()
				endif
			endif
		elseif (cidvd == "82")
			StKalk82()
		elseif (cidvd == "IM")
			StKalkIm()
		elseif (cidvd == "IP")
			StKalkIp()
		elseif (cidvd == "RN")
			if !fStara
				RaspTrosk(.t.)
			endif
			StkalkRN()
		elseif (cidvd == "PR")
			StkalkPR()
		endif

		if (cSeek!='IZDOKS')
			exit
		else
			select doks
			skip
			if eof()
				exit
			endif
			?
			?
		endif
		
		if (cidvd=="10".and.!((gVarEv=="2").or.(gmagacin=="1")).or.(cidvd $ "11#12#13")).and.(c10Var=="3")
			gPStranica:=gPSOld
			P_PO_P
		endif

	enddo // cSEEK

	if (gPotpis=="D")
		if (prow()>57+gPStranica)
			FF
			@ prow(),125 SAY "Str:"+str(++nStr,3)
		endif
		?
		?
		P_12CPI
		@ prow()+1,47 SAY "Obrada AOP  "; ?? replicate("_",20)
		@ prow()+1,47 SAY "Komercijala "; ?? replicate("_",20)
		@ prow()+1,47 SAY "Likvidatura "; ?? replicate("_",20)
	endif

	?
	?

	FF
	END PRINT

	if (cidvd $ "80#11#81#12#13#IP#19")
		fTopsD:=.t.
	endif
	
	if (cidvd $ "10#11#81")
		fFaktD:=.t.
	endif

	if (!empty(cSeek))
		exit
	endif

enddo  // vrti kroz kalkulacije

if (fTopsD .and. !fstara .and. gTops!="0 ")
	start print cret
	select PRIPR
	set order to 1
	go top
	cIdFirma:=IdFirma
	cBrDok:=BrDok
	cIdVD:=IdVD
	if (cIdVd $ "11#12")
		StKalk11_2(.t.)  //maksuzija za tops - bez NC
	elseif (cIdVd == "80")
		Stkalk80(.t.)
	elseif (cIdVd == "81")
		Stkalk81(.t.)
	elseif (cIdVd == "IP")
		StkalkIP(.t.)
	elseif (cIdVd == "19")
		Stkalk19()
	endif
	close all
	FF
	END PRINT

	GenTops()
endif

if (fFaktD .and. !fstara .and. gFakt!="0 ")
	start print cret
	select PRIPR
	set order to 1
	go top
	cIdFirma:=IdFirma
	cBrDok:=BrDok
	cIdVD:=IdVD
	if (cIdVd $ "11#12")
		StKalk11_2(.t.)  //maksuzija za tops - bez NC
	elseif (cIdVd == "10")
		StKalk10_3(.t.)
	elseif (cIdVd == "81")
		StKalk81(.t.)
	endif
	close all
	FF
	END PRINT

	PrModem(.t.)
endif

#ifdef CAX
if fstara
	select pripr
	use
endif
#endif
closeret
return nil
*}



/*! \fn PopustKaoNivelacijaMP()
 *  \brief Umjesto iskazanog popusta odradjuje smanjenje MPC
 */

function PopustKaoNivelacijaMP()
*{
local lImaPromjena
lImaPromjena:=.f.
OEdit()
select pripr
go top
do while !eof()
	if (!idvd="4" .or. rabatv==0)
		skip 1
		loop
	endif
	lImaPromjena:=.t.
	Scatter()
		_mpcsapp:=ROUND(_mpcsapp-_rabatv,2)
		_rabatv:=0
		private aPorezi:={}
		private fNovi:=.f.
		VRoba(.f.)
		WMpc(.t.)
		_error:=" "
		select pripr
	Gather()
	skip 1
enddo
if lImaPromjena
	Msg("Izvrsio promjene!",1)
	//lAutoAsist:=.t.
	keyboard CHR(K_ESC)
else
	MsgBeep("Nisam nasao nijednu stavku sa maloprodajnim popustom!")
endif
CLOSERET
return
*}



/*! \fn StOLPPAz()
 *  \brief Funkcija za stampu OLPP-a za azurirani KALK dokument
 */

function StOLPPAz()
*{
local nCol1
local nCol2
local nPom

nCol1:=0
nCol2:=0
nPom:=0

PRIVATE PicCDEM:=gPICCDEM
PRIVATE PicProc:=gPICPROC
PRIVATE PicDEM:= gPICDEM
PRIVATE Pickol:= gPICKOL

private nStr:=0

O_KONCIJ
O_ROBA
O_TARIFA
O_PARTN
O_KONTO
O_TDOK

#ifdef CAX
	select (F_PRIPR)
	use
#endif
O_SKALK   // alias pripr

select PRIPR
set order to 1
go top

do while .t.

	cIdFirma:=IdFirma
	cBrDok:=BrDok
	cIdVD:=IdVD

	if eof()
		exit
	endif

	if empty(cIdVd+cBrDok+cIdFirma)
		skip
		loop
	endif

	Box("",2,50)
		set cursor on
		@ m_x+1,m_y+2 SAY "Dokument broj:"
		if (gNW $ "DX")
			@ m_x+1,col()+2  SAY cIdFirma
		else
			@ m_x+1,col()+2 GET cIdFirma
		endif
		@ m_x+1,col()+1 SAY "-" GET cIdVD  valid cIdVd$"11#19#80#81" pict "@!"
		@ m_x+1,col()+1 SAY "-" GET cBrDok
		@ m_x+2, m_y+2 SAY "(moguce vrste KALK dok.su: 11,19,80,81)"
		read
		ESC_BCR
	BoxC()

	HSEEK cIdFirma+cIdVD+cBrDok

	EOF CRET

	StOlpp()
		

enddo  // vrti kroz kalkulacije

#ifdef CAX
	select pripr
	use
#endif
closeret
return nil
*}


