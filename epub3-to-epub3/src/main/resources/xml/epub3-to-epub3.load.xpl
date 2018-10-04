<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-epub3.load" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                exclude-inline-prefixes="#all"
                name="main">
	
	<!--
	    Create fileset from zipped or unzipped EPUB
	-->
	
	<p:output port="fileset" primary="true"/>
	<p:output port="in-memory" sequence="true">
		<!--
		    other files are loaded lazily
		-->
		<p:pipe step="package-documents" port="result"/>
	</p:output>
	
	<p:option name="epub" required="true" px:media-type="application/epub+zip"/>
	
	<p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/library.xpl"/>
	
	<px:fileset-create name="epub-base">
		<p:with-option name="base" select="if (ends-with(lower-case($epub),'.epub'))
	                                       then concat($epub,'!/')
	                                       else resolve-uri('./',$epub)"/>
	</px:fileset-create>
	<p:sink/>
	
	<p:choose name="container">
		<p:when test="ends-with(lower-case($epub),'.epub')">
			<p:output port="result"/>
			<px:unzip file="META-INF/container.xml" content-type="application/xml">
				<p:with-option name="href" select="$epub"/>
			</px:unzip>
		</p:when>
		<p:when test="ends-with($epub,'/mimetype')">
			<p:output port="result"/>
			<p:load>
				<p:with-option name="href" select="resolve-uri('META-INF/container.xml',$epub)"/>
			</p:load>
		</p:when>
		<p:otherwise>
			<p:output port="result"/>
			<px:error code="XXXXX" message="Input must either be a .epub file or a file named 'mimetype', but got '$1'.">
				<p:with-option name="param1" select="$epub"/>
			</px:error>
		</p:otherwise>
	</p:choose>
	
	<p:choose>
		<p:when test="ends-with(lower-case($epub),'.epub')">
			<p:output port="result">
				<p:pipe step="unzip" port="fileset"/>
			</p:output>
			<px:fileset-unzip name="unzip">
				<p:with-option name="href" select="$epub"/>
			</px:fileset-unzip>
			<p:sink/>
		</p:when>
		<p:otherwise>
			<p:output port="result"/>
			<px:fileset-from-dir>
				<p:with-option name="path" select="resolve-uri('./',$epub)"/>
			</px:fileset-from-dir>
		</p:otherwise>
	</p:choose>
	
	<p:for-each>
		<p:iteration-source select="//d:file"/>
		<p:variable name="href" select="/*/@href"/>
		<p:identity>
			<p:input port="source">
				<p:pipe step="epub-base" port="result"/>
			</p:input>
		</p:identity>
		<p:choose>
			<p:xpath-context>
				<p:pipe step="container" port="result"/>
			</p:xpath-context>
			<p:when test="$href='META-INF/container.xml'">
				<px:fileset-add-entry media-type="application/xml">
					<p:with-option name="href" select="$href"/>
				</px:fileset-add-entry>
			</p:when>
			<p:when test="//ocf:rootfile[@full-path=$href]">
				<px:fileset-add-entry media-type="application/oebps-package+xml">
					<p:with-option name="href" select="$href"/>
				</px:fileset-add-entry>
			</p:when>
			<p:otherwise>
				<px:fileset-add-entry>
					<p:with-option name="href" select="$href"/>
				</px:fileset-add-entry>
			</p:otherwise>
		</p:choose>
	</p:for-each>
	
	<px:fileset-join name="fileset-from-zip-or-dir"/>
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
				<p:pipe step="fileset-from-zip-or-dir" port="result"/>
			</p:input>
			<p:input port="in-memory">
				<p:empty/>
			</p:input>
			<p:with-option name="href" select="resolve-uri($full-path,base-uri(/*))">
				<p:pipe step="epub-base" port="result"/>
			</p:with-option>
		</px:fileset-load>
		<px:opf-manifest-to-fileset/>
	</p:for-each>
	
	<px:fileset-join name="filesets-from-package-documents"/>
	<p:sink/>
	
	<px:fileset-join>
		<p:input port="source">
			<p:pipe step="fileset-from-zip-or-dir" port="result"/>
			<p:pipe step="filesets-from-package-documents" port="result"/>
		</p:input>
	</px:fileset-join>
	
</p:declare-step>
