#!/bin/bash --

ENV_FILE="`dirname $0`/environment.sh"
if [ ! -f $ENV_FILE ]; then
    echo "environment.sh not found.  Consult environment-template.sh."
	exit 1
fi
source $ENV_FILE

function die () {
	echo "$1"; exit 1
}

function bailIfError () {
	if [ $? -ne 0 ]; then die "☠ Bad stuff happened"; fi
}

function hasFunction () {
    type $1 2>/dev/null | grep -q 'is a function'
}


FROM_DIR=`pwd`
TEMP_DIR=`mktemp -d` #'/tmp/Etoile.XXXXXX'`
PRODUCT_DIR="$TEMP_DIR/$BUILD_CONFIGURATION-$BUILD_SDK"

# clean

xcodebuild clean build -target "$TARGET_NAME" -configuration "$BUILD_CONFIGURATION" -sdk $BUILD_SDK CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" SYMROOT="$TEMP_DIR" PROVISIONING_PROFILE="$PROVISIONING_PROFILE"; bailIfError

cd "$PRODUCT_DIR"

codesign --verify -vvvv -R='anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.1] exists and (certificate leaf[field.1.2.840.113635.100.6.1.2] exists or certificate leaf[field.1.2.840.113635.100.6.1.4] exists)' "$PRODUCT_DIR/$PRODUCT_NAME"

/usr/bin/xcrun -sdk iphoneos PackageApplication -v "$PRODUCT_DIR/$PRODUCT_NAME" -o "$PRODUCT_DIR/$IPA_NAME" --sign "$CODE_SIGN_IDENTITY" --embed "$HOME/Library/MobileDevice/Provisioning Profiles/$PROVISIONING_PROFILE.mobileprovision"

zip -qr "$DSYM_ZIP_NAME" "$DSYM_NAME"

if type AFTER_BUILD >/dev/null 2>&1; then
	cd "$FROM_DIR"
	AFTER_BUILD; bailIfError
fi

rm -rv "$TEMP_DIR"
