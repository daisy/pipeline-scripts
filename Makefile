POMS := $(shell find * -name 'pom.xml')

.PHONY: all
all : .modules
	@if [ -s $< ]; then \
		mvn --projects $$(cat $< |paste -sd ',' -) clean install -DskipTests; \
	fi

.PHONY: check
check : .modules
	@if [ -s $< ]; then \
		@mvn --projects $$(cat $< |paste -sd ',' -) --also-make-dependents clean install; \
	fi

.PHONY: release
release : .modules
	@mvn --projects $$(cat $< |paste -sd ',' -) clean release:clean release:prepare && mvn release:perform	

.modules : maven/bom/pom.xml $(POMS)
	@for pom in $(POMS); do \
		v=$$(xmllint --xpath "/*/*[local-name()='version']/text()" $$pom) && \
		if [[ "$$v" =~ -SNAPSHOT$$ ]]; then \
			g=$$(xmllint --xpath "/*/*[local-name()='groupId']/text()" $$pom 2>/dev/null) || \
			g=$$(xmllint --xpath "/*/*[local-name()='parent']/*[local-name()='groupId']/text()" $$pom) && \
			a=$$(xmllint --xpath "/*/*[local-name()='artifactId']/text()" $$pom) && \
			if xmllint --xpath "//*[local-name()='dependency'][ \
			                         *[local-name()='groupId']='$$g' and \
			                         *[local-name()='artifactId']='$$a' and \
			                         *[local-name()='version']='$$v']" $< >/dev/null 2>/dev/null; then \
				dirname $$pom; \
			fi \
		fi \
	done > $@

.PHONY: release-notes
release-notes :
	test -z "$$(git status --porcelain $@)"
	xsltproc make/generate-release-notes.xsl maven/bom/pom.xml | cat - NEWS.md > NEWS.md.tmp
	mv NEWS.md.tmp NEWS.md
