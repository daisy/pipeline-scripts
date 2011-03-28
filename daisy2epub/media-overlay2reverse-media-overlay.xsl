<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:smil="http://www.w3.org/ns/SMIL" xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">

    <xsl:template match="/*">
        <c:entry reverse-media-overlay="{//smil:text/tokenize(@src,'#')[1]}"/>
    </xsl:template>

</xsl:stylesheet>
