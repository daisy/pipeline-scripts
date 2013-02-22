<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-inline-prefixes="p px pxi xsl"
    type="pxi:add-metadata" name="add-metadata" version="1.0">
    
    <p:input port="source" primary="true" px:media-type="application/x-pef+xml"/>
    <p:input port="metadata"/>
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:param name="title" select="''"/>
                    <xsl:param name="creator" select="''"/>
                    <xsl:template match="pef:meta">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                            <xsl:if test="$title != ''">
                                <xsl:element name="dc:title">
                                    <xsl:sequence select="$title"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="$creator != ''">
                                <xsl:element name="dc:creator">
                                    <xsl:sequence select="$creator"/>
                                </xsl:element>
                            </xsl:if>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
        <p:with-param name="title" select="(
            /*/dc:title/string(),
            /*/*[@property=('dc:title','dcterms:title')]/string(),
            /*/*[@property=('dc:title','dcterms:title')]/@content/string())[1]">
            <p:pipe step="add-metadata" port="metadata"/>
        </p:with-param>
        <p:with-param name="creator" select="(
            /*/dc:creator/string(),
            /*/*[@property=('dc:creator','dcterms:creator')]/string(),
            /*/*[@property=('dc:creator','dcterms:creator')]/@content/string())[1]">
            <p:pipe step="add-metadata" port="metadata"/>
        </p:with-param>
    </p:xslt>
    
</p:declare-step>