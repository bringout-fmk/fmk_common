#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/db/1g/kzb.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.3 $
 * $Log: kzb.prg,v $
 * Revision 1.3  2003/01/10 00:25:43  ernad
 *
 *
 * - popravka make systema
 * make zip ... \\*.chs -> \\\*.chs
 * ispravka std.ch ReadModal -> ReadModalSc
 * uvoðenje keyb/get.prg funkcija
 *
 * Revision 1.2  2002/06/19 12:13:26  sasa
 * no message
 *
 *
 */
 
/*! \file fmk/fin/db/1g/kzb.prg
 *  \brief Kontrola zbira naloga
 */

/*! \fn KontrZb()
 *  \brief Kontrola zbira naloga
 */
 
function KontrZb()
*{
select F_NALOG; use nalog ; set order to
select F_SUBAN; use suban ; set order to
#ifdef CAX
 AX_CacheRecords(20)
#endif
select F_ANAL; use anal  ; set order to
select F_SINT; use sint  ; set order to

Box("KZD",9,77,.f.)
set cursor off
@ m_x+1,m_y+11 say "³"+PADC("NALOZI",16)+"³"+PADC("SINTETIKA",16)+"³"+PADC("ANALITIKA",16)+"³"+PADC("SUBANALITIKA",16)
@ m_x+2,m_y+1  say REPLICATE("Ä",10)+"Å"+REPLICATE("Ä",16)+"Å"+REPLICATE("Ä",16)+"Å"+REPLICATE("Ä",16)+"Å"+REPLICATE("Ä",16)
@ m_x+3,m_y+1 say "duguje "+ValDomaca()
@ m_x+4,m_y+1 say "potraz."+ValDomaca()
@ m_x+5,m_y+1 say "saldo  "+ValDomaca()
@ m_x+7,m_y+1 say "duguje "+ValPomocna()
@ m_x+8,m_y+1 say "potraz."+ValPomocna()
@ m_x+9,m_y+1 say "saldo  "+ValPomocna()
FOR i:=11 TO 65 STEP 17
  FOR j:=3 TO 9
    @ m_x+j,m_y+i SAY "³"
  NEXT
NEXT

picBHD:=FormPicL("9 "+gPicBHD,16)
picDEM:=FormPicL("9 "+gPicDEM,16)

select NALOG;go top

nDug:=nPot:=nDu2:=nPo2:=0
DO WHILE !EOF().and.INKEY()!=27
   nDug+=DugBHD
   nPot+=PotBHD
   nDu2+=DugDEM
   nPo2+=PotDEM
   SKIP
ENDDO
if LASTKEY()==K_ESC
   BoxC()
   CLOSERET
endif
@ m_x+3,m_y+12 SAY nDug PICTURE picBHD
@ m_x+4,m_y+12 SAY nPot PICTURE picBHD
@ m_x+5,m_y+12 SAY nDug-nPot PICTURE picBHD
@ m_x+7,m_y+12 SAY nDu2 PICTURE picDEM
@ m_x+8,m_y+12 SAY nPo2 PICTURE picDEM
@ m_x+9,m_y+12 SAY nDu2-nPo2 PICTURE picDEM

select SINT; go top
nDug:=nPot:=nDu2:=nPo2:=0
go top
DO WHILE !EOF() .and. INKEY()!=27
   nDug+=Dugbhd; nPot+=Potbhd
   nDu2+=Dugdem; nPo2+=Potdem
   SKIP
ENDDO
ESC_BCR
@ m_x+3,m_y+29 SAY nDug PICTURE picBHD
@ m_x+4,m_y+29 SAY nPot PICTURE picBHD
@ m_x+5,m_y+29 SAY nDug-nPot PICTURE picBHD
@ m_x+7,m_y+29 SAY nDu2 PICTURE picDEM
@ m_x+8,m_y+29 SAY nPo2 PICTURE picDEM
@ m_x+9,m_y+29 SAY nDu2-nPo2 PICTURE picDEM


select ANAL; go top
nDug:=nPot:=nDu2:=nPo2:=0
DO WHILE !EOF() .and. INKEY()!=27
   nDug+=Dugbhd; nPot+=Potbhd
   nDu2+=Dugdem; nPo2+=Potdem
   SKIP
ENDDO
ESC_BCR
@ m_x+3,m_y+46 SAY nDug PICTURE picBHD
@ m_x+4,m_y+46 SAY nPot PICTURE picBHD
@ m_x+5,m_y+46 SAY nDug-nPot PICTURE picBHD
@ m_x+7,m_y+46 SAY nDu2 PICTURE picDEM
@ m_x+8,m_y+46 SAY nPo2 PICTURE picDEM
@ m_x+9,m_y+46 SAY nDu2-nPo2 PICTURE picDEM

select SUBAN
nDug:=nPot:=nDu2:=nPo2:=0
go top
DO WHILE !EOF() .and. INKEY()!=27
  if D_P=="1"
   nDug+=Iznosbhd; nDu2+=Iznosdem
  else
   nPot+=Iznosbhd; nPo2+=Iznosdem
  endif
  SKIP
ENDDO
ESC_BCR
@ m_x+3,m_y+63 SAY nDug PICTURE picBHD
@ m_x+4,m_y+63 SAY nPot PICTURE picBHD
@ m_x+5,m_y+63 SAY nDug-nPot PICTURE picBHD
@ m_x+7,m_y+63 SAY nDu2 PICTURE picDEM
@ m_x+8,m_y+63 SAY nPo2 PICTURE picDEM
@ m_x+9,m_y+63 SAY nDu2-nPo2 PICTURE picDEM

InkeySc(0)
BoxC()

closeret
return
*}

