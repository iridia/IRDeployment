# IRDeployment

IRDeployment is basically a script that builds an iOS project using `xcodebuild`, and punts it on TestFlight.

##	Recommended usage

*	Include this repository as a submodule.

*	Prepare a proper copy `environment.sh` somewhere.  If you do CI integration, you can host it somewhere else and copy it into the repository when you need to build something.

	There’s a `environment-template.sh` to get you started.
	
*	Invoke `deploy.sh` from the root of your project, wherever there’s one Xcode project.


###	What’s in `environment.sh`

The Environment file fills many fields with default values for you, including the Product Name, the SDK, the build configuration, using sensible defaults.  You must provide identifiers of your preferred Code Signing Identity, and the Provisioning Profile, for the build to work.

By default, you must provide a TestFlight API token, as well as your team token and the name of the default Distribution List that gets the notification.  This is provided so you can have only a subset of developers get build notifications, and manually re-edit the testers of the build once it passes muster.

If you’d like to archive the build artifacts — for example, storing the dSYM or the app bundle for later use, or to talk with other third party APIs — you’ll have to use the AFTER_BUILD function.  For example, this sample function would attempt to run another unit test, and will fail the entire build if the tests failed:

	function AFTER_BUILD () {

		xcodebuild build -target "app-Test" -configuration $BUILD_CONFIGURATION -sdk iphonesimulator SYMROOT="$TEMP_DIR"

	}
	
And this function sends the build items to a custom S3 bucket:

	function AFTER_BUILD () {

		cd $PRODUCT_DIR
		curl -F key="$DSYM_NAME" -F file="@$DSYM_NAME" -F AWSAccessKeyId="$AWS_S3_ACCESS_KEY_ID" -F acl=public-read -F filename="$DSYM_NAME" -F policy="$AWS_POLICY_DSYM" -F signature="$AWS_S3_DSYM_SIGNATURE" $AWS_S3_BUCKET_HTTP_URI
		curl -F key="$IPA_NAME" -F file="@$IPA_NAME" -F AWSAccessKeyId=AWS_S3_ACCESS_KEY_ID -F acl=public-read -F filename="$IPA_NAME" -F policy="$AWS_S3_IPA_POLICY" -F signature="$AWS_S3_IPA_SIGNATURE" $AWS_S3_BUCKET_HTTP_URI
		
		#	The URI is something along the line of http://bucket.s3.amazonaws.com
		#	For policies and signatures, See “Browser Uploads to S3 using HTML POST Forms”, James Murty, http://aws.amazon.com/articles/1434

	}

###	Other variables

You’ll find several variables exposed for your own convenience:

*	The `$TEMP_DIR` is where the build goes to, in order not to disturb what’s already in the repository.  Using it as the `SYMROOT` of your `xcodebuild` operation makes things tidy.  The temporary directory is automatically removed after each invocation.

*	The `$PRODUCT_DIR` is the directory inside the Temporary Directory which holds the corresponding build for the SDK and build configuration.  You’ll usually find the app bundle and the dSYM file right within the directory.

*	The `$PRODUCT_NAME` is provided in the Environments file and should match the built .app bundle.  For example if your app bundle is named `MyApplication.app`, then `$PRODUCT_NAME` should also be `MyApplication.app` for the script to function correctly.

	The product name is usually configured in your Xcode project.
	
*	The `$DSYM_NAME` is also provided in the Environments file, and should match the name of your .dSYM folder.

*	In the `AFTER_BUILD` block, the `$DSYM_ZIP_NAME` points to the name of a zip file, relative to `$PRODUCT_DIR`.

### `AFTER_BUILD` Recipes

#### Post to TestFlight

	cd "$PRODUCT_DIR"
	curl $TF_API_URI -F file=@"$IPA_NAME" -F dsym=@"$DSYM_ZIP_NAME" -F api_token="$TF_API_TOKEN" -F team_token="$TF_TEAM_TOKEN" -F notes="$PROJECT_DESCRIPTION" -F notify="$TF_NOTIFY" -F distribution_lists="$TF_DIST_LISTS"; bailIfError

#### Post to HockeyApp

	function AFTER_BUILD () {

		cd "$PRODUCT_DIR"
		curl $HOCKEY_API_URI \
			-F status="$HOCKEY_API_STATUS" \
			-F notify="$HOCKEY_API_NOTIFY" \
			-F notes="$PROJECT_DESCRIPTION" \
			-F notes_type="1" \
			-F ipa=@"$IPA_NAME" \
			-F dsym=@"$DSYM_ZIP_NAME" \
			-H "X-HockeyAppToken: $HOCKEY_APP_TOKEN"; bailIfError
	
	}
