#!/bin/bash
# APPSPATH
APPSPATH=$(pwd)
# APP File
APPFILE="mysqldumper.sh"

# Give user feedback
echo "Changing APPSPATH To: APPSPATH=\"$APPSPATH\""

# Expace \/
APPSPATH=$(echo $APPSPATH | sed 's/\//\\\//g')
# Change APPS PATH
sed -i "s/^\(APPSPATH=[\"|\']\).*\([\"|\']\)$/\1${APPSPATH}\2/" $APPFILE
