
*O_FPDP1
*O_EPMD1
*O_PARTN
*O_EPMD3
*
*PicBHD:="@Z 999999999999.99"
*PicDEM:="@Z 9999999.99"
*M:="---- ------ ------ ---------------------------- -- -------- -------- -------- --------------- --------------- ---------- ----------"
*
*SELECT FPDP1; set order to 4
*cIdFirma:=cIdVN:=space(2)
*cBrNal:=space(4)
*
*Box("",1,35)
* set confirm off
* @ m_x+1,m_y+2 SAY "Nalog:" GET cIdFirma
* @ m_x+1,col()+1 SAY "-" GET cIdVN
* @ m_x+1,col()+1 SAY "-" GET cBrNal
* read; ESC_BCR
* set confirm on
*BoxC()
*
*seek cidfirma+cidvn+cbrNal
*if !found(); Msg("Nalog ne postoji !",15); closeret; endif
*
*
*nStr:=0
*
*StartPrint()
*nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
*A:=0
*
*nUkDug:=nUkPot:=0
*b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
*cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal
*select fpdp1
*if A<>0; EJECTA0; Zagl11(); endif
*DO WHILE !eof() .and. eval(b2)
*
*     if A==0; Zagl11(); endif
*     if A>64; EJECTA0; Zagl11(); endif
*      @ ++A,0 SAY RBr
*      @ prow(),pcol()+1 SAY IdKonto
*
*      if !empty(IdPartner)
*        select PARTN; hseek fpdp1->idpartner
*        cStr:=trim(naz)+" "+trim(naz2)
*        select fpdp1
*      else
*        select epmd1; hseek fpdp1->idkonto
*        cStr:=naz
*        select fpdp1
*      endif
*      aRez:=SjeciStr(cStr,28)
*
*      @ prow(),pcol()+1 SAY IdPartner
*
*      nColStr:=PCOL()+1
*      @  prow(),pcol()+1 SAY padr(aRez[1],28) // dole cu nastaviti
*
*   @ prow(),pcol()+1 SAY IdTipDok
*   nColDok:=PCOL()+1
*   @ prow(),pcol()+1 SAY BrDok
*   @ prow(),pcol()+1 SAY DatDok
*   @ prow(),pcol()+1 SAY Valuta
*
*   nColIzn:=pcol()+1
*   IF D_P=="1"
*      @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
*      @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
*      nUkDugBHD+=IznosBHD
*   ELSE
*      @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
*      @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
*      nUkPotBHD+=IznosBHD
*   ENDIF
*
*   if D_P=="1"
*      @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
*      @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
*      nUkDugDEM+=IznosDEM
*   else
*      @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
*      @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
*      nUkPotDEM+=IznosDEM
*   endif
*   Pok:=0
*   for i:=2 to len(aRez)
*     @ ++a,nColStr say aRez[i]
*     If i=2
*        @ a,nColDok say opis
*        Pok:=1
*     endif
*   next
*   If Pok=0 .and. !Empty(opis)
*      @ ++a,nColDok say opis
*   endif
*
*
*      select FPDP1
*      SKIP
*   ENDDO
*
*   IF A>61; EJECTA0; Zagl11();  endif
*
*   @ ++A,0 SAY M
*   @ ++A,0 SAY "Z B I R   N A L O G A:"
*   @ A,nColIzn SAY nUkDugBHD PICTURE picBHD
*   @ A,pcol()+1 SAY nUkPotBHD PICTURE picBHD
*   @ A,pcol()+1 SAY nUkDugDEM PICTURE picDEM
*   @ A,pcol()+1 SAY nUkPotDEM PICTURE picDEM
*   @ ++A,0 SAY M
*
*
*EJECTA0
*EndPrint()
*closeret
