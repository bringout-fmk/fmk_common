#!/bin/bash

export BASEDIR=~/github

ITEMS="message  bterm  partnst  security pi  svi proizv event rabat/1g ugov exp_dbf xml fiscal  rn roba lokal rules"

CUR_DIR=`pwd`
for item in $ITEMS
do

echo build  $item
echo ----------------------------------------
cd $item

make 

cd $CUR_DIR

done
