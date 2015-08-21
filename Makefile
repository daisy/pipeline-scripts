.PHONY: release-notes
release-notes :
	test -z "$$(git status --porcelain $@)"
	xsltproc generate-release-notes.xsl bom/pom.xml | cat - NEWS > NEWS.tmp
	mv NEWS.tmp NEWS
