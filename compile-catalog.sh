#!/bin/sh

PWD=`pwd`
MODULE_DIR=`dirname $0`

cd $MODULE_DIR
echo "<?xml version=\"1.0\"?>" > catalog.xml
echo "<!DOCTYPE catalog PUBLIC \"-//OASIS//DTD Entity Resolution XML Catalog V1.0//EN\" \"http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd\">" >> catalog.xml
echo "<catalog xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">" >> catalog.xml
find . -name catalog.xml -exec echo "    <nextCatalog catalog=\"{}\"/>" \; | grep META-INF | grep "src/main" >> catalog.xml
echo "</catalog>" >> catalog.xml
cd $PWD
