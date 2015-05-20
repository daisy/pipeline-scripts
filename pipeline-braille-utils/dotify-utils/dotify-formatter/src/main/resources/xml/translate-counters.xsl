<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xsl" />
	
	<xsl:param name="braille-translator-query" as="xs:string" select="''"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="css:box[@class='counter']">
		<xsl:variable name="text-transform" as="xs:string" select="(@css:text-transform,'auto')[1]"/>
		<xsl:choose>
			<xsl:when test="$text-transform='none'">
				<xsl:value-of select="string(.)"/>
			</xsl:when>
			<xsl:when test="$text-transform='auto'">
				<xsl:value-of select="pf:text-transform($braille-translator-query, string(.))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="pf:text-transform($braille-translator-query,
				                                        string(.),
				                                        concat('text-transform:',string(@css:text-transform)))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
