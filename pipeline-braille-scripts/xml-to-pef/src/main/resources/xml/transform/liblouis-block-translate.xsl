<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:louis="http://liblouis.org/liblouis"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all">
	
	<xsl:import href="block-translator-template.xsl"/>
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-utils/library.xsl"/>
	
	<xsl:template match="css:block" mode="#all">
		<xsl:variable name="text" as="text()*" select="//text()"/>
		<xsl:variable name="style" as="xs:string*">
			<xsl:for-each select="$text">
				<xsl:variable name="inline-style" as="element()*"
				              select="css:specified-properties($inline-properties, true(), false(), true(), parent::*)"/>
				<xsl:sequence select="css:serialize-declaration-list($inline-style[not(@value='initial')])"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:apply-templates select="node()[1]" mode="treewalk">
			<xsl:with-param name="new-text-nodes" select="louis:translate(concat('(locale:',string(@xml:lang),')'), $text, $style)"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="css:property[@name=('text-transform','font-style','font-weight','text-decoration','color')]"
	              mode="translate-declaration-list"/>
	
	<xsl:template match="css:property[@name='hyphens' and @value='auto']" mode="translate-declaration-list">
		<xsl:sequence select="css:property('hyphens','manual')"/>
	</xsl:template>
	
</xsl:stylesheet>
