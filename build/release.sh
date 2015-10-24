#!/bin/bash

# exit if error
set -e

if (( $# != 2 ))
then
	echo "Usage: ./build.sh notes.html \"Version number 2!\""
	exit 1
fi

CONFIG=Debug
PRODUCT_NAME=Clutter
ZIP_NAME=$PRODUCT_NAME.app.zip
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
URL="https://loc.github.io/clutter"
RSS_DATE=`date +"%a, %d %b %Y %H:%M:%S %z"`
NOTES_FILE="$1"
MSG="$2"

cd $SCRIPT_DIR/..
git checkout gh-pages
git stash
git checkout master
TAG=`git describe --tag`
TAG_NO_V=`echo $TAG | awk '{print substr($1, 2);}'`

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $TAG_NO_V" $SCRIPT_DIR/../$PRODUCT_NAME/$PRODUCT_NAME-Info.plist-

# build 
xcodebuild -scheme Clutter -workspace Clutter.xcworkspace/ -configuration $CONFIG build

# reset so it doesn't actually mess with the plist in the project file
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion DEVELOPMENT" $SCRIPT_DIR/../$PRODUCT_NAME/$PRODUCT_NAME-Info.plist-

BUILD_DIR=`xcodebuild -scheme Clutter -workspace Clutter.xcworkspace/ -configuration $CONFIG -showBuildSettings | grep -e "\sBUILD_DIR\s" | awk -F '=' '{ print $2 }'`


cd $BUILD_DIR/$CONFIG
echo $BUILD_DIR/$CONFIG
zip -r $ZIP_NAME Clutter.app
DSA=`$SCRIPT_DIR/sign_update $ZIP_NAME $SCRIPT_DIR/../dsa_priv.pem`
cd $SCRIPT_DIR/..


git checkout gh-pages
git stash pop
mkdir -p release/$TAG/
cp $BUILD_DIR/$CONFIG/$ZIP_NAME release/$TAG/$ZIP_NAME
mv $NOTES_FILE release/$TAG/NOTES.html

BYTE_LENGTH=$(wc -c < release/$TAG/$ZIP_NAME)

cat << 'EOF' > newitem.xml
<item>
	<title>$MSG</title>
	<sparkle:releaseNotesLink>
		$URL/release/$TAG/NOTES.html
	</sparkle:releaseNotesLink>
	<pubDate>$RSS_DATE</pubDate>
	<enclosure url="$URL/release/$TAG/$ZIP_NAME"
		sparkle:version="$TAG_NO_V"
		sparkle:dsaSignature="$DSA"
		length="$BYTE_LENGTH"
		type="application/octet-stream" />
</item>
EOF

cat newitem.xml items.xml >> items.xml.new
mv items.xml.new items.xml
rm newitem.xml

./appcast.xml.template "$(cat items.xml | awk '{gsub("\"", "\\\""); print $0; }')" > appcast.xml

git add release/$TAG/NOTES.html
git add release/$TAG/$ZIP_NAME
git add items.xml
git add appcast.xml

#git commit -m "releasing $tag"
