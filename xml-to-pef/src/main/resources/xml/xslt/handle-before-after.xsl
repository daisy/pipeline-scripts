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
	
	<xsl:template match="*[@css:before or @css:after]">
		<xsl:if test="@css:before">
			<xsl:variable name="regex" select="concat('^(.*;)?\s*content\s*:\s*(', $STRING, ')\s*(;.*)?$')"/>
			<xsl:variable name="string" as="xs:string*">
				<xsl:analyze-string select="string(@css:before)" regex="{$regex}">
					<xsl:matching-substring>
						<xsl:sequence select="substring(regex-group(2), 2, string-length(regex-group(2))-2)"/>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:variable>
			<xsl:if test="$string[1]">
				<xsl:element name="css:inline">
					<xsl:sequence select="$string[1]"/>
				</xsl:element>
			</xsl:if>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
		<xsl:if test="@css:after">
			<xsl:variable name="regex" select="concat('^(.*;)?\s*content\s*:\s*(', $STRING, ')\s*(;.*)?$')"/>
			<xsl:variable name="string" as="xs:string*">
				<xsl:analyze-string select="string(@css:after)" regex="{$regex}">
					<xsl:matching-substring>
						<xsl:sequence select="substring(regex-group(2), 2, string-length(regex-group(2))-2)"/>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:variable>
			<xsl:if test="$string[1]">
				<xsl:element name="css:inline">
					<xsl:sequence select="$string[1]"/>
				</xsl:element>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="@css:before|@css:after">
	</xsl:template>

</xsl:stylesheet>
