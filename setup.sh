#!/bin/bash

# Path to the database file (using platform-agnostic HOME variable)
dbPath="$HOME/data/psychoscope/psychoscope.db"

# this directory
thisDir=$(dirname "$0")

# Path to the DDL file
ddlPath="$thisDir/ddl.sql"

# Ensure the database directory exists
mkdir -p "$(dirname "$dbPath")"

# Create the database file if it doesn't exist
sqlite3 "$dbPath" < "$ddlPath"
