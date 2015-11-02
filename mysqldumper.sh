#!/bin/bash
# App path
APPSPATH='.'

# Config DIR
CONFDIR="${APPSPATH}/conf"
# Lib DIR
LIBDIR="${APPSPATH}/lib"
# Unix Timestamp
UNIXTIME=$(date +%s)

# Load Config File
if [[ -f "${CONFDIR}/config.sh" ]]; then
  source "${CONFDIR}/config.sh"
fi

# Load Libs
if [[ -f "${LIBDIR}/func.sh" ]]; then
  source "${LIBDIR}/func.sh"
fi

# Check: if mysql is running
mySQLStatus

# Check: Root Password is set
mySQLRootPassword

# Clean Up Databses
dbCleanUp

# Dump Databses
dbDumper
