<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:louis="http://liblouis.org/liblouis"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	exclude-result-prefixes="#all">
	
	<xsl:import href="block-translator-template.xsl"/>
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-utils/library.xsl"/>
	
	<xsl:param name="prehyphenated" select="'false'"/>
	
	<xsl:template match="css:block" mode="#all">
		<xsl:variable name="table" select="louis:lookup-table(string(@xml:lang))"/>
		<xsl:if test="not($table)">
			<xsl:message terminate="yes">
				<xsl:value-of select="concat(
					'No liblouis table found that matches xml:lang=&quot;', string(@xml:lang), '&quot;')"/>
			</xsl:message>
		</xsl:if>
		<xsl:sequence select="louis:translate($table, string(/*), $prehyphenated='true', louis:get-typeform(/*))"/>
	</xsl:template>

</xsl:stylesheet>
