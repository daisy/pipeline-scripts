<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:louis="http://liblouis.org/liblouis"
	exclude-result-prefixes="xs louis">
	
	<xsl:param name="hyphenate" select="'false'"/>
	
	<xsl:template match="/*">
		<xsl:choose>
			<xsl:when test="/*/@xml:lang">
				<xsl:variable name="table" select="louis:find-table(string(/*/@xml:lang))"/>
				<xsl:choose>
					<xsl:when test="$table">
						<xsl:copy>
							<xsl:sequence select="louis:translate($table, string(/*), (), $hyphenate='true')"/>
						</xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">
							<xsl:value-of select="concat(
								'No liblouis table found that matches xml:lang=&quot;', string(/*/@xml:lang), '&quot;')"/>
						</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>This document has no xml:lang attribute</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
