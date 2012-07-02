<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
	xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
	xmlns:my="http://github.com/bertfrees"
	exclude-result-prefixes="xs z my">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/style-functions.xsl" />
	
	<xsl:template match="/*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="element()">
		<xsl:choose>
			<xsl:when test="contains(string(@brl:style), 'display')">
				<xsl:variable name="display" as="xs:string" select="brl:get-property-or-default(string(@brl:style), 'display')"/>
				<xsl:choose>
					<xsl:when test="$display != 'inline'">
						<xsl:copy>
							<xsl:apply-templates select="@*|node()"/>
						</xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@*|text()|comment()|processing-instruction()">
		<xsl:copy/>
	</xsl:template>

</xsl:stylesheet>
