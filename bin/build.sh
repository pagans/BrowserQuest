#!/bin/bash

# Script to generate an optimized client build of BrowserQuest

cd `dirname "$0"`
set -e

SCRIPTDIR=`pwd -P`
PROJECTDIR="../client/js"

if test -f /etc/nginx/conf.d/default.conf
then
  LOCAL=false
  BUILDDIR=/usr/share/nginx/html
else
  LOCAL=true
  BUILDDIR="../client-build"
fi

echo "Deleting previous build directory"
rm -rf $BUILDDIR

echo "Updating build file"
cd $PROJECTDIR
perl -p -e "s'dir: .*'dir: \"$BUILDDIR\",'" build.js >build-mod.js

echo "Building client with RequireJS"

cd "$SCRIPTDIR"
mkdir -p "$BUILDDIR"/js

cp -r ../shared/js "$BUILDDIR"/
#ls /usr/share/nginx/html/js/../../shared/js/gametypes.js

node ../../bin/r.js -o build-mod.js

echo "Removing unnecessary js files from the build directory"
# find $BUILDDIR/js -type f \( -iname "game.js" -or -iname "home.js" -or -iname "log.js" -or -iname "require-jquery.js" -or -iname "modernizr.js" -or -iname "css3-mediaqueries.js" -or -iname "mapworker.js" -or -iname "detect.js" -or -iname "underscore.min.js" -or -iname "text.js" \) -delete

echo "Removing sprites directory"
rm -rf "$BUILDDIR"/sprites

echo "Removing config directory"
rm -rf "$BUILDDIR"/config

echo "Moving build.txt to current dir"
mv "$BUILDDIR"/build.txt .

echo "Build complete"

LOCAL || chown nginx:nginx -R "$BUILDDIR"
