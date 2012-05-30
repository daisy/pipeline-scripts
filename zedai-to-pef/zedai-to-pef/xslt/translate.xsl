<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:louis="http://liblouis.org/liblouis"
	exclude-result-prefixes="xs louis">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />

	<xsl:param name="liblouis_tables" as="xs:string" select="'unicode.dis,en-us-g2.ctb'"/>

	<xsl:template match="text()" priority="1">
		<xsl:value-of select="louis:translate($liblouis_tables, .)"/>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
