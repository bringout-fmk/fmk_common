#!/bin/bash

export BASEDIR=~/github

ITEMS="message  bterm  partnst  security pi  svi proizv event rabat ugov exp_dbf xml fiscal  rn roba lokal rules"

for item in $ITEMS
do

cd $item
make clean
make 
cd ..

done
