#include "\cl\sigma\fmk\virm\virm.ch"


function PrenosFin()

O_JPRIH
O_SIFK
O_SIFV
O_BANKE
// ovom procedurom cu uzeti iz pripreme zeljena konta i baciti ih u
// virmane
O_PARTN
O_VRPRIM
O_PRIPR
FO_PRIPR

cKome_Txt:=""

qqKonto:=padr(IzFmkIni("VIRM","UslKonto","5;"),60)
dDatVir:=datdok

cDOpis:=space(36)

private cKo_txt:= ""
private cKo_zr:=""

Box(,5,70)

 @ m_x+1,m_y+2 SAY "PRENOS FIN NALOGA (koji je trenutno u pripremi) u VIRM"
 cIdBanka:=padr(cko_zr,3)
 @ m_x+2,m_y+2 SAY "Posiljaoc (sifra banke):       " GET cIdBanka valid  OdBanku(gFirma,@cIdBanka)
 read
 cKo_zr:=cIdBanka
 select partn; seek gFirma; select pripr
 cKo_txt := trim(partn->naz) + ", " + trim(partn->mjesto)+", "+trim(partn->adresa) + ", " + trim(partn->telefon)
 @ m_x+3,m_y+2 SAY "Konta za koja se prave virmani ?"  GET qqKonto pict "@!S30"
 @ m_x+4,m_y+2 SAY "Dodatak na opis:" GET cDOpis
 @ m_x+5,m_y+2 SAY "Datum" GET dDatVir
 read; ESC_BCR
BoxC()

UzmiIzIni(EXEPATH+"fmk.ini","VIRM","UslKonto",qqKonto,"WRITE")

select fpripr

private aUsl1:=Parsiraj(qqKonto,"IdKonto")
if aUsl1<>NIL
 set filter to &aUsl1
endif
go top


// fpripr finansije

nRbr:=0
do while !eof()

     select VRPRIM; set order to TAG "IDKONTO"

     if empty(fpripr->idpartner)
       hseek fpripr->(idkonto)
     else
       hseek fpripr->(idkonto+idpartner)
     endif

     select VRPRIM
     if found()
        cSvrha_pl:=id
     else // probaj 6000, 6010 naci
        hseek fpripr->(idkonto)
        if found() .and. VRPRIM->dobav=="D"
          cSvrha_pl:=id
          select partn
          seek fpripr->idpartner
          cU_korist:=id
          cKome_txt:=naz
          cKome_zr:=ziror
          cKome_sj:=mjesto
          cNacPl:="1"
          Box(,3,70)
            _IdBanka2:=space(3)
            _u_korist:=cu_korist
            _kome_txt:=cKome_txt
            _kome_zr:=cKome_zr
            Beep(1)
              cIdBanka2:=space(3)
              @ m_x+1,m_y+2 SAY ckome_txt+" "+fpripr->brdok+str(fpripr->iznosbhd,12,2)
              @ m_x+2,m_y+2 SAY "Primaoc (partner/banka):" GET _u_korist valid P_Firme(@_u_korist)  pict "@!"
              @ m_x+2,col()+2 GET _IdBanka2 valid {|| OdBanku(cu_korist,@_IdBanka2), SetPrimaoc()}
            read
            cKome_txt:=_kome_txt
            cKome_zr:=_kome_zr
            cu_korist:=_u_korist

          BoxC()
          //if cnacpl=="2"
            //ckome_zr:=dziror
          //endif
       else
         select fpripr
         skip
         loop
        endif
     endif

     // firma nalogdbodavac
     select partn
     hseek  gFirma

     select PRIPR
     APPEND BLANK
     replace rbr with ++nrbr, ;
             mjesto with gmjesto,;
             svrha_pl with csvrha_pl,;
             iznos with fpripr->iznosbhd,;
             na_teret  with gFirma,;
             Ko_Txt with cKo_txt,;
             Ko_ZR with  cKo_zr ,;
             kome_txt with VRPRIM->naz,;
             kome_sj  with "",;
             kome_zr with VRPRIM->racun,;
             dat_upl with dDatVir,;
             svrha_doz with trim(VRPRIM->pom_txt)+" "+cDOpis


           //  Ko_SJ  with partn->Mjesto,;
           //  nacpl with VRPRIM->nacin_pl, ;
           //  orgjed with gorgjed,;
           //  dat_dpo with dDatVir,;
           //  sifra with VRPRIM->sifra

     //if nacpl=="2"
     //       replace iznos with fpripr->iznosDEM,;
     //               ko_zr with partn->dziror
     //endif

     if VRPRIM->dobav=="D"
         if valtype(cKome_Txt)<>"C"  .or. empty(ckome_Txt)
             Beep(2)
             Msg("Nije pronadjen dobavljac !!")
         else
             replace kome_txt with cKome_txt, ;
                  kome_zr with cKome_zr ,;
                  kome_sj with cKome_sj ,;
                  u_korist with cU_korist

           //if cNacPl=="1"
                replace iznos with fpripr->iznosbhd
                //       nacpl with   cNacPl
           //else
           //     replace iznos with fpripr->iznosdem ,;
           //            nacpl with   cNacPl
           //endif
         endif
     endif

     select fpripr
     skip

enddo

select pripr
FillJPrih()  // popuni polja javnih prihoda
return
*}




