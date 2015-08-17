<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all">
	
	<xsl:import href="../../main/resources/xml/transform/block-translator-template.xsl"/>
	
	<xsl:template match="css:block" mode="#all">
		<xsl:apply-templates select="node()[1]" mode="treewalk">
			<xsl:with-param name="new-text-nodes" select="for $t in //text() return upper-case($t)"/>
		</xsl:apply-templates>
	</xsl:template>
	
</xsl:stylesheet>
