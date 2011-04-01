<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:html="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:template match="/*">
        <c:metadata>
            <!--xsl:for-each select="//html:head/html:meta"-->
                <!-- what kind of metadata in content documents are global? is there any? -->
            <!--/xsl:for-each-->
        </c:metadata>
    </xsl:template>
    
</xsl:stylesheet>
