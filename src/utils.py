"""
Utility functions for the project.
"""

# Imports
import os


# Constants
IGNORE = ['helper']


# Functions
def track_app(app, app_list):
    """
    Check if the app is in the app list with fuzzy matching.
    """
    for app_name in app_list:
        if app_name in app:
            for ignore_app in IGNORE:
                if ignore_app in app:
                    return False
            return True
    return False