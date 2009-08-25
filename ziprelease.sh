#!/bin/sh

version=1.1
zipfile=../releases/xqlog-$version.zip
exclude="$zipfile ziprelease.sh *.svn*"

zip -r $zipfile * -x $exclude
