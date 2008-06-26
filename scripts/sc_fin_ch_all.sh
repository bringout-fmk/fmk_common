convert_header()
{
mv $1 orig

sed  -e "s/include.*sc\.ch/include \"fmk.ch/" orig > $1

}

FILES=`ls *.prg`

for f in $FILES ; do
  convert_header $f
done
