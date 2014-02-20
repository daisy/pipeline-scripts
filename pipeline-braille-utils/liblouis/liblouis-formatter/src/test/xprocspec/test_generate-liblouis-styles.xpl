<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:test-generate-liblouis-styles"
		xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
		xmlns:p="http://www.w3.org/ns/xproc"
		exclude-inline-prefixes="#all"
		version="1.0">
	
	<p:input port="source" sequence="true"/>
	<p:output port="result" primary="true"/>
	<p:output port="secondary" sequence="true">
		<p:pipe step="xslt" port="secondary"/>
	</p:output>
	
	<p:xslt name="xslt">
		<p:input port="stylesheet">
			<p:document href="../../main/resources/xml/generate-liblouis-styles.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
</p:declare-step>
