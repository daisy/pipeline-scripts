#!/bin/bash
SCRIPTPATH=`dirname $0 | xargs readlink -f`
$HOME/utf-x-framework-svn-trunk/utfx.sh -Dutfx.test.dir=$SCRIPTPATH/
