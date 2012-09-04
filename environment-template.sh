#!/bin/bash --

PROJECT_NAME=""
PROVISIONING_PROFILE=""
CODE_SIGN_IDENTITY="iPhone Developer"

VERSION_MARKETING="`agvtool mvers -terse1`"
VERSION_BUILD="`agvtool vers -terse`"
COMMIT_SHA="`git rev-parse HEAD`"

BUILD_CONFIGURATION="Release"
BUILD_SDK="iphoneos"
SYMROOT="Deploy"
PRODUCT_NAME="$PROJECT_NAME.app"
TARGET_NAME="$PROJECT_NAME"
DSYM_NAME="$PROJECT_NAME.app.dSYM"
IPA_NAME="$PROJECT_NAME.app.ipa"
DSYM_ZIP_NAME="$PROJECT_NAME.app.dSYM.zip"

PROJECT_DESCRIPTION="$PROJECT_NAME $VERSION_MARKETING ($VERSION_BUILD) # $COMMIT_SHA"

# Enable them For TestFlight
# See Recipe in README
# 
# TF_API_URI="http://testflightapp.com/api/builds.json"
# TF_API_TOKEN=""
# TF_TEAM_TOKEN=""
# TF_NOTIFY="True"
# TF_DIST_LISTS=""

# Enable them for HockeyApp
# See Recipe in README
# 
# HOCKEY_APP_IDENTIFIER=""
# HOCKEY_APP_TOKEN=""
# HOCKEY_API_URI="https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_IDENTIFIER/app_versions"
# HOCKEY_API_NOTIFY="0" # 0: Don’t notify; 1: Notify
# HOCKEY_API_STATUS="1" # 1: Don’t allow downloads; 2: allow downloads
# HOCKEY_API_NOTES_TYPE="1" # 0: Textile; 1: Markdown
