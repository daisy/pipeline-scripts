<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="2.0">
	
	<xsl:variable name="braille-rendition.package-document" select="collection()[1]"/>
	<xsl:variable name="braille-rendition.html" select="collection()[position() &gt; 1]"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="opf:metadata/dc:language"/>
	
	<xsl:template match="opf:metadata">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:for-each select="distinct-values($braille-rendition.html//@xml:lang)">
				<dc:language>
					<xsl:value-of select="."/>
				</dc:language>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
