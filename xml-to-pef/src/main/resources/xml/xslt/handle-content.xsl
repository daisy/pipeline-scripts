<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	exclude-result-prefixes="xs css">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="css:before|css:after">
		<xsl:variable name="regex" select="concat('^(.*;)?\s*content\s*:\s*(', $STRING, ')\s*(;.*)?$')"/>
		<xsl:variable name="string" as="xs:string*">
			<xsl:analyze-string select="string(@style)" regex="{$regex}">
				<xsl:matching-substring>
					<xsl:sequence select="substring(regex-group(2), 2, string-length(regex-group(2))-2)"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:choose>
				<xsl:when test="exists($string)">
					<xsl:sequence select="$string"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
