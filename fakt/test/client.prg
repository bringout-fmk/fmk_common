
cRoot:="I:\SIGMA\SC\FAKT\"

do while .t.
 nH:=fopen(cRoot+"BROJAC",2)
 if nH > 0
    exit
 endif
enddo

cBuf:=space(8)
nRead:=fread(nH,@cBuf,8)
? "procitano",nread,"cbuf:", '#'+cbuf+'#'

cBuf:=allTrim(cBuf)

cImeFajla:=padl(cBuf,8,"0")
nBroj:=int(val(cBuf))

cBuf:=str(nbroj+1)
cBuf:=padl(alltrim(cBuf),8,"0")
? cbuf

fseek(nH,0) // idi na pocetak
fwrite(nH,cBuf,8)
fclose(nH)

cImeFak:=cBuf + ".FAK"

cImeFajla:=cRoot + cImeFak
? cImeFajla
nH:=fcreate( cImeFajla )
//fwrite(nH,'qout("test")' + chr(13)+chr(10))
//fwrite(nH,'qout("test2")'+ chr(13)+chr(10))
//for i:=1 to 10000
//  fwrite(nH,'qout("test'+str(i)+'")'+ chr(13)+chr(10))
//next
//fwrite(nH,'A:=10'+ chr(13)+chr(10))
//fwrite(nH,'B:=11'+ chr(13)+chr(10))
//fwrite(nH,'C:=A-B'+ chr(13)+chr(10))

/*
cPom:='dbusearea(.t.,nil,"i:\sigma\sc\sif1\partn")'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='dbappend()'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='_field->id:="0xx021"'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='_field->naz:="yyyernad"'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='dbclosearea()'
fwrite(nH,cPom+chr(13)+chr(10))


cPom:='dbusearea(.t.,nil,"i:\sigma\sc\sif1\roba")'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='dbappend()'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='_field->id:="01"'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='_field->naz:="roba 01"'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='_field->vpc:=1'
fwrite(nH,cPom+chr(13)+chr(10))


cPom:='dbappend()'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='_field->id:="02"'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='_field->naz:="roba 02"'
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='_field->vpc:=12'
fwrite(nH,cPom+chr(13)+chr(10))


cPom:='dbclosearea()'
fwrite(nH,cPom+chr(13)+chr(10))

*/

cDok:="00001"
@ 10,10 SAY "Dokument br 20-10 :" GET cDok
read

fwrite(nH, "__UTOKU__" + chr(13)+chr(10) )



cpom:="quite()"
? cPom
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='stdok2("10","20","'+cDok+'")'
? cPom
fwrite(nH,cPom+chr(13)+chr(10))

cPom:='__SHOW__'
? cPom
fwrite(nH,cPom+chr(13)+chr(10))


// zapisi na vrhu da je zavrsen posao !!!!! obavezno
fseek (nH, 0)
fwrite(nH, "__START__" + chr(13)+chr(10) )
fclose(nH)

inkey(0)

do while .t.
 if FILE ( cRoot+"xrez\" + cImeFak )
       // cekam rezultat ....
       cKom:="q "+ cRoot+"xrez\" + cImeFak
       run &cKom
       exit
 else
       ? "cekam rezultat" , cRoot+"xrez\" + cImeFak
 endif
enddo

