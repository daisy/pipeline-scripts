<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:hyphen="http://hunspell.sourceforge.net/Hyphen"
	xmlns:my="http://github.com/bertfrees"
	exclude-result-prefixes="#all">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/libhyphen-utils/xslt/library.xsl"/>

	<xsl:param name="fail-on-missing-table" select="'true'"/>
	
	<xsl:template match="/*">
		<xsl:if test="not(@xml:lang)">
			<xsl:message terminate="yes">
				<xsl:text>This document has no xml:lang attribute</xsl:text>
			</xsl:message>
		</xsl:if>
		<xsl:variable name="table" select="hyphen:lookup-table(@xml:lang)"/>
		<xsl:if test="$fail-on-missing-table='true' and not($table)">
			<xsl:message terminate="yes">
				<xsl:value-of select="concat(
					'No hyphenation table found that matches xml:lang=&quot;', @xml:lang, '&quot;')"/>
			</xsl:message>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="table" select="$table"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:param name="table"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="table" select="if (@xml:lang) then hyphen:lookup-table(@xml:lang) else $table"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:param name="table"/>
		<xsl:sequence select="if ($table) then hyphen:hyphenate($table, string(.)) else ."/>
	</xsl:template>
	
	<xsl:template match="@*">
		<xsl:sequence select="."/>
	</xsl:template>

</xsl:stylesheet>
