#!/bin/bash

# exit if error
set -e

CONFIG=Debug
PRODUCT_NAME=Clutter
ZIP_NAME=$PRODUCT_NAME.app.zip
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
URL="https://loc.github.io/clutter/"

cd $SCRIPT_DIR/..
git checkout master
git stash
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
cd $SCRIPT_DIR/..

git checkout gh-pages
mkdir -p release/$TAG/
cp $BUILD_DIR/$CONFIG/$ZIP_NAME release/$TAG/$ZIP_NAME

ITEMS=$(cat items.xml | tr -d '\n') awk -v find="APPCAST_ITEMS" -v replace="$ITEMS" 's=index($0,find){$0=substr($0,1,s-1) replace substr($0,s+length(find))}1' appcast.xml.template
./appcast.xml.template "$(echo $ITEMS | tr -d \")"

git add release/$TAG/$ZIP_NAME
git add items.xml
git add appcast.xml

git commit -m "releasing $tag"

git checkout master
git stash pop
