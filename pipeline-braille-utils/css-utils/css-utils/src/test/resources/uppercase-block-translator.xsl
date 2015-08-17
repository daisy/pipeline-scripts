<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all">
	
	<xsl:import href="../../main/resources/xml/transform/block-translator-template.xsl"/>
	
	<xsl:template match="css:block" mode="#default after before string-set">
		<xsl:variable name="uppercase-text" as="text()*">
			<xsl:apply-templates select=".//text()" mode="uppercase"/>
		</xsl:variable>
		<xsl:apply-templates select="node()[1]" mode="treewalk">
			<xsl:with-param name="new-text-nodes" select="$uppercase-text"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="text()" mode="uppercase">
		<xsl:variable name="inline-style" as="element()*"
		              select="css:computed-properties($inline-properties, true(), parent::*)"/>
		<xsl:value-of select="if ($inline-style[@name='white-space' and @value='normal'])
		                      then normalize-space(upper-case(.))
		                      else upper-case(.)"/>
	</xsl:template>
	
</xsl:stylesheet>
