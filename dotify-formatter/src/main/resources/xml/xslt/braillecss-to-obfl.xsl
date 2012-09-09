<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.daisy.org/ns/2011/obfl"
	xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	xmlns:my="http://github.com/bertfrees"
	exclude-result-prefixes="xs css obfl my">

	<!-- Convert a document with inline Braille CSS to OBFL (Open Braille Formatting Language)-->

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
	
	<xsl:template match="/">
		<xsl:element name="root">
			<xsl:attribute name="version" select="'2011-1'"/>
			<xsl:attribute name="xml:lang" select="/*/@xml:lang"/>
			<xsl:element name="layout-master">
				<xsl:attribute name="name" select="'main'"/>
				<xsl:attribute name="page-width" select="'40'"/>
				<xsl:attribute name="page-height" select="'25'"/>
				<xsl:attribute name="inner-margin" select="'0'"/>
				<xsl:attribute name="outer-margin" select="'0'"/>
				<xsl:attribute name="row-spacing" select="'1'"/>
				<xsl:attribute name="duplex" select="'true'"/>
				<xsl:element name="default-template">
					<xsl:element name="header"/>
					<xsl:element name="footer">
						<xsl:element name="field">
							<xsl:element name="current-page">
								<xsl:attribute name="style" select="'default'"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="sequence">
				<xsl:attribute name="master" select="'main'"/>
				<xsl:attribute name="initial-page-number" select="'1'"/>
				<xsl:apply-templates select="/*"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*">
		<xsl:if test="my:display(.) != 'none'">
			<xsl:variable name="content">
				<xsl:for-each-group select="*|text()" group-adjacent="not(descendant-or-self::*[my:display(.) != 'inline'])">
					<xsl:choose>
						<xsl:when test="current-grouping-key()">
							<xsl:sequence select="normalize-space(string-join(current-group()/string(.),''))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="current-group()">
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each-group>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="my:display(.) != 'inline'">
					<xsl:variable name="margin-bottom" select="number(css:get-property-value(., 'margin-bottom', true(), true(), false()))"/>
					<xsl:variable name="margin-left" select="number(css:get-property-value(., 'margin-left', true(), true(), false()))"/>
					<xsl:variable name="margin-right" select="number(css:get-property-value(., 'margin-right', true(), true(), false()))"/>
					<xsl:variable name="margin-top" select="number(css:get-property-value(., 'margin-top', true(), true(), false()))"/>
					<xsl:variable name="padding-bottom" select="number(css:get-property-value(., 'padding-bottom', true(), true(), false()))"/>
					<xsl:variable name="padding-left" select="number(css:get-property-value(., 'padding-left', true(), true(), false()))"/>
					<xsl:variable name="padding-right" select="number(css:get-property-value(., 'padding-right', true(), true(), false()))"/>
					<xsl:variable name="padding-top" select="number(css:get-property-value(., 'padding-top', true(), true(), false()))"/>
					<xsl:variable name="text-indent" select="number(css:get-property-value(., 'text-indent', true(), true(), false()))"/>
					<xsl:variable name="text-align" select="css:get-property-value(., 'text-align', true(), true(), false())"/>
					<xsl:variable name="page-break-after" select="css:get-property-value(., 'page-break-after', true(), true(), false())"/>
					<xsl:variable name="page-break-before" select="css:get-property-value(., 'page-break-before', true(), true(), false())"/>
					<xsl:variable name="page-break-inside" select="css:get-property-value(., 'page-break-inside', true(), true(), false())"/>
					<xsl:element name="block">
						<xsl:if test="$margin-bottom + $padding-bottom &gt; 0">
							<xsl:attribute name="margin-bottom" select="format-number($margin-bottom + $padding-bottom, '0')"/>
						</xsl:if>
						<xsl:if test="$margin-left + $padding-left &gt; 0">
							<xsl:attribute name="margin-left" select="format-number($margin-left + $padding-left, '0')"/>
						</xsl:if>
						<xsl:if test="$margin-right + $padding-right &gt; 0">
							<xsl:attribute name="margin-right" select="format-number($margin-right + $padding-right, '0')"/>
						</xsl:if>
						<xsl:if test="$margin-top + $padding-top &gt; 0">
							<xsl:attribute name="margin-top" select="format-number($margin-top + $padding-top, '0')"/>
						</xsl:if>
						<xsl:if test="$text-indent &gt; 0">
							<xsl:attribute name="first-line-indent" select="format-number($text-indent, '0')"/>
						</xsl:if>
						<xsl:if test="$page-break-after = 'avoid'">
							<xsl:attribute name="keep-with-next" select="'1'"/>
						</xsl:if>
						<xsl:if test="$page-break-before = 'always'">
							<xsl:attribute name="break-before" select="'page'"/>
						</xsl:if>
						<xsl:if test="$page-break-inside = 'avoid'">
							<xsl:attribute name="keep" select="'all'"/>
						</xsl:if>
						<xsl:sequence select="$content"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$content"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:function name="my:display" as="xs:string">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="css:get-property-value($element, 'display', true(), true(), false())"/>
	</xsl:function>
	
</xsl:stylesheet>
