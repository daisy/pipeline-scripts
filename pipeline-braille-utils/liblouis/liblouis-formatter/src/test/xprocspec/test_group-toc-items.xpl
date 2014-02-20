<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:test-group-toc-items"
		xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
		xmlns:p="http://www.w3.org/ns/xproc"
		exclude-inline-prefixes="#all"
		version="1.0">
	
	<p:input port="source" sequence="true"/>
	<p:output port="result" sequence="true"/>
	
	<p:import href="../../main/resources/xml/utils/xslt-for-each.xpl"/>
	
	<pxi:xslt-for-each>
		<p:input port="stylesheet">
			<p:document href="../../main/resources/xml/group-toc-items.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</pxi:xslt-for-each>
	
</p:declare-step>
