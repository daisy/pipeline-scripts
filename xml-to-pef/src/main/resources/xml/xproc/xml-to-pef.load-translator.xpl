<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="p px xsl"
    type="px:xml-to-pef.load-translator" version="1.0">
    
    <p:output port="result" primary="true"/>
    <p:option name="translator" required="true"/>
    
    <p:choose>
        <p:when test="matches($translator, '^http:/.*')">
            <p:try>
                <p:group>
                    <p:load>
                        <p:with-option name="href" select="$translator"/>
                    </p:load>
                </p:group>
                <p:catch>
                    <!-- If the URL is not a document, it must be a liblouis table -->
                    <p:add-attribute attribute-name="select" match="//xsl:variable[@name='table']">
                        <p:input port="source">
                            <p:inline>
                                <xsl:stylesheet version="2.0">
                                    <xsl:variable name="table"/>
                                    <xsl:variable name="hyphenate" select="'false'"/>
                                    <xsl:template match="/*">
                                        <xsl:copy>
                                            <xsl:sequence select="louis:translate($table, string(.), (), $hyphenate='true')"/>
                                        </xsl:copy>
                                    </xsl:template>
                                </xsl:stylesheet>
                            </p:inline>
                        </p:input>
                        <p:with-option name="attribute-value" select='concat("&apos;", $translator, "&apos;")'/>
                    </p:add-attribute>
                </p:catch>
            </p:try>
        </p:when>
        <p:otherwise>
            <p:error code="px:brl01">
                <p:input port="source">
                    <p:inline><message>The option 'translator' must be of the form 'http:/...'.</message></p:inline>
                </p:input>
            </p:error>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
