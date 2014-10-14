<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <xsl:param name="property-names"/>
    <xsl:variable name="property-names-list" as="xs:string*" select="tokenize(normalize-space($property-names), ' ')"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@style">
        <xsl:variable name="properties" as="element()*" select="css:parse-declaration-list(.)"/>
        <!--
            filter
        -->
        <xsl:if test="not($property-names='#all')">
            <xsl:sequence select="css:style-attribute(css:serialize-declaration-list(
                                    $properties[not(@name=$property-names-list)]))"/>
        </xsl:if>
        <xsl:variable name="properties" as="element()*"
                      select="for $n in distinct-values(if ($property-names='#all')
                                                        then $properties/@name
                                                        else $property-names-list)
                              return $properties[@name=$n][last()]"/>
        <!--
            validate
        -->
        <xsl:variable name="properties" as="element()*">
            <xsl:apply-templates select="$properties[@name=$css:properties]" mode="css:validate">
                <xsl:with-param name="validate" select="true()"/>
            </xsl:apply-templates>
        </xsl:variable>
        <!--
            inherit
        -->
        <xsl:variable name="properties" as="element()*">
            <xsl:apply-templates select="$properties" mode="css:inherit">
                <xsl:with-param name="concretize-inherit" select="true()"/>
                <xsl:with-param name="concretize-initial" select="true()"/>
                <xsl:with-param name="validate" select="true()"/>
                <xsl:with-param name="context" select="parent::*"/>
            </xsl:apply-templates>
        </xsl:variable>
        <!--
            default
        -->
        <xsl:variable name="properties" as="element()*">
            <xsl:apply-templates select="$properties" mode="css:default">
                <xsl:with-param name="concretize-initial" select="true()"/>
            </xsl:apply-templates>
        </xsl:variable>
        <!--
            make attributes
        -->
        <xsl:apply-templates select="$properties" mode="css:property-as-attribute"/>
    </xsl:template>
    
</xsl:stylesheet>
