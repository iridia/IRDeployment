#!/bin/bash --

# Execution Plan
# 
# * Load Environment from environment.sh
# 
# * Build with xcodebuild
# 
# * Use codesign --verify to make sure that the application is anchored correctly.
#   For more information:
#   * https://developer.apple.com/library/mac/#documentation/Security/Conceptual/CodeSigningGuide/Procedures/Procedures.html
#   * http://www.opensource.apple.com/source/libsecurity_cssm/libsecurity_cssm-36064/lib/oidsbase.h?txt
# 
# * Use xcrun to invoke PackageApplication and have it handle IPA packing
# 
# * Zip up the dSYM folder so third party completion handlers have a chance to get it
# 
# * Call completion handler and hand off configuration

ENV_FILE="`dirname $0`/environment.sh"
if [ ! -f $ENV_FILE ]; then
    echo "environment.sh not found.  Consult environment-template.sh."
	exit 1
fi
source $ENV_FILE

function die () { echo "☠ $1"; exit 1; }
function bailIfError () { if [ $? -ne 0 ]; then die "Bad stuff happened"; fi; }

FROM_DIR=`pwd`
TEMP_DIR=`mktemp -d '/tmp/Etoile.XXXXXX'`
PRODUCT_DIR="$TEMP_DIR/$BUILD_CONFIGURATION-$BUILD_SDK"

if [[ $BUILD_FOR = "Project" ]]; then
	xcodebuild clean build -project "$PROJECT_PATH"; -target "$TARGET_NAME"; -configuration "$BUILD_CONFIGURATION"; -sdk "$BUILD_SDK"; CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY"; SYMROOT="$TEMP_DIR"; PROVISIONING_PROFILE="$PROVISIONING_PROFILE"; bailIfError
elif [[ $BUILD_FOR = "Workspace" ]]; then
	xcodebuild clean build -workspace "$WORKSPACE_PATH" -scheme "$PROJECT_NAME" -configuration "$BUILD_CONFIGURATION" -sdk "$BUILD_SDK" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" SYMROOT="$TEMP_DIR" PROVISIONING_PROFILE="$PROVISIONING_PROFILE"; bailIfError
else
	die "BUILD_FOR should be Project or Workspace."
fi

codesign --verify -vvvv -R='anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.1] exists and (certificate leaf[field.1.2.840.113635.100.6.1.2] exists or certificate leaf[field.1.2.840.113635.100.6.1.4] exists)' "$PRODUCT_DIR/$PRODUCT_NAME"

/usr/bin/xcrun -sdk "$BUILD_SDK" PackageApplication -v "$PRODUCT_DIR/$PRODUCT_NAME" -o "$PRODUCT_DIR/$IPA_NAME" --sign "$CODE_SIGN_IDENTITY" --embed "$HOME/Library/MobileDevice/Provisioning Profiles/$PROVISIONING_PROFILE.mobileprovision"

zip -qr "$PRODUCT_DIR/$DSYM_ZIP_NAME" "$PRODUCT_DIR/$DSYM_NAME"

if type AFTER_BUILD >/dev/null 2>&1; then
	AFTER_BUILD; bailIfError
fi
