#!/bin/bash

# -- to understand the next line ... ;-)
# echo "PWD=$PWD"
# echo "ARGV[0]=${0}"
# echo "here=${0%/*}"
source "${0%/*}/../tools/svn.scan_authors.bash_inc"

echo "scanning this folder $PWD/.. prev to recent:"
svn_scan_authors .. PREV HEAD

echo "scanning sourceforge rDebug 1 .. HEAD"
svn_scan_authors svn://svn.code.sf.net/p/rdebug/svn/trunk/src 1 HEAD

echo "scanning sourceforge rDebug 15 23"
svn_scan_authors svn://svn.code.sf.net/p/rdebug/svn/trunk/src 15 23
