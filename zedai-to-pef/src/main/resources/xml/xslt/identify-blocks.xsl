<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	xmlns:my="http://github.com/bertfrees"
	exclude-result-prefixes="xs css my">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille-css/xslt/parsing-helper.xsl" />
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:choose>
				<xsl:when test="my:is-block(.)">
					<xsl:for-each-group select="*|text()"
						group-adjacent="boolean(self::*[my:is-block(.)])">
						<xsl:choose>
							<xsl:when test="current-grouping-key()">
								<xsl:for-each select="current-group()">
									<xsl:apply-templates select="."/>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="normalize-space(string-join(current-group()/string(.), ''))=''">
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="css:block">
									<xsl:attribute name="xml:lang" select="ancestor::*[@xml:lang][1]/@xml:lang"/>
									<xsl:for-each select="current-group()">
										<xsl:sequence select="."/>
									</xsl:for-each>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each-group>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|text()">
		<xsl:copy/>
	</xsl:template>
	
	<xsl:function name="my:is-block" as="xs:boolean">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="boolean($element/descendant-or-self::*[
			css:get-property-value(., 'display', true(), true(), false())!='inline'])"/>
	</xsl:function>

</xsl:stylesheet>
