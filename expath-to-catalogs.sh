#!/bin/sh

PWD=`pwd`
MODULE_DIR=`dirname $0`

cd $MODULE_DIR
echo "<doc>" > doc.xml
find . -name expath-pkg.xml -exec echo "<file>{}</file>" >> doc.xml \;
echo "</doc>" >> doc.xml
calabash -i source=doc.xml expath-to-catalogs.xpl
rm doc.xml
cd $PWD