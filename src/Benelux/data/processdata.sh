#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
awk -F',' '{print $1}' $SCRIPTPATH/Hoogte_nedbelg.csv | tail -n +2 > $SCRIPTPATH/x_values.txt
awk -F',' '{print $2}' $SCRIPTPATH/Hoogte_nedbelg.csv | tail -n +2 > $SCRIPTPATH/y_values.txt
awk -F',' '{print $3}' $SCRIPTPATH/Hoogte_nedbelg.csv | tail -n +2 > $SCRIPTPATH/heights.txt

grep "BE" $SCRIPTPATH/Hoogte_nedbelg.csv | awk -F',' '{print $1}' | tail -n +2 > $SCRIPTPATH/BEx_values.txt
grep "BE" $SCRIPTPATH/Hoogte_nedbelg.csv | awk -F',' '{print $2}' | tail -n +2 > $SCRIPTPATH/BEy_values.txt
grep "BE" $SCRIPTPATH/Hoogte_nedbelg.csv | awk -F',' '{print $3}' | tail -n +2 > $SCRIPTPATH/BEheights.txt

grep "NL" $SCRIPTPATH/Hoogte_nedbelg.csv | awk -F',' '{print $1}' | tail -n +2 > $SCRIPTPATH/NLx_values.txt
grep "NL" $SCRIPTPATH/Hoogte_nedbelg.csv | awk -F',' '{print $2}' | tail -n +2 > $SCRIPTPATH/NLy_values.txt
grep "NL" $SCRIPTPATH/Hoogte_nedbelg.csv | awk -F',' '{print $3}' | tail -n +2 > $SCRIPTPATH/NLheights.txt
