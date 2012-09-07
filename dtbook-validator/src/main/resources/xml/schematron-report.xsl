<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all">
    <xsl:template match="/">
        <section>
            <h2>Schematron Validation Results</h2>
            <xsl:apply-templates/>
        </section>
    </xsl:template>
    
    <xsl:template match="svrl:schematron-output">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    <xsl:template match="svrl:failed-assert">
        <!-- TODO a way to get line numbers? -->
        <li>
            <xsl:value-of select="svrl:text/text()"/>
        </li>
    </xsl:template>
    
</xsl:stylesheet>