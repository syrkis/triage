#!/bin/bash

# Define paths
appName="Triage.app"
dbPath="$HOME/data/triage/triage.db"
thisDir=$(dirname "$0")
ddlPath="$thisDir/ddl.sql"
appPath="$thisDir/$appName"
targetPath="/Applications/$appName"
argument="$1"

echo "Argument: $argument"

# Adjust PATH for Homebrew on both Intel and Apple Silicon Macs
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

# Function to display messages
log_message() {
    echo "$1" 
}

# Check and install Homebrew if not installed
if ! command -v brew &>/dev/null; then
    log_message "Homebrew not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { log_message "Failed to install Homebrew."; exit 1; }
else
    log_message "Homebrew is already installed."
fi

# Check and install Hammerspoon if not installed
if [ ! -d "/Applications/Hammerspoon.app" ]; then
    log_message "Hammerspoon not installed. Installing Hammerspoon..."
    brew install --cask hammerspoon || { log_message "Failed to install Hammerspoon."; exit 1; }
else
    log_message "Hammerspoon is already installed."
fi

# Create Hammerspoon's Spoons directory if it doesn't exist
spoonsDir="$HOME/.hammerspoon/Spoons"
mkdir -p "$spoonsDir" || { log_message "Failed to create Spoons directory."; exit 1; }

# Copy Spoons into Hammerspoon directory if not already present
if [ ! -d "$spoonsDir" ]; then
    log_message "Copying Spoons into Hammerspoon directory..."
    cp -r "$thisDir/Spoons/"* "$spoonsDir" || { log_message "Failed to copy Spoons."; exit 1; }
fi

# Inject Spoons loading and starting commands into init.lua
initFile="$HOME/.hammerspoon/init.lua"
if [ ! -f "$initFile" ]; then
    log_message "Creating Hammerspoon init.lua..."
    touch "$initFile"
    # echo 'hs.menubar:removeFromMenuBar()' >> "$initFile"
fi

# Inject if not present
if ! grep -q "hs.loadSpoon(\"Logging\")" "$initFile"; then
    log_message "Injecting Logging spoon..."
    echo 'hs.loadSpoon("Logging")' >> "$initFile"
    echo 'spoon.Logging:start()' >> "$initFile"
fi

if ! grep -q "hs.loadSpoon(\"Survey\")" "$initFile"; then
    log_message "Injecting Survey spoon..."
    echo 'hs.loadSpoon("Survey")' >> "$initFile"
    echo 'spoon.Survey:start()' >> "$initFile"
fi

# Check and install SQLite3 if not installed
if ! command -v sqlite3 &>/dev/null; then
    log_message "SQLite3 not installed. Installing SQLite3..."
    brew install sqlite || { log_message "Failed to install SQLite3."; exit 1; }
fi

# Create database directory and initialize the database
mkdir -p "$(dirname "$dbPath")" || { log_message "Failed to create database directory"; exit 1; }
if ! sqlite3 "$dbPath" < "$ddlPath"; then
    log_message "Failed to initialize database"
    exit 1
fi

# Add Hammerspoon to the login items
# log_message "Adding Hammerspoon to login items..."
# osascript -e 'tell application "System Events" to make new login item at end with properties {path:"/Applications/Hammerspoon.app", hidden:true, name:"Hammerspoon"}' || log_message "Failed to add Hammerspoon to login items."

log_message "Setup completed successfully."
