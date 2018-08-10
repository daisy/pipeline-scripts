<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-epub3.load" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                exclude-inline-prefixes="#all"
                name="main">
	
	<!--
	    Create fileset from ZIP contents but with new target location
	-->
	
	<p:input port="target-base">
		<!-- fileset -->
	</p:input>
	
	<p:output port="fileset" primary="true"/>
	<p:output port="in-memory" sequence="true">
		<p:empty/>
		<!-- files are loaded lazily -->
	</p:output>
	
	<p:option name="epub" required="true" px:media-type="application/epub+zip"/>
	
	<p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl"/>
	
	<px:unzip file="META-INF/container.xml" content-type="application/xml" name="container">
		<p:with-option name="href" select="$epub"/>
	</px:unzip>
	<p:sink/>
	
	<px:unzip>
		<p:with-option name="href" select="$epub"/>
	</px:unzip>
	
	<p:for-each>
		<p:iteration-source select="//c:file"/>
		<p:variable name="href" select="/*/@name"/>
		<p:variable name="original-href" select="resolve-uri($href,concat($epub,'!/'))"/>
		<p:identity>
			<p:input port="source">
				<p:pipe step="main" port="target-base"/>
			</p:input>
		</p:identity>
		<p:choose>
			<p:xpath-context>
				<p:pipe step="container" port="result"/>
			</p:xpath-context>
			<p:when test="$href='META-INF/container.xml'">
				<px:fileset-add-entry media-type="application/xml">
					<p:with-option name="href" select="$href"/>
					<p:with-option name="original-href" select="$original-href"/>
				</px:fileset-add-entry>
			</p:when>
			<p:when test="//ocf:rootfile[@full-path=$href]">
				<px:fileset-add-entry media-type="application/oebps-package+xml">
					<p:with-option name="href" select="$href"/>
					<p:with-option name="original-href" select="$original-href"/>
				</px:fileset-add-entry>
			</p:when>
			<p:otherwise>
				<px:fileset-add-entry>
					<p:with-option name="href" select="$href"/>
					<p:with-option name="original-href" select="$original-href"/>
				</px:fileset-add-entry>
			</p:otherwise>
		</p:choose>
	</p:for-each>
	
	<px:fileset-join/>
	
</p:declare-step>
