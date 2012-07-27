<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:louis="http://liblouis.org/liblouis"
	exclude-result-prefixes="xs louis">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />

	<xsl:variable name="table" select="louis:find-table(string(/*/@xml:lang))"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$table">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:when test="not(/*/@xml:lang)">
				<xsl:message terminate="yes">
					<xsl:text>This document has no xml:lang attribute</xsl:text>
				</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:value-of select="concat(
						'No liblouis table found that matches xml:lang=&quot;', string(/*/@xml:lang), '&quot;')"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="text()" priority="1">
		<xsl:value-of select="louis:translate($table, .)"/>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
