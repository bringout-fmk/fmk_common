#include "fmk.ch"


/*! \fn ShowIznRac(nIznos)
 *  \brief Ispisuje iznos racuna velikim slovima
 */

function ShowIznRac(nIznos)
*{
LOCAL cIzn, nCnt, Char, NextY, nPrevRow := ROW(), nPrevCol := COL()
SETPOS (0,0)

Box (, 9, 77)
cIzn := ALLTRIM (TRANSFORM (nIznos, "9999999.99"))
@ m_x,m_y+28 SAY "  IZNOS RACUNA JE  " COLOR INVERT
NextY := m_y + 76
FOR nCnt := LEN (cIzn) TO 1 STEP -1
   Char := SUBSTR (cIzn, nCnt, 1)
   DO CASE
      CASE Char = "1"
         NextY -= 6
         @ m_x+2, NextY SAY " ��"
         @ m_x+3, NextY SAY "  �"
         @ m_x+4, NextY SAY "  �"
         @ m_x+5, NextY SAY "  �"
         @ m_x+6, NextY SAY "  �"
         @ m_x+7, NextY SAY "  �"
         @ m_x+8, NextY SAY "  �"
         @ m_x+9, NextY SAY "�����"
      CASE Char = "2"
         NextY -= 8
         @ m_x+2, NextY SAY "�������"
         @ m_x+3, NextY SAY "      �"
         @ m_x+4, NextY SAY "      �"
         @ m_x+5, NextY SAY "�������"
         @ m_x+6, NextY SAY "�"
         @ m_x+7, NextY SAY "�"
         @ m_x+8, NextY SAY "�     �"
         @ m_x+9, NextY SAY "�������"
      CASE Char = "3"
         NextY -= 8
         @ m_x+2, NextY SAY " ������"
         @ m_x+3, NextY SAY "      �"
         @ m_x+4, NextY SAY "      �"
         @ m_x+5, NextY SAY "  ����"
         @ m_x+6, NextY SAY "      �"
         @ m_x+7, NextY SAY "      �"
         @ m_x+8, NextY SAY "      �"
         @ m_x+9, NextY SAY "�������"
      CASE Char = "4"
         NextY -= 8
         @ m_x+2, NextY SAY "�"
         @ m_x+3, NextY SAY "�"
         @ m_x+4, NextY SAY "�     �"
         @ m_x+5, NextY SAY "�     �"
         @ m_x+6, NextY SAY "�������"
         @ m_x+7, NextY SAY "      �"
         @ m_x+8, NextY SAY "      �"
         @ m_x+9, NextY SAY "      �"
      CASE Char = "5"
         NextY -= 8
         @ m_x+2, NextY SAY "�������"
         @ m_x+3, NextY SAY "�"
         @ m_x+4, NextY SAY "�"
         @ m_x+5, NextY SAY "�������"
         @ m_x+6, NextY SAY "      �"
         @ m_x+7, NextY SAY "      �"
         @ m_x+8, NextY SAY "�     �"
         @ m_x+9, NextY SAY "�������"
      CASE Char = "6"
         NextY -= 8
         @ m_x+2, NextY SAY "�������"
         @ m_x+3, NextY SAY "�"
         @ m_x+4, NextY SAY "�"
         @ m_x+5, NextY SAY "�������"
         @ m_x+6, NextY SAY "�     �"
         @ m_x+7, NextY SAY "�     �"
         @ m_x+8, NextY SAY "�     �"
         @ m_x+9, NextY SAY "�������"
      CASE Char = "7"
         NextY -= 8
         @ m_x+2, NextY SAY "�������"
         @ m_x+3, NextY SAY "      �"
         @ m_x+4, NextY SAY "     �"
         @ m_x+5, NextY SAY "    �"
         @ m_x+6, NextY SAY "   �"
         @ m_x+7, NextY SAY "  �"
         @ m_x+8, NextY SAY " �"
         @ m_x+9, NextY SAY "�"
      CASE Char = "8"
         NextY -= 8
         @ m_x+2, NextY SAY "�������"
         @ m_x+3, NextY SAY "�     �"
         @ m_x+4, NextY SAY "�     �"
         @ m_x+5, NextY SAY " ����� "
         @ m_x+6, NextY SAY "�     �"
         @ m_x+7, NextY SAY "�     �"
         @ m_x+8, NextY SAY "�     �"
         @ m_x+9, NextY SAY "�������"
      CASE Char = "9"
         NextY -= 8
         @ m_x+2, NextY SAY "�������"
         @ m_x+3, NextY SAY "�     �"
         @ m_x+4, NextY SAY "�     �"
         @ m_x+5, NextY SAY "�������"
         @ m_x+6, NextY SAY "      �"
         @ m_x+7, NextY SAY "      �"
         @ m_x+8, NextY SAY "�     �"
         @ m_x+9, NextY SAY "�������"
      CASE Char = "0"
         NextY -= 8
         @ m_x+2, NextY SAY " ����� "
         @ m_x+3, NextY SAY "�     �"
         @ m_x+4, NextY SAY "�     �"
         @ m_x+5, NextY SAY "�     �"
         @ m_x+6, NextY SAY "�     �"
         @ m_x+7, NextY SAY "�     �"
         @ m_x+8, NextY SAY "�     �"
         @ m_x+9, NextY SAY " �����"
      CASE Char = "."
         NextY -= 4
         @ m_x+9, NextY SAY "���"
      CASE Char = "-"
         NextY -= 6
         @ m_x+5, NextY SAY "�����"
   ENDCASE
NEXT
SETPOS (nPrevRow, nPrevCol)
return
*}


// sekvenca za cjepanje trake
function sjeci_traku(cSekv)
*{
if EMPTY(cSekv)
	return
endif
Setpxlat()
if gPrinter <> "R"
	qqout(cSekv)
endif
konvtable()
return
*}


// otvaranje ladice
function otvori_ladicu(cSekv)
*{
if EMPTY(cSekv)
	return
endif
Setpxlat()
if gPrinter <> "R"
	qqout(cSekv)
endif
konvtable()
return
*}



