#include "\cl\sigma\fmk\kam\kam.ch"

function KCKStopa()
*{
O_KS
 O_KS2
 cSta:="1"
 Box(,3,50)
   @ m_x+2, m_Y+2 SAY "Koji sifrarnik stopa treba kontrolisati (1/2) ?" GET cSta VALID cSta $ "12" PICT "9"
   READ; ESC_BCR
 BoxC()
 SELECT (IF(cSta=="1",F_KS,F_KS2))
 GO TOP
 dDat2:=DatDo; SKIP 1
 DO WHILE !EOF()
   IF DTOC(DatOd-1) != DTOC(dDat2)
     Msg('Pogresan "DatOd" na stopi ID='+id+' !',3)
   ENDIF
   dDat2:=DatDo
   SKIP 1
 ENDDO
CLOSERET
return
*}
