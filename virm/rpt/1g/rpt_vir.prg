#include "\cl\sigma\fmk\virm\virm.ch"

function StDok()
*{


 LOCAL aKol, i:=0
 O_KUMUL; set order to 3; GO TOP
 PRIVATE nRbr:=0, cSort:="1", gOstr:="D", lLin:=.t.
 PRIVATE cDomaca:=ALLTRIM(ValDomaca()), cPomocna:=ALLTRIM(ValPomocna())

 IF !VarEdit({{"Sortiranje po nalogodavcima ili primaocima (1/2)","cSort","cSort$'12'","@!",};
              },;
            10,1,14,79,"STAMPA LISTE DOKUMENATA","B1")
    CLOSERET
 ENDIF

 IF cSort=="2"
   SET ORDER TO 4; GO TOP
 ENDIF

 aKol:={ { "R.br."      , {|| STR(nRbr,4)+"."   }, .f., "C", 5, 0, 1,++i },;
         { "Mjesto"     , {|| mjesto            }, .f., 'C',17, 0, 2,  i },;
         { "Nalogodavac", {|| ALLTRIM(ko_txt)+" ("+ALLTRIM(ko_sj)+")"}    , .f., 'C',55, 0, 1,++i },;
         { "Primalac"   , {|| ALLTRIM(kome_txt)+" ("+ALLTRIM(kome_sj)+")"}, .f., 'C',55, 0, 2,  i },;
         { "Rn.nalogodavca", {|| ko_zr     }, .f., 'C',22, 0, 1,++i },;
         { "Rn.primaoca"   , {|| kome_zr   }, .f., 'C',22, 0, 2,  i },;
         { ""             , {|| LEFT(svrha_doz,31)       }, .f., 'C',31, 0, 1,++i },;
         { "Svrha doznake", {|| SUBSTR(svrha_doz,32,31)  }, .f., 'C',31, 0, 2,  i },;
         { ""             , {|| RIGHT(svrha_doz,30)      }, .f., 'C',31, 0, 3,  i },;
         { "Iznos"      , {|| iznos             }, .f., 'N',20, 2, 3,  i },;
         { "Val."       , {|| "#"                             }, .f., 'C', 4, 0, 1,++i },;
         { ""           , {|| IF(nacpl=="1",cDomaca,cPomocna) }, .f., 'C', 4, 0, 3,  i } }


     //    { "Org.jed."   , {|| orgjed            }, .f., 'C',17, 0, 1,++i },;
     //    { "Poz.na br.zad.", {|| pnabrzad       }, .f., 'C',20, 0, 1,++i },;
     //    { "Poz.na br.od." , {|| pnabrod        }, .f., 'C',20, 0, 2,  i },;
 GO TOP
 START PRINT CRET
 StampaTabele(aKol,{|| ++nRbr,.t.},,gTabela,,,"PREGLED A¦URIRANIH DOKUMENATA",;
             {|| .t.},IF(gOstr=="D",,-1),,lLin,,,)
 END PRINT
return
*}



