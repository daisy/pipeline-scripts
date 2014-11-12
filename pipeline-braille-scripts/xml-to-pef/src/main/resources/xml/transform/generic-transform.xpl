<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:generic-transform" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns:louis="http://liblouis.org/liblouis"
                xmlns:dotify="http://code.google.com/p/dotify/"
                exclude-inline-prefixes="#all">
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:option name="formatter" select="'liblouis'"/> <!-- liblouis|dotify -->
	<p:option name="query" select="''"/>
	<p:option name="temp-dir" required="true"/>
	
	<p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/braille/dotify-utils/library.xpl"/>
	
	<p:variable name="lang" select="(/*/@xml:lang,'und')[1]"/>
	
	<p:viewport match="math:math">
		<px:transform type="mathml">
			<p:with-option name="query" select="concat('(locale:',$lang,')',$query)"/>
			<p:with-option name="temp-dir" select="$temp-dir"/>
		</px:transform>
	</p:viewport>
	
	<p:choose>
		<p:when test="$formatter='dotify'">
			<px:transform type="css-block">
				<p:with-option name="query" select="concat('(locale:',$lang,')',$query)"/>
				<p:with-option name="temp-dir" select="$temp-dir"/>
			</px:transform>
			<dotify:format/>
		</p:when>
		<p:otherwise>
			<p:xslt>
				<p:input port="stylesheet">
					<p:document href="handle-list-item.xsl"/>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>
			<px:transform type="css-block">
				<p:with-option name="query" select="concat('(locale:',$lang,')',$query)"/>
				<p:with-option name="temp-dir" select="$temp-dir"/>
			</px:transform>
			<louis:format>
				<p:with-option name="temp-dir" select="$temp-dir"/>
			</louis:format>
		</p:otherwise>
	</p:choose>
	
</p:declare-step>
