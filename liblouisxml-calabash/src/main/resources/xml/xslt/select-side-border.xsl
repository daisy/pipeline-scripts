<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-result-prefixes="lblxml"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <lblxml:no-pagenum>
                <xsl:sequence select="descendant::lblxml:side-border[1]/*"/>
            </lblxml:no-pagenum>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>