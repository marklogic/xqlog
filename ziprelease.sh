#!/bin/sh

version=1.0
zipfile=../releases/xqlog-$version.zip
exclude="$zipfile ziprelease.sh *.svn*"

zip -r $zipfile * -x $exclude
