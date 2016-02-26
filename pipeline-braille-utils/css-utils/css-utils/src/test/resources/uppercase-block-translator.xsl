<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all">
	
	<xsl:import href="../../main/resources/xml/transform/block-translator-template.xsl"/>
	
	<xsl:template match="css:block" mode="#default after before">
		<xsl:variable name="uppercase-text" as="text()*">
			<xsl:apply-templates select=".//text()" mode="translate"/>
		</xsl:variable>
		<xsl:apply-templates select="node()[1]" mode="treewalk">
			<xsl:with-param name="new-text-nodes" select="$uppercase-text"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="text()" mode="translate">
		<xsl:variable name="inline-style" as="element()*"
		              select="css:computed-properties($inline-properties, true(), parent::*)"/>
		<xsl:variable name="uppercase" as="xs:string" select="upper-case(.)"/>
		<xsl:variable name="normalised" as="xs:string"
		              select="if ($inline-style[@name='white-space' and not(@value='normal')])
		                      then $uppercase
		                      else normalize-space($uppercase)"/>
		<xsl:variable name="hyphenated" as="xs:string"
		              select="if ($inline-style[@name='hyphens' and @value='auto'])
		                      then replace($normalised, 'FOOBAR', 'FOO=BAR')
		                      else $normalised"/>
		<xsl:value-of select="$hyphenated"/>
	</xsl:template>
	
	<xsl:template match="css:property[@name='hyphens' and @value='auto']" mode="translate-declaration-list">
		<xsl:sequence select="css:property('hyphens','manual')"/>
	</xsl:template>
	
</xsl:stylesheet>
