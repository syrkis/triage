"""
This is a productivity time tracking app,
that monitors the time spent on each application,
and each file path (when edditing files in an editor).

by: Noah Syrkis
"""

# Imports
import psutil
from src.utils import track_app


# Main function
def main():
    apps = ['code', 'brave', 'obsidian', 'hey', 'iterm2', 'zotero', 'logseq']
    for proc in psutil.process_iter(['pid', 'name', 'username']):
        if track_app(proc.info['name'].lower(), apps):
            print(proc.info)

if __name__ == "__main__":
    main()
