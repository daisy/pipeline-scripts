<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:dotify-transform" version="1.0" name="main"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:dotify="http://code.google.com/p/dotify/"
                exclude-inline-prefixes="#all">
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:input port="parameters" kind="parameter" primary="false"/>
	
	<p:option name="css-block-transform" required="true"/>
	<p:option name="text-transform" required="true"/>
	<p:option name="temp-dir" required="true"/>
	
	<p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
	<p:import href="../format.xpl"/>
	
	<!-- for debug info -->
	<p:for-each><p:identity/></p:for-each>
	
	<px:transform>
		<p:with-option name="query" select="$css-block-transform"/>
		<p:with-option name="temp-dir" select="$temp-dir"/>
		<p:input port="parameters">
			<p:pipe step="main" port="parameters"/>
		</p:input>
	</px:transform>
	
	<!-- for debug info -->
	<p:for-each><p:identity/></p:for-each>
	
	<dotify:format>
		<p:with-option name="text-transform" select="$text-transform"/>
		<p:with-option name="duplex" select="(//c:param[@name='duplex' and not(@namespace[not(.='')])]/@value,'true')[.=('true','false')][1]">
			<p:pipe step="main" port="parameters"/>
		</p:with-option>
	</dotify:format>
	
</p:declare-step>
