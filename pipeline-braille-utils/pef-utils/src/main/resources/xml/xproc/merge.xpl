<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pef:merge" name="merge"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-inline-prefixes="px p"
    version="1.0">

    <p:input port="source" sequence="true" primary="true" px:media-type="application/x-pef+xml"/>
    <p:input port="parameters" kind="parameter" primary="true"/>
    <p:output port="result" sequence="false" primary="true" px:media-type="application/x-pef+xml"/>

    <p:xslt template-name="initial" name="head">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0" xmlns="http://www.daisy.org/ns/2008/pef">
                    <xsl:param name="title" select="''"/>
                    <xsl:param name="creator" select="''"/>
                    <xsl:template name="initial">
                        <head>
                            <meta>
                                <xsl:if test="$title != ''">
                                    <dc:title>
                                        <xsl:sequence select="$title"/>
                                    </dc:title>
                                </xsl:if>
                                <xsl:if test="$creator != ''">
                                    <dc:creator>
                                        <xsl:sequence select="$creator"/>
                                    </dc:creator>
                                </xsl:if>
                                <dc:date>
                                    <xsl:sequence select="current-date()"/>
                                </dc:date>
                                <dc:format>
                                    <xsl:text>application/x-pef+xml</xsl:text>
                                </dc:format>
                                <dc:identifier>
                                    <xsl:text> </xsl:text>
                                </dc:identifier>
                            </meta>
                        </head>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    
    <p:wrap-sequence wrapper="body" wrapper-namespace="http://www.daisy.org/ns/2008/pef" name="body">
        <p:input port="source" select="//pef:volume">
            <p:pipe step="merge" port="source"/>
        </p:input>
    </p:wrap-sequence>
    
    <p:wrap-sequence wrapper="pef" wrapper-namespace="http://www.daisy.org/ns/2008/pef">
        <p:input port="source">
            <p:pipe step="head" port="result"/>
            <p:pipe step="body" port="result"/>
        </p:input>
    </p:wrap-sequence>
    
    <p:add-attribute match="/pef:pef" attribute-name="version" attribute-value="2008-1"/>
    
    <p:uuid match="//dc:identifier/text()[1]" name="output"/>
    
</p:declare-step>