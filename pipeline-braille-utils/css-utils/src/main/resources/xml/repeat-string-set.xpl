<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:repeat-string-set"
                exclude-inline-prefixes="p xsl"
                version="1.0">
    
    <!--
        Assumptions:
        - root elements have no @css:string-set or @css:string-entry attributes
    -->
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    
    <p:import href="shift-string-set.xpl"/>
    
    <p:for-each>
        <p:xslt>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="2.0">
                        <xsl:include href="library.xsl"/>
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:sequence select="@*"/>
                                <xsl:apply-templates select="@css:string-entry"/>
                                <xsl:apply-templates select="@css:string-set"/>
                                <xsl:apply-templates/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="@css:string-set|@css:string-entry">
                            <xsl:sequence select="css:parse-string-set(.)"/>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:identity name="iteration-source"/>
    <p:for-each>
        <p:identity name="current-section"/>
        <p:split-sequence>
            <p:input port="source">
                <p:pipe step="iteration-source" port="result"/>
            </p:input>
            <p:with-option name="test" select="concat('position()&lt;',p:iteration-position())"/>
        </p:split-sequence>
        <p:wrap-sequence wrapper="_" name="preceding-sections"/>
        <p:insert match="/*" position="first-child">
            <p:input port="source">
                <p:pipe step="current-section" port="result"/>
            </p:input>
            <p:input port="insertion"
                     select="for $n in distinct-values(//css:string-set/@name)
                             return (//css:string-set[@name=$n])[last()]">
                <p:pipe step="preceding-sections" port="result"/>
            </p:input>
        </p:insert>
    </p:for-each>
    
    <p:for-each>
        <p:xslt>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="2.0">
                        <xsl:include href="library.xsl"/>
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="/*">
                            <xsl:copy>
                                <xsl:if test="child::css:string-set">
                                    <xsl:attribute name="css:string-entry"
                                                   select="css:serialize-string-set(child::css:string-set)"/>
                                </xsl:if>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="css:string-set"/>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
</p:declare-step>
