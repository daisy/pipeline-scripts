<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:hyphen="http://hunspell.sourceforge.net/Hyphen"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    exclude-inline-prefixes="p px xsl"
    type="px:xml-to-pef.load-translator" version="1.0">
    
    <p:output port="result" primary="true" sequence="true"/>
    <p:option name="translator" required="true"/>
    
    <p:try>
        <p:group>
            <p:xslt template-name="main">
                <p:input port="source">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="../xslt/load-translator.xsl"/>
                </p:input>
                <p:with-param name="translator" select="$translator"/>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
        </p:group>
        <p:catch name="catch-error">
            <p:variable name="cause" select="string(/*/c:error[1])">
                <p:pipe step="catch-error" port="error"/>
            </p:variable>
            <p:string-replace match="/message/text()" name="error-message">
                <p:input port="source">
                    <p:inline><message>$message</message></p:inline>
                </p:input>
                <p:with-option name="replace" select="concat('&quot;Could not load translator ', $translator, '. ', $cause, '&quot;')"/>
            </p:string-replace>
            <p:error code="px:brl01" name="error">
                <p:input port="source">
                    <p:pipe step="error-message" port="result"/>
                </p:input>
            </p:error>
        </p:catch>
    </p:try>
    
    <p:filter select="//d:translator"/>

    <p:for-each name="translators">
        <p:choose>
            <p:xpath-context>
                <p:pipe step="translators" port="current"/>
            </p:xpath-context>
            <p:when test="/d:translator/@kind='xml'">
                <p:load>
                    <p:with-option name="href" select="/d:translator/@href"/>
                </p:load>
            </p:when>
            <p:when test="/d:translator/@kind='liblouis'">
                <p:add-attribute attribute-name="select" match="//xsl:variable[@name='table']">
                    <p:input port="source">
                        <p:inline>
                            <xsl:stylesheet version="2.0">
                                <xsl:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xslt/block-translator-template.xsl"/>
                                <xsl:variable name="table"/>
                                <xsl:template match="css:block">
                                    <xsl:sequence select="louis:translate($table, string(.))"/>
                                </xsl:template>
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-value" select='concat("&apos;", /d:translator/@href, "&apos;")'/>
                </p:add-attribute>
            </p:when>
            <p:when test="/d:translator/@kind='libhyphen'">
                <p:add-attribute attribute-name="select" match="//xsl:variable[@name='table']">
                    <p:input port="source">
                        <p:inline>
                            <xsl:stylesheet version="2.0">
                                <xsl:variable name="table"/>
                                <xsl:template match="text()">
                                    <xsl:sequence select="hyphen:hyphenate($table, string(.))"/>
                                </xsl:template>
                                <xsl:template match="element()|@*|comment()|processing-instruction()">
                                    <xsl:copy>
                                        <xsl:apply-templates select="@*|node()"/>
                                    </xsl:copy>
                                </xsl:template>
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-value" select='concat("&apos;", /d:translator/@href, "&apos;")'/>
                </p:add-attribute>
            </p:when>
            <p:when test="/d:translator/@kind='texhyph'">
                <p:add-attribute attribute-name="select" match="//xsl:variable[@name='table']">
                    <p:input port="source">
                        <p:inline>
                            <xsl:stylesheet version="2.0">
                                <xsl:variable name="table"/>
                                <xsl:template match="text()">
                                    <xsl:sequence select="tex:hyphenate($table, string(.))"/>
                                </xsl:template>
                                <xsl:template match="element()|@*|comment()|processing-instruction()">
                                    <xsl:copy>
                                        <xsl:apply-templates select="@*|node()"/>
                                    </xsl:copy>
                                </xsl:template>
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-value" select='concat("&apos;", /d:translator/@href, "&apos;")'/>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    
</p:declare-step>
