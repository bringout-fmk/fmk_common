#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/rpt_oinv.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.5 $
 * $Log: rpt_oinv.prg,v $
 * Revision 1.5  2003/11/11 14:06:35  sasavranic
 * Uvodjenje f-je IspisNaDan()
 *
 * Revision 1.4  2002/07/09 13:05:41  ernad
 *
 *
 * debug planika - sitnice
 *
 * Revision 1.3  2002/07/06 17:28:58  ernad
 *
 *
 * izvjestaj Trgomarket: pregled stanja po objektima
 *
 * Revision 1.2  2002/07/06 12:29:01  ernad
 *
 *
 * kalk, planika GenRekap1, GenRekap2
 *
 * Revision 1.1  2002/06/26 08:11:21  ernad
 *
 *
 * razbijanje prg-ova
 *
 *
 */


/*! \fn ObrazInv()
 *  \brief Obrazac inventure za prodavnice
 *  \param
 */
 
function ObrazInv()
*{
local nRec

private  ncnt:=i:=nT1:=nT4:=nT5:=nT6:=nT7:=0
private  nTT1:=nTT4:=nTT5:=nTT6:=nTT7:=0
private  n1:=n4:=n5:=n6:=n7:=0
private  nCol1:=0
private   PicCDEM:="999999.999"
private   PicProc:="999999.99%"
private   PicDEM:= "@Z 9999999.99"
private   Pickol:= "@Z 999999"

private dDatOd:=date()
private dDatDo:=date()
private qqKonto:=padr("132;",60)

private qqRoba:=space(60)
private cIdKPovrata:=space(7)
private ck7:="N"
cPrikKol:="D"

O_PARAMS
Private cSection:="F",cHistory:=" ",aHistory:={}
Params1()
RPar("c1",@cidKPovrata)
RPar("c2",@qqKonto)
RPar("d1",@dDatOd); RPar("d2",@dDatDo)


cPoc:="D"
cSNule:="N"
cProredPC:="D"
cObrNivelacije:="N"
Box(,15,77)
 set cursor on
 cNObjekat:=space(20)
 cKartica:="D"
 do while .t.
  @ m_x+1,m_y+2 SAY "Kriterij za objekte:" GET qqKonto pict "@!S50"
  @ m_x+3,m_y+2 SAY "tekuci promet je period:" GET dDatOd
  @ m_x+3,col()+2 SAY "do" GET dDatDo
  @ m_x+4,m_y+2 SAY "Naziv objekta:" GET cNObjekat pict "@!"
  @ m_x+5,m_y+2 SAY "Kriterij za robu :" GET qqRoba pict "@!S50"
  @ m_x+6,m_y+2 SAY "Prikaz samo pocetnog stanja:" GET cPOC pict "@!" valid cPoc$"DN"
  @ m_x+7,m_y+2 SAY "Prikaz starih artikala sa stanjem 0:" GET cSNule pict "@!" valid cSNule$"DN"
  @ m_x+9,m_y+2 SAY "Magacin u koji se vrsi povrat rekl. robe:" GET cIdKPovrata pict "@!"
  @ m_x+10,m_Y+2 SAY "Prikazi kolicine na obrascu"  GET cPrikKol pict "@!" valid cPrikkol $ "DN"
  @ m_x+11,m_Y+2 SAY "Atribut K2=X ne vrsi se  zbrajanje kolicina"
  @ m_x+12,m_Y+2 SAY "Cijene ocitavati sa kartica D/N" GET  cKartica pict "@!" valid ckartica $ "DN"

  @ m_x+14,m_Y+2 SAY "Prikazati obrazac promjene cijena D/N/2" GET  cObrNivelacije pict "@!" valid cObrNivelacije $ "DN2"
  @ m_x+15,m_Y+2 SAY "Prikazati sa proredom D/N" GET  cProredPC pict "@!" valid cProredPC $ "DN"
  read
  ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"MKonto")
  aUsl2:=Parsiraj(qqKonto,"PKonto")
  aUslR:=Parsiraj(qqRoba,"IdRoba")
  if aUsl1<>NIL .and. aUslR<>NIL
  	exit
  endif
 enddo
BoxC()

 if Params2()
  WPar("c1",cidKPovrata)
  WPar("c2",@qqKonto)
  WPar("d1",dDatOd); WPar("d2",dDatDo)
 endif
 select params
 use
 

#IFDEF PROBA
?? aUslr
Inkey(0)
#ENDIF

CreTblPobjekti()
CreTblRek1("2")

O_POBJEKTI
O_KONCIJ
O_ROBA
O_KONTO 
O_TARIFA
O_K1
O_OBJEKTI
O_KALK
O_REKAP1

GenRekap1(aUsl1, aUsl2, aUslR, cKartica, "2", nil, nil, nil, cIdKPovrata)

select rekap1
//g1+idtarifa+idroba+objekat
set order to 2 
aUsl3:=Parsiraj(qqKonto,"Objekat")

PRIVATE cFilt2:=""

cFilt2 := aUsl3+".and."+aUslR

// postavi filter samo na zeljeni objekat
set filter to &cFilt2 


private xxx:=0

for xxx:=1 to 3  // obrazac nivelacije

cVarPC:="1"

if cOBrNivelacije=="2"
  if xxx==2
     cVarPc:="2"
  else
     cVarPc:="3"
  endif

endif

select rekap1
go top
start print cret

private PREDOVA:=62

private  aTarife:={}
private  aTarGr:={}

private nStr:=0

if xxx==1
  ZaglInv()
  nCol1:=10
  m:="----- ---------------------------------------------------- --- ------- ------- ------ ---------- ------ ---------- ---------- ---------- ------ ---------- ------ ---------- ------ ---------- ------ ---------- ------ ----------"
else
  private PREDOVA:= 61
  m:="----- ---------------------------------------------------- --- --------- --------- --------- ------------ ------------ ------------"
  ZaglObrPC(cVarPC)
  nCol1:=10
endif
nT10:=nT11:=nT20:=nT21:=nT30:=nT31:=nT40:=nT41:=nT50:=nT51:=nT60:=nT61:=nT70:=nT71:=nT80:=nT81:=nT90:=nT91:=nT100:=nT101:=0

fFilovo:=.f.
nRec:=0
do while !eof()

  cG1:=g1
  nTT10:=nTT11:=nTT20:=nTT21:=nTT30:=nTT31:=nTT40:=nTT41:=nTT50:=nTT51:=nTT60:=nTT61:=nTT70:=nTT71:=nTT80:=nTT81:=nTT90:=nTT91:=nTT100:=nTT101:=0
  nRbr:=0
  
  do while !eof() .and. cG1==g1

   cIdTarifa:=idtarifa
   nTTT10:=nTTT11:=nTTT20:=nTTT21:=nTTT30:=nTTT31:=nTTT40:=nTTT41:=nTTT50:=nTTT51:=nTTT60:=nTTT61:=nTTT70:=nTTT71:=nTTT80:=nTTT81:=nTTT90:=nTTT91:=nTTT100:=nTTT101:=0
   fFilovo:=.f.
   
   do while !eof() .and. cG1==g1  .and. idtarifa==cIdTarifa
    cIdroba:=idroba
    select roba
    hseek cIdRoba
    select rekap1

    nK0:=0 // u sluceju da je vise objekata u prikazu inventure, saberi
    nK1:=nK2:=nK3:=nK4:=nK5:=nK6:=nK7:=nK8:=0
    nMPC:=nNovaMPC:=0
    do while  !eof() .and. cG1==field->g1  .and. field->idtarifa==cIdTarifa .and. cIdRoba==field->idroba
       nK0+=k0
       nK1+=k1
       nK2+=k2
       nK3+=k3
       nK4+=k4
       nK5+=k5
       nK6+=k6
       nK7+=k7
       nK8+=k8
       nMPC:=mpc
       	// nadji prvu novu mpc
       	if ((nNovaMpc==0) .and. (field->novaMpc<>0))
       		nNovaMPC:=field->novaMpc
	endif
       ++nRec
       ShowKorner(nRec,10)
      skip
    enddo


    if xxx=1
     // ako je pocetno stanje nula i prijem u mjesecu  je nula
     if cSNule=="N" .and. roba->tip<>"N" .and. round(nk0,4)=0 .and. round(nk4,4)=0
        // nk0 - pocetno stanje, nk4 - prijem u toku mjeseca
        loop
     endif
    else  
       // nivelacije
       if round(nNovaMPC,4)=0
        loop
       endif
       if cObrNivelacije=="2"
          if xxx==2 .and. (nNovampc-field->nmpc)<0
            loop
          endif
          if xxx==3 .and. (nNovampc-field->nmpc)>0
            loop
          endif
       endif

    endif

    fFilovo:=.t.
    if xxx>=2  // obrazac nivelacije
     if prow()>PREDOVA
     	FF
	ZaglObrPC(cVarPC)
     endif
     if cProredPC="D"
      ?
     endif
     ? str(++nRbr,4)," ", cidroba; ??  " "; ?? roba->naz; ??  " "
     // grupa artikla - atvibut N1 - numericki
     @ prow(),pcol() SAY roba->N1 pict  "999"; ??  " "
     // tekuca cijena
     @ prow(),pcol() SAY nmpc pict  "999999.99"; ??  " "
     // nova cijena
     @ prow(),pcol() SAY nnovampc pict  "@Z 999999.99"; ??  " "
     if cObrNivelacije=="2" .and. xxx==3
       @ prow(),pcol() SAY nMPC-nNovampc pict  "999999.99"
       ??  " "
     else
       @ prow(),pcol() SAY nNovampc-nmpc pict  "999999.99"
       ??  " "
     endif
     ?? "____________ ____________ ____________"
    endif

    if xxx=1
     if prow()>PREDOVA; FF; ZaglINV(); endif
     ? str(++nRbr,4),"³", cidroba; ??  "³"; ?? roba->naz; ??  "³"
     // grupa artikla - atvibut N1 - numericki
     @ prow(),pcol() SAY roba->N1 pict  "999"; ??  "³"
     // tekuca cijena
     @ prow(),pcol() SAY nmpc pict  "9999.99"; ??  "³"
     // nova cijena
     @ prow(),pcol() SAY nnovampc pict  "@Z 9999.99"; ??  "³"
    endif


    nCol1:=pcol()

    if cPrikKol=="D"
      nPom:=nk0
    else
      nPom:=0
    endif

    if roba->k2<>"X"
     nTTT10+=nPom
    endif

    nTTT11+=nPom*nmpc

    if xxx==1
     // predhodno stanje
     @ prow(),pcol() SAY nPom pict pickol; ??  "³"
     @ prow(),pcol() SAY nPom*nmpc pict picdem; ??  "³"

     // prijem u mjesecu
     if cPoc=="D"
       nPom:=0
     else
       nPom:=nK4 // prijem u mjesecu
     endif
     @ prow(),pcol() SAY nPom pict pickol; ??  "³"
     @ prow(),pcol() SAY nPom*nmpc pict picdem; ??  "³"
     if roba->k2<>"X"
       nTTT20+=nPom
     endif
     nTTT21+=nPom*nmpc

     // iznos povisenja
     if cPoc=="D"
        nPom:=0
     else
       if (nnovampc-nmpc)>0 .and. round(nnovampc,3)<>0
          nPom:=(nnovampc-nmpc)*nk2
       else
          nPom:=0
       endif
     endif
     @ prow(),pcol() SAY nPom pict picdem; ??  "³"
     nTTT30+=nPom


     // iznos snizenje
     if cPoc=="D"
        nPom:=0
     else
       if (nNovampc-nmpc)<0 .and. round(nnovampc,3)<>0
         nPom:=-(nnovampc-nMPC)*nk2
       else
          nPom:=0
       endif
     endif
     @ prow(),pcol() SAY nPom pict picdem; ??  "³"
     nTTT31+=nPom

     // otpremljeno u mjesecu
     if cPoc=="D"
        nPom:=0
     else
        nPom:=nK6 // izlaz iz prodavnice po ostalim osnovama
     endif
     @ prow(),pcol() SAY nPom pict pickol; ??  "³"
     @ prow(),pcol() SAY nPom*nmpc pict picdem; ??  "³"
     if roba->k2<>"X"
       nTTT40+=nPom
     endif
     nTTT41+=nPom*nmpc

     // reklamacija
     if cPoc=="D"
        nPom:=0
     else
        nPom:=nK5 // reklamacije u mjesecu
     endif
     @ prow(),pcol() SAY nPom pict pickol; ??  "³"
     @ prow(),pcol() SAY nPom*nmpc pict picdem; ??  "³"
     if roba->k2<>"X"
       nTTT50+=nPom
     endif
     nTTT51+=nPom*nmpc

     // prodaja
     if cPoc=="D"
        nPom:=0
     else
        nPom:=nK1 // prodaja mjesecu
     endif
     @ prow(),pcol() SAY nPom pict pickol; ??  "³"
     @ prow(),pcol() SAY nPom*nmpc pict picdem; ??  "³"
     if roba->k2<>"X"
      nTTT60+=nPom
     endif
     nTTT61+=nPom*nmpc

     // zaliha
     if cPoc=="D"
        nPom:=0
     else
       nPom:=nk2
     endif

     @ prow(),pcol() SAY nPom pict pickol; ??  "³"
     if round(nNovaMPC,3)==0
       @ prow(),pcol() SAY nPom*nMPC pict picdem; ??  "³"
       if roba->k2<>"X"
         nTTT70+=nPom
       endif
       nTTT71+=nPom*nmpc
     else
       @ prow(),pcol() SAY nPom*nNovaMPC pict picdem; ??  "³"
       if roba->k2<>"X"
        nTTT70+=nPom
       endif
       nTTT71+=nPom*nNovampc
     endif

     // kumulativno prodaja
     if cPoc=="D"
        nPom:=0
     else
       nPom:=nk3
     endif

     @ prow(),pcol() SAY nPom pict pickol; ??  "³"
     @ prow(),pcol() SAY nPom*nMPC pict picdem; ??  "³"
     if roba->k2<>"X"
       nTTT80+=nPom
     endif
     nTTT81+=nPom*nmpc

     ?  m
    endif//xxx=1
    select rekap1
   enddo // cidtarifa
   
   if !fFilovo
     loop
   endif

   if xxx>=2  // obrazac nivelacije
    if prow()>PREDOVA
    	FF
	ZaglObrPC(cVarPC)
    endif
    ? m
    ? "Ukupno tarifa", cidtarifa
    ? m
   endif

   if xxx=1
    	if prow()>PREDOVA
    		FF
		ZaglINV()
	endif
    //I_ON
    ? m
    ? "Ukupno tarifa", cidtarifa
    @ prow(),nCol1 SAY nTTT10 pict pickol; ??  "³"
    @ prow(),pcol() SAY nTTT11 pict picdem; ??  "³"
    @ prow(),pcol() SAY nTTT20 pict pickol; ??  "³"
    @ prow(),pcol() SAY nTTT21 pict picdem; ??  "³"
    @ prow(),pcol() SAY nTTT30 pict picdem; ??  "³"
    @ prow(),pcol() SAY nTTT31 pict picdem; ??  "³"
    @ prow(),pcol() SAY nTTT40 pict pickol; ??  "³"
    @ prow(),pcol() SAY nTTT41 pict picdem; ??  "³"
    @ prow(),pcol() SAY nTTT50 pict pickol; ??  "³"
    @ prow(),pcol() SAY nTTT51 pict picdem; ??  "³"
    @ prow(),pcol() SAY nTTT60 pict pickol; ??  "³"
    @ prow(),pcol() SAY nTTT61 pict picdem; ??  "³"
    @ prow(),pcol() SAY nTTT70 pict pickol; ??  "³"
    @ prow(),pcol() SAY nTTT71 pict picdem; ??  "³"
    @ prow(),pcol() SAY nTTT80 pict pickol; ??  "³"
    @ prow(),pcol() SAY nTTT81 pict picdem; ??  "³"
   endif //xxx=1
   nInd:=ascan(aTarife,{|x| x[1]=cIdTarifa})
   if nInd=0
     AADD(aTarife,{ cIdTarifa, nTTT10,nTTT11,nTTT20,nTTT21,nTTT30,nTTT31,nTTT40,nTTT41,nTTT50,nTTT51,nTTT60,nTTT61,nTTT70,nTTT71,nTTT80,nTTT81})
   else
     aTarife[nInd,2]+=nTTT10 ;      aTarife[nInd,3]+=nTTT11
     aTarife[nInd,4]+=nTTT20 ;      aTarife[nInd,5]+=nTTT21
     aTarife[nInd,6]+=nTTT30 ;      aTarife[nInd,7]+=nTTT31
     aTarife[nInd,8]+=nTTT40 ;      aTarife[nInd,9]+=nTTT41
     aTarife[nInd,10]+=nTTT50;     aTarife[nInd,11]+=nTTT51
     aTarife[nInd,12]+=nTTT60;      aTarife[nInd,13]+=nTTT61
     aTarife[nInd,14]+=nTTT70;      aTarife[nInd,15]+=nTTT71
     aTarife[nInd,16]+=nTTT80;      aTarife[nInd,17]+=nTTT81
   endif
   nInd:=ascan(aTarGr,{|x| x[1]=cG1 .and. x[2]=cIdTarifa})
   if nInd=0
     AADD(aTarGr, ;
             { cG1, cIdTarifa, ;
                nTTT10,nTTT11,;
                nTTT20,nTTT21,;
                nTTT30,nTTT31,;
                nTTT40,nTTT41,;
                nTTT50,nTTT51,;
                nTTT60,nTTT61,;
                nTTT70,nTTT71,;
                nTTT80,nTTT81;
              };
        )
   else
     aTarGr[nInd,3]+=nTTT10 ;      aTarGr[nInd,4]+=nTTT11
     aTarGr[nInd,5]+=nTTT20 ;      aTarGr[nInd,6]+=nTTT21
     aTarGr[nInd,7]+=nTTT30 ;      aTarGr[nInd,8]+=nTTT31
     aTarGr[nInd,9]+=nTTT40 ;      aTarGr[nInd,10]+=nTTT41
     aTarGr[nInd,11]+=nTTT50;      aTarGr[nInd,12]+=nTTT51
     aTarGr[nInd,13]+=nTTT60;      aTarGr[nInd,14]+=nTTT61
     aTarGr[nInd,15]+=nTTT70;      aTarGr[nInd,16]+=nTTT71
     aTarGr[nInd,17]+=nTTT80;      aTarGr[nInd,18]+=nTTT81
   endif



   nTT10+=nTTT10; nTT11+=nTTT11
   nTT20+=nTTT20; nTT21+=nTTT21
   nTT30+=nTTT30; nTT31+=nTTT31
   nTT40+=nTTT40; nTT41+=nTTT41
   nTT50+=nTTT50; nTT51+=nTTT51
   nTT60+=nTTT60; nTT61+=nTTT61
   nTT70+=nTTT70; nTT71+=nTTT71
   nTT80+=nTTT80; nTT81+=nTTT81
   if xxx=1
    ? m
    I_OFF
   endif
  enddo // cg1
  

  IF !fFilovo
     LOOP
  ENDIF

  // obrazac nivelacije
  if (xxx>=2)  
    if prow()>PREDOVA
    	FF
	ZaglObrPC(cVarPC)
    endif
    ? m
    select k1; hseek cg1; select rekap1
    ? "Ukupno grupa",cg1,"-",k1->naz
    ? m
  endif

  if xxx=1
   if prow()>PREDOVA; FF; ZaglINV(); endif
   //B_ON
   ? m
   select k1
   hseek cg1
   select rekap1
   ? "Ukupno grupa",cg1,"-",k1->naz
   @ prow(),nCol1 SAY  nTT10 pict pickol; ??  "³"
   @ prow(),pcol() SAY nTT11 pict picdem; ??  "³"
   @ prow(),pcol() SAY nTT20 pict pickol; ??  "³"
   @ prow(),pcol() SAY nTT21 pict picdem; ??  "³"
   @ prow(),pcol() SAY nTT30 pict picdem; ??  "³"
   @ prow(),pcol() SAY nTT31 pict picdem; ??  "³"
   @ prow(),pcol() SAY nTT40 pict pickol; ??  "³"
   @ prow(),pcol() SAY nTT41 pict picdem; ??  "³"
   @ prow(),pcol() SAY nTT50 pict pickol; ??  "³"
   @ prow(),pcol() SAY nTT51 pict picdem; ??  "³"
   @ prow(),pcol() SAY nTT60 pict pickol; ??  "³"
   @ prow(),pcol() SAY nTT61 pict picdem; ??  "³"
   @ prow(),pcol() SAY nTT70 pict pickol; ??  "³"
   @ prow(),pcol() SAY nTT71 pict picdem; ??  "³"
   @ prow(),pcol() SAY nTT80 pict pickol; ??  "³"
   @ prow(),pcol() SAY nTT81 pict picdem; ??  "³"
  endif //XXX
  nT10+=nTT10
  nT11+=nTT11
  nT20+=nTT20
  nT21+=nTT21
  nT30+=nTT30
  nT31+=nTT31
  nT40+=nTT40
  nT41+=nTT41
  nT50+=nTT50
  nT51+=nTT51
  nT60+=nTT60
  nT61+=nTT61
  nT70+=nTT70
  nT71+=nTT71
  nT80+=nTT80
  nT81+=nTT81

  ? m
  //B_OFF
enddo //eof()


if xxx>=2  // obrazac nivelacije
if prow()>PREDOVA
	FF
	ZaglObrPC(cVarPC)
endif
? m
? "U K U P N O"
? m
endif

if xxx=1
if prow()>PREDOVA
	FF
	ZaglINV()
endif
//B_ON
? strtran(m,"-","=")
? "U K U P N O"
  @ prow(),nCol1 SAY  nT10 pict pickol; ??  "³"
  @ prow(),pcol() SAY nT11 pict picdem; ??  "³"
  @ prow(),pcol() SAY nT20 pict pickol; ??  "³"
  @ prow(),pcol() SAY nT21 pict picdem; ??  "³"
  @ prow(),pcol() SAY nT30 pict picdem; ??  "³"
  @ prow(),pcol() SAY nT31 pict picdem; ??  "³"
  @ prow(),pcol() SAY nT40 pict pickol; ??  "³"
  @ prow(),pcol() SAY nT41 pict picdem; ??  "³"
  @ prow(),pcol() SAY nT50 pict pickol; ??  "³"
  @ prow(),pcol() SAY nT51 pict picdem; ??  "³"
  @ prow(),pcol() SAY nT60 pict pickol; ??  "³"
  @ prow(),pcol() SAY nT61 pict picdem; ??  "³"
  @ prow(),pcol() SAY nT70 pict pickol; ??  "³"
  @ prow(),pcol() SAY nT71 pict picdem; ??  "³"
  @ prow(),pcol() SAY nT80 pict pickol; ??  "³"
  @ prow(),pcol() SAY nT81 pict picdem; ??  "³"


? strtran(m,"-","=")
//B_OFF

if prow()>PREDOVA-8
	FF
	ZaglINV()
endif
endif//xxx=1

IF XXX=1
?
?
? "UKUPNO TARIFE / GRUPE:"
?
ENDIF
ASORT(aTarGr,,,{|x,y| x[2]+x[1]<y[2]+y[1]})
IF XXX==1
? strtran(m,"-","=")
? len(aTarGr)
ENDIF
IF XXX=1
for nCnt:=1 to len(aTarGr)
if prow()>PREDOVA; FF; ZaglINV(); endif
select k1
hseek aTarGr[nCnt,1]
? aTarGr[nCnt,1],k1->naz,"(",trim(aTarGr[nCnt,2]),")"
  @ prow(),nCol1 SAY  aTarGr[nCnt,3] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,4] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,5] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,6] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,7] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,8] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,9] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,10] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,11] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,12] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,13] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,14] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,15] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,16] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,17] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarGr[nCnt,18] pict picdem; ??  "³"
  ? m
next
? strtran(m,"-","=")
ENDIF//XXX=1

IF XXX=1
if prow()>PREDOVA-4; FF; ZaglINV(); endif
?
?
? "UKUPNO PO TARIFAMA:"
?
ASORT(aTarife,,,{|x,y| x[1]<y[1]})
? strtran(m,"-","=")
for nCnt:=1 to len(aTarife)
if prow()>PREDOVA; FF; ZaglINV(); endif
? aTarife[nCnt,1]
  @ prow(),nCol1 SAY  aTarife[nCnt,2] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,3] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,4] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,5] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,6] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,7] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,8] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,9] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,10] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,11] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,12] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,13] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,14] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,15] pict picdem; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,16] pict pickol; ??  "³"
  @ prow(),pcol() SAY aTarife[nCnt,17] pict picdem; ??  "³"
? m
next
? strtran(m,"-","=")
ENDIF XXX=1

FF

//if gPrinter<>"R"
// ?? chr(27)+"2"
//endif

end print

if cObrnivelacije=="N" .and. xxx=1
   exit
endif

if cObrNivelacije=="D" .and. xxx==2
   exit
endif

next //xxxx

#ifdef CAX
  close all
#endif
closeret
return
*}


/*! \fn ZaglObrPC(cKako)
 *  \brief Zaglavlje obrasca inventure za prodavnicu
 *  \param cKako
 */
 
function ZaglObrPC(cKako)
*{
local cString:="NALOG ZA PROMJENU CIJENA"
local cString2:="promjena"
Preduzece()
IspisNaDan(10)
P_10CPI
if cKako<>nil
   if cKako=="2"
      cString:="POVECANJE CIJENA"
      cString2:="povecanj"
   elseif cKako=="3"
      cString:="SNIZENJE CIJENA"
      cString2:="snizenje"
   endif
endif
?
? "NAZIV OBJEKTA ",cNObjekat
?
? PADC(cString+" U PRODAVNICI:_________________"+"  ,  Datum "+dtoc(dDatDo),80)
?
P_COND
? m
? "* R  *  Sifra    *        Naziv                           *   *   STARA *   NOVA  * "+cString2+"*  zaliha    *   iznos    *  ukupno   *"
? "* BR *           *                                        *   *  cijena *  cijena *  cijene * (kolicina) *   poreza   * promjena  *"
? m
return
*}


/*! \fn ZaglInv()
 *  \brief Zaglavlje inventure
 */
 
function ZaglInv()
*{
P_10CPI
//; B_ON
?? gTS+":",gNFirma,space(40),"Strana:"+str(++nStr,3)
?
?  "Obrazac obracuna inventure za period:",dDatOd,"-",dDAtDo
?
?  "NAZIV OBJEKTA ",cNObjekat,space(30),"Kriterij za Objekat:",trim(qqKonto)
?
//B_OFF
P_COND // ? ne znam hoce li stati na A3

//if gPrinter<>"R"
// ?? chr(27)+"0"
//endif
StZaglavlje("rekinv.txt", KUMPATH)

return
*}

