// kompajlira se sa CLP522R !
// --------------------------

// ovo sam napravio za MUP ZE-DO KANTONA zato çto prebacivanje obraŸuna putem
// disketa ne obuhvata Ÿitavu definiciju kredita, ve† samo one rate koje se
// odnose na obraŸun koji se prebacuje.     MS
// -----------------------------------------------
c1 := "C:\SIGMA\LD\KUM1\RADKR.DBF"     // c1 -> c3
c2 := "C:\SIGMA\LD\KUM2\RADKR.DBF"     // c2 -> c3
c3 := "F:\LD\KUM1\RADKR.DBF"           // --------

 SELECT 0
  use (c1) ALIAS B1
   set order to tag "1"
 SELECT 0
  use (c2) ALIAS B2
   set order to tag "1"
 SELECT 0
  use (c3) ALIAS B3
   set order to tag "1"

 // c1 -> c3
 // --------
 SELECT B1
 GO TOP
 DO WHILE !EOF()
   Scatter()
   SELECT B3
    SEEK STR(_godina)+STR(_mjesec)+_idradn+_idkred+_naosnovu
     IF !FOUND()
       APPEND BLANK
     ENDIF
      Gather()
   SELECT B1
   SKIP 1
 ENDDO

 // c2 -> c3
 // --------
 SELECT B2
 GO TOP
 DO WHILE !EOF()
   Scatter()
   SELECT B3
    SEEK STR(_godina)+STR(_mjesec)+_idradn+_idkred+_naosnovu
     IF !FOUND()
       APPEND BLANK
     ENDIF
      Gather()
   SELECT B2
   SKIP 1
 ENDDO
RETURN (NIL)

FUNC Gproc()
RETURN (NIL)

FUNC UcitajParams()
RETURN (NIL)

