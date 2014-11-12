<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline type="px:dotify-block-translate" version="1.0"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
            exclude-inline-prefixes="#all">
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="dotify-block-translate.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
</p:pipeline>
