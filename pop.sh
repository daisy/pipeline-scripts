#!/bin/sh

basedir=`pwd`

# Cleanup

# find . -type d -name bin -depth 2 -exec rm -R {} \;
# find . -type d -name target -depth 2 -exec rm -R {} \;
# find . -type f -name .DS_Store -delete
# hg rm catalog.xml
# hg rm expath-to-catalogs.sh
# hg rm expath-to-catalogs.xpl
# hg rm daisy-pipeline-modules-parent
# hg rm daisy.pipeline.modules.feature
# hg rm daisy.pipeline.modules.site
# hg rm modules-target-platform
# for file in `find . -type d -not -path "./.hg*"`; do
# 	if [ -d "$file/META-INF" ]; then
# 		cd "$file"
# 		hg rm -f build.properties
# 		hg rm -f .project
# 		hg rm -f .classpath
# 		rm -R .settings >& /dev/null
# 		cd "$basedir"
# 	fi
# done

for file in `find . -type d`; do
	if [ -f "$file/MANIFEST.txt" ]; then
	# if [ -d "$file/META-INF" ]; then
		cd "$file"
		PROJECT_ID=`basename $file` 
		# PROJECT_NAME=`sed -nE 's/Bundle-Name: *(.*) *$/\1/p' META-INF/MANIFEST.MF` 
		PROJECT_NAME=`sed -nE 's/Bundle-Name: *(.*) *$/\1/p' MANIFEST.txt` 
		# echo "Processing "$PROJECT_ID" ..."
		# 
		# mkdir -p src/main/resources/META-INF
		# mkdir -p src/test/resources
		# 
		# hg mv "$PROJECT_ID" src/main/resources/xml
		# sed -i "" "s/\.\.\/${PROJECT_ID}/..\/xml/g" META-INF/catalog.xml
		# hg mv META-INF/catalog.xml src/main/resources/META-INF/catalog.xml
		# mv META-INF/MANIFEST.MF MANIFEST.txt
		# hg rm META-INF/MANIFEST.MF
		# hg rm .settings
		# rm -R META-INF >& /dev/null
		# hg rm OSGI-INF
		# 
		# hg mv tests/* src/test/resources/ >& /dev/null
		# rm -R tests >& /dev/null
		cat > pom.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.daisy.pipeline.modules</groupId>
    <artifactId>modules-parent</artifactId>
    <version>1.0-SNAPSHOT</version>
    <relativePath>../parent</relativePath>
  </parent>

  <artifactId>$PROJECT_ID</artifactId>
  <version>1.0.0-SNAPSHOT</version>
  <packaging>bundle</packaging>

  <name>DAISY Pipeline 2 module :: $PROJECT_NAME</name>

</project>
EOF
	cd "$basedir"
	fi
done