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
TEMP_DIR=`mktemp -d '/tmp/Etoile.XXXXXX'`	# Clean me up

xcodebuild clean build -configuration $BUILD_CONFIGURATION -sdk $BUILD_SDK CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" SYMROOT="$TEMP_DIR" PROVISIONING_PROFILE="$PROVISIONING_PROFILE"; bailIfError


cd "$TEMP_DIR/$BUILD_CONFIGURATION-$BUILD_SDK"
mkdir Payload

cp -r $PRODUCT_NAME Payload
zip -qr $IPA_NAME Payload
zip -qr $DSYM_ZIP_NAME $DSYM_NAME

if type AFTER_BUILD >/dev/null 2>&1; then
	cd $FROM_DIR
	AFTER_BUILD; bailIfError
fi

curl $TF_API_URI -F file=@"$IPA_NAME" -F dsym=@"$DSYM_ZIP_NAME" -F api_token="$TF_API_TOKEN" -F team_token="$TF_TEAM_TOKEN" -F notes="$TF_NOTES" -F notify="$TF_NOTIFY" -F distribution_lists="$TF_DIST_LISTS"; bailIfError

rm -rv $TEMP_DIR
