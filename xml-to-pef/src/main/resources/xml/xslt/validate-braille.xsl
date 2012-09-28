<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	
	<xsl:template match="/*">
		<xsl:variable name="BRAILLE_OR_WHITESPACE">[\s\p{IsBraillePatterns}]+</xsl:variable>
		<xsl:analyze-string select="string(.)" regex="{$BRAILLE_OR_WHITESPACE}">
			<xsl:non-matching-substring>
				<xsl:message terminate="yes">
					<xsl:text>The document can only contain whitespace and Unicode Braille. </xsl:text>
					<xsl:text>However the following text was found: '</xsl:text>
					<xsl:value-of select="substring(., 1, 20)"/>
					<xsl:text> ...'.</xsl:text>
				</xsl:message>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
</xsl:stylesheet>
