#!/bin/bash

BASE=$(pwd)
cd $BASE
find $BASE \
	-path "$BASE/*build*/*" -prune -o \
	-path "$BASE/*test*/*" -prune -o \
	-path "$BASE/*.ccls-cache*/*" -prune -o \
	-name "*.[chxsS]" -print > $BASE/cscope.files
cscope -b -q
