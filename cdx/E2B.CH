#ifdef C52
private cBezveze:=" "
select tippr; seek DVAR1; select ld
if tippr->(found())  .and. tippr->aktivan=="D"
 if tippr->fiksan $ "DN"
      @ m_x+DRED,m_Y+2 SAY tippr->id+"-"+tippr->naz+" (SATI) " GET DVAR2  pict gpics;
                  when {|| tippr->(dbseek(DVAR1)),.t.} ;
                  valid {|| Izracunaj(@DVAR3) }
 elseif tippr->fiksan=="P"
    @ m_x+DRED,m_Y+2 SAY tippr->id+"-"+tippr->naz+" (%)    " GET DVAR2  pict "999.99";
      when {|| tippr->(dbseek(DVAR1)),.t.} ;
      valid {|| Izracunaj(@DVAR3) }
 elseif tippr->fiksan=="C"
    @ m_x+DRED,m_Y+2 SAY tippr->id+"-"+tippr->naz+"        " GET cBezveze;
      when {|| tippr->(dbseek(DVAR1)),.t.} ;
      valid {|| Izracunaj(@DVAR3) }
 endif
 @ m_x+DRED,m_y+50 SAY "IZNOS" GET DVAR3 pict gpici
endif
#else
private cBezveze:=" "
select tippr; seek DVAR1; select ld
if tippr->(found())  .and. tippr->aktivan=="D"
 if tippr->fiksan $ "DN"
      @ m_x+DRED,m_Y+2 SAY tippr->id+"-"+tippr->naz+" (SATI) " GET DVAR2  pict gpics;
                  when {|| tippr->(dbseek("1"+DVAR1)),.t.} ;
                  valid {|| Izracunaj(@DVAR3) }
 elseif tippr->fiksan=="P"
    @ m_x+DRED,m_Y+2 SAY tippr->id+"-"+tippr->naz+" (%)    " GET DVAR2  pict "999.99";
      when {|| tippr->(dbseek("1"+DVAR1)),.t.} ;
      valid {|| Izracunaj(@DVAR3) }
 elseif tippr->fiksan=="C"
    @ m_x+DRED,m_Y+2 SAY tippr->id+"-"+tippr->naz+"        " GET cBezveze;
      when {|| tippr->(dbseek("1"+DVAR1)),.t.} ;
      valid {|| Izracunaj(@DVAR3) }
 endif
 @ m_x+DRED,m_y+50 SAY "IZNOS" GET DVAR3 pict gpici
endif
#endif
