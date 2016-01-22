<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:generate-toc"
                name="main"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                exclude-inline-prefixes="#all"
                version="1.0">
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:option name="depth" required="true"/>
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="../xslt/generate-toc.xsl"/>
		</p:input>
		<p:with-param name="_depth" select="$depth"/>
	</p:xslt>
	
</p:declare-step>
