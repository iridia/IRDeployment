#!/bin/bash --

PROJECT_NAME=""
PROVISIONING_PROFILE=""
CODE_SIGN_IDENTITY="iPhone Developer"
TF_API_TOKEN=""
TF_TEAM_TOKEN=""

VERSION_MARKETING="`agvtool mvers -terse1`"
VERSION_BUILD="`agvtool vers -terse`"
COMMIT_SHA="`git rev-parse HEAD`"

BUILD_CONFIGURATION="Release"
BUILD_SDK="iphoneos"
SYMROOT="Deploy"
PRODUCT_NAME="$PROJECT_NAME.app"
DSYM_NAME="$PROJECT_NAME.app.dSYM"
IPA_NAME="$PROJECT_NAME.app.ipa"
DSYM_ZIP_NAME="$PROJECT_NAME.app.dSYM.zip"

TF_API_URI="http://testflightapp.com/api/builds.json"
TF_NOTES="$PROJECT_NAME $VERSION_MARKETING ($VERSION_BUILD) # $COMMIT_SHA"
TF_DIST_LISTS=""
TF_NOTIFY="True"

# Runs within the temp directory
# function AFTER_BUILD () {
# 
# }
