<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:hyphen="http://hunspell.sourceforge.net/Hyphen"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-inline-prefixes="p px xsl"
    type="px:xml-to-pef.load-translator" version="1.0">
    
    <p:output port="result" primary="true" sequence="true"/>
    <p:option name="translator" required="true"/>
    
    <p:choose>
        <p:when test="contains($translator, ',http:/')">
            <px:xml-to-pef.load-translator name="first">
                <p:with-option name="translator" select="substring-before($translator, ',http:/')"/>
            </px:xml-to-pef.load-translator>
            <p:sink/>
            <px:xml-to-pef.load-translator name="rest">
                <p:with-option name="translator" select="concat('http:/', substring-after($translator, ',http:/'))"/>
            </px:xml-to-pef.load-translator>
            <p:sink/>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="first" port="result"/>
                    <p:pipe step="rest" port="result"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:choose>
                <p:when test="matches($translator, '^http:/.*')">
                    <p:try>
                        <p:group>
                            <p:load>
                                <p:with-option name="href" select="$translator"/>
                            </p:load>
                            <p:choose>
                                <p:when test="/p:pipeline or /xsl:stylesheet">
                                    <p:identity/>
                                </p:when>
                                <p:otherwise>
                                    <p:error code="px:brl02">
                                        <p:input port="source">
                                            <p:inline><message>Translator is neither a &lt;xsl:stylesheet&gt; nor a &lt;p:pipeline&gt;.</message></p:inline>
                                        </p:input>
                                    </p:error>
                                </p:otherwise>
                            </p:choose>
                        </p:group>
                        <p:catch>
                            <p:choose>
                                <p:when test="matches($translator, '.*(\.cti|\.ctb|\.utb)$')">
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
                                        <p:with-option name="attribute-value" select='concat("&apos;", $translator, "&apos;")'/>
                                    </p:add-attribute>
                                </p:when>
                                <p:when test="matches($translator, '.*\.dic$')">
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
                                        <p:with-option name="attribute-value" select='concat("&apos;", $translator, "&apos;")'/>
                                    </p:add-attribute>
                                </p:when>
                                <p:otherwise>
                                    <p:error code="px:brl01">
                                        <p:input port="source">
                                            <p:inline><message>Translator could not be loaded.</message></p:inline>
                                        </p:input>
                                    </p:error>
                                </p:otherwise>
                            </p:choose>
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
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
