local dSDat:=date()
local cVrij:=time()

set date format to "DD.MM.YYYY"

clear
@ 2,5 SAY "........ SIGMA-COM software ........."

 @ 4, 5 SAY  "Datum:  " GET dSDat
 @ 5, 5 SAY  "Vrijeme:" GET cVrij
 read


  cDN:="N"
  @ 8, 5 SAY  "Postaviti vrijeme i datum racunara:" GET cDn pict "@!" valid cdn $ "DN"
  read

  if cDN=="D"
   setdate(dSDat)
   settime(cVrij)
  endif
