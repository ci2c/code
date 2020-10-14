#!/bin/bash

files=$1
#Suppression de la ligne contenant la chaîne "root = false"

sed '/^Root = False/d' ${files} > /home/aurelien/${files2}a.fib

#Suppression de la ligne contenant la chaîne "??? = false"

sed '/^BinaryData = False/d' /home/aurelien/${files2}a.fib > /home/aurelien/${files2}b.fib
