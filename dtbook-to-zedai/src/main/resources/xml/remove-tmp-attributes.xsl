<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    xmlns:rend="http://www.daisy.org/ns/z3998/authoring/features/rend/"
    xmlns:its="http://www.w3.org/2005/11/its" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns="http://www.daisy.org/ns/z3998/authoring/"
    exclude-result-prefixes="xs tmp">
    
    <xsl:output indent="yes" method="xml"/>
    
    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:message>Removing temporary attributes.</xsl:message>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- discard tmp: attributes, which were used to hold css data prior to extraction -->
    <!--<xsl:template match="@tmp:*"/>-->
    
</xsl:stylesheet>
