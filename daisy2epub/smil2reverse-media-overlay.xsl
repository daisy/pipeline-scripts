<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="/*">
        <c:entry reverse-media-overlay="{(//*[local-name()='text'])[1]/tokenize(@src,'#')[1]}"/>
    </xsl:template>

</xsl:stylesheet>
