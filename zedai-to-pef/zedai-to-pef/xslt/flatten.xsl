<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
	xmlns:my="http://github.com/bertfrees"
	exclude-result-prefixes="xs z my">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="my:flatten(.)">
					<xsl:apply-templates select="@*|element()|text()" mode="flatten"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="element()" mode="flatten">
		<xsl:apply-templates mode="flatten"/>
	</xsl:template>
	
	<xsl:template match="text()|@*" mode="flatten">
		<xsl:copy/>
	</xsl:template>
	
	<xsl:function name="my:flatten" as="xs:boolean">
		<xsl:param name="element" as="element()"/>
		<xsl:choose>
			<xsl:when test="$element/self::z:h">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="$element/self::z:p">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
