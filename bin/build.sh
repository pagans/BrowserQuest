#!/bin/bash

# Script to generate an optimized client build of BrowserQuest
set -e

cd `dirname "$0"`
SCRIPT_DIR=`pwd -P`

PROJECT_DIR=../client/js

# BUILD_DIR should be relative to PROJECT_DIR (build.js) on Windows
if test -f /etc/nginx/conf.d/default.conf
then
  LOCAL=false
  BUILD_DIR=/usr/share/nginx/html
else
  LOCAL=true
  BUILD_DIR=../../client-build
fi


get_abs() {
  cd $1
  pwd -P
}

update_js_build() {
  cd "$PROJECT_DIR"
  perl -p -e "s'dir: .*'dir: \"$BUILD_DIR\",'" build.js >build-mod.js
grep dir build-mod.js
}

create_build_dir() (
  cd "$PROJECT_DIR"
  rm -rf "$BUILD_DIR"
  mkdir "$BUILD_DIR"
)

copy_config() {
  mkdir -p "$BUILD_DIR"/config
  cp "$PROJECT_DIR"/../config/*-dist "$BUILD_DIR"/config
  rename -- -dist '' "$BUILD_DIR"/config/*-dist
  cp -n "$BUILD_DIR"/config/* "$PROJECT_DIR"/../config
}

copy_js() {
  mkdir -p "$BUILD_DIR"/js

  cp -r "$SCRIPT_DIR"/../shared/js "$BUILD_DIR"/
}

PROJECT_DIR=`get_abs "$PROJECT_DIR"`

echo "Updating build file"
update_js_build

echo "Deleting previous build directory"
create_build_dir
BUILD_DIR=`cd "$PROJECT_DIR"; get_abs "$BUILD_DIR"`

copy_config
copy_js



echo "Building client with RequireJS"
node ../../bin/r.js -o build-mod.js

echo "Removing unnecessary js files from the build directory"
# find $BUILDDIR/js -type f \( -iname "game.js" -or -iname "home.js" -or -iname "log.js" -or -iname "require-jquery.js" -or -iname "modernizr.js" -or -iname "css3-mediaqueries.js" -or -iname "mapworker.js" -or -iname "detect.js" -or -iname "underscore.min.js" -or -iname "text.js" \) -delete

echo "Removing sprites directory"
rm -rf "$BUILD_DIR"/sprites

echo "Removing config directory"
rm -rf "$BUILD_DIR"/config

echo "Moving build.txt to current dir"
mv "$BUILD_DIR"/build.txt .

echo "Build complete"

$LOCAL || chown nginx:nginx -R "$BUILD_DIR"

