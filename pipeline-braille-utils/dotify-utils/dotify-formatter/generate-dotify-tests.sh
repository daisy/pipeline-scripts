#!/bin/bash

CURDIR=$( cd $( dirname "$0" ) && pwd )
SAXON=${HOME}/.m2/repository/net/sf/saxon/Saxon-HE/9.5.1-5/Saxon-HE-9.5.1-5.jar

for f in $CURDIR/src/test/xprocspec/test_{format,obfl-to-pef}.xprocspec; do
    output_dir=$CURDIR/target/dotify-tests/$(basename $f)
    mkdir -p $output_dir
    java -jar "$SAXON" \
         -s:$f \
         -o:$output_dir/dummy \
         -xsl:$CURDIR/generate-dotify-tests.xsl \
        || exit
done
