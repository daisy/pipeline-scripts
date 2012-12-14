<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="#all"
    type="pxi:build-translation-pipeline" version="1.0">
    
    <p:output port="result" primary="true"/>
    <p:option name="translator" required="true"/>
    <p:option name="hyphenator" required="false" select="'none'"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <!-- Load hyphenator -->
    
    <p:choose name="hyphenator">
        <p:when test="$hyphenator='texhyphj'">
            <p:output port="result" sequence="true"/>
            <p:identity>
                <p:input port="source">
                    <p:document href="../xslt/tex-hyphenate.xsl"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:output port="result" sequence="true"/>
            <p:identity>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
    <!-- Load translator -->
    
    <p:choose name="translator">
        <p:when test="$translator=''">
            <p:output port="result"/>
            <p:load>
                <p:with-option name="href" select="'../xslt/simple-liblouis-translate.xsl'"/>
            </p:load>
        </p:when>
        <p:when test="matches($translator, '^http:/.*')">
            <p:output port="result"/>
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
                                    <xsl:variable name="hyphenation"/>
                                    <xsl:template match="/*">
                                        <xsl:copy>
                                            <xsl:sequence select="louis:translate($table, string(.), (), $hyphenation)"/>
                                        </xsl:copy>
                                    </xsl:template>
                                </xsl:stylesheet>
                            </p:inline>
                        </p:input>
                        <p:with-option name="attribute-value" select='concat("&apos;", $translator, "&apos;")'/>
                    </p:add-attribute>
                    <p:add-attribute attribute-name="select" match="//xsl:variable[@name='hyphenation']">
                        <p:with-option name="attribute-value" select="if ($hyphenator='liblouis') then 'true' else 'false')"/>
                    </p:add-attribute>
                </p:catch>
            </p:try>
        </p:when>
        <p:otherwise>
            <p:output port="result"/>
            <p:error code="px:brl01">
                <p:input port="source">
                    <p:inline><message>The option 'translator' must be of the form 'http:/...'.</message></p:inline>
                </p:input>
            </p:error>
        </p:otherwise>
    </p:choose>
    
    <!-- Combine into a single pipeline -->
    
    <p:wrap-sequence wrapper="wrap">
        <p:input port="source">
            <p:pipe step="hyphenator" port="result"/>
            <p:pipe step="translator" port="result"/>
        </p:input>
    </p:wrap-sequence>
    <p:choose>
        <p:when test="/*/p:pipeline and count(/*/*)=1">
            <p:identity>
                <p:input port="source">
                    <p:pipe step="hyphenator" port="result"/>
                    <p:pipe step="translator" port="result"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:group>
                <p:for-each name="steps">
                    <p:iteration-source>
                        <p:pipe step="hyphenator" port="result"/>
                        <p:pipe step="translator" port="result"/>
                    </p:iteration-source>
                    <p:choose>
                        <p:when test="/xsl:stylesheet">
                            <p:insert match="//p:inline" position="first-child">
                                <p:input port="source">
                                    <p:inline>
                                        <p:xslt>
                                            <p:input port="stylesheet">
                                                <p:inline></p:inline>
                                            </p:input>
                                            <p:input port="parameters">
                                                <p:empty/>
                                            </p:input>
                                        </p:xslt>
                                    </p:inline>
                                </p:input>
                                <p:input port="insertion">
                                    <p:pipe step="steps" port="current"/>
                                </p:input>
                            </p:insert>
                        </p:when>
                        <p:when test="/p:pipeline">
                            <p:insert match="//p:inline" position="first-child">
                                <p:input port="source">
                                    <p:inline>
                                        <cx:eval>
                                            <p:input port="pipeline">
                                                <p:inline></p:inline>
                                            </p:input>
                                            <p:input port="options">
                                                <p:empty/>
                                            </p:input>
                                        </cx:eval>
                                    </p:inline>
                                </p:input>
                                <p:input port="insertion">
                                    <p:pipe step="steps" port="current"/>
                                </p:input>
                            </p:insert>
                        </p:when>
                        <p:otherwise>
                            <p:error code="px:brl02">
                                <p:input port="source">
                                    <p:inline><message>The translator document is neither a &lt;xsl:stylesheet&gt; nor a &lt;p:pipeline&gt;.</message></p:inline>
                                </p:input>
                            </p:error>
                        </p:otherwise>
                    </p:choose>
                </p:for-each>
                <p:wrap-sequence wrapper="p:pipeline"/>
                <p:add-attribute match="/*" attribute-name="version" attribute-value="1.0"/>
            </p:group>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
