<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tex="http://code.google.com/p/texhyphj/"
	xmlns:my="http://github.com/bertfrees"
	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="utf-8"/>
	
	<xsl:template match="/">
		<xsl:if test="not(/*/@xml:lang)">
			<xsl:message terminate="yes">
				<xsl:text>This document has no xml:lang attribute</xsl:text>
			</xsl:message>
		</xsl:if>
		<xsl:apply-templates select="/*"/>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:param name="table"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="table" select="if (@xml:lang) then my:get-table(@xml:lang) else $table"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:param name="table"/>
		<xsl:sequence select="tex:hyphenate($table, string(.))"/>
	</xsl:template>
	
	<xsl:template match="@*">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:function name="my:get-table">
		<xsl:param name="lang"/>
		<xsl:variable name="table" select="tex:lookup-table($lang)"/>
		<xsl:if test="not($table)">
			<xsl:message terminate="yes">
				<xsl:value-of select="concat(
					'No hyphenation table found that matches xml:lang=&quot;', $lang, '&quot;')"/>
			</xsl:message>
		</xsl:if>
		<xsl:sequence select="$table"/>
	</xsl:function>

</xsl:stylesheet>
