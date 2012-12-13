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
        
        <!-- TODO refine this test -->
        <xsl:choose>
            <xsl:when test="svrl:failed-assert">
                <ul>
                    <xsl:apply-templates/>
                </ul>    
            </xsl:when>
            <xsl:when test="svrl:successful-report">
                <ul>
                    <xsl:apply-templates/>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <p>No errors detected.</p>        
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- failed asserts and successful reports are both notable events in SVRL -->
    
    <xsl:template match="svrl:failed-assert | svrl:successful-report">
        <!-- TODO can we output the line number too? -->
        <li class="error">
            <p><xsl:value-of select="svrl:text/text()"/></p>
            <div>
                <h3>Location (XPath)</h3>
                <pre><xsl:value-of select="@location"/></pre>
            </div>
        </li>
    </xsl:template>
    
    
</xsl:stylesheet>