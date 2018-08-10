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
		<p:pipe step="package-documents" port="result"/>
		<!-- other files are loaded lazily -->
	</p:output>
	
	<p:option name="epub" required="true" px:media-type="application/epub+zip"/>
	
	<p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/library.xpl"/>
	
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
	
	<px:fileset-join name="fileset-from-zip"/>
	<p:sink/>
	
	<p:for-each name="package-documents">
		<p:iteration-source select="//ocf:rootfile">
			<p:pipe step="container" port="result"/>
		</p:iteration-source>
		<p:output port="fileset" primary="true"/>
		<p:output port="result">
			<p:pipe step="package-document" port="result"/>
		</p:output>
		<p:variable name="full-path" select="/*/@full-path"/>
		<px:fileset-load name="package-document">
			<p:input port="fileset">
				<p:pipe step="fileset-from-zip" port="result"/>
			</p:input>
			<p:input port="in-memory">
				<p:empty/>
			</p:input>
			<p:with-option name="href" select="resolve-uri($full-path,base-uri(/*))">
				<p:pipe step="main" port="target-base"/>
			</p:with-option>
		</px:fileset-load>
		<px:opf-manifest-to-fileset/>
	</p:for-each>
	
	<px:fileset-join name="filesets-from-package-documents"/>
	<p:sink/>
	
	<px:fileset-join>
		<p:input port="source">
			<p:pipe step="fileset-from-zip" port="result"/>
			<p:pipe step="filesets-from-package-documents" port="result"/>
		</p:input>
	</px:fileset-join>
	
</p:declare-step>
