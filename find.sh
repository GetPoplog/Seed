#!/bin/sh
# This script finds the most recent corepop that works on this architecture. It relies
# on a very simple test to deternine if the corepop executable works - it runs it locally.
# TODO: Ideally it will run it in firejail, if available.
OSNAME=`uname -s | tr '[:upper:]' '[:lower:]'`
ARCH=`uname -m`
for i in "supplied.corepop" `ls -1r ${OSNAME}/${ARCH}/*.corepop`; do 
    output=`./$i ":sysexit()" 2>&1`
    if [ -z "$output" ]; then 
        echo $i
        break
    fi 
done
# If no good executable can be found, exit with an error code.
/bin/false
