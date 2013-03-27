<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	exclude-result-prefixes="#all">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xslt/block-translator-template.xsl"/>
	
	<xsl:template match="css:block">
		<xsl:sequence select="normalize-space(string(.))"/>
	</xsl:template>
	
</xsl:stylesheet>
