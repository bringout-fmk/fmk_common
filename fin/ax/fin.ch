
#xcommand O_PRIPR     =>  select (F_PRIPR);if !used(); usex (PRIVPATH+"PRIPR");end; set order to tag "1"
#xcommand O_PRIPRRP   => select (F_PRIPRRP);if !used(); usex (strtran(cDirPriv,gSezonDir,"\")+"PRIPR") alias priprrp;end; set order to 1

#xcommand O_SUBAN    => OKumul(F_SUBAN,KUMPATH,"SUBAN",5); set order to tag "1"
#xcommand O_KUF      => OKumul(F_KUF  ,KUMPATH,"KUF"  ,2); set order to tag "ID"
#xcommand O_KIF      => OKumul(F_KIF  ,KUMPATH,"KIF"  ,2); set order to tag "ID"
#xcommand O_ANAL    =>  OKumul(F_ANAL,KUMPATH,"ANAL",3)  ; set order to tag "1"
#xcommand O_SINT    =>  OKumul(F_SINT,KUMPATH,"SINT",2)  ; set order to tag "1"

#xcommand O_RSUBAN    => select (F_SUBAN);if !used();  user (KUMPATH+"SUBAN");end; set order to 1
#xcommand O_RANAL    => select (F_ANAL);if !used();  user (KUMPATH+"ANAL");end ; set order to 1
#xcommand O_SINTSUB => select (F_SUBAN);if !used();  use  (KUMPATH+"SUBAN");end; set order to 1
#xcommand O_NALOG    => select (F_NALOG);if !used(); use  (KUMPATH+"NALOG");end; set order to 1
#xcommand O_BUDZET   => select (F_BUDZET);if !used(); use  (KUMPATH+"BUDZET");end ; set order to 1
#xcommand O_PAREK   => select (F_PAREK);if !used(); use  (KUMPATH+"PAREK");end   ; set order to 1

#xcommand O_BBKLAS    => select (F_BBKLAS);if !used(); usex (PRIVPATH+"BBKLAS");end ; set order to 1
#xcommand O_IOS    => select (F_IOS);if !used(); usex (PRIVPATH+"IOS");end   ; set order to 1
#xcommand O_PNALOG   => select (F_PNALOG);if !used(); usex (PRIVPATH+"PNALOG");end; set order to 1
#xcommand O_PSUBAN   => select (F_PSUBAN);if !used(); usex (PRIVPATH+"PSUBAN");end; set order to 1
#xcommand O_PANAL   => select (F_PANAL);if !used(); usex (PRIVPATH+"PANAL")   ;end; set order to 1
#xcommand O_PSINT   => select (F_PSINT);if !used(); usex (PRIVPATH+"PSINT")   ;end; set order to 1

#xcommand O_RJ   => select (F_RJ); if !used();  use  (KUMPATH+"RJ")    ;end; set order to tag "ID"
#xcommand O_FUNK   => select (F_FUNK);if !used();    use  (KUMPATH+"FUNK") ;end; set order to tag "ID"
#xcommand O_FOND   => select (F_FOND);if !used();    use  (KUMPATH+"FOND") ;end; set order to tag "ID"
#xcommand O_KONTO    => select (F_KONTO);if !used();  use (SIFPATH+"KONTO");end;  set order to tag "ID"
#xcommand OX_KONTO    => select (F_KONTO);if !used();  usex (SIFPATH+"KONTO") ;end ;  set order to tag "ID"
#xcommand O_KONIZ  => select (F_KONIZ); if !used(); use  (KUMPATH+"KONIZ"); end ; set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE); if !used(); use  (KUMPATH+"IZVJE"); end ; set order to tag "ID"
#xcommand O_VKSG     => select (F_VKSG);if !used();  use (SIFPATH+"VKSG");end;  set order to tag "1"
#xcommand OX_VKSG     => select (F_VKSG);if !used();  usex (SIFPATH+"VKSG") ;end ;  set order to tag "1"


#xcommand O_ZAGLI  => select (F_ZAGLI); if !used(); use  (KUMPATH+"ZAGLI"); end ; set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ); if !used(); use  (KUMPATH+"KOLIZ"); end ; set order to tag "ID"
#xcommand O_BUIZ   => select (F_BUIZ);  if !used(); use  (KUMPATH+"BUIZ"); end  ; set order to tag "ID"

#xcommand O_RKONTO    => select (F_KONTO);if !used();  user (SIFPATH+"KONTO");end ; set order to tag "ID"
#xcommand O_PARTN    => select (F_PARTN);if !used();  use (SIFPATH+"PARTN") ;end; set order to tag "ID"
#xcommand OX_PARTN    => select (F_PARTN);if !used();  usex (SIFPATH+"PARTN");end ; set order to tag "ID"
#xcommand O_RPARTN    => select (F_PARTN);if !used();  user (SIFPATH+"PARTN");end ; set order to tag "ID"
#xcommand O_TNAL    => select (F_TNAL);if !used();  use (SIFPATH+"TNAL")    ;end  ; set order to tag "ID"
#xcommand OX_TNAL    => select (F_TNAL);if !used();  usex (SIFPATH+"TNAL")   ;end   ; set order to tag "ID"
#xcommand O_TDOK    => select (F_TDOK);if !used();  use (SIFPATH+"TDOK")     ;end ; set order to tag "ID"
#xcommand OX_TDOK    => select (F_TDOK);if !used();  usex (SIFPATH+"TDOK")    ;end  ; set order to tag "ID"
#xcommand O_PKONTO   => select (F_PKONTO);if !used(); use  (SIFPATH+"pkonto")  ;end; set order to tag "ID"
#xcommand OX_PKONTO   => select (F_PKONTO);if !used(); usex  (SIFPATH+"pkonto") ;end ; set order to tag "ID"
#xcommand O_VALUTE   => select(F_VALUTE);if !used();  use  (SIFPATH+"VALUTE")  ;end; set order to tag "ID"
#xcommand OX_VALUTE   => select(F_VALUTE);if !used();  usex  (SIFPATH+"VALUTE")  ;end; set order to tag "ID"

#xcommand O_FAKT      => select (F_FAKT) ;if !used();   use  (gFaktKum+"FAKT") ;end; set order to tag  "1"


#xcommand O_ROBA   => select(F_ROBA);if !used();  use  (SIFPATH+"ROBA")  ;end; set order to tag "ID"
#xcommand O_SAST   => select(F_SAST);if !used();  use  (SIFPATH+"SAST")  ;end; set order to tag "ID"
#xcommand O_TARIFA   => select(F_TARIFA);if !used();  use  (SIFPATH+"TARIFA") ;end ; set order to tag "ID"
#xcommand O_TRFP2    => select(F_TRFP2);if !used();   use  (SIFPATH+"TRFP2")   ;end; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);if !used();  use  (SIFPATH+"KONCIJ")     ;end; set order to tag "ID"
#xcommand O_FINMAT  => select(F_FINMAT);if !used(); usex (PRIVPATH+"FINMAT")    ;end; set order to 1

#xcommand O__KONTO => select(F__KONTO); use  (PRIVPATH+"_KONTO")
#xcommand O__PARTN => select(F__PARTN); use  (PRIVPATH+"_PARTN")

#xcommand O_UGOV     => select(F_UGOV);if !used();    use  (strtran(KUMPATH,"FIN","FAKT")+"UGOV")     ;end; set order to tag "ID"
#xcommand O_RUGOV    => select(F_RUGOV);if !used();    use (STRTRAN(KUMPATH,"FIN","FAKT")+"RUGOV")   ;end; set order to tag "ID"
#xcommand O_DEST     => select(F_DEST);if !used();    use  (STRTRAN(KUMPATH,"FIN","FAKT")+"DEST")     ;end; set order to tag "1"
#xcommand O_VRSTEP => SELECT (F_VRSTEP); if !used(); USE (SIFPATH+"VRSTEP"); end; set order to tag "ID"
#xcommand O_VPRIH => SELECT (F_VPRIH); if !used(); USE (SIFPATH+"VPRIH"); end; set order to tag "ID"
#xcommand O_ULIMIT => SELECT (F_ULIMIT); if !used(); USE (SIFPATH+"ULIMIT"); end; set order to tag "ID"

