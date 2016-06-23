<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline type="px:liblouis-block-translate" version="1.0"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
            xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
            exclude-inline-prefixes="#all">
	
	<p:option name="query" select="''"/>
	
	<p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
	
	<px:message message="[progress px:liblouis-block-translate 50 css:parse-properties] Parsing CSS properties"/>
	<css:parse-properties properties="display"/>
	
	<px:message message="[progress px:liblouis-block-translate 50 liblouis-block-translate.xsl] Translating blocks"/>
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="liblouis-block-translate.xsl"/>
		</p:input>
		<p:with-param name="query" select="$query"/>
	</p:xslt>
	
</p:pipeline>
