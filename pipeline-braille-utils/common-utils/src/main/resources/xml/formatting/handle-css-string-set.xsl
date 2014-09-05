<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <!--
        css-utils [2.0.0,3.0.0)
    -->
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(string(@style), 'string-set')]">
        <xsl:variable name="properties" as="element()*"
            select="css:specified-properties('#all string-set', true(), true(), true(), .)"/>
        <xsl:variable name="evaluated-string-set-property" as="element()?">
            <xsl:apply-templates select="$properties[@name='string-set']" mode="eval-string-set-property">
                <xsl:with-param name="context" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:copy>
            <xsl:sequence select="@*[not(name()='style')]"/>
            <xsl:sequence select="css:style-attribute(css:serialize-declaration-list(
                                    $properties[not(@name='string-set')]))"/>
            <xsl:if test="exists($evaluated-string-set-property)">
                <xsl:attribute name="css:string-set" select="$evaluated-string-set-property/@value"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:property[@name='string-set']" mode="eval-string-set-property" as="element()?">
        <xsl:if test="@value!='none'">
            <xsl:variable name="evaluated-string-set-pairs" as="element()*">
                <xsl:apply-templates select="css:parse-string-set(@value)" mode="eval-string-set-pair"/>
            </xsl:variable>
            <xsl:copy>
                <xsl:sequence select="@name"/>
                <xsl:attribute name="value" select="string-join(for $e in $evaluated-string-set-pairs return
                                                                  concat($e/@identifier,' ',$e/@value),
                                                                ', ')"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:string-set" mode="eval-string-set-pair" as="element()">
        <xsl:copy>
            <xsl:sequence select="@identifier"/>
            <xsl:variable name="evaluated-content" as="xs:string*">
                <xsl:apply-templates select="css:parse-content-list(@value, ())" mode="eval-content-list"/>
            </xsl:variable>
            <xsl:attribute name="value"
              select="concat('&quot;',replace(string-join($evaluated-content, ''), '[\s&#x2800;]+', ' '), '&quot;')"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:string" mode="eval-content-list" as="xs:string">
        <xsl:value-of select="string(@value)"/>
    </xsl:template>
    
    <xsl:template match="css:attr-fn" mode="eval-content-list" as="xs:string">
        <xsl:param name="context" as="element()" tunnel="yes"/>
        <xsl:variable name="name" select="string(@name)"/>
        <xsl:value-of select="string($context/@*[name()=$name])"/>
    </xsl:template>
    
    <xsl:template match="css:content-fn" mode="eval-content-list" as="xs:string">
        <xsl:param name="context" as="element()" tunnel="yes"/>
        <xsl:sequence select="string($context)"/>
    </xsl:template>
    
    <xsl:template match="css:string-fn" mode="eval-content-list">
        <xsl:message>string() function not supported in string-set property</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter-fn" mode="eval-content-list">
        <xsl:message>counter() function not supported in string-set property</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:target-text-fn" mode="eval-content-list">
        <xsl:message>target-text() function not supported in string-set property</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:target-string-fn" mode="eval-content-list">
        <xsl:message>target-string() function not supported in string-set property</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:target-counter-fn" mode="eval-content-list">
        <xsl:message>target-counter() function not supported in string-set property</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:leader-fn" mode="eval-content-list">
        <xsl:message>leader() function not supported in string-set property</xsl:message>
    </xsl:template>
    
    <xsl:template match="*" mode="eval-content-list">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
</xsl:stylesheet>
