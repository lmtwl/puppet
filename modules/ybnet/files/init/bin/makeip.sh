#!/bin/bash
a=9
b=0
c=$1
ca=$(( $c % 256 ))
cb=$(( $c / 256 ))
if (( cb > 0 ))
then 
  b=$(( $b + $cb ))
  if (( b > 255 ))
  then 
    ba=$(( $b % 256 ))
    bb=$(( $b / 256 ))
    a=$(( $a + $bb ))
    b=$ba
    echo $a.$b.$ca.0/24
  else 
    echo $a.$b.$ca.0/24
  fi
else
  echo $a.$b.$ca.0/24
fi
