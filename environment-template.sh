#!/bin/bash --

PROJECT_NAME=""
PROVISIONING_PROFILE=""
CODE_SIGN_IDENTITY="iPhone Developer"
VERSION_MARKETING=$(agvtool mvers -terse1)
VERSION_BUILD=$(agvtool vers -terse)
COMMIT_SHA=$(git rev-parse HEAD)

BUILD_FOR="Project" # "Project" or "Workspace"
PROJECT_PATH="$PROJECT_NAME.xcodeproj" # used if BUILD_FOR = "Project"
WORKSPACE_PATH="$PROJECT_NAME.xcworkspace" # used if BUILD_FOR = "Workspace"

BUILD_CONFIGURATION="Release"
BUILD_SDK="iphoneos"
SYMROOT="Deploy"
PRODUCT_NAME="$PROJECT_NAME.app"
TARGET_NAME="$PROJECT_NAME"
DSYM_NAME="$PROJECT_NAME.app.dSYM"
IPA_NAME="$PROJECT_NAME.app.ipa"
DSYM_ZIP_NAME="$PROJECT_NAME.app.dSYM.zip"

# Use a generic form for the notes.
PROJECT_DESCRIPTION="$PROJECT_NAME $VERSION_MARKETING ($VERSION_BUILD) # $COMMIT_SHA"

# Use latest Git tag + commit as notes.
# 
# GIT_TAG=$(git describe --match "v[0-9]*" --abbrev=4 HEAD);
# GIT_INFO=$(git show $GIT_TAG);
# PROJECT_DESCRIPTION="$PROJECT_NAME $VERSION_MARKETING ($VERSION_BUILD) # $COMMIT_SHA\n\n* * *\n\n$GIT_INFO"

# Post to TestFlight.
# 
# TF_API_URI="http://testflightapp.com/api/builds.json"
# TF_API_TOKEN="" # snip
# TF_TEAM_TOKEN="" # snip
# TF_NOTIFY="False"
# TF_DIST_LISTS=""
# 
# function AFTER_BUILD () {
# 
# 	cd "$PRODUCT_DIR"
# 
# 	curl $TF_API_URI \
# 		-F file=@"$IPA_NAME" \
# 		-F dsym=@"$DSYM_ZIP_NAME" \
# 		-F api_token="$TF_API_TOKEN" \
# 		-F team_token="$TF_TEAM_TOKEN" \
# 		-F notes="$PROJECT_DESCRIPTION" \
# 		-F notify="$TF_NOTIFY" \
# 		-F distribution_lists="$TF_DIST_LISTS"; bailIfError
# 
# }

# Post to HockeyApp.
# 
# HOCKEY_APP_IDENTIFIER=""
# HOCKEY_APP_TOKEN=""
# HOCKEY_API_URI="https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_IDENTIFIER/app_versions"
# HOCKEY_API_NOTIFY="1" # 0: Don’t notify; 1: Notify
# HOCKEY_API_STATUS="2" # 1: Don’t allow downloads; 2: allow downloads
# HOCKEY_API_NOTES_TYPE="1" # 0: Textile; 1: Markdown
# 
# function AFTER_BUILD () {
# 
# 	cd "$PRODUCT_DIR"
# 	
# 	# Only keep last 3 builds.
# 	
# 	curl "$HOCKEY_API_URI/delete" \
# 		-F keep=3 \
# 		-H "X-HockeyAppToken: $HOCKEY_APP_TOKEN" \
# 		--verbose; bailIfError
# 	
# 	# Send, tag internal people with tag `alphatesters`.
# 	
# 	curl $HOCKEY_API_URI \
# 	    -F status="$HOCKEY_API_STATUS" \
# 	    -F notify="$HOCKEY_API_NOTIFY" \
# 	    -F notes="$PROJECT_DESCRIPTION" \
# 	    -F notes_type="1" \
# 			-F tags="alphatesters" \
# 	    -F ipa=@"$IPA_NAME" \
# 	    -F dsym=@"$DSYM_ZIP_NAME" \
# 	    -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN" \
# 			--verbose; bailIfError
# 	
# }
