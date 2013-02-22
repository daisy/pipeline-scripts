<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	exclude-result-prefixes="xs css">
	
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl" />
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[contains(@style, 'string-set')]">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:attribute name="style" select="css:remove-from-style(string(@style), ('string-set'))"/>
			<xsl:variable name="element" as="element()" select="."/>
			<xsl:variable name="string-set" as="xs:string?"
				select="css:get-property-value(., 'string-set', true(), true(), false())"/>
			<xsl:if test="$string-set and $string-set!='none'">
				<xsl:for-each select="tokenize($string-set,',')">
					<xsl:variable name="identifier" select="replace(., '^\s*(\S+)\s.*$', '$1')"/>
					<xsl:variable name="content-list" select="substring-after(., $identifier)"/>
					<xsl:variable name="content" select="css:evaluate-content-list($element, $content-list)"/>
					<xsl:if test="$content[1] and matches($identifier, $IDENT)">
						<xsl:element name="css:string-set">
							<xsl:attribute name="name" select="$identifier"/>
							<xsl:sequence select="$content"/>
						</xsl:element>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
