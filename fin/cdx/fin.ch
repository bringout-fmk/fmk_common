
#xcommand O_PRIPR     => select (F_PRIPR);   usex (PRIVPATH+"PRIPR") ; set order to tag "1"
#xcommand O_PRIPRRP   => select (F_PRIPRRP); usex (strtran(cDirPriv,goModul:oDataBase:cSezonDir,SLASH)+"PRIPR") alias priprrp; set order to 1

#xcommand O_SUBAN    => OKumul(F_SUBAN,KUMPATH,"SUBAN",5); set order to tag 1
#xcommand O_KUF      => OKumul(F_KUF  ,KUMPATH,"KUF"  ,2); set order to tag "ID"
#xcommand O_KIF      => OKumul(F_KIF  ,KUMPATH,"KIF"  ,2); set order to tag "ID"
#xcommand O_ANAL    =>  OKumul(F_ANAL,KUMPATH,"ANAL",3)  ; set order to tag 1
#xcommand O_SINT    =>  OKumul(F_SINT,KUMPATH,"SINT",2)  ; set order to tag 1
#xcommand O_NALOG    => OKumul(F_NALOG,KUMPATH,"NALOG",2); set order to tag 1

#xcommand O_RSUBAN    => select (F_SUBAN);  user (KUMPATH+"SUBAN"); set order to 1
#xcommand O_RANAL    => select (F_ANAL);    user (KUMPATH+"ANAL") ; set order to 1
#xcommand O_SINTSUB => select (F_SUBAN);    use  (KUMPATH+"SUBAN"); set order to 1
#xcommand O_BUDZET   => select (F_BUDZET);    use  (KUMPATH+"BUDZET") ; set order to 1
#xcommand O_PAREK   => select (F_PAREK);    use  (KUMPATH+"PAREK")   ; set order to 1

#xcommand O_BBKLAS    => O_POMDB(F_BBKLAS,"BBKLAS"); set order to 1
#xcommand O_IOS    =>   O_POMDB(F_IOS,"IOS"); set order to 1

#xcommand O_PNALOG   => select (F_PNALOG); usex (PRIVPATH+"PNALOG"); set order to 1
#xcommand O_PSUBAN   => select (F_PSUBAN); usex (PRIVPATH+"PSUBAN"); set order to 1
#xcommand O_PANAL   => select (F_PANAL); usex (PRIVPATH+"PANAL")   ; set order to 1
#xcommand O_PSINT   => select (F_PSINT); usex (PRIVPATH+"PSINT")   ; set order to 1

#xcommand O_RJ   => select (F_RJ);          use  (KUMPATH+"RJ")    ; set order to tag "ID"
#xcommand O_FUNK   => select (F_FUNK);    use  (KUMPATH+"FUNK") ; set order to tag "ID"
#xcommand O_FOND   => select (F_FOND);    use  (KUMPATH+"FOND") ; set order to tag "ID"
#xcommand O_KONIZ  => select (F_KONIZ);    use  (KUMPATH+"KONIZ") ; set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE);    use  (KUMPATH+"IZVJE") ; set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI);    use  (KUMPATH+"ZAGLI") ; set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ);    use  (KUMPATH+"KOLIZ") ; set order to tag "ID"
#xcommand O_BUIZ   => select (F_BUIZ);    use  (KUMPATH+"BUIZ") ; set order to tag "ID"
#xcommand O_KONTO    => select (F_KONTO);  use (SIFPATH+"KONTO");  set order to tag "ID"
#xcommand OX_KONTO    => select (F_KONTO);  usex (SIFPATH+"KONTO")  ;  set order to tag "ID"
#xcommand O_VKSG     => select (F_VKSG);  use (SIFPATH+"VKSG");  set order to tag "1"
#xcommand OX_VKSG     => select (F_VKSG);  usex (SIFPATH+"VKSG")  ;  set order to tag "1"

#xcommand O_RKONTO    => select (F_KONTO);  user (SIFPATH+"KONTO") ; set order to tag "ID"
#xcommand O_PARTN    => select (F_PARTN);  use (SIFPATH+"PARTN") ; set order to tag "ID"
#xcommand OX_PARTN    => select (F_PARTN);  usex (SIFPATH+"PARTN") ; set order to tag "ID"
#xcommand O_RPARTN    => select (F_PARTN);  user (SIFPATH+"PARTN") ; set order to tag "ID"
#xcommand O_TNAL    => select (F_TNAL);  use (SIFPATH+"TNAL")      ; set order to tag "ID"
#xcommand OX_TNAL    => select (F_TNAL);  usex (SIFPATH+"TNAL")      ; set order to tag "ID"
#xcommand O_TDOK    => select (F_TDOK);  use (SIFPATH+"TDOK")      ; set order to tag "ID"
#xcommand OX_TDOK    => select (F_TDOK);  usex (SIFPATH+"TDOK")      ; set order to tag "ID"
#xcommand O_PKONTO   => select (F_PKONTO); use  (SIFPATH+"pkonto")  ; set order to tag "ID"
#xcommand OX_PKONTO   => select (F_PKONTO); usex  (SIFPATH+"pkonto")  ; set order to tag "ID"
#xcommand O_VALUTE   => select(F_VALUTE);  use  (SIFPATH+"VALUTE")  ; set order to tag "ID"
#xcommand OX_VALUTE   => select(F_VALUTE);  usex  (SIFPATH+"VALUTE")  ; set order to tag "ID"

#xcommand O_FAKT      => select (F_FAKT) ;   use  (gFaktKum+"FAKT") ; set order to tag  "1"
#xcommand O_KALK      => select (F_KALK) ;   use  (gKalkKum+"KALK") ; set order to tag  "1"

#xcommand O_ROBA   => select(F_ROBA);  use  (SIFPATH+"ROBA")  ; set order to tag "ID"
#xcommand O_SAST   => select(F_SAST);  use  (SIFPATH+"SAST")  ; set order to tag "ID"
#xcommand O_TARIFA   => select(F_TARIFA);  use  (SIFPATH+"TARIFA")  ; set order to tag "ID"
#xcommand O_TRFP2    => select(F_TRFP2);   use  (SIFPATH+"trfp2")       ; set order to tag "ID"
#xcommand O_TRFP3    => select(F_TRFP3);   use  (SIFPATH+"trfp3")       ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);  use  (SIFPATH+"KONCIJ")     ; set order to tag "ID"
#xcommand O_FINMAT  => select(F_FINMAT); usex (PRIVPATH+"FINMAT")    ; set order to 1

#xcommand O__KONTO => select(F__KONTO); use  (PRIVPATH+"_KONTO")
#xcommand O__PARTN => select(F__PARTN); use  (PRIVPATH+"_PARTN")

#xcommand O_UGOV     => select(F_UGOV);  use  (strtran(KUMPATH,"FIN","FAKT")+"UGOV")     ; set order to tag "ID"
#xcommand O_RUGOV    => select(F_RUGOV);  use (STRTRAN(KUMPATH,"FIN","FAKT")+"RUGOV")   ; set order to tag "ID"
#xcommand O_DEST     => select(F_DEST);  use  (STRTRAN(KUMPATH,"FIN","FAKT")+"DEST")     ; set order to tag "1"
#xcommand O_VRSTEP => SELECT (F_VRSTEP); USE (SIFPATH+"VRSTEP"); set order to tag "ID"
#xcommand O_VPRIH => SELECT (F_VPRIH); USE (SIFPATH+"VPRIH"); set order to tag "ID"
#xcommand O_ULIMIT => SELECT (F_ULIMIT); USE (SIFPATH+"ULIMIT"); set order to tag "ID"

