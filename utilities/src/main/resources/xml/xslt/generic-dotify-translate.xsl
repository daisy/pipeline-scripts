<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:dotify="http://code.google.com/p/dotify/"
	exclude-result-prefixes="xs dotify">
	
	<xsl:output method="xml" encoding="utf-8"/>

	<xsl:template match="/*">
		<xsl:choose>
			<xsl:when test="/*/@xml:lang">
				<xsl:copy>
					<xsl:sequence select="dotify:translate(string(/*/@xml:lang), string(/*))"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>This document has no xml:lang attribute</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
