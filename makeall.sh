#!/bin/bash
#
# run in jqt directory

S=$(dirname "$0")

if [ "`uname`" = "Darwin" ] ; then
 export QMAKESPEC=macx-g++
fi

# use clang instead of g++
# export QMAKESPEC=linux-clang

# QM=/usr/local/bin/qmake
QM="${QM:=qmake}"
hash $QM &> /dev/null
if [ $? -eq 1 ]; then
  echo 'use qmake-qt5' >&2
  QM=qmake-qt5
fi

# old version of astyle in raspbian
./clean.sh || true
./clean.l64

cd lib
$QM && make
cd ..

cd main
$QM && make
