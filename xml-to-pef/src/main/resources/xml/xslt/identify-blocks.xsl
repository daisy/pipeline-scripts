<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	xmlns:my="http://github.com/bertfrees"
	exclude-result-prefixes="xs css my">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:choose>
				<xsl:when test="css:get-property-value(., 'display', true(), true(), false())='none'">
					<xsl:apply-templates select="node()" mode="no-display"/>
				</xsl:when>
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
									<xsl:call-template name="style-attribute"/>
									<xsl:for-each select="current-group()">
										<xsl:sequence select="."/>
									</xsl:for-each>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each-group>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name="style-attribute">
		<xsl:variable name="element" select="if (self::*) then . else parent::*" as="element()"/>
		<xsl:variable name="style" as="xs:string"
			select="string-join(
				(for $name in $properties[not(.='display')][css:applies-to(., 'inline')] return
					(for $value in css:get-property-value($element, $name, true(), false(), false()) return
						concat($name, ':', $value))
				), ';')"/>
		<xsl:if test="$style!=''">
			<xsl:attribute name="style" select="$style"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="no-display">
		<xsl:copy>
			<xsl:apply-templates select="@*|*" mode="no-display"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="css:string-set" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:element name="css:block">
				<xsl:attribute name="xml:lang" select="ancestor::*[@xml:lang][1]/@xml:lang"/>
				<xsl:sequence select="node()"/>
			</xsl:element>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|text()" mode="#all">
		<xsl:copy/>
	</xsl:template>
	
	<xsl:function name="my:is-block" as="xs:boolean">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="boolean($element/descendant-or-self::*[
			self::css:string-set or
			not(matches(css:get-property-value(., 'display', true(), true(), false()), 'inline'))])"/>
	</xsl:function>

</xsl:stylesheet>
